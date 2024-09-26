# Combine the results from the different files
# last edited 2022-04-04 by @vankesteren
# ODISSEI Social Data Science team
library(tidyverse)

# read the parameter grid into memory
grid_tbl <- read_rds("data_processed/grid_tbl.rds")
n_total <- nrow(grid_tbl)

# add new column for output
grid_tbl <- grid_tbl %>% mutate(res = NA_real_)


# fill the new columns with info from array job files
files <- list.files("output", full.names = TRUE)

# just a small check: are we missing any output files?
all(diff(parse_number(files)) == 1)

# get chunk size for first file
chunk_size <- length(read_rds(files[1]))

for (fn in files) {
  cat(fn, "\n")
  # get the task_id from the file name
  task_id <- parse_number(fn)
  # determine which rows this result belongs to
  chunk_start <- ((task_id - 1)*chunk_size + 1)
  chunk_end <- min(task_id*chunk_size, n_total)
  # add the result to the grid
  grid_tbl[chunk_start:chunk_end, 7] <- read_rds(fn)
}

# write the results to disk
write_rds(grid_tbl, "data_processed/result_tbl.rds")
