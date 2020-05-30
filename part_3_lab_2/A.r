require("GA")
require("globalOptTests")

custom.crossing.function <- function(object, parents) {
  
  parents <- object@population[parents,, drop = FALSE]
  n <- ncol(parents)
  children <- matrix(as.double(NA), nrow = 2, ncol = n)
  tmp <- runif(n, 1, 2)
  children[1,] <- tmp*parents[1,] + (1-tmp)*parents[2,]
  children[2,] <- tmp * parents[2,] + (1 - tmp) * parents[1,]
  out <- list(children = children, fitness = rep(NA, 2))
  return(out)
}

custom.mutation.function <- function(object, parent) {
  mutate <- as.vector(object@population[parent,])
  # Amount of random changes
  random_changes <- sample(1:(length(mutate) / 20), 1)
  i <- 1
  while (i <= random_changes) {
    # Random indexes to change
    random_indexes <- sample(1:length(mutate), 2)
    temp <- mutate[random_indexes[1]]
    mutate[random_indexes[1]] <- mutate[random_indexes[2]]
    mutate[random_indexes[2]] <- temp
    i <- i + 1
  }
  return(mutate)
}

# Mutation operators
omutation.custom = custom.mutation.function
omutation.default = gareal_raMutation
omutation.range = c(custom.mutation.function, gareal_raMutation, gareal_nraMutation, gareal_rsMutation, gareal_powMutation)
omutation.names = c("custom", "ra", "nra", "rs", "pow")

# Crossover operators
ocrossover.custom = custom.crossing.function
ocrossover.default = gaperm_oxCrossover
ocrossover.range = c(custom.crossing.function, gareal_spCrossover, gareal_waCrossover, gareal_laCrossover, gareal_blxCrossover, gareal_laplaceCrossover)
ocrossover.names = c("custom", "sp", "wa", "la", "blx", "laplace")





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
             crossover = crossover.operator,
             mutation = mutation.operator
             )
    iteration.best.scores[iteration] <- -GA@fitnessValue # objective.fun(GA@solution[, 1], GA@solution[, 2])
    iteration.mean.scores[iteration] <- mean(apply(GA@population, 1, function(x1x2) { objective.fun(x1x2[1], x1x2[2]) }))
  }
  list(best.mean = mean(iteration.best.scores), mean.mean = mean(iteration.mean.scores), iteration.best.scores = iteration.best.scores)
}

# runs experiment for every param.name value in param.range
GA.run.experiment <- function(function.name, iterations.count, crossover.range = NULL, mutation.range = NULL) {
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
  for (operator in mutation.range) {
    operator.score <- GA.run.iterations(function.name, iterations.count, mutation.operator = operator)
    operator.best.scores[index] <- operator.score$best.mean
    operator.mean.scores[index] <- operator.score$mean.mean
    index = index + 1
  }
  # print(operator.best.scores)
  list(best.scores = operator.best.scores, mean.scores = operator.mean.scores)
}

# runs experiments as a batch
GA.run.experiment.list <- function(function.name, iterations.count = 10, crossover.range = NULL, mutation.range = NULL) {
  param.score.range <- GA.run.experiment(function.name, iterations.count, crossover.range, mutation.range)
  print(param.score.range)
  scores.plot(
    y1 = param.score.range$best.scores,
    y2 = param.score.range$mean.scores
  )
}

#plots best (y1) and mean (y2) scores for each param value x
scores.plot <- function(y1, y2, x.label = "Różnica między wartością funkcji celu a wartością globalnego optimum") {
  y1 = y1 - optimum.value
  y2 = y2 - optimum.value
  # Create plots for crossover operators
  png(file = "Crossover_best.png")
  barplot(abs(y1), main = "Porównanie operatorów krzyzowania", xlab = x.label, names.arg = ocrossover.names, , col=rainbow(6))
  dev.off()
  png(file = "Crossover_means.png")
  barplot(abs(y2), main = "Porównanie operatorów krzyzowania", xlab = x.label, names.arg = ocrossover.names, , col=rainbow(6))
  dev.off()

  # Create plots for mutation operators
  # png(file = "Mutation_best.png")
  # barplot(abs(y1), main = "Porównanie operatorów mutacji", xlab = x.label, names.arg = omutation.names, col=rainbow(6))
  # dev.off()
  # png(file = "Mutation_means.png")
  # barplot(abs(y2), main = "Porównanie operatorów mutacji", xlab = x.label, names.arg = omutation.names, col = rainbow(6))
  # dev.off()
}

optimum.value = -186.7309
type.name = "real-valued"

# experiments for Schuber function
function.name <- "Schubert"

#Function used to test all crossover operators
GA.run.experiment.list(function.name, 10, crossover.range = ocrossover.range)

#Function used to test all mutation operators
# GA.run.experiment.list(function.name, 10, mutation.range = omutation.range)


