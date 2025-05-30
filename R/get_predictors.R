#' @title Get the data from model predictors
#' @name get_predictors
#'
#' @description Returns the data from all predictor variables (fixed effects).
#'
#' @param verbose Toggle messages and warnings.
#' @inheritParams find_predictors
#'
#' @return The data from all predictor variables, as data frame.
#'
#' @examples
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#' head(get_predictors(m))
#' @export
get_predictors <- function(x, verbose = TRUE) {
  vars <- if (inherits(x, "wbm")) {
    unlist(compact_list(
      find_terms(x, flatten = FALSE, verbose = FALSE)[c("conditional", "instruments")]
    ))
  } else {
    find_predictors(
      x,
      effects = "fixed",
      component = "all",
      flatten = TRUE,
      verbose = FALSE
    )
  }

  dat <- get_data(x, verbose = FALSE)
  dat <- dat[, intersect(vars, colnames(dat)), drop = FALSE]

  if (is_empty_object(dat)) {
    if (isTRUE(verbose)) {
      format_warning("Data frame is empty, probably you have an intercept-only model?")
    }
    return(NULL)
  }

  dat
}
