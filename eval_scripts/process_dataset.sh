dataset='aruba'
numdays=15
grep -v '#' ../src/models/test_models.txt >models.tmp
rm -rf ../results/$dataset/
mkdir ../results/$dataset/

for m in $(cut -f 1 -d ' ' models.tmp)
do	

for i in $(cat models.tmp |grep $m|sed  -e 's/\s\+/\ /g'|cut -f 2-100 -d ' ');
do 
../bin/fremen ../data/$dataset/ $m $i $numdays confusion |grep Precision >../results/$dataset/$m\_${i}.txt
echo Model $m, parameter $i
done
done

