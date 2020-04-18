This page contains the pipeline that I used for analyzing genes under positive selection in Willisornis. I also included my notes which I took while learning how to do this analysis.
To replicate this pipeline, you would need the Refseq and Ensembl proteomes (instructions to download and filter are on another page of this repository), as well as the Willisornis proteome and transcript files (`Anteater.standardplus.namedtranscripts.fasta`).
Note that throughout the pipeline I call Willisornis files "Anteater".

You will need several programs installed: Clustal omega, pal2nal, Orthofinder (+ dependencies), seqkit
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
ncatG = 10       * # of categories in dG of NSsites models

getSE = 0        * 0: don't want them, 1: want S.E.s of estimates
RateAncestor = 0 * (0,1,2): rates (alpha>0) or ancestral states (1 or 2)

Small_Diff = .5e-6
cleandata = 0
fix_blength = 0  * 0: ignore, -1: random, 1: initial, 2: fixed, 3: proportional
```
```
#run codeml on the null model
time /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testnull.ctl 
```

### Branch site model A 
Alternative hypothesis: omega > 1 for at least some sites in the anteater  
This is specified using model = 2; NSsites = 2; fix_omega = 0; omega = 1.5  
Notice the only thing changed in the control file is whether or not to fix omega and the value of starting omega (and of course, the name of the output file)
```
cat > branchsites_testalt.ctl   #copy-paste contents of file, press enter, then ctrl-d to finish
```
Here are the file contents:
```
seqfile = anteater_alignments/OG0006656.pal2nal   * sequence data filename
treefile = Psittacopasserae.labelled.tree  * tree structure file name
outfile = OG0006656.branch-site-alt-model-output.txt   * main result file name

noisy = 3        * 0,1,2,3,9: how much rubbish on the screen
verbose = 1      * 1:detailed output
runmode = 0      * 0: user tree; 1: semi-automatic; 2: automatic 3: StepwiseAddition; (4,5):PerturbationNNI 
Mgene = 0 
seqtype = 1      * 1:codons; 2:AAs; 3:codons-->AAs
CodonFreq = 2    * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
icode = 0        * 0:use universal genetic code

model = 2        * models for codons: 0:one, 1:b, 2:2 or more dN/dS ratios for branches
NSsites = 2      *
fix_omega = 0    * 1:omega fixed, 0:omega to be estimated
omega = 1.5       * initial omega value
fix_kappa = 0    * 1: kappa fixed, 0: kappa to be estimated
kappa = 3        * initial or fixed kappa

fix_alpha = 1    * 0: estimate gamma shape parameter; 1: fix it at alpha
alpha = 0        * initial or fixed alpha, 0:infinity (constant rate)
Malpha = 0       * different alphas for genes
ncatG = 10       * # of categories in dG of NSsites models

getSE = 0        * 0: don't want them, 1: want S.E.s of estimates
RateAncestor = 0 * (0,1,2): rates (alpha>0) or ancestral states (1 or 2)

Small_Diff = .5e-6
cleandata = 0
fix_blength = 0  * 0: ignore, -1: random, 1: initial, 2: fixed, 3: proportional
```
```
#run codeml
time /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testalt.ctl 
conda activate python2
python /home/0_PROGRAMS/dnds/parse_codeml_output.py OG0006656.codeml.txt
```

#### Run in a loop over all proteins

Now that I have run a few tests to know that it works, I will run it in a loop over all of the proteins.
```
#set up a separate folder for each orthogroup so they don't overwrite each other
#and create control files for each one
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds
cat ../alignments/alignments | while read orthogroup ; do mkdir ./anteater_dnds/"$orthogroup" ; cp branchsites_testalt.ctl ./anteater_dnds/"$orthogroup" ; cp branchsites_testnull.ctl ./anteater_dnds/"$orthogroup" ; sed -i "s/OG0006656/$orthogroup/g" ./anteater_dnds/"$orthogroup"/branchsites_testalt.ctl ; sed -i "s/OG0006656/$orthogroup/g" ./anteater_dnds/"$orthogroup"/branchsites_testnull.ctl ; sed -i "s/anteater_alignments/\.\.\/\.\.\/anteater_alignments/g" ./anteater_dnds/"$orthogroup"/branchsites_testalt.ctl ; sed -i "s/anteater_alignments/\.\.\/\.\.\/anteater_alignments/g" ./anteater_dnds/"$orthogroup"/branchsites_testnull.ctl ; sed -i "s/Psittacopasserae/\.\.\/\.\.\/Psittacopasserae/g" ./anteater_dnds/"$orthogroup"/branchsites_testalt.ctl ; sed -i "s/Psittacopasserae/\.\.\/\.\.\/Psittacopasserae/g" ./anteater_dnds/"$orthogroup"/branchsites_testnull.ctl ; done

