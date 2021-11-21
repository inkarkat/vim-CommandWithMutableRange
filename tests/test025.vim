" Test mutation that replaces current and next lines with a single
" line.  
" Tests that removal of the current and next line marks is not okay if there
" are less than two lines less. 

edit headings.in
let g:CommandWithMutableRange_marks = 'uvw'
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ 'Heading' | execute 'normal! 2ddOHHH' | endif
call vimtest#SaveOut()
call vimtest#Quit()

