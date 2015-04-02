#!/usr/bin/perl

##read filter.net delete lines of scaffold anchored on another chromosome, have nonSyn as key words and following gaps
my %hash;
open IN, "$ARGV[0]" or die "$!";
while(<IN>){
    my @unit=split(" ",$_);
    #print "$unit[1]\t$unit[2]\t$unit[3]\t$unit[4]\n";
    if ($_=~/nonSyn/){
       $counter++;
       $hash{$unit[3]}=$counter;
    }
    if (exists $hash{$unit[3]}){
       next;
    }else{
       print "$_";
    }
}
close IN;
