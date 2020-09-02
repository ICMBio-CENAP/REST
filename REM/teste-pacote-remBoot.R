
# Teste com o pacote remBoot
# https://github.com/arcaravaggi/remBoot
# Caravaggi A. remBoot: An R package for Random Encounter Modelling. Journal of Open Source Software. 2(10). doi: 10.21105/joss.00176


# instalar pacote remBoot do github
library(devtools)
devtools::install_github("arcaravaggi/remBoot")

# carregar o pacote
library(remBoot)

# carregar os dados (exemplo do github)
data(hDat)
head(hDat) # espiar formato dos dados

# alguns ajustes
# y is the total number of photographic events
# t camera-trap survey effort
# v average speed of animal movement
# and r and h the radius and angle of the camera-trap detection zone
# (Gray, T. 2018. Monitoring tropical forest ungulates using camera-trap data. Journal of Zoology)
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

