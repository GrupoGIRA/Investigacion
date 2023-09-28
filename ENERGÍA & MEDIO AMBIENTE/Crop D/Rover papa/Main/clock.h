#include <Wire.h>               // librería para comunicaciones con el pc
#include <LiquidCrystal_I2C.h>  // librería para el LCD por I2C
#include <RTClib.h>             // librería para el RTCLib
#include <BH1750.h>

void start_clock();
String day();