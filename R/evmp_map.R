# Purpose: regional map for the ex vivo machine perfusion study in DBD heart
#   transplantation (Madan et al., J Card Fail 2025).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: evmp_states and maps saved in figures/evmp/.

## ---- evmp-region-summary
# Percentage from the regional spreadsheet, the measure the original map
# showed. The spreadsheet stores proportions, shown here as percentages.
# Legend title as in the original map; its exact meaning is to be confirmed (D3).
evmp_measures <- c(
  percentage = "Percentage of transplants"
)

evmp_file <- file.path(region_data_dir, region_files$evmp)

if (!file.exists(evmp_file)) {
  evmp_summary <- make_synthetic_region_summary(names(evmp_measures))
} else {
  evmp_summary <- read_region_summary(
    evmp_file,
    percent_columns = "percentage"
  )
}

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
    inset_bbox = northeast_bbox,
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
