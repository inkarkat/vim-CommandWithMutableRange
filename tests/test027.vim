" Test mutation that removes current line and sometimes the end marker, but
" leaves the next line marker. 
" line.  
" Tests the exception "end marker got removed."

edit headings.in
let g:CommandWithMutableRange_marks = 'uvw'
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ 'Heading' | execute 'normal! ddjd/^[^H].*$/e' | endif
call vimtest#SaveOut()
call vimtest#Quit()

