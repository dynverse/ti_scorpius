context("ti_scorpius")

test_that("ti_scorpius works", {
  dataset <- source(system.file("example.sh", package = "tiscorpius"))$value

  model <- dynwrap::infer_trajectory(dataset, tiscorpius::ti_scorpius())

  expect_is(model, "dynwrap::with_trajectory")
})
