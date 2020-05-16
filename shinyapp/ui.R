library(shiny)
library(shinythemes)
library(plotly)

my_ui <- fluidPage(
  theme = shinythemes::shinytheme("readable"),

  headerPanel("Data Visulization"),
  
  sidebarPanel(),
  
  mainPanel(
    h1("Bar Plot", align = "center"),
    plotOutput("barplot")
  )
)