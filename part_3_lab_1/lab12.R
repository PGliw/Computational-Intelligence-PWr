# Title     : TODO
# Objective : TODO
# Created by: Piotr
# Created on: 20.05.2020

# dependencies
require("GA")
require("globalOptTests")

function.names <- c("Schubert", "Hosaki")

# returns objective function given by name
objective.fun.of <- function(function.name) {
  # Get the length of the parameter vector expected by a given objective function.
  problem.dimen <- getProblemDimen(function.name)

  function (x1, x2) {
    x1x2 <- c(x1, x2)
    goTest(par = c(x1x2, rep(0, problem.dimen - length(x1x2))), fnName = function.name, checkDim = TRUE)
  }
}

objective.fun.plot <- function(function.name) {
  # Default lower and upper bounds (box constraints) for the given objective function
  default.bounds <- getDefaultBounds(function.name)

  x1 <- seq(default.bounds$lower[1], default.bounds$upper[1], by = 0.1)
  x2 <- seq(default.bounds$lower[2], default.bounds$upper[2], by = 0.1)

  # Acutal objective function of given name
  objective.fun <- objective.fun.of(function.name)

  # Apply objective.fun to each pair (x1', x2') where x1' belongs to x1 and x2 belongs to x2
  objective.fun.value <- outer(x1, x2, Vectorize(objective.fun))

  filled.contour(x1, x2, objective.fun.value, color.palette = jet.colors)
  persp3D(x1, x2, objective.fun.value, theta = 45, phi = 25, expand = 0.5, ticktype = "detailed", axes = TRUE)
  points3d(-15, -10, 0)
}

# objective.fun.plot(function.names[2])

