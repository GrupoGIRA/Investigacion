#include "Arduino.h"
#include "WString.h"
String doubleToString(double value, int decimalPlaces);
String uint16ToString(uint16_t value);
String floatToString(float number, int decimalPlaces);
String intToString(int contador);
void writeSD(int value);
void writeSD(String line);
void writeSD(float line);
void writeSDF(String value);
void write_record(int contador, uint16_t lum, float temp1, float hum1, float temp2, float hum2, int porcentaje, String fecha);