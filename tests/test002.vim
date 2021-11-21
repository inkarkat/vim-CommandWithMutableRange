" Test non-mutable function call. 
" Tests that the cursor is positioned in the first column of each line. 

function! MyFunction(prefix)
    execute 'normal! i' . line('.') . a:prefix
endfunction

edit la-li-lu.in
delmarks a-z
execute "normal! gg/la/e\<CR>"
/^#begin/+1,/^#end/-1 CallWithMutableRange MyFunction('>')
call vimtest#SaveOut()
call vimtest#Quit()

