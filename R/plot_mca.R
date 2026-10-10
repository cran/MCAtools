#' @importFrom graphics legend

plot_mca <- function(custom_result,
                     plot_type = "both",
                     scaleplot = 1.0,
                     dims = c(1, 2),
                     mag = 1.0,
                     plottype = "s",
                     label_ind = TRUE,
                     label_var = TRUE,
                     legend_pos = "topright") {
  
  ## -------------------------------------------------
  ## Checks
  ## -------------------------------------------------
  if (length(dims) != 2) {
    stop("Please provide exactly two dimensions to plot.")
  }
  
  dim1 <- dims[1]
  dim2 <- dims[2]
  
  ## -------------------------------------------------
  ## Eigenvalues safety extraction
  ## -------------------------------------------------
  eig <- custom_result$eig
  
  if (!is.data.frame(eig) && !is.matrix(eig)) {
    stop("custom_result$eig must be a matrix or data.frame.")
  }
  
  if (!all(c("percentage", "cumulative") %in% colnames(eig))) {
    stop("custom_result$eig must contain columns 'percentage' and 'cumulative'.")
  }
  
  
  perc1 <- as.numeric(eig[dim1, "percentage"])
  perc2 <- as.numeric(eig[dim2, "percentage"])
  cum2  <- as.numeric(eig[dim2, "cumulative"])
  
  ## -------------------------------------------------
  ## Coordinates
  ## -------------------------------------------------
  f.s1 <- custom_result$ind$coord[, dim1]
  f.s2 <- custom_result$ind$coord[, dim2]
  g.s1 <- custom_result$var$coord[, dim1]
  g.s2 <- custom_result$var$coord[, dim2]
  
  Z <- custom_result$Z
  
  ## -------------------------------------------------
  ## Plot setup
  ## -------------------------------------------------
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  par(pty = plottype)
  
  xlim <- scaleplot * range(c(f.s1, g.s1), na.rm = TRUE)
  ylim <- scaleplot * range(c(f.s2, g.s2), na.rm = TRUE)
  
  plot(0, 0, pch = " ",
       xlim = xlim, ylim = ylim,
       xlab = paste0("Principal Axis ", dim1, " (", round(perc1, 2), "%)"),
       ylab = paste0("Principal Axis ", dim2, " (", round(perc2, 2), "%)"))
  
  title(
    main = "Multiple Correspondence Analysis",
    
    sub  = paste0("[2D TOTAL INERTIA = ", round(cum2, 2), "%]")
  )
  
  abline(h = 0, v = 0, col = "grey70")
  
  ## -------------------------------------------------
  ## Individuals
  ## -------------------------------------------------
  if (plot_type %in% c("both", "ind")) {
    points(f.s1, f.s2, pch = 3, col = "blue")
    
    if (label_ind) {
      text(f.s1, f.s2,
           labels = rownames(Z),
           pos = 1,
           col = "blue",
           cex = mag)
    }
  }
  
  ## -------------------------------------------------
  ## Variables (categories)
  ## -------------------------------------------------
  if (plot_type %in% c("both", "var")) {
    points(g.s1, g.s2, pch = 8, col = "red")
    
    if (label_var) {
      text(g.s1, g.s2,
           labels = colnames(Z),
           pos = 3,
           col = "red",
           cex = mag)
      
    }
  }
  
  ## -------------------------------------------------
  ## Legend
  ## -------------------------------------------------
  if (plot_type == "both") {
    legend(legend_pos,
           legend = c("Individuals", "Categories"),
           col    = c("blue", "red"),
           pch    = c(3, 8),
           bty    = "n",
           cex    = 0.9)
  }
}