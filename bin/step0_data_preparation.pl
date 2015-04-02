#!/usr/local/bin/perl -w
# Copyright (c) BGI 2009
# Author:         baiyinqi <baiyq@genomics.org.cn>
# Program Date:2009-05-01
# Modifier:
# Last Modified:2009-10-21
# Description:  A Lastz/ChainNet pipeline for whole genome synteny alignment


my $help=<<USAGE;


Here is a Lastz/ChainNet pipeline for whole genome synteny alignment.
This is the prime step for the whole pipeline , called step0_data_preparation.pl for just an overall data preparation .
It is suggested to creat a new directory to run the pipeline.
Two RepeatMased genome sequence files in fasta format are needed for the comparation . One is confirmed as Reference genome (called Target in Lastz) , and the other is Query genome . 
This script deals with just one genome a time , so use it twice to finish both Target and Query , and give the appropriate name for them .

The output contains ,
1.a directory with splited fasta files                  speciesXX/
2.a directory with splited nib files                    speciesXX_nib/
3.a new fasta of genome sequence			speciesXX.fa
4.a fasta size file					speciesXX.sizes
5.a shell directory(just use to qsub the scrpit)	fatonib_sh/

Here are the parameters
-i <str>     the genome sequence files in fasta format as input
-spec <str>  the name of the genome would to use in whole pipeline 
-cut <i>     the cutoff of the sequence size for each splited fasta file , short sequence usually with none or bad 	       alignment result and wolud not affect much (fault 1000)
-help	     help

Example
perl ../bin/step0_data_preparation.pl  -spec arab -i ../input/arab.fa -cut 0


USAGE


use Getopt::Long;
use Cwd;
$cwd=cwd;
use FindBin qw($Bin);
use lib "$Bin/ChainNet_Package";
$chainnet_pathway="$Bin/ChainNet_Package";

GetOptions(\%opt,"cut:i","i:s","spec:s","help");
if(defined $opt{help}){
	die  $help ; 
}
if (!defined $opt{cut}){
	$opt{cut}=1000;
}

&preparation($opt{i},$opt{spec});


sub preparation{
	$in_file=shift;
	$spec=shift;


####### make a new large fasta file with a cut_off #########
	mkdir "$spec" if(!-d "$spec");

	open(IN,$in_file);
	$/=">";
	<IN>;
	while($line=<IN>){
	        chomp $line;
	        @seg=split(/\n/,$line);
	        $head_line=shift @seg;
	        $scaf=(split(/\s+/,$head_line))[0];
	        $seq=join("",@seg);
	        if((length $seq) >= $opt{cut}){
	                $fa_file="\>$scaf\n$seq\n";
	                push(@all_filter,$fa_file);
	                open(OUT,">$spec/$scaf");
	                print OUT $fa_file;
	                close OUT;
	        }
	}
	close IN;
	$/="\n";
	
	open(OUT,">$spec.fa");
	print OUT @all_filter;
	close OUT;


####### make a size file for the new large fasta file ##########
	`$chainnet_pathway/faSize -detailed $spec.fa > $spec.sizes`;



####### make nib file for each fasta file (just produce shell script)############
	open(IN,"$spec.sizes");
	mkdir "$spec\_nib/" if(!-d "$spec\_nib/");
	open(OUT,">$spec\_fatonib.sh");
	while($line=<IN>){
	        $scaf=(split(/\s+/,$line))[0];
	        print OUT "$chainnet_pathway/faToNib $cwd/$spec/$scaf $cwd/$spec\_nib/$scaf.nib\n";
	}
	close OUT;

	&qsub($spec); #Decide to qsub the shell script by yourself or use my default subprogramme

}


sub qsub{
####### qsub the fatonib.sh file #####################
	$spec=shift;
	$scaf_num=`wc -l $spec.sizes|awk '{print \$1}'`;
	$split_shell_num=(int($scaf_num/50)) + 1; #split no more than 50 shells
	mkdir "fatonib_sh" if(!-d "fatonib_sh");
	chdir "fatonib_sh";
	`split -$split_shell_num $cwd/$spec\_fatonib.sh $spec`;
	@qsub_file=<./$spec??>;	
	foreach $qsub_file(@qsub_file){
		`echo "echo work completed" >> $qsub_file`;
		#`qsub -S /bin/sh -l vf=0.8G -cwd $qsub_file`;
                `qsub $qsub_file`;
	}
	chdir $cwd;

}
