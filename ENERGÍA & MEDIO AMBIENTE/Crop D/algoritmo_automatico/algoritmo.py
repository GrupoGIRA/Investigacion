#!/usr/bin/env python
# coding: utf-8

# ### Claves del json

# In[72]:


#Keys
crop_keys = [{"name": "string"}, {"address": 'string'}, {"analysisSoil": 'string'}, {"areaUnits": 'string'}, {"calcium": 'float'}, {"creationDate": 'date'}, {"distanceForrows": 'float'}, {"distancePlants": 'float'}, {"electricConductivity": 'float'}, {"floorType": 'string'}, {"landArea": 'float'}, {"lastModification": 'date'}, {"latitude": 'float'}, {"longitude": 'float'}, {"nitrogen": 'float'}, {"ph": 'float'}, {"phosphorus": 'float'}, {"potassium": 'float'}, {"previusCrop": 'string'}, {"satAluminum": 'float'}, {"seed": 'string'}, {"seedtime": 'date'}, {"sodium": 'float'}, {"species": 'string'}, {"topographyFloor": 'string'}, {"variety": 'string'}]
samplings_keys = [{"creationDate": 'date'}, {"cropAge": 'string'}, {"lastModification": "date"}, {"observationCrop": "string"}]
observaciones_keys = [{"creationDate":"date"}, {"incidence":"int"}, {"insectPopulation": "int"}, {"insufficiencyOf": "string"}, {"leafColor": "array"}, {"modificationDate": "date"}, {"observations": "string"}, {"otherColorLeaf": "string"}, {"otherDiagnosis": "string"}, {"otherSymptoms": "string"}, {"plantHeight": "float"}, {"preliminaryDiagnosisAbiotic": "array"}, {"preliminaryDiagnosisBacteria": "array"}, {"preliminaryDiagnosisFungus": "array"}, {"preliminaryDiagnosisPests": "array"}, {"preliminaryDiagnosisVirus": "array"}, {"sample": "string"}, {"severity": "string"}, {"symptoms": "array"}, {"ws_counter": "int"}, {"ws_dateAge": "int"}, {"ws_distance": "float"}, {"ws_hdop": "int"}, {"ws_height": "float"}, {"ws_humidity1": "float"}, {"ws_humidity2": "float"}, {"ws_illumination": "int"}, {"ws_latitude": "float"}, {"ws_longitude": "float"}, {"ws_satellites": "int"}, {"ws_soilMoisture": "int"}, {"ws_speed": "float"}, {"ws_temperature1": "float"}, {"ws_temperature2": "float"}]
id_keys = ["timestamp", "randomValue1", "randomValue2", "counter"]
micasense_keys = ['FileName','SourceFile','MIMEType', 'CaptureId', 'PressureAlt', 'BandName', 'Bandwidth', 'FocalLength', 'Make', 'Model', 'GPSLatitude', 'GPSLongitude', 'GPSAltitude']


# In[73]:


import pandas as pd
import pymongo
from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime
from PIL import Image
from PIL.ExifTags import TAGS
import pytz
import subprocess
import json
import os


# ### Definición de variables

# In[74]:


db_name = 'prueba2'
db_conection_url = 'mongodb://mongoadmin:secret@127.0.0.1:27017'
mg_client = MongoClient(db_conection_url)
db = mg_client[db_name]
captures_path = './captures'
multiespectral_path = './multiespectrales'
zona_horaria = pytz.timezone('America/Bogota')

maximum_humidity = 700 #700 es un valor por defecto aproximado
minimum_humidity = 200 #200 es un valor por defecto aproximado


# In[75]:


records_count = 0


# In[82]:


def id_json_to_hex1(json):
    return "".join(hex(json[key])[2:] for key in id_keys)


def id_json_to_hex(json):
    # Convertimos cada valor según las especificaciones dadas, utilizando formateo para controlar la longitud
    timestamp_hex = "{:08x}".format(json["timestamp"])
    randomValue1_hex = "{:06x}".format(json["randomValue1"])

    randomValue2_hex = "{:04x}".format(json["randomValue2"])
    randomValue2_hex = randomValue2_hex.zfill(4) if len(randomValue2_hex) == 3 else randomValue2_hex
    counter_hex = "{:06x}".format(json["counter"])

    # Concatenamos los segmentos para formar el ObjectId
    hex_str = timestamp_hex + randomValue1_hex + randomValue2_hex + counter_hex
    return hex_str


