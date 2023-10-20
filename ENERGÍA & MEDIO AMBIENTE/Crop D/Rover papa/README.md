 ![Arduino](https://img.shields.io/badge/-Arduino-00979D?style=for-the-badge&logo=Arduino&logoColor=white) ![C++](https://img.shields.io/badge/c++-%2300599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white)
## 🥔🥔 CÓDIGO DE LA ESTACIÓN METEREOLÓGICA 🥔🥔

Aqui se encontrará los códigos para la realización de la estación metereológica.

El código esta separado en diverentes archivos y funciones, en relación a los sensores utilizados. También se encuentran los códigos de manera indivual para la comprobación de cada uno de los sensores.
## Main: 
El archivo Main es el archivo principal, aquí se encuentra la integración de todos los sensores a utilizar para la estacición metereológica, el archivo se encuentra divido en subarchivos cada una con su respectivo sensor, esto para mejorar y reducidir el código de una manera más comprensible y legible. Cada subarchivo se encuentran:

**1. GPS:** En este archivo (gp.cpp), se encuentra el código en donde se obtienen los datos suministrados por el sensor SPARKFUN VENUS GPS. 📌 🛰️

**2. Luminosidad:**  En este archivo (brigthness.cpp), se encuentra el código en donde se obtienen los datos suministrados por el sensor BH1750. ☀️☀️

**3. Humedad - Temperatura:**  En este archivo (temperature_humidity.cpp), se encuentra el código en donde se obtienen los datos suministrados por el sensor DTH11 y DTH22. 🌦🌦️

**4. Humedad de suelo:** En este archivo (soil.cpp), se encuentra el código en donde se obtienen los datos suministrados por un sensor de humedad de suelo capacitivo (se diseno el sensor, por lo que no se suminsitra referencia del mismo). 🌳🌳

**5. Reloj:** En este archivo (clock.cpp), se encuentra el código en donde se obtienen los datos suministrados por el sensor RTC DS3231. 🕑📅

**6. Display:** En este archivo (display.cpp), se encuentra el código en donde se muestran los mensajes, alarmas y/o datos de los demas sensores, se utiliza una pantalla lcd de 16x2. 📟📟

**7. SD:** En este archivo (record.cpp), se encuentra el código en donde se almacenan los datos de todos los sensores a medir, se utiliza un módulo de lectura y escritura SD. 💾💾

**8. BLE:** En este archivo (ble.cpp), se encuentra el código en donde se envian los datos de todos los sensores a medir, se utiliza un módulo HC-05, para realizar la conexión entre el arduino y la app móvil.📲📲