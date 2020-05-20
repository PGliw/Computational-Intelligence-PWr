# Title     : TODO
# Objective : TODO
# Created by: Piotr
# Created on: 20.05.2020


function.name <- "Schubert"

params <- list(pop.size=50, max.iter=100, elitism=5, pcrossover=0.8, pmutation=0.1)

GA.run.iterations <- function(function.name, iterations.count, params) {
  problem.dimen <- getProblemDimen(function.name)
  default.bounds.matrix <- matrix(unlist(getDefaultBounds(function.name)), ncol=problem.dimen, byrow=TRUE)
  objective.fun <- objective.fun.of(function.name)
  iteration.scores <- NULL # accumulator
  for(iteration in 1:iterations.count) {
    GA <- ga(type = "real-valued",
             fitness = function(x) -objective.fun(x[1], x[2]),
             lower = default.bounds.matrix[1,],
             upper = default.bounds.matrix[2,],
             popSize = params$pop.size,
             maxiter = params$max.iter,
             elitism = params$elitism,
             pcrossover = params$pcrossover,
             pmutation = params$pmutation)
    iteration.scores[iteration] <- objective.fun(GA@solution[,1], GA@solution[,2])
  }
  mean(iteration.scores)
}

res <- GA.run.iterations(function.name, 10, params)



