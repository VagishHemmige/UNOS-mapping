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

## ---- place-region-labels
# Points for the region numbers. On the main map, a region that the corridor
# box touches is labelled on its part outside the box (enlarged by `margin`
# metres), so no number sits under the box's outline. In the inset, each
# region is labelled on its part inside the box (shrunk by `margin`), so every
# region the inset shows gets its number.
place_region_labels <- function(region_outlines, box, margin, where) {
  regions <- region_outlines |>
    st_set_agr("constant")
  touched <- lengths(st_intersects(regions, box)) > 0

  if (where == "main") {
    outside_parts <- regions |>
      filter(touched) |>
      st_difference(st_buffer(box, margin))
    label_areas <- bind_rows(filter(regions, !touched), outside_parts)
  } else {
    label_areas <- regions |>
      filter(touched) |>
      st_intersection(st_buffer(box, -margin))
  }

  label_areas |>
    st_set_agr("constant") |>
    st_point_on_surface() |>
    mutate(label = str_remove(Region, "Region "))
}

## ---- write-region-table
# Save one study's regional table, as shown on its results page, to
# tables/<study>_regions.csv.
write_region_table <- function(region_table, study) {
  dir.create("tables", showWarnings = FALSE)
  write.csv(
    region_table,
    file.path("tables", str_c(study, "_regions.csv")),
    row.names = FALSE
  )
}

## ---- map-regions-ggplot
# Map one measure: states shaded by region value, region outlines on top,
# region numbers on a pale box so they read on any fill, transplant centers
# at their true locations with their own legend entry, and a note saying
# what the shading and the dots are.
map_regions_ggplot <- function(region_states, region_outlines, region_labels,
                               fill_var, legend_title, centers, center_label,
                               note, palette, na_fill, crs, base_size) {
  ggplot() +
    geom_sf(
      data = region_states,
      mapping = aes(fill = .data[[fill_var]]),
      colour = "grey55",
      linewidth = 0.2
    ) +
    geom_sf(data = region_outlines, fill = NA, colour = "black", linewidth = 0.4) +
    geom_sf(
      data = centers,
      mapping = aes(shape = center_label),
      size = 1,
      alpha = 0.6
    ) +
    geom_sf_label(
      data = region_labels,
      mapping = aes(label = label),
      colour = "navy",
      fill = alpha("white", 0.75),
      fontface = "bold",
      size = base_size / .pt
    ) +
    scale_fill_continuous_sequential(palette = palette, na.value = na_fill) +
    scale_shape_manual(values = 16, name = NULL) +
    coord_sf(crs = crs, datum = NA) +
    labs(fill = legend_title, caption = str_wrap(note, 110)) +
    theme_void(base_size = base_size) +
    theme(
      plot.caption = element_text(hjust = 0, size = base_size * 0.8),
      legend.position = "right"
    )
}

## ---- map-regions-tmap
# The same map in tmap, with the Washington-Boston corridor enlarged in an
# inset beside it. The inset is drawn as its own map, so it carries its own
# region numbers, and a red box on the main map shows where it is. The legend,
# the center symbol and the note run along the bottom.
map_regions_tmap <- function(region_states, region_outlines, main_labels,
                             inset_labels, fill_var, legend_title, centers,
                             center_label, inset_box, note, palette, na_fill) {
  # rev = TRUE puts the dark end of the palette on high values, matching
  # scale_fill_continuous_sequential() in the ggplot2 maps
  fill_scale <- tm_scale_continuous(
    values = sequential_hcl(7, palette = palette, rev = TRUE),
    value.na = na_fill
  )

  # The layers shared by the main map and the inset
  map_layers <- function(labels, bbox, fill_legend) {
    tm_shape(region_states, bbox = bbox) +
      tm_polygons(
        fill = fill_var,
        fill.scale = fill_scale,
        fill.legend = fill_legend,
        col = "grey55",
        lwd = 0.5
      ) +
      tm_shape(region_outlines) +
      tm_borders(col = "black", lwd = 1) +
      tm_shape(centers) +
      tm_dots(size = 0.15, fill_alpha = 0.6) +
      tm_shape(labels) +
      tm_text(
        "label",
        col = "navy",
        fontface = "bold",
        size = 0.55,
        bgcol = "white",
        bgcol_alpha = 0.75
      )
  }

  corridor_map <- map_layers(inset_labels, st_bbox(inset_box), tm_legend_hide())

  map_layers(
    main_labels,
    NULL,
    tm_legend(
      title = legend_title,
      orientation = "landscape",
      position = tm_pos_out("center", "bottom")
    )
  ) +
    tm_shape(inset_box) +
    tm_borders(col = "red", lwd = 1) +
    # Outside the map frame, to the right, so it hides nothing on the map
    tm_inset(
      corridor_map,
      position = tm_pos_out("right", "center"),
      width = 16,
      height = 16,
      frame = FALSE
    ) +
    tm_add_legend(
      type = "symbols",
      labels = center_label,
      fill = "black",
      size = 0.4,
      position = tm_pos_out("center", "bottom")
    ) +
    tm_credits(
      str_wrap(note, 105),
      position = tm_pos_out("center", "bottom"),
      size = 0.6
    ) +
    tm_layout(frame = FALSE)
}

## ---- save-region-maps
# Save the ggplot2 and tmap versions of one map under figures/<study>/, each
# as PNG (for the website), PDF (vector, for a journal) and TIFF at `dpi`.
save_region_maps <- function(ggplot_map, tmap_map, study, name, width, height,
                             dpi) {
  out_dir <- file.path("figures", study)
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

  ggplot_file <- file.path(out_dir, name)
  ggsave(str_c(ggplot_file, ".png"), ggplot_map,
         width = width, height = height, dpi = 300, bg = "white")
  ggsave(str_c(ggplot_file, ".pdf"), ggplot_map,
         width = width, height = height, bg = "white")
  ggsave(str_c(ggplot_file, ".tiff"), ggplot_map,
         width = width, height = height, dpi = dpi, bg = "white",
         compression = "lzw")

  tmap_file <- file.path(out_dir, str_c(name, "_inset"))
  tmap_save(tmap_map, str_c(tmap_file, ".png"),
            width = width, height = height, units = "in", dpi = 300)
  tmap_save(tmap_map, str_c(tmap_file, ".pdf"),
            width = width, height = height, units = "in")
  tmap_save(tmap_map, str_c(tmap_file, ".tiff"),
            width = width, height = height, units = "in", dpi = dpi,
            compression = "lzw")
}
