\name{electricity_africa}
\alias{electricity_africa}
\docType{data}

\title{
Electricity market structures and electricity supply costs in Sub-Saharan Africa
}

\description{
A cross-country dataset describing electricity sector organization, ownership,
network configuration, geographic constraints, and average electricity supply
costs in Sub-Saharan Africa.

The dataset combines observed country-level electricity system structures
with counterfactual reform scenarios for Cameroon (Cameroon_2018, Cameroon_h1,
Cameroon_h2), constructed to assess the potential impact of alternative market
designs on electricity supply costs.
}

\usage{
data(electricity_africa)
}

\format{
A data frame with 42 country--system observations and the following variables:

\describe{
  \item{country}{Country or system name. Includes observed countries and
  hypothetical reform scenarios for Cameroon.}

  \item{iso_code}{ISO 3-letter country code or scenario identifier
  (e.g. CMR_2018, CMR_h1, CMR_h2).}

  \item{total_cost}{Average electricity supply cost, expressed in USD per kWh.
  For hypothetical Cameroon scenarios, this variable may be missing and treated
  as an outcome of counterfactual analysis.}

  \item{vertical_integration}{Binary indicator equal to 1 if generation,
  transmission and distribution are vertically integrated within a single
  utility, 0 otherwise.}

  \item{private_in_generation}{Indicator for the presence of private sector
  participation in electricity generation (yes/no).}

  \item{public_in_generation}{Indicator for public ownership or participation
  in electricity generation (yes/no).}

  \item{stand_alone_generation}{Indicator equal to yes if generation assets
  operate independently from transmission and distribution.}

  \item{transmission_bundled_distribution}{Indicator equal to 1 if
  transmission is institutionally bundled with distribution.}

  \item{transmission_bundled_generation}{Indicator equal to 1 if
  transmission is institutionally bundled with generation.}

  \item{government_own_transmission}{Indicator equal to 1 if transmission
  assets are government-owned.}

  \item{multiple_transmission_system}{Indicator equal to 1 if multiple
  transmission operators coexist within the system.}

  \item{multiple_distributor}{Indicator equal to 1 if multiple electricity
  distribution companies operate in the country.}

  \item{independent_distributor}{Indicator equal to 1 if at least one
  distribution company operates independently from generation and transmission.}

  \item{not_interconnected}{Indicator equal to 1 if the national electricity
  system is not interconnected with neighboring countries.}

  \item{landlocked_country}{Indicator equal to 1 if the country is landlocked.}

  \item{fragmented_island}{Indicator equal to 1 for fragmented or small island
  electricity systems.}

  \item{openness}{Categorical indicator of electricity system openness to
  regional trade and interconnection, taking values such as
  I (isolated), E (export-oriented), or I/E (mixed).}
}
}

\details{
Observed data are primarily derived from Trimble et al. (2016) and complementary
institutional sources. The dataset is extended with three Cameroon-specific
entries: one reflecting the 2018 institutional configuration (Cameroon_2018),
and two forward-looking reform scenarios (Cameroon_h1, Cameroon_h2) representing
plausible future market designs considered by policymakers.

These counterfactual scenarios are included to explore how alternative
organizational structures may affect electricity supply costs.
}

\source{
Trimble, C., Kojima, M., Perez Arroyo, I., and Mohammadzadeh, F. (2016).
Financial viability of electricity sectors in Sub-Saharan Africa.
World Bank.
}

