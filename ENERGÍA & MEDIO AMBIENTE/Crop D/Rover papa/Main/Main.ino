#include "Arduino.h"
#include <SoftwareSerial.h>
#include <LiquidCrystal_I2C.h>  // librería para el LCD por I2C
#include <RTClib.h>             // librería para el RTCLib
#include <TinyGPS++.h>
#include "WString.h"
#include "record.h"
#include "display.h"
#include "brigthness.h"
#include "temperature_humidity.h"
#include "clock.h"
#include "soil.h"
#include "gp.h"


#define boton 45

const int humedadAire = 780;
const int humedadAgua = 10;

static const int RXPin = 2, TXPin = 3;

int contador = 0;
int estado = digitalRead(boton);
int estado_anterior = estado;


void setup() {
  pinMode(boton, INPUT);
  Serial.begin(9600); // Iniciar comunicación serie para monitoreo
  start_gp();
  Serial.println("0 setup");
  start_dht();
  start_lux();
  //start_dht();
  start_clock();
  Serial.println("E setup");

}

void loop() {
    //----Llamado de las funciones----
    
    gp(false);
    estado = digitalRead(boton);
    int porcentaje = soil();
    uint16_t luminosidad = lux();
    float * sensor_dht= temp_hum();
    String fecha = day();
    if(estado != estado_anterior) {     
      contador++;
      start_Display("Guardando datos"," ",false);
      Serial.print("Guardando datos");
      write_record(contador,luminosidad,sensor_dht[0],sensor_dht[1],sensor_dht[2],sensor_dht[3], porcentaje, fecha);
      gp(true);
      estado_anterior= estado;
      delay(0);
    }
   // Serial.println("Esperando la toma los datos");
    start_Display("Click para tomar","los datos!!",0); 
      Serial.print("Sensor 1: ");
      Serial.print(sensor_dht[0]);
      Serial.print(" ");
      Serial.print(sensor_dht[1]); 
      Serial.print("Sensor 2: ");
      Serial.print(sensor_dht[2]);
      Serial.print(" ");
      Serial.println(sensor_dht[3]); 
   // Serial.println(gpd[0]);
   // Serial.println(gpd[1]);
    //else{
    //  start_Display("No se guardaron datos :(");
    //}  
     
}