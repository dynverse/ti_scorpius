#' @import dplyr
#' @import purrr
#' @import SCORPIUS
#'
#' @export
run_fun <- function(expression, priors, parameters, seed = NULL, verbose = 0)  {
  if (!is.null(seed)) set.seed(seed)

  #   ____________________________________________________________________________
  #   Infer trajectory                                                        ####

  # doesn't support sparse yet... :(
  expression <- as.matrix(expression)

  # use k <= 1 to turn off clustering
  if (parameters$k <= 1) {
    parameters$k <- NULL
  }

  # TIMING: done with preproc
  checkpoints <- list(method_afterpreproc = Sys.time())

  space <- SCORPIUS::reduce_dimensionality(
    x = expression,
    dist_fun = function(x, y = NULL) as.matrix(dynutils::calculate_distance(x = x, y = y, method = parameters$distance_method)),
    landmark_method = ifelse(parameters$sparse, "naive", "none"),
    ndim = parameters$ndim,
    num_landmarks = ifelse(nrow(expression) > 500, 500, nrow(expression))
  )

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
    dynwrap::wrap_data(cell_ids = names(traj$time)) %>%
    dynwrap::add_linear_trajectory(
      pseudotime = traj$time
    ) %>%
    dynwrap::add_timings(timings = checkpoints)

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

  output
}


definition <- dynwrap:::.method_load_definition(system.file("definition.yml", package = "tiscorpius"))

#' Infer a trajectory using SCORPIUS
#'
#' @eval dynwrap::generate_parameter_documentation(definition)
#' @export
ti_scorpius <- dynwrap::create_ti_method_r(
  definition = definition,
  run_fun = run_fun
)