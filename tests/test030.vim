" Test mutation that copies even lines twice to the top. 

function! CopyEven()
    if line('.') / 2 * 2 == line('.')
	normal! yygg2P
    endif
endfunction

edit la-li-lu.in
delmarks xyz
/^#begin/+1,/^#end/-1 CallWithMutableRange CopyEven()
call vimtest#SaveOut()
call vimtest#Quit()

