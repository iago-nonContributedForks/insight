skip_if_not(getRversion() >= "4.4.0")
skip_if_not_installed("cplm")

# cplm::cpglmm doesn't work
suppressPackageStartupMessages({
  suppressWarnings(suppressMessages(library(cplm, quietly = TRUE, warn.conflicts = FALSE)))
})

data("FineRoot", package = "cplm")
m1 <- cpglmm(RLD ~ Stock + Spacing + (1 | Plant), data = FineRoot)

test_that("model_info", {
  expect_true(model_info(m1)$is_count)
  expect_false(model_info(m1)$is_linear)
})

test_that("find_predictors", {
  expect_identical(
    find_predictors(m1, effects = "all"),
    list(conditional = c("Stock", "Spacing"), random = "Plant")
  )
  expect_identical(
    find_predictors(m1, effects = "all", flatten = TRUE),
    c("Stock", "Spacing", "Plant")
  )
  expect_identical(
    find_predictors(m1, effects = "fixed"),
    list(conditional = c("Stock", "Spacing"))
  )
  expect_identical(
    find_predictors(m1, effects = "fixed", flatten = TRUE),
    c("Stock", "Spacing")
  )
  expect_identical(
    find_predictors(m1, effects = "random"),
    list(random = "Plant")
  )
  expect_identical(
    find_predictors(m1, effects = "random", flatten = TRUE),
    "Plant"
  )
})

test_that("find_random", {
  expect_identical(find_random(m1), list(random = "Plant"))
  expect_identical(find_random(m1, flatten = TRUE), "Plant")
})

test_that("find_response", {
  expect_identical(find_response(m1), "RLD")
})

test_that("get_response", {
  expect_equal(get_response(m1), FineRoot$RLD, ignore_attr = TRUE)
})


test_that("get_data", {
  expect_named(get_data(m1), c("RLD", "Stock", "Spacing", "Plant"))
  expect_named(get_data(m1, effects = "all"), c("RLD", "Stock", "Spacing", "Plant"))
  expect_named(get_data(m1, effects = "random"), "Plant")
})

test_that("find_formula", {
  expect_length(find_formula(m1), 2)
  expect_equal(
    find_formula(m1, component = "conditional"),
    list(
      conditional = as.formula("RLD ~ Stock + Spacing"),
      random = as.formula("~1 | Plant")
    ),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      response = "RLD",
      conditional = c("Stock", "Spacing"),
      random = "Plant"
    )
  )
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("RLD", "Stock", "Spacing", "Plant")
  )
})


test_that("link_function", {
  expect_equal(link_function(m1)(0.2), log(0.2), tolerance = 1e-3)
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), exp(0.2), tolerance = 1e-3)
})


test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = "RLD",
      conditional = c("Stock", "Spacing"),
      random = "Plant"
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("RLD", "Stock", "Spacing", "Plant")
  )
})

test_that("get_predictors", {
  expect_identical(colnames(get_predictors(m1)), c("Stock", "Spacing"))
})

test_that("get_random", {
  expect_identical(colnames(get_random(m1)), "Plant")
})

test_that("clean_names", {
  expect_identical(clean_names(m1), c("RLD", "Stock", "Spacing", "Plant"))
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional = c("(Intercept)", "StockMM106", "StockMark", "Spacing5x3"),
      random = list(Plant = "(Intercept)")
    )
  )
  expect_identical(nrow(get_parameters(m1)), 4L)
  expect_identical(get_parameters(m1)$Parameter, c("(Intercept)", "StockMM106", "StockMark", "Spacing5x3"))
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("get_variance", {
  skip_on_cran()
  expect_equal(
    suppressWarnings(get_variance(m1)),
    list(
      var.fixed = 0.1687617,
      var.random = 0.0002706301,
      var.residual = 2.682131,
      var.distribution = 2.682131,
      var.dispersion = 0,
      var.intercept = c(Plant = 0.0002706301)
    ),
    tolerance = 1e-3
  )
})

test_that("find_random_slopes", {
  expect_null(find_random_slopes(m1))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "t-statistic")
})

unloadNamespace("cplm")
