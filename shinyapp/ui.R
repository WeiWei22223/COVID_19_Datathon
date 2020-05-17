library(shiny)
library(shinythemes)
library(leaflet)
library(plotly)

bar_plot_states <- tabPanel(
  "Total Active Cases",
  h1("Active cases in India at state and distrcit level", align = "center"),
  p("Slide range below to see the number of states in India that have total active cases within the range."),
  sliderInput("total_count2", label = h3("Range of total active cases"), min = 0,
              max = 21468, value = c(0, 100)),
  verbatimTextOutput("range2"),
  p("The plot below shows the active cases by states."),
  plotlyOutput("barplot"),
  leafletOutput("state_map"),
  p("Slide range below to see the number of districts in India that have total active cases within the range."),
  sliderInput("total_count", label = h3("Range of total active cases"), min = 0,
              max = 13891, value = c(0, 100)),
  verbatimTextOutput("range"),
  p("The plot below shows the active cases by districts."),
  plotlyOutput("district_bar")
)

trace_plot_districts <- tabPanel(
  "Line Chart for States and Districts",
  fluidRow(
    splitLayout(cellWidths = c("50%","50%"),
      h2("Line Chart for selected Districts", align = "center"),
      h2("Line Chart for selected States", align = "center")
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

home_page <- tabPanel(
  "HOME",
  h1("COVID-19 IN INDIA", align = "center"),
  h4("Wei Fan, Qiaoxue Liu", align = "center"),
  h5("(Please allow a few minutes for the plots and maps to fully load!)", align = "center"),
  h2("Background"),
  p("In December, 2019, “coronavirus disease 2019” (abbreviated “COVID-19”) are detected from people working at Wuhan South China Seafood Wholesale Market. 
    Later, a growing number of patients reported they were not exposed to animal markets, indicating person-to-person spread. 
    Unfortunately, it was the lunar new year and a huge amount of people returned to their hometown from Wuhan during spring break, which allows the outbreak to spread to other provinces rapidly. 
    On January 30, 2020, the International Health Regulations Emergency Committee of the World Health Organization declared the outbreak as a “public health emergency of international concern”(PHEIC), which increases the general fear among the public. 
    Luckily, so far, China, as the most populous country in the world, has effectively controlled the spread of the virus with the lead of the authority. 
    However, the virus keeps spreading to other countries through international travelling and trade. 
    India, which is the second-most populous country in the world, is now facing the COVID-19 challenge.", br()),
  
  h2("Description"),
  p("In this project, we use the data, which includes recorded COVID-19 cases from 36 states and territories and 782 districts and sub-divisions in India, to show the current spread of the disease in India."),
  p("The project includes three parts: "),
  HTML("<ul>
          <li>Growth Rate across Country: Includes line charts that show the trend of both total and net amount for confirmed, active, recovered, and deceased cases.</li>
          <li>Total Active Cases: Includes two kinds of plots: bar plots and a map. The bar plots show the total active cases by May 17th, 2020 for both state and district; the map visually presents the spread of COVID-19 across states.</li>
          <li>Line Chart for States and Districts: Includes line charts showing the change of active cases for COVID-19 from April 21st, 2020 to May 15th, 2020 for selected districts. </li>
       </ul>"),
  
  h2("Data Source"),
  HTML("<p>Thanks for DubsTech, who provides the reliable <a href='https://github.com/zcolah/COVID_19_Datathon'>data set</a> for this project.</p>")
)

my_ui <- fluidPage(
  theme = shinythemes::shinytheme("slate"),
  includeCSS("www/style.css"),
  navbarPage(
    "COVID-19 IN INDIA", 
    home_page,
    growth_rate_country,
    bar_plot_states,
    trace_plot_districts
  )
)