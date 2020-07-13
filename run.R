#!/usr/local/bin/Rscript

requireNamespace("dyncli", quietly = TRUE)
# task <- dyncli::main(c("--dataset", "/ti/input.h5"))
task <- dyncli::main()
# task <- dyncli::main(args = strsplit("--dataset ~/example.h5 --output ~/output.h5", " ")[[1]], definition_location = "ti_scorpius/definition.yml")

library(dplyr, warn.conflicts = FALSE)
requireNamespace("dynutils", quietly = TRUE)
requireNamespace("dynwrap", quietly = TRUE)
requireNamespace("SCORPIUS", quietly = TRUE)

#   ____________________________________________________________________________
#   Load data                                                               ####

parameters <- task$parameters

# use k <= 1 to turn off clustering
if (parameters$k <= 1) {
  parameters$k <- NULL
}

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = Sys.time())

# use prior dimred if available
space <-
  if (is.null(task$priors$dimred)) {
    SCORPIUS::reduce_dimensionality(
      x = task$expression,
      dist = parameters$distance_method,
      ndim = parameters$ndim
    )
  } else {
    task$priors$dimred
  }

# infer a trajectory through the data
traj <- SCORPIUS::infer_trajectory(
  space,
  k = parameters$k,
  thresh = parameters$thresh,
  maxit = parameters$maxit,
  stretch = parameters$stretch,
  smoother = parameters$smoother
)

# TIMING: done with method
checkpoints$method_aftermethod <- Sys.time()

#   ____________________________________________________________________________
#   Save output                                                             ####

output <-
  dynwrap::wrap_data(
    cell_ids = names(traj$time)
  ) %>%
  dynwrap::add_linear_trajectory(
    pseudotime = traj$time
  ) %>%
  dynwrap::add_timings(
    timings = checkpoints
  )

# convert trajectory to segments
dimred_segment_points <- traj$path
dimred_segment_progressions <- output$progressions %>% select(from, to, percentage)

output <-
  output %>%
  dynwrap::add_dimred(
    dimred = space,
    dimred_segment_points = dimred_segment_points,
    dimred_segment_progressions = dimred_segment_progressions,
    connect_segments = TRUE
  )

dyncli::write_output(output, task$output)
