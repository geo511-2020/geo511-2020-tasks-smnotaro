---
title: "EnvStats"
author: Sandra Notaro
output: 
  revealjs::revealjs_presentation:
    theme: sky
    highlight: kate
    transition: none
    center: true
    keep_md: true
---

## Author: Steven Millard

![](Steven_Millard.jpg)

- Obtained his M.S. and Ph.D. in Biostatistics from the University of Washington
- Independent statistical consultant
- Senior biostatistician at the VA Puget Sound Health Care System in Seattle, Washington
- Wrote _EnvSats: An R Package for Environmental Statistics_ in 2013

## EnvStats

#### Provides functions for graphical and statistical analyses of environmnetal data
- Inlcudes major environmental statistical methods
- Includes built-in data sets
- __Can be used to create summary plots with ggplot2__

## EnvStats Functions to Create Plots with ggplot2
- `geom_stripchart()`: used to create a strip plot
- `stat_n_text()`: add text indicating sample size
- `stat_mean_sd_text()`: add text indicating the mean and standard deviation

## `geom_stripchart()` Example



```r
p <- ggplot(mtcars, aes(x = factor(cyl), y = mpg, color = factor(cyl))) + geom_stripchart() +
labs(x = "Number of Cylinders", y = "Miles per Gallon")
p
```

## `geom_stripchart()` Example Plotted
![](SNResourcePresentation_files/figure-revealjs/stripchart-1.png)

## `stat_n_text()` Example



```r
q <- ggplot(mtcars, aes(x = factor(cyl), y = mpg, color = factor(cyl))) +
theme(legend.position = "none") + geom_point() +
stat_n_text() +
labs(x = "Number of Cylinders", y = "Miles per Gallon")
q
```

## `stat_n_text()` Example Plotted
![](SNResourcePresentation_files/figure-revealjs/text-1.png)

## `stat_mean_sd_text()` Example



```r
r <- ggplot(mtcars, aes(x = factor(cyl), y = mpg, color = factor(cyl))) +
theme(legend.position = "none") + geom_point() +
stat_mean_sd_text() +
labs(x = "Number of Cylinders", y = "Miles per Gallon")
r
```

## `stat_mean_sd_text()` Example Plotted
![](SNResourcePresentation_files/figure-revealjs/meansd-1.png)
