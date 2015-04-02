#!/usr/bin/perl
###clear scaffold in chr axt if it is found to be hitted on anthor chr and hit very little in this chr
### in duplicate file: 
### colume1: Scaffold that have multi hit in chrs
### colume4: 1 mean both colume2 and 3 are positive hit of scaffold,0 mean colume3 is false positive hit by Lastz
### duplicate is produced by manual check file: cat chr.scaffold | cut -f2 | uniq -d | sort > duplicate  

my %hash;
open IN, "duplicate" or die "$!";
while(<IN>){
chomp $_;
my @unit=split("\t",$_);
if ($unit[1]=~/chr*/ and $unit[3] != 1){
     print "$unit[0]\t$unit[3]\n";
     my @chr=split(",",$unit[2]);
     foreach (@chr){
          if (exists $hash{$_}){
             my $temp=$hash{$_};
             push (@$temp,$unit[0]);
             $hash{$_}=$temp;  
          }else{
             my @temp;
             push (@temp,$unit[0]);
             $hash{$_}=\@temp;
          }
     }      
}
}
close IN;

foreach (sort keys %hash ){
    my $file="$_".".axt.chain.prenet.net.filter.net.axt";
    my $out =$file.".check";
    my %dupli;
    foreach (@{$hash{$_}}){
          $dupli{$_}=1;
    }
    open FILE, "$file" or die "$!";
    open OUT, ">$out" or die "$!";
             while (<FILE>){
                my @word;
                if ($_=~/^\d+/){
                  @word=split(" ",$_);     
                   
                  if (exists $dupli{$word[4]}){
                        <FILE>;
                        <FILE>;
                        <FILE>;
                  }else{
                        print OUT "$_";
                        for(my $i=0;$i<=2;$i++){
                           my $line=<FILE>;
                           print OUT "$line";
                        }
                  }
                }
             }
    close OUT;
    close FILE; 

} 

=pod
     foreach(@chr){
         my $file="$_".".axt.chain.prenet.net.filter.net.axt";
         my $out =$file.".check";
         open FILE, "$file" or die "$!";
         open OUT, ">>$out" or die "$!";
                 while (<FILE>){
                      if ($_=~/$unit[0]/){
                           <FILE>;
                           <FILE>;
                           <FILE>;
                      }else{
                           print OUT "$_";
                      }
                 }
         close OUT;
         close FILE;
     }
=cut


