library(sf)
library(shiny)
library(dplyr)
library(plotly)
library(leaflet)
library(geojsonsf)
library(jsonlite)

# Patient's data from all the state of India
all_data <- read.csv("data/aggregated_state_data.csv", stringsAsFactors = FALSE)
all_data <- all_data[order(all_data$state), ]

# Patient's data from 4 specific states
data <- all_data %>% filter(state == "Maharashtra" | state == "Delhi" | state == "Tamil Nadu" | state == "Gujarat")

# Read in the Inidan state map file 
backup <- rgdal::readOGR("data/india_states.geojson")

# Combine map data with patient's data
backup@data$patients <- 0
for (i in 1:nrow(all_data)) {
  state_name <- all_data$state[i]
  backup@data$patients[i] <- all_data$patients[i]
}

# Create a color palette for the map:
mypalette <- colorNumeric( palette="viridis", domain=backup@data$patients, 
                           na.color="transparent")
mypalette(c(45,43))


####### Block for trace plot for districts #######
districts_data = read.csv("data/districts_daily_may_15.csv")
Mumbai <- districts_data %>% filter(district == "Mumbai")
Chennai <- districts_data %>% filter(district == "Chennai")
Ahmadabad <- districts_data %>% filter(district == "Ahmadabad")
Delhi <- districts_data %>% filter(State == "Delhi")

date_list = Delhi$date
num_date_list = length(levels(districts_data$date))
num_date_ahm = length(Ahmadabad$date)
agg_active = numeric(num_date_list)
ahm_active = numeric(num_date_list)
# date_list[1]
for (k in 1:num_date_list) {
  spec_day = Delhi %>% filter(date == date_list[k])
  agg_active[k] <- sum(spec_day$active)
  
  if (k > num_date_ahm) {
    ahm_active[k] = NA
  } else {
    spec_ahm = Ahmadabad %>% filter(date == date_list[k])
    ahm_active[k] = spec_ahm$active
  }
}
##############

my_server <- function(input, output) {
  
  # Output a bar chart for state information
  output$barplot <- renderPlotly({
    plot_ly(data, x=data$state, y=data$male, type='bar', name = 'male patients', 
            text = paste0(data$state, " has ", data$patients, " patients diagnosed COVID-19."),
            color = I("light blue")) %>% 
      add_trace(y = data$female, name = 'female patients', color = I("pink")) %>% 
      add_trace(y = (data$patients - data$female - data$male), name ='Unknown gender', 
                color = I("gray")) %>% 
      layout(title = "Total Amount of patients that test postive in COVID-19 in India", 
               xaxis = list(title = "States in India"),
               yaxis = list(title = "Number of patients"),
               barmode = "stack")
  })
  
  output$state_map <- renderLeaflet({
    leaflet(data = backup) %>%
      setView(lng = 79, lat = 21, zoom = 4.4) %>% 
      addPolygons(label = backup@data$NAME_1,
                  fillColor = ~mypalette(patients), stroke=FALSE,
                  color = "#444444",
                  weight = 1,
                  smoothFactor = 0.5,
                  opacity = 1.0,
                  fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white",
                                                      weight = 2,
                                                      bringToFront = TRUE))
  })
  
  output$tracedistricts <- renderPlotly({
    trace_graph = plot_ly(Mumbai, x=~date, y=~active, type = 'scatter', mode = 'lines+markers', name = 'Mumbai') #%>%
    trace_graph <- trace_graph %>% add_trace(y = Chennai$active, name = "Chennai")
    trace_graph <- trace_graph %>% add_trace(y = ahm_active)
    trace_graph <- trace_graph %>% add_trace(y = agg_active, name = "Delhi")
    trace_graph <- trace_graph %>% layout(title = "Active Cases vs Date (2020-04-21 to 2020-05-16)", 
                                          xaxis = list(title = "Active Cases"),
                                          yaxis = list(title = "Date"))
    
  })
  
  
  
}