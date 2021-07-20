# Script info ---------------------------------------------------------------------------------------------
# Script Name: operaciones_if_else.R 
# Script Author: Nicole Davila
# Created date: Mon Jul 12 21:04:35 2021
# Purpose: Este codigo explora los usos de las operaciones relacionales y los if-else

### Import required libraries -----------------------------------------------------------------------------


library(lubridate)

### Define functions --------------------------------------------------------------------------------------


### Define variables --------------------------------------------------------------------------------------


### Load data ---------------------------------------------------------------------------------------------


### Pre-process -------------------------------------------------------------------------------------------


### Process -----------------------------------------------------------------------------------------------

# Evaluar si dos textos son equivalentes
"Nicole" == "nicole" # Falso
"Liann" == "Liann" # Cierto

# Evaluar si dos textos son diferentes
"Nicole" != "nicole" # Cierto
"Liann" != "Liann" # Falso

# Evaluar si un numero es mayor que otro
20 > 15 # Cierto
20 > 100 # Falso

# Evaluar si un numero es menor que otro
20 < 15 # Falso
20 < 100 #Cierto

# Evaluar si un numero es mayor o igual que otro
20 >= 20 # Cierto
20 >= 15 # Cierto
15 >= 20 # Falso

# Evaluar si un numero es menor o igual que otro
# 15 =< 20 # Falso
# 15 =< 15 # Cierto
# 15 =< 20 # Cierto

# Evaluar si un valor está presente en un vector de valores
"gato" %in% c("gato", "perro", "conejo") # Cierto
"caballo" %in% c("gato", "perro", "conejo") # Falso

# Evaluar una de varias expresiones
"Nicole" == "Nicole" | "Liann" == "liann" # Cierto (la primera comparacion es cierta y la segunda no pero estamos usando el operador "o")
"Nicole" == "Nicole" | "Liann" == "Liann" # Cierto (ambas comparaciones son ciertas)
"Nicole" == "nicole" | "Liann" == "liann" # Falso (ninguna de las comparaciones es cierta)

# Evaluar multiples expresiones
"Nicole" == "Nicole" & "Liann" == "liann" # Falso (la primera comparacion es cierta pero la segunda no y estamos usando el operador "y")
"Nicole" == "Nicole" & "Liann" == "Liann" # Cierto (ambas comparaciones son ciertas)
"Nicole" == "nicole" & "Liann" == "liann" # Falso (ninguna de las comparaciones es cierta)

# If-Else
edad_nicole <- 25
edad_liann <- 16

# Si la edad de Nicole es mayor que la edad de Liann, imprime que Nicole es mayor

if (edad_nicole > edad_liann) {
  print("Nicole es mayor que Liann.")
} # Esto te imprime el mensaje porque la comparacion evalua a Cierto

if (edad_nicole < edad_liann) {
  print("Liann es mayor que Nicole.")
} # Esto no hace nada porque la expresion evalua a Falso y no especificamos una accion alterna

# Si la edad de Nicole es mayor que la edad de Liann, imprime que Nicole es mayor y si no, imprime que Liann es mauyor
if (edad_nicole > edad_liann) {
  print("Nicole es mayor que Liann.")
} else {
  print("Liann es mayor que Nicole.")
} # Esto imprime que Nicole es mayor porque la comparacion evalua a Cierto

if (edad_nicole < edad_liann) {
  print("Nicole es mayor que Liann.")
} else {
  print("Liann es mayor que Nicole.")
} # Esto imprime que Liann es mayor porque la primera comparacion evalua afalso pero esta vez especificamos una accion alterna

# Podemos hacer if-else statements mas complicados
# Si la hora es de las 5 am a las 12 del medio dia, imprimir que es la ma~ana
# Si la hora es del medio dia hasta las 7 de la noche, imprimir que es la tarde
# Si no, imprimir que es la noche
if (hour(Sys.time()) >= 0 & 12 >= hour(Sys.time())) {
  print("Es la ma~ana.")
} else {
  if (hour(Sys.time()) > 12 & hour(Sys.time()) < 19) {
    print("Es la tarde.")
  } else {
    print("Es la noche.")
  }
}


### Load data ---------------------------------------------------------------------------------------------


# Clean up environment ----------------------------------------------------------------------------------