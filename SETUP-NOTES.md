# Setup notes

Non-sensitive setup decisions and open items for this repository. Open decisions move to GitHub Issues once filed; this file then links them.

## Decided at setup (2026-11-09)

- One repository and one Quarto website, with one code page per study and one shared page for the map layers.
- Every map uses sRtr for region geography and transplant centers, every layer is projected to EPSG:5070 before plotting, and each map is drawn with ggplot2 and with tmap (Northeast inset).
- The Chagas map is not included yet: its study is not yet published.
- The regional summaries and maps are public. Vagish Hemmige, 2026-11-09, in a Claude session: "The maps can be published. The raw data is in the papers so that's fair game too." `figures/` is tracked.
- The regional counts are written out with `tribble()` in each study script instead of read from spreadsheets (Vagish Hemmige, 2026-11-09: "There's very little data in here. Enough you could even define the tibble in the setups"). Percentages are computed from the counts. The typed counts match the supplied spreadsheets exactly, the computed percentages reproduce their percentage columns to four decimals, and the totals match the papers (HCV 109 of 1,322; DCD 87 of 1,581; EVMP 561 of 12,363).
- The COVID-19 donor and donor offer acceptance studies have no maps yet; the site starts with the three studies that do.
- The website is published from a committed `docs/` folder by GitHub Pages.
- The original RMDs are kept in `original/`, unchanged except that local folder paths were removed (2026-11-09, at Vagish Hemmige's request).

## Decisions for the deciders (open ones to be filed as decision issues)

**D1. Which transplant-center list to map.** `get_hrsa_transplant_centers()` returns the HRSA layer as of the day it runs, not as of each study period.
Options: (a) the current layer, accepting that centers opened or closed since the study period are wrong; (b) a dated snapshot saved once per study, closest to its study period; (c) the original HRSA file used for the published maps.
Plan §4. Code: `R/map_geography.R`, `heart-centers`.
**Decided:** (a), the current layer. Vagish Hemmige, 2026-11-09, in a Claude session: "I am fine with the live HRSA". The plan (§4) and the Map geography page now state this.

**D2. How to exclude pediatric centers.** The original rule drops names containing "Children" except two named centers. HRSA layer names may differ from the original file's, so the two exceptions may no longer match, and other combined adult-pediatric centers may be dropped.
Options: (a) keep the name rule and check the exceptions against the HRSA names; (b) use another HRSA field, if one identifies adult programs; (c) use a center list confirmed against each study's own center list.
Plan §5. Code: `R/functions.R`, `select-adult-centers`.

**D3. Whether to add within-region rates for HCV and DCD.** The spreadsheets settle what each published percentage is: for HCV and DCD, each region's share of the national count (Region 1: 10 of 109 HCV; 15 of 87 DCD); for EVMP, each region's own rate (Region 1: 79 of 577). A share of the national count is largest where the most transplants are done, so the HCV and DCD maps mostly show volume; the EVMP map shows uptake.
Options: (a) keep the published measures only; (b) add a map of each region's own rate (`n_hcv / n_total`, `n_dcd / n_total`) alongside, labelled as not in the paper.
Plan §2. Code: the `*-region-summary` sections of `R/hcv_map.R` and `R/dcd_map.R`.

## Cartographic changes from the original maps, for the maintainer to confirm

These change how the maps look, not what they show.

- Projection: EPSG:5070 instead of longitude and latitude.
- Centers drawn at their true locations instead of jittered.
- Region numbers placed by `st_point_on_surface()` instead of from `UNOS region labels.xlsx`.
- Legend titles say what each measure is (for example "Share of U.S. HCV-donor multiorgan HTs (%)") instead of "Percentage of transplants".
- Continuous colour bar instead of a binned legend (`guide_legend()`), and legend breaks chosen from the data instead of by hand (EVMP).

## Still to do

- [ ] Confirm the deciders and their areas in `AGENTS.md` (Shivank Madan and Vagish Hemmige, as drafted).
- [ ] Run `R/main.R`, commit `figures/`, and add a Results page showing the maps.
- [ ] File D2 and D3 as decision issues and replace the `SETUP-NOTES.md` references in the plan and pages with their links.
- [ ] Run `R/main.R` with tmap 4.x and the HRSA download, which could not be tested during setup (see below), and check the inset maps by eye.
- [ ] Write `ARCHITECTURE.md`.
- [ ] Maintainer: protect the `main` branch, and turn on GitHub Pages (from `main`, `/docs`) once the first pull request containing `docs/` is merged.
- [ ] Consider two sRtr issues: `get_hrsa_transplant_centers()` returns one row per center and organ, so callers must de-duplicate; and `get_hrsa_optn_regions()` returns WGS 84 while `UNOS_regions_sf` is EPSG:5070.

## What was tested during setup

- The ggplot2 path ran on the real regional counts, with centers taken from the original HRSA file in place of the live layer: all eleven regions joined, every layer was EPSG:5070, and the HCV and EVMP maps were inspected by eye. From the original file the center rule kept 109 heart centers, the same as the original code; one, in Puerto Rico, fell outside the map, so centers outside the mapped states are now dropped (108 remain).
- Earlier, the ggplot2 path also ran on synthetic regional values and a synthetic center layer shaped like the HRSA layer (one row per center and organ): all eleven regions joined, all layers were EPSG:5070, duplicate center rows were removed, a missing region stopped the join, and the maps were inspected by eye.
- Not tested: the tmap maps (tmap could not be installed in the setup environment), and the live HRSA download (not reachable from the setup environment). sRtr was installed for testing without arrow, which the mapping functions do not use.
