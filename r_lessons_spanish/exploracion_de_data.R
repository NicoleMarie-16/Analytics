# Script info ---------------------------------------------------------------------------------------------
# Script Name: exploracion_de_data.R
# Script Author: Nicole Davila
# Created date: Thu Jun 10 19:36:08 2021
# Purpose: Este codigo es para explorar data

### Import required libraries -----------------------------------------------------------------------------
library(data.table)
library(readxl)
library(RMySQL)

### Define functions --------------------------------------------------------------------------------------
defaultW <- getOption("warn")
options(warn = -1)

### Define variables --------------------------------------------------------------------------------------
user <- readLines("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/Sample of Data Pipeline/db_connection.csv")[1]
password <- readLines("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/Sample of Data Pipeline//db_connection.csv")[2]
host <- readLines("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/Sample of Data Pipeline//db_connection.csv")[3]
mydb <- dbConnect(MySQL(), user = user, password = password, host = host)

schema <- "world"

### Load data ---------------------------------------------------------------------------------------------
# Importar .csv
salarios <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/wages.csv")

# Importar data de Excel
covid <- read_excel("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/covid_chicago.xlsx")

# Importar data de una base de datos
dbSendQuery(mydb, paste0("USE ", schema))
ciudades <- dbGetQuery(mydb, "SELECT * FROM city;")

### Pre-process -------------------------------------------------------------------------------------------
# Identificar clase de una tabla 
class(salarios)

# Convierte en data.table
setDT(salarios)
class(salarios)

# Identificar clase de una columna
class(salarios$age)

# Identificar estructura de una tabla
# Cuantas columnas?
ncol(salarios)

# Cuanas lineas?
nrow(salarios)

# Estructura de una tabla
str(salarios)

# Ver las primeras lineas
head(salarios)

# Nobres de las columnas
colnames(salarios)

### Process -----------------------------------------------------------------------------------------------
# A~adir una columna que sea una fecha
salarios[, pulldate := "2021-06-15"]

# Convertir la nueva columna de string a fecha
class(salarios$pulldate)
salarios[, pulldate := as.Date(pulldate, format = "%Y-%m-%d")]
class(salarios$pulldate)

# Convertir de numeros a strings
class(salarios$age) 
salarios[, age := as.character(age)]
class(salarios$age)

# Convertir de strings a numeros
salarios[, age := as.numeric(age)]

# Convertir de numeros a enteros
salarios[, earn := as.integer(earn)]

# Converir de enteros a numeros
salarios[, earn := as.numeric(earn)]

# A~adir una columna de 1 y 0
salarios[, columna_nueva := sample(c(0, 1), replace = TRUE, size = nrow(salarios))]
salarios

# Convertir de 1 y 0 a C y F
salarios[, columna_nueva := as.logical(columna_nueva)]
salarios

# Convertr de C y F a 0 y 1
salarios[, columna_nueva := as.integer(as.logical(columna_nueva))]
salarios

# Cuantos valores en blanco hay en la columna `Cases - Weekly`?
setDT(covid)
nrow(covid[is.na(`Cases - Weekly`)])

# Cuantos valores distintos hay en la columna `Week Start`
nrow(covid[, .N, .(`Week Start`)])

# Cual es el promedio de pruebas semanales?
mean(covid$`Test Rate - Weekly`)

# Cuales son el maximo y minimo de casos cumulativos?
max(covid$`Cases - Cumulative`, na.rm = T)
min(covid$`Cases - Weekly`, na.rm = T)

# Seleccionar columnas especificas
covid[, .(`ZIP Code`, `Week Number`, `Cases - Weekly`)]

# Seleccionar lineas por numero o por valores
covid[`Week Number` > 50]
covid[1:10, ]

# Asignar nuevas columnas
covid[, columna_nueva := paste0("Esta es la semana #", `Week Number`, ".")]
covid[, .(`Week Number`, columna_nueva)]

# Crear tu propia tabla
mi_tabla <- data.table(nombre = c("Nicole", "Liann", "Jorge", "William"),
                       apellido = c("Davila", "Argueta", "Argueta", "Guzman"),
                       edad = c(25, 16, 39, 28))

# A~ade una columna con el nombre completo
mi_tabla[, nombre_completo := paste0(nombre, " ", apellido)]

# Borra la columna con el nombre completo
mi_tabla[, nombre_completo := NULL]

# Quedate con las mimeras dos lineas de la tabla y borra el resto
tabla_corta <- mi_tabla[1:2, ]

# A~ade dos lineas nuevas
nueva_tabla <- rbind(tabla_corta, data.table(nombre = c("Coralys", "Tony"),
                                             apellido = c("Davila", "Davila"),
                                             edad = c(22, 57)))

### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))
