# Purpose: reusable helper functions. Each takes its inputs as arguments.
# Needs: setup.R. Produces: functions only.

## ---- join-region-values
# Attach a regional summary to the state polygons. Every state takes its
# region's values. Stops if any region is missing from the summary.
join_region_values <- function(region_states, region_summary) {
  missing_regions <- setdiff(unique(region_states$Region), region_summary$region)
  if (length(missing_regions) > 0) {
    stop(
      "The regional summary has no row for: ",
      str_flatten_comma(sort(missing_regions))
    )
  }
  region_states |>
    left_join(
      region_summary,
      by = join_by(Region == region),
      relationship = "many-to-one"
    )
}

## ---- select-adult-centers
# Keep centers that list the organ, one row per center, excluding pediatric
# centers by name. The HRSA layer has one row per center and organ, so
# distinct() is needed or each center is drawn several times.
# Centers outside the mapped states (Alaska, Hawaii, Puerto Rico) are dropped,
# since the map shows only the 48 contiguous states and DC.
select_adult_centers <- function(centers, organ, adult_exceptions,
                                 mapped_states, crs) {
  centers |>
    filter(str_detect(Service_Lst, str_c("\\b", organ, "\\b"))) |>
    distinct(OTC_CD, .keep_all = TRUE) |>
    filter(!str_detect(OTC_NM, "Children") | OTC_NM %in% adult_exceptions) |>
    st_transform(crs) |>
    st_filter(mapped_states)
}

## ---- map-regions-ggplot
# Map one measure: states shaded by region value, region outlines on top,
# region numbers, and optionally transplant centers at their true locations.
map_regions_ggplot <- function(region_states, region_outlines, region_labels,
                               fill_var, legend_title, centers = NULL,
                               palette, na_fill, crs) {
  region_map <- ggplot() +
    geom_sf(
      data = region_states,
      mapping = aes(fill = .data[[fill_var]]),
      colour = "grey55",
      linewidth = 0.2
    ) +
    geom_sf(data = region_outlines, fill = NA, colour = "black", linewidth = 0.7) +
    geom_sf_text(
      data = region_labels,
      mapping = aes(label = label),
      colour = "navy",
      fontface = "bold",
      size = 3.5
    )

  if (!is.null(centers)) {
    region_map <- region_map +
      geom_sf(data = centers, size = 1.2, alpha = 0.6)
  }

  region_map +
    scale_fill_continuous_sequential(palette = palette, na.value = na_fill) +
    coord_sf(crs = crs, datum = NA) +
    labs(fill = legend_title) +
    theme_void()
}

## ---- map-regions-tmap
# The same map in tmap, with the Northeast enlarged in an inset so its small
# states and crowded centers can be read.
map_regions_tmap <- function(region_states, region_outlines, region_labels,
                             fill_var, legend_title, centers = NULL,
                             inset_bbox, palette, na_fill) {
  region_map <- tm_shape(region_states) +
    tm_polygons(
      fill = fill_var,
      fill.scale = tm_scale_continuous(
        values = sequential_hcl(7, palette = palette),
        value.na = na_fill
      ),
      fill.legend = tm_legend(title = legend_title),
      col = "grey55",
      lwd = 0.5
    ) +
    tm_shape(region_outlines) +
    tm_borders(col = "black", lwd = 1.5) +
    tm_shape(region_labels) +
    tm_text("label", col = "navy", fontface = "bold", size = 0.8)

  if (!is.null(centers)) {
    region_map <- region_map +
      tm_shape(centers) +
      tm_dots(size = 0.15, fill_alpha = 0.6)
  }

  region_map +
    tm_inset(inset_bbox, position = c("right", "bottom"), width = 14, height = 14) +
    tm_layout(frame = FALSE)
}

## ---- save-region-maps
# Save the ggplot and tmap versions of one map under figures/<study>/.
save_region_maps <- function(ggplot_map, tmap_map, study, name, width, height) {
  out_dir <- file.path("figures", study)
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  ggsave(
    file.path(out_dir, str_c(name, ".png")),
    plot = ggplot_map,
    width = width,
    height = height,
    bg = "white"
  )
  tmap_save(
    tmap_map,
    file.path(out_dir, str_c(name, "_inset.png")),
    width = width,
    height = height,
    units = "in"
  )
}
