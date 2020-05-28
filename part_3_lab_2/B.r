require("TSP")
tsplib.dir.path = "C:/Users/dawid/Desktop/Semestr 3/Computational-Intelligence-PWr/part_3_lab_2/TSPfiles"

# Lista testowanych instancji TSPLib
tsplib.file.instances <- list(
  read_TSPLIB(paste(tsplib.dir.path, "berlin52.tsp", sep = "/")),
  read_TSPLIB(paste(tsplib.dir.path, "brazil58.tsp", sep = "/"))
)

tsp.fit.function <- function(x, instance) {
  tour <- TOUR(x, tsp = instance)
  return(tour_length(tour))
}

print(tsplib.file.instances)