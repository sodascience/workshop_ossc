library(Rcpp)
sourceCpp("./src/update_cpp.cpp")

#' Run schelling simulation
#' 
#' Allows for any number of subpopulations
#'
#' @param prop vector of proportions of populations
#' @param free proportion of free cells
#' @param Ba proportion of desired similar neighbours
#' @param R neighbour distance to consider for similarity
#' @param N width & height of the grid
#' @param max_iter maximum iterations
#' @param anim if true, show intermediate steps
#'
#' @return list #' 
#' 
#' @export
abm_cpp <- function(prop, free = 0.25, Ba = 1/2, R = 1L, N = 51L, iter = 50L, anim = FALSE, use_tol = TRUE) {
  # preprocess prop
  if (all(is.na(prop))) return(NA)
  prop <- prop / sum(prop, na.rm = FALSE)
  prop[is.na(prop)] <- 0
  prop <- c(free/(1-free), prop) / (1 + free/(1-free))
  
  # additional parameters
  K <- length(prop) - 1
  
  # create initial state
  pop <- sample(
    x = 0L:K,
    size = N*N, 
    replace = TRUE,
    prob = prop
  )
  
  M <- matrix(data = pop, nrow = N)
  H <- matrix(data = FALSE, nrow = N, ncol = N)
  
  if (anim) plot_state(M, main = 0)
  h_prev <- .total_happy(M, H)
  for (i in 1:iter) {
    # cpp modifies in-place!
    .cpp_updateH(H, M, Ba, R, N)
    moved <- .cpp_updateM(H, M, N)
    h_cur <- .total_happy(M, H)
    if (anim) {
      flush.console()
      dev.flush()
      plot_state(M, main = i)
      Sys.sleep(0.05)
    }
    h_prev <- h_cur
  }
  return(list(M = M, H = H, h_tot = h_cur, h_prop = .happy_per_group(M, H), iter = i))
}

.total_happy <- function(M, H) {
  mean(H[M != 0])
}

.happy_per_group <- function(M, H) {
  sapply(1:(length(unique(c(M)))-1), \(k) mean(H[M == k]))
}

plot_state <- function(M, col = c("#3030a3", "#dd7373", "#499293", "#30602d", "#e2bd36"), ...) {
  Mna <- M
  Mna[M==0] <- NA
  image(Mna, asp = 1, bty = "n", axes = FALSE, useRaster = TRUE, col = col, ...)
}