def insert_record(record, collection):
    try:
        response = db[collection].insert_one(record)
        return response.inserted_id
    except NameError:
        print(NameError)
        return False


def calc_humidity(measure):
    humidity = 100*(measure - maximum_humidity)/(minimum_humidity - maximum_humidity)
    if humidity > 100: return 100
    if humidity < 0: return 0
    return humidity


def parse(value, data_type):
    if value == '': return value
    global records_count
    records_count = records_count + 1
    if data_type == 'string' or data_type == 'array' :return value
    if data_type == 'int': return int(value)
    if data_type == 'float': return float(value)
    if data_type == 'date': return localize_date(datetime.strptime(value, "%Y-%m-%d"))

def localize_date(date):
    date_localized = zona_horaria.localize(date)
    return date_localized.astimezone(pytz.utc)
    
#Convierte una coordenada en formato de grados minutos y segundos a decimal
def dms_to_decimal(coo, direction):
    if(len(coo) == 0): return None 
    decimal = coo[0] + coo[1] / 60 + coo[2] / 3600
    if direction in ['S', 'W']:
        decimal = -decimal
    return decimal


def captures_metadata_filter(metadata):
    gps_info = metadata['GPSInfo']
    if (len(metadata['GPSInfo']) == 0):
        gps_info[1] = ""
        gps_info[2] = []
        gps_info[3] = ""
        gps_info[4] = []
        gps_info[6] = 0

    captures_metadata = {
    "xResolution" : float(metadata['XResolution']),
    "yResolution" : float(metadata['YResolution']),
    "resolutionUnit" : int(metadata['ResolutionUnit']),
    "dateTime" : localize_date(datetime.strptime(metadata['DateTime'], "%Y:%m:%d %H:%M:%S")),
    "make" : metadata['Make'],
    "model" : metadata['Model'],
    "gpsLatitude" : [float(x) for x in gps_info[2]],
    "gpsLatitudeDirection" : gps_info[1],
    "gpsLongitude" : [float(x) for x in gps_info[4]],
    "gpsLongitudeDirection" : gps_info[3],
    "gpsAltitude" : float(gps_info[6]) }
    
    return captures_metadata
    
    
def get_image_metadata(image_path):
    # Abrir la imagen
    image = Image.open(image_path)

    # Extraer metadatos EXIF
    exif_data = image._getexif()

    # Convertir los códigos EXIF en legibles
    readable_exif = {}
    if exif_data:
        for tag, value in exif_data.items():
            readable_tag = TAGS.get(tag, tag)
            readable_exif[readable_tag] = value

    return readable_exif

def get_multiespectral_image_metadata(image_path):

    # Llamar a ExifTool para extraer los metadatos
    result = subprocess.run(['exiftool', '-json', image_path], stdout=subprocess.PIPE)

    # Convertir la salida de ExifTool de JSON a un objeto Python
    metadata = json.loads(result.stdout)[0]
    
    metadata_filtered = {}
    for key in micasense_keys:
        if key in metadata:
            metadata_filtered[key] = metadata[key]
    return metadata_filtered


def multiespectral_process(sampling_id):
    path = multiespectral_path + '/' + sampling_id
    entradas = os.listdir(path)

    # Filtrar y mostrar solo las carpetas (los vuelos)
    fligths = []
    for nombre in entradas:
        ruta = os.path.join(path, nombre)
        if os.path.isdir(ruta):
            fligths.append(nombre)

    _id_images = []
    for fligth in fligths:
        path_images_multi = path + '/' + fligth

        # Listar y ordenar todos los archivos y carpetas en el directorio
        files = os.listdir(path_images_multi)
        files.sort()

        # Filtrar y procesar solo los archivos .tif
        for nombre in files:
            if nombre.endswith('.tif'):
                metadata = get_multiespectral_image_metadata(path_images_multi + '/' + nombre)
                metadata['flightId'] = fligth
                _id = insert_record(metadata, 'multiespectral_images')
                _id_images.append(_id)
    return _id_images


