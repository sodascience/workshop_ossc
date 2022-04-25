# Analyze the results and plot
# last edited 2022-04-04 by @vankesteren
# ODISSEI Social Data Science team
library(tidyverse)
library(sf)
library(mgcv)

# load the results & map data
result_tbl <- read_rds("data_processed/result_tbl.rds")
migr_sf <- read_rds("data_processed/migr_sf.rds")

# look at 1 area
roi_df <- result_tbl |> filter(row == 1)
pref_plot <- 
  roi_df |> 
  ggplot(aes(x = Ba, y = res)) + 
  geom_point(alpha = 0.2, colour = "#499293") + 
  geom_line(aes(group = iter), alpha = .2, colour = "#499293") +
  labs(x = "Preference parameter Ba", y = "Percent of happy nonwestern migrants", 
       title = "Simulated preference vs happiness", subtitle = "In Groningen Centrum") +
  xlim(0, 1) +
  ylim(0, 1) +
  theme_minimal()
pref_plot

# add smooth fit line
pref_plot + 
  geom_smooth(formula = y ~ s(x, bs = "ps", k = 25, fx = TRUE), method = "gam", colour = "#3030a3")

# create function to compute crossing point where 50% are expected happy
find_fifty <- function(Ba, res) {
  if (sum(is.na(res)) > 4000) return(NA)
  fit_gam <- gam(res ~ s(Ba, bs = "ps", k = 25, fx = TRUE))
  ba_pred <- seq(0.1, 0.9, length.out = 100)
  pred_gam <- predict(fit_gam, tibble(Ba = ba_pred))
  if (all(pred_gam > .5)) return(NA)
  if (all(pred_gam < .5)) return(NA)
  int_fun <- approxfun(x = ba_pred, y = pred_gam-.5, yleft = -.5, yright = .5)
  out <- tryCatch(uniroot(int_fun, c(0.1, .9)), error = \(e) list(root=NA))
  return(out$root)
}

# test function on area
fiftypercent <- find_fifty(roi_df$Ba, roi_df$res)
pref_plot + 
  geom_smooth(formula = y ~ s(x, bs = "ps", k = 25, fx = TRUE), method = "gam", colour = "#3030a3") +
  geom_vline(xintercept = fiftypercent, lty = 1, colour = "#343434") +
  geom_hline(yintercept = 0.5, lty = 2, colour = "#343434")
  
# apply the function per area
res_50 <- 
  result_tbl |> 
  group_by(row) |> 
  summarize(est_fifty = find_fifty(Ba, res))

# add the results to the sf object
migr_sf$est <- res_50$est_fifty

# plot!
migr_sf |> 
  ggplot(aes(fill = replace_na(est, 1))) +
  geom_sf(col = "transparent") +
  theme_minimal() +
  scale_fill_viridis_c(na.value = "#34343434") +
  labs(title = "Nonwestern migrant segregation",
       subtitle = "Agent-based model results", 
       fill = "50% happiness point")

