# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_3_respuestas.R
# Script Author: Nicole Davila
# Created date: Thu Jul 08 18:57:16 2021
# Purpose: Este codigo es una asignacion de limpieza de data

### Import required libraries -----------------------------------------------------------------------------
library(dplyr)
library(tibble)
library(stringr)
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------
defaultW <- getOption("warn")
options(warn = -1)

### Load data ---------------------------------------------------------------------------------------------
# Importa el documento "customers.csv"
customers <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/Datasets/customers.csv")

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table
setDT(customers)

# Investiga la estructura de la tabla. 
glimpse(customers)

# Si quieres ver un resumen de una columna, por ejemplo "spendig_score", qué función usarías?
summary(customers$spending_score)

# La columna "annual_income" debe ser numerica. Una manera de condirmarlo es: 
is.numeric(customers$annual_income)

# Vemos que "annual_income" no es de clase numérico. De qué clase es?
class(customers$annual_income)

# Si vemos, la columna "annual_income" tiene un símbolo de "$", asi que la computadora lo lee como una palabra. Tenemos que
# remover esos símbolos de la columna para quedarnos solo con los numeros. 
customers[, annual_income := gsub("\\D+", "", annual_income)]
class(customers$annual_income)

# Vemos que sigue siendo de clase character asi que tenemos que hacer la conversion a numeric. 
customers[, annual_income := as.numeric(as.character(annual_income))]
class(customers$annual_income)

# Ahora que tenemos una columna de annual_income de clase numeric, vamos a ver cual es el salario promedio de los clientes.
# Para evitar errores por posibles valores NA, usemos el argumento na.rm = T
mean(customers$annual_income, na.rm = T)

# Identificar si algun valor se sale del intervalo aceptado. La columna "year" no debe tener fechas en el futuro,
# así que si algún año es mayor que 2021, lo podemos reemplazar con 2021 que es el año actual, removerlos del todo,
# cambiarlos por NA, o reemplazarlos con otro valor.
summary(customers$year)

# Opción 1: Reemplazar con 2021. Primero crea una copia de la tabla actual para no alterarla. Llama la nueva tabla
#           customers_1
customers_1 <- copy(customers)
customers_1[year > 2021, year := 2021]

# Asegurúmonos de que ya no queden valores mayores que 2021
nrow(customers_1[year > 2021])


# Opción 2: Remueve cualquier observación cuyo valor sea mayor que 2021. Crea una copia de la tabla original y llámala
#           customers_2
customers_2 <- copy(customers)
customers_2 <- customers_2[2021 >= year]

# Asegurúmonos de que ya no queden valores mayores que 2021
nrow(customers_2[year > 2021])

# Otra manera de corroborar es que la tabla original debe tener más líneas que la copia
nrow(customers) > nrow(customers_2)

#  Opción 3: Convertir los valores en NA. Crea una tercera copia de la tabla original y llámala customers_3
customers_3 <- copy(customers)
customers_3[year > 2021, year := NA_integer_]


# Opción 4: Reemplazar con otro valor. Como sabemos que los años no pueden ser decimales, podemos escoger el
#           valor de estos que mas se repite en la columna usando la moda.

# Primero determina la moda de la columna y asígnasela a una nueva variable llamada "moda"
moda <- customers[, .N, .(year)][N == max(N)]$year

# Crea una cuarta copia de la tabla original, llamada customers_4 y reemplaza los valores mayores a 2021 con
# la variable "moda" que generaste previamente.
customers_4 <- copy(customers)
customers_4[year > 2021, year := moda]

# Cómo encontrar valores duplicados (duplicados completos)?
duplicados <- customers[duplicated(customers)]

# Si miras la tabla "duplicados" que creaste anteriormente, hay duplicados completos?
nrow(duplicados) # No

# Cómo deshacerte de duplicados completos?
unicos <- unique(customers)

# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "customer_id"
customers_id_unico <- unique(customers, by = "customer_id")

# Selecciona los valores distintos con la fecha mas reciente
# Ordena la tabla "customers" por "customer_id" ascendente y "year" descendente y luego selecciona los valores únicos
# por "customer_id"
setorder(customers, customer_id, -year)
customers_fecha_mayor <- unique(customers, by = "customer_id")

# Agrupar por id y determinar el salario promedio. Calcula el promedio de "annual_income" agrupando por "customer_id"
customers_salario_promedio <- customers[ ,list(annual_income = mean(annual_income)), by = customer_id]

# Para la edad, seleccionemos la observación con el valor mayor. Sigue pasos parecidos a los que usaste para la fecha
# pero usando la columna "age" en lugar de "year"
setorder(customers, customer_id, -age)
customers_edad_mayor <- unique(customers, by = "customer_id")

# Combinemos nuestros datos. Tenemos tres nuevas tablas que tienen valores unicos.
# 1. De customers_fecha_mayor, vamos a quedarnos con las columnas "customer_id", "gender", "spending_score", y "year".
#    Así nos quedamos con el genero y score de gastos del año mas reciente para el cual tenemos datos
customers_fecha_mayor <- customers_fecha_mayor[, .(customer_id, gender, spending_score, year)]

# 2. customers_salario_promedio solo tiene las columnas "customer_id" y "annual_income" asi que dejemosla como esta 

# 3. De customers_edad_mayor solo queremos las columnas "customer_id" y "age" para quedarnos con la edad mayor de
#    de cada "customer_id"
customers_edad_mayor <- customers_edad_mayor[, .(customer_id, age)]

# 4. Tabla final
customers_final <- customers_fecha_mayor[customers_edad_mayor, on = "customer_id"]
customers_final <- customers_salario_promedio[customers_final, on = "customer_id"]
customers_final


### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))

