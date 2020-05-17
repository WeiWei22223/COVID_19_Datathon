library(shiny)
library(shinythemes)
library(leaflet)
library(plotly)

bar_plot_states <- tabPanel(
  "Total Active Cases",
  h1("Active cases in India at state and distrcit level", align = "center"),
  h2("State-level data visualization"),
  p("Slide range below to see the number of states in India that have total active cases within the range."),
  splitLayout(cellWidths = c("50%","50%"),
              sliderInput("total_count2", label = h3("Range of total active cases"), min = 0,
                          max = 21468, value = c(0, 100)),
              verbatimTextOutput("range2")
  ),
  p("Plots below shows the active cases by states."),
  splitLayout(cellWidths = c("50%","50%"),
              plotlyOutput("barplot"),
              leafletOutput("state_map")),
  p("Slide range below to see the number of districts in India that have total active cases within the range."),
  
  h2("District-level data visualization"),
  splitLayout(cellWidths = c("50%","50%"),
              sliderInput("total_count", label = h3("Range of total active cases"), min = 0,
                          max = 13891, value = c(0, 100)),
              verbatimTextOutput("range")
  ),
  p("The plot below shows the active cases by districts."),
  plotlyOutput("district_bar")
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
  includeCSS("www/style.css"),
  navbarPage(
    "COVID-19 IN INDIA", 
    growth_rate_country,
    bar_plot_states,
    trace_plot_districts
  )
)