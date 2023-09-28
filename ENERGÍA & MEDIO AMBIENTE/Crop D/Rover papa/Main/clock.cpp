#include <Wire.h>               // librería para comunicaciones con el pc
#include <LiquidCrystal_I2C.h>  // librería para el LCD por I2C
#include <RTClib.h>             // librería para el RTCLib
#include <BH1750.h>
#include "display.h"

// DECLARAMOS LAS VARIABLES QUE VAMOS A UTILIZAR
String fecha;                  // Para la frase de la fecha
String hora;                   // Para la frase de la hora
String frase;                  // Para la frase que queremos mostrar en el lcd

RTC_DS3231 rtc;                                                       // creamos el objeto que usamos para el RTC

void start_clock() {
  // ** Comprobamos si tenemos el RTC conectado, si no lo encuentra se quedará en un bucle continuo **
  if (!rtc.begin()) {
    Serial.println("No hay un módulo RTC"); 
    start_Display("No hay un módulo RTC","",1);

    while (1);
  }
  // *************************************************************************************************
  DateTime now = rtc.now(); // Con esta instrucción sacamos la fecha y hora del RTC
  //Serial.print("El RTC tenía : ");
  frase = String(now.day()) + "/" + String(now.month()) + "/"+ String(now.year()) + "  " + String(now.hour()) + ":" + String(now.minute()) + ":"+ String(now.second());
  Serial.println(frase); // enviamos el mensaje al pc

  // **con esta instrucción le pasamos al RTC la fecha y la hora del sistema, esto solo lo hacemos la primera vez, depués quitamos esta línea o la comentamos**
  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  // **********************************************************************************************************************************************************

}

String day(){
  DateTime now = rtc.now(); // Con esta instrucción sacamos la fecha y hora del RTC
  //Serial.print("El RTC tiene ahora : ");
  fecha = String(now.day()) + "/" + String(now.month()) + "/"+ String(now.year());
  hora = String(now.hour()) + ":" + String(now.minute()) + ":"+ String(now.second());
  frase = fecha + "," + hora;
  //Serial.println(frase); // enviamos el mensaje al pc
  //delay(1000); // esperamos un segundo para que muestre por segundos
  return frase;
}