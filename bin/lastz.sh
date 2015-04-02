for file in *.fas;
do fastaDeal.pl -cuts 1 $file;
lastz ./$file.cut/$file.1  ./$file.cut/$file.2 --strand=plus --gfextend --gapped  --chain --format=axt --rdotplot=./pdf/4r > ./$file.cut/$file.axt;
cat lastzplot.r | R --vanilla --slave;
mv ./pdf/4r.pdf ./pdf/$file.pdf;
rm ./pdf/4r;
done;
