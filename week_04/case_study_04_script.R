library(tidyverse)
library(nycflights13)

#Viewing tables
#view(airports)
#view(planes)
#view(weather)
#view(flights)
#view(airlines)

#Looking at only origin, dest, and distance in flights
flights_minimal <- flights %>%
  select(origin, dest, distance)

#Looking at farthest distance from JFK
far_distance <- flights_minimal %>%
  group_by(distance) %>%
  arrange(desc(distance))
view(far_distance)  

#Joining the tables
join_dest <- inner_join(far_distance, airports, by = c("dest"="faa"))
focus_far <- join_dest[[1,4]]
print(focus_far)

#Got inner join to work with help from Bhavana
#Got help to to choose what column and row to look at with help from Tina