#include "Arduino.h"

const int humedadAire = 780;
const int humedadAgua = 10;

int soil() 
{
   int humedad = analogRead(A0);
   //Serial.println(humedad);
   
   int porcentajeHumedad = map(humedad, humedadAire, humedadAgua, 0, 100);
   if(porcentajeHumedad > 100) {
    porcentajeHumedad = 100;
    return porcentajeHumedad;
   }
   else if (porcentajeHumedad < 0) {
    porcentajeHumedad = 0;
    return porcentajeHumedad; 
   }
   else if (porcentajeHumedad > 0 && porcentajeHumedad < 100) {
    Serial.print(porcentajeHumedad);
    Serial.println("%"); 
    return porcentajeHumedad;
   }
}