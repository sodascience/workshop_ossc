# Introduction to creating a condition grid in R
# last edited 2022-04-04 by @vankesteren
# ODISSEI Social Data Science team
library(tidyverse)
library(sf)

# Read data ----
# I have prepared a dataset in the data_processed/ folder
migr_sf <- read_rds("data_processed/migr_sf.rds")

# plot: where is nonwestern migration? 
ggplot(migr_sf) +
  geom_sf(aes(fill = nonwest), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Nonwest")

# Create a condition grid ----
# using tidyverse data processing pipeline
grid_tbl <- 
  as_tibble(migr_sf) |> # first, transform to normal data frame from sf object
  mutate(row = 1:n()) |> # then, add row numbers as a column
  select(row, nl, west, nonwest) |> # then, select only row number and proportions
  mutate(
    # add iteration counter (50) and parameter grid as list-columns
    iter = list(1:50),            
    Ba = list(seq(.05, .95, .01))
  ) |> 
  unnest_longer(Ba) |> # unnest parameter grid
  unnest_longer(iter) # unnest iteration number

# write to file
write_rds(grid_tbl, "data_processed/grid_tbl.rds")



# Preview: how to aggregate results from this grid? ----
result_tbl <- grid_tbl |> mutate(result = rnorm(n()))
result <- 
  result_tbl |> 
  group_by(row, Ba) |> # grouping
  summarise(output = mean(result, na.rm = TRUE)) |> # summarizing
  summarise(final = sample(output, 1)) # summarizing further across Ba

# then we can add it to our sf dataset and plot the outcome
migr_sf |> 
  mutate(result = result$final) |> 
  ggplot() +
  geom_sf(aes(fill = result), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Results")


# How many jobs will we need on the supercomputer? ----
# each node has 16 cores
n_cores  <- 16
# each core can estimate about 400 models per minute
mod_rate <- 400
# we want to run each job for about 30 minutes
job_time <- 30
# get final chunk size
chunk_size <- n_cores*mod_rate*job_time

# number of jobs needed:
ceiling(nrow(grid_tbl) / chunk_size)

# 77!
