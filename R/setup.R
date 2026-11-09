# Purpose: attach packages and define constants shared by every script.
# Needs: nothing. Produces: attached packages and named constants.
# The regional summary spreadsheets are public (their values are published in
# the papers) and are kept in data/regional/. A study whose spreadsheet is
# missing is drawn from synthetic values instead.

## ---- load-packages
library(sRtr)        # UNOS region geography and HRSA transplant centers
library(sf)          # spatial data
library(dplyr)
library(stringr)
library(readxl)      # reads the regional summary spreadsheets
library(janitor)     # clean_names() for spreadsheet headers
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

# Folder holding the regional summary spreadsheets
region_data_dir <- file.path("data", "regional")

# Regional summary spreadsheets, one per study
region_files <- list(
  hcv = "UNOS regions.xlsx",
  dcd = "DCD by UNOS regions.xlsx",
  evmp = "DBD EVMP UNOS regions_corrected.xlsx"
)

# Size of saved maps, in inches
figure_width <- 9
figure_height <- 5.5
