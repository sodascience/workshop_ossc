# Introduction to running a slow function in parallel in R
# last edited 2024-09-04 by @vankesteren
# ODISSEI Social Data Science team
library(tidyverse)
library(pbapply)
library(parallel)
source("./src/schelling_cpp.R")

# Create an analysis function ----
# let's create a function that returns a number of interest
analysis_function <- function(x) {
  
  # we run the abm with certain parameters
  output <- abm_cpp(
    prop = c(.69, .19, .12),
    Ba = 0.6
  )
  
  # we find out how happy the smallest group is
  return(output$h_prop[3])
  
}

# Run the function 300 times using the "apply" family of functions
# Apply is a short, functional version of a "for loop".
res <- pbsapply(X = 1:300, FUN = analysis_function)

# plot
res |> 
  tibble() |> 
  ggplot() + 
  geom_histogram(aes(x = res), fill = "#345534", bins = 40) + 
  theme_minimal() +
  labs(x = "Happiness", y = "Count", title = "Variation in happiness", 
       subtitle = "Variation over 300 runs of our ABM")

# what is the mean happiness?
mean(res)

# that's pretty slow! let's see if we can speed this up.
# we will use the parallel package

# Run the abm in parallel ----
# first, figure out how many logical cores (threads) you have
detectCores()

# I have 12 threads (logical cores) available on my machine so 
# I use 10 threads to leave some computing power for other tasks.
n_threads <- 10 

# create the cluster
clus <- makeCluster(n_threads) 

# then, we load the abm code on each of the threads
out <- clusterEvalQ(clus, source("./src/schelling_cpp.R"))

# now, we run the function in parallel
res_parl <- pbsapply(X = 1:300, FUN = analysis_function, cl = clus)

# we can also use "load-balancing" (LB) which can deal with
# the fact that runs can take differing amounts of time
# (at the cost of a little more overhead than non-load-balancing)
res_parl <- parSapplyLB(
  cl = clus,
  X = 1:300,
  FUN = analysis_function
)

# important step! stop the cluster to free up resources.
stopCluster(clus)

# plot
res_parl |> 
  tibble() |> 
  ggplot() + 
  geom_histogram(aes(x = res_parl), fill = "#345534", bins = 40) + 
  theme_minimal() +
  labs(x = "Happiness", y = "Count", title = "Variation in happiness", 
       subtitle = "Variation over 300 runs of our ABM")

# what is the mean happiness?
mean(res_parl)
