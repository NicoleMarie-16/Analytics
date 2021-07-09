# Script info ---------------------------------------------------------------------------------------------
# Script Name: asignacion_3.R
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

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table


# Investiga la estructura de la tabla. 


# Si quieres ver un resumen de una columna, por ejemplo "spendig_score", qué función usarías?


# La columna "annual_income" debe ser numerica. Una manera de condirmarlo es: 


# Vemos que "annual_income" no es de clase numérico. De qué clase es?


# Si vemos, la columna "annual_income" tiene un símbolo de "$", asi que la computadora lo lee como una palabra. Tenemos que
# remover esos símbolos de la columna para quedarnos solo con los numeros. 


# Vemos que sigue siendo de clase character asi que tenemos que hacer la conversion a numeric. 


# Ahora que tenemos una columna de annual_income de clase numeric, vamos a ver cual es el salario promedio de los clientes.
# Para evitar errores por posibles valores NA, usemos el argumento na.rm = T


# Identificar si algun valor se sale del intervalo aceptado. La columna "year" no debe tener fechas en el futuro,
# así que si algún año es mayor que 2021, lo podemos reemplazar con 2021 que es el año actual, removerlos del todo,
# cambiarlos por NA, o reemplazarlos con otro valor.


# Opción 1: Reemplazar con 2021. Primero crea una copia de la tabla actual para no alterarla. Llama la nueva tabla
#           customers_1


# Asegurúmonos de que ya no queden valores mayores que 2021



# Opción 2: Remueve cualquier observación cuyo valor sea mayor que 2021. Crea una copia de la tabla original y llámala
#           customers_2


# Asegurúmonos de que ya no queden valores mayores que 2021


# Otra manera de corroborar es que la tabla original debe tener más líneas que la copia


#  Opción 3: Convertir los valores en NA. Crea una tercera copia de la tabla original y llámala customers_3



# Opción 4: Reemplazar con otro valor. Como sabemos que los años no pueden ser decimales, podemos escoger el
#           valor de estos que mas se repite en la columna usando la moda.

# Primero determina la moda de la columna y asígnasela a una nueva variable llamada "moda"


# Crea una cuarta copia de la tabla original, llamada customers_4 y reemplaza los valores mayores a 2021 con
# la variable "moda" que generaste previamente.


# Cómo encontrar valores duplicados (duplicados completos)?


# Si miras la tabla "duplicados" que creaste anteriormente, hay duplicados completos?


# Cómo deshacerte de duplicados completos?


# Ahora en vez de seleccionar los valores únicos en base a todas las columnas, hazlo sólo con la columna "customer_id"


# Selecciona los valores distintos con la fecha mas reciente
# Ordena la tabla "customers" por "customer_id" ascendente y "year" descendente y luego selecciona los valores únicos
# por "customer_id"


# Agrupar por id y determinar el salario promedio. Calcula el promedio de "annual_income" agrupando por "customer_id"


# Para la edad, seleccionemos la observación con el valor mayor. Sigue pasos parecidos a los que usaste para la fecha
# pero usando la columna "age" en lugar de "year"


# Combinemos nuestros datos. Tenemos tres nuevas tablas que tienen valores unicos.
# 1. De customers_fecha_mayor, vamos a quedarnos con las columnas "customer_id", "gender", "spending_score", y "year".
#    Así nos quedamos con el genero y score de gastos del año mas reciente para el cual tenemos datos


# 2. customers_salario_promedio solo tiene las columnas "customer_id" y "annual_income" asi que dejemosla como esta 

# 3. De customers_edad_mayor solo queremos las columnas "customer_id" y "age" para quedarnos con la edad mayor de
#    de cada "customer_id"


# 4. Tabla final



### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
options(warn = defaultW)
rm(list = ls(all.names = TRUE))

