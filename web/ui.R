#' ui.R
#' Shiny UI.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("shiny")

shinyUI(fluidPage(
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
  #sidebarLayout(position = "right",
  #  sidebarPanel(
  #    sliderInput("bins",
  #                "Number of bins:",
  #                min = 1,
  #                max = 50,
  #                value = 30)
  #  ),
  #)
))
