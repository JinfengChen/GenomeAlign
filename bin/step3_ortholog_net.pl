#!/usr/local/bin/perl -w
# Copyright (c) BGI 2009
# Author:         baiyinqi <baiyq@genomics.org.cn>
# Program Date:2009-05-01
# Modifier:
# Last Modified:2009-10-21
# Description:  A Lastz/ChainNet pipeline for whole genome synteny alignment


my $help=<<USAGE;


Here is a Lastz/ChainNet pipeline for whole genome synteny alignment.
This is the third step for the whole pipeline , called step3_ortholog_net.pl , giving the best alignment for both Target and Query sequence region .
Make sure to run the script in the same directory as step0_data_preparation.pl .
Its Ortholog Net result describes the best pairwise alignment for both Target and Query region within long gaps.
Its Ortholog Maf result describes the best pairwise alignment for both Target and Query region without long gaps , and can easily be expanded to multi alignments for several species.


The output contains ,
1.a directory with ortholog net files                         ortholog_net/
2.a directory with ortholog maf files                         ortholog_maf/

Here are the parameters
-help        help

Example
perl ../bin/step3_ortholog_net.pl


USAGE

use Getopt::Long;
GetOptions(\%opt,"help");

if(defined $opt{help}){
        die  $help ;
}



@table=&all_fill;
&find_ortholog(\@table);
&ortholog_net;
&make_ortholog_maf;
sub all_fill{
	chdir "prenet_net";
	@file=<*>;
	chdir "../.";
	mkdir "Find_ortholog_regions" if(!-d "Find_ortholog_regions");
	foreach $file(@file){
		$file1=(split(/\./,$file))[0].".table";
		push (@out_file,$file1);
		open(OUT,">Find_ortholog_regions/$file1");
		open(IN,"prenet_net/$file");
		$line=<IN>;
		($chr,$len)=(split(/\s+/,$line))[1,2];
		while($line=<IN>){
			if($line=~m/^ fill/){
				print OUT "$chr $len$line";
			}
		}
		close IN;
		close OUT;
	}
	return @out_file;
}

sub find_ortholog{
	$table=shift;
	chdir "Find_ortholog_regions";
	@dir=@$table;
	foreach $dir(@dir){
		`cat $dir >> All_fill.table`;
	}
	#`cat @dir > All_fill.table`;
	`sort -k6,6 -k8n,8 All_fill.table > sort_All_fill.table`;
	open(IN,"sort_All_fill.table");
	open(OUT,">confirm_ortholog_region.table");
	$line0=<IN>;
	($scaf0,$begin0,$len0)=(split(/\s+/,$line0))[5,7,8];
	$end0=$begin0+$len0;
	while($line=<IN>){
	        ($scaf,$begin,$len)=(split(/\s+/,$line))[5,7,8];
	        $end=$begin+$len;
	        if($scaf eq $scaf0 && $begin < $end0){
	                if($len0 >= $len){
	                        next;
	                }
	                else{
	                        $begin0=$begin;
	                        $end0=$end;
	                        $len0=$len;
	                        $line0=$line;
	                }
	        }
	        else{
	                print OUT $line0;
	                $scaf0=$scaf;
        	        $begin0=$begin;
	                $end0=$end;
        	        $len0=$len;
	                $line0=$line;
	        }
	}
	print OUT $line0;
	close IN;
	close OUT;
	`sort -k1,1 -k4n,4 confirm_ortholog_region.table > sort_confirm_ortholog_region.table`;
	chdir "../.";
}

sub ortholog_net{
	open(IN,"Find_ortholog_regions/sort_confirm_ortholog_region.table");
	mkdir "ortholog_net" if(!-d "ortholog_net");
	$line=<IN>;
	$line=~m/^(\S+)\s+/;
	$chr0=$1;
	push (@out,$line);
	while($line=<IN>){
	        $line=~m/^(\S+)\s+/;
	        $chr=$1;
	        if($chr ne $chr0){
	                open(OUT,">ortholog_net/$chr0");
	                print OUT @out;
	                close OUT;
	                @out=();
	                $chr0=$chr;
	        }
	        push(@out,$line);
	}
	open(OUT,">ortholog_net/$chr0");
	print OUT @out;
	close OUT;
	@out=();
}

sub make_ortholog_maf{
	chdir "ortholog_net";
	@dir=<*>;
	chdir "../.";
	mkdir "ortholog_maf" if(!-d "ortholog_maf");

	foreach $dir(@dir){
	        &ortholog_maf($dir);
	}
}

sub ortholog_maf{
        @ary=();
        $chr=shift;
#        $old_maf=`ls $ARGV[0]_$ARGV[1]_maf/ |grep $chr`;
#	chomp $old_maf;
	$old_maf="$chr.axt.chain.prenet.net.axt.maf";
        open(IN,"ortholog_net/$chr");
        while($line=<IN>){
                ($begin,$len)=(split(/\s+/,$line))[3,4];
                $end=$begin+$len;
                push(@ary,$begin);
                push(@ary,$end);
        }
        close IN;
        open(IN,"axt_maf/$old_maf");
	$/="\n"; 
	
        @out=();
        $line=<IN>; # annotation information
        push (@out,$line);
        $/="\n\n";
        while($line=<IN>){
                $point=(split(/\s+/,(split(/\n/,$line))[1]))[2];
                $i=0;
                foreach $ary(@ary){
                        $i++;
                        if($ary >= $point){
                                last;
                        }
                }
                if($i%2==0){
                        push(@out,$line);
                }
        }
        open(OUT,">ortholog_maf/$old_maf");
        print OUT @out;
        close OUT;
	@ary=();
	@out=();
}

