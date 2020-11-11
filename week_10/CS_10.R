# Preparing the data
library(raster)
library(rasterVis)
library(rgdal)
library(ggmap)
library(tidyverse)
library(knitr)
library(ncdf4)
library(stats)

dir.create("data",showWarnings = F)

lulc_url="https://github.com/adammwilson/DataScienceData/blob/master/inst/extdata/appeears/MCD12Q1.051_aid0001.nc?raw=true"
lst_url="https://github.com/adammwilson/DataScienceData/blob/master/inst/extdata/appeears/MOD11A2.006_aid0001.nc?raw=true"

download.file(lulc_url,destfile="data/MCD12Q1.051_aid0001.nc", mode="wb")
download.file(lst_url,destfile="data/MOD11A2.006_aid0001.nc", mode="wb")

# Loading the data into R
lulc = stack("data/MCD12Q1.051_aid0001.nc",varname="Land_Cover_Type_1")
lst = stack("data/MOD11A2.006_aid0001.nc",varname="LST_Day_1km")

# Plotting All of the Land Use Land Cover Data
plot(lulc)

# Plotting the Land Use Land Cover 2013 Data
lulc = lulc[[13]]
plot(lulc)

# Processing the Land Cover Data
Land_Cover_Type_1 = c(
  Water = 0, 
  `Evergreen Needleleaf forest` = 1, 
  `Evergreen Broadleaf forest` = 2,
  `Deciduous Needleleaf forest` = 3, 
  `Deciduous Broadleaf forest` = 4,
  `Mixed forest` = 5, 
  `Closed shrublands` = 6,
  `Open shrublands` = 7,
  `Woody savannas` = 8, 
  Savannas = 9,
  Grasslands = 10,
  `Permanent wetlands` = 11, 
  Croplands = 12,
  `Urban & built-up` = 13,
  `Cropland/Natural vegetation mosaic` = 14, 
  `Snow & ice` = 15,
  `Barren/Sparsely vegetated` = 16, 
  Unclassified = 254,
  NoDataFill = 255)

lcd=data.frame(
  ID=Land_Cover_Type_1,
  landcover=names(Land_Cover_Type_1),
  col=c("#000080","#008000","#00FF00", "#99CC00","#99FF99", "#339966", "#993366", "#FFCC99", "#CCFFCC", "#FFCC00", "#FF9900", "#006699", "#FFFF00", "#FF0000", "#999966", "#FFFFFF", "#808080", "#000000", "#000000"),
  stringsAsFactors = F)

kable(head(lcd))

# Converting the Land Use Land Cover Raster into a Categorical Raster
lulc = as.factor(lulc)

levels(lulc) = left_join(levels(lulc)[[1]],lcd)

# Plotting the Converted Raster
gplot(lulc)+
  geom_raster(aes(fill = as.factor(value)))+
  scale_fill_manual(values=levels(lulc)[[1]]$col,
                    labels=levels(lulc)[[1]]$landcover,
                    name="Landcover Type")+
  coord_equal()+
  theme(legend.position = "bottom")+
  guides(fill = guide_legend(ncol=1, byrow=TRUE))

# Observing Land Surface Temperature
plot(lst[[1:12]])

# Converting Land Surface Temperature from Kelvin to Celcius
offs(lst) = -273.15
plot(lst[[1:10]])

# Adding Dates to Time (z) Dimension
names(lst)[1:5]
tdates = names(lst)%>%
  sub(pattern = "X", replacement = "")%>%
  as.Date("%Y.%m.%d")

names(lst) = 1:nlayers(lst)
lst = setZ(lst,tdates)

# Extracting Timeseries for a Point
## Defining a new spatial point at that location
lw = SpatialPoints(data.frame(x = -78.791547, y = 43.007211))

##Setting the projection
projection(lw) <- "+proj=longlat"
lw_transf <- spTransform(lw, "+proj=longlat")

## Extracting and Transposing the Land Surface Temperature Data
extract_lst <- raster::extract(lst, lw, buffer = 1000, fun = mean, na.rm=T)
transpose_lst <- t(extract_lst)

## Extracting the Dates and Combining Them Into a Data Frame with Extracted LST Data
extract_dates <- getZ(lst)
combined_df <- bind_cols(transpose_lst, extract_dates)

## Plotting Land Surface Temperature
renamed_df <- combined_df %>%
  rename(date = ...2, temp = ...1)
lst_final_plot <- ggplot(renamed_df, aes(date, temp)) + geom_point() + 
  geom_smooth(span = 0.05, n = 250, se = FALSE) + 
  labs(x = "Date", y = "Monthly Mean Land Surface Temperature") + 
  theme(axis.title = element_text(size = 20))
lst_final_plot
# Learned how to use span and n from https://ggplot2.tidyverse.org/reference/geom_smooth.html


# Summarizing Weekly Data to Monthly Climatologies
tmonth <- as.numeric(format(getZ(lst),"%m"))

## Summarizing the Mean Value
lst_month <- stackApply(lst, tmonth, fun = mean)
# Tina helped with the stackApply() step

names(lst_month) = month.name

## Plotting the Map for Each Month
month_plot <- gplot(lst_month) + geom_raster(aes(fill = value)) + facet_wrap(~variable) + 
  scale_fill_gradient2(low = "red", mid = "white", 
                       high = "blue", midpoint = 15) + coord_equal() + 
  theme(axis.text = element_blank())
month_plot
# Tina sent me https://ggplot2.tidyverse.org/reference/scale_gradient.html to know how to
# color the facets

## Finding Monthly Mean
monthly_mean <- cellStats(lst_month, mean)
knitr::kable(monthly_mean, "simple")

# Summarizing Land Surface Temperature by Land Cover
resampling <- resample(lulc, lst, method = "ngb")

## Extracting Values
lcds1 = cbind.data.frame(
  values(lst_month),
  ID = values(resampling[[1]])) %>%
  na.omit()

## Gathering the Data into a Tidy Format
gathering <- gather(lcds1, key = "month", value = "value", -ID)

## Converting ID to Numeric and Month to an Ordered Factor
id_month <- gathering %>%
  mutate(ID = as.numeric(ID)) %>%
  mutate(month = factor(month, levels = month.name, ordered=T))

## Left Join
join_lcd <- left_join(id_month, lcd)

## Filtering
filtered_lcd <- join_lcd %>% 
  filter(landcover %in% c("Urban & built-up","Deciduous Broadleaf forest"))

## Illustrating the Monthly Variability in Land Surface Temperature
variability_plot <- ggplot(filtered_lcd, aes(month, value))+ facet_wrap(~landcover) +
  geom_point(alpha=.5, position = "jitter") +
  geom_smooth() +
  geom_violin(alpha = .5, col = "red", scale = "width",position = "dodge")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylab("Monthly Mean Land Surface Temperature (C)")+
  xlab("Month")+
  ggtitle("Land Surface Temperature in Urban and Forest areas in Buffalo, NY") + 
  theme(axis.title = element_text(size = 16), axis.text = element_text(size = 12), 
        plot.title = element_text(size = 20))
variability_plot