#run alternative hypothesis, takes a very long time to do 4000 tests. Running 20 in parallel at a time.
cat ../alignments/alignments | parallel -j 20 "cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/"{1} "; echo" {1} "; /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testalt.ctl"

#count how many had possible selection detected
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds
grep "foreground w" ./*/*branch-site-alt-model-output.txt > omega_estimates
awk 'BEGIN{FS=" "}{ if ($5>1.00000){ print } }' omega_estimates | sed 's/\.\///g' | sed 's/\/.*//g' > possible_selection

#how many genes do we need to do the null hypothesis for? No reason to run null hypothesis if the model did not even estimate omega greater than 1 for Willisornis
wc -l possible_selection #1594 genes had omega greater than 1 for Willisornis (at at least some sites)

#save likelihoods for safe keeping in case the files are overwritten somehow
cat ../alignments/alignments | while read line ; do grep "lnL" ./anteater_dnds/"$line"/rst | sed 's/lnL = //g' >> lnL_archive && echo "$line" >> alt_hypotheses ; done

#before running, move the supplemental files from the previous run into a new folder before they are overwritten, then do null hypothesis for tests that proposed positive selection in Willisornis
#Now do null hypothesis model on that list of genes
time cat anteater_dnds/genes_to_do_null | parallel -j 20 "cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/"{1} "; mkdir alt_run_sup ; mv rst* alt_run_sup ; mv rub alt_run_sup ; mv lnf alt_run_sup ; mv 4fold.nuc alt_run_sup ; echo" {1} "; /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testnull.ctl &> paml_null.log"

#Oh no! lost connection to the server only part way through, and so it crashed. Need to restart where it left off
ls ./*/*branch-site-null-model-output.txt | sed 's/\.\///g' | sed 's/\/.*//g' > done_genes_for_LRT_round2 #624 done
grep -vf done_genes_for_LRT_round2 possible_selection > genes_to_do_null_round2 #970 to go
cd ..
time cat anteater_dnds/genes_to_do_null_round2 | parallel -j 20 "cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/"{1} "; mkdir alt_run_sup ; mv rst* alt_run_sup ; mv rub alt_run_sup ; mv lnf alt_run_sup ; mv 4fold.nuc alt_run_sup ; echo" {1} "; /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testnull.ctl &> paml_null.log"

