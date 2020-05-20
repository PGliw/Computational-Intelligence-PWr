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

  function(x1, x2) {
    x1x2 <- c(x1, x2)
    goTest(par = c(x1x2, rep(0, problem.dimen - length(x1x2))), fnName = function.name, checkDim = TRUE)
  }
}

objective.fun.get <- function(function.name) {
  # Default lower and upper bounds (box constraints) for the given objective function
  default.bounds <- getDefaultBounds(function.name)

  x1 <- seq(default.bounds$lower[1], default.bounds$upper[1], by = 0.1)
  x2 <- seq(default.bounds$lower[2], default.bounds$upper[2], by = 0.1)

  # Acutal objective function of given name
  objective.fun <- objective.fun.of(function.name)

  # Apply objective.fun to each pair (x1', x2') where x1' belongs to x1 and x2 belongs to x2
  objective.fun.value <- outer(x1, x2, Vectorize(objective.fun))
  list(x1 = x1, x2 = x2, values = objective.fun.value)
}

# plots function given by name
objective.fun.plot <- function(function.name, axes = {axis(1); axis(2)}) {
  objective.fun <- objective.fun.get(function.name)
  # filled.contour(objective.fun$x1, objective.fun$x2, objective.fun$values, plot.axes={axis(1); axis(2); points(-0.8,-7.7,  pch=3, cex=2, col="black", lwd=4); points(-7.7, -0.8,  pch=3, cex=2, col="black", lwd=4)}, color.palette = jet.colors)
  filled.contour(objective.fun$x1, objective.fun$x2, objective.fun$values, plot.axes=axes, color.palette=jet.colors)
  persp3D(objective.fun$x1, objective.fun$x2, objective.fun$value, theta = 45, phi = 25, expand = 0.5, ticktype = "detailed", axes = TRUE)
}

objective.fun.plot(function.names[1])

# finds global optimums of function given by name
objective.fun.opt.indecies <- function(function.name) {
  objective.fun.value <- (objective.fun.get(function.name))$values
  which(objective.fun.value == min(objective.fun.value), arr.ind = TRUE)
}

# translates indecies into values for function given by name
objective.fun.opt.indecies.translate <- function(matrix.of.idecies, function.name) {
  # Default lower and upper bounds (box constraints) for the given objective function
  default.bounds <- getDefaultBounds(function.name)

  x1 <- seq(default.bounds$lower[1], default.bounds$upper[1], by = 0.1)
  x2 <- seq(default.bounds$lower[2], default.bounds$upper[2], by = 0.1)
  result <- NULL
  add.to.result <- function(row.col) {
    append(result, c(x1[row.col[1]], x2[row.col[2]]))
  }
  apply(matrix.of.idecies, 1, add.to.result)
  result
}

# translates indecies into values for function given by name
objective.fun.opt.indecies.translate.one <- function(indecies, function.name) {
  # Default lower and upper bounds (box constraints) for the given objective function
  default.bounds <- getDefaultBounds(function.name)

  x1 <- seq(default.bounds$lower[1], default.bounds$upper[1], by = 0.1)
  x2 <- seq(default.bounds$lower[2], default.bounds$upper[2], by = 0.1)
  c(x1[indecies[1]], x2[indecies[2]])
}

