# Purpose: regional maps for the HCV-donor multiorgan heart-transplant study
#   (Madan et al., J Heart Lung Transplant 2021).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: hcv_states and maps saved in figures/hcv/.

## ---- hcv-region-summary
# Percentage_HT_HCV from the regional spreadsheet, the measure the original
# map showed. The spreadsheet stores proportions, shown here as percentages.
# The original map had no legend title; this one is to be confirmed (D3).
hcv_measures <- c(
  percentage_ht_hcv = "Percentage of transplants"
)

hcv_file <- file.path(region_data_dir, region_files$hcv)

if (!file.exists(hcv_file)) {
  hcv_summary <- make_synthetic_region_summary(names(hcv_measures))
} else {
  hcv_summary <- read_region_summary(
    hcv_file,
    percent_columns = c("percentage_ht_hcv", "percentage_ht_total")
  )
}

hcv_states <- join_region_values(region_states, hcv_summary)

## ---- hcv-maps
for (measure in names(hcv_measures)) {
  hcv_ggplot <- map_regions_ggplot(
    hcv_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = hcv_measures[[measure]],
    centers = heart_centers,
    palette = fill_palette,
    na_fill = missing_fill,
    crs = map_crs
  )
  hcv_tmap <- map_regions_tmap(
    hcv_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = hcv_measures[[measure]],
    centers = heart_centers,
    inset_bbox = northeast_bbox,
    palette = fill_palette,
    na_fill = missing_fill
  )
  save_region_maps(
    hcv_ggplot, hcv_tmap,
    study = "hcv",
    name = measure,
    width = figure_width,
    height = figure_height
  )
}
