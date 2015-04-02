#!/usr/bin/perl
### cut the fasta into subfiles and run repeatmasker by qsub-sge.pl
### report statistic of result file
use strict;
use warnings;
use File::Basename qw(basename dirname); 
use Getopt::Long;

my %opt;
GetOptions(\%opt,"help:s");

die "Usage: perl runrepeatmasker.pl infile rmlib > log" if (@ARGV < 1 or $opt{help});
my $infile=$ARGV[0];
my $rmlib=$ARGV[1];
my $filename=basename($infile);
print "$infile\t$filename\n";

my $outdir=".";
my $script="/rhome/cjinfeng/software/bin";
my $repeat2gff="$script/repeat_to_gff.pl";
my $fastadeal="$script/fastaDeal.pl";
my $repeatmasker="/usr/local/bin/RepeatMasker";
my $statTE="$script/stat_TE.pl";
my $qsub="$script/qsub-pbs.pl";
## cut file and push file name to array

`perl $fastadeal -cutf 60 $infile -outdir $outdir`;
my @subfiles=glob("./$filename.cut/*.*");

## write shell file 
my $repeatshell="$filename".".sh";
open OUT, ">$repeatshell" or die "can not open my shell out";
foreach (@subfiles){
    print "$_\n";
    #print OUT "$repeatmasker -lib $rmlib -qq -xsmall -nolow -no_is -norna $_ > $_.log 2> $_.log2\n";
    #print OUT "$repeatmasker -species arabidopsis -q -xsmall -nolow -no_is -norna $_ > $_.log 2> $_.log2\n";
    print OUT "$repeatmasker -species rice -q -xsmall -nolow -no_is -norna $_ > $_.log 2> $_.log2\n";
}
close OUT;

## run shell by qsub-sge.pl
`perl $qsub $repeatshell`;
`cat $outdir/$filename.cut/*.out > $outdir/$filename.RepeatMasker.out`;
`cat $outdir/$filename.cut/*.masked > $outdir/$filename.RepeatMasker.masked`;
`cat $outdir/$filename.cut/*.tbl > $outdir/$filename.RepeatMasker.tbl`;
`cat $outdir/$filename.cut/*.cat > $outdir/$filename.RepeatMasker.cat`;
`perl $repeat2gff $outdir/$filename.RepeatMasker.out`;
`perl $statTE --repeat $outdir/$filename.RepeatMasker.out --rank all > $outdir/$filename.RepeatMasker.out.stat.all`;
`perl $statTE --repeat $outdir/$filename.RepeatMasker.out --rank type > $outdir/$filename.RepeatMasker.out.stat.type`;
`perl $statTE --repeat $outdir/$filename.RepeatMasker.out --rank subtype > $outdir/$filename.RepeatMasker.out.stat.subtype`;
`perl $statTE --repeat $outdir/$filename.RepeatMasker.out --rank family > $outdir/$filename.RepeatMasker.out.stat.family`;
#`rm -R $outdir/$filename.cut`;


