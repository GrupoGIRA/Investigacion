// main.ino
#include "ilumination.h"

void setup() {
  Serial.begin(9600);
  set_lux();
  Serial.println("EE setup");
}

void loop() {
  delay(1000);
  Serial.println(get_lux());
  Serial.println(".");
}