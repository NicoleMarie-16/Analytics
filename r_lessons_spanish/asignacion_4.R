# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_4.R
# Script Author: Nicole Davila
# Created date: Mon Jul 19 20:22:02 2021
# Purpose: Este codigo es una asignacion de limpieza de data

### Import required libraries -----------------------------------------------------------------------------
library(dplyr)
library(tibble)
library(stringr)
library(zoo)
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------


### Load data ---------------------------------------------------------------------------------------------
# Importa el documento "mtcars.csv", a~ade el argumento na.strings = c("", NA_character_) para que los espacios
# en blanco sean interpretados como NA

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table


# Investiga la estructura de la tabla. 


# Si quieres ver un resumen de una columna, por ejemplo "cyl", qué función usarías?


# La columna "mpg" (miles per gallon) debe ser numerica. Una manera de condirmarlo es: 


# Vemos que "mpg" no es de clase numérico. De qué clase es?


# Si vemos, la columna "mpg" tiene las letras "mpg", asi que la computadora lo lee como una palabra. Tenemos que
# remover esas letras de la columna para quedarnos solo con los numeros. 


# Vemos que sigue siendo de clase character asi que tenemos que hacer la conversion a numeric. 


# Ahora que tenemos una columna de mpg de clase numeric, vamos a ver cuanto es el promedio de
# millas por galon. Para evitar errores por posibles valores NA, usemos el argumento na.rm = T


# Identifiquemos las columnas con NA. Puedes correr el codigo de abajo para determinarlo
colnames(cars)[colSums(is.na(cars)) > 0]

# Vamos a reemplazar los valores NA en las columnas "mpg", "disp", "hp", "drat", "wt" y "qsec"
# con el promedio


# La otra columna con valores en blanco, "model", va a tener re ser reemplazada con la moda ya que
# no es una columna numerica. 


# Cómo encontrar valores duplicados (duplicados completos)?


# Cómo deshacerte de duplicados completos?


# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "vehicle_id"


# Agrupar por id y determinar las medidas promedio para las columnas numeric (no incluyas las integer).


# Combinemos nuestros datos. Tenemos dos nuevas tablas que tienen valores unicos.
# 1. De cars_unico, vamos a quedarnos con las columnas "vehicle_id", "model", "hp",
#    "vs", "am", "gear", "carb" y "cyl".


# 2. De medidas_promedio nos vamos a quedar con todos los valores

# 3. Tabla final



### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))


