" Test non-mutable user command. 
" Tests that the cursor is positioned in the first column of each line. 

command! -nargs=? MyCommand execute 'normal! i' . line('.') . <q-args>

edit la-li-lu.in
delmarks a-z
execute "normal! gg/la/e\<CR>"
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange MyCommand >
call vimtest#SaveOut()
call vimtest#Quit()

