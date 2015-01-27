#' manager.R
#' Manages everything.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

source("battery_capacity.R")

#' Builds the cache to speed things up.
#' 
#' @param max_points Maximum number of points to be used to simplify the dataset.
build_cache <- function (max_points = 200) {
  types = list.dirs(datadir, recursive = FALSE, full.names = FALSE)
  for (i in 1:length(types)) {
    batteries = get_batteries(types[i], FALSE)
    
    for (j in 1:length(batteries)) {
      batteries[[j]] = simplify_data(batteries[[j]], max_points)
    }

    saveRDS(batteries, paste0(cachedir, "/", types[i], ".rds"))
  }
}

#' Simplifies a dataset to make it easier for ggplot2 to plot the data.
#' 
#' @param battery The data frame from `battery_discharge`.
#' @param max_points Maximum number of points for the final dataset.
#' @return A simplified version of the battery dataset.
#' @seealso battery_discharge
simplify_data <- function (battery, max_points = 200) {
  steps = nrow(battery) / max_points
  mah = c()
  volts = c()
  
  # Record the starting voltage.
  mah = c(mah, battery[["mah"]][1])
  volts = c(volts, battery[["voltage"]][1])
  
  for (i in 1:max_points) {
    mah = c(mah, battery[["mah"]][i * steps])
    volts = c(volts, battery[["voltage"]][i * steps])
  }
  
  return(data.frame(voltage = volts, mah = mah, name = battery[["name"]][1]))
}

#' Plots the batteries.
#' 
#' @param type Type of battery to plot.
plot_battery <- (type) {
  batteries = get_batteries(type)
  plot_mah(batteries)
}