# Extrae y procesa los datos de un array de imagenes
# captures: un array con el nombre de las imagenes a procesar
# root_path: la ruta donde estan ubicadas esas imagenes
def captures_process(captures, root_path):
    id_captures = []
    last_date = None
    latitude, longitude, gps_latitude_direction, gps_longitude_direction = [], [], None, None

    for capture in captures:
        image_path = root_path + '/' + capture
        metadata = get_image_metadata(image_path)
        captures_metadata = captures_metadata_filter(metadata)
        captures_metadata = {**captures_metadata, 'fileName': capture}
        
        id_capture = insert_record(captures_metadata, 'captures')
        
        id_captures.append(id_capture)
        last_date = captures_metadata['dateTime']
        latitude = captures_metadata['gpsLatitude']
        longitude = captures_metadata['gpsLongitude']
        gps_latitude_direction = captures_metadata['gpsLatitudeDirection']
        gps_longitude_direction = captures_metadata['gpsLongitudeDirection']

    latitude = dms_to_decimal(latitude, gps_latitude_direction)
    longitude = dms_to_decimal(longitude, gps_longitude_direction)
    
    return id_captures, last_date, latitude, longitude


# Procesa la observación
# observation_data: json con los valores de la observación generados por la app
def observation_process(observation_data, sampling_id):
    _id = id_json_to_hex(observation_data["_id"])

    root_path_images = captures_path + '/' + sampling_id + '/' + _id
    _id_captures_inserted, creation_date, latitude, longitude = captures_process(observation_data['captures'], root_path_images)
    
    observation_parsed = {
        '_id': ObjectId(_id)
    }
    for key_dict in observaciones_keys:
        key = next(iter(key_dict))
        data_type = key_dict[key]
        
        value = observation_data[key]
        parsed = parse(value, data_type)
        observation_parsed[key] = parsed
  
    ws_dateTime = creation_date if creation_date != None else observation_parsed['creationDate']
    observation_parsed['ws_dateTime'] = ws_dateTime
    soilMoisturePercentage = calc_humidity(int(observation_data['ws_soilMoisture']))
    observation_parsed['soilMoisturePercentage'] = soilMoisturePercentage
    observation_parsed['captures'] = _id_captures_inserted
    
    if(latitude == None or longitude == None):
        observation_parsed["latitude"] = observation_parsed["ws_latitude"]
        observation_parsed["longitude"] = observation_parsed["ws_longitude"]

    id_observation = insert_record(observation_parsed, 'observations')
    
    return id_observation


def sampling_process(sampling):
    #maximum_humidity = int(input('Ingrese medición del aire: '))
    #minimum_humidity = int(input('Ingrese medición del agua: '))
    _id = id_json_to_hex(sampling["_id"])
    sampling_parsed = {"_id": ObjectId(_id)}

    id_observations = []
    for observation in sampling['observations']:
        id_observation = observation_process(observation, _id)
        id_observations.append(id_observation)
    
    for key_dict in samplings_keys:
        key = next(iter(key_dict))
        data_type = key_dict[key]
        value = sampling[key]
        parsed = parse(value, data_type)
        sampling_parsed[key] = parsed
    sampling_parsed["observations"] = id_observations
    
    id_multiespectral_images = multiespectral_process(_id)
    sampling_parsed['multiespectral_images'] = id_multiespectral_images
    
    id_sampling = insert_record(sampling_parsed, 'samplings')
    return id_sampling


def crop_process(crop):
    _id = id_json_to_hex(crop['_id'])
    crop_parsed = {
        '_id': ObjectId(_id),
    }

    for key_dict in crop_keys:
        key = next(iter(key_dict))
        data_type = key_dict[key]
        value = crop[key]
        parsed = parse(value, data_type)
        crop_parsed[key] = parsed

    id_samplings = []    
    for sampling in crop['samplings']:
        id_sampling = sampling_process(sampling)
        id_samplings.append(id_sampling)

    crop_parsed['samplings'] = id_samplings
    id_crop = insert_record(crop_parsed, 'crops2')


# In[6]:


df = pd.read_json("./datos_final.json")


# In[83]:


df.apply(lambda crop: crop_process(crop), axis=1)


# In[38]:


multi_image = './multiespectrales/657cbe2ba42138148a4b0eb2/K4dzFYM5NzpCiqy2xT0o/IMG_0000_1.tif'


# In[51]:


directorio = './multiespectrales/'


# In[66]:


multiespectral_process('6583073a68dd6045097d5f49')


# In[ ]:




