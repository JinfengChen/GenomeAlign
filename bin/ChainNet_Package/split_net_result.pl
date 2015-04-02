use FindBin qw($Bin);
use lib "$Bin";
use File::Basename;
$dir=dirname $ARGV[0];
#($species1,$species2)=(split(/\_/,$dir))[0,1];
$file_prefix=basename $ARGV[0];
$prenet_file=substr($file_prefix,0,-4);
#print $prenet_file;
open(IN,"$ARGV[0]");
$net_head=<IN>;

$i=1;
$tmp_file=$file_prefix.".tmp".$i;
push (@tmp_file,$tmp_file);
open(OUT,">$tmp_file");
print OUT $net_head;

while($line=<IN>){
	if($line=~/^\s+fill\s+/){
		$num++;
	}
	if($num >= 1000){
		if($line=~/^ fill\s+/){
			close OUT;
			$i++;
			$tmp_file=$file_prefix.".tmp".$i;
			push (@tmp_file,$tmp_file);
			open(OUT,">$tmp_file");
			print OUT $net_head;
			$num=1;
		}
	}
	print OUT $line;
}

foreach $tmp_file(@tmp_file){
	`$Bin/netToAxt $tmp_file $ARGV[1]/$prenet_file $ARGV[2] $ARGV[3] $tmp_file.axt`;
	`cat $tmp_file.axt >> $ARGV[4]/$file_prefix.axt`;
	`rm $tmp_file.axt`;
}
