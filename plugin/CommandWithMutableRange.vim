" TODO: summary
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2008 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	00-Jan-2008	file creation

" Avoid installing twice or when in unsupported VIM version. 
if exists('g:loaded_CommandWithMutableRange') || (v:version < 700)
    finish
endif
let g:loaded_CommandWithMutableRange = 1

function! s:GotoFirstColumnInLine( lineNum )
    " The '0' normal mode command would open a closed fold; unfortunately,
    " there's no ex command to jump to a first column of a line (that leaves
    " folding intact). Thus, we issue the fold-altering normal mode command with
    " folding temporarily turned off. 
    let l:save_foldenable = &foldenable
    try
	setlocal nofoldenable
	execute a:lineNum
	normal! 0
    finally
	let &foldenable = l:save_foldenable
    endtry
endfunction
function! s:CommandWithMutableRange( commandType, startLine, endLine, commandString )
echomsg '****' a:startLine . ' ' . a:endLine
    let l:line = a:startLine
    while l:line <= a:endLine
	call s:GotoFirstColumnInLine(l:line)
	execute a:commandType . ' ' . a:commandString
	let l:line += 1
    endwhile
endfunction

command! -range -nargs=1 CommandWithMutableRange	call <SID>CommandWithMutableRange('', <line1>, <line2>, <q-args>)
command! -range -nargs=1 CallWithMutableRange		call <SID>CommandWithMutableRange('call', <line1>, <line2>, <q-args>)
command! -range -nargs=1 -bang NormalWithMutableRange	call <SID>CommandWithMutableRange('normal<bang>', <line1>, <line2>, <q-args>)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
