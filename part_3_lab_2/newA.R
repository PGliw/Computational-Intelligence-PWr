require("GA")
require("globalOptTests")

# Operatory mutacji
# omutation.custom = custom.mutation.function
omutation.default = gaperm_simMutation
omutation.range = c(gaperm_simMutation, gaperm_ismMutation,
                    gaperm_swMutation, gaperm_dmMutation,
                    gaperm_scrMutation)
omutation.names = c("custom", "sim", "ism", "sw", "dm", "scr")

# Operatory krzyzowania
# ocrossover.custom = custom.crossing.function
ocrossover.default = gaperm_oxCrossover
ocrossover.range = c(gaperm_cxCrossover, gaperm_pmxCrossover,
                     gaperm_oxCrossover, gaperm_pbxCrossover)
ocrossover.names = c("custom", "cx", "pmx", "ox", "pbx")
oselection.default = gaperm_lrSelection


# returns objective function given by name
objective.fun.of <- function(function.name) {
  # Get the length of the parameter vector expected by a given objective function.
  problem.dimen <- getProblemDimen(function.name)
  function(x1, x2) {
    x1x2 <- c(x1, x2)
    goTest(par = c(x1x2, rep(0, problem.dimen - length(x1x2))), fnName = function.name, checkDim = TRUE)
  }
}

# runs function genetic algorithm for function given by name iterations.count times
# params is list that contains params for genetic algorithm
GA.run.iterations <- function(function.name, iterations.count, crossover.operator = gaControl(type.name)$crossover, mutation.operator = gaControl(type.name)$mutation) {
  default.bounds <- getDefaultBounds(function.name)
  objective.fun <- objective.fun.of(function.name)
  iteration.mean.scores <- NULL # accumulator for mean results in each iteration
  iteration.best.scores <- NULL # accumulator for best results in each iteration
  for (iteration in 1:iterations.count) {
    GA <- ga(type = type.name,
             fitness = function(x) - objective.fun(x[1], x[2]),
             lower = c(default.bounds$lower[1], default.bounds$lower[2]),
             upper = c(default.bounds$upper[1], default.bounds$upper[2]),
             population = gaControl(type.name)$population,
             selection = gaControl(type.name)$selection,
             crossover = crossover.operator,
             mutation = mutation.operator
             )
    iteration.best.scores[iteration] <- -GA@fitnessValue # objective.fun(GA@solution[, 1], GA@solution[, 2])
    iteration.mean.scores[iteration] <- mean(apply(GA@population, 1, function(x1x2) { objective.fun(x1x2[1], x1x2[2]) }))
  }
  list(best.mean = mean(iteration.best.scores), mean.mean = mean(iteration.mean.scores), iteration.best.scores = iteration.best.scores)
}

# runs experiment for every param.name value in param.range
GA.run.experiment <- function(function.name, iterations.count, crossover.range, mutation.range) {
  operator.best.scores <- NULL # accumulator for best mean results in generation
  operator.mean.scores <- NULL # accumulator for mean mean results in generation
  # GA.best <- NULL # best result
  index <- 1
  for(operator in crossover.range) {
    operator.score <- GA.run.iterations(function.name, iterations.count, crossover.operator = operator)
    operator.best.scores[index] <- operator.score$best.mean
    operator.mean.scores[index] <- operator.score$mean.mean
    index = index + 1
  }
  # print(operator.best.scores)
  list(best.scores = operator.best.scores, mean.scores = operator.mean.scores)
}

# runs experiments as a batch
GA.run.experiment.list <- function(function.name, iterations.count = 10, crossover.range, mutation.range) {
  param.score.range <- GA.run.experiment(function.name, iterations.count, crossover.range, mutation.range)
  print(param.score.range)
  scores.plot(
    x = seq_along(param.score.range$best.scores),
    y1 = param.score.range$best.scores,
    y2 = param.score.range$mean.scores,
    const = getGlobalOpt(function.name),
    x.label = "scores"
  )
}

#plots best (y1) and mean (y2) scores for each param value x
scores.plot <- function(x, y1, y2, const, x.label, y.label = "Wartość funkcji celu") {
  matplot(x, cbind(y1, y2), col = c("green", "blue"), type = c("o", "o"), pch = 1:2, xlab = x.label, ylab = y.label)
  abline(h = const, col = "red")
}

type.name = "permutation"

# experiments for Schuber function
function.name <- "Schubert"

GA.run.experiment.list(function.name, 10, ocrossover.range)
