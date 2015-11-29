# Battery Capacity

Just logging battery capacity.

## Setup

If you want to play around with the R scripts and the web server to look at the data, first you need to build the cache to make the plotting process a lot more efficient.

```r
source("manager.R")
build_cache()
```

After building the cache you can plot the data like this:

```r
source("manager.R")

# Automagic way.
plot_battery("9V")

# If you want you can do it manually (and maybe without using the cache)
batteries <- get_batteries("9V", cached = FALSE)
plot_mah(batteries)
```

If you want to run the [Shiny](http://shiny.rstudio.com/) web server to get a bit more interactive with the data:

```r
library("shiny")
runApp(".")
```

If you want a much faster alternative you can build the C program by running `make` and then just executing the program with `./battery_capacity <type>`.

## 9V

![9V Discharge](https://raw.githubusercontent.com/nathanpc/battery-capacity/master/exports/9V-Capacity.jpeg)

## AA

![AA Discharge](https://raw.githubusercontent.com/nathanpc/battery-capacity/master/exports/AA-Capacity.jpeg)

## AAA

![AAA Discharge](https://raw.githubusercontent.com/nathanpc/battery-capacity/master/exports/AAA-Capacity.jpeg)

