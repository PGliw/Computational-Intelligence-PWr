# Title     : TODO
# Objective : TODO
# Created by: Piotr
# Created on: 20.05.2020

GA.run.iterations <- function(function.name, iterations.count, params) {
  problem.dimen <- getProblemDimen(function.name)
  default.bounds.matrix <- matrix(unlist(getDefaultBounds(function.name)), ncol = problem.dimen, byrow = TRUE)
  objective.fun <- objective.fun.of(function.name)
  iteration.scores <- NULL # accumulator
  for (iteration in 1:iterations.count) {
    GA <- ga(type = "real-valued",
             fitness = function(x) -objective.fun(x[1], x[2]),
             lower = default.bounds.matrix[1,],
             upper = default.bounds.matrix[2,],
             popSize = params$pop.size,
             maxiter = params$max.iter,
             elitism = params$elitism,
             pcrossover = params$pcrossover,
             pmutation = params$pmutation)
    iteration.scores[iteration] <- objective.fun(GA@solution[, 1], GA@solution[, 2])
  }
  mean(iteration.scores)
}

# res <- GA.run.iterations(function.name, 10, params)

# runs experiment for every param.name value in param.range
GA.run.experiment <- function(function.name, iterations.count, params, param.name, param.range) {
  param.scores <- NULL # accumulator
  # GA.best <- NULL # best result
  for (param.value.index in seq_along(param.range)) {
    params$param.name <- param.range[param.value.index]
    param.score <- GA.run.iterations(function.name, iterations.count, params)
    param.scores[param.value.index] <- param.score
  }
  param.scores
}

function.name <- "Hosaki"

params <- list(pop.size = 10, max.iter = 100, elitism = 0.1, pcrossover = 0.8, pmutation = 0.1)

param.names.and.ranges <- list(names = c("pop.size", "max.iter", "elitism", "pcrossover", "pmutation"),
                               bounds.lower = c(40, 40, 0.0, 0.0, 0.0),
                               bounds.upper = c(400, 400, 1.0, 1.0, 1.0),
                               bounds.step = c(40, 40, 0.1, 0.1, 0.1)
)


for (param.index in seq_along(param.names.and.ranges)) {
  param.name <- param.names.and.ranges$names[param.index]
  param.value.range <- seq(param.names.and.ranges$bounds.lower[param.index], param.names.and.ranges$bounds.upper[param.index], by = param.names.and.ranges$bounds.step[param.index])
  param.score.range <- GA.run.experiment(function.name, 10, params, param.name, param.value.range)
  plot(param.value.range, param.score.range, xlab = param.name, ylab = "Wartość funkcji celu")
  lines(param.value.range, param.score.range, col = "red")
  global.opt <- getGlobalOpt(function.name)
  abline(h = global.opt, col = "blue")
}

