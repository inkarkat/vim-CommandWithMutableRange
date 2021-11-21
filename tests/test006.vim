" Test that all marks are restored.
" Tests with a non-mutable command, because otherwise, the mark positions would
" naturally change.

source helpers/marks.vim
let s:marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')

call vimtest#StartTap()
call vimtap#Plan(6)
edit la-li-lu.in

" Test with all predefined marks.
let g:CommandWithMutableRange_marks = 'abc'
call InitMarks(s:marks, [])
let s:marksBefore = RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(CompareMarks(s:marksBefore, RecordMarks(s:marks)), {}, 'Marks kept with all predefined marks')

" Test with partially predefined marks.
let g:CommandWithMutableRange_marks = 'x'
call InitMarks(s:marks, split('ghi', '\zs'))
let s:marksBefore = RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(CompareMarks(s:marksBefore, RecordMarks(s:marks)), {}, 'Marks kept with partially predefined marks')

" Test with partially predefined marks, and not enough marks set.
let g:CommandWithMutableRange_marks = 'x'
call InitMarks(s:marks, ['j'])
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error with partially predefined marks and not enough marks set')

" Test auto-placement with enough unset marks.
let g:CommandWithMutableRange_marks = ''
call InitMarks(s:marks, split('dfghjk', '\zs'))
let s:marksBefore = RecordMarks(s:marks)
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(CompareMarks(s:marksBefore, RecordMarks(s:marks)), {}, 'Marks kept with enough unset marks')

" Test auto-placement with not enough unset marks.
let g:CommandWithMutableRange_marks = ''
call InitMarks(s:marks, split('xy', '\zs'))
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error when doing auto-placement with not enough unset marks')

" Test auto-placement with no unset marks.
let g:CommandWithMutableRange_marks = ''
call InitMarks(s:marks, [])
/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>
call vimtap#Is(v:errmsg, 'Ran out of unused marks!', 'Error when doing auto-placement with no unset marks')

call vimtest#Quit()
