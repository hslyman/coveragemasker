coveragemasker
==============
This repository contains coverage_masker.pl, a Perl script for masking functionally repetetive sequence based on its coverage level. This script requires <a href="https://github.com/KorfLab/Perl_utils/blob/master/FAlite.pm">FAlite.pm</a> and <a href="https://github.com/BenLangmead/bowtie2">bowtie2</a>.
Using coverage_masker.pl:
-------------------------
```bash
./coverage_masker.pl <contigs FASTA> <reads FASTQ> -a <bowtie2> -d <output directory> -x <coverage threshold>
```
The script will generate (1) a SAM file, (2) a coverage map for each entry in the contigs FASTA file, (3) a histogram of coverage and (4) a coverage-masked output FASTA, all contained within the output directory.

Running the script without the -x option will generate (1) a SAM file, (2) a coverage map for each entry in the contig FASTA and (3) a histogram of coverage. Only the coverage-masked FASTA is omitted.

Subsequent to the initial run, coverage_masker.pl can be rerun to mask at different x-values without rewriting the SAM, coverage maps or histogram. This is intended to allow rapid exploration of masking stringency on large sequence spaces, but <B>will cause errors if the input data is changed without altering the output directory</B>.

<B>Coverage masking will not occur unless -a specifies the location of an executable copy of bowtie2</B>. If, for example, to run bowtie from the command line, you would type:
```bash
/share/apps/bowtie2/bowtie2
```
followed by your arguments, write "-a should be /share/apps/bowtie2/bowtie2". <B>Even if bowtie2 is a part of your path, its location must still be specified</B> (this may be changed in the future).
