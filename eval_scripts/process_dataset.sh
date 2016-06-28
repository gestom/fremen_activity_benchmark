dataset=$1
numdays=15
mkdir ../results/$dataset/

for j in confmat #0.2 0.8 

do
echo Diagonal precision $j
perc=$(echo $j*100|bc -l| sed s/\\..*//)
if [ $perc == 0 ];then perc='confmat';fi
cp ../data/$dataset/confmat .

for i in 1 24 96 288 720 1440;
do 
../bin/fremen ../data/$dataset/ HN $i $numdays $j|grep Precision >../results/$dataset/interval_${i}_${perc}.txt
echo Interval Model bin interval: $i
done

for i in 1 10 50 100 500 1000;
do
../bin/fremen ../data/$dataset/ AN $i $numdays $j|grep Precision >../results/$dataset/adaptive_${i}_${perc}.txt
echo Adaptive Interval Model threshold: $i
done

for i in 1 2 3 4 5;
do
../bin/fremen ../data/$dataset/ GN $i $numdays $j|grep Precision >../results/$dataset/gmm_${i}_${perc}.txt
echo GMM order: $i
done

for i in 0 1 2 3 4 5;
do
../bin/fremen ../data/$dataset/ FN $i $numdays $j|grep Precision >../results/$dataset/fremen_${i}_${perc}.txt
echo Fremen order: $i
done

../bin/fremen ../data/$dataset/ NH 0 $numdays $j|grep Precision >../results/$dataset/location_${perc}.txt
../bin/fremen ../data/$dataset/ NN 0 $numdays $j|grep Precision >../results/$dataset/none_${perc}.txt

done


