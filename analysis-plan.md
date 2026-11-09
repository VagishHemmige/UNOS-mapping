# Analysis plan: Regional maps for published heart-transplantation registry studies

Status: draft

## Scope and reporting framework

This document is the authoritative specification of the study's scientific objectives,
population, definitions, estimands and statistical methods. `ARCHITECTURE.md` documents
the implementation, `AGENTS.md` the working conventions, and GitHub Issues the open
decisions and implementation status. Neither file supersedes this plan.

This repository reproduces the regional maps from a series of published heart-transplantation
studies that used the United Network for Organ Sharing (UNOS) registry, and teaches how to
build them with the sRtr package [@srtr_package]. The underlying studies, their cohorts and
their regional summaries are specified in the published papers; this plan covers only how a
regional summary becomes a map. Reporting follows STROBE and RECORD
[@vonelm2007strobe; @benchimol2015record] as they apply to a descriptive figure. The
reporting map below links each checklist item to a section of this plan.

## 1. Background and rationale

Each study below reported that use of a donor type or technology varied widely across UNOS
regions. A map of the eleven UNOS regions shows that variation at a glance. The original maps
were drawn with hand-built region tables, a local Census shapefile and a downloaded list of
transplant centers. The sRtr package now holds the region geography and downloads the
transplant-center layer, so the same maps can be drawn from a few package calls.

## 2. Objectives

- **Primary:** for each study, draw a map of the 48 contiguous states and the District of
  Columbia, with each state shaded by the value of its UNOS region and the eleven region
  boundaries drawn over the states.
- **Secondary:** overlay the locations of adult heart-transplant centers on the same map.
- **Teaching:** show the original code and the sRtr version side by side for each study.

| Study | Measures mapped by region (spreadsheet columns as shown in the original maps) |
|---|---|
| HCV donors in multiorgan heart transplantation, 2015–2020 [@madan2021hcv] | `Percentage_HT_HCV` |
| DCD donors in multiorgan heart transplantation, 2020–2023 [@madan2024dcd] | Number of multiorgan HTs using DCD donors; its percentage; total number of multiorgan HTs; its percentage |
| Ex vivo machine perfusion in DBD heart transplantation, 2020–2024 [@madan2025evmp] | `Percentage` |

**Open:** what each percentage is a share of (the region's own transplants, or the national total), which sets each map's legend (decision D3 in `SETUP-NOTES.md`; issue to be filed).

The COVID-19 donor study [@madan2023covid] and the donor offer acceptance study
[@ramineni2026doa] join this table when their mapping code is added.

## 3. Study design and setting

Descriptive mapping of region-level summaries already computed for each published study.
No new cohort is drawn and no new statistic is estimated.

## 4. Data sources and measurement periods

- **Regional summaries:** one spreadsheet per study in `data/regional/`, holding one row per UNOS
  region with the study's counts and percentages. Each was computed from the UNOS registry for the study period
  in the table above, as described in its paper.
- **Region geography:** `UNOS_regions_sf` from sRtr, state polygons from the 2018 Census
  cartographic boundary file (1:20,000,000) with each state's UNOS region [@srtr_package].
- **Transplant centers:** the HRSA organ procurement and transplantation layer, downloaded with
  `sRtr::get_hrsa_transplant_centers()` [@hrsa_otc_layer]. The original maps used a downloaded
  copy of an HRSA transplant-center file.

**Open:** which transplant-center list to map. The HRSA layer describes centers as of the day it
is downloaded, not as of each study period. The options are the current layer, a dated snapshot
saved once per study, or the original HRSA file (decision D1 in `SETUP-NOTES.md`; issue to be
filed).

## 5. Study populations and unit definitions

- **Unit of display:** the UNOS region. Every state in a region carries that region's value.
- **Geography:** the 48 contiguous states and the District of Columbia. Alaska, Hawaii and
  Puerto Rico are excluded, as in the original maps.
- **Transplant centers:** centers that list heart transplantation, excluding pediatric centers.
  The original code excluded centers whose name contains "Children", except Memorial Regional
  Hospital/Joe DiMaggio Children's Hospital and Providence Sacred Heart Medical Center &
  Children's Hospital, which also transplant adults.

**Open:** whether to keep the name-based pediatric exclusion with the HRSA layer, whose center
names and service lists may differ from the original file (decision D2 in `SETUP-NOTES.md`;
issue to be filed).

## 6. Estimation

None. Values are taken from each study's regional summary as published. Proportions stored as
fractions are multiplied by 100 for display as percentages.

## 7. Linkage and geography

Regional summaries join to `UNOS_regions_sf` by region number. A join that does not match all
eleven regions stops the script.

## 8. Measures and outcomes

As listed for each study in §2.

## 9. Analysis and interpretation

The maps are descriptive. They show where use of a donor type or technology was higher or
lower; they do not estimate why, and a shaded state says nothing about that state alone,
only about its region.

## 10. Missing data and validity requirements

A region with no value is drawn in grey and named in the legend as having no data, not as zero.

## 11. Sensitivity analyses

None.

## 12. Disclosure control

Each regional summary holds region-level values that are published in its paper
[@madan2021hcv; @madan2024dcd; @madan2025evmp]. The spreadsheets and the maps drawn from them are
therefore public, as stated by Vagish Hemmige on 2026-11-09 (recorded in `SETUP-NOTES.md`). No
patient-level data are used.

## 13. Limitations to address in reporting

- Shading whole states by region hides variation within a region.
- Center locations show where programs are, not how many transplants each performed.

## 14. Reporting map

| Checklist item | Topic | Plan section |
|---|---|---|
| STROBE 5 | Setting, locations and periods | 3, 4 |
| STROBE 7 / RECORD 7.1 | Variables and their definitions | 2, 5, 8 |
| STROBE 8 / RECORD 8.1 | Data sources and measurement | 4 |
| STROBE 12 / RECORD 12.1–12.3 | Statistical methods, data access, linkage | 6, 7, 12 |
| STROBE 14 | Descriptive data | 2, 10 |

## References
