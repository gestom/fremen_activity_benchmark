#diag='confmat'
#max = 39.9
#min = 0.00 
numdays = 13.9
set terminal fig color size 5.0,3.0 
set multiplot
set xlabel 'Time [days]' offset 0.0,0.2
set ylabel 'Error rate [%]' offset 1.2,0.0
set size 0.515,0.7
set origin 0.0,0.13

set title 'Aruba (apartment) dataset'
plot [0:numdays] [min:max] \
'../results/aruba/fremen_0_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/location_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/interval_288_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/adaptive_1000_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/gmm_3_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/aruba/fremen_2_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\

set size 0.47,0.7
set origin 0.48,0.13
unset ylabel
set format y ""
set title 'Witham (office) dataset'
plot [0:numdays] [min:max] \
'../results/witham/fremen_0_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/location_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/interval_288_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/adaptive_1000_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/gmm_3_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\
'../results/witham/fremen_2_'.diag.'.txt' using (100-$5*100) lw 2 with lines notitle,\

unset title 
unset xlabel
unset ylabel
unset border
unset xtics
unset ytics
set size 1.0,0.1
set origin -0.05,0.0
set key  horizontal bottom outside
plot [0:numdays] [0:0.01] \
'../results/witham/fremen_0_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Static',\
'../results/witham/location_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Location-based',\
'../results/witham/interval_288_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Interval-based',\
'../results/witham/adaptive_1000_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Adaptive intervals',\
'../results/witham/gmm_3_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Gaussian Mixtures',\
'../results/witham/fremen_2_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'FreMEn',\
