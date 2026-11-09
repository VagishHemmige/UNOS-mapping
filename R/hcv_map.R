# Purpose: regional maps for the HCV-donor multiorgan heart-transplant study
#   (Madan et al., J Heart Lung Transplant 2021).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: hcv_summary, hcv_states, tables/hcv_regions.csv and maps
#   saved in figures/hcv/.

## ---- hcv-region-summary
# Multiorgan heart transplants by UNOS region, August 2015 to August 2020:
# those using HCV donors, and all of them. The totals (109 and 1,322) are the
# paper's. Percentages are each region's share of the national count, as in
# the regional spreadsheet the original map read.
hcv_summary <- tibble::tribble(
  ~region,     ~n_hcv, ~n_total,
  "Region 1",      10,       53,
  "Region 2",       6,      107,
  "Region 3",       5,      125,
  "Region 4",       2,      143,
  "Region 5",      15,      358,
  "Region 6",       4,       20,
  "Region 7",       4,      143,
  "Region 8",       1,       33,
  "Region 9",      17,       91,
  "Region 10",     14,       95,
  "Region 11",     31,      154
) |>
  mutate(
    pct_of_us_hcv = 100 * n_hcv / sum(n_hcv),
    pct_of_us_total = 100 * n_total / sum(n_total)
  )

hcv_measures <- c(
  pct_of_us_hcv = "Share of U.S. HCV-donor\nmultiorgan HTs (%)"
)

hcv_states <- join_region_values(region_states, hcv_summary)

## ---- hcv-region-table
# The counts and percentages behind the maps, for the table on the Maps page
hcv_summary |>
  transmute(
    Region = region,
    `HCV-donor multiorgan HTs` = n_hcv,
    `Share of U.S. HCV-donor multiorgan HTs (%)` = round(pct_of_us_hcv, 1),
    `All multiorgan HTs` = n_total,
    `Share of all U.S. multiorgan HTs (%)` = round(pct_of_us_total, 1)
  ) |>
  write_region_table(study = "hcv")

## ---- hcv-maps
for (measure in names(hcv_measures)) {
  hcv_ggplot <- map_regions_ggplot(
    hcv_states, region_outlines, main_labels,
    fill_var = measure,
    legend_title = hcv_measures[[measure]],
    centers = heart_centers,
    center_label = center_label,
    note = map_note,
    palette = fill_palette,
    na_fill = missing_fill,
    crs = map_crs,
    base_size = base_text_size
  )
  hcv_tmap <- map_regions_tmap(
    hcv_states, region_outlines, main_labels, inset_labels,
    fill_var = measure,
    legend_title = hcv_measures[[measure]],
    centers = heart_centers,
    center_label = center_label,
    inset_box = corridor_box,
    note = map_note,
    palette = fill_palette,
    na_fill = missing_fill
  )
  save_region_maps(
    hcv_ggplot, hcv_tmap,
    study = "hcv",
    name = measure,
    width = figure_width,
    height = figure_height,
    dpi = tiff_dpi
  )
}
