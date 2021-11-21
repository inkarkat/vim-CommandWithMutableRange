" Test mutation that replaces current and next lines with a single
" line.  
" Tests that manually setting the current line mark fixes the limitation that
" removal of the current and next line marks is not okay if there are less than
" two lines less. 

edit headings.in
let g:CommandWithMutableRange_marks = 'uvw' " Note: First mark must match with mark set inside the command over range. 
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ 'Heading' | execute 'normal! 2ddOHHH' | execute 'normal! mu' | endif
call vimtest#SaveOut()
call vimtest#Quit()

