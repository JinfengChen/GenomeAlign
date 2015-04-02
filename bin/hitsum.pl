#!/usr/bin/perl
use Getopt::Long;

GetOptions(\%opt,"help");

my $help=<<USAGE;
This scrip is designed to parse Lastz pipeline result, summarize the hit infromation for query sequence into LastzHitInf.txt.
Example LastzHitInf.txt:
Query                           Target  Start   End     Strand    Length  HitLength
OB_Scaffold000110_425519_639420 chr08   4708251 5259086 +         550836  70338

In prenet_net directory
Run: perl hitsum.pl 

USAGE

if ($opt{help}){
    print "$help\n";
    exit();
}

my %hitinf;
my %hitlen;
my %plus;
my @file=glob("*.axt.chain.prenet.net.filter.net.axt");
foreach(@file){
   my $file=$_;
   if ($file=~/(\w+).axt.chain.prenet.net.filter.net.axt/){
      my $chr=$1;
      my %len;
      my %start;
      my %end;
      open IN, "$file" or die "$!";
      while(<IN>){
         if ($_=~/^\d+/){
            my @unit=split(" ",$_);
            $len{$unit[4]}+=$unit[3]-$unit[2]+1;
            if ($unit[7] eq "+"){
                $plus{$unit[4]}++;
            }else{
                $plus{$unit[4]}--;
            }
            my @start;
            my @end;
            if (exists $start{$unit[4]}){
                 my $refstart=$start{$unit[4]};
                 my $refend  =$end{$unit[4]};
                 push (@$refstart,$unit[2]);
                 push (@$refend,  $unit[3]); 
            }else{
                 push (@start,$unit[2]);
                 push (@end,$unit[3]);
                 $start{$unit[4]}=\@start;
                 $end{$unit[4]}=\@end;
            }
         }
      }
      close IN;
      foreach (keys %len){
           my $strand;
           if ($plus{$_} >= 0){
               $strand="+";
           }else{
               $strand="-";
           }
           my @array1=sort {$a <=> $b} @{$start{$_}};
           my $hstart;
           for(my $i=0;$i<@array1-2;$i++){
               my $hstart1=$array1[$i];
               my $hstart2=$array1[$i+1];
               my $hstart3=$array1[$i+2];
               my $inter1=abs ($hstart2-$hstart1);
               my $inter2=abs ($hstart3-$hstart2);
               if ($inter1 < 10000 and $inter2 < 10000){
                   $hstart=$array1[$i];
                   last;
               }
           }
           my @array2=sort {$a <=> $b} @{$end{$_}};
           my $hend;
           for(my $i=@array1-1;$i>=0;$i--){
               my $hend1=$array1[$i];
               my $hend2=$array1[$i-1];
               my $hend3=$array1[$i-2];
               my $inter1=abs ($hend1-$hend2);
               my $inter2=abs ($hend2-$hend3);
               if ($inter1 < 10000 and $inter2 < 10000){
                   $hend=$array1[$i];
                   last;
               }
           }
          #foreach (keys %len){
          #print "$chr\t$_\t$len{$_}\n";
          my $covlen=$hend-$hstart+1;
          if ($covlen < 10000 or $len{$_} < 10000){
             next;
          }
          if (exists $hitlen{$_}){
             if ($len{$_} > $hitlen{$_}){
                 $hitlen{$_}=$len{$_};
                 $hitinf{$_}="$_\t$chr\t$hstart\t$hend\t$strand\t$covlen\t$hitlen{$_}\n";
             } 
          }else{
             $hitlen{$_}=$len{$_};
             $hitinf{$_}="$_\t$chr\t$hstart\t$hend\t$strand\t$covlen\t$hitlen{$_}\n";
          }
      }
   }

}
my $counter;
open OUT, ">LastzHitInf.txt" or die "$!";
foreach (keys %hitinf){
    print OUT "$hitinf{$_}";
    $counter++;
}
close OUT;
print "$counter\n";