\examples{
## Load data
data(electricity_africa)

## Load package
library(MCAtools)

## -------------------------------------------------
## 1. Preparation of qualitative data for MCA
## -------------------------------------------------

## Keep only qualitative variables (excluding cost)
df <- electricity_africa[, c("iso_code",
                             "vertical_integration",
                             "private_in_generation",
                             "public_in_generation",
                             "stand_alone_generation",
                             "transmission_bundled_generation",
                             "government_own_transmission",
                             "multiple_transmission_system",
                             "transmission_bundled_distribution",
                             "multiple_distributor",
                             "independent_distributor",
                             "not_interconnected",
                             "landlocked_country",
                             "fragmented_island",
                             "openness"
)]

## Convert to factors
df[] <- lapply(df, as.factor)

## Cameroon reform scenarios treated as supplementary individuals
sup_rows <- which(is.na(electricity_africa$total_cost))

## -------------------------------------------------
## 2. Ordinary MCA (lambda = 1)
## -------------------------------------------------

res_ord <- mca_analysis(
  data = df,
  id_ind = "iso_code",
  sup_ind = sup_rows,
  lambda = 1
)

res_ord$eig$percentage[1]

\donttest{

## Extract first dimension (market structure)
dim1 <- res_ord$ind$coord$Dim1

## -------------------------------------------------
## 3. Relationship between market structure and cost
## -------------------------------------------------

analysis_df <- data.frame(
  country = electricity_africa$country[1:39],
  cost = log(electricity_africa$total_cost)[1:39],
  dim1 = scale(dim1)
)

analysis_df <- analysis_df[!is.na(analysis_df$cost), ]

## Quadratic relationship (U-shaped pattern)
model <- lm(cost ~ poly(dim1, 2), data = analysis_df)
summary(model)

## =========================================================
## ROBUSTNESS ANALYSIS OVER THE STABILITY INTERVAL OF lambda
## =========================================================

## -------------------------------------------------
## 4. Selection of phi-divergence parameter lambda
## -------------------------------------------------

lambda_grid <- seq(-2, 2, by = 0.05)

results <- data.frame(
  lambda = lambda_grid,
  inertia1 = NA_real_
)

for (k in seq_along(lambda_grid)) {
  res <- mca_analysis(
    data = df,
    id_ind = "iso_code",
    sup_ind = sup_rows,
    lambda = lambda_grid[k]
  )
  results$inertia1[k] <- res$eig$eigenvalue[1]
}

## Smooth inertia profile to avoid singularities at lambda = 0 and lambda = -1
singular <- abs(results$lambda) < 1e-6 |
  abs(results$lambda + 1) < 1e-6

results$inertia1_clean <- results$inertia1
results$inertia1_clean[singular] <- NA

for (k in seq_along(lambda_grid)) {
  ifelse(
    is.na(results$inertia1_clean[k]),
    results$inertia1_smooth[k] <-
      (results$inertia1_clean[k - 1] + results$inertia1_clean[k + 1]) / 2,
    results$inertia1_smooth[k] <- results$inertia1_clean[k]
  )
}

plot(
  results$lambda,
  results$inertia1_smooth,
  type = "l",
  lwd = 2,
  xlab = "lambda",
  ylab = "Inertie du premier axe",
  main = "Stabilite empirique de l'ACM phi-divergence"
)

abline(v = 1, col = "red", lty = 2)
text(1, max(results$inertia1), "lambda = 1 (chi-square)", pos = 4)

## Optimal lambda and 95% stability interval
lambda_opt <- results$lambda[which.max(results$inertia1_smooth)]

I_max <- max(results$inertia1_smooth, na.rm = TRUE)
lambda_ci <- range(results$lambda[
  results$inertia1_smooth >= 0.95 * I_max
])

lambda_opt
lambda_ci

lambda_min <- -0.335
lambda_max <-  0.095

lambda_grid <- seq(lambda_min, lambda_max, length.out = 25)

## Convert to factors
df[] <- lapply(df, as.factor)

## Container for pooled results
df_U_list <- vector("list", length(lambda_grid))

for (k in seq_along(lambda_grid)) {

  lambda_k <- lambda_grid[k]

  fit <- tryCatch(
    mca_analysis(
      data   = df,
      id_ind = "iso_code",
      sup_ind = sup_rows,
      lambda  = lambda_k
    ),
    error = function(e) NULL
  )

  if (is.null(fit)) next

  ## Active countries only (excluding Cameroon scenarios)
  n_active <- sum(!is.na(electricity_africa$total_cost))

  df_U_list[[k]] <- data.frame(
    country = rownames(fit$ind$coord)[1:n_active],
    dim1    = fit$ind$coord[1:n_active, 1],
    cost    = log(electricity_africa$total_cost[1:n_active]),
    lambda  = rep(lambda_k, n_active)
  )
}

df_U <- do.call(rbind, df_U_list)

## ---------------------------------------------------------
## Normalization of Dim 1 within each lambda
## ---------------------------------------------------------

df_U$dim1_z <- NA_real_

for (l in unique(df_U$lambda)) {
  idx <- df_U$lambda == l
  df_U$dim1_z[idx] <- as.numeric(scale(df_U$dim1[idx]))
}

## Central lambda (previously selected optimal value)
lambda_central <- lambda_opt

df_central <- df_U[
  abs(df_U$lambda - lambda_central) ==
    min(abs(df_U$lambda - lambda_central)),
]

df_central <- df_central[!duplicated(df_central$country), ]

## ---------------------------------------------------------
## Pooled quadratic regression (robustness test)
## ---------------------------------------------------------

curve_fit <- lm(
  cost ~ poly(dim1_z, 2),
  data = df_U
)

summary(curve_fit)

}
}