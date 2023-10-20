#include <Wire.h>            
#include <LiquidCrystal_I2C.h>  
#include <RTClib.h>           
#include <BH1750.h>
#include "display.h"

String fecha;              
String hora;                  
String frase;                

RTC_DS3231 rtc;                                                   

void start_clock() {
  if (!rtc.begin()) {
    Serial.println("No hay un módulo RTC"); 
    start_Display("No hay un módulo RTC","",1);

    while (1);
  }

  DateTime now = rtc.now(); 
  frase = String(now.day()) + "/" + String(now.month()) + "/"+ String(now.year()) + "  " + String(now.hour()) + ":" + String(now.minute()) + ":"+ String(now.second());
  Serial.println(frase); // 

  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

}

String day(){
  DateTime now = rtc.now();
  fecha = String(now.day()) + "/" + String(now.month()) + "/"+ String(now.year());
  hora = String(now.hour()) + ":" + String(now.minute()) + ":"+ String(now.second());
  frase = fecha + "," + hora;
  //delay(1000); // esperamos un segundo para que muestre por segundos
  return frase;
}