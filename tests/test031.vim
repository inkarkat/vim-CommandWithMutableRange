" Test mutation that moves even lines to the top. 

function! MoveEven()
    if line('.') / 2 * 2 == line('.')
	normal! ddggP
    endif
endfunction

edit la-li-lu.in
delmarks xyz
/^#begin/+1,/^#end/-1 CallWithMutableRange MoveEven()
call vimtest#SaveOut()
call vimtest#Quit()

