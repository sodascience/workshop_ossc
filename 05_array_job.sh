#!/bin/bash

# usage: sbatch -a 1-100 05_array_job.sh

# Array job shell script which runs R code
# last edited 2024-09-04 by @vankesteren
# ODISSEI Social Data Science team

# Set job requirements
#SBATCH -n 1
#SBATCH -t 00:45:00
#SBATCH -o ./logs/output.%a.out # STDOUT
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=e.vankesteren1@uu.nl


# Loading modules
module load 2023
module load R/4.3.2-gfbf-2023a

# Run the script
Rscript "04_array_job.R" $SLURM_ARRAY_TASK_ID
