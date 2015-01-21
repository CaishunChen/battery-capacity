#' battery_capacity.R
#' Plots and analyzes battery capacity.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("ggplot2")
library("scales")
rm(list = ls(all = TRUE))  # Clear the workspace.
datadir <- "data"

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

  for (i in 1:length(batts)) {
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
  csv = read.csv(paste(datadir, type, "index.csv", sep = "/"))
  batts = list()
  
  for (i in 1:nrow(csv)) {
    battery = csv[i,]
    
    if (battery$show == 1) {
      model = battery$model
      capacity = battery$exp_capacity
      
      if (!is.na(model)) {
        if (model != "") {
          model = paste0(" ", model)
        }
      }
      
      if (!is.na(capacity)) {
        capacity = sprintf(" %smAh", capacity)
      } else {
        capacity = ""
      }
      
      name = sprintf("%s%s %sV%s @ %smA", battery$brand, model, battery$voltage, capacity, battery$current)
      batts[[length(batts) + 1]] = battery_discharge(name,
                                                     paste(datadir, type, battery$file, sep = "/"),
                                                     battery$current,
                                                     battery$cutoff)
    }
  }
  
  return(batts)
}
