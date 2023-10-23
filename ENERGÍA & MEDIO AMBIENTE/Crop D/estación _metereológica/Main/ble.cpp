#include "WString.h"
#include <SPI.h>
#include <SD.h>
#include <SoftwareSerial.h>

#define  BLE Serial1

String linea;
File myFile;

void start_ble() {
  Serial.begin(9600);
  BLE.begin(38400);
}

String last(){
  if (!SD.begin(53)) {
   Serial.println("Error al inicializar la tarjeta SD");
    return;
  }

  myFile = SD.open("PRUEBA2.txt");
  if (myFile) {
    while (myFile.available()) {
      linea = myFile.readStringUntil('\n');
    }
    Serial.println(linea);
    return linea;

    myFile.close();
  } 
  else {
    Serial.println("Error al abrir el archivo.");
  }
}


