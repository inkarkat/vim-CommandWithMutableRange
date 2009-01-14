" Test that all marks are restored. 

call vimtap#Output(expand('<sfile>:p:r') . '.tap')
edit la-li-lu.in

" Preset all marks to subsequent lines, wrapping around at EOF. 
1
let s:marks = 'abcdefghijklmnopqrstuvwxyz'
let s:rememberedMarks = {}
for s:mark in split(s:marks, '\zs')
    execute 'normal! m' . s:mark
    let s:rememberedMarks[s:mark] = getpos("'" . s:mark)
    execute 'normal! ' .  (line('.') < line('$') ? 'j' : 'gg')
endfor
call vimtap#Plan(len(s:rememberedMarks))

/^#begin/+1,/^#end/-1 NormalWithMutableRange! i>

for s:mark in keys(s:rememberedMarks)
    call vimtap#Is(getpos("'" . s:mark), s:rememberedMarks[s:mark], 'Position of mark ' . s:mark)
endfor

quit!

