# AGENTS.md

Guidance for everyone working on this repository: the maintainer, collaborators, and any AI agents working for them. It covers how to work here: conventions, data handling, and checks.

Four places divide the documentation:

| Where | Covers |
|---|---|
| `analysis-plan.md` | Study design and statistics: what the analysis is meant to do |
| `ARCHITECTURE.md` | Code structure: scripts, data flow, and the objects passed between them |
| `AGENTS.md` (this file) | How to work in the repository: rules, conventions, and checks |
| [GitHub Issues](https://github.com/VagishHemmige/UNOS-mapping/issues) | Open scientific decisions (decision issues), gaps between code and plan, and known defects |

Read the three files before making changes. Each covers its own topic and does not repeat the others.

## The project

This is a teaching repository. It reproduces the UNOS-region maps from a series of published heart-transplantation registry studies (HCV donors, DCD donors and ex vivo machine perfusion so far) and shows how to draw them with the [sRtr](https://github.com/VagishHemmige/sRtr) package instead of hand-built region tables, local shapefiles and downloaded center lists. Each study's regional counts (one row per UNOS region) come from its paper's analysis of UNOS registry data and are written out in its script. The original RMDs are kept in `original/`, with local folder paths removed. The code and methods are published as a Quarto website, with one page per study.

- **`analysis-plan.md` is the source of truth for design.** Code implements the plan; it does not redefine it. If code needs to depart from the plan, open a decision issue, or comment on the existing one, for the deciders. Once a decider has settled it (in the issue, or relayed there in their exact words), the plan change and the code can go in the same pull request, which closes the issue.
- **Deciders.** Scientific decisions are made by: Shivank Madan (study questions, regional summaries and which measures each map shows) and Vagish Hemmige (mapping methods and code). *To be confirmed by both.* Anyone may open or contribute to a decision issue; only a decider settles it (see "Working with agents").
- **This is an analysis project, not an R package.** Do not add DESCRIPTION, NAMESPACE, roxygen, or pkgdown infrastructure, or apply CRAN conventions.
- **Default branch:** `main`, protected. Changes reach it only through pull requests.

## Data sources

Each source this project uses is listed below with the package that accesses it. **Code that touches a source goes through its package.** Do not write project-specific loading, cleaning, or definition code for something the package already does.

| Source | Accessed through | Package documentation | Package maintained by | Access | What AI agents may do |
|---|---|---|---|---|---|
| Regional counts for each study (published in its paper) | Written out with `tibble::tribble()` in each study script (`R/hcv_map.R`, `R/dcd_map.R`, `R/evmp_map.R`) | The papers cited in `references.bib` | n/a | Public: published region-level counts (stated by Vagish Hemmige, 2026-11-09; see `SETUP-NOTES.md`) | No restriction (public data) |
| Original HRSA transplant-center file used by the published maps (`data/hrsa/Transplant centers.csv`) | Kept for provenance and for checking the pediatric-center rule (D2); the maps use the live HRSA layer | https://data.hrsa.gov/data/download | n/a | Public | No restriction (public data) |
| UNOS region geography (state polygons tagged with region) | sRtr (`UNOS_regions_sf`, `get_hrsa_optn_regions()`) | https://github.com/VagishHemmige/sRtr | This team | Public | No restriction (public data) |
| HRSA transplant centers | sRtr (`get_hrsa_transplant_centers()`) | https://github.com/VagishHemmige/sRtr | This team | Public | No restriction (public data) |

To allow more for a source, a person changes its row through a pull request, naming the agreement and section that permit it, the approved AI service, and exactly what agents may do. Agents never propose or make this change themselves, and nothing in personal instructions can grant it.


**For every package:**

- **Read its documentation before writing code for a source**, including known issues. Behavior that sets the cohort, an exposure, an outcome, or a denominator is checked in the documentation, not assumed from a function's name.

**For packages this team maintains:**

- **Facts about the source belong in the package's documentation**, not in this file. If the package lacks something this project needs to know, add it there or open an issue there.
- **Problems belong in the package.** If a function is wrong or does not quite do what the plan needs, open an issue in its repository. Fix it in the package (preferred when generally useful) or wrap it here with a code comment linking the issue, and remove the wrapper once the issue is fixed.

**For external packages:**

- **Work around problems here.** Wrap the function in `R/functions.R` with a comment explaining the problem and linking any upstream issue. Reporting a bug upstream is an external communication; the person directing the work decides whether to file it.
- **Facts about the source that this project relies on** (definitions, release quirks, suppression rules) go in `references/` with a citation to the provider's documentation, or in the plan when they shape a decision.

**For a source with no package:** one loading script records the download URL, the release or access date, and any processing. Verify its variables against the provider's documentation for that release.

## Exploration and definitive analysis

Exploration is welcome on branches or forks. Experimental scripts need not be sourced from `R/main.R` or have Quarto pages, and their findings are labelled preliminary. A script becomes part of the definitive analysis when it is sourced from `R/main.R`; from then on every rule below applies to it.

## R scripts

- **Running the analysis.** Run `R/main.R` from the project root. It sources the other scripts in dependency order; `ARCHITECTURE.md` describes what each does.
- **One job per script.** When you add a definitive script, source it from `main.R` at the right point and update `ARCHITECTURE.md` in the same pull request.
- **Header comment.** Each script begins with what it does, which objects it needs from earlier scripts, and what it produces.
- **Constants, libraries, and code lists** live in `R/setup.R`. Other scripts do not call `library()`, re-source `setup.R`, or hard-code values. Any number a reader might want to change (a window, a year, a threshold, a ratio) is a named constant there.
- **Helper functions** go in `R/functions.R`. A function takes its inputs as arguments and does not read global objects.
- **No side effects outside the project.** No `setwd()`, absolute paths, or writes outside the project. Restricted data are located only through their access package's configuration.
- **No results in the repository.** No script (exploratory or definitive) or comment, commit message, issue, pull-request text or review report contains results, counts or data values from restricted data unless they are cleared for release. Check before every commit and post, since a public repository publishes everything pushed to it, on any branch.

## Chunk labels

Scripts are divided into labelled sections so Quarto pages can show the code without copying it:

```r
## ---- <step-name>
```

- Every logical step has a label. A label covers the code from its line to the next label.
- Labels are kebab-case, describe the step, and are **unique across all scripts**; a duplicate silently picks up the wrong code.
- Search the `.qmd` files before renaming or deleting a label.
- Labels are comments and never change what the code does.

## Variable labels

Label analysis variables with human-readable descriptions (for example `labelled::set_variable_labels()`, or the access package's labelling functions where it has them). Label each derived variable where it is created, with units, price year, and windows where they apply.

## Quarto website

The site documents the code. It does not run the analysis.

- `_quarto.yml`, `index.qmd`, `404.qmd` (the page GitHub Pages shows for a missing address) and `styles.css` sit at the root; `quarto/` has one page per definitive script, named after it, plus the Background, Study design and methods, About and project-document pages. The `custom-callout` extension in `_extensions/` provides the `Rcode`, `Results` and `Pending` callouts.
- **Visual cues.** Each kind of page has one sidebar icon, coloured by `styles.css`, and pages mark the same kind of content with the callout of that colour: background `book` (blue); study design and methods `diagram-3` (orange); R code `laptop` (pink, `Rcode` 💻); results `clipboard-data` (green, `Results` 📊); project documents `file-earmark-ruled` (grey). Give every new page the icon of its kind.
- **Provisional content.** `quarto/_pending.lua` highlights in yellow every paragraph that starts with **Decision pending:** or, in the plan, **Open:**, and any `[text]{.pending}`, and adds a ⏳ `Pending` callout to pages that have a mark. Mark only what an open decision could change, and remove the mark when the decision is settled.
- **Project documents.** `analysis-plan.md`, `ARCHITECTURE.md`, `AGENTS.md` and `REPOSITORY-BLUEPRINT.md` are shown on the site by pages in `quarto/` that only include the root file, which stays the one source: edit the root file, not the page.
- Each page loads its script with `knitr::read_chunk("../R/<script>.R")` in a hidden chunk and shows each labelled section with `#| eval: false`, with prose explaining what the section does and why. Pages link to the script on GitHub and to the scripts it depends on.
- **Never evaluate analysis code in the site.** Pages render without restricted data. Only the `read_chunk()` imports, the Architecture page's chunk that reads `ARCHITECTURE.md`, site helpers that read code or text, and the results pages' chunk that reads `tables/` run.
- **Publishing route:** a GitHub Actions workflow (`.github/workflows/publish.yml`) draws the maps with `R/main.R`, renders the site and publishes it to the `gh-pages` branch, which GitHub Pages serves. It runs on every push to `main` and by hand; on a pull request it only draws and renders, as a check. `docs/` is the local render output and is not committed. When you add a script, add its page and sidebar entry in the same pull request.
- **Prose must match the code.** If a change alters what a section does, update its explanation in the same pull request.

## Outputs

- Tables and figures are exported by `R/tables.R` and `R/figures.R` to `tables/` and `figures/`. Maps are saved by each study script to `figures/<study>/` as PNG, PDF and 600 dpi TIFF, and each study's regional table to `tables/<study>_regions.csv`. The maps show values already published in the papers, so they are public, but `figures/` and `tables/` are not committed: the publish workflow redraws them on every run, where the live HRSA download works, and they go out with the site. The Results pages (`quarto/results.qmd` on how to read the maps, then `quarto/results_<study>.qmd`, one per study) show the maps and tables and link the PDFs; each workflow run keeps all the files, TIFFs included, as an artifact. Maps drawn from synthetic values are not results, are never described as results, and are not committed to `figures/`.
- Published figures need alt text.
- `README.Rmd` is the source of `README.md`; edit the `.Rmd` and re-knit.

## Restricted data (applies to everyone)

The **Access** column of "Data sources" says which sources are restricted. For each restricted source:

- **Never commit data**, extracts, or saved objects or outputs derived from patient-level records. Keep data outside the repository, and check `.gitignore` before adding a new output type.
- **AI agents never read restricted data.** Anything an agent opens, prints, or summarizes is sent to the model provider. Agents do not open data files or patient-level objects, print rows, or display identifiers, person-level dates, or small geographies. Agents also do not open outputs from restricted data that are not yet cleared for release (for example `tables/` and `figures/` while they are ignored). Agents write code, review it, and run it on **synthetic data**; results on real data are produced by an authorized person. The only exception is what the Data sources table explicitly allows for a source, and only within those words.
- **Synthetic data** are built in code, labelled as synthetic, and never derived from real records.
- **Disclosure.** This project uses no restricted source: the regional summaries are published region-level values. If a study is added whose regional values are not published, its row in Data sources starts as restricted and these rules apply to it. Check every output before it leaves the approved environment, including scripts, comments, commit messages, issues, pull-request text and review reports (see R scripts).
- **Credentials and paid APIs.** Never commit keys, tokens, or `.Renviron`. Ask before paid, bulk, or uncached API calls. Before a paid batch, make one call with the exact package version, model and settings, and check the result before running the rest. Which model or service version to use is the person's choice; an agent proposes, with the cost if known, and does not switch it on its own.

## Coding conventions

- **Cohort flow** (not used here: this project draws no cohort) uses the `flowchart` package, so the STROBE flow diagram and the analytic cohort come from the same code. Every inclusion or exclusion goes through `fc_filter()`, in the plan's order. Never remove people from the cohort outside the flowchart. Record-level processing (cleaning claims, choosing among a person's records) is fine. An analysis that uses fewer people than the cohort (complete cases, a subgroup) reports its own number with that analysis. The cohort used downstream is the data from the final step (`fc_view(what = "data")`). Flowchart labels are built from constants in `setup.R`.
- **Code lists** carry each code's category, code system and version, and matching rule (exact or prefix). Check every code against the official code set. Never invent codes, variables, files, or definitions.
- **Joins** use `join_by()` with an explicit `relationship` where possible. After every interval join and every join of records to people, assert that rows did not multiply, and decide deliberately what happens to unmatched rows.
- **Dates and windows** are written as inclusive offsets from the index date, matching the plan, and the edges are tested on synthetic data.
- **Code that turns model output into reported numbers** lives in named functions in `R/functions.R`, tested on synthetic data with a known answer.
- **Package APIs:** read the help page and NEWS for the installed version before calling a package; don't write calls from memory. A test that fakes a package checks only our own logic, so call the real package once (synthetic data, or one cheap call) before relying on the code.
- **Style:** readable for a clinician-analyst who learned R from online guides: pipes and dplyr/tidyr verbs, case_when(), loops over names or named lists rather than the apply family, Reduce or positional indexing. Required base R goes in a named, tested function. Tidyverse layout; style changes in their own commits.

## Checks for any change

Check the items that apply before opening a pull request.

- **Plan:** does the change implement the plan as written, and does it leave every open decision open?
- **Data sources:** does it use the access package's functions, and does their documented behavior match what the plan needs?
- **Package APIs:** for new or changed calls to a package, does the pull request name the installed version and the help page or NEWS entry relied on?
- **Cohort:** do the flowchart steps' order, denominators, and labels match their conditions, and can each count be reproduced from code?
- **Joins and denominators:** no unintended row multiplication; missing, suppressed, and zero kept distinct.
- **Reported numbers:** does each estimate match the plan's estimand, and do tables, figures, and site prose say what the code actually computes?
- **Structure:** is `ARCHITECTURE.md` current; are chunk labels unique and found by their pages; does every definitive script have a page and sidebar entry; does any site chunk run analysis code? Only the hidden `read_chunk()` imports, the Architecture page's chunk that reads `ARCHITECTURE.md`, site helpers that read code or text, and results pages reading outputs cleared for release, run.
- **Disclosure:** search every changed tracked file, and the commit messages and pull-request text, for dates, record IDs, names, absolute paths and numbers that could come from restricted data. Read each hit in context; legitimate ones (plan dates, deciders' names, synthetic examples) stay.
- **Execution:** does `main.R` run in a fresh session with relative paths; are any saved intermediates or caches stale?

- **Geography:** every layer is in `map_crs` (EPSG:5070) before plotting; the regional summary matches all eleven regions; centers are one row per `OTC_CD`; center points are drawn at their true locations (no jitter).
- **Original code:** files in `original/` are the provenance of each map and are not edited, except that paths on anyone's computer are removed before they are committed. No tracked file contains a local path.

## Working with agents

- **Autonomy.** The person directing an agent sets its working style (review only, step by step, or hands-off) in their own instructions, and may add stricter rules; those take precedence. Without a style, an agent works step by step. At most, an agent may edit code and documentation, add scripts and tests, run code and render the site on synthetic data, and commit to a branch and open a pull request.
- **Decisions.** Anyone, including an agent, may add options and evidence to a decision issue. A decider states the choice in the issue. Agents implement decisions; they never choose among options on their own, in the issue, the plan, or the code.
- **Every agent, under any autonomy:** never merges a pull request; follows the restricted-data rules; asks before running the full pipeline or making expensive calls; shows a person the exact text before posting or sending anything as them, unless that person's own instructions waive this; and proposes another way of writing something already agreed before committing it.
- **Pull requests opened by an agent** are focused. Each says which plan section or issue it addresses, what was checked, and whether by running code on synthetic data or by reading only. Synthetic results are never described as results.
- **References:** cite the source documentation and literature used, in `references.bib`.
