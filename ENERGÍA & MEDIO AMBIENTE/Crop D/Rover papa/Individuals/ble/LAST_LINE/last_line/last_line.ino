#include <SPI.h>
#include <SD.h>
#include <SoftwareSerial.h>

#define  BLE Serial1

char dato = 'z';
String lastLine;
File myFile;

void setup() {
  Serial.begin(9600);
  BLE.begin(38400);

  if (!SD.begin(53)) {
    Serial.println("Error al inicializar la tarjeta SD");
    return;
  }

  myFile = SD.open("PRUEBA1.txt");

  if (myFile) {
    while (myFile.available()) {
      lastLine = myFile.readStringUntil('\n');
    }

    Serial.println("La última línea es: ");
    Serial.println(lastLine);

    myFile.close();
  } else {
    Serial.println("Error al abrir el archivo.");
  }
}

void loop() {
    
  delay(1000);
  if (BLE.available()) {
    dato = (char) BLE.read();}

  Serial.print("dato:");
  Serial.println(dato);
  Serial.println(strcmp(dato, 'a'));
  
  if (strcmp(dato, 'a') == 0) {
    BLE.println(lastLine);
    dato = 'z';
  }
}