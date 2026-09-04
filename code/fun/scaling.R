## Scaling function
fit_scaler <- function(data, variables) {
  
  tibble( variable = variables, 
          mean = vapply( variables, function(variable) { mean(data[[variable]], na.rm = TRUE) }, numeric(1)),
          sd = vapply( variables, function(variable) { stats::sd(data[[variable]], na.rm = TRUE) }, numeric(1) )
  ) %>% 
    mutate( sd = if_else( is.na(sd) | sd == 0, 1, sd ) ) 
}

# standard scaler
apply_scaler <- function(data, scaler) { output <- data
for (i in seq_len(nrow(scaler))) { variable <- scaler$variable[i] 
scaled_variable <- paste0(variable, "_s") 
output[[scaled_variable]] <-
  ( output[[variable]] - scaler$mean[i] ) / scaler$sd[i]
}
output
}