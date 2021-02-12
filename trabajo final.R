
library(ggplot2)
library(dplyr)
library(readxl)
library(stats)
library(seasonal)
library(seasonalview)

library(MASS)
library(strucchange)
library(zoo)
library(sandwich)
library(urca)
library(lmtest)
library(vars)
# Directorio de trabajo
setwd("~/Series-de-Tiempo-Fall2020-master/examen2")

# Pregunta 1 
# Variable:	Descripción
# IGAE :Indicador global de la actividad económica, base 2013
# INPC :Indice Nacional de Precios al consumidor
# TIIE ;Tasa de Interes Interbancaria de Equlibrio a 28 dias
# Importar la base de datos

B_Datos <- read_excel("database.xlsx", sheet = "dataset", col_names = TRUE)
view(B_Datos)

# Conversion a series de tiempo y desestacionalizacion:
IGAE <- ts(B_Datos$IGAE, 
           start = c(2008, 1), 
           freq = 12)
Seas_IGAE <- seas(IGAE)
plot(Seas_IGAE)
IGAE_Ad <- final(Seas_IGAE)
plot(IGAE)
summary(Seas_IGAE)
##############################################
INPC <- ts(B_Datos$INPC, 
             start = c(2008, 1), 
             freq = 12)
Seas_INPC <- seas(INPC)
plot(Seas_INPC)
INPC_Ad <- final(Seas_INPC)
plot(INPC)
summary(Seas_INPC)
##############################################
TIIE_28 <- ts(B_Datos$TIIE_28, 
             start = c(2008, 1), 
             freq = 12)
Seas_TIIE_28 <- seas(TIIE_28)
plot(Seas_TIIE_28)
TIIE_28_Ad <- final(Seas_TIIE_28)
plot(TIIE_28)
summary(Seas_TIIE_28)
#****************************************************************************************
# Agregando nuevas series desestacionalizadas:

Datos_Ad <- data.frame(cbind(IGAE_Ad, INPC_Ad, TIIE_28_Ad))

Datos_Adj <- cbind(B_Datos, Datos_Ad)

save(Datos_Adj, file = "Datos_Adj.RData")

load("Datos_Adj.RData")
view(Datos_Adj)

# Convertimos a series de tiempo

Datos <- ts(Datos_Adj[5: 7], 
            start = c(2008, 1), 
            end = c(2020, 11), 
            freq = 12)
# Logaritmos
LDatos <- log(Datos)

# Diferencias
DLDatos <- diff(log(Datos, base = exp(1)), 
                lag = 1, 
                differences = 1)

# Graficas
# grafica en nivles
plot(LDatos, 
     plot.type = "m", nc = 2,
     col = c("forestgreen", "violetred3", "orangered1"), 
     main = "Series en Logaritmos", 
     xlab = "Tiempo")

# grafica en diferencias
plot(DLDatos, 
     plot.type = "m", nc = 2,
     col = c("deeppink", "darkturquoise", "darkgreen"), 
     main = "Series en Diferencias Logaritmicas", 
     xlab = "Tiempo")

#****************************************************************************************
#Pruebas de Raices Unitarias
#****************************************************************************************

# Regla de dedo para idenificar el numero de rezagos
#p = int{4*(155/100)^(1/4)}
# int(4*(155/100)^(1/4))
# = int{4.46316472}
# = 4 
p <- (4*(155/100)^(1/4))
#############################

#****************************************************************************************

# 2. PP: Phillips - Perron Test
# ur.pp = function (x, type = c("Z-alpha", "Z-tau"), model = c("constant", "trend"), lags = c("short", "long"), use.lag = NULL) 

# NIVELES: IGAE

# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 1], type = "Z-tau", model = "trend", use.lag = 4)) #modelo a, con tendencia
# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 1], type = "Z-tau", model = "constant", use.lag = 4)) #modelo b, con constante

# DIFERENCIAS: IGAE
summary(ur.pp(DLDatos[, 1], type = "Z-tau", model = "trend", use.lag = 4))
# el t estadistico es menor al t de tablas, se rechaza ho, la serie es estacionaria 
# la serie se tiene que diferenciar al menos una vez
summary(ur.pp(DLDatos[, 1], type = "Z-tau", model = "constant", use.lag = 5))
# el t estadistico es menor al t de tablas, se rechaza ho, la serie es estacionaria 
# la serie se tiene que diferenciar al menos una vez

# NIVELES: INPC

# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 2], type = "Z-tau", model = "trend", use.lag = 4)) #modelo a, con tendencia
# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 2], type = "Z-tau", model = "constant", use.lag = 4)) #modelo b, con constante

# DIFERENCIAS: INPC
summary(ur.pp(DLDatos[, 2], type = "Z-tau", model = "trend", use.lag = 4))
# el t estadistico es menor al t de tablas, se rechaza ho, la serie es estacionaria 
# la serie se tiene que diferenciar al menos una vez
summary(ur.pp(DLDatos[, 2], type = "Z-tau", model = "constant", use.lag = 4))
# el t estadistico es menorr al t de tablas, se rechaza ho, la serie  es estacionaria 
# la serie se tiene que diferenciar al menos una vez

# NIVELES: TIIE_28

# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 3], type = "Z-tau", model = "trend", use.lag = 4)) #modelo a, con tendencia
# el t estadistico es mayor al t de tablas, se acepta ho, la serie no es estacionaria  
summary(ur.pp(LDatos[, 3], type = "Z-tau", model = "constant", use.lag = 4)) #modelo b, con constante

# DIFERENCIAS: TIIE_28 

