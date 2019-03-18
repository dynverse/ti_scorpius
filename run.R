#!/usr/local/bin/Rscript

task <- dyncli::main()

library(jsonlite)
library(readr)
library(dplyr)
library(purrr)

library(SCORPIUS)

#   ____________________________________________________________________________
#   Load data                                                               ####

expression <- as.matrix(task$expression)
params <- task$params

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####


# use k <= 1 to turn off clustering
if (params$k <= 1) {
  params$k <- NULL
}

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = Sys.time())

space <- SCORPIUS::reduce_dimensionality(
  x = expression,
  dist_fun = function(x, y = NULL) dynutils::calculate_distance(x = x, y = y, method = params$distance_method),
  landmark_method = ifelse(params$sparse, "naive", "none"),
  ndim = params$ndim,
  num_landmarks = ifelse(nrow(expression) > 500, 500, nrow(expression))
)

# infer a trajectory through the data
traj <- SCORPIUS::infer_trajectory(
  space,
  k = params$k,
  thresh = params$thresh,
  maxit = params$maxit,
  stretch = params$stretch,
  smoother = params$smoother
)

# TIMING: done with method
checkpoints$method_aftermethod <- Sys.time()

#   ____________________________________________________________________________
#   Save output                                                             ####

output <- 
  dynwrap::wrap_data(cell_ids = names(traj$time)) %>%
  dynwrap::add_linear_trajectory(
    pseudotime = traj$time
  ) %>%
  dynwrap::add_timings(timings = checkpoints)

# convert trajectory to segments
dimred_segment_points <- traj$path
dimred_segment_progressions <- output$progressions %>% select(from, to, percentage)

output <- output %>% dynwrap::add_dimred(
  dimred = space,
  dimred_segment_points = dimred_segment_points,
  dimred_segment_progressions = dimred_segment_progressions,
  connect_segments = TRUE
)

output %>% dyncli::write_output(task$output)
