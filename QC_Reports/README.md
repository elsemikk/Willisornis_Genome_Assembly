This folder contains the quality control data for the sequencing reads.

1) **Raw sequence reports**
* `4717-JW-0008_S*_L00*_R*_001_fastqc.html` e.g. `4717-JW-0008_S4_L002_R2_001_fastqc.html`: these are the raw FastQC reports of the raw, untrimmed sequencing data. This dataset still contains the 10X barcodes at the 5' end of the read 1 files, and there is a separate one for each of read 1 and read 2 reads. Note that the sharp spike at 50% GC content is caused by an overrepresented AGGGTTAGGGTTAGGGTTAGGGTTAGGGTTAGGGTTAGGGTTAGGGTTAG repeat sequence (and its reverse complement).

2) **Trimming reports**
* `*_qualtrim_out.log`: standard output of Trimmomatic, reporting the commands run and the number of surviving reads.
* `fltrd_adaptrlss*fastqc.html`: FastQC of the trimmed data. Note that while my standard workflow names the trimmed files with fltrd_adaptrlss as the prefix, these reads were *not* specifically trimmed to remove read-through adapters, but they have had their 10X barcodes removed. There are both paired and unpaired reports for R1 and R2, the unpaired sequences were not carried into further analyses: the are of rather low quality as you may view from the FastQC reports.

3) **Mapping reports**
* `*_mapping.log`: not too meaningfull, just the raw standard output log of the bwa mem program mapping reads to the genome for each sequencing run, with the linux command and the timing.
* `*.bamstats.txt`: bamtools stats report for the mapping of the trimmed reads to the genome for each sequencing run
* `*.samstats.txt`: samtools stats report for the mapping of the trimmed reads to the genome for each sequencing run
* `*.flagstats.txt`: samtools flagstat report for the mapping of the trimmed reads to the genome for each sequencing run
* `*.idxstats.txt`: samtools idxstats report for number of trimmed reads mapping to each contig for each sequencing run

