# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_5_respuestas.R
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
violations <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/Datasets/violations.csv", na.strings = c("", NA_real_))

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table
setDT(violations)

# Investiga la estructura de la tabla. 
glimpse(violations)

# Vemos que los nombres de las columnas no siguen las convenciones de nomenclatura. Convierte los nombres
# de las columnas en minusculas y reemplaza los puntos por "_".
setnames(violations, colnames(violations), tolower(gsub("\\.", "_", colnames(violations))))

# Vemos que la ultima columna, "x", solo tiene valores NA, asi que la podemos eliminar
violations[, x := NULL]

# Vemos que las columnas "imposed_fine" y "admin_costs" aparecen como facores, pero deben ser numericas.
# Conviertelas a la clase correcta.
violations[, imposed_fine := as.numeric(imposed_fine)]
violations[, admin_costs := as.numeric(admin_costs)]

# Como puedes notar, algunas de las observaciones tienen mas de un respondente, separados por un "|". Vamos 
# a quedarnos solamente con el primero que aparezca
violations[, respondents := sub("\\|.*", "", respondents)]

# Esta tabla tiene muchas columnas con informacion que no necesitamos. Vamos a quedarnos solamente con las
# siguientes columnas: id, street_number, street_direction, street_name, street_type, imposed_fine, 
# admin_costs, violation_description, violation_date, respondents.
violations <- violations[, .(id, street_number, street_direction, street_name, street_type, imposed_fine, admin_costs, violation_description, violation_date, respondents)]

# Ve un resumen de las columnas "imposed_fine" y "admin_costs"
summary(violations$imposed_fine)
summary(violations$admin_costs)

# Vemos que ambas tienen valores NA. Tambien vemos que los valores son numeros enteros, asi que en lugar de
# reemplazar con el promedio, reemplacemos con la moda
moda_imposed_fine <- violations[, .N, .(imposed_fine)]
setorder(moda_imposed_fine, -N)
moda_imposed_fine <- moda_imposed_fine[1, ]$imposed_fine

moda_admin_costs <- violations[, .N, .(admin_costs)]
setorder(moda_admin_costs, -N)
moda_admin_costs <- moda_admin_costs[1, ]$admin_costs

violations[is.na(imposed_fine), imposed_fine := moda_imposed_fine]
violations[is.na(admin_costs), admin_costs := moda_admin_costs]

# Identifiquemos que otras columnas tienen NA
colnames(violations)[colSums(is.na(violations)) > 0]

# No queremos quedarnos con records cuya id es NA. Eliminemos esas observaciones.
violations <- violations[!is.na(id)]

# La otra columna con valores en blanco, "street_type", va a tener que ser reemplazada con la moda ya que
# no es una columna numerica. 
moda_street_type <- setorder(violations[, .N, .(street_type)], -N)
moda_street_type <- moda_street_type[1, ]$street_type
violations[is.na(street_type), street_type := moda_street_type]

# Hay varias columnas de direccion. Vamos a crear una nueva columna que tenga la direccion completa y eliminar
# el resto.
violations[, full_address := paste0(street_number, " ", street_name, " ", street_type)]
violations[ ,c("street_number","street_name", "street_type") := NULL]

# Cómo encontrar valores duplicados (duplicados completos)?
duplicados <- violations[duplicated(violations)]
nrow(duplicados)

# Cómo deshacerte de duplicados completos?
unicos <- unique(violations)

# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "id"
# pero vamos a ordenar primero por la columna de violation_date para quedarnos con los records mas recientes
violations[, violation_date := as.Date(as.character(violation_date), format = "%m/%d/%Y")]
setorder(violations, -violation_date)
violations <- unique(violations, by = "id")


### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))


