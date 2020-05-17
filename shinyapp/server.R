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

############# Block for trace plot for districts #######
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
############## growth rate across country ############
agg_country_active <- numeric(num_date_list)
agg_country_confirmed <- numeric(num_date_list)
agg_country_recovered <- numeric(num_date_list)
agg_country_deceased <- numeric(num_date_list)
agg_country_net_active <- numeric(num_date_list)
agg_country_net_recovered <- numeric(num_date_list)
agg_country_net_deceased <- numeric(num_date_list)
for (k in 1:num_date_list) {
  cur_day = districts_data %>% filter(date == date_list[k])
  agg_country_confirmed[k] = sum(cur_day$confirmed)
  agg_country_active[k] = sum(cur_day$active)
  agg_country_recovered[k] = sum(cur_day$recovered)
  agg_country_deceased[k] = sum(cur_day$deceased)
  if (k == 1) {
    agg_country_net_active[k] = NA
  } else {
    agg_country_net_active[k] = agg_country_active[k] - agg_country_active[k-1]
  }
  if (k == 1) {
    agg_country_net_recovered[k] = NA
  } else {
    agg_country_net_recovered[k] = agg_country_recovered[k] - agg_country_recovered[k-1]
  }
  if (k == 1) {
    agg_country_net_deceased[k] = NA
  } else {
    agg_country_net_deceased[k] = agg_country_deceased[k] - agg_country_deceased[k-1]
  }
}

avg_active_net = mean(agg_country_net_active[2:26]/agg_country_active[1:25])
avg_recovered_net = mean(agg_country_net_recovered[2:26]/agg_country_recovered[1:25])
avg_deceased_net = mean(agg_country_net_deceased[2:26]/agg_country_deceased[1:25])
##################
################## cases for states and district across time ############
agg_area <- function(area,target, s_or_d) {
  area_list = levels(area)
  num_area = length(area_list)
  
  mtx = data.frame(matrix(ncol = num_area, nrow = num_date_list))
  row.names(mtx) = as.vector(levels(date_list))
  colnames(mtx) = area_list
  
  for (k in 1:num_date_list) {
    cur_day = districts_data %>% filter(date == date_list[k])
    for (j in 1:num_area) {
      temp_area = area_list[j]
      if (s_or_d == 0) {
        cur_area = cur_day %>% filter(State == temp_area)
      } else {
        cur_area = cur_day %>% filter(district == temp_area)
      }
      if (target == 1) {
        mtx[k,j] = sum(cur_area$confirmed)
      } else if (target == 2) {
        mtx[k,j] = sum(cur_area$active)
      } else if (target == 3) {
        mtx[k,j] = sum(cur_area$recovered)
      } else {
        mtx[k,j] = sum(cur_area$deceased)
      }
    }
  }
  return(mtx)
}

states_mtx_confirmed = agg_area(districts_data$State, 1, 0)
states_mtx_active = agg_area(districts_data$State, 2, 0)
states_mtx_recovered = agg_area(districts_data$State, 3, 0)
states_mtx_deceased = agg_area(districts_data$State, 4, 0)

district_mtx_confirmed = agg_area(districts_data$district, 1, 1)
district_mtx_active = agg_area(districts_data$district, 2, 1)
district_mtx_recovered = agg_area(districts_data$district, 3, 1)
district_mtx_deceased = agg_area(districts_data$district, 4, 1)
##################

# select total active cases at state level
total_active_state <- states_mtx_active[nrow(states_mtx_active), ]
total_active_state <- t(total_active_state)
total_active_state <- data.frame(total_active_state)
total_active_state <- tibble::rownames_to_column(total_active_state, "state")
names(total_active_state)[1] <- "state"
names(total_active_state)[2] <- "patients"

# Patient's data from 4 specific states
active_state_4 <- total_active_state %>% filter(state == "Maharashtra" | state == "Delhi" | state == "Tamil Nadu" | state == "Gujarat")

# Read in the Inidan state map file 
backup <- rgdal::readOGR("data/india_states.geojson")

# Combine map data with patient's data
backup@data$patients <- 0
for (i in 1:nrow(total_active_state)) {
  for (j in 1:nrow(backup@data)) {
    if (total_active_state$state[i] == backup@data$NAME_1[j]) {
      backup@data$patients[j] <- total_active_state$patients[i]
    }
  }
}

# Create a color palette for the map:
mypalette <- colorNumeric( palette="viridis", domain=backup@data$patients, 
                           na.color="transparent")
mypalette(c(45,43))

