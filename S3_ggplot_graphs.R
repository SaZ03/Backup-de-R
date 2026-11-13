library(dslabs)
library(dplyr)
library(ggplot2)
library(ggthemes)

#Importar los datos
data("heights")
head(heights)

#Obtener un histograma de altura hombres
heights%>%filter(sex == 'Male') %>% ggplot(aes(x=height))

p <- heights%>%filter(sex == 'Male') %>% ggplot(aes(x=height))

#Generamos el grafico 
p + geom_histogram(binwidth = 1)

p + geom_histogram(binwidth = 1,fill='blue',col='black') + 
  ggtitle('Histogram of Male Height') + 
  xlab('Male Height') + 
  ylab('Frequency') 

p + geom_histogram(binwidth = 1,fill='blue',col='black') + 
  ggtitle('Histogram of Male Height') + 
  xlab('Male Height') + 
  ylab('Frequency') + 
  theme_hc()

#Generar histograma mujeres
pw <- heights%>%filter(sex == 'Female') %>% ggplot(aes(x=height))
pw + geom_histogram(binwidth = 1,fill='red',col='black') + 
  ggtitle('Histogram of Female Height') + 
  xlab('Male Height') + 
  ylab('Frequency') + 
  theme_hc()


## Density Plot
p + geom_density(fill = 'blue') + 
  ggtitle('Histogram of Male Height') + 
  xlab('Male Height') + 
  ylab('%') + 
  theme_hc()


# Density plot de 2 variables en un mismo grafico 
#Forma 1:
heights %>% ggplot(aes(height, group = sex)) + geom_density()
#Forma 2: 
heights %>% ggplot(aes(height, color = sex)) + geom_density()
#Forma 3: 
heights %>% ggplot(aes(height, fill = sex)) + geom_density(alpha = 0.3)

# Agregar titulos
heights %>% ggplot(aes(height, fill = sex)) + geom_density(alpha = 0.3) + 
  ggtitle('Density of Female and Male Height') + 
  xlab('Male Height') + 
  ylab('Frecuency (%)')

#Agregamos tema
heights %>% ggplot(aes(height, fill = sex)) + geom_density(alpha = 0.3) + 
  ggtitle('Density of Female and Male Height') + 
  xlab('Male Height') + 
  ylab('Frecuency (%)') + 
  theme_hc()


# Box plots
p_box <- heights %>% ggplot(aes(sex,height))

p_box + geom_boxplot()

#Color forma 1: 
p_box + geom_boxplot(fill = 'blue')

#Color forma 2:
p_box + geom_boxplot(aes(color=sex),fill='black',outlier.color='yellow')

#Color forma 3: 
p_box + geom_boxplot(aes(fill=sex),outlier.color='black') + 
  coord_flip()

#Agregar titulos
p_box + geom_boxplot(aes(fill=sex),outlier.color='black') + 
  ggtitle('Boxplot of Male and Female Height') + 
  xlab('Sex') + ylab('Height')


## Grid Plots o Dashboards
#Definir estructura del grafico
p_histm <- heights %>% filter(sex == 'Male') %>% ggplot(aes(height))
p_histm

#Generar los 3 histogramas individuales
p1 <- p_histm + geom_histogram(binwidth = 1, fill = 'blue', col = 'black') +
  ggtitle('binwidth=1') + theme_fivethirtyeight()
p1
p2 <- p_histm + geom_histogram(binwidth = 2, fill = 'blue', col = 'black') +
  ggtitle('binwidth=2') + theme_fivethirtyeight()
p2
p3 <- p_histm + geom_histogram(binwidth = 3, fill = 'blue', col = 'black') +
  ggtitle('binwidth=3') + theme_fivethirtyeight()
p3

library(gridExtra)
grid.arrange(p1,p2,p3,ncol=3,nrow=1)


#Realizar un dashboard de 2x2, que incluya hist male, hist female, 
#density plot female and male, y boxplots de female and male

#Construir cada grafico de forma individual 
pm <- p + geom_histogram(binwidth = 1, fill = 'blue',col = 'black') + theme_economist() + 
  ggtitle('Histogram of Male Height')
pm


pw2 <- p + geom_histogram(binwidth = 1, fill = 'red',col = 'black') + theme_economist() + 
  ggtitle('Histogram of Male Height')
pw2

ds <- heights %>% ggplot(aes(height, fill = sex)) + geom_density(alpha = 0.3) + 
  ggtitle('Density of Female and Male Height') + 
  xlab('Height') + theme_economist() 
ds


pbox2 <- p_box + geom_boxplot(aes(fill=sex),outlier.color='black') + 
  ggtitle('Boxplot of Male and Female Height') + 
  theme_economist()
pbox2

#Generamos el dashboard
grid.arrange(pm,pw2,ds,pbox2,ncol=2,nrow=2)

#Generar un dashboard de 3x2, que incluya además un gráfico de barras del sexo,
#y un violing plot de altura hombres y mujeres 
pb <- heights %>% ggplot(aes(sex)) + geom_bar(aes(fill=sex)) + 
  ggtitle('Bar plot') + theme_economist()
pb

#Grafico de violin 
pv <- p_box + geom_violin(aes(fill=sex),draw_quantiles = c(0.25,0.5,0.75)) + 
  ggtitle('violin plot') + theme_economist()
pv


#Generar el dashboard
grid.arrange(pm,pw2,ds,pbox2,pb,pv,ncol=3,nrow=2)
grid.arrange(pm,pw2,ds,pbox2,pb,pv,ncol=2,nrow=3)
