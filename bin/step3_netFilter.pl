#!/usr/bin/perl

use strict;
use Getopt::Long;
use FindBin qw ($Bin);
use lib "$Bin/ChainNet_Package";
my $chainnet_pathway="$Bin/ChainNet_Package";
my %opt;
GetOptions(\%opt,"help:s");
### the script should be run in the prenet_net dir and do the same job with step3_ortholog_net.pl
### Usage: perl step3_netFilter.pl > log
die "Usage: perl step3_netFilter.pl > log" if ($opt{help});

while (glob("*\.axt\.chain\.prenet\.net")){
     my $file=$_;
     my $chr;
     if ($file =~/(\w+)\.axt\.chain\.prenet\.net/){
        $chr=$1;
     }
     `$chainnet_pathway/netFilter -syn $chr.axt.chain.prenet.net > $chr.axt.chain.prenet.net.filter.net`;
     #`perl $Bin/parseNonsyn.pl $chr.axt.chain.prenet.net.filter.net > $chr.axt.chain.prenet.net.filter.net.parseNonSyn.net`; 
     #`$chainnet_pathway/netToAxt $chr.axt.chain.prenet.net.filter.net.parseNonSyn.net ../axt_chain/$chr.axt.chain ../rice_nib ../bra_nib $chr.axt.chain.prenet.net.filter.net.axt`;
     `$chainnet_pathway/netToAxt $chr.axt.chain.prenet.net.filter.net ../axt_chain/$chr.axt.chain ../rice_nib ../bra_nib $chr.axt.chain.prenet.net.filter.net.axt`;
     #`perl $Bin/chain2r.pl -i $chr.axt.chain.prenet.net.filter.net.axt -f axt`;
     #`mv 4r.pdf $chr.pdf`;     
     #`mv 4r.png $chr.png`;
     #`rm 4r`;
}
