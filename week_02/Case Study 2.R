library(tidyverse)
dataurl="https://raw.githubusercontent.com/AdamWilsonLab/GEO511/master/CS_02.csv"
temp = read_csv(dataurl,
                skip=1, 
                na="999.90",
                col_names = c("YEAR","JAN","FEB","MAR", 
                              "APR","MAY","JUN","JUL",  
                              "AUG","SEP","OCT","NOV",  
                              "DEC","DJF","MAM","JJA",  
                              "SON","metANN"))
#Exploring the data set with the following:
#View(temp)
#summary(temp)
#glimpse(temp)

library(ggplot2)
mean_JJA <- ggplot(temp, aes(YEAR, JJA))
final_JJA <- mean_JJA + geom_line() + geom_smooth(color = "red") +
  ggtitle("Mean Summer Temperatures in Buffalo, NY") +
  labs(subtitle = "Summer includes June, July, and August
          Data from the Global Historcial Climate Network
          Red line is a LOESS smooth") + 
  theme(plot.title = element_text(size = 12, face = "bold")) + 
  xlab("Year") + ylab("Mean Summer Temperatures (C)")
print(final_JJA)
png("Case Study2.png")
final_JJA
dev.off()

#Used geom_line() with the help from Adam
#Got directions for changing plot title font size and bold font from https://stackoverflow.com/questions/35458230/how-to-increase-the-font-size-of-ggtitle-in-ggplot2
