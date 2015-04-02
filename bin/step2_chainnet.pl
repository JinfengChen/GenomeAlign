#!/usr/local/bin/perl -w
# Copyright (c) BGI 2009
# Author:         baiyinqi <baiyq@genomics.org.cn>
# Program Date:2009-05-01
# Modifier:
# Last Modified:2009-10-21
# Description:  A Lastz/ChainNet pipeline for whole genome synteny alignment


my $help=<<USAGE;


Here is a Lastz/ChainNet pipeline for whole genome synteny alignment.
This is the second step for the whole pipeline , called step2_chainnet.pl , dealing with the raw data of Lastz by ChainNet Package .
Make sure to run the script in the same directory as step0_data_preparation.pl .
ChainNet Package give the best alignment for each Target sequence region .
Its chain result describes all pairwise alignments that allow gaps in both sequences simultaneously.
Its Net result describes the best pairwise alignment for each Target sequence region within long gaps.
Its Axt result describes the best pairwise alignment for each Target sequence region without long gaps.
Its Maf result describes the best pairwise alignment for each Target sequence region without long gaps , and can easily be expanded to multi alignments for several species. 


The output contains ,
1.a directory with chain files				axt_chain/
2.a directory with prenet files				chain_prenet/
3.a directory with net files				prenet_net
4.a directory with axt files				net_axt
5.a directory with maf files				axt_maf
5.a shell directory(just use to qsub the scrpit)        chainnet_sh/

Here are the parameters
-tar_spec <str>		give the Target speciecs name  
-tar_latin <str>  	give the Target speciecs latin name (use in Maf result) 
			default -tar_spec=-tar_latin
-qry_spec <str>     	give the Query speciecs name
qry_latin <str>		give the Query speciecs latin name (use in Maf result)
			default -tar_spec=-tar_latin
-help        help

Example
perl ../bin/step2_chainnet.pl  -tar_spec arab -qry_spec cucumber -tar_latin ARATH -qry_latin CUSCA


USAGE

use File::Basename;
use Cwd;
$cwd=cwd;
use FindBin qw($Bin);
use lib "$Bin/ChainNet_Package";
$chainnet_pathway="$Bin/ChainNet_Package";
use Getopt::Long;
@dir=<lastz_axt/*>;
GetOptions(\%opt,"tar_spec:s","qry_spec:s","tar_latin:s","qry_latin:s","help");

if(defined $opt{help}){
        die  $help ;
}

$opt{tar_latin}||=$opt{tar_spec};
$opt{qry_latin}||=$opt{qry_spec};
mkdir "axt_chain" if(!-d "axt_chain");
mkdir "chain_prenet" if(!-d "chain_prenet");
mkdir "prenet_net" if(!-d "prenet_net");
mkdir "net_axt" if(!-d "net_axt");
mkdir "axt_maf" if(!-d "axt_maf");


open(OUT,">run_chainnet.sh");
foreach $dir(@dir){
        $basename=basename $dir;
       # $shell=(split(/\.axt/,$basename))[0].".sh";
       # open(OUT,">chainnet_sh/$shell");
       print OUT "$chainnet_pathway/axtChain $cwd/lastz_axt/$basename $cwd/$opt{tar_spec}_nib $cwd/$opt{qry_spec}_nib $cwd/axt_chain/$basename.chain\n";
        print OUT "$chainnet_pathway/chainPreNet $cwd/axt_chain/$basename.chain $cwd/$opt{tar_spec}.sizes $cwd/$opt{qry_spec}.sizes $cwd/chain_prenet/$basename.chain.prenet\n";
        print OUT "$chainnet_pathway/chainNet $cwd/chain_prenet/$basename.chain.prenet $cwd/$opt{tar_spec}.sizes $cwd/$opt{qry_spec}.sizes $cwd/$basename.tmp1 $cwd/$basename.tmp2\n";
        print OUT "$chainnet_pathway/netSyntenic $cwd/$basename.tmp1 $cwd/prenet_net/$basename.chain.prenet.net\n";
       print OUT "perl $chainnet_pathway/split_net_result.pl $cwd/prenet_net/$basename.chain.prenet.net $cwd/chain_prenet $cwd/$opt{tar_spec}_nib $cwd/$opt{qry_spec}_nib $cwd\n";
       print OUT "$chainnet_pathway/axtSort $cwd/$basename.chain.prenet.net.axt $cwd/net_axt/$basename.chain.prenet.net.axt\n";
       print OUT "$chainnet_pathway/axtToMaf $cwd/net_axt/$basename.chain.prenet.net.axt $cwd/$opt{tar_spec}.sizes $cwd/$opt{qry_spec}.sizes -tPrefix=$opt{tar_latin}. -qPrefix=$opt{qry_latin}. $cwd/axt_maf/$basename.chain.prenet.net.axt.maf\n";
        print OUT "rm $cwd/$basename\*\n";
}
close OUT;

&qsub($opt{tar_spec});

sub qsub{
####### qsub the fatonib.sh file #####################
        $spec=shift;
        $scaf_num=`wc -l $spec.sizes|awk '{print \$1}'`;
        $split_shell_num=8*(int($scaf_num/50) + 1); #split no more than 50 shells , 8 lines a scaf.sh
        mkdir "chainnet_sh" if(!-d "chainnet_sh");
	chdir "chainnet_sh";
        `split -$split_shell_num $cwd/run_chainnet.sh cn`;
        @qsub_file=<./cn??>;
        foreach $qsub_file(@qsub_file){
                `echo "echo work completed" >> $qsub_file`;
                `cat /rhome/cjinfeng/HEG4_cjinfeng/GenomeAlign/Lastz/bin/lib/head.sh $qsub_file > $qsub_file.sh`;
                #`qsub -S /bin/sh -l vf=0.6G -cwd $qsub_file`;
                `qsub $qsub_file.sh`;
        }
        chdir $cwd;

}

