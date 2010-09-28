" Test that all marks are restored. 
" Tests with a non-mutable command, because otherwise, the mark positions would
" naturally change. 

let s:marks = split('abcdefghijklmnopqrstuvwxyz', '\zs')

function! s:InitMarks( marks, unsetMarks )
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
function! s:RecordMarks( marks )
    let l:marksRecord = {}
    for l:mark in a:marks
	let l:marksRecord[l:mark] = getpos("'" . l:mark)
    endfor
    return l:marksRecord
endfunction
function! s:CompareMarks( marksExpected, marksActual )
    return filter(a:marksActual, 'v:val != a:marksExpected[v:key]')
endfunction

call vimtest#StartTap() 
call vimtap#Plan(6)
edit la-li-lu.in

" Test with all predefined marks. 
let g:CommandWithMutableRange_marks = 'abc'
call s:InitMarks(s:marks, [])
let s:marksBefore = s:RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(s:CompareMarks(s:marksBefore, s:RecordMarks(s:marks)), {}, 'Marks kept with all predefined marks')

" Test with partially predefined marks. 
let g:CommandWithMutableRange_marks = 'x'
call s:InitMarks(s:marks, split('ghi', '\zs'))
let s:marksBefore = s:RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(s:CompareMarks(s:marksBefore, s:RecordMarks(s:marks)), {}, 'Marks kept with partially predefined marks')

" Test with partially predefined marks, and not enough marks set. 
let g:CommandWithMutableRange_marks = 'x'
call s:InitMarks(s:marks, ['j'])
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error with partially predefined marks and not enough marks set')

" Test auto-placement with enough unset marks. 
let g:CommandWithMutableRange_marks = ''
call s:InitMarks(s:marks, split('dfghjk', '\zs'))
let s:marksBefore = s:RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(s:CompareMarks(s:marksBefore, s:RecordMarks(s:marks)), {}, 'Marks kept with enough unset marks')

" Test auto-placement with not enough unset marks. 
let g:CommandWithMutableRange_marks = ''
call s:InitMarks(s:marks, split('xy', '\zs'))
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error when doing auto-placement with not enough unset marks')

" Test auto-placement with no unset marks. 
let g:CommandWithMutableRange_marks = ''
call s:InitMarks(s:marks, [])
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error when doing auto-placement with no unset marks')

call vimtest#Quit()

