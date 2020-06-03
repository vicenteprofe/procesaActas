# ProcesaActas
Shell Script para parsear actas de evaluaciones usando la librería Tabula

Script creado por Vicente Martínez
Este script extrae la información de las actas de evaluación (en formato PDF) a documentos CSV.

Condiciones para que funcione el script
  - El archivo tabula-1.0.2-jar-with-dependencies.jar tiene que estar dentro del subdirectorio libs/ScriptTabula
  - Las actas que se procesan deben estar agrupados en carpetas por cursos
    + Las actas de la evaluación ordinaria (Junio) deben estar en el subdirectorio ConvocatoriaOrdinaria
    + Las actas de la evaluación extraordinaria (Julio) deben estar en el subdirectorio ConvocatoriaExtraordinaria

### ENTRADA

El programa recibe un parámetro de entrada **(ordinaria | extraordinaria)** para indicar qué actas se quieren procesar
Si no se indica ningún parámetro, por defecto se tomará el valor "ordinaria".

### SALIDA

La salida del script son un conjunto de archivos CSV que contienen sólo las filas que cominezan por un número
Como resultado del procesamiento se obtiene un archivo CSV por nivel
Cada archivo CSV contiene una cabecera con la información de las asignaturas que que aparece en el PDF de las actas
*En el ejemplo se trata un grupo especial (PMAR 3ESOG) que requiere un postprocesamiento espcial al trabajar por ámbitos.*

[Acceso al repositorio](https://github.com/vicenteprofe/procesaActas.git)
