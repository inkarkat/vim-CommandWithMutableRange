" CommandWithMutableRange.vim: Execute commands which may add or remove lines
" for each line in the range. 
"
" DESCRIPTION:
"   The built-in :normal[!] and :call commands can take a [range], and are then
"   executed for each line in the range. If the supplied command / function
"   modifies the number of lines in the buffer, the iteration continues over the
"   initially supplied range of line numbers, totally oblivious to the changes.
"   Thus, if you want to apply modifications that add or delete lines before or
"   inside the [range], this built-in VIM functionality isn't much of a help.
"   (You can work around this by recording a macro and then repeating it over
"   each line.)  
"   This script offers enhanced versions of the :[range]normal[!] and
"   :[range]call commands which allow for additions and deletions of lines
"   during iteration, and adapt the initially supplied [range] accordingly. 
"
" USAGE:
"   :[range]CallWithMutableRange {name}([arguments])
"	Call a function (that does not need to accept a range) once for every
"	line in [range]. 
"
"   :[range]NormalWithMutableRange[!] {commands}
"	Execute Normal mode commands {commands} for each line in the [range]. 
"
"   :[range]ExecuteWithMutableRange {expr1} ...
"	Execute the string that results from the evaluation of {expr1} as an Ex
"	command, once for every line in [range]. Normally, (custom) commands
"	that can operate over multiple lines should take an optional [range],
"	but sometimes this wasn't implemented, and the command only operates on
"	the current position. 
"
"   For each iteration, the cursor is positioned in the first column of that
"   line. Folding is temporarily disabled. The cursor is left at the last line
"   (possibly moved by the last invocation). The arguments are re-evaluated for
"   each line. 
"
" HOW IT WORKS:
"   Before invoking the command, three marks are used to mark the current line,
"   the next line and the last line of the range. As long as all marks are left
"   intact by the command, the second mark still points to the next line for
"   iteration. But even if one or multiple marks have been removed by the
"   command (e.g. by ':delete'ing the current line), the next line can still
"   often be figured out by inspecting how the remaining marks have moved. 
"   The *WithMutableRange commands will abort with an error if they lost track
"   and cannot continue with the iteration; see INTEGRATION below on how you can
"   help avoid this situation. 
"
" INSTALLATION:
"   Put the script into your user or system VIM plugin directory (e.g.
"   ~/.vim/plugin). 
"
" DEPENDENCIES:
" CONFIGURATION:
"   By default, the commands try to find 3 unused marks in the current buffer,
"   and will refuse to work if no unused marks can be found. 
"   Alternatively, you can reserve any number of marks (but a maximum of 3 will
"   be used) for use by the commands by setting a global variable (either
"   temporarily in a user function, or permanently in your vimrc file): 
"	let g:CommandWithMutableRange_marks = 'abc'
"   The existing mark positions will still be saved and restored (but only to
"   their pre-iteration line numbers, not adapted to the modifications!), but
"   you really shouldn't use these marks inside the commands executed by the
"   *WithMutableRange commands. (Except for helping our command to keep track of
"   the next line, see INTEGRATION below.) 
"
" INTEGRATION:
"   This section describes what your commands / functions executed by the
"   *WithMutableRange command should and shouldn't do in order to succeed. 
"
"   - You do not need to restore the cursor position or move back to the current
"     line, this is taken care of automatically. 
"   - Deleting lines removes the line's marks; joining lines together moves
"     marks, etc. Try to keep the marks on the current and next line. 
"     For example, to add these >> markers << vertically around each line, you
"     could either use 
"	:NormalWithMutableRange! Ovv^M^^^[jddkP
"     which temporarily deletes the current line, thereby removing its mark, or 
"	:NormalWithMutableRange! Ovv^[jo^^
"     which keeps all marks intact. (Though in this simple case, our commands
"     can recover from the lost mark because the next line is left untouched.) 
"   - If the commands cannot continue with the iteration, you can help by
"     re-setting any deleted marks yourself. First, you need to avoid that
"     arbitrary marks are used:
"	:let g:CommandWithMutableRange_marks = 'uvw'
"     Then, re-set any deleted mark inside your command / function. (In this
"     example, the "current line" mark (u) is restored:) 
"	:ExecuteWithMutableRange if getline('.') =~ 'Heading' | 
"	\   execute 'normal! 2ddOHHH' | execute 'normal! mu' | endif
"     (Don't forget to reset g:CommandWithMutableRange_marks to its previous
"     contents (default is '', don't :unset the variable!)) 
"
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	10-Jan-2009	file creation

