## construct model comparison table
extract_theta <- function(model) { 
  
  get_theta <- model$family$getTheta
  if (is.function(get_theta)) {
    return(
      as.numeric(get_theta(TRUE))
    )
  }
  NA_real_
}


compare_canton_models <- function(models) {
  family_names <- vapply( models,
                          function(model) { model$family$family }, character(1) ) 
  tibble( Model = names(models), 
                                                                                          Family = if_else( grepl( "Negative Binomial", family_names, fixed = TRUE ), 
                                                                                                            "Negative Binomial", "Poisson" ),
                                                                                          Theta = vapply(models, extract_theta, numeric(1) ),
                                                                                          LogLik = vapply( models, function(model) { as.numeric(logLik(model)) }, numeric(1) ),
                                                                                          AIC = vapply( models, AIC, numeric(1) ),
                                                                                          BIC = vapply( models, BIC, numeric(1) ),
                                                                                          Deviance_explained = vapply( models, function(model) { summary(model)$dev.expl }, numeric(1) )
                          )
}