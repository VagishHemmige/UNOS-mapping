# Purpose: attach packages and define constants shared by every script.
# Needs: nothing. Produces: attached packages and named constants.
# Each study's regional counts are short enough to be written out in its own
# script (hcv_map.R, dcd_map.R, evmp_map.R); they are published values.

## ---- load-packages
library(sRtr)        # UNOS region geography and HRSA transplant centers
library(sf)          # spatial data
library(dplyr)
library(stringr)
library(ggplot2)
library(colorspace)  # sequential "OrYel" palette used in the published maps
library(tmap)        # maps with an inset of the Washington-Boston corridor (tmap 4.x)

## ---- define-constants
# Projection for every layer: NAD83 / Conus Albers, as in sRtr and HOPE-CDC
map_crs <- 5070

# Extent of the tmap inset, in longitude and latitude: the Washington-Boston
# corridor, where centers crowd together (DC, Baltimore, Philadelphia, New
# York, Hartford, Providence, Boston)
corridor_extent <- c(xmin = -77.6, ymin = 38.6, xmax = -70.5, ymax = 42.9)

# Fill palette and colour for regions with no value
fill_palette <- "OrYel"
missing_fill <- "grey85"

# Organ whose centers are overlaid
center_organ <- "Heart"

# Centers with "Children" in their name that also transplant adults, carried
# over from the original maps (analysis plan section 5)
adult_center_exceptions <- c(
  "Memorial Regional Hospital/Joe DiMaggio Children's Hospital",
  "Providence Sacred Heart Medical Center & Children's Hospital"
)

# Space, in metres, between the corridor box and the region numbers placed
# next to it (main map) or inside it (inset)
label_margin <- 40000

# Legend entry for the center dots, and the note printed under every map.
# {retrieved} is replaced by the date the HRSA layer was downloaded.
center_label <- "Adult heart-transplant center (current HRSA list)"
map_note_template <- str_c(
  "Shading: regional counts from the published study (OPTN/UNOS registry). ",
  "Dots: adult heart-transplant centers in HRSA's current list, retrieved ",
  "{retrieved}; they do not show which centers took part during the study ",
  "period."
)

# Saved maps: 7 inches wide, a double-column journal figure, with text at
# 8 pt. PNG for the website at 300 dpi; PDF (vector) and TIFF at tiff_dpi
# for journal submission.
figure_width <- 7
figure_height <- 4.6
base_text_size <- 8
tiff_dpi <- 600
