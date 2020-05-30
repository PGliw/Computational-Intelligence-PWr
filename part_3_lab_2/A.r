require("GA")
require("globalOptTests")

# Nazwa badanej funkcji
function.name = "Schubert"
# Liczba iteracji dla usredniania wynikow
test.iterations = 1
# Rozmiar populacji
popSize.default = 50
# Liczba generacji
maxiter.default = 100
# Selekcja elitarna
elitism.default = 0.05
# Prawdopodobienstwo krzyzowania
pcrossover.default = 0.8
# Prawdopodobienstwo mutacji
pmutation.default = 0.1

# Operatory mutacji
omutation.custom = custom.mutation.function
omutation.default = gaperm_simMutation
omutation.range = c(gaperm_simMutation, gaperm_ismMutation,
                    gaperm_swMutation, gaperm_dmMutation,
                    gaperm_scrMutation)
omutation.names = c("custom", "sim", "ism", "sw", "dm", "scr")

# Operatory krzyzowania
ocrossover.custom = custom.crossing.function
ocrossover.default = gaperm_oxCrossover
ocrossover.range = c(gaperm_cxCrossover, gaperm_pmxCrossover,
                     gaperm_oxCrossover, gaperm_pbxCrossover)
ocrossover.names = c("custom", "cx", "pmx", "ox", "pbx")
oselection.default = gaperm_lrSelection


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
objective.fun.plot <- function(function.name, axes = { axis(1); axis(2) }) {
  objective.fun <- objective.fun.get(function.name)
  # jpeg("Schubert2D.jpeg")
  # filled.contour(objective.fun$x1, objective.fun$x2, objective.fun$values, plot.axes = axes, color.palette = jet.colors)
  # dev.off()
  # jpeg("Schubert3D.jpeg")
  # persp3D(objective.fun$x1, objective.fun$x2, objective.fun$value, theta = 45, phi = 25, expand = 0.5, ticktype = "detailed", axes = TRUE, xlab = "x1", ylab="x2", zlab="f(x1, x2)")
  # dev.off()
}



drawPlot <- function(results, names, title) {
  dev.new()
  y_limit <- c(min(results), max(results))
  for (i in 1:length(results[1, ])) {
    plot(((101 - length(results[, i])):100), results[, i], type = "l",
         col = (9 * i), xaxt = 'n', yaxt = 'n', xlab = '', ylab = '',
         lwd = 2, ylim = y_limit)
    par(new = TRUE)
  }
  axis(side = 2)
  axis(side = 1)
  title(main = title, xlab = "Generacja (iteracja)",
        ylab = "Wartość funkcji")
  legend(x = "bottomright", names, col = (1:length(names)) * 9,
         lty = c(1), bg = "gray90")
  par(new = FALSE)
}

# Funkcja usredniajaca wyniki w kazdej generacji (iteracji)
avgGenerations <- function(o.mutation, o.crossover) {
  default.bounds <- getDefaultBounds(function.name)
  objective.fun <- objective.fun.of(function.name)
  solution <- matrix(0, maxiter.default, 6)
  GA <- NULL
  for (i in 1:test.iterations) {
    GA <- ga("permutation", function(x) - objective.fun(x[1], x[2]),
             lower = c(default.bounds$lower[1], default.bounds$lower[2]),
             upper = c(default.bounds$upper[1], default.bounds$upper[2]),
             popSize = popSize.default, 
             maxiter = maxiter.default,
             pmutation = pmutation.default, 
             pcrossover = pcrossover.default,
             mutation = o.mutation, 
             crossover = o.crossover,
             selection = oselection.default, 
             elitism = elitism.default)
    solution = solution + GA@summary
  }
  return(solution / test.iterations)
}

##### Testy operatorow mutacji #####
test.omutation <- function() {
  # Test wlasnego operatora
  results.omutation <- NULL
  results.omutation =
    data.frame(custom = avgGenerations(custom.mutation.function,
                                       ocrossover.default)[, 1])
  # Testy wbudowanych operatorow
  i <- 2
  for (omutation in omutation.range) {
    results.omutation[omutation.names[i]] <-
      avgGenerations(omutation,
                     ocrossover.default)[, 1]
    i <- i + 1
  }
  drawPlot(results.omutation, omutation.names,
           "Porównanie operatorów mutacji")
}

##### Testy operatorow mutacji #####
test.ocrossover <- function() {
  # Test wlasnego operatora
  results.omutation <- NULL
  results.omutation =
    data.frame(custom = avgGenerations(omutation.default,
                                       custom.crossing.function)[, 1])
  # Testy wbudowanych operatorow
  i <- 2
  for (omutation in omutation.range) {
    results.omutation[ocrossover.names[i]] <-
      avgGenerations(omutation.default,
                     omutation)[, 1]
    i <- i + 1
  }
  drawPlot(results.omutation, ocrossover.names,
           "Porównanie operatorów mutacji")
}

# objective.fun.plot("Schubert")

test.omutation()
# test.ocrossover()