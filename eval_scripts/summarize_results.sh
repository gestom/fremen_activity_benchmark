d='aruba'

function extend_figure
{
        w=$(identify $1 |cut -f 3 -d ' '|cut -f 1 -d x)
        h=$(identify $1 |cut -f 3 -d ' '|cut -f 2 -d x)
        if [ $w -lt 1000 ]; then        convert $1 -bordercolor white -border $(((1000-$w)/2))x0 $1;fi
        if [ $h -lt 1000 ]; then        convert $1 -bordercolor white -border 0x$(((1000-$h)/2)) $1;fi
        convert $1 -resize 1000x1000 $1
        w=$(identify $1 |cut -f 3 -d ' '|cut -f 1 -d x)
        h=$(identify $1 |cut -f 3 -d ' '|cut -f 2 -d x)
        if [ $w -lt 1000 ]; then        convert $1 -bordercolor white -border $(((1000-$w)/2))x0 $1;fi
        if [ $h -lt 1000 ]; then        convert $1 -bordercolor white -border 0x$(((1000-$h)/2)) $1;fi
        convert $1 -resize 1000x1000 $1
}

function create_graph
{
        echo digraph 
        echo { 
        echo node [penwidth="2" fontname=\"palatino bold\"]; 
        echo edge [penwidth="2"]; 
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
grep -v '#' ../src/models/test_models.txt >models.tmp
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
convert -density 400 $d.pdf -trim -bordercolor white $d.png
extend_figure $d.png
cat best.txt |cut -f 2,4 -d ' '|tr ' ' _|sed s/$/.txt/|sed s/^/..\\/results\\//
cp draw_summary_skelet.gnu draw_summary.gnu
for i in $(cut -f 1 -d ' ' models.tmp);do
        echo \'$(grep $i best.txt |cut -f 2,4 -d ' '|tr ' ' _|sed s/$/.txt/|sed s/^/..\\/results\\/$d\\//)\' 'using (100-$5*100) lw 2 with line title' \'$i\',\\ >>draw_summary.gnu;
done
gnuplot draw_summary.gnu >graphs.fig
fig2dev -Lpdf graphs.fig graphs.pdf
convert -density 400 graphs.pdf graphs.png

extend_figure graphs.png
convert -size 2200x1200 xc:white \
        -draw 'Image src-over 50,200 1000,1000 'graphs.png'' \
        -draw 'Image src-over 1150,200 1000,1000 '$d.png'' \
        -pointsize 64 \
        -draw 'Text 200,80 "Performance of temporal models for activity recognition"' \
        -pointsize 36 \
        -gravity North \
        -draw 'Text 0,120 "Arrow A->B means that A performs statistically significantly better that B"' summary.png;
cp summary.png  ../results/summary.png

