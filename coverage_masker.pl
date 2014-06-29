#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use FAlite;
use Cwd;
use Getopt::Std;
use vars qw($opt_a $opt_d $opt_x);
getopts('a:d:x:');

my $DIR = "cmtemp";
my $BOWTIE = "";
my $THRESHOLD;

die "
usage: $0 [options] <contigs> <reads>
options:
  -a <path>   path to bowtie [$BOWTIE]
  -d <string> directory [$DIR]
  -x <int>    coverage threshold [undefined and you must define it!]
" unless @ARGV == 2; # add options later
my ($CONTIGS, $READS) = @ARGV;

$BOWTIE = $opt_a if $opt_a;
$DIR = $opt_d if $opt_d;
$THRESHOLD = $opt_x if $opt_x;

##################
# Part 1: set up #
##################

die "bowtie2 not found" unless -x $BOWTIE;
$CONTIGS = Cwd::abs_path($CONTIGS);
$READS   = Cwd::abs_path($READS);
system("mkdir $DIR") unless -d $DIR;
system("ln -s $CONTIGS $DIR/contigs") unless -s "$DIR/contigs";
system("ln -s $READS $DIR/reads") unless -s "$DIR/reads";
chdir $DIR;
unless (-e "$CONTIGS.1.bt2") {
	system("$BOWTIE-build $CONTIGS $CONTIGS");
	# note that this CREATES indexes in the location of the original file
	# and not the temporary directory. hopefully write access available there
}
unless (-s "alignments") {
	system("$BOWTIE --no-unal -x $CONTIGS -U $READS --very-fast-local -S alignments");
}

#####################################
# Part 2: creating the coveragemaps # reading file multiple times to minimize memory
#####################################

my %length;
open(my $fh, "alignments") or die;
while (<$fh>) {
	last if $_ !~ /^@/;
	my ($name, $length) = $_ =~ /SN:(\S+)\s+LN:(\d+)/;
	next if not defined $name;
	$length{$name} = $length;
}
close $fh;

foreach my $scaffold (keys %length) {
	unless (-s "map.$scaffold") {
		my @map;
		open(my $fh, "alignments") or die;
		while (<$fh>) {
			my @f = split;
			next unless $f[2] eq $scaffold;
			my $beg = $f[3] - 1;
			my $end = $beg + length($f[9]);
			for (my $i = $beg; $i <= $end; $i++) {
				$map[$i]++;
			}
		}
		close $fh;
		open(my $ofh, ">map.$scaffold") or die;
		for (my $i = 0; $i < @map; $i++) {
			if (not defined $map[$i]) {print $ofh "0\n"}
			else                      {print $ofh "$map[$i]\n"}
		}
		close $ofh;
	}
}

##################################
# Part 3: creating the histogram #
##################################
my @hist;
foreach my $scaffold (keys %length) {
	open(my $fh, "map.$scaffold") or die;
	while (<$fh>) {
		chomp;
		$hist[$_]++;
	}
	close $fh;
}
unless (-s "histogram") {
	open(my $hout, ">histogram") or die;
	for (my $i = 0; $i < @hist; $i++) {
		$hist[$i] = 0 if not defined $hist[$i];
		print $hout "$i\t$hist[$i]\n";
	}
	close $hout;
}

##################################
# Part 4: threshold & output #
##################################
if ($opt_x) {
	open(my $ofh, ">masked.fa") or die;
	open(my $fh, $CONTIGS) or die;
	my $fasta = new FAlite($fh);
	while (my $entry = $fasta->nextEntry) {
		my ($id) = $entry->def =~ /^>(\S+)/;
		
		my $seq = $entry->seq;
		open(my $mfh, "map.$id") or die;
		my @map;
		while (<$mfh>) {
			chomp;
			push @map, $_;
		}
		close $mfh;

		print $ofh ">$id";
		#print masked sequence
		for (my $i = 0; $i < $length{$id}; $i++) {
			if ($i % 50 == 0) {print $ofh "\n"}
			if ($map[$i] >= $THRESHOLD) {print $ofh "N"}
			else                        {print $ofh substr($seq, $i, 1)}
			#if ($i % 50 == 0) {print $ofh "\n"}
		}
		print $ofh "\n";
	}
	close $fh;	
} else {
	print "Choose a value for -x to create coverage-masked sequence\n";
}


