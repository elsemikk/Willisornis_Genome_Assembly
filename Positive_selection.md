This page contains the pipeline that I used for analyzing genes under positive selection in Willisornis. I also included my notes which I took while learning how to do this analysis.
To replicate this pipeline, you would need the Refseq and Ensembl proteomes (instructions to download and filter are on another page of this repository), as well as the Willisornis proteome and transcript files (`Anteater.standardplus.namedtranscripts.fasta`).
Note that throughout the pipeline I call Willisornis files "Anteater".

You will need several programs installed: Clustal omega, pal2nal, Orthofinder (+ dependencies), seqkit, R, paml, and ermineJ.
# Pipeline for my data
Now that I have a proteome for Willisornis, I would like to estimate the dN/dS ratio of the proteins in the genome. For each protein, I want to estimate *omega*: at its most simple, if this is less than 1, it could imply negative/purifying selection, and if it is greater than 1, it could imply positive/adaptive/diversifying selection. A value equal to 1 would be consistent with neutral evolution, as in pseudogenes or genes that are somehow selectively neutral or not actually expressed as proteins (or positive and purifying selection balance out). Most genes should have omega less than 1. 
My ultimate goal/hope would be to find a set of genes with *omega* > 1 under positive selection in the antbird lineage, but not another related lineage.

Input:
1) Protein sequences and nucleotide coding sequences for lineage of interest: done previously with Maker2 annotating the Willisornis genome. NOTE: make sure that the CDS sequence and protein sequence match perfectly i.e. the protein sequence is a direct translation of the CDS sequence.
* (note: at the time that I ran this pipeline I did not have the Hypocnemis or Rhegmatorhina data so they were not included)

2) Closely related organism(s) to compare to: You technically only need one but more is always better. I will use all of the RefSeq and Ensembl proteomes for songbirds/parrots that I can access.

# 1) Obtain data: proteins and CDS
The pipeline used for obtaining the Refseq/Ensembbl data is outlined in another page of this repository.


