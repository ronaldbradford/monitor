#!/usr/bin/gnuplot
set terminal png size 1400,400
set xlabel "time"
set ylabel "count/(ms)"
set timefmt x "%s"
set xdata time
set format x "%M:%S"

set yrange [0:150]
set output "reqstat-rps.png"
set title "#ID# reqstat RPS on #HOSTNAME#"
plot "reqstat.tsv" u 1:3 w l title "rps", \
     "reqstat.tsv" u 1:4 w l title "avg_req (ms)"

set yrange [0:250]
set ylabel "ms"
set output "reqstat-per.png"
set title "#ID# reqstat Last Request Times on #HOSTNAME#"
plot "reqstat.tsv" u 1:5 w p title "last (ms)", \
     "reqstat.tsv" u 1:10 w p title "max (ms)" 
