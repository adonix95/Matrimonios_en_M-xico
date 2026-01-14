# INSTRUCCIONES ####
#Hola, con este código podrá procesar todos los datos de estadística de matrimonios que da INEGI
# Primero deberá descargarlos de https://www.inegi.org.mx/programas/emat/#microdatos
#En este enlace accederá a los microdatos y podrá bajar año por año las estadísticas  que necesite.
#INEGI permite bajar en diversos formatos (csv, xlsx, dta, dbf) Hemos elegido hacer este proceso con dbf (Compatible con SPSS)
#Por lo tanto, para que este codigo funcione tendrá que descargar todas las bases que necesite en dbf.
#Nosotros hemos elegido todos los años,


# 1.- CARGAR LIBRERIAS ####
#Las librerias ayudarán a ejercer las funciones necesarias para crear las bases, serán como nuestra caja de herramientas.
library(foreign)
library(dplyr)
library(purrr)
library(ggplot2)


# 2.- DEFINIR CARPETA ORIGEN ####
# Ruta donde están los archivos .dbf (Usted deberá reemplazar con su propia ruta, es decir con la carpeta donde dejó las bases descargadas)
ruta_base <- "C:/Users/Saul_/OneDrive/Econometria.org/Publicaciones/RRSS/1.- Matrimonios publicacion/bases matrimonios/" #Este es un ejemplo.
anios <- 1990:2023 #Seleccione los años a cargar, si solo tiene digamos 2009 a 2018, deberá escribir 2009:2018


# 3.- CREAR FUNCIÓN PARA PROCESAR CADA AÑO ####
#Cada base de datos debe cargarse y procesarse. Se añade primero a Rstudio y al final se compilará en una sola base. 
#Para facilitar este proceso, se ha creado una función que lo hará automático.
# Función para procesar cada 
procesar_matrimonios <- function(anio) {
  archivo <- paste0(ruta_base, "MATRI", substr(anio, 3, 4), ".dbf")
  if (!file.exists(archivo)) return(NULL)
  
  base <- read.dbf(archivo, as.is = TRUE)
  
  base <- base %>%
    mutate(ANIO = anio)
  
  # Total de matrimonios heterosexuales por año
  total_hetero <- base %>%
    filter(GENERO == 1) %>%
    nrow()
  
  # Filtrar mujer joven y hombre mayor
  base_filtrada <- base %>%
    filter(
      GENERO == 1,
      (
        (SEXO_CON1 == 2 & EDAD_CON1 >= 20 & EDAD_CON1 <= 30 &
           SEXO_CON2 == 1 & EDAD_CON2 >= 55) |
          (SEXO_CON2 == 2 & EDAD_CON2 >= 20 & EDAD_CON2 <= 30 &
             SEXO_CON1 == 1 & EDAD_CON1 >= 55)
      )
    )
  
  total_filtrado <- nrow(base_filtrada)
  
  tibble(
    ANIO = anio,
    TOTAL_RELACIONES = total_filtrado,
    TOTAL_HETERO = total_hetero,
    PORCENTAJE_RELATIVO = round(100 * total_filtrado / total_hetero, 3),
    EDAD_PROMEDIO_MUJER = mean(ifelse(base_filtrada$SEXO_CON1 == 2, base_filtrada$EDAD_CON1, base_filtrada$EDAD_CON2), na.rm = TRUE),
    EDAD_PROMEDIO_HOMBRE = mean(ifelse(base_filtrada$SEXO_CON1 == 1, base_filtrada$EDAD_CON1, base_filtrada$EDAD_CON2), na.rm = TRUE)
  )
}

# Procesar todos los años
serie_matrimonios <- map_dfr(anios, procesar_matrimonios)

# Mostrar tabla de resultados
print(serie_matrimonios)
