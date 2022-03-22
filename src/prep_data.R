library(tidyverse)
library(sf)
library(patchwork)
wb_url <- "WFS:https://service.pdok.nl/cbs/wb2021/wfs/v1_0"
wijk_sf <- st_read(wb_url, layer = "wb2021:wijken")
wijk_sf <- 
  wijk_sf |> 
  mutate(across(starts_with("percentage"), na_if, -99999999)) |> 
  filter(oppervlakteLandInHa > 0)

migr_sf <- 
  wijk_sf |> 
  select(wijkcode, wijknaam, gemeentecode, gemeentenaam, west = percentageWesterseMigratieachtergrond, nonwest = percentageNietWesterseMigratieachtergrond) |> 
  mutate(
    west = west/100,
    nonwest = nonwest/100,
    nl = 1 - west - nonwest
  )

pl_nl <- 
  ggplot(migr_sf) +
  geom_sf(aes(fill = nl), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "NL")

pl_west <- 
  ggplot(migr_sf) +
  geom_sf(aes(fill = west), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "West")

pl_nonwest <- 
  ggplot(migr_sf) +
  geom_sf(aes(fill = nonwest), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Nonwest")

ggsave(plot = pl_nl + pl_west + pl_nonwest, "img/migr_plot.png", width = 15, height = 9)

grid_tbl <- 
  as_tibble(migr_sf) |> 
  mutate(row = 1:n()) |> 
  select(row, nl, west, nonwest) |> 
  mutate(iter = list(1:30), Ba = list(seq(0.1, 0.9, .1))) |> 
  unnest_longer(Ba) |> 
  unnest_longer(iter)

write_rds(migr_sf, "data_processed/migr_sf.rds")
write_rds(grid_tbl, "data_processed/grid_tbl.rds")
