#include <Rcpp.h>
using namespace Rcpp;


int count_if_mat(IntegerMatrix& m, int ref) {
  int counter = 0;
  for (int i = 0; i < m.nrow(); i ++) {
    for (int j = 0; j < m.ncol(); j ++) {
      if (m(i,j) == ref) counter++;
    }
  }
  return counter;
}

IntegerMatrix get_neighbourhood(int i, int j, int R, int N, IntegerMatrix& M) {
  // get neighbourhood
  int lo_x = (i < R) ? 0 : i - R;
  int hi_x = ((N - 1 - i) < R) ? N - 1 : i + R;
  int lo_y = (j < R) ? 0 : j - R;
  int hi_y = ((N - 1 - j) < R) ? N - 1 : j + R;
  return M(Range(lo_x, hi_x), Range(lo_y, hi_y));
}

double compute_b(int i, int j, int state, IntegerMatrix& M, int R, int N) {
  IntegerMatrix hood = get_neighbourhood(i, j, R, N, M);
  int similar = count_if_mat(hood, state) - 1;
  int empty = count_if_mat(hood, 0);
  int total = hood.nrow() * hood.ncol() - empty - 1;
  return (double)similar / (double)total;
}

// [[Rcpp::export(.cpp_updateH)]]
void cpp_updateH(LogicalMatrix& H, IntegerMatrix& M, double Ba, int R, int N) {
  int state;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      state = M(i,j);
      if (state == 0) {
        H(i,j) = true; // empty cell, never move
        continue;
      }
      H(i,j) = compute_b(i, j, state, M, R, N) > Ba;
    }
  }
}

// [[Rcpp::export(.cpp_updateM)]]
bool cpp_updateM(LogicalMatrix& H, IntegerMatrix& M, int N) {
  // find open ids & move ids
  IntegerVector id_open;
  IntegerVector id_move;
  for (int i = 0; i < (N*N); i ++) {
    if (M[i] == 0) id_open.push_back(i);
    if (!H[i]) id_move.push_back(i);
  }
  
  if ((id_move.length() == 0) | (id_open.length() == 0)) {
    return false; // no moves
  }
  
  int l;
  int val;
  for (int k = 0; k < id_move.length(); k++) {
    l = sample(id_open.length() - 1, 1)[0]; // pick random idx from id_open
    //Rcout << " moving " << id_move[k] << " to " << id_open[l] << " (" << M[id_move[k]] << ")" <<"\n";
    val = M[id_move[k]];
    M[id_open[l]] = val;
    M[id_move[k]] = 0;
    id_open[l] = id_move[k];
  }
  return true; // we moved
}
