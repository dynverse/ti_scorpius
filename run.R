#!/usr/local/bin/Rscript

requireNamespace("dyncli", quietly = TRUE)
task <- dyncli::main()

library(tiscorpius, warn.conflicts = FALSE)

output <- tiscorpius::run_fun(
  expression = task$expression,
  priors = task$priors,
  parameters = task$parameters,
  seed = task$seed,
  verbose = task$verbose
)

dyncli::write_output(output, task$output)
