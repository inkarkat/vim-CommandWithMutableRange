" Test that all marks are restored. 
" Tests with a non-mutable command, because otherwise, the mark positions would
" naturally change. 

let s:marks = split('abcdefghijklmnopqrstuvwxyz', '\zs')

function! s:SetMarks( marks )
    " Preset all marks to subsequent lines, wrapping around at EOF. 
    1
    for l:mark in a:marks
	execute 'normal! m' . l:mark
	execute 'normal! ' .  (line('.') < line('$') ? 'j' : 'gg')
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

call vimtap#Output(expand('<sfile>:p:r') . '.tap')
edit la-li-lu.in

call vimtap#Plan(1)

" Test non-mutable normal mode command. 
call s:SetMarks(s:marks)
let s:marksBefore = s:RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(s:CompareMarks(s:marksBefore, s:RecordMarks(s:marks)), {}, 'Marks kept during non-mutable command')

quit!

