library(tidyverse)
library(reprex)
library(sf)

#Highlight under this
library(spData)
data(world)

library(ggplot2)

ggplot(world,aes(x=gdpPercap, y=continent, color=continent))+
   geom_density(alpha=0.5,color=F)

