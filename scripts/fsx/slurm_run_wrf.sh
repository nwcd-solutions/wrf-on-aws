#!/bin/bash 
#SBATCH --error=job.err
#SBATCH --output=job.out
#SBATCH --time=24:00:00
#SBATCH --job-name=wrf
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
module load openmpi
cd /fsx/FORECAST/domains/test/run
mpirun  ./wrf.exe
