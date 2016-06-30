d='aruba'

function extend_figure
{
	w=$(identify $1 |cut -f 3 -d ' '|cut -f 1 -d x)
	h=$(identify $1 |cut -f 3 -d ' '|cut -f 2 -d x)
	if [ $w -lt 500 ]; then	convert $1 -bordercolor white -border $(((500-$w)/2))x0 $1;fi
	if [ $h -lt 500 ]; then	convert $1 -bordercolor white -border 0x$(((500-$h)/2)) $1;fi
	convert $1 -resize 500x500 $1
	w=$(identify $1 |cut -f 3 -d ' '|cut -f 1 -d x)
	h=$(identify $1 |cut -f 3 -d ' '|cut -f 2 -d x)
	if [ $w -lt 500 ]; then	convert $1 -bordercolor white -border $(((500-$w)/2))x0 $1;fi
	if [ $h -lt 500 ]; then	convert $1 -bordercolor white -border 0x$(((500-$h)/2)) $1;fi
	convert $1 -resize 500x500 $1
}

function create_graph
{
	echo digraph 
	echo { 
	echo node [penwidth="2" fontname=\"palatino bold\"]; 
	echo edge [penwidth="2"]; 
	#echo node1 [shape="underline",label=\"Comparative performace of temporal methods.\\n\\n Arrow from A to B indicates that method A\\n has a lower classification error than method B \"];
	#echo node2 [shape="underline",label=\"Best performing models that were used in this test:\\n FreMEn order $1\\n  GMM with $2 gaussians \\n Adaptive intervals with $3 samples \\n Interval with $4 minute bin width \\n \"];
	#echo node1 '->' node2 [color=white];
	for m in $(cut -f 1 -d ' ' models.tmp)
	do	
		e=0
		for n in $(cut -f 1 -d ' ' models.tmp)
		do
			#echo -ne Comparing $m and $n' ';
			if [ $(paste $m.txt $n.txt|tr \\t ' '|./t-test|grep -c higher) == 1 ]
			then
				echo $(grep $n best.txt|cut -d ' ' -f 2,4|sed s/' '/_/|sed s/\_0//) '->' $(grep $m best.txt|cut -d ' ' -f 2,4|sed s/' '/_/|sed s/\_0//) ;
				e=1
			fi
		done
		if [ $e == 0 ]; then echo $(grep $m best.txt|cut -d ' ' -f 2,4|sed s/' '/_/|sed s/\_0//);fi
	done
	echo }
}

rm best.txt
grep -v '#' models.mod >models.tmp
for m in $(cut -f 1 -d ' ' models.tmp)
do
	errmin=100
	indmin=0
	for o in $(cat models.tmp |grep $m|sed  -e 's/\s\+/\ /g'|cut -f 2-100 -d ' ');
	do
		err=$(cat ../results/$d/$m\_$o.txt |sed -n 7,1000p|awk '{i=i+1;a=a+1-$5}END{print a/i}')
		#echo $m $o $err $errmin
		sm=$(echo $err $errmin|awk '{a=0}($1 > $2){a=1}{print a}')
		if [ $sm == 0 ];
		then
			errmin=$err
			indmin=$o
		fi
	done
	cat ../results/$d/$m\_$indmin.txt |sed -n 7,1000p|awk '{print 1-$5}' >$m.txt
	echo Model $m param $indmin has $errmin error.  >>best.txt
done

create_graph |dot -Tpdf >$d.pdf
convert -density 200 aruba.pdf -trim -bordercolor white aruba.png 
extend_figure aruba.png
cat best.txt |cut -f 2,4 -d ' '|tr ' ' _|sed s/$/.txt/|sed s/^/..\\/results\\//
cp draw_summary_skelet.gnu draw_summary.gnu
for i in $(cut -f 1 -d ' ' models.tmp);do 
	echo \'$(grep $i best.txt |cut -f 2,4 -d ' '|tr ' ' _|sed s/$/.txt/|sed s/^/..\\/results\\/aruba\\//)\' 'using (100-$5*100) lw 2 with line title' \'$i\',\\ >>draw_summary.gnu;
done
gnuplot draw_summary.gnu >graphs.fig
fig2dev -Lpdf graphs.fig graphs.pdf
convert -density 200 graphs.pdf graphs.png
extend_figure graphs.png 
convert -size 1100x600 xc:white \
	-draw 'Image src-over 25,100 500,500 'graphs.png'' \
	-draw 'Image src-over 575,100 500,500 'aruba.png'' \
	-pointsize 32 \
	-draw 'Text 100,40 "Performance of temporal models for activity recognition"' \
	-pointsize 18 \
	-gravity North \
	-draw 'Text 0,60 "Arrow A->B means that A performs statistically significantly better that B"' aruba.png;
