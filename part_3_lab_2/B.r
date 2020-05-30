require("TSP")
require("GA")

tsplib.dir.path = "part_3_lab_2/TSPfiles"

params <- list(pop.size = 100, max.iter = 100, elitism = 0, pcrossover = 0.8, pmutation = 0.2)
param.names.and.labels <- list(
  names = c("pop.size", "max.iter", "elitism", "pcrossover", "pmutation"),
  labels = c("Rozmiar populacji", "Liczba pokoleń", "Poziom elityzmu", "Prawdopodobieństwo krzyżowania", "Prawdopodobieństwo mutacji")
)
param.value.ranges <- list(
  pop.size = c(1, 2, 3, 4, 5, 7, 10, 15, 20, 30, 40, 60, 80, 100, 140, 160),
  max.iter = c(1, 2, 3, 4, 5, 7, 10, 15, 20, 30, 40, 60, 80, 100, 140, 160),
  elitism = c(0, 1, 2, 3, 4, 5, 10, 15, 20, 30, 40, 60, 80, 100),
  pcrossover = seq(0, 1, by = 0.1),
  pmutation = seq(0, 1, by = 0.1)
)

# List of tested instances from TSPlib library
tsplib.file.instances <- list(
  read_TSPLIB(paste(tsplib.dir.path, "dantzig42.tsp", sep = "/")),
  read_TSPLIB(paste(tsplib.dir.path, "brazil58.tsp", sep = "/"))
)

tsp.fit.function <- function(x, instance) {
  tour <- TOUR(x, tsp = instance)
  return(tour_length(tour))
}

# runs function genetic algorithm for function given by name iterations.count times
# params is list that contains params for genetic algorithm
GA.run.iterations <- function(instance, iterations.count, params) {
  iteration.mean.scores <- NULL # accumulator for mean results in each iteration
  iteration.best.scores <- NULL # accumulator for best results in each iteration
  for (iteration in 1:iterations.count) {
    GA <- ga(type = "permutation",
             function(x) - tsp.fit.function(x, instance),
             lower = 1,
             upper = n_of_cities(instance),
             popSize = params$pop.size,
             maxiter = params$max.iter,
             elitism = params$elitism,
             pcrossover = params$pcrossover,
             pmutation = params$pmutation)
    iteration.best.scores[iteration] <- -GA@fitnessValue # objective.fun(GA@solution[, 1], GA@solution[, 2])
    # iteration.mean.scores[iteration] <- mean(apply(GA@population, 1, function(x1x2) { objective.fun(x1x2[1], x1x2[2]) }))
  }
  list(best.mean = mean(iteration.best.scores), mean.mean = mean(iteration.mean.scores), iteration.best.scores = iteration.best.scores)
}

# runs experiment for every param.name value in param.range
GA.run.experiment <- function(function.name, iterations.count, params, param.name, param.range) {
  param.best.scores <- NULL # accumulator for best mean results in generation
  param.mean.scores <- NULL # accumulator for mean mean results in generation
  # GA.best <- NULL # best result
  for (param.value.index in seq_along(param.range)) {
    params[[param.name]] <- param.range[param.value.index]
    param.score <- GA.run.iterations(function.name, iterations.count, params)
    param.best.scores[param.value.index] <- param.score$best.mean
    param.mean.scores[param.value.index] <- param.score$mean.mean
  }
  list(best.scores = param.best.scores, mean.scores = param.mean.scores)
}

# runs experiments as a batch
GA.run.experiment.list <- function(function.name, param.names.and.labels, param.value.ranges, iterations.count = 10) {
  for (param.index in seq_along(param.names.and.labels$names)) {
    param.name <- param.names.and.labels$names[param.index]
    param.value.range <- param.value.ranges[[param.name]]
    param.score.range <- GA.run.experiment(function.name, iterations.count, params, param.name, param.value.range)
    scores.plot(
      x = param.value.range,
      y1 = param.score.range$best.scores,
      y2 = param.score.range$mean.scores,
      x.label = param.names.and.labels$labels[param.index]
    )
  }
}

#plots best (y1) and mean (y2) scores for each param value x
scores.plot <- function(x, y1, y2, const, x.label, y.label = "Wartość funkcji celu") {
  png(file = paste(x.label, ".png"))
  matplot(x, cbind(y1, y2), col = c("green", "blue"), type = c("o", "o"), pch = 1:2, xlab = x.label, ylab = y.label)
  dev.off()
}

for (instance in tsplib.file.instances) {
  GA.run.experiment.list(instance, param.names.and.labels, param.value.ranges)
}
