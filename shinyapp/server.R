library(shiny)
library(dplyr)
library(plotly)

data <- read.csv("data/aggregated_state_data.csv", stringsAsFactors = FALSE)
data <- data %>% filter(state == "Maharashtra" | state == "Delhi" | state == "Tamil Nadu" | state == "Gujarat")

my_server <- function(input, output, session) {
  
  # Output a bar chart with number of employees in different gender
  output$state_plot <- renderPlotly({
    fig <- plot_ly(data, x = data$state, y = data$patients, type = 'bar', name = 'A')
  })
}