# 2) Find Orthologs
To do dN/dS analysis, you need to align orthologous genes - so you need to know which genes are orthologousto your species of interest! For published datasets there are databases listing orthologs. For my antbird I need to assign orthology. I used OrthoFinder as I find it very simple, quick, and it is easy to add new species and it gives a variety of useful outputs. Another popular program is [OrthoMCL](https://orthomcl.org/orthomcl/about.do#methods) (tutorial [here](https://github.com/bernicehuang/general_pipelines/blob/master/protocols/orthomcl.md), info [here](https://www.biostars.org/p/113460/)).

The goal is to find 1:1 orthologs between my species and all other species.

First, I make some lists of which species to analyze. These are lists of my species codes (first 3 letters of genus followed by the first 3 letters of species name) which I used for naming all the CDS/proteome files.

Ensemble passerines/parots:
```bash
cd /home/0_GENOMES1/0_Genetic_resources/Ensembl_99
cat > EnsPasserines_list.txt #copy-paste file contents, press enter, then ctrl-d to finish
```
Here are the contents of `EnsPasserines_list.txt`:
```
Amacol
Cyacae
Erygou
Ficalb
Junhie
Lepcor
Lonstr
Manvit
Melund
Parmaj
Sercan
Strhab
Taegut
Zonalb
```

Refseq species that are not redundant with Ensembl:
```bash
cat > RefnotEnsPasserines_list.txt #copy-paste file contents, press enter, then ctrl-d to finish
```
Here are the contents of `RefnotEnsPasserines_list.txt`:
```
Acachl
Campar
Coralt
Corbra
Corcor
Emptra
Falche
Falper
Geofor
Neochr
Nesnot
Pipfil
Psehum
Stuvul
```

That is 14 + 14 = 28 species plus Willisornis = 29 species.

```
#load environment
export PATH=$PATH:/home/0_PROGRAMS/fastme-2.1.5/binaries
export PATH=$PATH:/home/0_PROGRAMS/ #for Diamond
export PATH=$PATH:/home/0_PROGRAMS/OrthoFinder

#make directory for output
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/PasserinesPlus
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/PasserinesPlus

#place copies of all the longest isoform fastas in here (moving from main server to node), as well as the Willisornis standardplus named proteome file.
cp /home/0_GENOMES1/0_Genetic_resources/Ensembl_99/EnsPasserines_list.txt . #get the list of taxa to analyze
cat EnsPasserines_list.txt | while read line ; do cp /home/0_GENOMES1/0_Genetic_resources/Ensembl_99/longest.simpleheader."$line".AA.fa . ; done
cp /home/0_GENOMES1/0_Genetic_resources/Refseq/RefnotEnsPasserines_list.txt . #get the list of taxa to analyze
cat RefnotEnsPasserines_list.txt | while read line ; do cp /home/0_GENOMES1/0_Genetic_resources/Refseq/longest.simpleheader."$line".AA.fa . ; done
cp ../Willisornis.fa . #I had already moved the Willisornis proteome to /home/0_GENOMES1/0_Genetic_resources/orthologues/Willisornis.fa

#There are 29 fasta files of proteomes now. Run OrthoFinder in thsi directory, it will detect the proteomes.
time orthofinder -f /home/0_GENOMES1/0_Genetic_resources/orthologues/PasserinesPlus -t 24 > Orthofinder_PasserinePlus.log
```

**Timing**: took 282m56 to run on 28 proteomes with 24 threads. It took 3343m38 user time (25m6 sys time) so multithreading saved a lot of time.

**Results**: Automatically detected the parrots as the outgroup for rooting, although it should have used falcons. 98.1% of genes were assigned an orthogroup, 4564 orthogroups were strictly 1:1 orthologs between all 28 species.

Now we have our orthologs to calculate dN/dS with!

# 3) Align sequences
Now, I need to align the orthologs. My preference is to use MUSCLE however Clustal Omega (not ClustalW) is also a good option (or other aligners). Then, the choice will be to either filter (more conservative) or not filter the alignments. I am not going to filter. Finally, we need to align the nucleotide sequences while preserving codon positions, which we can do with the program pal2nal.

Firstly, we need a fasta file of each amino acid and cds orthogroup in separate fastas, 1 per orthogroup with all species in each file. These should ideally be 1:1:1:1...:1:1:1 orthologs between all the species in your phylogeny. Luckily, these are listed by Orthofinder! And, OrthoFinder has already made us a fasta file of each protein cluster! We just have to do the same for the CDS's. Orthofinder has already listed all the single copy orthologs in `PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt`.

```
#set up working directory
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/

#put all the single copy ortholog protein fastas into the working folder and name them .faa to specify amino acid fasta
cat PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | while read Orthogroup ; do cp PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroup_Sequences/"$Orthogroup".fa ./alignments/"$Orthogroup".faa ; done

#Now get CDS sequences as well
#Make sure that the headers of the CDS sequences match the AA sequences! If not you can salvage it with a a mapping file that lists the old names and the new names in two columns, and then find and replace:
cp /home/0_GENOMES1/0_Genetic_resources/Ensembl_99/Ensembl2speciescodes . #This is my name mapping file
cat Ensembl2speciescodes | while read oldname newname ; do sed -i "s/$oldname/$newname/g" ./Orthogroup_Sequences/*.fa ; done

#for each orthogroup, for each species, get a list of fasta headers (genes) you need, extract the matching ones from that species' CDS fasta file, and add it on to that ortholog's CDS fasta.
cat PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | while read orthogroup ; do cat PasserinesPlus/EnsPasserines_list.txt | while read species ; do grep "$species" ./alignments/"$orthogroup".faa | sed 's/>//g' | seqkit grep -n -f - /home/0_GENOMES1/0_Genetic_resources/Ensembl_99/longest.simpleheader."$species".CDS.fa >> ./alignments/"$orthogroup".fna ; done ; done

#repeat for Refseq species
cat PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | while read orthogroup ; do cat PasserinesPlus/RefnotEnsPasserines_list.txt | while read species ; do grep "$species" ./alignments/"$orthogroup".faa | sed 's/>//g' | seqkit grep -n -f - /home/0_GENOMES1/0_Genetic_resources/Refseq/longest.simpleheader."$species".CDS.fa >> ./alignments/"$orthogroup".fna ; done ; done

#and Willisornis
cp /home/else/anteater/functional_ann/Anteater.standardplus.namedtranscripts.fasta . #get the CDS sequences
cat PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | while read orthogroup ; do grep "WilPoe" ./alignments/"$orthogroup".faa | sed 's/>//g' | seqkit grep -f - Anteater.standardplus.namedtranscripts.fasta >> ./alignments/"$orthogroup".fna ; done
```
* `seqkit grep`: search for fasta sequences whose header match an input pattern 
* `seqkit grep -n`: -n means to search and match a full name perfectly. This command selects sequences whose fasta headers match the input exactly, rather than just containing the input (i.e. no extra words allowed in header).
* `seqkit grep -f -`: -f means to take the pattern to search/grep for as a file. putting a `-` as the input for `-f` means that the input file should be ready from the standard input that is piped into the command.

Now finally do the alignment of the amino acids! Here I am using Clustal Omega but another aligner like muscle would be ok too.
```
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments
cat ../PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | parallel /home/0_PROGRAMS/clustalo -i {1}.faa -o {1}.aln.faa
```

Now we can use the amino acid alignment to get a codon-based nucleotide alignment. pal2nal will use the protein alignment to align the nucleotide CDS sequence, this is important as regular nucleotide alignments might accidentally add framshifts that will ruin the dN/dS calculation. It will also output as paml format which is not quite regular fasta format: no ">" to specify headers, and no symbols or double spaces allowed in headers and max 30 letters long. Also the first line of the file gives the number of taxa and the length of the alignment.
```
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments
#run pal2nal
cat ../PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | time parallel /home/0_PROGRAMS/pal2nal.v14/pal2nal.pl {1}.aln.faa {1}.fna -output paml -nogap ">" {1}.pal2nal "2>" {1}.pal2nal.log

#check if there were any warnings or errors
cat *.pal2nal.log #a few errors and warning. Warnings can be ignored but the errors made no output for those proteins.
#make a list of failed alignments if there were any
grep "ERROR" *.pal2nal.log | sed 's/.pal2nal.*//g' > failed_alignments
#make a list of good alignments to analyze
cat ../PasserinesPlus/OrthoFinder/Results_Jan20/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | grep -v -f failed_alignments > alignments
```
Now we have an alignment! pal2nal was very fast (1m10 real 1638s user to align all 4000+ sets!!).


# 4) Get Phylogenetic tree.
Next, we need a phylogenetic tree. It could be for the aligned proteins of interest, or for the species that they came from. If the species are very closely related such that different genes may have different topologies, then you should use a separate tree for each gene to reflect this. I am using fairly distant species which should have completed lineage sorting long ago, so I will use just a single tree to represent the species to skip making phylogenies for each gene. Luckily, this tree just needs the topology and not the branch lengths, which is much easier to get, and since the tree of birds is generally so well resolved I can rely on published trees. Note that paml is not meant for tree inference (although it can infer trees) so it is recommended to use a different method (like RAxML) to create an input tree rather than making one in paml.

I am basing this phylogeny mostly on a Passerine phylogeny published in 2019: Oliveros et al 2019 "Earth history and the passerine superradiation" and adding missing taxa based on taxonomy or other published phylogenies (timetree.org is helpful to find published phylogenies that include two species of interest).

Note: the tree needs to be in parenthesis notation, does not need branch lengths, all clades must be separated by commas, and it must have a `;` at the very end. The names in the tree must match exactly the names that will be in the sequence headers.
```
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds
cat > Psittacopasserae.tree #copy-paste contents of file, press enter, then ctrl-d to finish
```
Here are the contents of `Psittacopasserae.tree`:
```
((Falche,Falper),(((Strhab,Nesnot),(Melund,Amacol)),(Acachl,((Wilpoe,(((((Lepcor,Manvit),Pipfil),Coralt),Neochr),Emptra)),((Corcor,Corbra),(((Parmaj,Cyacae),Psehum),((Ficalb,Stuvul),(((Taegut,Lonstr),Erygou),(Sercan,((Campar,Geofor),(Zonalb,Junhie)))))))))))
```
I am also making a labelled tree that labels Wilpoe as my branch of interest. This is needed for branch-site models where you compare a branch of interest to background branches. To label the foreground, just place a `#` followed by consecutive numbers to label different groups. Add it to all nodes that you want to belong to that group. If you label an internal node with a `$` insted of `#`, then the label is inherited by all branches and not just that internal branch.
```
cat > Psittacopasserae.labelled.tree #copy-paste contents of file, press enter, then ctrl-d to finish
```
Here are the contents of `Psittacopasserae.labelled.tree`:
```
((Falche,Falper),(((Strhab,Nesnot),(Melund,Amacol)),(Acachl,((Wilpoe #1,(((((Lepcor,Manvit),Pipfil),Coralt),Neochr),Emptra)),((Corcor,Corbra),(((Parmaj,Cyacae),Psehum),((Ficalb,Stuvul),(((Taegut,Lonstr),Erygou),(Sercan,((Campar,Geofor),(Zonalb,Junhie)))))))))));
```


# 5) Calculate dN/dS
Finally, once we have aligned orthologous sequences, we can calculate dN/dS using the program CODEML in the package paml. Paml will estimate omega, which is equivalent to dN/dS. There is a helpful presentation [here](file:///Users/elsemikkelsen/Downloads/pamlDEMO.pdf).

CODEML uses a codon substitution model to estimate some parameters of interest: omega (dN/dS), kappa (transition vs transversion ratio), and pi (substitution rate). These parameters can be estimated or fixed depending on the model being used.

Additionally, more complex models can be used to allow, for example, omega (dN/dS) to vary between lineages or between codons. Using the basic model will estimate omega (dN/dS) for the entire protein, but that is generally not what is wanted. From the manual: "the model of a single ω for all sites is probably wrong in every functional protein, so there is little point of testing." Usually you will need a more complicated model to test something of interest. The main categories might be:  

1) branch models: omega varies across different branches of the phylogeny. It is used to ask: is the average omega **along the whole gene** greater than 1 **on a particular branch**? (Unlikely, it is quite extreme for the whole protein to be under positive selection)  It can be specified with `model = 1` to allow a different omega on each branch (too many parameters!) or ` model = 2` where you specify just one or a few clades labelled on the phylogeny that are allowed to have a different omega value. 
2) site models: omega can vary at different sites within a gene. It is used to ask: is omega greater than 1 **at certain codons of a gene** when considering **all species**? (more realistic, but often selection is only acting temporarily on a certain clade and may not be noticed when considering all lineages at once).
3) branch-site model: omega is allowed to vary at different sites within a gene and along different branches. It can be used to ask: is omega greater than 1 **for certain codons of a gene** for **at least some specified branch**? (most realistic, and often used)

