#!/usr/local/bin/perl -w
# Copyright (c) BGI 2009
# Author:         baiyinqi <baiyq@genomics.org.cn>
# Program Date:2009-05-01
# Modifier:
# Last Modified:2009-10-21
# Description:  A Lastz/ChainNet pipeline for whole genome synteny alignment


my $help=<<USAGE;


Here is a Lastz/ChainNet pipeline for whole genome synteny alignment.
This is the first step for the whole pipeline to run lastz , called step1_run_lastz.pl .
Run the script in the same directory as step0_data_preparation.pl .
It runs Lastz for each Target sequence with a series of Latsz parameters .

Here are 3 representative parameter combination for different species division distance for reference only .
(  lower cutoff of parameters leads have longer alignments )
1.Human vs Fish :(default)
	K=2200 L=6000 Y=3400 E=30 H=0 O=400 T=1
2.Human vs Dog :
	K=3000 L=3000 Y=9400 E=150 H=0 O=600 T=1
2.Human vs Monkey :
	K=4500 L=3000 Y=15000 E=150 H=0 O=600 T=2

More information of Lastz and its parameters in 
../documents/*
http://www.bx.psu.edu/miller_lab/dist/README.lastz-1.01.50/README.lastz-1.01.50.html
http://genomewiki.ucsc.edu/index.php/Hg19_conservation_lastz_parameters


The output contains ,
1.a directory with lastz results(axt format)		lastz_axt/
5.a shell directory(just use to qsub the scrpit)        lastz_sh/

Here are the parameters
-tar_spec <str>     give the Target speciecs name
-qry_spec <str>     give the Query speciecs name
-K/L/Y/E/H/Y <i>    Lastz parameters  (fault K=2200 L=6000 Y=3400 E=30 H=0 O=400 T=1)
-help               help

Example
perl ../bin/step1_run_lastz.pl -tar_spec arab -qry_spec cucumber

USAGE

use Cwd;
$cwd=cwd;
use File::Basename;
use Getopt::Long;
GetOptions (\%opt,"tar_spec:s","qry_spec:s","K:i","L:i","Y:i","E:i","H:i","O:i","T:i","help");

if(defined $opt{help}){
        die  $help ;
}

if (!defined $opt{K}){
        $opt{K}=2200;
}
if (!defined $opt{L}){
        $opt{L}=6000;
}
if (!defined $opt{Y}){
        $opt{Y}=3400;
}
if (!defined $opt{E}){
        $opt{E}=30;
}
if (!defined $opt{H}){
        $opt{H}=0;
}
if (!defined $opt{O}){
        $opt{O}=400;
}
if (!defined $opt{T}){
        $opt{T}=1;
}


@dir=<$cwd/$opt{tar_spec}/*>;
#print "CWD $cwd\n";
mkdir "lastz_axt" if(!-d "lastz_axt");
open(OUT,">lastz.sh");
foreach $dir(@dir){
        #print "DIR $dir\n";
        $scaf=basename $dir;
        print OUT "/opt/lastz/1.03.02/lastz $dir $cwd/$opt{qry_spec}.fa K=$opt{K} L=$opt{L} Y=$opt{Y} E=$opt{E} H=$opt{H} O=$opt{O} T=$opt{T} --format=axt --ambiguous=n --ambiguous=iupac > $cwd/lastz_axt/$scaf.axt\n";
}
close OUT;

&qsub($opt{tar_spec},"lastz.sh","lastz_sh","$opt{qry_spec}.fa");

####### qsub the lastz.sh file #####################
sub qsub {
	$spec=shift;
	$shell_file=shift;
	$shell_dir=shift;
	$qry_file=shift;
	$mem=`du -m $qry_file |awk '{print \$1*2}'`;
	chomp $mem;
	$mem.="M";
        $scaf_num=`wc -l $spec.sizes|awk '{print \$1}'`;
	chomp $scaf_num;
        $split_shell_num=(int($scaf_num/50)) + 1; #split no more than 50 shells
        mkdir "$shell_dir" if(!-d "$shell_dir");
        chdir "$shell_dir";
        #print "$scaf_num\n$split_shell_num\n";
        `split -$split_shell_num $cwd/$shell_file lz`;
        @qsub_file=<./lz??>;
        foreach $qsub_file(@qsub_file){
                #print "$qsub_file\n";
                `echo "echo work completed" >> $qsub_file`;
                #`qsub -S /bin/sh -l vf=0.5G -cwd $qsub_file`;
                `qsub $qsub_file`;
        }
        chdir $cwd;

}

