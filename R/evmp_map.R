# Purpose: regional map for the ex vivo machine perfusion study in DBD heart
#   transplantation (Madan et al., J Card Fail 2025).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: evmp_summary, evmp_states and maps saved in figures/evmp/.

## ---- evmp-region-summary
# DBD heart transplants by UNOS region, January 2020 to June 2024: all of
# them, and those using ex vivo machine perfusion (EVMP). The totals (12,363
# and 561) are the paper's. The percentage is the share of each region's own
# DBD transplants that used EVMP, as in the regional spreadsheet the original
# map read.
evmp_summary <- tibble::tribble(
  ~region,     ~n_dbd, ~n_evmp,
  "Region 1",     577,      79,
  "Region 2",    1247,      19,
  "Region 3",    1523,      66,
  "Region 4",    1109,      27,
  "Region 5",    1993,      61,
  "Region 6",     399,      21,
  "Region 7",    1069,      53,
  "Region 8",     849,      10,
  "Region 9",     958,      56,
  "Region 10",    952,      40,
  "Region 11",   1687,     129
) |>
  mutate(pct_evmp = 100 * n_evmp / n_dbd)

evmp_measures <- c(
  pct_evmp = "DBD HTs in the region\nusing EVMP (%)"
)

evmp_states <- join_region_values(region_states, evmp_summary)

## ---- evmp-maps
for (measure in names(evmp_measures)) {
  evmp_ggplot <- map_regions_ggplot(
    evmp_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = evmp_measures[[measure]],
    centers = heart_centers,
    palette = fill_palette,
    na_fill = missing_fill,
    crs = map_crs
  )
  evmp_tmap <- map_regions_tmap(
    evmp_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = evmp_measures[[measure]],
    centers = heart_centers,
    inset_bbox = corridor_bbox,
    palette = fill_palette,
    na_fill = missing_fill
  )
  save_region_maps(
    evmp_ggplot, evmp_tmap,
    study = "evmp",
    name = measure,
    width = figure_width,
    height = figure_height
  )
}
