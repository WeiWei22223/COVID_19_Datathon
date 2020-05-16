data <- read.csv("data/cleaned_patient_city_district_wise_data.csv", stringsAsFactors = FALSE)
state <- unique(data$Detected_State)
state_code <- unique(data$State_Code)
district <- unique(data$Detected_District)
state_wise <- data.frame(state, state_code)
state_wise["patients"] <- 0
state_wise["female"] <- 0
state_wise["male"] <- 0

# Loop through all data to update count of patient in each gender
for (i in 1:nrow(data)) {
  line <- data[i, ]
  for (j in 1:nrow(state_wise)) {
    if (state_wise[j, 1] == line[, 4]) {
      state_wise[j, 3] = state_wise[j, 3] + 1;
      if (line[, 1] == "F") {
        state_wise[j, 4] = state_wise[j, 4] + 1;
      } else if (line[, 1] == "M") {
        state_wise[j, 5] = state_wise[j, 5] + 1;
      }
    }
  }
}

write.csv(state_wise, "aggregated_state_data.csv", row.names = FALSE)
