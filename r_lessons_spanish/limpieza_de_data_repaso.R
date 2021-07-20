# Script info ---------------------------------------------------------------------------------------------
# Script Name: limpieza_de_data_repaso.R
# Script Author: Nicole Davila
# Created date: Mon Jul 19 20:22:02 2021
# Purpose: Este codigo es un repaso de limpieza de data

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
# Importa el documento "iris.csv"
iris <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/Datasets/iris.csv")

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table
setDT(iris)

# Investiga la estructura de la tabla. 
glimpse(iris)

# Si quieres ver un resumen de una columna, por ejemplo "sepal_length_cm", qué función usarías?
summary(iris$sepal_length_cm)

# La columna "petal_length" debe ser numerica. Una manera de condirmarlo es: 
is.numeric(iris$petal_length)

# Vemos que "petal_length" no es de clase numérico. De qué clase es?
class(iris$petal_length)

# Si vemos, la columna "petal_length" tiene las letras "cm", asi que la computadora lo lee como una palabra. Tenemos que
# remover esas letras de la columna para quedarnos solo con los numeros. 
iris[, petal_length := gsub("cm", "", petal_length)]
class(iris$petal_length)

iris[, petal_width := gsub("cm", "", petal_width)]
class(iris$petal_width)

# Vemos que sigue siendo de clase character asi que tenemos que hacer la conversion a numeric. 
iris[, petal_length := as.numeric(as.character(petal_length))]
class(iris$petal_length)

iris[, petal_width := as.numeric(as.character(petal_width))]
class(iris$petal_width)

# Ahora que tenemos una columna de petal_length de clase numeric, vamos a ver cual es el largo promedio de los petalos.
# Para evitar errores por posibles valores NA, usemos el argumento na.rm = T
mean(iris$petal_length, na.rm = T)
mean(iris$petal_width, na.rm = T)

# Vamos a reemplazar los valores NA con el promedio de la columna
iris[] <- lapply(iris, na.aggregate)
iris

# Cómo encontrar valores duplicados (duplicados completos)?
duplicados <- iris[duplicated(iris)]
nrow(duplicados)

# Cómo deshacerte de duplicados completos?
unicos <- unique(iris)

# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "record_id"
iris_unico <- unique(iris, by = "record_id")

# Agrupar por id y determinar las medidas promedio.
medidas_promedio <- iris[ ,list(sepal_length_cm = round(mean(sepal_length_cm), 1),
                                sepal_width_cm = mean(sepal_width_cm),
                                petal_length = mean(petal_length),
                                petal_width = mean(petal_width)),
                          by = record_id]

# Combinemos nuestros datos. Tenemos dos nuevas tablas que tienen valores unicos.
# 1. De iris_unico, vamos a quedarnos con las columnas "record_id" y "species".
iris_unico <- iris_unico[, .(record_id, species)]

# 2. De medidas_promedio nos vamos a quedar con todos los valores

# 3. Tabla final
iris_final <- medidas_promedio[iris_unico, on = "record_id"]
iris_final


### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))

