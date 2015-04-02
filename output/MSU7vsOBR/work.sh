echo "lastz alignment of MSU7 and OBR"
#ln -s /rhome/cjinfeng/HEG4_cjinfeng/GenomeAlign/Lastz/output/MSU7vsHEG4_RAW/MSU7* ./
perl ../../bin/step0_data_preparation.pl -spec MSU7 -i ../../input/mask/MSU_r7.fa.RepeatMasker.masked > log 2> log2 &
perl ../../bin/step0_data_preparation.pl -spec OBR -i ../../input/mask/OBR.fa.RepeatMasker.masked > log 2> log2 &
perl ../../bin/step1_run_lastz.pl -tar_spec MSU7 -qry_spec OBR -K 4500 -L 3000 -Y 15000 -E 150 -H 0 -O 600 -T 2 > log 2> log2 &
perl ../../bin/step2_chainnet.pl -tar_spec MSU7 -qry_spec OBR > log 2> log2 &
perl ../../bin/step3_ortholog_net.pl
python ../../bin/step4_ortholog_clean_maf.py > ortholog_maf_clean.log &
