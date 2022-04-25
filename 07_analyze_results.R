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
roi_df <- result_tbl |> filter(row %in% c(1700, 14, 268))
pref_plot <- 
  roi_df |> 
  ggplot(aes(x = Ba, y = res, colour = factor(row))) + 
  geom_point(alpha = 0.15) + 
  geom_line(aes(group = iter), alpha = .1) +
  geom_smooth(formula = y ~ s(x, bs = "ps", k = 25, fx = TRUE), method = "gam", colour = "#3030a3") +
  geom_smooth(formula = y ~ 1, method = "lm", colour = "#343434", lty = "dotted", se = FALSE) +
  labs(x = "Preference parameter Ba", y = "Percent of happy nonwestern migrants", 
       title = "Simulated preference vs happiness") +
  xlim(0, 1) +
  theme_minimal() + 
  scale_colour_brewer(type = "qual", guide = "none") +
  facet_wrap(~paste(migr_sf$gemeentenaam[row], migr_sf$wijknaam[row]))

ggsave(plot = pref_plot, filename = "img/pref_plot.png", height = 6, width = 12, bg = "white")
  
# apply the function per area
res_area <- 
  result_tbl |> 
  group_by(row) |> 
  summarize(res = mean(res, na.rm = TRUE))

# add the results to the sf object
migr_sf$est <- res_area$res

# plot on map
segr_map <- 
  migr_sf |> 
  ggplot(aes(fill = est)) +
  geom_sf(col = "transparent") +
  theme_minimal() +
  scale_fill_viridis_c(na.value = "#34343434", guide = "none") +
  labs(title = "Nonwestern migrant segregation",
       subtitle = "Agent-based model results")

ggsave(plot = segr_map, "img/segr_map.png", height = 9, width = 7, bg = "white")