# Labels for choropleths
labels <- sprintf("<strong>%s</strong><br/>count: %g",
                  backup@data$NAME_1, backup@data$patients) %>% 
  lapply(htmltools::HTML)


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
      addPolygons(label = labels,
                  fillColor = ~mypalette(patients), 
                  stroke=TRUE,
                  color = "#444444",
                  weight = 1,
                  smoothFactor = 0.5,
                  opacity = 1.0,
                  fillOpacity = 0.5,
                  highlightOptions = highlightOptions(color = "white",
                                                      weight = 2,
                                                      bringToFront = TRUE)) %>% 
      addLegend("bottomleft", pal = mypalette, values = backup@data$patients,
                title = "Number of Patients",
                opacity = 0.5) 
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
  
  output$aggtraceplot <- renderPlotly({
    agg_trace_plt = plot_ly(x = levels(date_list), y = agg_country_confirmed, type = 'scatter', mode = 'lines+markers', name = "Total confirmed cases", hoverinfo = 'text')
    agg_trace_plt = agg_trace_plt %>% add_trace(y = agg_country_active, name = "Total active cases")
    agg_trace_plt = agg_trace_plt %>% add_trace(y = agg_country_recovered, name = "Total recovered cases")
    agg_trace_plt = agg_trace_plt %>% add_trace(y = agg_country_deceased, name = "Total deceased cases")
    agg_trace_plt = agg_trace_plt %>% layout(title = "Cases vs Date (2020-04-21 to 2020-05-16) in India", 
                                             xaxis = list(title = "Cases", showgrid = F),
                                             yaxis = list(title = "Date"),
                                             legend = list(x = 0.05, y = 0.95, title=list(text='<b>Total Cases</b>'), bgcolor = 'rgba(255,255,255,0.5)'))
  })
  
  output$aggactiveplot <- renderPlotly({
    sub_agg_plt_increase = plot_ly(x = levels(date_list), y = agg_country_active, type = 'scatter', mode = 'lines+markers', name = "Total active cases")
    sub_agg_plt_increase = sub_agg_plt_increase %>% add_trace(y = agg_country_net_active, name = "Net active cases", yaxis = "y2")
    sub_agg_plt_increase = sub_agg_plt_increase %>% layout(title = "Total/Net Active Cases vs Date", 
                                                           xaxis = list(title = "Date", showgrid = F),
                                                           yaxis = list(color = "steelblue", tickfont = list(color = "steelblue"),title = "Total"),
                                                           yaxis2 = list(color = "darkorange", tickfont = list(color = "darkorange"), overlaying = "y",side = "right",title = "Net"),
                                                           legend = list(x = 0.05, y = 0.9, title=list(text='<b>Growth Rate: 4.288883%</b>'), bgcolor = 'rgba(255,255,255,0.5)'),
                                                           margin = list(r = 60))
  })
  
  output$aggrecoveredplot <- renderPlotly({
    sub_agg_plt_recovered = plot_ly(x = levels(date_list), y = agg_country_recovered, type = 'scatter', mode = 'lines+markers', name = "Total recovered cases")
    sub_agg_plt_recovered = sub_agg_plt_recovered %>% add_trace(y = agg_country_net_recovered, name = "Net recovered cases", yaxis = "y2")
    sub_agg_plt_recovered = sub_agg_plt_recovered %>% layout(title = "Total/Net Recovered Cases vs Date", 
                                                             xaxis = list(title = "Date", showgrid = F),
                                                             yaxis = list(color = "steelblue", tickfont = list(color = "steelblue"),title = "Total"),
                                                             yaxis2 = list(color = "darkorange", tickfont = list(color = "darkorange"),overlaying = "y",side = "right",title = "Net"),
                                                             legend = list(x = 0.1, y = 0.9, title=list(text='<b>Growth Rate: 14.21489%</b>'), bgcolor = 'rgba(255,255,255,0.5)'),
                                                             margin = list(r = 60))
  })
  
  output$aggdeceasedplot <- renderPlotly({
    sub_agg_plt_deceased = plot_ly(x = levels(date_list), y = agg_country_deceased, type = 'scatter', mode = 'lines+markers', name = "Total deceased cases")
    sub_agg_plt_deceased = sub_agg_plt_deceased %>% add_trace(y = agg_country_net_deceased, name = "Net deceased cases", yaxis = "y2")
    sub_agg_plt_deceased = sub_agg_plt_deceased %>% layout(title = "Total/Net Deceased Cases vs Date", 
                                                           xaxis = list(title = "Date", showgrid = F),
                                                           yaxis = list(color = "steelblue", tickfont = list(color = "steelblue"),title = "Total"),
                                                           yaxis2 = list(color = "darkorange", tickfont = list(color = "darkorange"),overlaying = "y",side = "right",title = "Net"),
                                                           legend = list(x = 0.15, y = 0.9, title=list(text='<b>Growth Rate: 16.8953%</b>'), bgcolor = 'rgba(255,255,255,0.5)'),
                                                           margin = list(r = 60))
  })
  
}