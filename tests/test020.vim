" Test mutation that joins lines after the current line. 

edit la-li-lu.in
delmarks jkl
/^#begin/+1,/^#end/-1 NormalWithMutableRange! 5J
call vimtest#SaveOut()
call vimtest#Quit()

