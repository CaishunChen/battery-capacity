#' server.R
#' Shiny server.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("shiny")
source("../battery_capacity.R")
setwd("../")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  batteries = get_batteries("9V")

  output$plot <- renderPlot({
    #x    <- faithful[, 2]  # Old Faithful Geyser data
    #bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    plot_mah(batteries)
  })
})
