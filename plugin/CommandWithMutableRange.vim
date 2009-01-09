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

function! s:CommandWithMutableRange( commandType, startLine, endLine, commandString )
echomsg '****' a:startLine . ' ' . a:endLine
    " Disable folding during the iteration over the lines. The '0' normal mode
    " command would open a closed fold, anyway. (Unfortunately, there's no ex
    " command to jump to a first column of a line (that leaves folding intact).)
    let l:save_foldenable = &foldenable
    try
	setlocal nofoldenable
	let l:line = a:startLine
	while l:line <= a:endLine
	    execute l:line
	    normal! 0
	    try
		execute a:commandType . ' ' . a:commandString
		catch /^Vim\%((\a\+)\)\=:E/
		    echohl ErrorMsg
		    " v:exception contains what is normally in v:errmsg, but with extra
		    " exception source info prepended, which we cut away. 
		    echomsg substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
		    echohl NONE
	    endtry
	    let l:line += 1
	endwhile
    finally
	let &foldenable = l:save_foldenable
    endtry
endfunction

command! -range -nargs=1 CommandWithMutableRange	call <SID>CommandWithMutableRange('', <line1>, <line2>, <q-args>)
command! -range -nargs=1 CallWithMutableRange		call <SID>CommandWithMutableRange('call', <line1>, <line2>, <q-args>)
command! -range -nargs=1 -bang NormalWithMutableRange	call <SID>CommandWithMutableRange('normal<bang>', <line1>, <line2>, <q-args>)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
