# Analyze the results and plot
# last edited 2022-04-04 by @vankesteren
# ODISSEI Social Data Science team
library(tidyverse)
library(sf)
library(mgcv)

# load the results & map data
result_tbl <- read_rds("data_processed/result_tbl.rds")
migr_sf <- read_rds("data_processed/migr_sf.rds")


result_tbl <- 
  result_tbl |> 
  group_by(row, iter) |> 
  mutate(res = 1/(1+exp(seq(5, -5, length.out = n()) + rnorm(n(), sd = .1)))) |> 
  ungroup()

# plot one location
result_45 <- result_tbl |> filter(row == 45)

result_45 |> 
  ggplot(aes(x = Ba, y = res)) +
  geom_point()

# create function to compute crossing point where 50% are expected happy
find_fifty <- function(Ba, res) {
  fit_gam <- gam(res ~ s(Ba))
  ba_pred <- seq(0.1, 0.9, length.out = 100)
  pred_gam <- predict(fit_gam, tibble(Ba = ba_pred))
  int_fun <- approxfun(x = ba_pred, y = pred_gam-.5, yleft = -.5, yright = .5)
  out <- tryCatch(uniroot(int_fun, c(0.1, .9)), error = \(e) NA)
  return(out$root)
}

# apply the function per area
res_50 <- 
  result_tbl |> 
  group_by(row) |> 
  summarize(est_fifty = find_fifty(Ba, res))

# add the results to the sf object
migr_sf$est <- res_50$est_fifty

# plot!
migr_sf |> 
  ggplot(aes(fill = est)) +
  geom_sf(col = "transparent") +
  theme_minimal() +
  labs(title = "Nonwestern migrant segregation",
       subtitle = "Agent-based model results", 
       fill = "50% happiness point")

