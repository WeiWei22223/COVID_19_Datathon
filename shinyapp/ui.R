library(shiny)
library(shinythemes)
library(plotly)

#main_page <- tabPanel()

bar_plot_states <- tabPanel(
  "Bar Plot for States",
  h1("Overall count of diagnosed patients of COVID-19 in 4 states' of India", align = "center"),
  p("The plot below shows the number of diagnosed patients by states and gender."),
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