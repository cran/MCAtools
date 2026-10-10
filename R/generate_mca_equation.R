generate_mca_equation <- function(mca_result,
                                  dimension = 1,
                                  top = 5,
                                  digits = 4) {
  
  ## -------------------------------------------------
  ## Minimal structural checks
  ## -------------------------------------------------
  if (is.null(mca_result$var) || is.null(mca_result$var$coord)) {
    stop("mca_result must contain $var$coord.")
  }
  
  coord_mat <- mca_result$var$coord
  
  if (!is.matrix(coord_mat) && !is.data.frame(coord_mat)) {
    stop("$var$coord must be a matrix or data.frame.")
  }
  
  if (dimension < 1 || dimension > ncol(coord_mat)) {
    stop("Invalid dimension index.")
  }
  
  ## -------------------------------------------------
  ## Coordinates
  ## -------------------------------------------------
  coord <- as.numeric(coord_mat[, dimension])
  names_mod <- rownames(coord_mat)
  
  ## -------------------------------------------------
  ## Contributions (safe reconstruction)
  ## -------------------------------------------------
  if (!is.null(mca_result$var$contrib)) {
    
    contrib_mat <- mca_result$var$contrib
    if (is.matrix(contrib_mat) || is.data.frame(contrib_mat)) {
      contrib <- as.numeric(contrib_mat[, dimension])
    } else {
      contrib <- coord^2
    }
  } else {
    contrib <- coord^2
  }
  
  ## Normalisation (%)
  contrib <- 100 * contrib / sum(contrib, na.rm = TRUE)
  
  ## -------------------------------------------------
  ## Ordering
  ## -------------------------------------------------
  ord <- order(abs(contrib), decreasing = TRUE)
  ord <- ord[seq_len(min(top, length(ord)))]
  
  coord <- coord[ord]
  contrib <- contrib[ord]
  names_mod <- names_mod[ord]
  
  ## -------------------------------------------------
  ## Equation (ASCII-only, signed terms)
  ## -------------------------------------------------
  terms <- ifelse(
    coord >= 0,
    paste0("+ ", round(coord, digits), " x ", names_mod),
    paste0("- ", round(abs(coord), digits), " x ", names_mod)
  )
  
  
  equation <- paste(terms, collapse = " ")
  ## Remove the leading "+ " for a cleaner first term
  equation <- sub("^\\+ ", "", equation)
  
  ## -------------------------------------------------
  ## Output
  ## -------------------------------------------------
  list(
    dimension = dimension,
    equation = paste0("Dim", dimension, " = ", equation),
    table = data.frame(
      modality = names_mod,
      coordinate = coord,
      contribution = round(contrib, 2),
      row.names = NULL
    )
  )
}