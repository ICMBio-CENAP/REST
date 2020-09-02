
# Teste com o pacote remBoot
# https://github.com/arcaravaggi/remBoot
# Caravaggi A. remBoot: An R package for Random Encounter Modelling. Journal of Open Source Software. 2(10). doi: 10.21105/joss.00176


# instalar pacote remBoot do github
library(devtools)
devtools::install_github("arcaravaggi/remBoot")


library(remBoot)

# carregar e preparar dados de exemplo

data(hDat)
head(hDat) # dar uma espiada no formato dos dados

grpDat <- split_dat(hDat) # aparentemente separa as cameras
tm <- 3600  
v <- 1.4  

# rodar funcao
rem(dat = grpDat[[1]], tm = 3600, v = 1.4)  
rem(dat = grpDat[[2]], tm = 3360, v = 1.4)

nboots <- 1000  
remsD <- lapply(grpDat, boot_sd)   
remsSD <- lapply(remsD, sd)  
remsSD 

