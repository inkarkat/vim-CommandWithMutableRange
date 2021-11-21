" Test mutation that replaces current, next and next next lines with a single
" line.  
" Tests that removal of the current and next line marks is okay as long as there
" are at least two lines less. 

edit headings.in
let g:CommandWithMutableRange_marks = 'uvw'
setlocal formatoptions+=o comments=:#
/^#begin/+1,/^#end/-1 ExecuteWithMutableRange if getline('.') =~ 'Heading' | execute 'normal! 3ddOHHH' | endif
call vimtest#SaveOut()
call vimtest#Quit()

