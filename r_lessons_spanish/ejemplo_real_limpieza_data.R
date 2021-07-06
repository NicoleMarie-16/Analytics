# Script info ---------------------------------------------------------------------------------------------
# Script Name: ejemplo_real_limpieza_data.R
# Script Author: Nicole Davila
# Created date: Tue Jul 06 13:24:19 2021
# Purpose: Este script es un fragmento de un script mas largo que fue utilizado para un proyecto en grupo
#          en el cual analizamos los reviews de whisky para investigar aquellos atributos hacen que un whisky
#          sea considerado de menor o mayor calidad. Partes del codigo han sido adaptadas para seguir el
#          enfoque de estas tutorias y ha sido convertido en data.table pero fue a pesar de que fue originalmente
#          escrito en data.frame. Para ver el script original visita este link:
#          https://github.com/NicoleMarie-16/data-processing-analytics/blob/master/analytics/whisky_review_analysis.R

### Import required libraries -----------------------------------------------------------------------------
library(data.table)
library(dplyr)
library(stringr)
library(readxl)


### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------


### Load data ---------------------------------------------------------------------------------------------
whisky <- read_excel("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/Datasets/whisky_dataset_v1.4.xlsx")


### Pre-process -------------------------------------------------------------------------------------------
# Aseguremonos de no tener notacion cientifica en nuestro codigo
options(scipen = 100)

# Veamos la tabla
View(whisky)

# Veamos la estructura de la tabla
str(whisky)

# Reasignemos los nombres de dos de nuestras columnas para mayor consistencia
setnames(whisky, c("...1", "review.point"), c("id", "review_point"))

# Convirtamos whisky en data.table
setDT(whisky)


### Process -----------------------------------------------------------------------------------------------
# Vimos que la columna "currency" es irrelevante porque todos los whiskies estn en dolar. Esta columna la 
# podemos remover
whisky[, currency := NULL]

# Remover los falsos NA de la columna "age"
whisky[age == "NA", age := NA_real_]

# Investigar columna price
class(whisky$price)

# Remover comas y otros simbolos de los numeros de la columna "price"
whisky[, price := gsub("\\D+", "", price)]

# Convertir las columnas "age", "price" y "review_point" a la clase numeric 
whisky[, c("age", "price", "review_point") := lapply(.SD, as.numeric), .SDcols = c("age", "price", "review_point")]

# Cuantos valores NA hay en la columna "age"?
sum(is.na(whisky$age))

# Calculemos la mediana de la columna y reemplazemos los NA con ese valor
median_whisky_age <- median(whisky$age, na.rm = T) 
whisky[is.na(age), age := median_whisky_age]

# Ahora deben haber cero NAs en la columna "age"
sum(is.na(whisky$age))

# Cuantos NAs hay en la columna "price"?
sum(is.na(whisky$price))

# Veamos si hay numeros que se salen de lo normal?
summary(whisky$price)

# Uno de los whiskies cuesta $1,500,060,000 pero sabemos que el whisky mas caro cuests $6,200,000, asi que podemos
# reemplazar cualquier whisky con un valor mayor a $6,200,000 con ese precio.
whisky[price > 6200000, price := 6200000]
summary(whisky$price)

# Cuantos valores NA hay en la columna "review_point"?
sum(is.na(whisky$review_point))


### Load data ---------------------------------------------------------------------------------------------


### Clean up environment ----------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))
