# Script info ---------------------------------------------------------------------------------------------
# Script Name: funciones_y_loops.R 
# Script Author: Nicole Davila
# Created date: Mon Jul 26 20:26:53 2021
# Purpose: Este codigo es para ense~ar lo que son las funciones, loops y el lapply

### Import required libraries -----------------------------------------------------------------------------
library(data.table)

### Define functions --------------------------------------------------------------------------------------
edad_en_dias <- function(nombre = character(),
                        edad_en_anos = numeric()){
  tryCatch(
    expr = {
      edad_dias <- edad_en_anos * 365
      print(paste0(nombre, " tiene ", edad_dias, " dias de edad."))
      resultados <- list(tabla = data.table(nombre = nombre, edad_anos = edad_en_anos, edad_dias = edad_dias, estatus = "EXITO", mensaje = NA_character_),
                         dias_de_edad = edad_dias)
      return(resultados)
    }, error = function(e){
      print(paste0("Ha ocurrido un error calculando la edad en dias: ", e$message))
      resultados <- list(tabla = data.table(nombre = nombre, edad_anos = edad_en_anos, edad_dias = NA_real_, estatus = "ERROR", mensaje = e$message),
                         dias_de_edad = NA_real_)
      return(resultados)
    }
  )
}

### Define variables --------------------------------------------------------------------------------------
anos <- c(1, 2, 3, 4, 5, 6)
tabla_prueba <- data.table(nombre = c("Liann", "Nicole", "Jorge", "William"),
                           edad = c(16, 25, 39, 28))

tabla_error <- data.table(nombre = c("Liann", "Nicole", "Jorge", "William"),
                          edad = list(16, 25, "39", "28"))

### Load data ---------------------------------------------------------------------------------------------


### Pre-process -------------------------------------------------------------------------------------------


### Process -----------------------------------------------------------------------------------------------
# Cómo se aplicaría esta función con sólo una observación?
edad_en_dias(nombre = "Nicole", edad_en_anos = 25)

# No siempre tienes que especificar los argumentos, luego de que esten en el orden correcto:
edad_en_dias("Liann", 16)
edad_en_dias(16, "Liann")

# Para quedarte con la tabla que te dice el estatus de la funcion puedes correr:
tabla_resultados <- edad_en_dias(nombre = "Nicole", edad_en_anos = 25)$tabla
tabla_resultados

# Para quedarte con la edad en dias puedes correr:
edad_dias <- edad_en_dias(nombre = "Nicole", edad_en_anos = 25)$dias_de_edad
edad_dias

# Que pasa si hay un error?
edad_en_dias(nombre = "Liann", edad_en_anos = "17")

# Como capturar el error?
mensaje_error <- edad_en_dias(nombre = "Liann", edad_en_anos = "17")$tabla$mensaje
mensaje_error

# For loop
for(ano in anos){
  print(ano*365)
}

# Lapply
# Hagamos que la funcion solo regrese una tabla con resultados en lugar de una lista
edad_en_dias <- function(nombre = character(),
                         edad_en_anos = numeric()){
  tryCatch(
    expr = {
      edad_dias <- edad_en_anos * 365
      print(paste0(nombre, " tiene ", edad_dias, " dias de edad."))
      resultados <- data.table(nombre = nombre, edad_anos = edad_en_anos, edad_dias = edad_dias, estatus = "EXITO", mensaje = NA_character_)
      return(resultados)
    }, error = function(e){
      print(paste0("Ha ocurrido un error calculando la edad en dias: ", e$message))
      resultados <- data.table(nombre = nombre, edad_anos = edad_en_anos, edad_dias = NA_real_, estatus = "ERROR", mensaje = e$message)
      return(resultados)
    }
  )
}
 
# Cuando no hay error tenemos los siguientes resultados
resultados <- lapply(seq_along(tabla_prueba$nombre), function (nombre) edad_en_dias(nombre = tabla_prueba$nombre[[nombre]],
                                                                               edad_en_anos = tabla_prueba$edad[[nombre]]))

tabla_final <- rbindlist(resultados)

# CUando ocurre un error tenemos los siguientes resuktados
resultados2 <- lapply(seq_along(tabla_error$nombre), function (x) edad_en_dias(nombre = tabla_error$nombre[[x]],
                                                                               edad_en_anos = tabla_error$edad[[x]]))

tabla_final2 <- rbindlist(resultados2)

### Load data ---------------------------------------------------------------------------------------------
if(nrow(tabla_final[estatus == "EXITO"]) == nrow(tabla_final)){
  print("Todos los calculos fueron exitosos utilizando la tabla_prueba.")
}else{
  print(paste0(nrow(tabla_final[estatus != "EXITO"]), " de los intentos con tabla_prueba fallaron."))
}

if(nrow(tabla_final2[estatus == "EXITO"]) == nrow(tabla_final2)){
  print("Todos los calculos fueron exitosos utilizando la tabla_eror.")
}else{
  print(paste0(nrow(tabla_final2[estatus != "EXITO"]), " de los intentos con tabla_error fallaron."))
}

saludo <- function(nombre = character()){
  tryCatch(
    expr = {
      if (is.character(nombre)){
        print("Continuando el proceso.")
        resultado <- paste0("Hola ", nombre, "!")
        print(resultado)
        return(resultado)
      }else{
        print("El argumento no es de clase character!")
        stop("Error!")
      }
    }, error = function(e){
      resultado <- paste0("No hay nadie con ese nombre!")
      print(resultado)
      return(resultado)
    }
  )
}

for (nombre in list(1, "Nicole", "Jorge", "Liann", "William", 12, 13, 14)){
  saludo(nombre)
}

saludo <- function(nombre = character()){
      if (is.character(nombre)){
        print("Continuando el proceso.")
        resultado <- paste0("Hola ", nombre, "!")
        print(resultado)
        return(resultado)
      }else{
        print("El argumento no es de clase character!")
        stop("Error!")
      }

}

for (nombre in list(1, "Nicole", "Jorge", "Liann", "William", 12, 13, 14)){
  saludo(nombre)
}

lapply(list(1, "Nicole", "Jorge", "Liann", "William", 12, 13, 14), saludo)

# Clean up environment ----------------------------------------------------------------------------------