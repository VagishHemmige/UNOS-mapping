# Setup notes

Non-sensitive setup decisions and open items for this repository. Open decisions move to GitHub Issues once filed; this file then links them.

## Decided at setup (2026-11-09)

- One repository and one Quarto website, with one code page per study and one shared page for the map layers.
- Every map uses sRtr for region geography and transplant centers, every layer is projected to EPSG:5070 before plotting, and each map is drawn with ggplot2 and with tmap (Northeast inset).
- The Chagas map is not included yet: its study is not yet published.
- The regional summaries and maps are public. Vagish Hemmige, 2026-11-09, in a Claude session: "The maps can be published. The raw data is in the papers so that's fair game too." The spreadsheets go in `data/regional/` and `figures/` is tracked.
- The COVID-19 donor and donor offer acceptance studies have no maps yet; the site starts with the three studies that do.
- The website is published from a committed `docs/` folder by GitHub Pages.
- The original RMDs are kept in `original/`, unchanged except that local folder paths were removed (2026-11-09, at Vagish Hemmige's request).

## Decisions for the deciders (to be filed as decision issues)

**D1. Which transplant-center list to map.** `get_hrsa_transplant_centers()` returns the HRSA layer as of the day it runs, not as of each study period.
Options: (a) the current layer, accepting that centers opened or closed since the study period are wrong; (b) a dated snapshot saved once per study, closest to its study period; (c) the original HRSA file used for the published maps.
Plan §4. Code: `R/map_geography.R`, `heart-centers`.

**D2. How to exclude pediatric centers.** The original rule drops names containing "Children" except two named centers. HRSA layer names may differ from the original file's, so the two exceptions may no longer match, and other combined adult-pediatric centers may be dropped.
Options: (a) keep the name rule and check the exceptions against the HRSA names; (b) use another HRSA field, if one identifies adult programs; (c) use a center list confirmed against each study's own center list.
Plan §5. Code: `R/functions.R`, `select-adult-centers`.

**D3. What each percentage means, and its legend.** The spreadsheet columns (`Percentage_HT_HCV`, the two DCD percentages, `Percentage` for EVMP) are not defined in the RMDs, and the original legends say only "Percentage of transplants". Each may be the region's share of its own transplants or the region's share of the national total.
Needed: the definition for each column, from the study's analysis, and the legend wording.
Plan §2. Code: the `*-region-summary` sections of each study script.

## Cartographic changes from the original maps, for the maintainer to confirm

These change how the maps look, not what they show.

- Projection: EPSG:5070 instead of longitude and latitude.
- Centers drawn at their true locations instead of jittered.
- Region numbers placed by `st_point_on_surface()` instead of from `UNOS region labels.xlsx`.
- Continuous colour bar instead of a binned legend (`guide_legend()`), and legend breaks chosen from the data instead of by hand (EVMP).

## Still to do

- [ ] Confirm the deciders and their areas in `AGENTS.md` (Shivank Madan and Vagish Hemmige, as drafted).
- [ ] Add the three regional spreadsheets to `data/regional/`, run `R/main.R`, commit `figures/`, and add a Results page showing the maps.
- [ ] File D1 to D3 as decision issues and replace the `SETUP-NOTES.md` references in the plan and pages with their links.
- [ ] Run `R/main.R` with tmap 4.x and the HRSA download, which could not be tested during setup (see below), and check the inset maps by eye.
- [ ] Write `ARCHITECTURE.md`.
- [ ] Maintainer: protect the `main` branch, and turn on GitHub Pages (from `main`, `/docs`) once the first pull request containing `docs/` is merged.
- [ ] Consider two sRtr issues: `get_hrsa_transplant_centers()` returns one row per center and organ, so callers must de-duplicate; and `get_hrsa_optn_regions()` returns WGS 84 while `UNOS_regions_sf` is EPSG:5070.

## What was tested during setup

- The ggplot2 path of `R/main.R` ran on synthetic regional values and a synthetic center layer shaped like the HRSA layer (one row per center and organ): all eleven regions joined, all layers were EPSG:5070, duplicate center rows were removed, a missing region stopped the join, and the maps were inspected by eye.
- Not tested: the tmap maps (tmap could not be installed in the setup environment), `read_region_summary()` on the real spreadsheets (not yet supplied), and the live HRSA download (not reachable from the setup environment). sRtr was installed for testing without arrow, which the mapping functions do not use.
