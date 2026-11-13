# Importo las librerías
library(dplyr)
library(ggplot2)
library(ggthemes)
library(gridExtra)

# Importo los datos
pinguins = read.csv("C:\\Users\\sergi\\Downloads\\pinguins_clean.csv", na.strings="")
head(pinguins)

# Reviso la Tabla de frecuencias
table(pinguins$sex)
table(pinguins$species)

# 1. Realizar un histograma únicamente de los pinguinos macho y la variable 
# body_mass_g con las siguientes características: binwidth=200, color de relleno 
# azul, color de bordes negro. No olvidar agregar los labels y títulos según el 
# contexto, y agrega el tema economist.

# Filtro solo a los machos y defino la estructura del gráfico
p_male <- pinguins %>% filter(sex == 'MALE') %>% ggplot(aes(x=body_mass_g))

# Genero el histograma con sus títulos y el tema economist
p1 <- p_male + geom_histogram(binwidth = 200, fill = 'blue', col = 'black') +
  ggtitle('Histogram of Male Penguins Body Mass') +
  xlab('Body Mass (g)') +
  ylab('Frequency') +
  theme_economist()
p1

# 2. Realizar un histograma únicamente de los pinguinos hembra y la variable 
# body_mass_g con las siguientes características: binwidth=200, color de relleno 
# rojo, color de bordes negro. No olvidar agregar los labels y títulos según el 
# contexto, y agrega el tema economist.

# Filtro solo a las hembras y defino la estructura del gráfico
p_female <- pinguins %>% filter(sex == 'FEMALE') %>% ggplot(aes(x=body_mass_g))

# Genero el histograma con sus títulos y el tema economist
p2 <- p_female + geom_histogram(binwidth = 200, fill = 'red', col = 'black') +
  ggtitle('Histogram of Female Penguins Body Mass') +
  xlab('Body Mass (g)') +
  ylab('Frequency') +
  theme_economist()
p2

# 3. Realizar un smooth density plot únicamente de los pinguinos macho y la 
# variable body_mass_g con las siguientes características: color de relleno azul. 
# No olvidar agregar los labels y títulos según el contexto, y agrega el tema 
# economist.

# Reutilizo la estructura de machos y genero el density plot
p3 <- p_male + geom_density(fill = 'blue') +
  ggtitle('Density of Male Penguins Body Mass') +
  xlab('Body Mass (g)') +
  ylab('Density') +
  theme_economist()
p3

# 4. Realizar un smooth density plot únicamente de los pinguinos hembra y la 
# variable body_mass_g con las siguientes características: color de relleno rojo. 
# No olvidar agregar los labels y títulos según el contexto, y agrega el tema 
# economist.

# Reutilizo la estructura de hembras y genero el density plot
p4 <- p_female + geom_density(fill = 'red') +
  ggtitle('Density of Female Penguins Body Mass') +
  xlab('Body Mass (g)') +
  ylab('Density') +
  theme_economist()
p4

# 5. Realizar un smooth density plot en el que de manera simultánea se vean los 
# gráficos de los pinguinos hembra y macho de la variable body_mass_g, con las 
# siguientes características: alpha=0.3. No olvidar agregar los labels y títulos 
# según el contexto, y agrega el thema economist.

# Uso fill = sex para que se vean ambos sexos en el mismo gráfico
p5 <- pinguins %>% ggplot(aes(body_mass_g, fill = sex)) + geom_density(alpha = 0.3) +
  ggtitle('Density of Female and Male Penguins Body Mass') +
  xlab('Body Mass (g)') +
  ylab('Density') +
  scale_fill_discrete(name="Sex") +
  theme_economist()
p5

# 6. Realizar un box plot en el que de manera simultánea se vean los gráficos de 
# los pinguinos hembra y macho de la variable body_mass_g. No olvidar agregar los 
# labels y títulos según el contexto, y agrega el tema economist.

# Defino la estructura con sexo en x y masa corporal en y
p_box <- pinguins %>% ggplot(aes(sex, body_mass_g))

# Genero el boxplot coloreado según el sexo
p6 <- p_box + geom_boxplot(aes(fill=sex), outlier.color='black') +
  ggtitle('Boxplot of Female and Male Penguins Body Mass') +
  xlab('Sex') +
  ylab('Body Mass (g)') +
  scale_fill_discrete(name="Sex") +
  theme_economist()
p6

# 7. Realizar un scatter plot entre las variables bill length (x) y body mass (y) 
# con las siguientes características: size=3, color según la especie. No olvidar 
# agregar los labels y títulos según el contexto, y agrega el thema economist.

# Genero el scatter plot coloreando los puntos según la especie
p7 <- pinguins %>% ggplot(aes(bill_length_mm, body_mass_g)) +
  geom_point(size=3, aes(col=species)) +
  ggtitle('Bill Length vs Body Mass') +
  xlab('Bill Length (mm)') +
  ylab('Body Mass (g)') +
  scale_color_discrete(name="Species") +
  theme_economist()
p7

# 8. Realizar un violint plot usando las variables que considere pertinentes.

# Elijo comparar la masa corporal por especie y agrego los cuartiles
p8 <- pinguins %>% ggplot(aes(species, body_mass_g)) +
  geom_violin(aes(fill=species), draw_quantiles = c(0.25,0.5,0.75)) +
  ggtitle('Violin Plot of Body Mass by Species') +
  xlab('Species') +
  ylab('Body Mass (g)') +
  scale_fill_discrete(name="Species") +
  theme_economist()
p8

# 9. Realizar un bar plot usando las variables que considere pertinentes.

# Elijo contar cuántos pingüinos hay por isla, coloreando según la especie
p9 <- pinguins %>% ggplot(aes(island)) + geom_bar(aes(fill=species)) +
  ggtitle('Number of Penguins by Island and Species') +
  xlab('Island') +
  ylab('Count') +
  scale_fill_discrete(name="Species") +
  theme_economist()
p9

# 10. Realizar un dasboard con grid plots de 3x3 (3 filas, 3 columnas). Es decir, 
# un dashboard con los 9 diagramas tomados de los anteriores puntos.

# Junto los 9 gráficos en un dashboard de 3 filas y 3 columnas
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9, ncol=3, nrow=3)