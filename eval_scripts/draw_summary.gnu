set terminal fig color 
set xlabel 'Time [days]' offset 0.0,0.2
set ylabel 'Error rate [%]' offset 1.2,0.0
set size 0.6,0.75
set title 'Classification error rate over time'
diag='confmat'
plot \
'../results/aruba/fremen_0_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Static',\
'../results/aruba/location_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Location-based',\
'../results/aruba/interval_288_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Interval-based',\
'../results/aruba/adaptive_1000_'.diag.'.txt' using (100-$5*100) lw 2 with lines  title 'Adaptive intervals',\
'../results/aruba/gmm_3_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'Gaussian Mixtures',\
'../results/aruba/fremen_2_'.diag.'.txt' using (100-$5*100) lw 2 with lines title 'FreMEn',\
