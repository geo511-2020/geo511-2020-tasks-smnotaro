library(raster)
library(sp)
library(spData)
library(tidyverse)
library(sf)

data(world)

library(ncdf4)
download.file("https://crudata.uea.ac.uk/cru/data/temperature/absolute.nc","crudata.nc")
tmean=raster("crudata.nc")

#view(world) to view the world dataset

#Removing Antarctica 
no_Antarc <- world %>%
  filter(continent != "Antarctica")
#view(no_Antarc) to view filtered out Antarctica

#Converting sf to sp
no_Antarc_sp <- as(no_Antarc, Class = "Spatial")

#Getting access to WorldClim max temperatures dataset
tmax_monthly <- getData(name = "worldclim", var="tmax", res=10)
#view(tmax_monthly) to view dataset
#plot(tmax_monthly) to view plot of dataset

#Converting to Celsius
gain(tmax_monthly) <- 0.1
#plot(tmax_monthly) to view plot in Celsius
#Learned how to convert to Celsius from https://cmerow.github.io/RDataScience/05_Raster.html

#Changing the default name "layer" to "tmax"
tmax_annual <- max(tmax_monthly)
names(tmax_annual) <- "tmax"

#Finding the max temp observed in each country
max_temp_country <- raster::extract(tmax_annual, no_Antarc_sp, fun = max, 
                                    na.rm = T, small = T, sp = T)
max_temp_country_sf <- st_as_sf(max_temp_country)

final_map <- ggplot(max_temp_country_sf) + geom_sf(aes(fill = tmax)) + 
  scale_fill_viridis_c(name = "Annual\nMaximum\nTemperature (C)") +
  theme(legend.position = 'bottom', axis.text = element_text(size = 14), 
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 16))
print(final_map)
ggsave(filename = "Annual Max Temp.png", device = "png")

#Finding hottest cpuntry in each continent
max_temp_country_sf %>%
  group_by(continent) %>%
  top_n(1, tmax) %>%
  select(name_long, continent, tmax) %>%
  arrange(desc(tmax)) %>%
  st_set_geometry(NULL)
#Got a hint how to use top_n() properly from Ting. All I needed was the number 1, I
#originally thought I had to write 7. I then realized I should use tmax as the wt spot
