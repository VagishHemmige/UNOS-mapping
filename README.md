
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Status](https://img.shields.io/badge/status-in_development-yellow)](#)
[![Purpose](https://img.shields.io/badge/purpose-teaching-blue)](#)
[![Not for
Citation](https://img.shields.io/badge/use-not_for_citation-lightgrey)](#)
<!-- badges: end -->

# Mapping UNOS regions with sRtr

The goal of this repository is to reproduce the UNOS-region maps from
published heart-transplantation registry studies, and to teach how to
draw them with the [sRtr](https://github.com/VagishHemmige/sRtr)
package. It covers the HCV-donor (2021), DCD-donor (2024) and
machine-perfusion (2025) studies so far; the original RMDs are kept
unchanged in `original/`.

The website, which explains the code step by step, is available at:
<https://vagishhemmige.github.io/UNOS-mapping/>

## Documentation

- [`analysis-plan.md`](analysis-plan.md): what the maps are meant to
  show
- [`ARCHITECTURE.md`](ARCHITECTURE.md): how the code is organized (not
  yet written)
- [`AGENTS.md`](AGENTS.md): how to work in this repository
- [`SETUP-NOTES.md`](SETUP-NOTES.md): open decisions and setup steps
  still to do
- [Issues](https://github.com/VagishHemmige/UNOS-mapping/issues): open
  decisions and known gaps

## Running the analysis

Run `R/main.R` from the project root. It needs sRtr
(`remotes::install_github("VagishHemmige/sRtr")`), tmap 4.x and an
internet connection for the HRSA transplant-center layer. The regional
summary spreadsheets are in `data/regional/`; their values are published
in the papers. Maps are saved to `figures/`.
