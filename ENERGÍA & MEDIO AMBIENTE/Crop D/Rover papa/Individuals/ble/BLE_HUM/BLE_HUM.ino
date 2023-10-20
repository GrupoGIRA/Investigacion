#include <SoftwareSerial.h>
#include "DHT.h"
#include "Arduino.h"
#include "WString.h"



#define DHTTYPE1 DHT22   // DHT 21 (AM2301)
#define  BLE Serial1

char dato = 'z';
const int DHTPin1 = 9; 
String valor, valor1;

DHT dht1(DHTPin1, DHTTYPE1);

String floatToString(float number, int decimalPlaces){
  char buffer[20]; // Suficientemente grande para contener el número como cadena
  dtostrf(number, 0, decimalPlaces, buffer); // Convierte el float a una cadena con el número deseado de decimales
  return String(buffer); // Convierte el buffer en un objeto String
}

void setup()  
{
  Serial.begin(9600);
  Serial.println("Listo");
  BLE.begin(38400);

  dht1.begin();
}

void loop() {
  
  delay(2000);
  float h1 = dht1.readHumidity();
  float t1 = dht1.readTemperature();

  if (BLE.available()) {
    dato = (char) BLE.read();
  }
  Serial.print("dato:");
  Serial.println(dato);
  Serial.print(strcmp(dato, 'a'));
  if (strcmp(dato, 'a') == 0) {
    Serial.print("DATO IF: ");
    Serial.println(dato);
    valor = floatToString(h1,2);
    valor1 = floatToString(t1,2);
    BLE.println(valor+","+valor1);
    dato = 'z';
  }
}