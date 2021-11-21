" Test non-mutable normal mode command ranges. 
" Tests that the default for the range is the current line ('.'). 
" Tests that the entire buffer ('%') can be processed. 

edit la-li-lu.in
delmarks a-z
execute "normal! gg/la/e\<CR>"
NormalWithMutableRange! i>
%NormalWithMutableRange! i>
call vimtest#SaveOut()
call vimtest#Quit()

