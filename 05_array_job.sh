#!/bin/bash

# usage: sbatch -a 1-100 05_array_job.sh

# Array job shell script which runs R code
# last edited 2024-09-25 by @vankesteren
# ODISSEI Social Data Science team

# Set job requirements
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=00:15:00
#SBATCH --partition=rome
#SBATCH --output=./logs/output.%a.out
#SBATCH --error=./logs/output.%a.err

# Loading modules
module load 2023
module load R-bundle-CRAN/2023.12-foss-2023a

# Run the script
Rscript "04_array_job.R" $SLURM_ARRAY_TASK_ID
