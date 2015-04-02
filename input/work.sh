perl ../bin/runRepeatMasker.pl OBa.all.fa /share/raid12/chenjinfeng/FFgenome/repeat/library/combined4RM.fa > log &
perl ../bin/runRepeatMasker.pl IRGSP.build5 > log &

echo "mask genomes"
perl ../bin/runRepeatMasker.pl MSU_r7.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl HEG4_RAW.fa > HEG4.log 2> HEG4.log2 &
perl ../bin/runRepeatMasker.pl OGL.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl OPU.fa > OPU.log 2> OPU.log2 &
perl ../bin/runRepeatMasker.pl HEG4_RAW.refassist.fa > HEG4_ref.log 2> HEG4_ref.log2 &
perl ../bin/runRepeatMasker.pl OBA.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl OBR.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl OID.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl ORU.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl ONI.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl OME.fa > log 2> log2 &
perl ../bin/runRepeatMasker.pl OGU.fa > log 2> log2 &

perl ../bin/runRepeatMasker.pl HEG4.allpathlg.v1.noIUPAC.fasta > HEG4.v1.log 2> HEG4.v1.log2 &
perl ../bin/runRepeatMasker.pl HEG4.allpathlg.GC.v1.noIUPAC.fasta > HEG4.GC.v1.log 2> HEG4.GC.v1.log2 &
perl ../bin/runRepeatMasker.pl A123.allpathlg.GC.v1.noIUPAC.fasta > A123.GC.v1.log 2> A123.GC.v1.log2

perl ../bin/runRepeatMasker.pl HEG4_ALLPATHLG_v1.chr.fasta > log 2> log2 &
perl ../bin/runRepeatMasker.pl A123_ALLPATHLG_v1.chr.fasta > log 2> log2 &
