# Clinical-Trial-Data-Curation-Bayesian-Network-Meta-Analysis-HbA1c-Week-40-52-
Conducted structured extraction of Phase 3 RCT data to evaluate comparative HbA1c reduction of GLP-1 therapies at ~40 weeks. Harmonized endpoints, converted CIs to standard errors, and built analysis-ready datasets. Implemented a Bayesian network meta-analysis in R and documented estimand and population assumptions for transparency.
---

#Overview

This project demonstrates a structured pharmaceutical evidence synthesis workflow using the SURPASS-2 randomized clinical trial.

The objective was to extract, curate, and structure clinical trial data in a format suitable for Bayesian network meta-analysis (NMA), consistent with industry practices used in competitive intelligence and statistical evidence synthesis teams.

The project includes:

- Systematic data extraction from published RCT sources
- Estimand-aware endpoint harmonization
- Creation of meta-analysis-ready datasets
- Bayesian fixed and random-effects NMA using `gemtc`
- Transparent audit trail documentation

#Research Question

What is the comparative efficacy of tirzepatide versus semaglutide (and ultimately liraglutide) in reducing HbA1c at approximately 40–52 weeks in adults with Type 2 Diabetes?

#PICO Framework

**Population**  
Adults (≥18 years) with Type 2 Diabetes inadequately controlled on metformin.

**Intervention**  
Tirzepatide 5 mg, 10 mg, 15 mg (once weekly).

**Comparator**  
Semaglutide 1 mg (once weekly).

**Outcome**  
Change in HbA1c from baseline (%-points).

**Timepoint Rule**  
Closest to 40–52 weeks (SURPASS-2 primary endpoint = Week 40).

#Datasets
`arms.csv`
Arm-level dataset containing:
- Study and trial identifiers
- Treatment arms and doses
- Analysis population
- HbA1c mean change at Week 40
- Estimand classification
- Audit source location

`relative_effects.csv`
Contrast-level dataset containing:
- Mean differences vs semaglutide
- 95% confidence intervals
- Derived standard errors
- Direction consistency check

Standard errors were calculated using:
SE = (CI_high − CI_low) / (2 × 1.96)

## 🔬 Analysis Approach

Bayesian network meta-analysis was implemented using the `gemtc` package.

Models run:

- Fixed-effect consistency model
- Random-effects model (demonstration only; heterogeneity not identifiable with a single study)

Convergence was evaluated using:

- Gelman-Rubin diagnostics
- Effective sample size
- Traceplots
- Only one multi-arm RCT (SURPASS-2) was available.
- Multi-arm covariance was not explicitly modeled due to unavailable variance structure.
- Arm-level SD values were not available in the extracted excerpt.
- Random-effects model is prior-driven due to single-study network.

This project demonstrates workflow capability rather than definitive pooled estimates and core competencies required for evidence synthesis and statistical co-op roles:

- Clinical trial data mining
- Endpoint and estimand interpretation
- Structured dataset harmonization
- Bayesian modeling
- Transparent documentation
- Reproducible analytical workflow

The structure is scalable to multi-trial network meta-analysis including semaglutide and liraglutide trials at 40–52 weeks.