This brings us to some of the specific models available in CODEML:  
* `M0`: basic one ratio model, estimate the average omega for a whole gene for all lineages
* `M1a`: Nearly Neutral Model, codons are grouped into either omega<1 or omega=1. No omega>1 allowed.
* `M2a`: Positive Selection Model, codons are now grouped into three classes, including omega <1, =1, or >1. Can do a likelihood ratio test comparing to model M1a in order to test for positive selection in a gene (df=2).
* `M7`: Beta model, codons have an omega distribution between 0 and 1, no omega>1 allowed.
* `M8`: Beta and Omega Model, codons have an omega distribution that could include omega>1 Can do a likelihood ratio test comparing to M7 to test for positive selection in a gene (df=2).
* `Model A, modified`: Background branches can have omega vary across sites with 2 estimates: The first can vary between 0 and 1 while the second is constrained to be 1. The foreground branch can have 3 omegas: one is between 0-1, one is equal to 1, and one is greater than 1 (positive selection) ( model = 2 NSsites = 2) **This is what I am interested in**
* `Model A's null`: fixes ω2 = 1. Both foreground and background can only have two omegas: either 1 or between 0 and 1 (no positive selection allowed). Used as a null to compare to model A with a likelihood ratio test with df = 1.(fix_omega = 1 and omega = 1)

