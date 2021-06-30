# Script info ---------------------------------------------------------------------------------------------
# Script Name: familiarizacion_en_r.R
# Script Author: Nicole Davila
# Created date: Tue Jun 08 20:05:47 2021
# Purpose: Este codigo sirve para familiarizarte con RStudio

### Import required libraries -----------------------------------------------------------------------------
install.packages("data.table")
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------
# Opcion 1 para asgnar variables (preferida)
edad_nicole <- 25
papa_nicole <- "Tony"

# Opcion 2 para asignar variables
edad_liann = 16
papa_liann = "Jorge"

# Definir un numero enero
x <- as.integer(9)

# Definir un vector
nombres <- c("Nicole", "Liann", "Jorge", "Tony")
edades <- c(25, 16, 49, 56)
class(nombres)
class(edades)

# Definir una tabla (data frame)
data <- data.frame(nombres = nombres,
                   edades = edades)
data
class(data)

# Definir una matriz
vector_1 <- c(1,2,3,4,5,6,7,8,9)
matriz <- matrix(vector_1, nrow = 3, ncol = 3, byrow = TRUE)
matriz
class(matriz)

# Definir una lista
lista <- list(nombres, edades, data, matriz)
lista
class(lista)

### Load data ---------------------------------------------------------------------------------------------


### Pre-process -------------------------------------------------------------------------------------------


### Process -----------------------------------------------------------------------------------------------

### Identificar clases
class(edad_nicole)
class(papa_nicole)
class(x)
class(TRUE)

### Algunos calculos basicos
# Suma
edad_nicole + edad_liann 

# Resta
edad_nicole - edad_liann

# Multiplicacion
edad_nicole * 2

# Division
edad_liann/2

# Concatenar 
paste0("Nicole tiene ", edad_nicole, ".")

### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))
