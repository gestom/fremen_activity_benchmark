d=$1

function create_graph
{
	echo digraph 
	echo { 
	echo node [penwidth="2" fontname=\"palatino bold\"]; 
	echo edge [penwidth="2"]; 
	echo node1 [shape="underline",label=\"Comparative performace of temporal methods.\\n\\n Arrow from A to B indicates that method A\\n has a lower classification error than method B \"];
	echo node2 [shape="underline",label=\"Best performing models that were used in this test:\\n FreMEn order $1\\n  GMM with $2 gaussians \\n Adaptive intervals with $3 samples \\n Interval with $4 minute bin width \\n \"];
	echo node1 '->' node2 [color=white];
	for m in FreMEn GMM Location Static Adaptive Interval None
	do	
		e=0
		for n in FreMEn GMM Location Static Adaptive Interval None
		do
			#echo -ne Comparing $m and $n' ';
			if [ $(paste ${m,,}.txt ${n,,}.txt|tr \\t ' '|./t-test|grep -c higher) == 1 ]
			then
				echo $n '->' $m ;
				e=1
			fi
		done
		if [ $e == 0 ]; then echo $m;fi
	done
	echo }
}

for m in gmm 
do
	errmin=100
	indmin=0
	for o in 1 2 3 4 5
	do
		err=$(cat ../results/$d/$m\_$o\_confmat.txt |sed -n 7,1000p|awk '{i=i+1;a=a+1-$5}END{print a/i}')
		#echo $m $o $err $errmin
		sm=$(echo $err $errmin|awk '{a=0}($1 > $2){a=1}{print a}')
		if [ $sm == 0 ];
		then
			errmin=$err
			indmin=$o
		fi
done
	cat ../results/$d/$m\_$indmin\_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >$m.txt
	gmm_order=$indmin
done

for m in fremen 
do
	errmin=100
	indmin=0
	for o in 1 2 3 4 5
	do
		err=$(cat ../results/$d/$m\_$o\_confmat.txt |sed -n 7,1000p|awk '{i=i+1;a=a+1-$5}END{print a/i}')
		#echo $m $o $err $errmin
		sm=$(echo $err $errmin|awk '{a=0}($1 > $2){a=1}{print a}')
		if [ $sm == 0 ];
		then
			errmin=$err
			indmin=$o
		fi
done
	cat ../results/$d/$m\_$indmin\_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >$m.txt
	fremen_order=$indmin
done


for m in interval 
do
	errmin=100
	indmin=0
	for o in 1 24 96 288 720 1440 
	do
		err=$(cat ../results/$d/$m\_$o\_confmat.txt |sed -n 7,1000p|awk '{i=i+1;a=a+1-$5}END{print a/i}')
		#echo $m $o $err $errmin
		sm=$(echo $err $errmin|awk '{a=0}($1 > $2){a=1}{print a}')
		if [ $sm == 0 ];
		then
			errmin=$err
			indmin=$o
		fi
done
	cat ../results/$d/$m\_$indmin\_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >$m.txt
	interval_order=$indmin
done

for m in adaptive 
do
	errmin=100
	indmin=0
	for o in 1 10 50 100 500 1000 
	do
		err=$(cat ../results/$d/$m\_$o\_confmat.txt |sed -n 7,1000p|awk '{i=i+1;a=a+1-$5}END{print a/i}')
		#echo $m $o $err $errmin
		sm=$(echo $err $errmin|awk '{a=0}($1 > $2){a=1}{print a}')
		if [ $sm == 0 ];
		then
			errmin=$err
			indmin=$o
		fi
done
	cat ../results/$d/$m\_$indmin\_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >$m.txt
	adaptive_order=$indmin
done


cat ../results/$d/location_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >location.txt
cat ../results/$d/fremen_0_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >static.txt
cat ../results/$d/none_confmat.txt |sed -n 7,1000p|awk '{print 1-$5}' >none.txt

#for m in fremen gmm location static
#do	
#for n in fremen gmm location static
#do
	#echo -ne Comparing $m and $n' ';paste $m.txt $n.txt|tr \\t ' '|./t-test
#done
#done


#echo 'digraph { rankdir=LR; A -> B [label="T-test indicates that \n A achieves lower error then B"];'

create_graph $gmm_order $fremen_order $adaptive_order $((1440/$interval_order))|dot -Tpdf >$d.pdf
create_graph $gmm_order $fremen_order $adaptive_order $((1440/$interval_order))|dot -Tpng >$d.png
gnuplot draw_summary.gnu >graphs.fig
fig2dev -Lpng -m5 graphs.fig graphs.png
convert aruba.png -extent 960x571 aruba.png 
convert $d.png -draw 'Image src-over 35,280 385,290 "graphs.png"' $d.png 
