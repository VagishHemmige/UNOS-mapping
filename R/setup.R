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
library(tmap)        # maps with a Northeast inset (tmap 4.x)

## ---- define-constants
# Projection for every layer: NAD83 / Conus Albers, as in sRtr and HOPE-CDC
map_crs <- 5070

# Regions drawn again, enlarged, in the tmap inset
northeast_regions <- c("Region 1", "Region 2", "Region 9")

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

# Size of saved maps, in inches
figure_width <- 9
figure_height <- 5.5
