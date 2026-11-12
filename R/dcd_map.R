# Purpose: regional maps for the DCD-donor multiorgan heart-transplant study
#   (Madan et al., Clin Transplant 2024).
# Needs: setup.R, functions.R, map_geography.R.
# Produces: dcd_summary, dcd_states, tables/dcd_regions.csv and maps
#   saved in figures/dcd/.

## ---- dcd-region-summary
# Multiorgan heart transplants by UNOS region, January 2020 to June 2023:
# those using DCD donors, and all of them. The totals (87 and 1,581) are the
# paper's. Percentages are each region's share of the national count, as in
# the regional spreadsheet the original maps read.
dcd_summary <- tibble::tribble(
  ~region,     ~n_dcd, ~n_total,
  "Region 1",      15,       66,
  "Region 2",       0,       96,
  "Region 3",       7,      138,
  "Region 4",       3,      182,
  "Region 5",      19,      374,
  "Region 6",       0,       27,
  "Region 7",       7,      166,
  "Region 8",       3,       38,
  "Region 9",       9,      179,
  "Region 10",      1,      104,
  "Region 11",     23,      211
) |>
  mutate(
    pct_of_us_dcd = 100 * n_dcd / sum(n_dcd),
    pct_of_us_total = 100 * n_total / sum(n_total)
  )

# The four maps the original RMD drew
dcd_measures <- c(
  n_dcd = "DCD-donor multiorgan HTs (n)",
  pct_of_us_dcd = "Share of U.S. DCD-donor\nmultiorgan HTs (%)",
  n_total = "All multiorgan HTs (n)",
  pct_of_us_total = "Share of all U.S.\nmultiorgan HTs (%)"
)

dcd_states <- join_region_values(region_states, dcd_summary)

## ---- dcd-region-table
# The counts and percentages behind the maps, for the table on its results page
dcd_summary |>
  transmute(
    Region = region,
    `DCD-donor multiorgan HTs` = n_dcd,
    `Share of U.S. DCD-donor multiorgan HTs (%)` = round(pct_of_us_dcd, 1),
    `All multiorgan HTs` = n_total,
    `Share of all U.S. multiorgan HTs (%)` = round(pct_of_us_total, 1)
  ) |>
  write_region_table(study = "dcd")

## ---- dcd-maps
for (measure in names(dcd_measures)) {
  dcd_ggplot <- map_regions_ggplot(
    dcd_states, region_outlines, main_labels,
    fill_var = measure,
    legend_title = dcd_measures[[measure]],
    centers = heart_centers,
    center_label = center_label,
    note = map_note,
    palette = fill_palette,
    na_fill = missing_fill,
    crs = map_crs,
    base_size = base_text_size
  )
  dcd_tmap <- map_regions_tmap(
    dcd_states, region_outlines, main_labels, inset_labels,
    fill_var = measure,
    legend_title = dcd_measures[[measure]],
    centers = heart_centers,
    center_label = center_label,
    inset_box = corridor_box,
    note = map_note,
    palette = fill_palette,
    na_fill = missing_fill
  )
  save_region_maps(
    dcd_ggplot, dcd_tmap,
    study = "dcd",
    name = measure,
    width = figure_width,
    height = figure_height,
    dpi = tiff_dpi
  )
}