CODEML will use maximum likelihood to fit these models. Often you will want to run more than one model in order to compare a model with vs without positive selection allowed. This will be using a likelihood ratio test (assuming that the two models you are comparing are nested within each other) If you find a protein with evidence for positive selection, you can then find out which specific sites are involved as paml will estimate this with the NEB and BEB method.

I am planning to use model A modified and model A's null model in order to test whether my species of interest has at least some sites under positive selection compared to background lineages. Ideally, this will give me a list of genes with evidence for positive selection in my species.

## More formatting required
For CodeML to work, the headers of each gene should have only the species name exactly matching how it is written in the phylogenetic tree input. That means I need to get rid of the gene names from each of the alignments so that only the species names remain.
```
#reformat gene names and then place in a new folder
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_alignments
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds

#read through our list of the orthogroups for alignments that worked, fix the headers and then save into a working folder.
cat ../alignments/alignments | while read orthogroup ; do cat ../alignments/"$orthogroup".pal2nal | sed '2,$s/[0-9].*$//g' | sed 's/WilPoe/Wilpoe/g' > ./anteater_alignments/"$orthogroup".pal2nal ; done
```
* `sed '2,$s/[0-9].*$//g'`: starting in the second line (to preserve the first line containing number of species/codons), do find and replace to find anything starting with a number up until the end of the line and replacing it with nothing.
* `sed 's/WilPoe/Wilpoe/g'`: fix the capitalization, I decided later it bothers me too much to have a species epithet abbreviation capitalized in Willisornis

