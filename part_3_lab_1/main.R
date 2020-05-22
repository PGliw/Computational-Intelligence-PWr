# Title     : Computional Intelligence
# Objective : Examine Genetic Algorithm
# Created by: Piotr
# Created on: 20.05.2020

# plots each generation of GA
monitor <- function(obj)
  {
  contour(objective$x1, objective$x2, objective$values, drawlabels = FALSE, col = grey(0.5))
  title(paste("iteration =", obj@iter), font.main = 1)
  points(obj@population, pch = 20, col = 2)
  Sys.sleep(0.2)
}

# runs GA only once for function given by name with params
# monitor function can be attached to show progress in each generation
GA.run.once <- function(function.name, params, monitor=NULL) {
  default.bounds <- getDefaultBounds(function.name)
  objective.fun <- objective.fun.of(function.name)
  ga(type = "real-valued",
     fitness = function(x) -objective.fun(x[1], x[2]),
     lower = c(default.bounds$lower[1], default.bounds$lower[2]),
     upper = c(default.bounds$upper[1], default.bounds$upper[2]),
     popSize = params$pop.size,
     maxiter = params$max.iter,
     elitism = params$elitism,
     pcrossover = params$pcrossover,
     pmutation = params$pmutation,
     monitor = monitor
  )
}

params <- list(pop.size = 100, max.iter = 100, elitism = 1, pcrossover = 0.8, pmutation = 0.2)
function.name <- "Hosaki"

ga.result <- GA.run.once(function.name, params, monitor)



