# getting the arguments from the commandline
args <- commandArgs(trailingOnly = TRUE)
num  <- as.numeric(args[1])

# return random numbers
rnorm(num)