test_that("ti_scorpius works", {
  dataset <- dynutils::read_h5(system.file("example.h5", package = "tiscorpius"))

  model <- dynwrap::infer_trajectory(dataset, tiscorpius::ti_scorpius())

  expect_is(model, "dynwrap::with_trajectory")
})
