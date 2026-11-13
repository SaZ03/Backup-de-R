# Importo las librerías
library(readxl)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(gridExtra)

# Importo los datos
galton = read_excel("C:\\Users\\sergi\\Downloads\\Galton_dataset.xlsx")
head(galton)

# Reviso la Tabla de frecuencias
table(galton$Who)

# Question 1
# Make a blue histogram of parent's height using a binwidth of 1. Do not forget 
# to put a xlabel and title.

# Filtro solo a los padres y defino la estructura del gráfico
p_parent <- galton %>% filter(Who == 'Parent') %>% ggplot(aes(x=Height))

# Genero el histograma azul con sus títulos
p1 <- p_parent + geom_histogram(binwidth = 1, fill = 'blue', col = 'black') +
  ggtitle('Histogram of Parent Height') +
  xlab('Parent Height (inches)') +
  ylab('Frequency')
p1

# Question 2
# What can you say about this blue histogram?


# Question 3
# Make a red histogram of child height using a binwidth of 1. Do not forget to 
# put a xlabel and title.

# Filtro solo a los hijos y defino la estructura del gráfico
p_child <- galton %>% filter(Who == 'Child') %>% ggplot(aes(x=Height))

# Genero el histograma rojo con sus títulos
p2 <- p_child + geom_histogram(binwidth = 1, fill = 'red', col = 'black') +
  ggtitle('Histogram of Child Height') +
  xlab('Child Height (inches)') +
  ylab('Frequency')
p2

# Question 4
# What can you say about this picture?


# Question 5
# Make one density plot containing both the information of parent and child 
# height in one pitcure. Do not forget to put a title and fill them with 
# different colors.

# Uso fill = Who para que padres e hijos aparezcan en el mismo gráfico con 
# colores distintos
p3 <- galton %>% ggplot(aes(Height, fill = Who)) + geom_density(alpha = 0.3) +
  ggtitle('Density of Parent and Child Height') +
  xlab('Height (inches)') +
  ylab('Density')
p3

# Question 6
# What can you say about this picture?

# Question 7
# Make a boxplot of parent and child height. Do not forget to fill them with two 
# different colors and put a title.

# Defino la estructura con el grupo en x y la altura en y
p_box <- galton %>% ggplot(aes(Who, Height))

# Genero el boxplot coloreado según el grupo
p4 <- p_box + geom_boxplot(aes(fill=Who), outlier.color='black') +
  ggtitle('Boxplot of Parent and Child Height') +
  xlab('Group') +
  ylab('Height (inches)')
p4

# Question 8
# What can you say about this picture?


# Question 9
# Make a grid plot with 2 columns and 2 rows containing the histograms of parent 
# and child height, the density plot and the box plot previously built. 4 plots 
# in total. Please guarantee that all pictures have a title. Do not put any style.

# Junto los 4 gráficos en un grid de 2x2 sin estilo
grid.arrange(p1,p2,p3,p4,ncol=2,nrow=2)

# Question 10
# Put the style that you prefer to the previous grid plot and show the result.

# Le agrego el tema economist a cada gráfico
p1s <- p1 + theme_economist()
p2s <- p2 + theme_economist()
p3s <- p3 + theme_economist()
p4s <- p4 + theme_economist()

# Genero el grid de 2x2 con estilo
grid.arrange(p1s,p2s,p3s,p4s,ncol=2,nrow=2)

# Question 11
# Please analyze these both grid plots and conclude.

# Question 12
# Finally, make a grid plot with 2 columns and 3 rows containing all the diagrams 
# that you consider very relevant (remember the diagrams seen in class), 6 plots 
# in total. Please guarantee that all pictures have a title. Do not put any style.

# Agrego un violin plot con los cuartiles para comparar la forma de las 
# distribuciones
p5 <- p_box + geom_violin(aes(fill=Who), draw_quantiles = c(0.25,0.5,0.75)) +
  ggtitle('Violin Plot of Parent and Child Height') +
  xlab('Group') +
  ylab('Height (inches)')
p5

# Agrego un bar plot para revisar cuántos datos hay de cada grupo
p6 <- galton %>% ggplot(aes(Who)) + geom_bar(aes(fill=Who)) +
  ggtitle('Bar Plot of Parents and Children') +
  xlab('Group') +
  ylab('Count')
p6

# Junto los 6 gráficos en un grid de 3 filas y 2 columnas sin estilo
grid.arrange(p1,p2,p3,p4,p5,p6,ncol=2,nrow=3)

# Question 13
# Put the style that you prefer to the previous grid plot big version and show 
# the result.

# Le agrego el tema economist a los 2 gráficos nuevos
p5s <- p5 + theme_economist()
p6s <- p6 + theme_economist()

# Genero el grid de 3x2 con estilo
grid.arrange(p1s,p2s,p3s,p4s,p5s,p6s,ncol=2,nrow=3)

# Question 14
# Do not forget to upload the R file