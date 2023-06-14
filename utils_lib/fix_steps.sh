#!/bin/bash

# SBATCH --job-name=FIX
# SBATCH --account=kg98
# SBATCH --ntasks=1
# SBATCH --cpus-per-task=4
# SBATCH --time=0:40:00
# SBATCH --export=ALL
# SBATCH --mem-per-cpu=16G

# Run this after running run_fix_hcp.sh - This script runs fix in 3 steps: feature extraction; labelling components; and removing noise.
# script takes ~20min to run
# This runs with highpass filter = 2000 and using HCP_hp2000 training set

export fix_dir=/usr/local/fix/1.068/bin
export output=~/kg98/Priscila/GPIP_HCP-EP_clean/hcp_output/sub-${s}/MNINonLinear/Results/task-rest_run-${r}_bold/task-rest_run-${r}_bold_hp2000.ica

${fix_dir}/fix -f ${output} # extract features

${fix_dir}/fix -c ${output} ${fix_dir}/training_files/HCP_hp2000.RData 10 # creating a file with component labels - using a threshold = 10

${fix_dir}/fix -a ${output}/fix4melview_HCP_hp2000_thr10.txt -m -h 2000 # removing noise components, not aggressive cleanup, highpass filter = 2000

echo fix donde $s $r


