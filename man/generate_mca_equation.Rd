\name{generate_mca_equation}
\alias{generate_mca_equation}
\title{Extract a Symbolic Equation for an MCA Dimension}

\description{
Generates a symbolic representation of a selected dimension from a Multiple Correspondence Analysis (MCA) result.
The equation highlights the modalities that contribute most to the chosen dimension, based on their coordinates
and reconstructed contributions.
}

\usage{
generate_mca_equation(
  mca_result,
  dimension = 1,
  top = 5,
  digits = 4
)
}

\arguments{
  \item{mca_result}{
  An object returned by \code{mca_analysis}, containing at least the component
  \code{$var$coord}. If available, \code{$var$contrib} is used; otherwise,
  contributions are reconstructed from squared coordinates.
  }

  \item{dimension}{
  Integer. Index of the MCA dimension for which the equation is extracted.
  Default is \code{1}.
  }

  \item{top}{
  Integer. Number of most contributing modalities to include in the equation.
  Default is \code{5}.
  }

  \item{digits}{
  Integer. Number of digits used to round the coefficients in the symbolic equation.
  Default is \code{4}.
  }
}

\details{
For the selected dimension, the function extracts modality coordinates from the MCA result.
If contribution values are not explicitly available, they are reconstructed as squared
coordinates and normalized to sum to 100.

The symbolic equation is formed by retaining the \code{top} modalities with the highest
absolute contributions. This provides an interpretable approximation of the latent axis
in terms of the most influential modalities.

This approach is particularly useful in generalized or phi-divergence-based MCA settings,
where classical contribution tables may not always be stored explicitly.
}

\value{
A list with the following components:
\item{dimension}{The selected MCA dimension.}
\item{equation}{A character string representing the symbolic equation of the dimension.}
\item{table}{A data frame containing the selected modalities, their coordinates,
  and their percentage contributions.}
}

\examples{
# Example usage:
## Load package
library(MCAtools)

## Load data
data(electricity_africa)

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

res_ord <- mca_analysis(
  data = df,
  id_ind = "iso_code",
  sup_ind = sup_rows,
  lambda = 1
)

eq1 <- generate_mca_equation(
  mca_result = res_ord,
  dimension = 1,
  top = 6
)

eq1$equation
eq1$table
}
\author{Awa Traoré, Assi Lazare N'GUESSAN, MOUSSA Kouamé Richard, Nona Servais KAMDEM SIMO, Muhamad Setyawan Bahari}
\seealso{\code{\link{mca_analysis}} for computing MCA results.}
\keyword{multivariate}