summary(ur.pp(DLDatos[, 3], type = "Z-tau", model = "trend", use.lag = 4))
# el t estadistico es menorr al t de tablas, se rechaza ho, la serie no es estacionaria 
# la serie se tiene que diferenciar al menos una vez
summary(ur.pp(DLDatos[, 3], type = "Z-tau", model = "constant", use.lag = 4))
# el t estadistico es menor al t de tablas, se rechaza ho, la serie no es estacionaria 
# la serie se tiene que diferenciar al menos una vez

#****************************************************************************************

# Dado que la conclusion es que el modelo tiene el mismo orden de integracion cuando le aplicamos el modelo "a" y el modelo "b" 
# ya que en el modelo "b" fue necesario aplicar la primera diferencia para que la fuera estacionario
# Procedemos a realizar un modelo VAR(p) en niveles
# VAR(p): En niveles
# ARGUMENTOS: 
# function (y, p = 1, 
# type = c("const", "trend", "both", "none"), 
# season = NULL, exogen = NULL, lag.max = NULL, 
# ic = c("AIC", "HQ", "SC", "FPE"))

# VAR(p) Seleccion:
# si elegimos el modelo con ambos, el numero de rezagos de acuerdo al criterio AIC debe ser 8 rezagos
VARselect(LDatos, lag.max = 10, type = "both")

# si elegimos el modelo con tendencia, el numero de rezagos de acuerdo al criterio AIC debe ser 2 rezagos
VARselect(LDatos, lag.max = 10, type = "trend")

# si elegimos el modelo con constante, el numero de rezagos de acuerdo al criterio AIC debe ser 2 rezagos
VARselect(LDatos, lag.max = 10, type = "const")

# si elegimos el modelo sin tendencia y sin consatante, el numero de rezagos de acuerdo al criterio AIC debe ser 4 rezagos
VARselect(LDatos, lag.max = 10, type = "none")

# El tipo de modelo que vamos a utlizar es con constante, ya que al realizar las pruebas de raices unitarias
# el modelo con constante tiene el mismo orden de integracion i=1.
# Para realizar el numero de rezagos utilizamos el criterio AIC, el cual nos dio que debemos utilizar 2 rezagos
# VAR Estimacion:
VAR_1 <- VAR(LDatos, p = 2, type = "trend")

summary(VAR_1)

VAR_1
plot(VAR_1)


#****************************************************************************************
# Cointegration Test: Realizamos la prueba de cointegracion
#****************************************************************************************
# ca.jo = function (x, type = c("eigen", "trace"), ecdet = c("none", "const", 
# "trend"), K = 2, spec = c("longrun", "transitory"), season = NULL, 
# dumvar = NULL) 

# Existen al menos "d" vectores de cointegracion
# rechazo Ho, no hay cero vectores de cointegracion
# existe al menos 1 vector de cointegracion considerando un mecanismo con tendencia y con 2 rezagos
# el igae con relacion al INPC de largo plazo es positiva
# el igae con relacion al TIIE_28 de largo plazo es negativa
# y Una tendencia negativa

summary(ca.jo(LDatos, type = "trace", ecdet = "trend", K = 2, spec = "longrun"))


# Existen al menos "" vectores de cointegracion
# rechazo Ho, no hay cero vectores de cointegracion
# existe al menos 1 vector de cointegracion considerando un mecanismo con tendencia y con 2 rezagos
# el igae en su relacion con el INPC de largo plazo es positiva
# el igae en su relacion con el TIIE de largo plazo es negativa
# y Una constante positiva

summary(ca.jo(LDatos, type = "trace", ecdet = "const", K = 2, spec = "longrun"))

# Existen al menos "" vectores de cointegracion
# rechazo Ho, no hay cero vectores de cointegracion
# existe al menos 1 vector de cointegracion considerando un mecanismo sin tendencia y sin constante y 4 rezagos

summary(ca.jo(LDatos, type = "trace", ecdet = "none", K = 4, spec = "longrun"))

# Concluimos que la series cointegran utilizando un modelo con tendencia, un modelo con constante y sin tendencia y constante
# Utilizamos un procedimiento con constante

CA_1 <- ca.jo(LDatos, type = "trace", ecdet = "trend", K = 2, spec = "longrun")
summary(CA_1)

# Calculamos ls residuales

# Residuales:

TT <- ts(c(1:155), 
         start = c(2008, 1), 
         end = c(2020, 11), 
         freq = 12)
# calculamos la ecuacion de los residuales utilizando los resultados de summary(CA_1)
U <- LDatos[ , 1] - 2.839673805*LDatos[ , 2] + 0.051677628*LDatos[ , 3] + 0.007464802*TT
# forma de encontar un cobminacion lineal de los vectores incluio en el vector y
# generando un objeto estacionario

# Residual que genera la relacion de largo plazo de las series que cointegran alrededor de una tendencia
# estos residuales son estacionarios
plot(U, main = "Residuales de la Ecuacion de Cointegracion",
     type = "l", 
     col = "darkred")

# Aplicamos las Raices Unitarias para saber si los residuales son estacionarios 
# NIVELES
# los residuales son estacionarios alrededor de una tendencia

# Raices Unitarias
# NIVELES
summary(ur.df(U, type = "trend", lags = 2))

summary(ur.df(U, type = "drift", lags = 2))

summary(ur.df(U, type = "none", lags = 4))

# DIFERENCIAS
summary(ur.df(DLDatos[,1], type = "trend", lags = 2))

summary(ur.df(DLDatos[,1], type = "drift", lags = 2))

summary(ur.df(DLDatos[,1], type = "none", lags = 4))

