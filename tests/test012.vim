" Test mutation that adds a line before and after the current line via temporary
" deletion of the current line. 

edit la-li-lu.in
delmarks ghi
setlocal autoindent
/^#begin/+1,/^#end/-1 NormalWithMutableRange! Ovv^^jddkP
call vimtest#SaveOut()
call vimtest#Quit()

