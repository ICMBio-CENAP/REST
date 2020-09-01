## Testes com modelo REST de Nakashima et al. 2018 Jour. App. Ecol. 
## Codigo adaptado do material suplementar do artigo original

# A ideia aqui e re-analisar os dados do Nakashima e ver se chegamos nas mesmas estimativas
# Alem de entender a logica do codigo e do modelo
# A tabela S7 do material suplementar tem estimativas para Duikers com area pequena, grande, diferentes ambientes etc


## ---- Carregar pacotes ----
#library(R2OpenBUGS)
library(R2jags)
library(here)


## ---- Ler dados ----
data <- read.csv(here("data", "Nakashima_JAPPL_2017.csv"))
data <- subset(data, Species == "BlueDuiker")
data <- subset(data, Transect == "SW") # testar somente com os dados dos swamps para comparar com tabela S7 
#data <- subset(data, Transect == "OS")

# ---- Preparar dados para modelo do JAGS ----
Ncam <- length(unique(data$CameraID))
S <- 2.67/1000000 # Area focal grande
#S <- 0.67/1000000 # area focal pequena
#day <- as.numeric(max(as.Date(data$DateTime))-min(as.Date(data$DateTime))) # duracao da amostragem, idealmente deveria ser calculada por camera
actv <- 0.32	# ver tabela S7 material suplementar Nakashima
t <- 24*60*60*day*actv  # Research effort (sec.) per camera trap
#eff <- rep(t, Ncam) # idealmente o esforco deveria ser calculado por camera:

# calcular esforco separado por camera (assumindo que dados incluem data inicial e final de cada uma)
day <- rep(NA, Ncam)
for(i in 1:length(day)) {
  df1 <- subset(data, CameraID == unique(data$CameraID)[i])
  min <- min(as.Date(df1$DateTime))
  max <- max(as.Date(df1$DateTime))
  day[i] <- as.numeric(max-min)
}
eff <- 24*60*60*day*actv
eff # algumas cameras estao com esforco zero, usar a media do esforco para prencher:
eff[eff==0] <- mean(eff)

# Criar coluna somente com staying time de BlueDuiker:
#data$NewData <- NA
#for(i in 1:nrow(data)) {
#  if(data$Species[i] == "BlueDuiker") {
#  data$NewData[i] <- data$StayLarge[i]
#  }
#  else {
#  data$NewData[i] <- 0
#  }
#}

# somar staying time por camera e total
y <- aggregate(data$StayLarge, by=list(data$CameraID), FUN=sum, na.rm = TRUE)
#y <- aggregate(data$NewData, by=list(data$CameraID), FUN=sum, na.rm = TRUE)
y <- round(y$x)
y[is.na(y)] <- 0
Nstay <- sum(y)


# ---- Especificar modelo na linguagem do JAGS ----
model.file <- here("bin", "model1.txt")
sink(model.file)
cat("model
    {
    for(i in 1:Nstay){
    #stay[i] ~ dexp(lambda)T(cens[i],)   # use T(,) instead of I(,), https://sourceforge.net/p/mcmc-jags/discussion/610037/thread/4288692c/
    stay[i] ~ dexp(lambda)
    }
    
    for(i in 1:Ncam){
    pcy[i] ~ dpois(mu.y[i])
    y[i] ~ dpois(mu.y[i])
    mu.y[i] <- mu[i]*u[i]
    log(mu[i]) <- log(S)+log(eff[i])+log(rho)+log(lambda)
    u[i] ~ dgamma(alpha,alpha)
    }
    
    lambda ~ dgamma(0.1,0.1)
    rho ~ dgamma(0.1,0.1)
    alpha ~ dunif(0,100)
    
    }
    ")
sink()


# ---- Agrupar dados, inits, parametros etc ----
#datalist <- list(y=y,S=S,eff=eff,stay=stay,cens=cens,Nstay=Nstay,Ncam=Ncam)
datalist <- list(y=y, S=S, eff=eff, Nstay=Nstay, Ncam=Ncam)

inits <- function(){
  list(lambda=1/8,rho=7,invalpha=1)
}

parameters <- c("lambda","rho","stay","mu","alpha","pcy")    


# ---- Rodar o modelo ----
res <- jags(datalist, inits, parameters, model.file,
          n.chains=3, n.iter=2000, n.burnin=1000, n.thin=20, working.directory = getwd())
res

# Checar estimativa de rho (densidade)
summary(res$BUGSoutput$sims.list$rho) # valores nao batem com os do artigo, investigar



