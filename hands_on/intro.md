# A parallel agent-based model in R

The hands-on sessions are about going through the code together and understanding what each line approximately does. 

## Introduction - `5 minutes`
1. Assign someone to be the timekeeper & someone else with experience with R/RStudio to be the screen-sharer.
2. Shortly (!) get to know each other. 

## Agent-based model - `20 minutes`
1. Open the file [`01_example_sim.R`](../01_example_sim.R) in RStudio.
2. Discuss and run the code until line 28.
3. What is the proportion of happiness in the last subpopulation in `result_2`?
4. Compile the `C++` version of the ABM using the code on line 33.
5. Now run the same ABM as in `result_2` by using the C++ version (line 36). Do you notice the speedup?
6. Run the rest of the file. Discuss what is happening.

## Parallel programming - `20 minutes`
1. Open the file [`02_parallel_eval.R`](../02_parallel_eval.R) in RStudio.
2. Run the file until line 22.
3. Run the following code: `analysis_function(1)`. Discuss what this does.
4. Now run & discuss the code until line 37. What does the plot show & what does the mean value represent?
5. Next, discuss & run the code until line 54. Edit the number of threads so that there are 1 or 2 threads left on your machine. For example, if `detectCores()` returns 8, then line 48 should be `n_threads <- 6` or `n_threads <- 7`.
6. Run & discuss the remainder of the file.