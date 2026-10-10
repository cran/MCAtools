\name{mca_analysis}
\alias{mca_analysis}
\title{Multiple Correspondence Analysis with lambda-divergence and supplementary qualitative variables}
\description{
Performs a Multiple Correspondence Analysis (MCA) on a data.frame of categorical variables using a general lambda-divergence residuals formulation. The function builds the indicator matrix, computes joint proportions, constructs residuals depending on the 'lambda' parameter, performs a singular value decomposition (SVD) and returns coordinates, contributions, cos2, eta2, v-test for active variables and optionally handles supplementary qualitative and quantitative variables and supplementary individuals.
}

\usage{mca_analysis(data,
                         id_ind = NULL,
                         sup_ind = NULL, 
                         sup_qual = NULL, 
                         sup_quant = NULL, 
                         lambda = 1, 
                         nonzero = 0.05, 
                         dim1 = 1, dim2 = 2,
                         plottype = "s", 
                         giveplot = TRUE, 
                         mag = 0.8, 
                         acc = 5, 
                         scaleplot = 1.2)
}

\arguments{
  \item{data}{A data.frame (or tibble) where each column is a factor (categorical variable). Each factor's levels are treated as the modalities used to build the indicator matrix.}
  \item{id_ind}{An optional character string giving the name of the column in \code{data} that contains individual identifiers. This column is not used to compute the analysis dimensions but is used to label individuals in the output. Required when \code{sup_ind} is supplied. Default is \code{NULL}.}
  \item{sup_ind}{An optional integer vector. If supplied, this vector is used to identify individuals (observations) that will be isolated as supplementary individuals. These individuals are not used to compute the analysis dimensions but their coordinates are computed a posteriori and returned in \code{ind_sup}. Default is \code{NULL}.}
  \item{sup_qual}{An optional data.frame with supplementary qualitative (categorical) variables, aligned row-for-row with \code{data}. If supplied, these variables are not used to compute the analysis dimensions but their group-mean coordinates and \eqn{\eta^2} are computed a posteriori. Default is \code{NULL}.}
  \item{sup_quant}{An optional data.frame with supplementary quantitative (numeric) variables, aligned row-for-row with \code{data}. If supplied, these variables are not used to compute the analysis dimensions but their correlations with the individual coordinates are computed a posteriori. Default is \code{NULL}.}
  \item{lambda}{Numeric. Divergence parameter used to compute residuals. Common values: 1 (default, standard MCA / chi-square residuals formulation), 0 (log-based, Kullback-Leibler-type alternative), -1 (reverse Kullback-Leibler-type special case). The function contains safeguarded computations (small offsets) to avoid division by zero.}
  \item{nonzero}{Numeric scalar. Small positive value used in the \code{lambda == 0} branch to replace zero cell probabilities. Default \code{0.05}.}
  \item{dim1}{Integer. First dimension index, kept for interface compatibility with \code{\link{plot_mca}}. Default is 1.}
  \item{dim2}{Integer. Second dimension index, kept for interface compatibility with \code{\link{plot_mca}}. Default is 2.}
  \item{plottype}{Character, kept for interface compatibility with \code{\link{plot_mca}}. Default \code{"s"}.}
  \item{giveplot}{Logical, kept for interface compatibility with \code{\link{plot_mca}}. Default \code{TRUE}.}
  \item{mag}{Numeric, kept for interface compatibility with \code{\link{plot_mca}}. Default \code{0.8}.}
  \item{acc}{Integer. Number of decimal digits used when rounding reported summary statistics such as Chi-squared, total inertia, and the p-value. Default \code{5}.}
  \item{scaleplot}{Numeric, kept for interface compatibility with \code{\link{plot_mca}}. Default \code{1.2}.}
}

\details{
This implementation follows these main steps:
\enumerate{
  \item Build the indicator (dummy) matrix \eqn{Z} from the factor columns of \code{data}. The number of columns of \eqn{Z} equals the total number of modalities across variables.
  \item Compute the joint proportions matrix \eqn{P = Z / sum(Z)}, row and column margins (\eqn{p_{i.}} and \eqn{p_{.j}}), and the independence matrix \eqn{E = p_{i.} p_{.j}^\top}.
  \item Compute residuals \eqn{r_{ij}} using the chosen \code{lambda} divergence. Three branches are implemented: general \code{lambda} (not 0 or -1), \code{lambda == 0} (log-based form with replacement of zeros by \code{nonzero}), and \code{lambda == -1} (special formulation). Tiny offsets (e.g. 1e-13) are added to avoid numerical instabilities.
  \item Perform singular value decomposition (SVD) of the residual matrix \eqn{r} and compute singular values, principal coordinates for individuals and variables, contributions, cos2, v-test, and eta-squared statistics.
  \item If \code{sup_ind} is provided, project the corresponding individuals onto the estimated factorial space using the same divergence branch as for active individuals (the branch is re-selected for the supplementary residuals, so the projection is consistent for \code{lambda = 0} and \code{lambda = -1} as well).
  \item If \code{sup_qual} is provided, compute supplementary coordinates as group means of individual coordinates and compute \eqn{\eta^2} for each supplementary variable and each dimension.
  \item If \code{sup_quant} is provided, compute the correlation between each supplementary quantitative variable and the individual coordinates on each dimension.
}

Note: Input columns of \code{data} should be factors. If they are character vectors, convert using \code{data[] <- lapply(data, factor)} prior to calling the function.

The arguments \code{dim1}, \code{dim2}, \code{plottype}, \code{giveplot}, \code{mag}, and \code{scaleplot} are accepted for interface compatibility with \code{\link{plot_mca}} but do not affect the computations of \code{mca_analysis}; no plot is produced by this function.
}

\value{
A list with components:
\describe{
  \item{eig}{A data.frame of eigenvalues and percentage of explained inertia per dimension and cumulative percentage.}
  \item{ind}{A list with individual results: \code{coord} (data.frame of individual coordinates), \code{contrib} (contribution percentages for individuals), and \code{cos2} (quality of representation).}
  \item{var}{A list with active-modality results: \code{coord} (data.frame of modality coordinates), \code{contrib} (contribution percentages of modalities), \code{cos2} (modalities' cos2), \code{v.test} (v-test values), and \code{eta2} (eta-squared per active variable and dimension).}
  \item{var_sup}{If \code{sup_qual} was provided, a list with \code{coord} (a list of data.frames, one per supplementary qualitative variable, giving the group-mean coordinates of its modalities) and \code{eta2} (data.frame of \eqn{\eta^2} per supplementary variable and dimension). Otherwise \code{NULL}.}
  \item{quanti_sup}{If \code{sup_quant} was provided, a data.frame of correlations between each supplementary quantitative variable and the individual coordinates, with dimensions as rows. Otherwise \code{NULL}.}
  \item{ind_sup}{If \code{sup_ind} was provided, a data.frame of the projected coordinates of the supplementary individuals. Otherwise \code{NULL}.}
  \item{Z}{The indicator matrix (as a data.frame) used in the analysis.}
  \item{lambda}{The chosen \code{lambda} value (numeric), as supplied by the user.}
  \item{Chi.Squared}{Numeric. Rounded Chi-squared statistic used for testing association.}
  \item{Total.Inertia}{Numeric. Rounded total inertia (sum of principal inertias).}
  \item{P.Value}{Numeric. Rounded p-value for the Chi-squared test.}
}

All numeric matrices/data.frames indexed by dimension have column names \code{Dim1}, \code{Dim2}, ... corresponding to components extracted from the SVD.
}

\references{See standard texts on Multiple Correspondence Analysis and phi-divergence approaches for related formulations.}

\author{Awa Traoré, Assi Lazare N'GUESSAN, MOUSSA Kouamé Richard, Nona Servais KAMDEM SIMO, Muhamad Setyawan Bahari}

\seealso{\code{\link{plot_mca}} for visualizing MCA results, and \code{\link{generate_mca_equation}} for extracting a symbolic interpretation of a dimension.}

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
## 2.Ordinnary MCA (lambda = 1)
## -------------------------------------------------

res_ord <- mca_analysis(
  data = df,
  id_ind = "iso_code",
  sup_ind = sup_rows,
  lambda = 1
)

res_ord$eig$percentage[1]

}

\keyword{multivariate}