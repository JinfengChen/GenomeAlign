#!/usr/bin/perl
use Getopt::Long;

### can convert maf, axt , net to 4r to plot in R
GetOptions(\%opt,"infile:s","format:s","help:s");
die "Usage: perl chain2r.pl --infile chr03.net --format net" if (!-f $opt{infile} or $opt{help});

if ($opt{format} eq "maf"){
    maf($opt{infile});
}elsif($opt{format} eq "net"){
    net($opt{infile});
}elsif($opt{format} eq "axt"){
    axt($opt{infile});
}else{
    print "Format not support!\n";
}
#`convert -antialias -density 150 -scale 600 4r.pdf 4r.png`;


sub axt {
my ($file)=@_;
my ($ref,$com,@start,@end);
open IN, "$file" or die "$!";
while (<IN>){
    next if ($_ eq "");
    next if ($_ =~/#/);
    if ($_ =~/^\d+/){
        my @unit=split(" ",$_);
        $ref=$unit[1];
        $com=$unit[4];
        push (@start,$unit[2]);
        push (@end, $unit[3]);
    }
}
close IN;

open OUT, ">4r";
print OUT "$ref\t$com\n";
for(my $i=0;$i<@start;$i++){
    print OUT "$start[$i]\t$end[$i]\n";
    print OUT "$start[$i]\t$end[$i]\n";
    print OUT "NA\tNA\n";
}
close OUT;
`cat /rhome/cjinfeng/HEG4_cjinfeng/GenomeAlign/Lastz/bin/lastzplot.r | R --vanilla --slave`;

}


sub maf {
my ($file)=@_;
my ($ref,$com,@start,@end);
open IN, "$file" or die "$!";
while (<IN>){
    next if ($_ eq "");
    next if ($_ =~/##/);
    if ($_ =~/score=/){
        my $target=<IN>;
        my @tar=split(" ",$target);
        $ref=$tar[1]; 
        push (@start,$tar[2]);
        push (@end,$tar[2]+$tar[3]);
        my $query =<IN>;
        my @que=split(" ",$query);
        $com=$que[1];
    }
}
close IN;

open OUT, ">4r";
print OUT "$ref\t$com\n";
for(my $i=0;$i<@start;$i++){
    print OUT "$start[$i]\t$end[$i]\n";
    print OUT "$start[$i]\t$end[$i]\n";
    print OUT "NA\tNA\n";
}
close OUT;
`cat /rhome/cjinfeng/HEG4_cjinfeng/GenomeAlign/Lastz/bin/lastzplot.r | R --vanilla --slave`;

}

sub net {
my ($file)=@_;
my ($target,$query,@start,@end);
open IN, "$file" or die "$!";
while (<IN>){
   next if ($_ eq "");
   my @unit=split(" ",$_);
   $target=$unit[0];
   $query =$unit[5];
   push (@start,$unit[3]);
   push (@end,  $unit[3]+$unit[4]);
}
close IN;
open OUT, ">4r";
print OUT "$target\t$query\n";
for (my $i=0;$i<@start;$i++){
   print OUT "$start[$i]\t$end[$i]\n";
   print OUT "$start[$i]\t$end[$i]\n";
   print OUT "NA\tNA\n";
}
close OUT;
`cat /rhome/cjinfeng/HEG4_cjinfeng/GenomeAlign/Lastz/bin/lastzplot.r | R --vanilla --slave`;
}

