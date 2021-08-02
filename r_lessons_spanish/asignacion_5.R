# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_5.R
# Script Author: Nicole Davila
# Created date: Mon Aug 02 12:26:47 2021
# Purpose: Este codigo es una asignacion de limpieza de data

### Import required libraries -----------------------------------------------------------------------------
library(dplyr)
library(tibble)
library(stringr)
library(zoo)
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------
defaultW <- getOption("warn")
options(warn = -1)

### Load data ---------------------------------------------------------------------------------------------
# Importa el documento "violations.csv", a~ade el argumento na.strings = c("", NA_real_) para que los espacios
# en blanco sean interpretados como NA. Asignalo a una tabla llamada "violations"

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table


# Investiga la estructura de la tabla. 


# Vemos que los nombres de las columnas no siguen las convenciones de nomenclatura. Convierte los nombres
# de las columnas en minusculas y reemplaza los puntos por "_".


# Vemos que la ultima columna, "x", solo tiene valores NA, asi que la podemos eliminar


# Vemos que las columnas "imposed_fine" y "admin_costs" aparecen como facores, pero deben ser numericas.
# Conviertelas a la clase correcta.


# Como puedes notar, algunas de las observaciones tienen mas de un respondente, separados por un "|". Vamos 
# a quedarnos solamente con el primero que aparezca


# Esta tabla tiene muchas columnas con informacion que no necesitamos. Vamos a quedarnos solamente con las
# siguientes columnas: id, street_number, street_direction, street_name, street_type, imposed_fine, 
# admin_costs, violation_description, violation_date, respondents.


# Ve un resumen de las columnas "imposed_fine" y "admin_costs"


# Vemos que ambas tienen valores NA. Tambien vemos que los valores son numeros enteros, asi que en lugar de
# reemplazar con el promedio, reemplacemos con la moda


# Identifiquemos que otras columnas tienen NA


# No queremos quedarnos con records cuya id es NA. Eliminemos esas observaciones.


# La otra columna con valores en blanco, "street_type", va a tener que ser reemplazada con la moda ya que
# no es una columna numerica. 


# Hay varias columnas de direccion. Vamos a crear una nueva columna que tenga la direccion completa y eliminar
# el resto.


# Cómo encontrar valores duplicados (duplicados completos)?


# Cómo deshacerte de duplicados completos?


# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "id"
# pero vamos a ordenar primero por la columna de violation_date para quedarnos con los records mas recientes



### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))


