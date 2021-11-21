" Test mutation that causes errors on some lines. 

edit la-li-lu.in
delmarks xyz
" The :s command is missing the 'e' flag. 
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange s/l/L/
call vimtest#SaveOut()
call vimtest#Quit()

