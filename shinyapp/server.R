library(shiny)
library(dplyr)
library(plotly)

data <- read.csv("data/aggregated_state_data.csv", stringsAsFactors = FALSE)
data <- data %>% filter(state == "Maharashtra" | state == "Delhi" | state == "Tamil Nadu" | state == "Gujarat")

my_server <- function(input, output) {
  
  # Output a bar chart
  output$barplot <- renderPlotly({
    plot_ly(data, x=data$state, y=data$patients, type='bar', color = I("black")) %>% 
      layout(title = "Total Amount of patients that test postive in COVID-19 in India", 
               xaxis = list(title = "States in India"),
               yaxis = list(title = "Number of patients"))
  })
}