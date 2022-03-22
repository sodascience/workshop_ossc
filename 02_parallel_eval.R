# script that runs job in parallel
library(tidyverse)
library(parallel)

n_cores <- 10
chunk_size <- 30*9*6 # thirty iters per condition, 9 pref values, 6 areas
grid_tbl <- readRDS("data_processed/grid_tbl.rds")[1:chunk_size,]

# let's only do the fi
# start the cluster
clus <- makeCluster(n_cores)
out <- clusterExport(clus, "grid_tbl")
out <- clusterEvalQ(clus, source("./src/schelling_cpp.R"))

res <- parSapplyLB(
  cl = clus, 
  X = 1:nrow(grid_tbl), 
  FUN = function(i) {
    pars <- as.list(grid_tbl[i,])
    output <- abm_cpp(
      prop = c(pars$nl, pars$west, pars$nonwest),
      Ba = pars$Ba
    )
    output$h_prop[3]
  }
)

stopCluster(clus)


grid_tbl$y <- res

grid_summary <- 
  grid_tbl |> 
  group_by(row, Ba) |> 
  summarize(y = mean(y))

grid_summary |> 
  left_join(migr_sf |> mutate(row = 1:n()) |> select(row, wijknaam, gemeentenaam)) |> 
  ggplot(aes(x = Ba, y = y, colour = paste(gemeentenaam, wijknaam))) +
  geom_point() +
  geom_line() +
  scale_colour_viridis_d() +
  theme_minimal() +
  labs(x = "Neighbourhood similarity desire", 
       y = "Happiness of non-western group",
       colour = "Area",
       title = "Happiness of non-western groups differs per neighbourhood.")

