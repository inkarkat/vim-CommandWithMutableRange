function! InitMarks( marks, unsetMarks )
    " Preset all marks to subsequent lines, wrapping around at EOF. 
    1
    for l:mark in a:marks
	if index(a:unsetMarks, l:mark) == -1
	    execute 'normal! ^m' . l:mark
	    execute 'normal! ' .  (line('.') < line('$') ? 'j' : 'gg')
	else
	    execute 'delmarks ' . l:mark
	endif
    endfor
endfunction
function! RecordMarks( marks )
    let l:marksRecord = {}
    for l:mark in a:marks
	let l:marksRecord[l:mark] = getpos("'" . l:mark)
    endfor
    return l:marksRecord
endfunction
function! CompareMarks( marksExpected, marksActual )
    return filter(a:marksActual, 'v:val != a:marksExpected[v:key]')
endfunction

finish

" Usage: 
source helpers/marks.vim
let s:marks = split('abcdefghijklmnopqrstuvwxyz', '\zs')
call InitMarks(s:marks, split('dfghjk', '\zs'))
let s:marksBefore = RecordMarks(s:marks)
MyCommand
call vimtap#Is(CompareMarks(s:marksBefore, RecordMarks(s:marks)), {}, 'Marks kept with enough unset marks')

