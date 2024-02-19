 ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)

#  Algoritmo de etiquetado automático

El algoritmo es capaz de extraer y transformar información de diferentes fuentes para posteriormente almacenarla en mongoDB. Incorpora librerías como Pandas, PyMongo, y PIL para facilitar la manipulación de datos, la interacción con la base de datos, y el tratamiento de imágenes, entre otras.

Este algoritmo incluye la extracción de los metadatos se usó la librería exiftool en el sistema operativo linux, por lo que es importante tenerla instalada, el comando de exiftool se ejecuta como un subproceso dentro de python, la salida del comando de convierte a JSON o diccionario, se filtraron solo los datos definidos en el diccionario y por último se retorna el diccionario filtrado.