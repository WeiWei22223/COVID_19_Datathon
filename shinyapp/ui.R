library(shiny)
library(shinythemes)
library(leaflet)
library(plotly)

bar_plot_states <- tabPanel(
  "States Data",
  h1("Overall count of diagnosed patients in India", align = "center"),
  p("The plot below shows the number of diagnosed patients by states and gender."),
  # leafletOutput("state_map")
  fluidRow(
    splitLayout(cellWidths = c("50%", "50%"), plotlyOutput("barplot"),
                leafletOutput("state_map"))
  )
)

trace_plot_districts <- tabPanel(
  "Trace Plot for States and Districts",
  fluidRow(
    splitLayout(cellWidths = c("50%","50%"),
      h2("Trace Plot for selected Districts", align = "center"),
      h2("Trace Plot for selected States", align = "center")
    )
  ),
  fluidRow(
    splitLayout(cellWidths = c("50%","50%"),
      plotlyOutput("tracestates"),
      plotlyOutput("tracedistricts")
    )
  )
)

growth_rate_country <- tabPanel(
  "Growth Rate across Country",
  h1("Total growth across country", align = "center"),
  plotlyOutput("aggtraceplot", width = "100%"),
  h1("Total vs Net growth across country", align = "center"),
  splitLayout(cellWidths = c("33%", "33%", "33%"),
              plotlyOutput("aggactiveplot"),
              plotlyOutput("aggrecoveredplot"),
              plotlyOutput("aggdeceasedplot")
  )
)

my_ui <- fluidPage(
  theme = shinythemes::shinytheme("slate"),
  HTML('<center><h1>COVID-19 IN INDIA</h1></center>'),
  navbarPage(
    "COVID-19 IN INDIA", 
    growth_rate_country,
    bar_plot_states,
    trace_plot_districts
  )
)