#' Run schelling simulation
#' 
#' Allows for any number of subpopulations
#'
#' @param prop vector of proportions of populations
#' @param free proportion of free cells
#' @param Ba proportion of desired similar neighbours
#' @param R neighbour distance to consider for similarity
#' @param N width & height of the grid
#' @param iter maximum iterations
#' @param anim if true, show intermediate steps
#'
#' @return list
#' 
#' @export
abm <- function(prop, free = 0.25, Ba = 1/2, R = 1L, N = 51L, iter = 50L, anim = FALSE) {
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
    H <- .updateH(M, H, Ba, R, N)
    M <- .updateM(M, H)
    h_cur <- .total_happy(M, H)
    if (anim) {
      plot_state(M, main = i)
      Sys.sleep(0.15)
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

.updateH <- function(M, H, Ba, R, N) {
  # loop over all people
  for (i in 1:N) {
    for (j in 1:N) {
      this_state <- M[i,j]
      if (this_state == 0) {
        H[i,j] <- TRUE # empty cell, never move
        next
      }
      
      # is person i,j happy?
      B <- .compute_B(i, j, this_state, M, R)
      H[i,j] <- B > Ba
    }
  }
  return(H)
}

.updateM <- function(M, H) {
  # move unhappy to random location
  id_open <- which(M == 0)
  id_move <- which(!H)
  if (length(id_move) > 1) id_move <- sample(id_move)
  l_open  <- length(id_open)
  for (l in id_move) {
    m <- sample(l_open, 1)
    M[id_open[m]] <- M[l]
    M[l] <- 0
    id_open[m] <- l
  }
  return(M)
}


.compute_B <- function(i, j, class, M, R) {
  idx <- .get_neighbourhood(i, j, nrow(M), R)
  m <- M[idx$x, idx$y]
  similar <- sum(m[m!=0] == class) - 1
  total <- sum(m!=0) - 1
  b <- similar/total
  if (is.nan(b)) b <- 0
  return(b)
}

.get_neighbourhood <- function(i, j, N, R) {
  lo_x <- if (i <= R) 1 else i - R
  hi_x <- if ((N - i) < R) N else i + R
  lo_y <- if (j <= R) 1 else j - R
  hi_y <- if ((N - j) < R) N else j + R
  list(x = lo_x:hi_x, y = lo_y:hi_y)
}