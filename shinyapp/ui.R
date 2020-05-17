library(shiny)
library(shinythemes)
library(plotly)

#main_page <- tabPanel()

bar_plot_states <- tabPanel(
  "States Data",
  h1("Overall count of diagnosed patients in India", align = "center"),
  p("The plot below shows the number of diagnosed patients by states and gender."),
  fluidRow(
    splitLayout(cellWidths = c("50%", "50%"), plotlyOutput("barplot"), 
                leafletOutput("state_map"))
  )
)

trace_plot_districts <- tabPanel(
  "Trace Plot for Districts",
  plotlyOutput("tracedistricts")
)

my_ui <- fluidPage(
  theme = shinythemes::shinytheme("readable"),
  HTML('<center><h1>COVID-19 IN INDIA</h1></center>'),
  #headerPanel("Data Visulization"),
  #sidebarPanel(),
  navbarPage(
    "COVID-19 IN INDIA", 
    bar_plot_states,
    trace_plot_districts
    #diversity_map              
  )
)