" Test non-mutable normal mode command. 
" Tests that the cursor is positioned in the first column of each line. 

edit la-li-lu.in
delmarks a-z
execute "normal! gg/la/e\<CR>"
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtest#SaveOut()
call vimtest#Quit()

