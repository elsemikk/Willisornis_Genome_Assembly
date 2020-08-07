# Willisornis_Genome_Assembly
![Willisornis vidua](https://upload.wikimedia.org/wikipedia/commons/2/24/Willisornis_vidua_-_Xingu_scale-back_antbird_%28young_male%29.jpg)
Image: a young male *Willisornis vidua*, photograph by Hector Bottai, copyright [creative commons](https://creativecommons.org/licenses/by-sa/4.0/deed.en)

The repository describes all pipelines used to annotate and analyze the genome of Willisornis vidua nigrigula.
Note that throughout this repository, the file names refer to "Willisornis poecilinotus" - this was the name of Willisornis vidua before it was split from Willisornis poecilinotus. The sample sequenced here belongs to Willisornis vidua nigrigula, with approximately 9.8% ancestry from W. poecilinotus griseiventris.

Note that the code archived here are the commands that were actually run with the Willisornis data, and so all of the paths to folders and executables are hard-coded. To run on a different machine or with different data, the commands will need to be modified. 

I have placed several output files and data documenting various steps into this repository as well.

The most useful ones are:
* The curated TE library is in the folder Repeat_library as "Wilpoe_TE_library.fasta"
* The uncurated TE library is in the folder Repeat_library as "Anteater_repeat_library.lib" - warning: I recommend using the curated TE library above, not this uncurated TE library, as it includes classification errors that were corrected during curation.

Annotation_stats
* tsv file listing interproscan hits to all the proteins: `Anteater_R4prot_5interpro.tsv`
* statistics about the filtered proteome: `Anteater.standardplus.functional_5interpro`

![Willisornis poecilinotus](https://upload.wikimedia.org/wikipedia/commons/1/1b/HypocnemisLepidonotaSmit.jpg)
Illustration: Willisornis poecilinotus lepidonota, female (top) and male (below) by Joseph Smit, 1892 (Public domain).