set terminal fig color size 5.0,5.0 
set multiplot layout 4,2

set lmargin 10 
set rmargin 1
set tmargin 2
set bmargin 0

set format x ""
set ylabel "Weak classifier \n \n Error rate [%]" offset 1.2,0.0
numdays = 13.9
max = 79.5 
min = 30 
set title 'Aruba dataset' 
plot [0:numdays] [min:max] \
'../results/aruba/fremen_0_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_1_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_2_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_3_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_4_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_5_20.txt' using (100-$5*100) lw 2 with lines notitle,\

set origin 0.38,0.75
unset ylabel
set format y ""
set title 'Witham dataset' 
plot [0:numdays] [min:max] \
'../results/witham/fremen_0_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_1_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_2_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_3_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_4_20.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_5_20.txt' using (100-$5*100) lw 2 with lines notitle,\

set origin 0.0,0.52
unset title
set format y 
max = 29.5
min = 00 
set ylabel "Good classifier \n \n Error rate [%]" offset 1.2,0.0
plot [0:numdays] [min:max] \
'../results/aruba/fremen_0_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_1_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_2_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_3_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_4_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_5_80.txt' using (100-$5*100) lw 2 with lines notitle,\

set origin 0.38,0.52
unset ylabel
set format y ""
#set title 'Witham dataset' 
plot [0:numdays] [min:max] \
'../results/witham/fremen_0_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_1_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_2_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_3_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_4_80.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_5_80.txt' using (100-$5*100) lw 2 with lines notitle,\

set origin 0.00,0.29
set format x 
set xlabel 'Time [days]' offset 0.0,0.2
set format y 
set ylabel "Real classifier \n \n Error rate [%]" offset 1.2,0.0
plot [0:numdays] [min:max] \
'../results/aruba/fremen_0_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_1_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_2_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_3_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_4_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
#'../results/aruba/gmm_5_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\

set origin 0.38,0.29
unset ylabel
set format y ""
#set title 'Witham dataset' 
plot [0:numdays] [min:max] \
'../results/witham/fremen_0_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_1_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_2_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_3_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
#'../results/witham/gmm_4_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\
#'../results/witham/gmm_5_confmat.txt' using (100-$5*100) lw 2 with lines notitle,\

unset title 
unset xlabel
unset ylabel
unset border
unset xtics
unset ytics
set size 1.00,0.1
set origin -0.06,0.15
set key horizontal bottom outside center
plot [0:numdays] [0:0.01] \
'../results/aruba/fremen_0_20.txt' using (100-$5*100) lw 2 with lines title '  Static model',\
'../results/aruba/gmm_1_20.txt' using (100-$5*100) lw 2 with lines title 	'  GMM: 1 gaussian',\
'../results/aruba/gmm_2_20.txt' using (100-$5*100) lw 2 with lines title 	'  GMM: 2 gaussians',\
'../results/aruba/gmm_3_20.txt' using (100-$5*100) lw 2 with lines title 	'  GMM: 3 gaussians',\
'../results/aruba/gmm_4_20.txt' using (100-$5*100) lw 2 with lines title 	'  GMM: 4 gaussians',\
'../results/aruba/gmm_5_20.txt' using (100-$5*100) lw 2 with lines title 	'  GMM: 5 gaussians'
