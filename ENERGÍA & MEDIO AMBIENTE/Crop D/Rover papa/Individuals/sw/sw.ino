#define boton 45

int contador = 0;
int estado = digitalRead(boton);
int estado_anterior = estado;

void setup() {
  pinMode(boton, INPUT);
  Serial.begin(9600);
}

void loop() {
  estado = digitalRead(boton);
  if (estado != estado_anterior) {
    contador++;
    Serial.print("No. Toma:");
    delay(1000);
    estado_anterior= estado; 
  }
}
