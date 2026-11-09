# Purpose: build the map layers every study shares: state polygons with their
# UNOS region, region outlines, region label points, adult heart-transplant
# centers, and the extent of the corridor inset. All layers use map_crs.
# Needs: setup.R, functions.R. Downloads the HRSA center layer (public).
# Produces: region_states, region_outlines, heart_centers, hrsa_retrieved,
#   map_note, corridor_box, main_labels, inset_labels.

## ---- region-geography
# State polygons tagged with UNOS region, built into sRtr. These replace the
# Census shapefile and the hand-split region table in the original code.
region_states <- UNOS_regions_sf |>
  st_transform(map_crs)

# One outline per region, replacing the original st_union() step
region_outlines <- get_hrsa_optn_regions() |>
  st_transform(map_crs)

## ---- heart-centers
# Current HRSA transplant-center layer, filtered to adult heart centers. The
# download date goes into the note under every map.
heart_centers <- get_hrsa_transplant_centers() |>
  select_adult_centers(
    organ = center_organ,
    adult_exceptions = adult_center_exceptions,
    mapped_states = region_states,
    crs = map_crs
  )
hrsa_retrieved <- Sys.Date()

map_note <- str_glue(
  map_note_template,
  retrieved = format(hrsa_retrieved, "%d %B %Y")
)

## ---- corridor-inset
# The corridor extent, given in longitude and latitude, as a box in map_crs.
# The box is projected as a polygon and its bounding box taken, so the inset
# covers the whole corridor after projection.
corridor_box <- st_bbox(corridor_extent, crs = 4326) |>
  st_as_sfc() |>
  st_transform(map_crs) |>
  st_bbox() |>
  st_as_sfc()

## ---- region-labels
# A point for each region's number, replacing the hand-entered label
# positions in "UNOS region labels.xlsx": one set for the main map, kept
# clear of the corridor box, and one for the inset, inside it
main_labels <- place_region_labels(
  region_outlines, corridor_box, label_margin, where = "main"
)
inset_labels <- place_region_labels(
  region_outlines, corridor_box, label_margin, where = "inset"
)
