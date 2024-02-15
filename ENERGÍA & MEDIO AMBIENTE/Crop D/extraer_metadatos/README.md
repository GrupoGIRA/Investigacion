![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

# Algoritmo Extracción de los metadatos

Para la extracción de los metadatos se usó la librería exiftool en el sistema operativo linux, por lo que es importante tenerla instalada, el comando de exiftool se ejecuta como un subproceso dentro de python, la salida del comando de convierte a JSON o diccionario, se filtraron solo los datos definidos en el diccionario y por último se retorna el diccionario filtrado.