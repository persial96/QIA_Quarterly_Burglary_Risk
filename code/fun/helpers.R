# ============================================================
# 7. BEST-MODEL HELPERS
# ============================================================

get_best_model_name <- function(
    result,
    criterion = c("AIC", "BIC"),
    family = NULL
) {
  
  criterion <- match.arg(criterion)
  
  comparison <- result$comparison
  
  if (!is.null(family)) {
    comparison <- comparison %>%
      filter(Family == family)
  }
  
  comparison %>%
    slice_min(
      order_by = .data[[criterion]],
      n = 1,
      with_ties = FALSE
    ) %>%
    pull(Model)
}


get_best_model <- function(
    result,
    criterion = c("AIC", "BIC"),
    family = NULL
) {
  
  criterion <- match.arg(criterion)
  
  model_name <- get_best_model_name(
    result = result,
    criterion = criterion,
    family = family
  )
  
  result$models[[model_name]]
}