The Willisornis vidua nigrigula genome was assembled using Supernova.

```bash
cat > 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_450mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_450mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__450milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=450000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```
```bash
cat > 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_500mill.sh
```
```bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_500mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__500milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=500000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS

```
```bash
cat > 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_550mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_550mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__550milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=550000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```

```bash
cat > 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_600mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_600mill
#SBATCH --output=OUTPUT_TEST_600mill_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__550milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=600000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```
```bash
cat > 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_650mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_650mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__650milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=650000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```
```bash
cat 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_700mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_700mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__700milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=700000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```
```bash
cat 0_GRAHAM_submitFile__ChromiumXSupernova_Willisornis_750mill.sh
```
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=240G
#SBATCH --time=53:59:00
#SBATCH --job-name weir_ChromiumX_Xiphorhynchus_750mill
#SBATCH --output=OUTPUT_TEST1_%.txt

module load supernova/2.1.1

# EXECUTION COMMAND; 
export OMP_NUM_THREADS=32

#User sets these options
   WD=/scratch/jweir
   SAMPLE=Willisornis_JTW11144
   VERSION=__750milReads__2019Nov12
   OUTPUT=/scratch/jweir/0_WEIRLAB_GENOMES/0_ASSEMBLIES/$SAMPLE$VERSION
   INPUT1=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2017Sept
   INPUT2=/scratch/jweir/0_WEIRLAB_GENOMES/0_RAW_GENOMIC_DATA/Willisornis_poecilinotus_JTW1144/2018Jan

   NCORES=32
   LOCALMEM=220
   MAXREADS=750000000


  #automated code to run (don't change)
   ASSEMBLY=$SAMPLE$VERSION
   mkdir $OUTPUT
   cd $OUTPUT
   supernova run --id=$ASSEMBLY \
              --fastqs=$INPUT1,$INPUT2 --sample=4717-JW-0008,4717-JW-0008 \
              --localcores=$NCORES   --localmem=$LOCALMEM --maxreads=$MAXREADS
```