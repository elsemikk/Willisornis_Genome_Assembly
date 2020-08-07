This page describes the pipeline used to download and process proteome and CDS data from Ensembl and Refseq. These datasets were used for the dN/dS ratio analysis and gene family expansion analyses.

To replicate this pipeline, you do not need any input files, but you will need a few programs installed like Seqkit, and you will likely have to change the directory names to match your own file system.

# 1) Obtain data: proteins and CDS

For this project I am taking data from 2 sources: Ensembl and Refseq. These two sources have standardized genome annotation pipelines for predicting proteins and their datasets can be easily obtained and are publicly available.  
Note that some of the species available from Ensembl/RefSeq are under embargo so analyses of those genomes should not be published, with some exceptions listed by the genome producers. 

### Downloading CDS & Proteomes from Ensembl
There was just a new update to Ensembl 99 while I was working on this project. A tree of the species available can be found [here](http://useast.ensembl.org/info/about/speciestree.html). I'm downloading datasets from all of the available birds but I will only use the Passerines and their parrot outgroup since this particular project is only interested in antbirds.

The directory structure of ensembl has the files in `ftp://ftp.ensembl.org/pub/release-99/fasta/` and then a directory which is the scientific name of the organism. Within that directory the protein sequences is in `/pep/*.pep.all.fa.gz` and the CDS nucleotide sequences in `/cds/*.cds.all.fa.gz`. These can be accessed via command line with wget.
```
#set up directory to keep raw data
mkdir /home/0_GENOMES1/0_Genetic_resources/Ensembl_99
cd /home/0_GENOMES1/0_Genetic_resources/Ensembl_99

#Download cds and peptide sequences for all birds on Ensembl
#redirect output to gunzip to uncompress and then rename the files to my standard codes
#I am keping a record of what I download in Ensembl_downloads.log in case I need to check what the original name of each file was or what genome assembly version the data came from
#The files are named as the first 3 letters of genus + first 3 letters of species so that I can more easily keep track

# Suboscines

wget ftp://ftp.ensembl.org/pub/release-99/fasta/lepidothrix_coronata/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Lepcor.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/lepidothrix_coronata/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Lepcor.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/manacus_vitellinus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Manvit.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/manacus_vitellinus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Manvit.CDS.fa


# Oscines

wget ftp://ftp.ensembl.org/pub/release-99/fasta/cyanistes_caeruleus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cyacae.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/cyanistes_caeruleus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cyacae.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/parus_major/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Parmaj.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/parus_major/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Parmaj.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/junco_hyemalis/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Junhie.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/junco_hyemalis/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Junhie.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/zonotrichia_albicollis/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Zonalb.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/zonotrichia_albicollis/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Zonalb.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/ficedula_albicollis/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Ficalb.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/ficedula_albicollis/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Ficalb.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/serinus_canaria/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Sercan.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/serinus_canaria/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Sercan.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/erythrura_gouldiae/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Erygou.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/erythrura_gouldiae/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Erygou.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/lonchura_striata_domestica/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Lonstr.AA.fa 
wget ftp://ftp.ensembl.org/pub/release-99/fasta/lonchura_striata_domestica/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Lonstr.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/taeniopygia_guttata/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Taegut.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/taeniopygia_guttata/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Taegut.CDS.fa

# Psittaciformes (parrots)

wget ftp://ftp.ensembl.org/pub/release-99/fasta/melopsittacus_undulatus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Melund.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/melopsittacus_undulatus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Melund.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/strigops_habroptila/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Strhab.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/strigops_habroptila/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Strhab.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/amazona_collaria/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Amacol.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/amazona_collaria/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Amacol.CDS.fa

# Assorted Neoaves

wget ftp://ftp.ensembl.org/pub/release-99/fasta/athene_cunicularia/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Athcun.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/athene_cunicularia/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Athcun.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/accipiter_nisus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Accnis.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/accipiter_nisus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Accnis.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/aquila_chrysaetos_chrysaetos/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aquchr.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/aquila_chrysaetos_chrysaetos/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aquchr.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/calidris_pugnax/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Calpug.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/calidris_pugnax/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Calpug.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/calidris_pygmaea/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Calpyg.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/calidris_pygmaea/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Calpyg.CDS.fa

# Galloanserae

wget ftp://ftp.ensembl.org/pub/release-99/fasta/gallus_gallus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Galgal.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/gallus_gallus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Galgal.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/pavo_cristatus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Pavcri.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/pavo_cristatus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Pavcri.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/chrysolophus_pictus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Chrpic.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/chrysolophus_pictus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Chrpic.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/numida_meleagris/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Nummel.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/numida_meleagris/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Nummel.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/meleagris_gallopavo/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Melgal.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/meleagris_gallopavo/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Melgal.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/coturnix_japonica/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cotjap.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/coturnix_japonica/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cotjap.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/phasianus_colchicus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Phacol.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/phasianus_colchicus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Phacol.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/anas_platyrhynchos_platyrhynchos/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Anapla.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/anas_platyrhynchos_platyrhynchos/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Anapla.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/anser_cygnoides/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Anscyg.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/anser_cygnoides/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Anscyg.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/anser_brachyrhynchus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Ansbra.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/anser_brachyrhynchus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Ansbra.CDS.fa

# Paleognathae

wget ftp://ftp.ensembl.org/pub/release-99/fasta/struthio_camelus_australis/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Strcam.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/struthio_camelus_australis/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Strcam.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/nothoprocta_perdicaria/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Notper.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/nothoprocta_perdicaria/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Notper.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/dromaius_novaehollandiae/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Dronov.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/dromaius_novaehollandiae/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Dronov.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_haastii/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Apthaa.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_haastii/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Apthaa.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_owenii/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aptowe.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_owenii/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aptowe.CDS.fa

wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_rowi/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aptrow.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/apteryx_rowi/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Aptrow.CDS.fa

# Crocodile (outgroup to birds)
wget ftp://ftp.ensembl.org/pub/release-99/fasta/crocodylus_porosus/pep/*.pep.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cropor.AA.fa
wget ftp://ftp.ensembl.org/pub/release-99/fasta/crocodylus_porosus/cds/*.cds.all.fa.gz -O - 2>> Ensembl_downloads.log | gunzip -c > Cropor.CDS.fa
```
* `wget -O -`: the downloading file gets redirected to standard out in order to be piped to the next command rather than saved as it is
* `2>> `: save the standard error messages to a file as a record instead of printing to the Terminal screen


Now, to process these files. Firstly, I am going to make a file that just lists the species that I downloaded in order to process them in a loop.
```
# find a list of all the .AA.fa files, remove the ".AA.fa" and remove the leading "./" and then save that list to a file
find ./*.AA.fa | sed 's/.AA.fa//g' | sed 's/.\///g' > Ensembl99_specieslist.txt
wc -l Ensembl99_specieslist.txt #35 species of bird + crocodile
```

Next we want to filter to only keep the longest isoform of each protein. Also, it would be nice if that protein were named the exact same thing as its corresponding CDS so we will modify the names.  

```
#setup environment
cd /home/0_GENOMES1/0_Genetic_resources/Ensembl_99
export PATH=$PATH:/home/0_PROGRAMS #for seqkit

#get lengths of proteins
cat Ensembl99_specieslist.txt | while read line ; do seqkit fx2tab -n -l "$line".AA.fa | awk 'BEGIN{FS="\t"}{gsub(" .*$", "", $1); print}' | sort > "$line".AA_len.tsv ; done
#Get matching file where gene name is in first column, protein name is in second column
cat Ensembl99_specieslist.txt | while read line ; do grep "^>" "$line".AA.fa | awk 'BEGIN{FS="\t"}{gsub(" .*gene:", "\t", $1); gsub(" .*$", "", $1); print}' | awk 'BEGIN{FS="\t"}{print $2,$1}' | sed 's/>//g' | sort -k 2,2 | uniq > "$line".gene_AA.tsv ; done
#get list of longest proteins for each gene
cat Ensembl99_specieslist.txt | while read line ; do join -1 2 "$line".gene_AA.tsv -2 1 "$line".AA_len.tsv | awk 'len[$2]<$3 {len[$2]=$3; id[$2]=$1} END {for (i in id) {print id[i]}}' > "$line".longest_AA.txt ; done
#select these longest isoforms from the protein fasta file
cat Ensembl99_specieslist.txt | while read line ; do seqkit grep -r -n -f "$line".longest_AA.txt "$line".AA.fa > longest."$line".AA.fa ; done

#Get a list with the name of the matching transcript for each of the selected proteins
cat Ensembl99_specieslist.txt | while read line ; do grep "^>" longest."$line".AA.fa | sed 's/^.* transcript://g' | sed 's/ .*$//g' > "$line".longest_CDS.txt ; done
#select these longest isoforms from the CDS fasta file
cat Ensembl99_specieslist.txt | while read line ; do seqkit grep -r -n -f "$line".longest_CDS.txt "$line".CDS.fa > longest."$line".CDS.fa ; done
```
* `seqkit fx2tab -n -l "$line".AA.fa`: outputs the fasta header, and the number of AA's in it
* `awk 'BEGIN{FS="\t"}{gsub(" .*$", "", $1); print}' | sort`: removes everything after the first space until the end of the line in the fasta header in order to simplify the names
* `grep "^>" "$line".AA.fa | awk 'BEGIN{FS="\t"}{gsub(" .*gene:", "\t", $1); gsub(" .*$", "", $1); print}' | awk 'BEGIN{FS="\t"}{print $2,$1}' | sed 's/>//g' | sort -k 2,2 | uniq`: first, find all of the lines that start with ">" (fasta headers); remove everything from the first space until the word gene and replace it with a tab, and remove everything after the next space until the end of the line. Then rearrange the columns, and remove the ">" symbols. Sort that by the second column, remove redundant lines and now you have the gene name in the first column and corresponding protein name in second column.

That took a bit of coding but now we have sequences of the longest isoform for each protein and its CDS, but I need their headers to match, so I made these commands to rename them according to their gene name rather than protein/transcript name. I am also replacing the Ensembl species code with my own codes (first 3 letters of genus + first 3 of species)

```
#CDS
#preserve the original file by making a copy. Then do some find+replace to simplify the headers and add my species codes
cat Ensembl99_specieslist.txt | while read line ; do cp longest."$line".CDS.fa longest.simpleheader."$line".CDS.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i 's/>.*gene:/>/g' longest.simpleheader."$line".CDS.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i 's/ .*$//g' longest.simpleheader."$line".CDS.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i "s/>ENS...G/>$line/g" longest.simpleheader."$line".CDS.fa ; done

#Here I made a key for translating between the old and new names if needed
cat Ensembl99_specieslist.txt | while read line ; do head -n 1 longest.simpleheader."$line".AA.fa | sed 's/>//g' | sed 's/[0:9].*$//g' >> Ensembl2speciescodes ; done
paste Ensembl2speciescodes Ensembl99_specieslist.txt > temp ; mv temp Ensembl2speciescodes 

#AA
#repeat CDS steps for the AA sequences
cat Ensembl99_specieslist.txt | while read line ; do cp longest."$line".AA.fa longest.simpleheader."$line".AA.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i 's/>.*gene:/>/g' longest.simpleheader."$line".AA.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i 's/ .*$//g' longest.simpleheader."$line".AA.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i "s/>ENS...P/>$line/g" longest.simpleheader."$line".AA.fa ; done
cat Ensembl99_specieslist.txt | while read line ; do sed -i "s/>ENS...G/>$line/g" longest.simpleheader."$line".AA.fa ; done

#check that thet all look reasonable and headers look clean
head -n 1 *simple*.fa
```
Now we have clean CDS/AA fasta sequences for all birds included in Ensembl release 99 in the folder `/home/0_GENOMES1/0_Genetic_resources/Ensembl_99`.

## Getting data from Refseq
Refseq has some species annotated which Ensembl does not have yet, so I am going to get these too. They are stored in a ftp directory which has less standardized paths than Ensembl. Here is a [list](https://www.ncbi.nlm.nih.gov/genome/annotation_euk/all/) of the species available. 
It is also possible to view a list of annotations [in progress](https://www.ncbi.nlm.nih.gov/genome/annotation_euk/status/#inprogress). Some exciting species always coming up!

I am making a list of all the directories for each species that I want, and the species code I will use for it first. Then I will be able to download all the data automatically.
```
#set up a folder to keep them in
mkdir /home/0_GENOMES1/0_Genetic_resources/Refseq
cd /home/0_GENOMES1/0_Genetic_resources/Refseq

#make a list of all of the genomes I want and their ftp directories
cat > genomes_to_fetch.txt #copy paste the file contents below, then press ctrl-d to finish
```
Here are the contents of `genomes_to_fetch.txt`:
```
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57068/100
Acachl
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8839/103
Anapla
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/381198/100
Anscyg
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/279965/101
Antcar
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57397/100
Apavit
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9233/101
Aptfor
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/202946/100
Aptaus
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/308060/100
Aptrow
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/216574/100
Aquchr
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/223781/100
Aquchr2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/194338/100
Athcun
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/100784/100
Balreg
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/175836/100
Bucrhi
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/198806/100
Calpug
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9244/101
Calana
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/87175/100
Campar
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54380/100
Carcri
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8897/100
Chapel
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/50402/100
Chavoc
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/187382/100
Chlmac
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57412/100
Colstr
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8932/102
Colliv
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/415028/100
Coralt
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/85066/101
Corbra
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/932674/102
Corcor
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/93934/100
Cotjap
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/55661/100
Cuccan
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/156563/100
Cyacae
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8790/100
Dronov
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/188379/100
Egrgar
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/164674/100
Emptra
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54383/100
Eurhel
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/345164/102
Falche
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8954/102
Falper
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/59894/101
Ficalb
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30455/100
Fulgla
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9031/104
Galgal
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/37040/100
Gavste
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/48883/102
Geofor
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8969/100
Halalb
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/52644/100
Halleu
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/321398/100
Lepcor
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/188344/100
Lepdis
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/299123/101
Lonstr
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/328815/103
Manvit
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9103/103
Melgal
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/13146/103
Melund
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57421/100
Mernub
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54374/100
Mesuni
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/114329/100
Neochr
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/176057/100
Nesnot
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/128390/100
Nipnip
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30464/100
Notper
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8996/100
Nummel
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30419/100
Opihoa
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9157/101
Parmaj
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/36300/100
Pelcri
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/97097/100
Phalep
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9209/100
Phacar
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9054/100
Phacol
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/118200/100
Picpub
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/649802/100
Pipfil
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/181119/101
Psehum
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/240206/100
Ptegut
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9238/100
Pygade
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9135/102
Sercan
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/2489341/100
Strhab
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/441894/100
Strcam
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9172/100
Stuvul
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/59729/104
Taegut
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/121530/100
Tauery
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/94827/100
Tingut
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/56313/100
Tytalb
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/44394/102
Zonalb
```
Now make this list have tab separated columns. Then use curl to go into the directories and list the contents. Take the name of the genome, which starts with "GCF" and add it to the file. Download the cds and AA sequences, which all have the prefix `*_cds_from_genomic.fna.gz` or `*_translated_cds.faa.gz`. This way I know that the AA and CDS sequences will match exactly.
```
#place the species name on the same line as their directory, separated by tab (\t)
cat genomes_to_fetch.txt | paste -d"\t" - - > temp ; mv temp genomes_to_fetch.txt
#Get a list of the genome for each species (a record of genome version as well) and add it to the directory file
cat genomes_to_fetch.txt | while read site species ; do curl -l "$site"/GCF* | grep GCF >> genome_directories ; done
paste genomes_to_fetch.txt genome_directories > temp ; mv temp genomes_to_fetch.txt

#download the cds and amino acids from NCBI ftp directory using the list of directories
cat genomes_to_fetch.txt | while read site species genome ; do wget "$site"/"$genome"/*_cds_from_genomic.fna.gz -O - 2>> Refseq_CDS_downloads.log | gunzip -c > "$species".CDS.fa ; done
cat genomes_to_fetch.txt | while read site species genome ; do wget "$site"/"$genome"/*_translated_cds.faa.gz -O - 2>> Refseq_AA_downloads.log | gunzip -c > "$species".AA.fa ; done
```

I have placed the `genomes_to_fetch.txt` below in the appendix for the record.  

Now that I have all the raw data, I need to filter them just like the Ensembl sets: get a file linking gene to protein names, filter to keep only the longest isoform per gene, and then simplify the fasta headers.
```
#filter to keep only the longest isoform of each gene
export PATH=$PATH:/home/0_PROGRAMS #for seqkit
#get list of protein lengths
cat genomes_to_fetch.txt | while read site species genome ; do seqkit fx2tab -n -l "$species".AA.fa | awk 'BEGIN{FS="\t"}{gsub("^.*protein_id=", "", $1); gsub("].*$", "", $1); print}' | sort > "$species".AA_len.tsv ; done
#get file linking gene name is in first column, protein name in second column
cat genomes_to_fetch.txt | while read site species genome ; do grep "^>" "$species".AA.fa | awk 'BEGIN{FS="\t"}{gsub("^.*GeneID:", "", $1); gsub("].*protein_id=", "\t", $1); gsub("].*$", "", $1); print}' | sort -k 2,2 | uniq > "$species".gene_AA.tsv ; done

#get list of longest proteins for each gene
cat genomes_to_fetch.txt | while read site species genome ; do join -1 2 "$species".gene_AA.tsv -2 1 "$species".AA_len.tsv | awk 'len[$2]<$3 {len[$2]=$3; id[$2]=$1} END {for (i in id) {print id[i]}}' > "$species".longest_AA.txt ; done
#select these from the protein fasta
cat genomes_to_fetch.txt | while read site species genome ; do seqkit grep -r -n -f "$species".longest_AA.txt "$species".AA.fa > longest."$species".AA.fa ; done
#repeat for CDS
cat genomes_to_fetch.txt | while read site species genome ; do seqkit grep -r -n -f "$species".longest_AA.txt "$species".CDS.fa > longest."$species".CDS.fa ; done

#simplify headers and add my own species codes
#CDS
cat genomes_to_fetch.txt | while read site species genome ; do cp longest."$species".CDS.fa longest.simpleheader."$species".CDS.fa ; done
cat genomes_to_fetch.txt | while read site species genome ; do sed -i "s/>.*GeneID:/>$species/g" longest.simpleheader."$species".CDS.fa ; done
cat genomes_to_fetch.txt | while read site species genome ; do sed -i 's/].*$//g' longest.simpleheader."$species".CDS.fa ; done

#AA
cat genomes_to_fetch.txt | while read site species genome ; do cp longest."$species".AA.fa longest.simpleheader."$species".AA.fa ; done
cat genomes_to_fetch.txt | while read site species genome ; do sed -i "s/>.*GeneID:/>$species/g" longest.simpleheader."$species".AA.fa ; done
cat genomes_to_fetch.txt | while read site species genome ; do sed -i 's/].*$//g' longest.simpleheader."$species".AA.fa ; done
```

Now we have:
* for all the bird species on Ensembl release 99 and Refseq as of Jan 20 2020:
* 1) a fasta file of amino acid sequences, keeping only the longest isoform, with simplified headers
* 2) a fasta file of corresponding CDS sequences, keeping only the longest isoform, with simplified headers

This is what I used for the dN/dS ratio analysis of Willisornis, and the OrthoFinder/Cafe pipeline. I only used the parrots/songbirds as my project is focused on the antbird lineage in particular. Also, I took out a couple species that are under embargo right now (2020) , like Strigops. Also, I used the older release (Ensembl 98) of Taeniopygia guttata (Zebra Finch) because the current release is under embargo.

# Appendix
Here are the contents of `genomes_to_fetch.txt` for the record. It lists the URL of the ftp site where I obtained the data, my species code, and the genome assembly name associated with the annotation.
```
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57068/100	Acachl	GCF_000695815.1_ASM69581v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8839/103	Anapla	GCF_003850225.1_IASCAAS_PekingDuck_PBH1.5
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/381198/100	Anscyg	GCF_000971095.1_AnsCyg_PRJNA183603_v1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/279965/101	Antcar	GCF_000700745.1_ASM70074v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57397/100	Apavit	GCF_000703405.1_ASM70340v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9233/101	Aptfor	GCF_000699145.1_ASM69914v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/202946/100	Aptaus	GCF_001039765.1_AptMant0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/308060/100	Aptrow	GCF_003343035.1_aptRow1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/216574/100	Aquchr	GCF_000766835.1_Aquila_chrysaetos-1.0.2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/223781/100	Aquchr2	GCF_900496995.1_bAquChr1.2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/194338/100	Athcun	GCF_003259725.1_athCun1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/100784/100	Balreg	GCF_000709895.1_ASM70989v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/175836/100	Bucrhi	GCF_000710305.1_ASM71030v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/198806/100	Calpug	GCF_001431845.1_ASM143184v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9244/101	Calana	GCF_003957555.1_bCalAnn1_v1.p
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/87175/100	Campar	GCF_901933205.1_STF_HiC
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54380/100	Carcri	GCF_000690535.1_ASM69053v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8897/100	Chapel	GCF_000747805.1_ChaPel_1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/50402/100	Chavoc	GCF_000708025.1_ASM70802v2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/187382/100	Chlmac	GCF_000695195.1_ASM69519v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57412/100	Colstr	GCF_000690715.1_ASM69071v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8932/102	Colliv	GCF_000337935.1_Cliv_1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/415028/100	Coralt	GCF_003945725.1_ASM394572v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/85066/101	Corbra	GCF_000691975.1_ASM69197v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/932674/102	Corcor	GCF_000738735.2_ASM73873v2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/93934/100	Cotjap	GCF_001577835.1_Coturnix_japonica_2.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/55661/100	Cuccan	GCF_000709325.1_ASM70932v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/156563/100	Cyacae	GCF_002901205.1_cyaCae2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8790/100	Dronov	GCF_003342905.1_droNov1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/188379/100	Egrgar	GCF_000687185.1_ASM68718v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/164674/100	Emptra	GCF_003031625.1_ASM303162v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54383/100	Eurhel	GCF_000690775.1_ASM69077v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/345164/102	Falche	GCF_000337975.1_F_cherrug_v1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8954/102	Falper	GCF_000337955.1_F_peregrinus_v1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/59894/101	Ficalb	GCF_000247815.1_FicAlb1.5
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30455/100	Fulgla	GCF_000690835.1_ASM69083v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9031/104	Galgal	GCF_000002315.5_GRCg6a
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/37040/100	Gavste	GCF_000690875.1_ASM69087v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/48883/102	Geofor	GCF_000277835.1_GeoFor_1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8969/100	Halalb	GCF_000691405.1_ASM69140v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/52644/100	Halleu	GCF_000737465.1_Haliaeetus_leucocephalus-4.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/321398/100	Lepcor	GCF_001604755.1_Lepidothrix_coronata-1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/188344/100	Lepdis	GCF_000691785.1_ASM69178v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/299123/101	Lonstr	GCF_005870125.1_lonStrDom2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/328815/103	Manvit	GCF_001715985.3_ASM171598v3
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9103/103	Melgal	GCF_000146605.3_Turkey_5.1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/13146/103	Melund	GCF_000238935.1_Melopsittacus_undulatus_6.3
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/57421/100	Mernub	GCF_000691845.1_ASM69184v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/54374/100	Mesuni	GCF_000695765.1_ASM69576v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/114329/100	Neochr	GCF_003984885.1_ASM398488v2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/176057/100	Nesnot	GCF_000696875.1_ASM69687v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/128390/100	Nipnip	GCF_000708225.1_ASM70822v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30464/100	Notper	GCF_003342845.1_notPer1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/8996/100	Nummel	GCF_002078875.1_NumMel1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/30419/100	Opihoa	GCF_000692075.1_ASM69207v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9157/101	Parmaj	GCF_001522545.2_Parus_major1.1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/36300/100	Pelcri	GCF_000687375.1_ASM68737v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/97097/100	Phalep	GCF_000687285.1_ASM68728v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9209/100	Phacar	GCF_000708925.1_ASM70892v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9054/100	Phacol	GCF_004143745.1_ASM414374v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/118200/100	Picpub	GCF_000699005.1_ASM69900v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/649802/100	Pipfil	GCF_003945595.1_ASM394559v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/181119/101	Psehum	GCF_000331425.1_PseHum1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/240206/100	Ptegut	GCF_000699245.1_ASM69924v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9238/100	Pygade	GCF_000699105.1_ASM69910v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9135/102	Sercan	GCF_007115625.1_cibio_Scana_2019
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/2489341/100	Strhab	GCF_004027225.1_bStrHab1_v1.p
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/441894/100	Strcam	GCF_000698965.1_ASM69896v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9172/100	Stuvul	GCF_001447265.1_Sturnus_vulgaris-1.0
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/59729/104	Taegut	GCF_003957565.1_bTaeGut1_v1.p
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/121530/100	Tauery	GCF_000709365.1_ASM70936v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/94827/100	Tingut	GCF_000705375.1_ASM70537v2
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/56313/100	Tytalb	GCF_000687205.1_ASM68720v1
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/44394/102	Zonalb	GCF_000385455.1_Zonotrichia_albicollis-1.0.1
```

Here is a summary of the taxa that I used for the Willisornis analyses:

| Species                     | Common Name                    | Clade                                | Annotation source | Assembly Name                | Assembly Accession      |
|-----------------------------|--------------------------------|--------------------------------------|-------------------|------------------------------|-------------------------|
| Willisornis poecilinotus    | Common Scale-backed Antbird    | Suboscine passerine (Thamnophilidae) | This study        | NA                           | NA                      |
| Hypocnemis ochrogyna        | Rondonia warbling antbird      | Suboscine passerine (Thamnophilidae) | This study        | NA                           | NA                      |
| Rhegmatorhina melanosticta  | Hairy-crested Antbird          | Suboscine passerine (Thamnophilidae) | This study        | NA (Coelho et al. 2019)      | NA (Coelho et al. 2019) |
| Acanthisitta chloris        | Rifleman                       | Acanthisitta                         | RefSeq            | ASM69581v1                   | GCF_000695815.1         |
| Parus major                 | Great Tit                      | Oscine passerine                     | Ensembl           | Parus_major1.1               | GCA_001522545.3         |
| Junco hyemalis              | Dark-eyed Junco                | Oscine passerine                     | Ensembl           | ASM382977v1                  | GCA_003829775.1         |
| Taeniopygia guttata         | Zebra Finch                    | Oscine passerine                     | Ensembl           | taeGut3.2.4                  | GCA_000151805.2         |
| Serinus canaria             | Common Canary                  | Oscine passerine                     | Ensembl           | SCA1                         | GCA_000534875.1         |
| Erythrura gouldiae          | Gouldian Finch                 | Oscine passerine                     | Ensembl           | GouldianFinch                | GCA_003676055.1         |
| Cyanistes caeruleus         | Blue Tit                       | Oscine passerine                     | Ensembl           | cyaCae2                      | GCA_002901205.1         |
| Ficedula albicollis         | Collared Flycatcher            | Oscine passerine                     | Ensembl           | FicAlb_1.4                   | GCA_000247815.1         |
| Zonotrichia albicollis      | White-throated Sparrow         | Oscine passerine                     | Ensembl           | Zonotrichia_albicollis-1.0.1 | GCA_000385455.1         |
| Lonchura striata domestica  | Bengalese Finch                | Oscine passerine                     | Ensembl           | LonStrDom1                   | GCA_002197715.1         |
| Camarhynchus parvulus       | Small tree finch               | Oscine passerine                     | RefSeq            | STF_HiC                      | GCF_901933205.1         |
| Corvus brachyrhynchos       | American Crow                  | Oscine passerine                     | RefSeq            | ASM69197v1                   | GCF_000691975.1         |
| Corvus cornix               | Hooded Crow                    | Oscine passerine                     | RefSeq            | ASM73873v2                   | GCF_000738735.2         |
| Geospiza fortis             | Medium ground finch            | Oscine passerine                     | RefSeq            | GeoFor_1                     | GCF_000277835.1         |
| Pseudopodoces humilus       | Ground Tit                     | Oscine passerine                     | RefSeq            | PseHum1.0                    | GCF_000331425.1         |
| Sturnus vulgaris            | European Starling              | Oscine passerine                     | RefSeq            | Sturnus_vulgaris-1.0         | GCF_001447265.1         |
| Amazona collaria            | Yellow-billed Parrot           | Psittaciformes (parrot)              | Ensembl           | ASM394721v1                  | GCA_003947215.1         |
| Melopsittacus undulatus     | Budgerigar                     | Psittaciformes (parrot)              | Ensembl           | Melopsittacus_undulatus_6.3  | GCA_000238935.1         |
| Nestor notabilis            | Kea                            | Psittaciformes (parrot)              | RefSeq            | ASM69687v1                   | GCF_000696875.1         |
| Manacus vitellinus          | Golden-collared Manakin        | Suboscine passerine (Tyranni)        | Ensembl           | ASM171598v2                  | GCA_001715985.2         |
| Lepidothrix coronata        | Blue-crowned Manakin           | Suboscine passerine (Tyranni)        | Ensembl           | Lepidothrix_coronata-1.0     | GCA_001604755.1         |
| Corapipo altera             | White-ruffed manakin           | Suboscine passerine (Tyranni)        | RefSeq            | ASM394572v1                  | GCF_003945725.1         |
| Empidonax trailli           | Willow Flycatcher              | Suboscine passerine (Tyranni)        | RefSeq            | ASM303162v1                  | GCF_003031625.1         |
| Neopelma chrysocephalum     | Saffron-crested tyrant-manakin | Suboscine passerine (Tyranni)        | RefSeq            | ASM398488v2                  | GCF_003984885.1         |
| Pipra filicauda             | Wire-tailed manakin            | Suboscine passerine (Tyranni)        | RefSeq            | ASM394559v1                  | GCF_003945595.1         |
