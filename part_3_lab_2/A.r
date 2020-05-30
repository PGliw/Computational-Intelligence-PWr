require("GA")
require("globalOptTests")

custom.crossing.function <- function(object, parents) {
  # Pierwszy potomek - operator OX
  parents <- object@population[parents,, drop = FALSE]
  n <- ncol(parents)
  cxPoints <- sample(seq(2, n - 1), size = 2)
  cxPoints <- seq(min(cxPoints), max(cxPoints))
  children <- matrix(as.double(NA), nrow = 2, ncol = n)
  children[, cxPoints] <- parents[, cxPoints]
  j <- 1
  pos <- c((max(cxPoints) + 1):n, 1:(max(cxPoints)))
  val <- setdiff(parents[-j, pos], children[j, cxPoints])
  i <- intersect(pos, which(is.na(children[j,])))
  children[j, i] <- val
  # Drugi potomek - operator PMX
  cxPoints <- sample(1:n, size = 2)
  cxPoints <- seq(min(cxPoints), max(cxPoints))
  children2 <- matrix(as.double(NA), nrow = 2, ncol = n)
  children2[, cxPoints] <- parents[, cxPoints]
  for (i in setdiff(1:n, cxPoints)) {
    if (!any(parents[1, i] == children2[2, cxPoints])) {
      children2[2, i] <- parents[1, i]
    }
  }
  children2[2, is.na(children2[2,])] <- setdiff(parents[1,],
                                                 children2[2,])
  children[2,] = children2[2,]
  out <- list(children = children, fitness = rep(NA, 2))
  return(out)
}

custom.mutation.function <- function(object, parent) {
  mutate <- as.vector(object@population[parent,])
  # Liczba losowych przestawien 
  random_changes <- sample(1:(length(mutate) / 20), 1)
  i <- 1
  while (i <= random_changes) {
    # Losowe miejsca (indeksy) do zamiany
    random_indexes <- sample(1:length(mutate), 2)
    temp <- mutate[random_indexes[1]]
    mutate[random_indexes[1]] <- mutate[random_indexes[2]]
    mutate[random_indexes[2]] <- temp
    i <- i + 1
  }
  return(mutate)
}

# Operatory mutacji
omutation.custom = custom.mutation.function
omutation.default = gaperm_simMutation
omutation.range = c(omutation.custom, gaperm_simMutation, gaperm_ismMutation,
                    gaperm_swMutation, gaperm_dmMutation,
                    gaperm_scrMutation)
omutation.names = c("custom", "sim", "ism", "sw", "dm", "scr")

# Operatory krzyzowania
ocrossover.custom = custom.crossing.function
ocrossover.default = gaperm_oxCrossover
ocrossover.range = c(ocrossover.custom, gaperm_cxCrossover, gaperm_pmxCrossover,
                     gaperm_oxCrossover, gaperm_pbxCrossover)
ocrossover.names = c("custom", "cx", "pmx", "ox", "pbx")





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
scores.plot <- function(y1, y2, y.label = "Wartość funkcji celu") {
  # Create plots for crossover operators
  png(file = "Crossover_best.png")
  barplot(abs(y1), main = "Porównanie operatorów krzyzowania", ylab = y.label, names.arg = ocrossover.names, , col=rainbow(5))
  dev.off()
  png(file = "Crossover_means.png")
  barplot(abs(y2), main = "Porównanie operatorów krzyzowania", ylab = y.label, names.arg = ocrossover.names, , col=rainbow(5))
  dev.off()

  # Create plots for mutation operators
  # png(file = "Mutation_best.png")
  # barplot(abs(y1), main = "Porównanie operatorów mutacji", ylab = y.label, names.arg = omutation.names, col=rainbow(6))
  # dev.off()
  # png(file = "Mutation_means.png")
  # barplot(abs(y2), main = "Porównanie operatorów mutacji", ylab = y.label, names.arg = omutation.names, col = rainbow(6))
  # dev.off()
}

type.name = "permutation"

# experiments for Schuber function
function.name <- "Schubert"

#Function used to test all crossover operators
GA.run.experiment.list(function.name, 10, crossover.range = ocrossover.range)

#Function used to test all mutation operators
# GA.run.experiment.list(function.name, 10, mutation.range = omutation.range)


