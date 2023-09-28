#include "Arduino.h"
#include <Wire.h>               // librería para comunicaciones con el pc
#include <BH1750.h>

BH1750 luxometro;
const byte luxMode = BH1750::CONTINUOUS_HIGH_RES_MODE;

void start_lux() {
  luxometro.begin(luxMode);
  }

uint16_t lux(){
  uint16_t lux=luxometro.readLightLevel();
  //Serial.println("Iluminacion tomada");
  return lux;
}