coveragemasker
==============
This repository contains coverage_masker.pl, a Perl script for masking functionally repetetive sequence based on its coverage level. This script requires FAlite.pm, a Perl module that can be found in the Korf Lab Perl_utils repository: https://github.com/KorfLab/Perl_utils/blob/master/FAlite.pm.
Using coverage_masker.pl:
-------------------------
usage: ./coverage_masker.pl \<contigs fasta\> \<reads fastq\> -a \<path to bowtie2\> -d \<output directory\> -x \<coverage threshold\>

The script will generate (1) a sam file, (2) a coverage map for each entry in the contigs fasta file and (3) a coverage-masked output fasta, all contained within the output directory.

Running the script without the -x option will generate (1) a sam file and (2) a coverage map for each entry in the contig fasta.
