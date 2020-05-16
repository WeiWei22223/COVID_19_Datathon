library(shiny)
library(dplyr)
library(plotly)

data <- read.csv("data/aggregated_state_data.csv", stringsAsFactors = FALSE)
data <- data %>% filter(state == "Maharashtra" | state == "Delhi" | state == "Tamil Nadu" | state == "Gujarat")

my_server <- function(input, output) {
  
  # Output a bar chart with number of employees in different gender
  output$barplot <- renderPlot({
    p <- ggplot(data, aes(x=data$state, y=data$patients)) + geom_bar(stat="identity")
    p
  })
}