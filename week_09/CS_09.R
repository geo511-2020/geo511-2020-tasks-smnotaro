library(sf)
library(tidyverse)
library(ggmap)
library(rnoaa)
library(spData)
data(world)
data(us_states)
library(dplyr)

dataurl="https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/shapefile/IBTrACS.NA.list.v04r00.points.zip"
tdir=tempdir()
download.file(dataurl,destfile=file.path(tdir,"temp.zip"))
unzip(file.path(tdir,"temp.zip"),exdir = tdir)
list.files(tdir)
storm_data <- read_sf(list.files(tdir,pattern=".shp",full.names = T))

# Filtering for years 1950s to present
filtered_1950_present <- storm_data %>%
  filter(SEASON >= 1950) %>%
  mutate_if(is.numeric, function(x) ifelse(x==-999.0,NA,x)) %>%
  mutate(decade=(floor(year/10)*10))
  
region <- st_bbox(filtered_1950_present)

# Plotting maps
storm_plots <- ggplot(world) + geom_sf() + facet_wrap(~decade) +
  stat_bin2d(data = filtered_1950_present, aes(y = st_coordinates(filtered_1950_present)[,2], 
                              x = st_coordinates(filtered_1950_present)[,1]), bins = 100) +
  scale_fill_distiller(palette = "YlOrRd", trans = "log", direction = -1, 
                       breaks = c(1,10,100,1000)) + coord_sf(ylim=region[c(2,4)], 
                                                             xlim=region[c(1,3)]) +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())
print(storm_plots)

# Reprojecting us_states to the reference system of filtered_1950_present and
#renaming NAME column to state
state <- us_states %>%
  st_transform(crs = st_crs(filtered_1950_present)) %>%
  select(state = NAME)

# Spatial join between storm database and states object
storm_states <- st_join(filtered_1950_present, state, join = st_intersects,left = F)

# Making the table
table <- storm_states %>%
  group_by(state) %>%
  summarize(filtered_1950_present =length(unique(NAME))) %>%
  arrange(desc(filtered_1950_present)) %>%
  slice(1:5) %>%
  st_set_geometry(NULL)
knitr::kable(table, "simple")



