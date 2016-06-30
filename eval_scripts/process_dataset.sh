dataset='aruba'
numdays=15
grep -v '#' models.mod >models.tmp
mkdir ../results/$dataset/
cp ../data/$dataset/confmat .

for m in $(cut -f 1 -d ' ' models.tmp)
do	

for i in $(cat models.tmp |grep $m|sed  -e 's/\s\+/\ /g'|cut -f 2-100 -d ' ');
do 
../bin/fremen ../data/$dataset/ $m $i $numdays confmat |grep Precision >../results/$dataset/$m\_${i}.txt
echo Model $m, parameter $i
done
done