### Building a model

CODEML runs using control files which list all the parameters in the model. When you run CODEML you will tell it the name of which control file to use.

#### Basic model `M0`

First, we could quickly test CODEML with model `M0`, a basic model. I am not going to report these results, it is just a quick test. We will make a basic control file like this:
```
cat > codeml-M0_test2.ctl #copy-paste contents of file, press enter, then ctrl-d to finish
```
This is the contents of the control file:
```
seqfile = anteater_alignments/OG0006656.pal2nal
treefile = Psittacopasserae.labelled.tree
outfile = OG0006656.M0_2.output.txt 
noisy = 0        * 0,1,2,3,9: how much output printed to the screen
verbose = 0      * 1:detailed output 0: not detailed output
runmode = 0     * 0:use input tree
seqtype = 1      * 1:codons
CodonFreq = 2    * 0:equal, 1:F1X4, 2:F3X4, 3:F61
model = 0        * free ratio model, each branch in the tree gets its own omega value
NSsites = 0      *
icode = 0        * 0:use universal genetic code
fix_omega = 0    * 1:omega fixed, 0:omega to be estimated
omega = 0.5      * initial omega value
fix_kappa = 0    * 1:kappa fixed, 0:kappa to be estimated
kappa = 1        * initial or fixed kappa. kappa=1 is probably not correct, should probably be greater than 1 usually

```
We run it like this
```
time /home/0_PROGRAMS/paml4.9j/bin/codeml codeml-M0_test2.ctl 
#look at results for omega
grep "omega" OG0006656.M0.output.txt 
grep "kappa" OG0006656.M0.output.txt 
```
**Timing**: took 6 6m37 to estimate omega and kappa for one alignment of 29 species. If it takes 1 second, that means something is probably wrong with the control file or input and it probably did not estimate omega. I found I had to use my labelled tree for it to work for some reason even though I am not using any branch model here...
**Result**: estimated dN/dS = 0.01758. If this were the only gene I were interested in, I would do multiple runs with different starting values of omega to make sure that it converged on the best estimate. At least this looks like the input files are ok. Estimated kappa (transitions/transversions) = 4.95436 which seems ok although higher than I was expecting. I tried repeating once more and got the exact same values (omega=0.01758, kappa=4.95436) so it appears repeatable.

