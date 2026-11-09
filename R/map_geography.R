# Purpose: build the map layers every study shares: state polygons with their
# UNOS region, region outlines, region label points, adult heart-transplant
# centers, and the extent of the corridor inset. All layers use map_crs.
# Needs: setup.R, functions.R. Downloads the HRSA center layer (public).
# Produces: region_states, region_outlines, region_labels, heart_centers,
#   corridor_bbox.

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
    mapped_states = region_states,
    crs = map_crs
  )

## ---- corridor-inset
# The corridor extent, given in longitude and latitude, as a box in map_crs.
# The box is projected as a polygon, then its bounding box taken, so the
# inset covers the whole corridor after projection.
corridor_bbox <- st_bbox(corridor_extent, crs = 4326) |>
  st_as_sfc() |>
  st_transform(map_crs) |>
  st_bbox()