" Avoid installing twice or when in unsupported VIM version. 
if exists('g:loaded_CommandWithMutableRange') || (v:version < 700)
    finish
endif
let g:loaded_CommandWithMutableRange = 1

if ! exists('g:CommandWithMutableRange_marks')
    let g:CommandWithMutableRange_marks = ''
endif

function! s:FindUnusedMark()
    for l:mark in split('abcdefghijklmnopqrstuvwxyz', '\zs')
	if getpos("'" . l:mark) == [0, 0, 0, 0]
	    " Reserve mark so that the next invocation doesn't return it again. 
	    execute 'normal! m' . l:mark
	    return l:mark
	endif
    endfor
    throw 'CommandWithMutableRange: Ran out of unused marks!'
endfunction
function! s:ReserveMarks()
    let l:marksRecord = {}
    for l:cnt in range(0,2)
	let l:mark = strpart(g:CommandWithMutableRange_marks, l:cnt, 1)
	if empty(l:mark)
	    let l:unusedMark = s:FindUnusedMark()
	    let l:marksRecord[l:unusedMark] = [0, 0, 0, 0]
	else
	    let l:marksRecord[l:mark] = getpos("'" . l:mark)
	endif
    endfor
    return l:marksRecord
endfunction
function! s:UnreserveMarks( marksRecord )
    for l:mark in keys(a:marksRecord)
	call setpos("'" . l:mark, a:marksRecord[l:mark])
    endfor
endfunction
function! s:SetMarks( reservedMarks, currentLine, endLine )
    let l:marks = [ [a:currentLine, a:reservedMarks[0]], [a:currentLine + 1, a:reservedMarks[1]], [a:endLine, a:reservedMarks[2]] ]
    for [l:lineNumber, l:mark] in l:marks
	if setpos("'" . l:mark, [0, l:lineNumber, 1, 0]) != 0
	    throw 'CommandWithMutableRange: Panic: Couldn''t set mark!'
	endif
    endfor
    return l:marks
endfunction

function! s:IsValid( markLineNum )
    return (a:markLineNum > 0)
endfunction
function! s:EvaluateMarks( marks )
    call map(a:marks, '[v:val[0], getpos("''". v:val[1])[1]]')
