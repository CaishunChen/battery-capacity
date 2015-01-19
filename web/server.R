#' server.R
#' Shiny server.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("ggplot2")
library("scales")
library("shiny")
setwd("~/Developer/Statistics/Battery-Capacity/data")

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
                                                     paste(type, battery$file, sep = "/"),
                                                     battery$current,
                                                     battery$cutoff)
    }
  }
  
  return(batts)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  
  output$distPlot <- renderPlot({
    #x    <- faithful[, 2]  # Old Faithful Geyser data
    #bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    batteries <- get_batteries("9V")
    plot_mah(batteries)
  })
})
