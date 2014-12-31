#' battery_capacity.R
#' Plots and analyzes battery capacity.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("ggplot2")
setwd("~/Developer/Statistics/data/Battery-Capacity/")


###
###
### FUCK THIS SHIT. ggplot2 is fucking horrible.
###
###


parse_csv <- function (csvfile, current) {
  csv = read.csv(csvfile, header = FALSE)
  volts = unlist(csv[3])
  mah = c()

  for (i in 0:(length(volts) - 1)) {
    mah = c(mah, current * (i / 3600))
    
    if (i > 0 && volts[i] < 0.8) {
      length(volts) <- i + 1
      break;
    }
  }
  
  return(data.frame(voltage = volts, mah = mah))
}

batteries = c(parse_csv("MOX-AA-3600mAh-Discharge.log", 200))

# Plotting.
#plot_mah <- function (vlist) {
  graph = ggplot()

  for (i in 1:length(batteries)) {
    graph = graph + geom_line(aes(x = mah, y = voltage), batteries[i])
  }

  # Setup labels and etc.
  graph = graph + scale_x_continuous("Capacity (mAh)")
  graph = graph + scale_y_continuous("Voltage (V)")
  graph = graph + ggtitle("AA Battery Discharge at 200mA")
  
  graph
#}
