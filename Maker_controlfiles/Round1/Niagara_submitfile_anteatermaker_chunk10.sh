#!/bin/bash
#SBATCH --nodes=1 #
#SBATCH --ntasks-per-node=1#
#SBATCH --cpus-per-task=40
#SBATCH --mem=0 #set to 0 to use all available memory of each requested node. Advatage, any of the ntasks of each node can use any amount of the memory provided to sum does not exceed thata available to the node
#SBATCH --time=13:00:00
#SBATCH --job-name Anteater_Maker_Round1
#SBATCH --output=OUTPUT_R1_10_%.txt

#export paths
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/RepeatMasker 
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/snap 
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/snap/Zoe 
export ZOE=/gpfs/fs0/project/j/jweir/tools/snap/Zoe
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/exonerate-2.2.0-x86_64/bin
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/maker/bin
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/snoscan-0.9.1
export PATH=$PATH:/gpfs/fs0/project/j/jweir/tools/tRNAscan-SE-2.0
export LD_PRELOAD=/cvmfs/soft.computecanada.ca/easybuild/software/2017/avx512/Compiler/gcc7.3/openmpi/3.1.2/lib/libmpi.so

#load modules
module load NiaEnv
module load CCEnv
module load StdEnv
module load intel/2019.3
module load nixpkgs/16.09
module load gcccore/.8.3.0
module load gcc/7.3.0
module load perl/5.22.4
module load bioperl/1.7.1 #1.7.5
module load exonerate/2.4.0
module load trf/4.09
module load rmblast/2.9.0
module load blast+/2.7.1
module load openmpi/3.1.2
module load augustus/3.3

export OMP_NUM_THREADS=40

#User sets these options
WD=/project/j/jweir/0_MAKER/anteater

#automated code to run (don't change)
   cd $WD
   #job10
   (maker -cpus 10 -base Anteater_input -g Anteater_input_036.fasta) &
   (maker -cpus 10 -base Anteater_input -g Anteater_input_037.fasta) &
   (maker -cpus 10 -base Anteater_input -g Anteater_input_038.fasta) &
   (maker -cpus 10 -base Anteater_input -g Anteater_input_039.fasta) &
wait
