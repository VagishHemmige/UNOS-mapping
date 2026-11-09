# Purpose: regional maps for the DCD-donor multiorgan heart-transplant study
#   (Madan et al., Clin Transplant 2024).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: dcd_states and maps saved in figures/dcd/.

## ---- dcd-region-summary
# Four measures per region. Column names are the spreadsheet's headers after
# clean_names(). Legend titles are those of the original maps; what each
# percentage is a share of is to be confirmed (SETUP-NOTES.md, D3). The third
# header mentions HCV because it was carried over from the HCV spreadsheet.
dcd_measures <- c(
  number_of_multiorgan_h_ts_using_dcd_donors =
    "Number of transplants",
  percentage_of_total_multiorgan_h_ts_using_dcd_donors_during_study_period =
    "Percentage of transplants",
  total_number_of_multiorgan_h_ts_irrespective_of_donor_hcv_status =
    "Total number of transplants",
  percentage_of_total_multiorgan_h_ts_during_study_period =
    "Percentage of transplants"
)

dcd_file <- file.path(region_data_dir, region_files$dcd)

if (!file.exists(dcd_file)) {
  dcd_summary <- make_synthetic_region_summary(names(dcd_measures))
} else {
  dcd_summary <- read_region_summary(
    dcd_file,
    percent_columns = c(
      "percentage_of_total_multiorgan_h_ts_using_dcd_donors_during_study_period",
      "percentage_of_total_multiorgan_h_ts_during_study_period"
    )
  )
}

dcd_states <- join_region_values(region_states, dcd_summary)

## ---- dcd-maps
for (measure in names(dcd_measures)) {
  dcd_ggplot <- map_regions_ggplot(
    dcd_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = dcd_measures[[measure]],
    centers = heart_centers,
    palette = fill_palette,
    na_fill = missing_fill,
    crs = map_crs
  )
  dcd_tmap <- map_regions_tmap(
    dcd_states, region_outlines, region_labels,
    fill_var = measure,
    legend_title = dcd_measures[[measure]],
    centers = heart_centers,
    inset_bbox = northeast_bbox,
    palette = fill_palette,
    na_fill = missing_fill
  )
  save_region_maps(
    dcd_ggplot, dcd_tmap,
    study = "dcd",
    name = measure,
    width = figure_width,
    height = figure_height
  )
}
