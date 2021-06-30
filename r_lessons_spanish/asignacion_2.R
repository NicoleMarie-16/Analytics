# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_2.R
# Script Author: 
# Created date: Wed Jun 23 14:12:05 2021
# Purpose: Este codigo es la asignacion #2

### Import required libraries -----------------------------------------------------------------------------
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------
# Crea una variable llamada "apellido" cuyo valor sea el nombre de una persona. La variable debe ser de
# clase character.


# Crea una variable llamada "num_letras" cuyo valor sea el numero de letras del apellido que seleccionaste
# para la pregunta anterior (ejemplo: Davila tiene 6 letras, ese seria el numero que le asigno a la vaiable
# "num_letras". La variable sebe ser de clase integer.


# Crea un vector llamado "idiomas" que contenga 9 idiomas.


# Crea una matriz llamada "matriz" utilizando el vector "idiomas". La matriz debe ser de 3 x 3 y ordenada por rinea (byrow = T)


# Definir una lista llamada "lista" que contenga los siguientes objetos que ya creaste:
# - apelido
# - num_letras
# - matriz


### Load data ---------------------------------------------------------------------------------------------
# Importa el .csv llamado "energy" y asignalo a la variable "energia"


### Pre-process -------------------------------------------------------------------------------------------
# Corre la siguiente linea para convertir los nombres de las columnas en minusculas y cambiar los puntos (.)
# por underscore" (_)
setnames(energia, colnames(energia), gsub("\\.", "_", tolower(colnames(energia))))

# Convierte la tabla "energia" en un data.table


# Cual es la estructura de la tabla "energia"?


# Que codigo ejecutarias para ver las primeras 15 observaciones de la tabla "energia"?


# Cual es la clase de la columna "kwh_january_2010"?


# Cuantas columnas (variables) tiene la tabla "energia"?


# Cuantas lineas (observaciones) tiene la tabla "energia"?


# A~ade una columna llamada "fecha_hora" que contenga la fecha del dia de hoy y la hora. Puedes usar la
# siguente funcion para adquirir la fecha y hora:
dia_hora <- substr(now(), 1, 19)

# Convierte la columna "kwh_january_2010" de entero (integer) a numerico (numeric)


# Cuantos valores en blanco (NA) hay en la columna "occupied_units_percentage"?


# Cuantos valores distintos hay en la columna "building_type"? 


# Cual es el promedio de la columna "average_housesize"? Esta columna puede tener valores en blanco asi
# que tienes que usar el argumento "na.rm = T".


# Cuales son el maximo y minimo de la columna "occupied_housing_units"? Esta columna puede tener valores en blanco asi
# que tienes que usar el argumento "na.rm = T".


# Selecciona las columnas "community_area_name" y "electricity_accounts"


# Seleccionar las lineas donde el valor de la columna "community_area_name" sea igual a Lincoln Park


# Selecciona las lineas 50 - 100 de la tabla "energia"


# Crea una nueva columna llamada "suma" que sea la suma de las columnas "therm_january_2010" y "therm_february_2010"


# Crea ua tabla que tenga 4 columnsas y 3 observaciones. Puedes llamar la tabla como quieras.
# Las columnas y las clases pueden ser lo que tu quieras, despues que la tbla tenga la estructura
# especificada.


# Borra una de las columnas de tu tabla


# Borra la primera linea de tu tabla


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))
