#' app.R
#' Battery capacity Shiny application.
#' 
#' @author Nathan Campos <nathanpc@dreamintech.net>

library("shiny")
source("battery_capacity.R")

battery_list <- function (type) {
  csv = read.csv(paste(datadir, type, "index.csv", sep = "/"))
  names = list()
  files = list()
  
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
      
      names[[length(names) + 1]] = sprintf("%s%s %sV%s @ %smA", battery$brand, model, battery$voltage, capacity, battery$current)
      files[[length(files) + 1]] = paste(datadir, type, battery$file, sep = "/")
    }
  }
  
  return(list(names = names, files = files, selected = list(1:length(names))))
}



ui <- shinyUI(fluidPage(
  title = "Battery Capacity",
  plotOutput("plot"),
  hr(),
  fluidRow(
    column(3,
           selectInput("batt_type", h4("Battery Type"), as.list(list.dirs("data", recursive = FALSE, full.names = FALSE)))
    ),
    column(7,
           checkboxGroupInput("batteries", h4("Batteries"), choices = list("Nothing"))
    )
  )
))

server <- shinyServer(function(input, output, session) {
  observe({
    batt_list = battery_list(input$batt_type)
    batteries = get_batteries(input$batt_type)

    updateCheckboxGroupInput(session, "batteries",
                             choices = batt_list[["names"]],
                             selected = batt_list$names[unlist(batt_list[["selected"]])])
    
    output$plot <- renderPlot({
      plot_mah(batteries)
    })
  })
})

shinyApp(ui = ui, server = server)
