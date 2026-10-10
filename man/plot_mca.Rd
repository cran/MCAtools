\name{plot_mca}
\alias{plot_mca}
\title{Plot Multiple Correspondence Analysis Results}
\description{
Produces 2D scatterplots from an MCA result object created by \code{mca_analysis}, displaying individuals and/or variable modalities on selected principal dimensions. The function provides several plot types (individuals, variables, or both) and allows customization of scaling and label size.
}

\usage{
plot_mca(custom_result, plot_type = "both", scaleplot = 1.0,
         dims = c(1, 2), mag = 1.0, plottype = "s",
         label_ind = TRUE, label_var = TRUE, legend_pos = "topright")
}

\arguments{
  \item{custom_result}{An MCA result list obtained from \code{mca_analysis}. The object must contain the elements \code{ind$coord}, \code{var$coord}, and \code{eig}.}
  \item{plot_type}{Character string indicating what to display. One of \code{"both"} (individuals and variables, default), \code{"ind"} (individuals only), or \code{"var"} (variables only).}
  \item{scaleplot}{Numeric. Scaling factor applied to determine x/y axis limits. Default is \code{1.0}.}
  \item{dims}{Integer vector of length two specifying which dimensions to plot (e.g. \code{c(1,2)}).}
  \item{mag}{Numeric. Magnification factor (similar to \code{cex}) for text labels. Default \code{1.0}.}
  \item{plottype}{Character, passed to \code{par(pty=)}. Common options: \code{"s"} (square) or \code{"m"} (maximized). Default \code{"s"}.}
  \item{label_ind}{Logical. If \code{TRUE} (the default), individual labels (row identifiers) are displayed on the plot. Set to \code{FALSE} to omit individual labels, which can improve readability when the number of observations is large.}
  \item{label_var}{Logical. If \code{TRUE} (the default), category (modality) labels are displayed on the plot. Set to \code{FALSE} to omit category labels, for example when combined with \code{mag} to emphasize the point cloud rather than the text.}
  \item{legend_pos}{Character string indicating the position of the legend, passed to \code{\link[graphics]{legend}}. Accepted values include \code{"topright"} (the default), \code{"topleft"}, \code{"bottomright"}, \code{"bottomleft"}, and other keywords accepted by \code{\link[graphics]{legend}}. Ignored when \code{plot_type} does not require a legend.}
}

\details{
The function extracts the coordinates of individuals and variable modalities for the selected dimensions and generates a biplot-like figure:
\itemize{
  \item Individuals (rows) are represented by blue '+' symbols.
  \item Variable modalities (columns) are represented by red '*' symbols.
}
Labels are automatically annotated beside their respective points.

The axes labels indicate the dimension number and its percentage of explained inertia (from \code{custom_result$eig}). A subtitle shows the cumulative percentage of total inertia explained by the displayed dimensions. Horizontal and vertical reference lines are drawn at zero.

If \code{plot_type = "ind"}, only individuals are shown; if \code{plot_type = "var"}, only variables are shown.
}

\value{
This function returns no value. It is used for its graphical output (a base R plot). The function produces a 2D plot of MCA results using the provided object.
}

\examples{
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

res_ord <- mca_analysis(
  data = df,
  id_ind = "iso_code",
  sup_ind = sup_rows,
  lambda = 1
)

# Plot individuals and variables together
plot_mca(
  res_ord,
  plot_type = "both",
  dims = c(1, 2),
  mag = 0.8
)

# Plot individuals only
plot_mca(
  res_ord,
  plot_type = "ind",
  dims = c(1, 2),
  mag = 0.8
)

# Plot variable modalities only
plot_mca(
  res_ord,
  plot_type = "var",
  dims = c(1, 2),
  mag = 0.8
)
}

\author{Awa Traoré, Assi Lazare N'GUESSAN, MOUSSA Kouamé Richard, Nona Servais KAMDEM SIMO, Muhamad Setyawan Bahari}
\seealso{\code{\link{mca_analysis}} for generating the MCA result used as input.}
\keyword{multivariate}
\keyword{hplot}