"****D echomsg string(a:marks)
    let [l:currentLineBefore, l:currentLineAfter] = a:marks[0]
    let [l:nextLineBefore, l:nextLineAfter] = a:marks[1]
    let [l:endLineBefore, l:endLineAfter] = a:marks[2]
    if s:IsValid(l:currentLineAfter)
	let l:currentLineDelta = l:currentLineAfter - l:currentLineBefore
    endif
    if s:IsValid(l:nextLineAfter)
	let l:nextLineDelta = l:nextLineAfter - l:nextLineBefore
    endif
    if s:IsValid(l:endLineAfter)
	let l:endLineDelta = l:endLineAfter - l:endLineBefore
    endif

    " We're done when we knew beforehand that this is the last line to process. 
    if l:nextLineBefore > l:endLineBefore
	return [l:nextLineBefore, l:endLineBefore, '0)']
    endif

    if s:IsValid(l:nextLineAfter)
	if (s:IsValid(l:currentLineAfter) && l:nextLineAfter > l:currentLineAfter)
	    " a) Simplest case: The marks on the current and next lines have been
	    " left intact, and the next line is still behind the current line. 
	    if ! s:IsValid(l:endLineAfter) || l:endLineAfter <= l:nextLineAfter
		" Somehow, the end mark got (re-)moved. Reconstruct. 
		let l:endLineAfter = l:endLineBefore + l:nextLineDelta
	    endif
	    return [l:nextLineAfter, l:endLineAfter, 'a)']
	elseif ! s:IsValid(l:currentLineAfter) && s:IsValid(l:endLineAfter)
	    " The mark on the current line has been removed, but the mark on the
	    " next line does still exist. 
	    let l:todoDistanceBefore = l:endLineBefore - l:nextLineBefore + 1
	    let l:todoDistanceAfter = l:endLineAfter - l:nextLineAfter + 1
	    let l:todoDistanceDelta = l:todoDistanceAfter - l:todoDistanceBefore
	    if l:todoDistanceDelta == 0
		" If the distance between next and end line was maintained, we
		" continue with the next line, if there is still something to
		" process. 
		if l:todoDistanceAfter > 0
		    return [l:nextLineAfter, l:endLineAfter, 'b)' ]
		else
		    " We're already on or beyond the end line, signal end of
		    " processing. 
		    return [l:endLineAfter + 1, l:endLineAfter, 'b0)' ]
		endif
	    elseif l:todoDistanceDelta < 0
		" If the distance decreased, the next line has already been
		" consumed and we continue with the following line. 
		return [l:nextLineAfter + 1, l:endLineAfter, 'c)' ]
	    else
		throw 'CommandWithMutableRange: Cannot continue with iteration; deletions and additions occurred around the next line.'
	    endif
	elseif s:IsValid(l:endLineAfter)
	    " d) The mark on the next line moved onto or even before the mark on
	    " the current line. Just continue with the next line. 
	    return [l:currentLineAfter + 1, l:endLineAfter, 'd)']
	else
	    throw 'CommandWithMutableRange: Cannot continue with iteration; end marker got removed.'
	endif
    else
	if s:IsValid(l:currentLineAfter)
	    " e) The mark on the next line has been removed, but we can simply
	    " go to the next line based on the intact current line marker. 
	    if s:IsValid(l:endLineAfter)
		return [ l:currentLineAfter + 1, l:endLineAfter, 'e)' ]
	    else
		" The mark of the end line also got removed. There are no more
		" lines to process; we're done. 
		return [ l:currentLineAfter + 1, l:currentLineAfter, 'e0)' ]
	    endif
	elseif s:IsValid(l:endLineAfter)
	    " f) The marks on the current and next line(s) have been removed. If
	    " the end line moved up at least two lines, continue processing on
	    " the same line as before. 
	    if l:endLineDelta <= -2
		return [ l:currentLineBefore, l:endLineAfter, 'f)' ]
	    else
		throw 'CommandWithMutableRange: Cannot continue with iteration; deletions and additions occurred around the current and next line.'
	    endif
	else
	    " g) All three marks have been removed; we stop processing. 
	    return [ l:currentLineBefore + 1, l:currentLineBefore, 'g)' ]
	endif
    endif

    throw 'CommandWithMutableRange: Unhandled scenario.'
endfunction
function! s:CommandWithMutableRange( commandType, startLine, endLine, commandString )
"****D echomsg '****' a:startLine . ' ' . a:endLine 
    " Disable folding during the iteration over the lines. The '0' normal mode
    " command would open a closed fold, anyway. (Unfortunately, there's no ex
    " command to jump to a first column of a line (that leaves folding intact).)
    let l:save_foldenable = &foldenable
    let l:reservedMarksRecord = {}
    try
	setlocal nofoldenable
	let l:reservedMarksRecord = s:ReserveMarks()

	let l:line = a:startLine
	let l:endLine = a:endLine
	while l:line <= l:endLine
	    let l:marks = s:SetMarks(keys(l:reservedMarksRecord), l:line, l:endLine)

	    execute l:line
	    normal! 0
	    try
"****D echomsg '****' l:line . ' ' . getline(l:line)
		execute a:commandType . ' ' . a:commandString
	    catch /^Vim\%((\a\+)\)\=:E/
		echohl ErrorMsg
		" v:exception contains what is normally in v:errmsg, but with extra
		" exception source info prepended, which we cut away. 
		let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
		echomsg v:errmsg
		echohl None
	    endtry
	    let [l:line, l:endLine, l:debug] = s:EvaluateMarks(l:marks)
"****D echomsg '****' l:debug . ' => ' . l:line . ' ' . l:endLine
	endwhile
    catch /^CommandWithMutableRange:/
	echohl ErrorMsg
	let v:errmsg = substitute(v:exception, '^CommandWithMutableRange:\s*', '', '')
	echomsg v:errmsg
	echohl None
    finally
	call s:UnreserveMarks(l:reservedMarksRecord)
	let &foldenable = l:save_foldenable
    endtry
endfunction

command! -range -nargs=1 ExecuteWithMutableRange	call <SID>CommandWithMutableRange('', <line1>, <line2>, <q-args>)
command! -range -nargs=1 CallWithMutableRange		call <SID>CommandWithMutableRange('call', <line1>, <line2>, <q-args>)
command! -range -nargs=1 -bang NormalWithMutableRange	call <SID>CommandWithMutableRange('normal<bang>', <line1>, <line2>, <q-args>)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
