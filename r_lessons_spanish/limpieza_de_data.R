# Script info ---------------------------------------------------------------------------------------------
# Script Name: limpieza_de_data.R
# Script Author: Nicole Davila
# Created date: Tue Jun 22 05:51:08 2021
# Purpose: Este codigo es para aprender a limpiar data

### Import required libraries -----------------------------------------------------------------------------
install.packages("dplyr")
install.packages("tibble")
install.packages("stringr")
library(dplyr)
library(tibble)
library(stringr)
library(data.table)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------


### Load data ---------------------------------------------------------------------------------------------
iphone <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/iphone.csv")

### Pre-process -------------------------------------------------------------------------------------------
# Convierte la tabla en data.table
setDT(iphone)

# Investiga la estructura de la tabla. glimpse() es muy parecido a str()
glimpse(iphone)

# Si quieres ver un resumen de una columna, por ejemplo "price" usamos summary()
summary(iphone$price)

# La columna gb debe ser numerica porque GB son numeros. Una manera de condirmarlo es: 
is.numeric(iphone$gb)

# Identificar la clase de una columna
class(iphone$gb)

# Si vemos, la columna gb tiene "GB" al final, asi que la computadora lo lee como una palabra. Tenemos que
# remover esas letras para quedarnos solo con los numeros. Pra hacer eso con el library de data.frame:
iphone$gb_numeric = str_remove(iphone$gb, "GB")
class(iphone$gb_numeric)

# Vemos que sigue siendo de clase character asi que tenemos que hacer la conversion a numeric. Veamos como
# hacer eso usando el library de data.frame:
iphone$gb_numeric = as.numeric(iphone$gb_numeric)
class(iphone$gb_numeric)

# Ahora que tenemos una columna de GB de clase numeric, vamos a ver cual es el promedio de GB de los iphone.
# Para evitar errores por posibles valores NA, usemos el argumento na.rm = T
mean(iphone$gb_numeric, na.rm = T)

# Identificar si algun valor se sale del intervalo aceptado. Sabemos que un iPhone no puede dener mas de 512GB
# ni menos de 64. Veamos si algun valor se sale de lo normal.
summary(iphone$gb_numeric)

# Vemos que el minimo es 0, asi que algo anda mal. Cuales son las observaciones cuyo valor de gb_numeric es 0?
iphone[gb_numeric==0]

# Opciones para reemplazar este valor
# 1. Remover esas observaciones al seleccionar solo aquellas cuyo valor es menor o igual que 512 (max), mayor
#    o igual que 64 (min) o el valor es NA. De esta forma solo excluimos los valores que se salen del intervalo.
iphone_1 <- iphone[(512 >= gb_numeric & gb_numeric >= 64) | is.na(gb_numeric)]
# Si ves en el Environment, iphone_1 ahora tiene dos lineas menos que iphone porque removims las dos observaciones
# donde el valor era igual a cero

# 2. Convertir los valores en NA
iphone_2 <- copy(iphone)
iphone_2[!(512 >= gb_numeric & gb_numeric >= 64), gb_numeric := NA_real_]
summary(iphone_2$gb_numeric) 
# Vemos que ahora hay 2 NAs adicionales que reemplazaron las dos observaciones que antes eran igual a cero. Usamos
# copy para crear una copia de nuestra tabla "iphone" dejando la original intacta y modificando la nueva.

# 3. Reemplazarlos con el limite del intervalo. Si sabemos que el maximo de GB que puede tener un iPhone
#    es 512, vamos a reemplazarlo con ese valor.
iphone_3 <- copy(iphone)
iphone_3[gb_numeric > 512 | gb_numeric < 64, gb_numeric := 512]
mean(iphone$gb_numeric, na.rm = T)
mean(iphone_3$gb_numeric, na.rm = T)
# Vemos como el promedio aumento al reemplazar los valores con el maximo

