#' battery_capacity.R
#' Plots and analyzes battery capacity.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("ggplot2")
library("scales")
setwd("~/Developer/Statistics/data/Battery-Capacity/data")
rm(list = ls(all = TRUE))  # Clear the workspace.

# Get the battery discharge data from the CSV file.
battery_discharge <- function (name, csvfile, current, cutoff) {
  csv = read.csv(csvfile, header = FALSE)
  volts = csv[[3]]
  mah = c()

  for (i in 0:(length(volts) - 1)) {
    mah = c(mah, current * (i / 3600))
    
    if (i > 0 && volts[i] < cutoff) {
      length(volts) <- i + 1
      break;
    }
  }
  
  return(data.frame(voltage = volts, mah = mah, name = name))
}

# Plotting.
plot_mah <- function (batts) {
  graph = ggplot()
  graph = graph + scale_colour_brewer(palette="Set1")
  graph = graph + theme(legend.title = element_blank(),
                        legend.justification = c(1, 1),
                        legend.position = c(1, 1))

  for (i in 1:length(batteries)) {
    graph = graph + geom_line(data = batts[[i]],
                              aes(x = mah, y = voltage, color = name))
  }

  # Setup labels and etc.
  graph = graph + scale_x_continuous("Capacity (mAh)",
                                     breaks = pretty_breaks(n = 10))
  graph = graph + scale_y_continuous("Voltage (V)",
                                     breaks = pretty_breaks(n = 10))
  #graph = graph + ggtitle("AA Battery Discharge at 200mA")
  
  print(graph)
}

# Get batteries by type.
get_batteries <- function (type) {
  csv = read.csv(paste(type, "index.csv", sep = "/"))
  batts = list()
  
  for (i in 1:nrow(csv)) {
    battery = csv[i,]
    
    if (battery$show == 1) {
      model = battery$model
      capacity = battery$exp_capacity
      
      if (model != "") {
        model = paste0(" ", model)
      }
      
      if (!is.na(capacity)) {
        capacity = sprintf(" %smAh", capacity)
      } else {
        capacity = ""
      }
      
      name = sprintf("%s%s %sV%s", battery$brand, model, battery$voltage, capacity)
      batts[[length(batts) + 1]] = battery_discharge(name,
                                                     paste(type, battery$file, sep = "/"),
                                                     battery$current,
                                                     battery$cutoff)
    }
  }
  
  return(batts)
}

batteries <- get_batteries("9V")
plot_mah(batteries)