#Oh no! A power outage! Start again.
ls ./*/*branch-site-null-model-output.txt | sed 's/\.\///g' | sed 's/\/.*//g' > done_genes_for_LRT_round3 #727 done
grep -vf done_genes_for_LRT_round3 possible_selection > genes_to_do_null_round3 #867 to go
cd ..
time cat anteater_dnds/genes_to_do_null_round3 | parallel -j 20 "cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/"{1} "; mkdir alt_run_sup ; mv rst* alt_run_sup ; mv rub alt_run_sup ; mv lnf alt_run_sup ; mv 4fold.nuc alt_run_sup ; echo" {1} "; /home/0_PROGRAMS/paml4.9j/bin/codeml branchsites_testnull.ctl &> paml_null.log"
```
**Timing:** For the altrnative hypothesis, the first finished Jan 23 at 9:47 and the last finished Jan 29 at 5:08. So it took ~6 days to do ~4000 branch site models. 

### Explanation of some parameters in the control files

* `seqfile`: sequence alignment file, output of pal2nal in this case. Not quite fasta format, see manual for details if making yourself.
* `treefile`: tree file in Newick format, with foreground branch labelled. See phylogeny section for details
* `outfile`: name of output file. There will be other output files also made but this is the main one.
* `noisy`: how much output to print to terminal on a scale of 0 to 3
* `verbose`: how much output to print to the file: 0, concise or 1, detailed
* `Mgene`: for if you partition your sequence alignment. No = 0.
* `Small_Diff`: "a small value used in the difference approximation of derivatives. Use a value between 1e-8 and 1e-5 and check that the results are not sensitive to the value used."
* `icode`: "This specifies the genetic code to be used for ancestral reconstruction of protein-coding DNA sequences."
* `fix_alpha`: 
* `ndata`: number of alignments to analyze
* `CodonFreq`:how to calculate codon frequency: either assume all codons are equal 1/61 frequency (0), use average nucleotide frequencies to calculate codon frequency (1), or use nucleotide frequencies at each codon position to calculate frequency of each codon (2).
* `model = 0`: which model to use. "specifies the branch models. model = 0 means one ω ratio for all branches; 1 means one ratio for each branch (the free-ratio model); and 2 means an arbitrary number of ratios (such as the 2-ratios or 3-ratios models). When model = 2, you have to group branches on the tree into branch groups using the symbols # or $ in the tree. See the section above about specifying branch/node labels. With model = 2, the variable fix_omega fixes the last ω ratio (ωk − 1 if you have k ratios in total) at the value of omega specified in the file. This option is used to test whether the ratio for the foreground branch is significantly greater than one." "model = 1 fits the so-called free-ratios model, which assumes an independent ω ratio for each branch. This model is very parameter-rich and its use is discouraged. model = 2 allows you to have several ω ratios. You have to specify how many ratios and which branches should have which rates in the tree file by using branch labels. "
* `NSsites`: which model to use for sites. "Specifies the site models, with NSsites = m corresponds to model Mm in Yang et al. (2000b). The variable ncatG is used to specify the number of categories in the ω distribution under some models. In Yang et al. (2000b), this is 3 for M3 (discrete), 5 for M4 (freq), 10 for the continuous distributions (M5: gamma, M6: 2gamma, M7: beta, M8:beta&w, M9:beta&gamma, M10: beta&gamma+1, M11:beta&normal>1, and M12:0&2normal>1, M13:3normal>0). For example, M8 has 11 site classes (10 from the beta distribution plus 1 additional class for positive selection with ωs ≥ 1). You can run several Nssites models in one batch, as follows, in which case the default values of ncatG, as in Yang et al. (2000b), are used. `NSsites = 0 1 2 3 7 8` The posterior probabilities for site classes as well as the expected ω values for sites are listed in the file rst, which may be useful to identify sites under positive selection.
* `seqtype`: 1 = nucleotide alignment, 2= AA
* `cleandata`: In the pairwise distance calculation (the lower-diagonal distance matrix in the output), cleandata = 1 means “complete deletion”, with all sites involving ambiguity characters and alignment gaps removed from all sequences, while cleandata = 0 means "pairwise deletion", with only sites which have missing characters in the pair removed."

### Reading the output

**codons under selection**
One of the outputs of certain models including `model A modified` will be a list of specific codons putatively under positive selection, detected by the BEB and NEB method. Of these two methods, the paml manual states "We suggest that you ignore the NEB output and use the BEB results only" so you might only care about the BEB results. It will show a column that looks like this:
```
135 K 0.983* 4.615 +- 1.329
```
* `135`: the position of the codon in the protein, numbered from the beginning
* `K`: the amino acid coded at that position, in this case K=Lysine
* `0.983*`: the posterior probability. It will have one `*` for >95%, and `**` if the probability is > 99%
* `4.615`: approximate mean of the posterior distribution for omega
* `+- 1.329`: the square root of the variance in the posterior distribution for omega

# 6) Likelihood ratio test 
Next, test whether a model that includes omega > 1 is significantly better than one that does not. This is done with a likelihood ratio test. You need to have run at least two different models in order to compare their likelihood scores: if the more complicated model has a much better likelihood than the simpler, then you have evidence that it is a better fit to the data. If it is not too much better, then you do not have evidence that the protein is evolving under the more complicated model and the simpler model should be used instead.

The likelihood ratio test statistic is 2*(difference in log likelihood between your two models). Find the chi-squared critical value for the number of degrees of freedom of your comparison, and see if your test statistic is higher (reject null model).

In our case, k=1 because the more complicated model has 1 extra parameter (omega) which is allowed to vary.

When testing thousands of genes, don't forget to correct for multiple testing with a false discovery rate correction!

Also, remember that you can ONLY do a likelihood ratio test to compare nested models!

```
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds

