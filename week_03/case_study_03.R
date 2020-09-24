library(ggplot2)
library(gapminder) 
library(dplyr)

#First plot
gap_no_Kuwait <- gapminder %>%
  filter(country != "Kuwait")

plot_lifeExp <- ggplot(gap_no_Kuwait, aes(lifeExp, gdpPercap, color = continent, size = pop/100000)) +
  geom_point() + facet_wrap(~year, nrow = 1) +
  scale_y_continuous(trans = "sqrt") + theme_bw() + 
  theme(plot.title = element_text(size = 24)) +
  labs(title = "Wealth and life expectancy through time", x = "Life Expectancy", 
       y = "GDP per capita", size = "Population (100k)", color = "Continent")
ggsave(filename = "Life_Exp_Week_3", device = "png", width = 15, units = c("in"))
print(plot_lifeExp)

#Learned code on how to change legend titles for specific legens from https://cmdlinetips.com/2019/10/how-to-change-legend-title-in-ggplot2/


#Second plot
gapminder_continent <- gap_no_Kuwait %>%
  group_by(continent, year) %>%
  summarize(gdpPercapweighted = weighted.mean(x = gdpPercap, w = pop), 
            pop = sum(as.numeric(pop)))

plot_continents <- ggplot(gap_no_Kuwait, aes(year, gdpPercap, color = continent)) + 
  geom_line(aes(group = country)) + 
  geom_point(aes(size = pop/100000, group = country)) + 
  geom_line(data = gapminder_continent, color = "black", aes(year, gdpPercapweighted)) + 
  geom_point(data = gapminder_continent, color = "black", aes(year, gdpPercapweighted, 
                                                              size = pop/100000)) +
  facet_wrap(~continent, nrow = 1) + theme_bw() + labs(x = "Year", y = "GDP per capita", 
                                                       size = "Population (100k)")
ggsave(filename = "Continents_Week_3", device = "png", width = 15, units = c("in"))
print(plot_continents)

#Got help with plotting the black lines from Tina