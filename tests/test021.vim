" Test mutation that deletes some current lines. 

edit la-li-lu.in
delmarks mno
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ '^\s\{4,4}\S' | delete | endif
call vimtest#SaveOut()
call vimtest#Quit()