# 4. Reemplazar con otro valor. Como sabemos que los GB no pueden ser decimales y que la opciones de GB de los
#    iPhone son: 512, 256, 128 y 64 podemos escoger el valor de estos que mas se repite en la columna usando la 
#    moda.
moda <- iphone[, .N, .(gb_numeric)][N == max(N)]$gb_numeric
moda
iphone_4 <- copy(iphone)
iphone_4[gb_numeric > 512 | gb_numeric < 64, gb_numeric := moda]
# En este caso reemplazamos los valores con 64 que es el numero de GB mas comun en la columna

# Cómo encontrar valores duplicados (duplicados completos)?
duplicados <- iphone[duplicated(iphone)]
duplicados

# Cómo deshacerte de duplicados completos?
unicos <- unique(iphone)

# Añadamos una columna para la ID
id <- c(1:nrow(iphone))
id <- paste0("00", id)
iphone[, id := id]

# Hagamos que algunas ids se dupliquen
iphone_id_duplicados <- rbindlist(list(iphone, iphone[1:50]))

# Seleccionar una sola columna para idenificar nivel de signularidad
iphone_id_unico <- unique(iphone_id_duplicados, by = "id")

# Importa el file hogar.csv
hogar <- read.csv("C:/Users/nicol/OneDrive/Public/Email attachments/Documents/R Sample Work/hogar.csv")

# Convierte la tabla hogar en un data.table
setDT(hogar)

# Modifica el nombre de la primera columna
setnames(hogar, "ï..id", "id")

# Selecciona los valores distintos con la fecha mas reciente
# 1. Convierte la columna en formato de fecha, ordena primero por id y luego por fecha en orden de mayor a menor
#    y luego selecciona los valores unicos por id.
hogar[, fecha := format(as.Date(as.character(fecha), format = "%Y"),"%Y")]
setorder(hogar, id, -fecha)
hogar_fecha_mayor <- unique(hogar, by = "id")

# 2. Agrupar por id y determinar el promedio 
#    Por ejemmplo, a traves de los a~os el salario de una persona puede haber cambiado, veamos a la persona
#    cuyo id es 189. Su salario ha aumentado durante los a~os pero tenemos una id que se repite y no queremos
#    eso.
hogar[id == 189]

# Si agrupamos por id y sacamos el promedio del salario:
hogar_salario_promedio <- hogar[ ,list(salario = mean(salario)), by = id]
hogar_salario_promedio

# 3. Para el numero de hijos, seleccionemos la observacion con el numero mayor de hijos. Sigue pasos parecidos
#    a los que usaste para la fecha
setorder(hogar, id, -numero_hijos)
hogar_hijos_mayor <- unique(hogar, by = "id")

# Combinemos nuestros datos. Tenemos tres nuevas tablas que tienen valores unicos.
# 1. De hogar_fecha_mayor, vamos a quedarnos con las columnsa id, fecha, genero, y casado. Así nos quedamos con el
#    genero y estado marital del a~o mas reciente para el cual tenemos data para cada id
hogar_fecha_mayor <- hogar_fecha_mayor[, .(id, genero, casado, fecha)]

# 2. hogar_salario_promedio solo tiene las columnas id y salario asi que dejemosla como esta 
# 3. De hogar_hijos_mayor solo queremos la columna id y numero_hijos para quedarnos con el numero mas alto de
#    hijos por id
hogar_hijos_mayor <- hogar_hijos_mayor[, .(id, numero_hijos)]

# 4. Tabla final
hogar_final <- hogar_fecha_mayor[hogar_hijos_mayor, on = "id"]
hogar_final <- hogar_salario_promedio[hogar_final, on = "id"]
hogar_final


### Process -----------------------------------------------------------------------------------------------


### Push data ---------------------------------------------------------------------------------------------


### Clean environment -------------------------------------------------------------------------------------
rm(list = ls(all.names = TRUE))

