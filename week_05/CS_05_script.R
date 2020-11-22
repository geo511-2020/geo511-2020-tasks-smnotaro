library(spData)
library(sf)
library(tidyverse)
library(units)

#load 'world' data from spData package
data(world)  
# load 'states' boundaries from spData package
data(us_states)

#plot if desired
#plot(world[1])
#plot(us_states[1])

albers="+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
world_transform <- st_transform(world, crs = albers)
head(world)

Canada_filtered <- world_transform %>%
  filter(name_long == "Canada")

Canada_buffered <- st_buffer(Canada_filtered, dist = 10000)
#Got help with transformation from Betsy
#Got st_buffer() function from Chapter 5 of Geocomputation with R

us_transform <- st_transform(us_states, albers)
head(us_states)

NY_filtered <- us_transform %>%
  filter(NAME == "New York")
view(NY_filtered)

NY_and_Canada <- st_intersection(st_geometry(NY_filtered), st_geometry(Canada_buffered))
#Learned st_geometry() from https://github.com/r-spatial/sf/issues/406 to avoid an error

final_map <- ggplot(data = NY_filtered) + geom_sf() + 
  geom_sf(data = NY_and_Canada, fill = "red") + 
  labs(title = "New York Land within 10km") + 
  theme(plot.title = element_text(size = 20)) + 
  theme(axis.text = element_text(size = 12))
print(final_map)

border_area <- st_area(NY_and_Canada) %>%
  set_units(km^2)
print(border_area)
#Got script on how to pipe from Ting

ggsave(filename = "New York Land within 10km.png", device = "png")