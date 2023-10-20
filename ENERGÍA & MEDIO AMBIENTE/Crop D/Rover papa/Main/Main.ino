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
#include "ble.h"


#define boton 45
#define  BLE Serial1


const int humedadAire = 780;
const int humedadAgua = 10;

static const int RXPin = 2, TXPin = 3;

int contador = 0;
//int estado = digitalRead(boton);
//int estado_anterior = estado;
char dato = 'z';

void setup() {
  pinMode(boton, INPUT);
  Serial.begin(9600); // Iniciar comunicación serie para monitoreo
  BLE.begin(38400);
  start_gp();
  Serial.println("0 setup");
  start_dht();
  start_lux();
  start_clock();
  start_ble();
  Serial.println("E setup");

}

void loop() {
    //----Llamado de las funciones----
    
    gp(false);
    //estado = digitalRead(boton);
    int porcentaje = soil();
    uint16_t luminosidad = lux();
    float * sensor_dht= temp_hum();
    String fecha = day();

    if (BLE.available()) {
    dato = (char) BLE.read();}

    if(strcmp(dato, 'a') == 0) {     
      contador++;
      start_Display("Guardando datos"," ",false);
      Serial.print("Guardando datos");
      write_record(contador,luminosidad,sensor_dht[0],sensor_dht[1],sensor_dht[2],sensor_dht[3], porcentaje, fecha);
      gp(true);
      //estado_anterior= estado;
      String linea = last();
      Serial.println(linea);
      BLE.println(linea);
      dato = 'z';
      delay(0);
    }
   // Serial.println("Esperando la toma los datos");
    start_Display("Click para tomar","los datos!!",0); 
    //else{
    //  start_Display("No se guardaron datos :(");
    //}  
     
}