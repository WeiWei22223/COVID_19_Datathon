library(shiny)
library(shinythemes)
library(plotly)

#main_page <- tabPanel()

bar_plot_states <- tabPanel(
  "Bar Plot for States",
  h1("Bar Plot", align = "center"),
  plotlyOutput("barplot")
)

my_ui <- fluidPage(
  theme = shinythemes::shinytheme("readable"),
  HTML('<center><h1>COVID-19 IN INDIA</h1></center>'),
  headerPanel("Data Visulization"),
  #sidebarPanel(),
  navbarPage(
    "COVID-19 IN INDIA", 
    bar_plot_states
    #diversity_map              
  )
)