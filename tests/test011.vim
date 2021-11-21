" Test mutation that adds a line before the current line. 

edit la-li-lu.in
delmarks def
setlocal autoindent
/^#begin/+1,/^#end/-1 NormalWithMutableRange! Ovv
call vimtest#SaveOut()
call vimtest#Quit()

