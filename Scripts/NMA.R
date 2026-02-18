library(readr)
library(dplyr)
library(gemtc)
library(coda)

suppressPackageStartupMessages(library(rjags))

cat("\nJAGS detected at:\n")
print(Sys.which("jags"))

cat("\nJAGS version (from rjags):\n")
print(jags.version())   # <-- use print(), not cat()

cat("\nPackage versions:\n")
cat("gemtc: "); print(packageVersion("gemtc"))
cat("rjags: "); print(packageVersion("rjags"))

# Load data 
arms <- read_csv("Data/arms.csv", show_col_types = FALSE)
re   <- read_csv("Data/relative_effects.csv", show_col_types = FALSE)

cat("\nLoaded arms.csv (first 6 rows):\n")
print(head(arms))

cat("\nLoaded relative_effects.csv:\n")
print(re)

re_gemtc <- re %>%
  transmute(
    study      = study_id,
    treatment  = treatment,
    comparator = comparator,
    diff       = md,
    std.err    = se
  )

# Baseline row: one per study
baseline_rows <- re_gemtc %>%
  distinct(study) %>%
  mutate(
    treatment  = "semaglutide_1",
    comparator = NA_character_,
    diff       = NA_real_,
    std.err    = 0.0001  
  )

re_gemtc2 <- bind_rows(baseline_rows, re_gemtc) %>%
  arrange(study, desc(is.na(diff)), treatment)

cat("\nData passed to gemtc (re_gemtc2):\n")
print(re_gemtc2)

# QC: exactly 1 baseline row per study
check_baseline <- re_gemtc2 %>%
  group_by(study) %>%
  summarise(n_baseline = sum(is.na(diff)), .groups = "drop")

cat("\nBaseline row check (must be 1 per study):\n")
print(check_baseline)

if (any(check_baseline$n_baseline != 1)) {
  stop("Baseline row problem: each study must have exactly 1 diff=NA row.")
}

network <- mtc.network(data.re = re_gemtc2)

cat("\nNetwork summary:\n")
print(summary(network))

model_fe <- mtc.model(
  network,
  type        = "consistency",
  linearModel = "fixed",
  likelihood  = "normal",
  link        = "identity"
)

set.seed(123)
result_fe <- mtc.run(model_fe, n.adapt = 5000, n.iter = 20000, thin = 10)

cat("\n=== FIXED-EFFECT MODEL SUMMARY ===\n")
print(summary(result_fe))

cat("\nRelative effects vs semaglutide_1 (fixed-effect):\n")
rel_fe <- relative.effect(result_fe, t1 = "semaglutide_1")
print(rel_fe)

cat("\nGelman-Rubin diagnostic (fixed-effect):\n")
print(gelman.diag(as.mcmc.list(result_fe), autoburnin = FALSE))

cat("\nEffective sample size (fixed-effect):\n")
print(effectiveSize(as.mcmc.list(result_fe)))

plot(result_fe)

cat("\nRank probabilities (fixed-effect) — interpret cautiously (single study):\n")
rank_fe <- rank.probability(result_fe)
print(rank_fe)

cat("\nNOTE: Random-effects tau is NOT identifiable with 1 study.\n",
    "This section is for demonstration only.\n", sep="")

model_re <- mtc.model(
  network,
  type        = "consistency",
  linearModel = "random",
  likelihood  = "normal",
  link        = "identity"
)

set.seed(123)
result_re <- mtc.run(model_re, n.adapt = 5000, n.iter = 20000, thin = 10)

cat("\n=== RANDOM-EFFECTS MODEL SUMMARY (PRIOR-DRIVEN WITH 1 STUDY) ===\n")
print(summary(result_re))

cat("\nRelative effects vs semaglutide_1 (random-effects):\n")
rel_re <- relative.effect(result_re, t1 = "semaglutide_1")
print(rel_re)

cat("\nGelman-Rubin diagnostic (random-effects):\n")
print(gelman.diag(as.mcmc.list(result_re), autoburnin = FALSE))

cat("\nEffective sample size (random-effects):\n")
print(effectiveSize(as.mcmc.list(result_re)))

par(mar = c(4,4,2,2))
plot(result_re)

cat("\nRank probabilities (random-effects) — interpret cautiously:\n")
rank_re <- rank.probability(result_re)
print(rank_re)

cat("\nSession info:\n")
sessionInfo()

