#!/usr/bin/gnuplot
set terminal png size 1000,300
set xlabel "time"
set xdata time
set format x "%M:%S"
set timefmt x "%s"

set output "dstat-load.png"
set title "#ID# dstat  (Load Avg) on #HOSTNAME#"
set ylabel "val"
plot "dstat.tsv" u 1:4 w l title "load avg(1m)"

set output "dstat-cpu.png"
set title "#ID# dstat (CPU) on #HOSTNAME#"
set ylabel "% usage"
plot "dstat.tsv" u 1:7 w l title "usr%", \
     "dstat.tsv" u 1:8 w l title "sys%", \
     "dstat.tsv" u 1:10 w l title "wio%"

set output "dstat-net.png"
set title "#ID# dstat (Network) on #HOSTNAME#"
set ylabel "b/s"
plot "dstat.tsv" u 1:21 w l title "recv", \
     "dstat.tsv" u 1:22 w l title "sent"

set output "dstat-disk.png"
set title "#ID# dstat (Disk) on #HOSTNAME#"
set ylabel "b/s"
plot "dstat.tsv" u 1:19 w l title "read", \
     "dstat.tsv" u 1:20 w l title "write"
