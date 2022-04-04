#!/usr/bin/env Rscript

# usage: Rscript 04_array_job.R $SLURM_ARRAY_TASK_ID

# Fully encapsulated R analysis program which does the following:
# - get the array job number from commandline arguments
# - determine which chunk should be computed by this number
# - load that chunk of the condition grid in memory
# - run the function for this chunk
# - save the output
# - write a log as well!

# last edited 2022-04-04 by @vankesteren
# ODISSEI Social Data Science team

# Logging setup ----
# start with a small logging function
plog <- function(...) cat(format(Sys.time()), "|", ..., "\n")

# log the start of the script
start <- Sys.time()
plog("Starting the abm analysis.")


# Packages ----
plog("Loading packages & ABM code...")
library(tidyverse)
library(parallel)
source("src/schelling_cpp.R")
plog("Packages & ABM code loaded.")

# Load data ----
plog("Loading ABM parameter grid...")
grid_tbl <- read_rds("data_processed/grid_tbl.rds")
plog("Parameter grid loaded.")

# Chunking ----
# first we compute how many models to run on this node
plog("Computing chunks")
# each node has 24 cores, run for about 10 minutes
n_cores  <- 24
# each core can estimate about 25 models per second
mod_rate <- 25
# we want to run each job for about 10 minutes (600 seconds)
job_time <- 600
# get final chunk size
chunk_size <- n_cores*mod_rate*job_time

# then we get the current task id and assign the right chunk to the current job
task_id     <- parse_integer(commandArgs(trailingOnly = TRUE)[1])
n_total     <- nrow(grid_tbl)
chunk_start <- ((task_id - 1)*chunk_size + 1)
chunk_end   <- min(task_id*chunk_size, n_total)
plog("Running ABM for grid row", chunk_start, "to", chunk_end)

# subset the parameter grid so it's only the chunks we need
grid_tbl <- grid_tbl[chunk_start:chunk_end,]

# Analysis function creation ----
# Again, it really depends on what you are doing.
# I'll output a single number for each row in the grid:
# The simulated proportion of happy nonwestern migrants
analysis_function <- function(row) {
  # Get the parameters belonging to this row
  settings <- as.list(grid_tbl[row,])
  
  # compute the proportion of happy nonwestern migrants
  # use trycatch to avoid crashing. This is important otherwise
  # you will have a lot of problems with underused compute!
  out <- tryCatch(
    # this is the expression to evaluate
    expr = {
      prop_vec <- c(settings$nl, settings$west, settings$nonwest)
      res <- abm_cpp(prop = prop_vec, Ba = settings$Ba)
      return(res$h_prop[3])
    }, 
    # if there is an error, return NA as output!
    error = function(e) return(NA)
  )
  
  return(out)
}

# Cluster creation ----
# On the supercomputer, we can make a FORK cluster
# this way we don't have to copy data over to the 
# child threads! This is possible for UNIX systems.
# With Fork clusters, cluster nodes have all data 
# from the main thread automatically. 
plog("Making FORK cluster...")
clus <- makeForkCluster(n_cores)
plog("Cluster successfully created.")

# compute model with load-balancing parallel apply
plog("Running", chunk_size, "ABM simulations...")
out <- parSapplyLB(
  cl  = clus, 
  X   = chunk_start:chunk_end, 
  FUN = analysis_function
)
plog("Simulations done!")

# stop the cluster
stopCluster(clus)

# Storing ----
plog("Storing output...")
file_name <- paste0("results_", str_pad(task_id, 5, pad = "0"), ".rds")
write_rds(out, paste0("output/", file_name))
plog("Output stored!")
plog("Elapsed time:", format(Sys.time() - start))

# done, end of script