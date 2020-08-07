# Willisornis_Genome_Assembly
![Willisornis vidua](https://upload.wikimedia.org/wikipedia/commons/2/24/Willisornis_vidua_-_Xingu_scale-back_antbird_%28young_male%29.jpg)
Image: a young male *Willisornis vidua*, photograph by Hector Bottai, copyright [creative commons](https://creativecommons.org/licenses/by-sa/4.0/deed.en)

The repository describes all pipelines used to annotate and analyze the genome of Willisornis vidua nigrigula.
Note that throughout this repository, many of the file names refer to "*Willisornis poecilinotus*" - this was the name of *Willisornis vidua* before it was split from *Willisornis poecilinotus*. The sample sequenced here belongs to Willisornis vidua nigrigula, with approximately 9.8% ancestry from W. poecilinotus griseiventris.

Note that the code archived here are the commands that were actually run for the Willisornis project, and so all of the paths to folders and executables are hard-coded. To run on a different machine or with different data, the commands will need to be modified. 

I have placed several output files and data documenting various steps into this repository as well:

### Sequencing Data
* The quality control statistics for the sequencing reads (bamstats, flagstats, samstats, mapping logs, and FastQC reports) are in `QC_reports`
* The output files from kmer analysis, including histogram files and images, and in `QC_reports/kmer_analysis`

### Genome Assembly
* The output statistics from each run of Supernova are in `QC_reports/Assembly_reports`

### TE Library
* Various files related to the TE library are in the Repeat_library folder
* The curated TE library is in the folder Repeat_library as "Wilpoe_TE_library.fasta"
* The uncurated TE library is in the folder Repeat_library as "Uncurated/Willisornis_repeat_library.lib" - warning: I recommend using the curated TE library above, not this uncurated TE library, as it includes classification errors that were corrected during curation.
* The landscape graph files and images are in `Repeat_library/landscape`
* The repeatmasking summary is in `Repeat_library/repeat_masking`
* The TEsorter, Censor, and TEClass results are in `Repeat_library/TE_classification`

### Protein Prediction
* The Maker control files, bash scripts, and SNAP hmm files are in the folder `Maker_controlfiles`.

### Annotation_stats
* statistics about the raw (unfiltered) proteome produced by the 4 rounds of maker are in `Annotation_stats/*_genestats`
* tsv file listing interproscan hits to all the proteins: `Annotation_stats/Willisornis_R4prot_5interpro.tsv`
* statistics about the filtered proteome (average lengths, etc): `Annotation_stats/Willisornis.standardplus.functional_5interpro`

### Proteome/transcriptome
* The final transcriptome is in `Willisornis.standardplus.namedtranscripts.fasta`
* The final proteome is in `Willisornis.standardplus.namedproteins.fasta`

### Rhegmatorhina/Hypocnemis
* The *Rhegmatorhina melanosticta* transcriptome and proteome are in `Rhegmatorhina_annotation`
* The *Hypocnemis ochrogyna* transcriptome and proteome are in `Hypocnemis_annotation`

### Gene family analysis
* The file `gene_counts.csv` is in the folder `Genefamily` listing the number of genes in each orthogroup for each species.
* The gene family counts files and tree inputs for Cafe, are in `Genefamily/CAFE`
* Files listing the the lanbda and epsilon values are in `Genefamily/CAFE`
* Files listing the expanded and significantly expanded orthogroups for each antbird lineage are in `Genefamily/CAFE`
* Files related to GO analysis of the CAFE results are in `Genefamily/GO`

![Willisornis poecilinotus](https://upload.wikimedia.org/wikipedia/commons/1/1b/HypocnemisLepidonotaSmit.jpg)
Illustration: Willisornis poecilinotus lepidonota, female (top) and male (below) by Joseph Smit, 1892 (Public domain).