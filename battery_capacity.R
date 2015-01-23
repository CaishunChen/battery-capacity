#' battery_capacity.R
#' Plots and analyzes battery capacity.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("ggplot2")
library("scales")
rm(list = ls(all = TRUE))  # Clear the workspace.
datadir <- "data"

#' Get the battery discharge data from the log file.
#' 
#' @param name Battery name to be displayed on the legend.
#' @param file Log file location.
#' @param current Discharge current.
#' @param cutoff Voltage cutoff point to ignore when plotting.
#' @return A data frame with the battery data.
battery_discharge <- function (name, file, current, cutoff) {
  csv = read.csv(file, header = FALSE)
  volts = csv[[3]]
  mah = c()

  # Calculate the capacity and voltage at a point.
  for (i in 0:(length(volts) - 1)) {
    mah = c(mah, current * (i / 3600))
    
    # Stop appending data to the list when the cutoff point has been reached.
    if (i > 0 && volts[i] < cutoff) {
      length(volts) <- i + 1
      break;
    }
  }
  
  return(data.frame(voltage = volts, mah = mah, name = name))
}

#' Get batteries data by type.
#' 
#' @param type Battery type.
#' @return A list with the data frames from `battery_discharge`
#' @seealso battery_discharge
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
      
      # Create the name string and append the data to it.
      name = sprintf("%s%s %sV%s @ %smA", battery$brand, model, battery$voltage, capacity, battery$current)
      batts[[length(batts) + 1]] = battery_discharge(name,
                                                     paste(datadir, type, battery$file, sep = "/"),
                                                     battery$current,
                                                     battery$cutoff)
    }
  }
  
  return(batts)
}

#' Plots the capacity of the batteries.
#' 
#' @param batts Battery data from `get_batteries`
#' @seealso get_batteries
plot_mah <- function (batts, show) {
  graph = ggplot()
  graph = graph + scale_colour_brewer(palette="Set1")
  graph = graph + theme(legend.title = element_blank(),
                        legend.justification = c(1, 1),
                        legend.position = c(1, 1))
  
  # Add the lines for each battery.
  for (i in 1:length(batts)) {
    for (j in 1:length(show)) {
      if (i == show[j]) {
        graph = graph + geom_line(data = batts[[i]],
                                  aes(x = mah, y = voltage, color = name))
      }
    }
  }

  # Setup labels and etc.
  graph = graph + scale_x_continuous("Capacity (mAh)",
                                     breaks = pretty_breaks(n = 15))
  graph = graph + scale_y_continuous("Voltage (V)",
                                     breaks = pretty_breaks(n = 15))
  
  # Plot the data.
  print(graph)
}
