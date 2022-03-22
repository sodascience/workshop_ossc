# plot results
library(sf)
library(tidyverse)

res <- read_rds("data_processed/res.rds")
migr_sf <- read_rds("data_processed/migr_sf.rds")
migr_sf <- 
  migr_sf |> 
  mutate(h_tot = sapply(res, function(x) {
    ifelse(is.na(x)[1], NA, x$h_tot) # remember na will be returned if
  }))

ggplot(migr_sf) +
  geom_sf(aes(fill = h_tot), col = "transparent") + 
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Total happiness")
