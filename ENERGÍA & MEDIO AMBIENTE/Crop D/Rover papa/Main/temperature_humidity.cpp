#include "DHT.h"
#include "display.h"
#include "Arduino.h"

#define DHTTYPE2  DHT11 
#define DHTTYPE1 DHT22  

const int DHTPin2 = 8;     
const int DHTPin1 = 9;   

DHT dht1(DHTPin1, DHTTYPE1);
DHT dht2(DHTPin2, DHTTYPE2);

void start_dht() {
  dht1.begin();
  dht2.begin();
}

float * temp_hum() {

  float h1 = dht1.readHumidity();
  float t1 = dht1.readTemperature();

  float h2 = dht2.readHumidity();
  float t2 = dht2.readTemperature();

  if (isnan(h1) || isnan(t1)) {
    Serial.println("Failed to read from DHT sensor!");
    start_Display("Fallo sensor","DHT 1",1); 
  }
  if (isnan(h2) || isnan(t2)) {
    start_Display("Fallo Sensor","DHT 2",1);
  }


  static float My_arrayth[] = {t1,h1, t2, h2};
  return My_arrayth;
}