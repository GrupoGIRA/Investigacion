#include "HardwareSerial.h"
#include "WString.h"
#include "Arduino.h"
#include <SPI.h>    
#include <SD.h>   
#include "display.h"
#include "clock.h"

#define SSpin 53   

File archivo;   

String fileName = "PRUEBA2.txt";

void writeSD(String line) {
  if (!SD.begin(SSpin)) {     
    start_Display("fallo en inicializacion !","",1);
    Serial.println("fallo en inicializacion !");
    return;         
  }
  
  archivo = SD.open(fileName, FILE_WRITE);  

  if (archivo) {
    archivo.print(line);  
    archivo.close();        
    Serial.println("escritura correcta"); 
  } else {
    Serial.println("error en apertura de prueba.txt");
    start_Display("error en apertura de prueba.txt","",1);
  }
}
//---------------------------------CONVERSION DE TIPOS DE DATOS -------------------------------------------
String doubleToString(double value, int decimalPlaces) {
  char buffer[12];                                       // Ajusta el tamaño según tus necesidades
  buffer[0] = '\0';
  dtostrf(value, 11, decimalPlaces, buffer);
  return String(buffer);
}
//-------------------------------------------------------------------------------
String uint16ToString(uint16_t value) {
  char buffer[6];                                        // Suficiente para valores hasta 65535
  snprintf(buffer, sizeof(buffer), "%u", value);
  
  return String(buffer);
}
//------------------------------------------------------------------------------
String floatToString(float number, int decimalPlaces){
  char buffer[20];                                      // Suficientemente grande para contener el número como cadena
  dtostrf(number, 0, decimalPlaces, buffer); 
  return String(buffer); 
}
//------------------------------------------------------------------------------
String intToString(int contador) { 
  return String(contador);
}
//--------------------------------------------------------------------------------
void write_record(int contador,uint16_t lum, float temp1, float hum1, float temp2, float hum2, int porcentaje, String fecha){
  writeSD(intToString(contador)+","+uint16ToString(lum)+","+ floatToString(temp1, 2)+","+ floatToString(hum1, 2)+","+ floatToString(temp2, 2)+","+ floatToString(hum2, 2)+","+intToString(porcentaje)+","+fecha+",");
}
//--------------------------------------------------------------------------------
void writeSD(int value) {
  if (!SD.begin(SSpin)) {     
    start_Display("fallo en inicializacion !","",1);
    Serial.println("fallo en inicializacion !");
    return;      
  }
  
  archivo = SD.open(fileName, FILE_WRITE); 

  if (archivo) {
    archivo.print(value);  
    archivo.print(",");
    archivo.close();       
    Serial.println("escritura correcta"); 
  } else {
    Serial.println("error en apertura de prueba.txt");
    start_Display("error en apertura de prueba.txt","",1);
  }
}
//--------------------------------------------------------
void writeSD(float value) {
  if (!SD.begin(SSpin)) {   
    start_Display("fallo en inicializacion !","",1);
    Serial.println("fallo en inicializacion !");
    return;        
  }
  
  archivo = SD.open(fileName, FILE_WRITE);  

  if (archivo) {
    archivo.print(value, 8);  
    archivo.print(",");
    archivo.close();        
    Serial.println("escritura correcta"); 
  } else {
    Serial.println("error en apertura de prueba.txt"); 
    start_Display("error en apertura de prueba.txt","",1);
  }
}
//--------------------------------------------------------------
void writeSDF(String value) {
  if (!SD.begin(SSpin)) {    
    start_Display("fallo en inicializacion !","",1);
    Serial.println("fallo en inicializacion !");
    return;    
  }
  
  archivo = SD.open(fileName, FILE_WRITE);  

  if (archivo) {
    archivo.println(" "); 
    archivo.close(); 
    Serial.println("escritura correcta"); 
  } else {
    Serial.println("error en apertura de prueba.txt");  
    start_Display("error en apertura de prueba.txt","",1);
  }
}