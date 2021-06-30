# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_1.R
# Script Author: 
# Created date: Sat Jun 19 14:02:48 2021
# Purpose: Este codigo es la asignacion #1

### Import required libraries -----------------------------------------------------------------------------
install.packages("lubridate")
library(lubridate)
library(data.table)
library(readxl)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------
# Cea una variable llamada nombre cuyo valor sea el nombre de una persona. La variable debe ser de clase character.


# Crea una variable llamada edad cuyo valor sea 50. La variable sebe ser de clase numeric.


# Crea un vector que contenga 5 animales (por ejemplo: perro, gato, etc...)


# Crea una tabla (data.table)


# Crea una matriz
 

# Definir una lista


### Load data ---------------------------------------------------------------------------------------------
# Importa el .csv llamado diamonds y asignalo a la variable diamantes


### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla "diamantes" en un data.table


# Cual es la estructura de la tabla "diamantes"?


# QUe codigo ejecutarias para ver las primeras 10 observaciones de la tabla "diamantes"?


# Cual es la clase de la columna "price"?


# Cuantas columnas (variables) tiene la tabla "diamantes"?


# Cuantas lineas (observaciones) tiene la tabla "diamantes"?


# A~ade una columna llamada fecha que contenga la fecha del dia de hoy y llamala "fecha". Puedes usar la
# siguente funcion para adquirir la fecha:
fecha <- today()


# Convierte la columna "price" de entero (integer) a numerico (numeric)


# Cuantos valores en blanco hay en la columna "table"?


# Cuantos valores distintos hay en la columna "cut"?


# Cual es el promedio de la columna "price"?


# Cuales son el maximo y minimo de la columna "depth"?


# Selecciona las columnas "cut" y "clarity"


# Seleccionar las lineas donde el valor de "price" sea mayor que 60


# Selecciona las lineas 100 - 200 de la tabla


# Selecciona las columnas "carat" y "cut" solamente


# Crea una nueva columna llamada "multiplicacion" que sea la multiplicacion de las columnas "x" y "y"


# Crea ua tabla que tenga tres columnsas y cinco observaciones. Puedes llamar la tabla como quieras.
# Las columnas y las clases pueden ser lo que tu quieras, despues que la tbla tenga la estructura
# especificada.


# Borra una de las columnas de tu tabla


# Borra la ultima linea de tu tabla


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))
