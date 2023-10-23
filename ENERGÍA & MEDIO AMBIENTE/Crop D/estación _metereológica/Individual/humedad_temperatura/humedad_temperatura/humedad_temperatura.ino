#include "DHT.h"
#include "Arduino.h"
#include "WString.h"
#include <LiquidCrystal_I2C.h> 

LiquidCrystal_I2C lcd(0x27,16,2); // (0x3f,16,2) || (0x27,16,2)  ||(0x20,16,2) 
// Uncomment whatever type you're using!
//#define DHTTYPE DHT11   // DHT 11

#define DHTTYPE2 DHT11   // DHT 21 (AM2301)
#define DHTTYPE1 DHT22   // DHT 22  (AM2302), AM2321

// Connect pin 1 (on the left) of the sensor to +5V
// NOTE: If using a board with 3.3V logic like an Arduino Due connect pin 1
// to 3.3V instead of 5V!
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

const int DHTPin2 = 8;     // what digital pin we're connected to
const int DHTPin1 = 9;     // what digital pin we're connected to

DHT dht1(DHTPin1, DHTTYPE1);
DHT dht2(DHTPin2, DHTTYPE2);

void setup() {
  Serial.begin(9600);
  Serial.println("DHTxx test!");

  dht1.begin();
  dht2.begin();

  lcd.init();
  lcd.clear();
  lcd.backlight();
  lcd.setCursor(0,0);
}

void loop() {
  // Wait a few seconds between measurements.
  delay(2000);

  // Reading temperature or humidity takes about 250 milliseconds!
  float h1 = dht1.readHumidity();
  float t1 = dht1.readTemperature();

  float h2 = dht2.readHumidity();
  float t2 = dht2.readTemperature();

  if (isnan(h1) || isnan(t1)) {
    Serial.println("Failed to read from DHT sensor!");
    lcd.print("hola'''"); 
  }
  if (isnan(h2) || isnan(t2)) {
    lcd.print("hola...");
    //return;
  }

  Serial.print("Sensor 1 - Humidity: ");
  Serial.print(h1);
  Serial.print(" %\t");
  Serial.print("Temperature: ");
  Serial.print(t1);
  Serial.println(" *C ");

  Serial.print("Sensor 2 - Humidity: ");
  Serial.print(h2);
  Serial.print(" %\t");
  Serial.print("Temperature: ");
  Serial.print(t2);
  Serial.println(" *C ");
  Serial.println("----------------------------");

}
