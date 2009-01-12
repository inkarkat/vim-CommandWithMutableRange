" Test mutation that adds lines after the current line. 

edit la-li-lu.in
/^#begin/+1,/^#end/-1 NormalWithMutableRange! o--
execute 'saveas! ' . expand('<sfile>:p:r') . '.out'
quit

