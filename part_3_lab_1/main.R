#---------------functions-------------------

f <- function(x) goTest(
  par = c(x),
  fnName = funcName,
  checkDim = TRUE)

print <- function(x, y, pos, lab){
  dev.new()
  plot(x, y, type = "o", col = "blue", ylab = "avg and standard deviation", xlab = lab)
  lines(currentParam, sigma1, type = "l", col = "gray")
  lines(currentParam, sigma2, type = "l", col = "gray")
  tmp <- rep(0,length(currentParam))
  lines(currentParam, tmp, type = "l", col = "green")
  legend(pos, c("mean","standard deviation", "extremum"), fill =c ("blue","gray","green"))
  dev.copy(png, fileName,width = 1366, height = 685, units="px")
  dev.off()
}

#---------------------------------


funcName <- "MultiGaus"
dim <- getProblemDimen(funcName)
Bounds <- matrix( unlist( getDefaultBounds(funcName)), ncol=dim, byrow=TRUE)

populations = seq(10, 150, 10)
populationSize <- 50

iterations = seq(10, 150, 10)
iteration <- 100

mutations = seq(0, 1, 0.2)
mutation <- 0.1

crossProb = seq(0, 1, 0.2)
crossp = 0.8

elits = seq(0, 100, 5)
elit <- 5

currentParam = crossProb        # changeable
paramName = "crossing&mutation"
fileName = paste("io\\",funcName, paramName, ".png")
testIter <- length(crossProb)
testIter2 <- length(mutations)
insiderIter = 10

results <- rep (0, 1)
avgResults <- rep (0, testIter)
sdValue <- rep (0, testIter)
solutionStore <- matrix (0, nrow = testIter*testIter2*insiderIter , ncol = 2)

for(i in 1:testIter)
  {
  #populationSize = populations[i] 
  #iteration = iterations[i] 

  crossp = crossProb[i]
  #elit = elits[i]

  for(j in 1:testIter2){
    mutation = mutations[j]

    for (h in 1: insiderIter) {

      GA <- ga(type = "real-valued",
               fitness = function(x) -f(x),
               lower = c(Bounds[1,]),
               upper = c(Bounds[2,]),
               popSize = populationSize,
               maxiter = iteration,
               elitism = elit,
               pcrossover = crossp,
               pmutation = mutation)

      results[j] = -GA@fitnessValue
      index = (i-1)*insiderIter+j
      solutionStore[index,] <- GA@solution
    }
  }
  avgResults[i] <- mean(results)
  sdValue[i] <- sd(results)
}

cpt <- outer(
  crossProb,
  mutations,
  Vectorize(function(x,y) f(c(x,y))
  ))

dev.new()
filled.contour(
  crossProb,
  mutations,
  cpt,
  color.palette = bl2gr.colors,
  xlab = "crossing probability",
  ylab = "mutation probability"
)

#sigma1 <- avgResults-sdValue
#sigma2 <- avgResults+sdValue

#print(currentParam, avgResults, "topright", paramName)


x <- seq(Bounds[1,1], Bounds[2,1], by = 0.1)
y <- seq(Bounds[1,2], Bounds[2,2], by = 0.1)
z <- outer(x, y, Vectorize(function(x,y) f(c(x,y))))




