### models
fit_canton_models <- function(prepared_data) { 
  
  train_model <- prepared_data$train_model
  
  ## define formulas
  formula_mdl0 <- y ~ log_popdens_s + log_swiss_s + log_female_s + log_businesses_s + log_empldens_s + tavg_s + prcp_s + offset(log(n_days))
  formula_mdl1 <- y ~ season_qtr + time_id_s + log_popdens_s + log_swiss_s + log_female_s + log_businesses_s + log_empldens_s + tavg_s + prcp_s + offset(log(n_days))
  formula_mdl2 <- y ~ season_qtr + time_id_s + log_popdens_s + log_swiss_s + log_female_s + log_businesses_s + log_empldens_s + tavg_s + prcp_s + 
    # spatial part
    E_REFR_s + N_REFR_s + I(E_REFR_s^2) + I(N_REFR_s^2) + E_REFR_s:N_REFR_s + offset(log(n_days))
  
  ## Poi distribution for the dep variable
  mdl0 <- mgcv::gam( formula = formula_mdl0, family = poisson(link = "log"), method = "ML", data = train_model )
  mdl1 <- mgcv::gam( formula = formula_mdl1, family = poisson(link = "log"), method = "ML", data = train_model )
  mdl2 <- mgcv::gam( formula = formula_mdl2, family = poisson(link = "log"), method = "ML", data = train_model )
  
  ## Neg Bin distribution for the dep variable
  mdl0_nb <- mgcv::gam( formula = formula_mdl0, family = mgcv::nb(link = "log"), method = "ML", data = train_model )
  mdl1_nb <- mgcv::gam( formula = formula_mdl1, family = mgcv::nb(link = "log"), method = "ML", data = train_model )
  mdl2_nb <- mgcv::gam( formula = formula_mdl2, family = mgcv::nb(link = "log"),  method = "ML", data = train_model )
  
  # store models 
  list( MDL0 = mdl0, MDL0_NB = mdl0_nb, MDL1 = mdl1,
        MDL1_NB = mdl1_nb, MDL2 = mdl2, MDL2_NB = mdl2_nb )
}