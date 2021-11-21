" Test mutation that deletes current and next line. 
" Tests that removal of the current and next line marks is okay as long as there
" are at least two lines less. 

edit headings.in
let g:CommandWithMutableRange_marks = 'uvw'
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ 'Heading' | execute 'normal! 2dd' | endif
call vimtest#SaveOut()
call vimtest#Quit()

