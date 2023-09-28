//#include "globals.h"

#include <Wire.h>
#include <BH1750.h>

BH1750 luxometro;
const byte luxMode = BH1750::CONTINUOUS_HIGH_RES_MODE;

uint16_t get_lux() {
  uint16_t lux = luxometro.readLightLevel();
  return lux;
}

void set_lux() {
  luxometro.begin(luxMode);
}