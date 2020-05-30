# runs GA only once for function given by name with params
# monitor function can be attached to show progress in each generation
GA.run.once <- function(function.name, method.name) {
  default.bounds <- getDefaultBounds(function.name)
  objective.fun <- objective.fun.of(function.name)
  ga(type = "real-valued",
     fitness = function(x) - objective.fun(x[1], x[2]),
     lower = c(default.bounds$lower[1], default.bounds$lower[2]),
     upper = c(default.bounds$upper[1], default.bounds$upper[2]),
     optim = TRUE, optimArgs = list(method = method.name)
  )
}

function.name <- "Schubert"

methods.names <- c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN")

# ga.result <- GA.run.once(function.name, method)
# png(paste(method, ".png"))
# plot(ga.result)
# dev.off()


for (method in methods.names) {
    ga.result <- GA.run.once(function.name, method)
    png(paste(method, ".png"))
    plot(ga.result)
    dev.off()
}
