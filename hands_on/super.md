# Submitting an R array job

In this section, you will create a grid, define a job script, and submit an array job based on this.

## Creating the grid - `15 minutes`
1. Open the file [`03_create_grid.R`](../03_create_grid.R) in RStudio.
2. Go through & run the code step-by-step and explain / figure out with your group what each part does by inspecting the resulting objects.
3. After line 30, answer the following question: what is the purpose of the column `row` in the condition grid?

## An array job script in R - `15 minutes`
1. Open the file [`04_array_job.R`](../04_array_job.R) in RStudio.
2. Again, go through the file line-by-line figuring out what each line does, paying extra attention to the following questions. The clustering part you don't need to run (FORK clusters don't work on non-UNIX systems)
    - What does the function `plog` on line 18 do? Try it out with a few different texts.
    - What does the code starting on line 50 do?
    - In which chunk (job) is the 234287th line of the condition grid?
    - What will the output folder look like after all the chunks are done?
3. Go to the terminal (next to the console window in RStudio) and run the following code: 
    ```
    Rscript 04_array_job.R 12
    ``` 
    Explain what happens.


## Running the array job - `30 minutes`
1. Open the file [`05_array_job.sh`](../05_array_job.sh). What does this file do? How much time is scheduled for this job?
2. Give the job a nice name using `#SBATCH --job-name="name"`
3. Upload the whole folder to the supercomputer using the skills you acquired this morning.
4. Move to the just uploaded project folder using `cd`
5. Run the first three jobs on the supercomputer using the SLURM array notation:
    ```
    sbatch -a 1-3 05_array_job.sh
    ```
6. Now check your queue to see if the code runs! (`squeue`)
7. Monitor the progress of the first job using `cat logs/output.1.out`.
8. Talk through what is happening with your group.
