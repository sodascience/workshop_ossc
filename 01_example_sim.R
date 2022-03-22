# Introduction to schelling agent-based model and its parameters
# last edited 2022-03-22 by @vankesteren
# ODISSEI Social Data Science team

# I have pre-programmed a function that runs a schelling model
source("./src/schelling.R")

# The function is as follows:
result <- abm(
  prop = c(0.5, 0.5), # the proportions of the populations
  free = 0.25,        # the number of free cells in the grid
  Ba   = 0.4,         # desired perc. of similar neighbours
  R    = 1L,          # neighbourhood radius
  N    = 51L,         # grid size, each side is N cells big
  iter = 30L,         # number of iterations to run
  anim = TRUE         # whether to show an animation (slow!)
)

# what percentage of the subpopulations is happy?
result$h_prop

# what else is in the result?
str(result)

# what if we have more populations and a smaller percentage?
result <- abm(c(.6, 0.2, 0.1, 0.1), Ba = .33, iter = 200)
plot_state(result$M)

# ok, that took some time! 
# we may need to speed this up. 
# I've programmed the same function in c++
# if you don't have Rcpp installed, install it with
# install.packages("Rcpp")
source("src/schelling_cpp.R")

# cpp version is ~8 times faster
result <- abm_cpp(prop = c(.6, 0.2, 0.1, 0.1), Ba = .33, iter = 200)
plot_state(result$M)


# let's iterate longer
result <- abm_cpp(c(.6, 0.2, 0.1, 0.1), anim = FALSE, Ba = .33, iter = 3000)
plot_state(result$M)
# majority population stays spread out, minorities form cliques
result$h_prop

