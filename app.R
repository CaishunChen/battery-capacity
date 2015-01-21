#' app.R
#' Battery capacity Shiny application.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("shiny")
source("battery_capacity.R")

ui <- shinyUI(fluidPage(
  title = "Battery Capacity",
  plotOutput("plot"),
  hr(),
  fluidRow(
    column(3,
           selectInput("batt_type", h4("Battery Type"), list("9V", "AA"))
    ),
    column(7,
           checkboxGroupInput("batteries", h4("Batteries"), 
                              choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
                              selected = list(1,3))
    )
  )
))

server <- shinyServer(function(input, output) {
  batteries = get_batteries("9V")
  
  output$plot <- renderPlot({
    plot_mah(batteries)
  })
})

shinyApp(ui = ui, server = server)
