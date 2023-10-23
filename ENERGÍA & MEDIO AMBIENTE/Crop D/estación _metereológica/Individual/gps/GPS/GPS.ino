#include <SoftwareSerial.h>
#include <TinyGPS.h>
#include "Arduino.h"
#include <SPI.h>    // incluye libreria interfaz SPI
#include <SD.h>     // incluye libreria para tarjetas SD

long lat,lon;
SoftwareSerial gpsSerial(2, 3);
TinyGPS gps;
void setup() {
  Serial.begin(9600);
  gpsSerial.begin(9600);
}
#define SSpin 53    // Slave Select en pin digital 10

File archivo;     // objeto archivo del tipo File

void writeSD(long line) {
  if (!SD.begin(SSpin)) {     // inicializacion de tarjeta SD
    //start_Display("fallo en inicializacion !");
    Serial.println("fallo en inicializacion !");// si falla se muestra texto correspondiente y
    return;         // se sale del setup() para finalizar el programa
  }
  
  archivo = SD.open("prueba2.txt", FILE_WRITE);  // apertura para lectura/escritura de archivo prueba.txt

  if (archivo) {
    archivo.println(line);  // escritura de una linea de texto en archivo
    archivo.close();        // cierre del archivo
    //start_Display("escritura correcta");
    Serial.println("escritura correcta"); // texto de escritura correcta en monitor serie
  } else {
    Serial.println("error en apertura de prueba.txt");  // texto de falla en apertura de archivo
    //start_Display("error en apertura de prueba.txt");
  }
}

void loop() {

  
  while(gpsSerial.available()){

    if(gps.encode(gpsSerial.read())){
      gps.get_position(&lat,&lon);
      float vitesse = gps.f_speed_kmph();
      Serial.print("Position: ");
      Serial.print("Lattitude: ");
      Serial.print(lat);
      Serial.print(" ");
      Serial.print("Longitude: ");
      Serial.print(lon);
      Serial.print(" ");
      Serial.print("Vitesse: ");
      Serial.print(vitesse);
      Serial.println(" km/h");
      writeSD(lat);
      writeSD(lon);

    }
  }
}