#include "Arduino.h"
#include "WString.h"
#include <LiquidCrystal_I2C.h> 

LiquidCrystal_I2C lcd(0x27,16,2); // Otras direcciones: (0x3f,16,2) || (0x27,16,2)  ||(0x20,16,2) 

void start_Display(String cadena, String cadena1,  boolean  error) {

  lcd.init();
  lcd.clear();
  if (error){
      lcd.backlight();
  }
  lcd.setCursor(0,0);
  lcd.print(cadena); 
  lcd.setCursor(0,1);
  lcd.print(cadena1); 
  delay(1000);
  lcd.noBacklight();
}

