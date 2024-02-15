#include "WString.h"
#include "Arduino.h"
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include "record.h"
#include "display.h"

static const int RXPin = 10, TXPin = 11;
static const int GPSBaud = 9600;

TinyGPSPlus gps;
SoftwareSerial ss(RXPin, TXPin);

void start_gp(){
  ss.begin(GPSBaud);
}

static void smartDelay(unsigned long ms){
  unsigned long start = millis();
  do 
  {
    while (ss.available())
      gps.encode(ss.read());
  } while (millis() - start < ms);
}

void saveI(int value, bool isValid, bool write) {
  if(!write) return;

  if(isValid) {
    writeSD(value);
    return;
  }
  writeSD(",");
}

void saveF(float value, bool isValid, bool write) {
  if(!write) return;
  if(isValid) {
    writeSD(value);
    return;
  }
    writeSD(",");
}
void saveFi(String value, bool isValid, bool write) {
  if(!write) return;
  if(isValid) {
    writeSDF(value);
    return;
  }
}


void gp(bool write){
  static const double REFERENCE_LAT = 5.717833, REFERENCE_LON = -72.943173;

  saveI(gps.satellites.value(), gps.satellites.isValid(), write);
  saveI(gps.hdop.value(), gps.hdop.isValid(), write);
  saveF(gps.location.lat(), gps.location.isValid(), write);
  saveF(gps.location.lng(), gps.location.isValid(), write);
  saveI(gps.location.age(), gps.location.isValid(), write);
  saveF(gps.altitude.meters(), gps.altitude.isValid(), write);
  saveF(gps.course.deg(), gps.course.isValid(), write);
  saveF(gps.speed.kmph(), gps.speed.isValid(), write);
  saveFi("finn", true, write);

  unsigned long distanceKmToReference =
    (unsigned long)TinyGPSPlus::distanceBetween(
      gps.location.lat(),
      gps.location.lng(),
      REFERENCE_LAT, 
      REFERENCE_LON) / 1000;

  double courseToReference =
    TinyGPSPlus::courseTo(
      gps.location.lat(),
      gps.location.lng(),
      REFERENCE_LAT, 
      REFERENCE_LON);
  const char *cardinalToReference = TinyGPSPlus::cardinal(courseToReference);

  smartDelay(2500);

  if (millis() > 5000 && gps.charsProcessed() < 10){
    Serial.println(F("No GPS data received: check wiring"));
    start_Display("No GPS","check wiring",1);
  }

}


