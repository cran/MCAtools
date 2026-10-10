mca_analysis <- function(data, 
                         id_ind = NULL,
                         sup_ind = NULL, 
                         sup_qual = NULL, 
                         sup_quant=NULL, 
                         lambda = 1, 
                         nonzero = 0.05, 
                         dim1 = 1, dim2 = 2,
                         plottype = "s", 
                         giveplot = TRUE, 
                         mag = 0.8, 
                         acc = 5, 
                         scaleplot = 1.2) {
  
  # ==================================================
  # 1. Séparation individus actifs / supplémentaires
  # ==================================================
  
  if (!is.null(sup_ind)) {
    
    # sup_ind est interprété comme indices de lignes
    sup_ind <- as.integer(sup_ind)
    
    # Sécurité
    if (any(sup_ind < 1 | sup_ind > nrow(data))) {
      stop("sup_ind contient des indices hors limites")
    }
    
    data_sup <- data[sup_ind, , drop = FALSE]
    data_active_full <- data[-sup_ind, , drop = FALSE]
    
  } else {
    
    
    data_active_full <- data
    data_sup <- NULL
    
  }
  
  # ==================================================
  # 2. Exclusion variables non actives
  # ==================================================
  
  exclude_vars <- character(0)
  if (!is.null(id_ind)) exclude_vars <- c(exclude_vars, id_ind)
  if (!is.null(sup_qual)) exclude_vars <- c(exclude_vars, names(sup_qual))
  
  data_active <- data_active_full[, setdiff(names(data_active_full), exclude_vars), drop = FALSE]
  
  I <- nrow(data_active)
  J <- ncol(data_active)
  
  #print(I)
  ind_names <- if (!is.null(id_ind)) {
    as.character(data_active_full[[id_ind]])
  } else {
    rownames(data_active)
  }
  
  # ==================================================
  # 3. Construction de la matrice disjonctive Z
  # ==================================================
  
  lev.n <- sapply(data_active, nlevels)
  Jt <- sum(lev.n)
  
  
  Z <- matrix(0, nrow = I, ncol = Jt)
  offset <- c(0, cumsum(lev.n)[-length(lev.n)])
  newdat <- lapply(data_active, as.numeric)
  
  for (j in seq_len(J)) {
    Z[cbind(seq_len(I), offset[j] + newdat[[j]])] <- 1
  }
  
  colnames(Z) <- paste(rep(names(data_active), lev.n),
                       unlist(lapply(data_active, levels)),
                       sep = ":")
  rownames(Z) <- ind_names
  
  # ==================================================
  # 4. Probabilités et résidus φ-divergence
  # ==================================================
  
  P <- Z / sum(Z)
  pidot <- rowSums(P)
  pdotj <- colSums(P)
  
  r <- matrix(0, I, Jt)
  
  if (lambda != 0 && lambda != -1) {
    r <- ((P + 1e-13)^lambda -
            (pidot %*% t(pdotj) + 1e-13)^lambda) /
      ((pidot %*% t(pdotj) + 1e-13)^(lambda / 2))
  } else if (lambda == 0) {
    P[P == 0] <- nonzero
    r <- -sqrt(pidot %*% t(pdotj)) * log((pidot %*% t(pdotj)) / P)
  } else {
    
    r <- ((pidot %*% t(pdotj)) * ((pidot %*% t(pdotj)) - P)) /
      (P + 1e-13)
  }
  
  # ==================================================
  # 5. SVD et coordonnées
  # ==================================================
  
  svd_res <- svd(r)
  lambda <- svd_res$d^2
  
  F <- sweep(svd_res$u %*% diag(svd_res$d), 1, sqrt(pidot), "/")
  G <- sweep(svd_res$v %*% diag(svd_res$d), 1, sqrt(pdotj), "/")
  
  colnames(F) <- colnames(G) <- paste0("Dim", seq_len(ncol(F)))
  rownames(F) <- ind_names
  rownames(G) <- colnames(Z)
  
  # ==================================================
  # 6. Inerties
  # ==================================================
  
  eig <- lambda / sum(lambda)
  eig_df <- data.frame(
    eigenvalue = eig,
    percentage = eig * 100,
    cumulative = cumsum(eig * 100)
  )
  rownames(eig_df) <- colnames(F)
  
  # ==================================================
  # 7. PROJECTION DES INDIVIDUS SUPPLÉMENTAIRES
  
  # ==================================================
  
  sup_ind_coord <- NULL
  
  if (!is.null(data_sup)) {
    
    data_sup_active <- data_sup[, colnames(data_active), drop = FALSE]
    
    Z_sup <- matrix(0, nrow = nrow(data_sup_active), ncol = Jt)
    new_sup <- lapply(data_sup_active, as.numeric)
    
    for (j in seq_len(J)) {
      Z_sup[cbind(seq_len(nrow(Z_sup)), offset[j] + new_sup[[j]])] <- 1
    }
    
    rownames(Z_sup) <- as.character(data_sup[[id_ind]])
    colnames(Z_sup) <- colnames(Z)
    
    P_sup <- Z_sup / sum(Z)
    pidot_sup <- rowSums(P_sup)
    
    r_sup <- ((P_sup + 1e-13)^lambda -
                (pidot_sup %*% t(pdotj) + 1e-13)^lambda) /
      ((pidot_sup %*% t(pdotj) + 1e-13)^(lambda / 2))
    
    sup_ind_coord <- sweep(r_sup %*% svd_res$v, 1, sqrt(pidot_sup), "/")
    #print(sup_ind_coord)
    colnames(sup_ind_coord) <- colnames(F)
  }
  
  # ==================================================
  # 8. Sortie finale
  
  # ==================================================
  
  list(
    eig = eig_df,
    ind = list(coord = as.data.frame(F)),
    var = list(coord = as.data.frame(G)),
    ind_sup = sup_ind_coord,
    lambda = lambda
  )
}