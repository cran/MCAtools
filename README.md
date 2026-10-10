# MCAtools

**Multiple Correspondence Analysis Toolkit (Phi-Divergence Framework)**

## Overview

MCAtools is an R package designed to perform **Multiple Correspondence Analysis (MCA)** using the **φ-divergence framework** introduced by **Cressie \& Read (1984)**. The package extends traditional MCA by allowing more general divergence measures, improving interpretability and robustness in categorical data analysis.

It provides three main functions:

* `mca\_analysis()` — performs MCA computation under the φ-divergence framework.
* `plot\_mca()` — visualizes individuals and variable modalities on the selected principal dimensions.
* `generate\_mca\_equation()` — produces a symbolic or algebraic representation of the MCA dimensions for analytical interpretation.

## Installation

You can install the development version directly from GitHub:

```r
# install.packages("devtools")
devtools::install\_github("nskamdem/MCAtools")
```

## Usage Example

```r
library(MCAtools)

# Sample dataset
data <- data.frame(
  Var1 = factor(sample(c("A", "B", "C"), 30, TRUE)),
  Var2 = factor(sample(c("X", "Y", "Z"), 30, TRUE))
)

# Run MCA analysis
res <- mca\_analysis(data, delta = 1)

# Visualize MCA results
plot\_mca(res, plot\_type = "both")

# Generate symbolic equation
generate\_mca\_equation(res)
```

## Reference

Cressie, N. A., \& Read, T. R. C. (1984). *Goodness-of-Fit Statistics for Discrete Multivariate Data.* **Journal of the Royal Statistical Society, Series B (Methodological)**, 46(3), 440–464.

## Author

&#x20; 
Maintainer: [nona.kamdem@gmail.com](mailto:nona.kamdem@gmail.com)

## License

GPL-3

