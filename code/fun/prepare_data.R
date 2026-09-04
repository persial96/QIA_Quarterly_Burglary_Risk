## prepare data by canton
prepare_canton_data <- function( df_q, canton, train_share = 0.80 ) {
  required_columns <- c( "quarter", "RELI", "E_REFR", "N_REFR", "y", "n_days", "popdens", "swiss_pop", "female_pop", "businesses", "empldens", "tavg", "prcp" )
  missing_columns <- setdiff(required_columns, names(df_q))
  
  # convert quarter to Date when read from CSV as text
  if (!inherits(df_q$quarter, "Date")) { df_q <- df_q %>% mutate(quarter = as.Date(quarter)) }
  all_quarters <- sort(unique(df_q$quarter))
  
  ## covariates
  df_model_raw <- df_q %>%
    arrange(RELI, quarter) %>%
    mutate( RELI_chr = as.character(RELI), season_qtr = factor( lubridate::quarter(quarter),
                                                                levels = 1:4,
                                                                labels = c("Q1", "Q2", "Q3", "Q4") ),
            time_id = match(quarter, all_quarters), 
            log_popdens = log1p(popdens), 
            log_swiss = log1p(swiss_pop), 
            log_female = log1p(female_pop), 
            log_businesses = log1p(businesses), 
            log_empldens = log1p(empldens) )
  
  complete_variables <- c(
    "y", "n_days", "E_REFR", "N_REFR", "log_popdens", "log_swiss", "log_female", "log_businesses", "log_empldens", "tavg", "prcp"
  )
  
  df_model_raw <- df_model_raw %>%
    filter( n_days > 0, if_all(all_of(complete_variables), ~ !is.na(.x) ) )
  
  ## train-test split
  quarter_values <- sort( unique(df_model_raw$quarter) )
  cutoff_index <- floor(train_share * length(quarter_values))
  cutoff_index <- max(1, min( cutoff_index, length(quarter_values) - 1))
  cutoff <- quarter_values[cutoff_index]
  train_raw <- df_model_raw %>% filter(quarter <= cutoff)
  test_raw <- df_model_raw %>% filter(quarter > cutoff)
  
  ## scaling is done using training data only
  variables_to_scale <- c("E_REFR", "N_REFR", "time_id", "log_popdens", "log_swiss", "log_female", "log_businesses", "log_empldens", "tavg", "prcp")
  
  scaler <- fit_scaler( data = train_raw, variables = variables_to_scale )
  train_scaled <- apply_scaler( data = train_raw, scaler = scaler )
  test_scaled <- apply_scaler( data = test_raw, scaler = scaler )
  
  ## estimation sample
  required_model_variables <- c( "y", "n_days", "RELI_chr", "season_qtr", "E_REFR_s", "N_REFR_s", "time_id_s", 
                                 "log_popdens_s", "log_swiss_s", "log_female_s", "log_businesses_s", "log_empldens_s", 
                                 "tavg_s", "prcp_s")
  train_model <- train_scaled %>% drop_na( all_of(required_model_variables) )
  test_model <- test_scaled %>% drop_na( all_of(required_model_variables) )
  
  cat(
    "\n",
    "============================================================\n",
    canton,
    "\n",
    "============================================================\n",
    "Training cutoff: ",
    as.character(cutoff),
    "\n",
    "Training quarters: ",
    n_distinct(train_model$quarter),
    "\n",
    "Test quarters: ",
    n_distinct(test_model$quarter),
    "\n",
    "Training observations: ",
    format(nrow(train_model), big.mark = ","),
    "\n",
    "Test observations: ",
    format(nrow(test_model), big.mark = ","),
    "\n",
    sep = ""
  )
  
  list( canton = canton, cutoff = cutoff, 
        scaler = scaler, train_model = train_model, 
        test_model = test_model )
}