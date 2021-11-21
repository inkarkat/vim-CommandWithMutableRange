" Test mutation that adds lines after the current line. 

edit la-li-lu.in
delmarks abc
setlocal autoindent
/^#begin/+1,/^#end/-1 NormalWithMutableRange! o--
call vimtest#SaveOut()
call vimtest#Quit()

