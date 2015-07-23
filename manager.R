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
  cat("Building cache for the following battery types: ")
  cat(types)
  cat("\n")
  
  for (i in 1:length(types)) {
    cat(sprintf("Type: %s\n", types[i]))
    batteries = get_batteries(types[i], FALSE)
    
    for (j in 1:length(batteries)) {
      cat(sprintf("Simplifying the dataset for %s\n", as.character(batteries[[j]][["name"]][1])))
      batteries[[j]] = simplify_data(batteries[[j]], max_points)
    }

    filename = paste0(cachedir, "/", types[i], ".rds")
    cat(sprintf("Saving cache to %s\n", filename))
    saveRDS(batteries, filename)
  }
  
  cat("Finished building the cache.\n")
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
plot_battery <- function (type) {
  batteries = get_batteries(type)
  plot_mah(batteries)
}

#' Adds a battery to the index.
#' 
#' @param type Battery type.
#' @param brand Battery brand.
#' @param model Battery model.
#' @param voltage Nominal voltage.
#' @param exp_capacity Expected capacity.
#' @param current Discharge current.
#' @param chemistry Battery chemistry.
#' @param cutoff Voltage cutoff.
#' @param file File where the logged data is stored.
#' @param comment Any comments about the battery.
add_battery <- function (type, brand = "", model = "", voltage = "",
                         exp_capacity = "", current = "", chemistry = "",
                         cutoff = "", file = "", comment = "") {
  # TODO: Check if the directory exists.
  if (brand == "") {
    # Interactive mode.
    brand = readline("Brand: ")
    model = readline("Model: ")
    voltage = readline("Nominal Voltage (V): ")
    exp_capacity = readline("Expected Capacity (mAh): ")
    current = readline("Discharge Current (mA): ")
    chemistry = readline("Chemistry: ")
    cutoff = readline("Voltage Cutoff (V): ")
    
    sample_file = ""
    if (model != "")
      sample_file = gsub(" ", "", sprintf("-%s", model))
    sample_file = sprintf("%s%s-%sV-%smAh.csv", brand, sample_file, voltage, exp_capacity)
    
    file = readline(sprintf("File (%s): ", sample_file))
    if (file == "") {
      file = sample_file
    }
    
    comment = readline("Comment: ")
  }
  
  line = sprintf("1,%s,%s,%s,%s,%s,%s,%s,%s,%s,", brand, model, voltage, exp_capacity, current, chemistry, cutoff, file, comment)
  print(line)
  # TODO: Append to file.
  # TODO: Add option to build cache.
}
