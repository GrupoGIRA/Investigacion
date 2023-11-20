const int sensorPin = A0;
const int humedadAire = 750;
const int humedadAgua = 400;

void setup() 
{
  Serial.begin(9600);
}

void loop() 
{
   int humedad = analogRead(sensorPin);
   //Serial.println(humedad);
   
   int porcentajeHumedad = map(humedad, humedadAire, humedadAgua, 0, 100);
   if(porcentajeHumedad > 100) {
    porcentajeHumedad = 100;
    Serial.print(porcentajeHumedad);
    Serial.println("%"); 
   }
   else if (porcentajeHumedad < 0) {
    porcentajeHumedad = 0;
    Serial.print(porcentajeHumedad);
    Serial.println("%"); 
   }
   else if (porcentajeHumedad > 0 && porcentajeHumedad < 100) {
    Serial.print(porcentajeHumedad);
    Serial.println("%"); 
   }
   delay(1000);
}