#get a list of the genes to do a likelihood ratio test on
ls ./*/*branch-site-null-model-output.txt | sed 's/\.\///g' | sed 's/\/.*//g' > done_genes_for_LRT

#This code only works if there are NO failed runs (dangerous, could lead to big errors)
#the following only works if you had no failed runs within done_genes_for_LRT since it will make a list of the genes and then combine lists of their likelihoods, so it requires that the order of genes in each list is identical
#cat done_genes_for_LRT | while read line ; do grep "lnL" ./"$line"/rst | sed 's/lnL = //g' >> temp && grep "lnL" ./"$line"/alt_run_sup/rst | sed 's/lnL = //g' >> temp2 ; done

#This code is safer, getting lists of the likelihood after checking if the run succeeded
cat done_genes_for_LRT | while read line ; do grep "lnL" ./"$line"/rst | sed 's/lnL = //g' >> temp ; done
cat done_genes_for_LRT | while read line ; do if grep -q "lnL" ./"$line"/rst ; then grep "lnL" ./"$line"/alt_run_sup/rst | sed 's/lnL = //g' >> temp2 ; fi ; done

#rename the tem files
mv temp null_likelihoods
mv temp2 alt_likelihoods
paste alt_likelihoods null_likelihoods > LRT
```
I am using R to do the likelihood ratio test.
```R
R
lnL <- read.table("LRT")
lnL[,3] <- as.numeric(2*(lnL[,1] - lnL[,2]))
sum(lnL[,3]>6.64) #925 significant
```
Before the list can be useful, it must be filtered.
```bash
#filter likely false positives driven by errors: dN/dS> 50 or sites under selection < 5% of sites
cat done_genes_for_LRT | while read line ; do if grep -q "lnL" ./"$line"/rst ; then grep "foreground w" ./"$line"/*branch-site-alt-model-output.txt | awk 'BEGIN{FS=" "}{ { print $5} }' >> temp3 ; fi ; done
mv temp3 omega_estimates_forLRT

#get lists of the proportions estimated to be under positive selection
cat done_genes_for_LRT | while read line ; do if grep -q "lnL" ./"$line"/rst ; then grep "proportion" ./"$line"/*branch-site-alt-model-output.txt | awk 'BEGIN{FS=" "}{ { print $4 "\t" $5} }' >> temp4 ; fi ; done
mv temp4 positiveselection_proportions_forLRT
paste LRT_names omega_estimates_forLRT positiveselection_proportions_forLRT alt_likelihoods null_likelihoods > LRT

cat done_genes_for_LRT | while read line ; do if grep -q "lnL" ./"$line"/rst ; then echo "$line" >> temp5 ; fi ; done
mv temp5 LRT_names
```
Now I am filtering again in R
```R
R
library(dplyr)
LRT <- read.table("LRT") #1552 genes starting out

colnames(LRT)
colnames(LRT) <- c("Orthogroup", "Omega", "p1", "p2", "alt_l", "null_l")

#Filter to retain omega values less than 50 covering more than 5% of sites, like the Komodo Dragon paper did
LRT_filtered <- LRT %>%
  dplyr::filter(Omega<50) %>% #580 remaining
  dplyr::filter(p1 + p2 > 0.05) #130 remaining

#do a likelihood ratio test to see if positive selection is a significantly better fit than the null model at p<0.01
LRT_filtered$LRT <- as.numeric(2*(LRT_filtered$alt_l - LRT_filtered$null_l))
LRT_filtered <- LRT_filtered %>%
  dplyr::filter(LRT>6.64) #29 left!

write.table(LRT_filtered, file = "LRT_filtered.txt", sep = "\t",
            row.names = F, col.names = F, quote = FALSE)
```
Now we can compare these values to a chi-square distribution (1 degree of freedom) to get a p-value. The critical value for p<0.05 is 3.84 ; for p<0.01 it is 6.64

# 7) Interpret results!

BEWARE: with large datasets you will get statistically significant results. They may even be real. but are they biologically meaningful? It is posssible to detect even extremely weak correlations with large enough datasets. But do they matter?

Firstly, what are the genes? I have a list of 29 potentially under positive selection in the Willisornis lineage. I need to get their names.
```
cut -f 1 LRT_filtered
```

# GO analysis

A: Fisher's exact test. Count how many genes in a particular GO category have a significant value for their likelihood ratio test. Use Fisher's Exact Test to see if the GO category is enriched for significant genes. 
B: Mann-Whitney test. Compare the likelihood ratio test statistic of different groups

Don't forget multiple test correction! For example, Bonferonni correction.

I am using ermineJ for my GO analyses because I really like the documentation and it is straightforward, works on command line (but there is a GUI too), and allows you to provide your own annotated datasets so that it works on non-model organisms. I have more details about it in the gene family expansion page.

1) GO functions of all genes that detected omega > 1 in the branch-site alternative model  
(I did the analysis also with all genes where codeml suggested positive selection regardless of significance but I am not reporting this because I do not think it is a good idea, I only ran it because I was impatient and the null models were still running).

```bash
mkdir /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/GO_analysis
cd /home/0_GENOMES1/0_Genetic_resources/orthologues/dnds/anteater_dnds/GO_analysis

#first, turn the orthogroup names into gene names for the possibly selected group
cat ../LRT_filtered.txt | cut -f 1 | while read orthogroup ; do grep "WilPoe" /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments/"$orthogroup".faa >> LRT_filtered_geneIDs.txt ; done
sed -i 's/>//g' LRT_filtered_geneIDs.txt
sed -i 's/-RA//g' LRT_filtered_geneIDs.txt
#29 genes out of the original set

#this is without filtering (not a great idea)
#cat ../possible_selection | while read orthogroup ; do grep "WilPoe" /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments/"$orthogroup".faa >> possible_selection_geneIDs.txt ; done
#sed -i 's/>//g' possible_selection_geneIDs.txt
#sed -i 's/-RA//g' possible_selection_geneIDs.txt
#1594 genes out of the original set

#Do the same for the rest of the genes that were tested and successfully estimated an omega
cat ../omega_estimates | sed 's/\.\///g' | sed 's/\/.*$//g' | while read orthogroup ; do grep "WilPoe" /home/0_GENOMES1/0_Genetic_resources/orthologues/alignments/"$orthogroup".faa >> tested_geneIDs.txt ; done
sed -i 's/>//g' tested_geneIDs.txt
sed -i 's/-RA//g' tested_geneIDs.txt

#make a scorefile
awk 'BEGIN{FS="\t"}{print $1,"0"}' tested_geneIDs.txt > LRT_filtered.scorefile
cat LRT_filtered_geneIDs.txt | while read gene ; do sed -i "s/$gene 0/$gene 1/g" LRT_filtered.scorefile ; done
sed -i 's/ /\t/g' LRT_filtered.scorefile

#this is without filtering 
#awk 'BEGIN{FS="\t"}{print $1,"0"}' tested_geneIDs.txt > possible_selection.scorefile
#cat possible_selection_geneIDs.txt | while read gene ; do sed -i "s/$gene 0/$gene 1/g" possible_selection.scorefile ; done
#sed -i 's/ /\t/g' possible_selection.scorefile

#run ermineJ
ERMINEJ_HOME=/home/0_PROGRAMS/ermineJ-3.1.2/
/home/0_PROGRAMS/ermineJ-3.1.2/bin/ermineJ.sh -a /home/0_GENOMES1/0_WEIRLAB_GENOMES_CHROMIUMX/anteater/Cafe/enrichment_analysis/GO_mappings.ermineJ.txt -s LRT_filtered.scorefile -c /home/0_PROGRAMS/ermineJ-3.1.2/go_daily-termdb.rdf-xml.gz -o LRT_filtered.ermine.results -y 5 -b

#this is without filtering 
#/home/0_PROGRAMS/ermineJ-3.1.2/bin/ermineJ.sh -a /home/0_GENOMES1/0_WEIRLAB_GENOMES_CHROMIUMX/anteater/Cafe/enrichment_analysis/GO_mappings.ermineJ.txt -s possible_selection.scorefile -c /home/0_PROGRAMS/ermineJ-3.1.2/go_daily-termdb.rdf-xml.gz -o possible_selection.ermine.results -y 5 -b
```
**Results:** No significant results! All is not lost, it is possible that specific genes were under positive selection, but not entire gene families, so they would not show up in a GO analysis.

If you did find genes under selection, if feasible, check the alignment manually to make sure that it looks correctly aligned. Also, are ensure that you assigned orthology correctly for this gene.

Here is a list of the genes:

| Willisornis gene name | orthogroup | CAFÉ orthogroup | Similar to                                                     |
|-----------------------|------------|-----------------|----------------------------------------------------------------|
| WilPoe00216           | OG0004903  | OG0004860.fa:   |  TERF1: Telomeric repeat-binding factor 1                      |
| WilPoe01331           | OG0007560  | OG0007352.fa:   |  Rxylt1: Ribitol-5-phosphate xylosyltransferase 1              |
| WilPoe02350           | OG0006962  | OG0006807.fa:   |  IL6: Interleukin-6                                            |
| WilPoe02832           | OG0008460  | OG0008229.fa:   |  Nrdc: Nardilysin                                              |
| WilPoe03433           | OG0009245  | OG0008958.fa:   |  POMP: Proteasome maturation protein                           |
| WilPoe03547           | OG0009292  | OG0009002.fa:   |  CCDC122: Coiled-coil domain-containing protein 122            |
| WilPoe05105           | OG0006388  | OG0006272.fa:   |  CERS3: Ceramide synthase 3                                    |
| WilPoe05533           | OG0007875  | OG0007657.fa:   |  ZNF438: Zinc finger protein 438                               |
| WilPoe07319           | OG0005703  | OG0005604.fa:   |  CASP6: Caspase-6                                              |
| WilPoe08440           | OG0008013  | OG0007807.fa:   |  NDUFAF5: Arginine-hydroxylase NDUFAF5                         |
| WilPoe08473           | OG0008029  | OG0007823.fa:   |  PUS10: Putative tRNA pseudouridine synthase Pus10             |
| WilPoe08958           | OG0005251  | OG0005183.fa:   |  APOOL: MICOS complex subunit MIC27                            |
| WilPoe09520           | OG0006144  | OG0006031.fa:   |  CAMKK1: Calcium/calmodulin-dependent protein kinase kinase 1  |
| WilPoe09646           | OG0008065  | OG0007857.fa:   |  FAM180A: Protein FAM180A                                      |
| WilPoe10382           | OG0006584  | OG0003516.fa:   |  PDLIM4: PDZ and LIM domain protein 4                          |
| WilPoe10631           | OG0005217  | OG0005154.fa:   |  NUP50: Nuclear pore complex protein Nup50                     |
| WilPoe10848           | OG0007342  | OG0007146.fa:   |  Tsen15: tRNA-splicing endonuclease subunit Sen15              |
| WilPoe11434           | OG0007268  | OG0007079.fa:   |  CLRN1: Clarin-1                                               |
| WilPoe11906           | OG0008812  | OG0008557.fa:   |  PIK3AP1: Phosphoinositide 3-kinase adapter protein 1          |
| WilPoe12145           | OG0004799  | OG0004761.fa:   |  PSMB2: Proteasome subunit beta type-2                         |
| WilPoe12554           | OG0006208  | OG0006094.fa:   |  NUDC: Nuclear migration protein nudC                          |
| WilPoe12649           | OG0009059  | OG0008785.fa:   |  NCBP3: Nuclear cap-binding protein subunit 3                  |
| WilPoe12975           | OG0008859  | OG0004243.fa:   |  Zmat4: Zinc finger matrin-type protein 4                      |
| WilPoe13055           | OG0005447  | OG0009416.fa:   |  PNPT1: Polyribonucleotide nucleotidyltransferase 1            |
| WilPoe13900           | OG0007827  | OG0007611.fa:   |  CD3E: T-cell surface glycoprotein CD3 epsilon chain           |
| WilPoe14705           | OG0009077  | OG0008803.fa:   |  B9d1: B9 domain-containing protein 1                          |
| WilPoe15842           | OG0008960  | OG0002086.fa:   | PPARG: Peroxisome proliferator-activated receptor gamma        |
| WilPoe16825           | OG0009196  | OG0002726.fa:   |  POLE2: DNA polymerase epsilon subunit 2                       |
| WilPoe17236           | OG0006031  | OG0009556.fa:   |  HMBOX1: Homeobox-containing protein 1                         |

After this, the last step is to research the genes to see what they do. In this case, I am interested if any of these genes can be related to the unique features of antbirds, such as:
* ant-following
* living in the Amazon
* long lifespans
* nightly torpor
* low metabolism
* thin/permeable skin
* innate song


# Appendix
These are the notes that I took while learning how to do this pipeline. Particularly helpful for me was the book "Molecular Population Genetics" by Matthew Hahn, and To start, and the Parasite Genomics Protocols 2015 book, [chapter 4](https://link.springer.com/content/pdf/10.1007%2F978-1-4939-1438-8.pdf): "65Christopher Peacock (ed.), Parasite Genomics Protocols, Methods in Molecular Biology, vol. 1201,DOI 10.1007/978-1-4939-1438-8_4, © Springer Science+Business Media New York 2015Chapter 4 A Beginners Guide to Estimating the Non-synonymous to Synonymous Rate Ratio of all Protein-Coding Genes in a Genome". There is also a tutorial [here](https://www.protocols.io/view/introduction-to-calculating-dn-ds-ratios-with-code-qhwdt7e?step=4) and of course the paml manual [here](http://abacus.gene.ucl.ac.uk/software/pamlDOC.pdf).

# Intro to dN/dS estimates with a proteome

### Firstly, should you calculate a dN/dS ratio for your data?
If you have population genetic data (ie at least 2 haploid samples from your species) then you may be interested in the more powerful McDonald-Kreitman test. 

*Note*: dN/dS ratio is meant to compare sequences from different species that are not sharing alleles through gene flow. If you are comparing two sequences from the same species, then you should not calculate the dN/dS ratio with an intention to observe anything to do with positive selection. This is because you will not likely see positively-selected non-synonymous (or synonymous) mutations as polymorphisms in your dataset: they rise swiftly to high frequency due to positive selection (if they are not lost right away due to drift), spending very little time as a polymorphism at intermediate allele frequency, and so you are quite unlikely to catch them as a polymorphism in your dataset. Instead, if you do see non-synonymous differences between them, these are probably either deleterious or neutral/nearly neutral, or retained at intermediate allele frequency due to **balancing selection**. Thus the equivalent of dN/dS ratio for within-species comparisons, is the piN/piS ratio (where pi is nucleotide diversity within a population). If piN/piS is greater than one it suggests that balancing selection is acting.

### Theory
* the substitution rate of new neutral alleles (*k*, aka *ρ*) equals the mutation rate that these neutral alleles arise (μ) (regardless of population size).
* advantangeous mutations (s > 0) come to fixation with a higher probability μ~=2s and thus a higher substitution rate `4Nvfs` (where v is overall mutation rate, f is fraction which are advantageous, and s is strength of selection). Note this depends on population size (efficacy of selection and number of individuals rolling dice to get an advantageous mutation).
* deleterious mutations (s < 0) come to fixation with a lower probability μ~=2s/(1 - e^(-4Ns)) and thus a lower substitution rate `4Nvfs/(1 - e^(-4Ns))`. Note this depends on population size (efficacy of selection).
* sequence divergence equals *k* \* 2t [+ ancestral variation (theta_Ancestral)]
* dN/dS (AKA KA/KS) measures the ratio of divergence due to nonsynonymous vs synonymous mutations within a protein-coding sequence.
* `dN` = number of nonsynonymous differences per possible nonsynonymous site
* `dS` = number of synonymous differences per possible synonymous site
* accounting for numbers of nonsynonymous/synonymous sites (sites where a mutation would make a nonsynonymous or synonymous change) accounts for the fact that there are usually more possible nonsynonymous mutations than synonymous mutations. So if there was no selection (eg pseudogene, dN/dS=1), you would in fact expect more nonsynonymous than synonymous differences!
* In order to do a formal test, we are calculating dN/dS in a likelihood framework which estimates several parameters including omega, which is essentially dN/dS without estimating dN or dS separately.

### Assumptions
* Assumes that all/most synonymous mutations are selectively (nearly) neutral (not true but usually close enough. Mostly violated in very broadly expressed genes in fast-growing species with huge population sizes)
* This method using PAML assumes that there is a single tree topology (ie no recombination within the aligment)

Note: *Most genes are under purifying selection, dN/dS <<1*

### Interpretations
* If trying to get a single dN/dS ratio for a gene, it will almost certainly be less than 1 unless it is something like an immune gene or reproductive arms race gene, Red Queen situation, etc. If you want to find dN/dS > 1 you will probably have to let it vary between branches or among sites (probably both)
* dN/dS << 1: strong purifying selection over most of protein
* dN/dS < 1: purifying selection over most of protein (could be a few advantageous mutations, but cannot tell)
* dN/dS = 1: neutral evolution OR positive selection is balanced with purifying selection, cannot tell.
* dN/dS > 1: positive selection! (remember there is still probably SOME purifying selection against deleterious mutations, but it is overshadowed by the positively selected mutations)
* Note that it is *not* valid to do 1 - dN/dS = fraction of deleterious nonsynonymous mutations. dN/dS is affected by several parameters including number of nonsynonymous deleterious mutations, number of nonsynonymous positively selected mutations, strengths of selection, and population size.
* In general, larger populations should have lower dN/dS due to lower impact of drift [but this did not really hold in birds](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-014-0542-8).

Warning: often, only a single protein domain will be under strong positive selection. Will this be enough to shift the overall omega enough for you to detect it if you only calculate a single value for the whole protein? Also, if only one species is under selection within your dataset, will that shift omega enough to detect it? PAML has models that allow omega to vary between lineages and/or sites to help deal with this.

### Notes on picking species
* As noted above, they should be different species, do not include members of the same species in the alignment
* This workflow will throw out any positions in your aligment that have a gap. If you include more distant species in your comparisons, you will probably end up with more gaps in the alignment and will have to remove more data. This reduces power but also can lead to a bias as you are throwing away the codon positions that are capable of being an indel. If these positions tend to be under less stringent purifying selection on average than sites that have no indels, then you will bias your dN/dS ratio lower towards zero (less likely to detect positive selection possibly).
* If the species are too far apart, you will eventually run into saturation as the same nucleotides mutate more than once in your dataset. This should not lead to false positives in tests for dN/dS>1  but could reduce power to detect true positives.
* The species need to at least be close enough to align well. It seems like alignment errors are more dangerous than sequence aturation as you increase divergence. Alignment errors can raise dN/dS and possibly give false positives for positive selection.
* The book chapter advises that the sequences should not be too similar (>95% similar at nucleotide level) or there will not be enough differences to calculate dN/dS accurately. But, they should not be so far away that mutations are saturated or you can't assign orthologs or make good alignments. 
* The more species, the more power to detect positive selection. "absolute minimum number of species is 4 or 5 and that 10 is good, but 20 would be better."... "good estimates of  ω can be obtained with six species, while detection of adaptive evolution has relatively low power with this many taxa"