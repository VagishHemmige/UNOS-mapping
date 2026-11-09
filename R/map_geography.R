# Purpose: build the map layers every study shares: state polygons with their
# UNOS region, region outlines, region label points, adult heart-transplant
# centers, and the Northeast inset extent. All layers use map_crs.
# Needs: setup.R, functions.R. Downloads the HRSA center layer (public).
# Produces: region_states, region_outlines, region_labels, heart_centers,
#   northeast_bbox.

## ---- region-geography
# State polygons tagged with UNOS region, built into sRtr. These replace the
# Census shapefile and the hand-split region table in the original code.
region_states <- UNOS_regions_sf |>
  st_transform(map_crs)

# One outline per region, replacing the original st_union() step
region_outlines <- get_hrsa_optn_regions() |>
  st_transform(map_crs)

## ---- region-labels
# A point inside each region for its number, replacing the hand-entered
# label positions in "UNOS region labels.xlsx"
region_labels <- region_outlines |>
  st_point_on_surface() |>
  mutate(label = str_remove(Region, "Region "))

## ---- heart-centers
# Current HRSA transplant-center layer, filtered to adult heart centers
heart_centers <- get_hrsa_transplant_centers() |>
  select_adult_centers(
    organ = center_organ,
    adult_exceptions = adult_center_exceptions,
    crs = map_crs
  )

## ---- northeast-inset
# Extent of the Northeast regions, enlarged in the tmap inset
northeast_bbox <- region_outlines |>
  filter(Region %in% northeast_regions) |>
  st_bbox()
