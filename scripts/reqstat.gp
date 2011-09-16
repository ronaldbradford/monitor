#!/usr/bin/gnuplot
set terminal png size 1000,400
set output "reqstat.png"
set title "#ID# reqstat on #HOSTNAME#"
set xlabel "time"
set ylabel "count/(ms)"
set timefmt x "%s"
set xdata time
set format x "%M:%S"
plot "reqstat.tsv" u 1:3 w l title "rps", \
     "reqstat.tsv" u 1:4 w l title "avg_req (ms)", \
     "reqstat.tsv" u 1:5 w p title "last (ms)", \
     "reqstat.tsv" u 1:10 w p title "max (ms)" 