### Pairwise dN/dS ratio between all lineages
These settings come from a tutorial (and use the results parser [here](https://github.com/faylward/dnds).)  
These settings will calculate dN/dS pairwise between all pairs (so you do not really need a phylogeny for anything).  
They are not used to test anything or compare models, they just give an estimate of dN/dS for the gene for each combination of lineages. I am just testing it with a single gene, `OG0006656`
```
cat > pairwise_test.ctl  #copy-paste contents of file, press enter, then ctrl-d to finish
```
```
seqfile = anteater_alignments/OG0006656.pal2nal
*treefile = Psittacopasserae.tree
outfile = OG0006656.pairwise.output.txt 
noisy = 0        * 0,1,2,3,9: how much output printed to the screen
verbose = 0      * 1:detailed output 0: not detailed output
runmode = -2     * -2:pairwise comparison mode
seqtype = 1      * 1:codons
CodonFreq = 2    * 0:equal, 1:F1X4, 2:F3X4, 3:F61
model = 1        * free ratio model, each branch in the tree gets its own omega value
NSsites = 0      *
icode = 0        * 0:use universal genetic code
fix_kappa = 1    * 1:kappa fixed, 0:kappa to be estimated
kappa = 1        * initial or fixed kappa
fix_omega = 0    * 1:omega fixed, 0:omega to be estimated
omega = 0.5      * initial omega value
```
```
time /home/0_PROGRAMS/paml4.9j/bin/codeml pairwise_test.ctl #runs using the settings in the control file
#parse results using the script from the online tutorial
conda activate python2 #script uses python2 not 3
python /home/0_PROGRAMS/dnds/parse_codeml_output.py OG0006656.pairwise.output.txt #parses results file and prints pairwise omega values
```
**Timing**: only took 34 seconds for 1 gene with 29 species.  
This gives us a value of omega, dN, and dS for each comparison. It is quite a lot faster than estimating omega for the whole tree.   
The test gene looks to be under purifying selection (dnds<<1) which makes sense as most genes should be.   

Next, can we find any (parts of a gene) under positive selection in our lineage specifically?

I will be using a branch-site model, MA( ω > 1)  vs. MA( ω = 1) to see whether my anteater genome is more likely to contain sites with ω > 1.

### Branch-site null model for model A
Null hypothesis: no positive selection, no omega > 1.  
This is specified using model = 2; NSsites = 2; fix_omega = 1; omega = 1
```
cat > branchsites_testnull.ctl   #copy-paste contents of file, press enter, then ctrl-d to finish
```
Here are the file contents:
```
seqfile = anteater_alignments/OG0006656.pal2nal   * sequence data filename
treefile = Psittacopasserae.labelled.tree  * tree structure file name
outfile = OG0006656.branch-site-null-model-output.txt   * main result file name

noisy = 3      * 0,1,2,3,9: how much output printed to the screen
verbose = 1    * 1:detailed output
runmode = 0    * 0: user tree; 1: semi-automatic; 2: automatic 3: StepwiseAddition; (4,5):PerturbationNNI 
Mgene = 0 
seqtype = 1    * 1:codons; 2:AAs; 3:codons-->AAs
CodonFreq = 2  * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
icode = 0      * 0:use universal genetic code

model = 2      * models for codons: 0:one, 1:b, 2:2 or more dN/dS ratios for branches
NSsites = 2    *
fix_omega = 1  * 1: omega or omega_1 fixed, 0: estimate 
omega = 1 
fix_kappa = 0  * 1: kappa fixed, 0: kappa to be estimated
kappa = 3  * initial or fixed kappa

fix_alpha = 1    * 0: estimate gamma shape parameter; 1: fix it at alpha
alpha = 0        * initial or fixed alpha, 0:infinity (constant rate)
Malpha = 0       * different alphas for genes
ncatG = 10       * # of categories in dG
