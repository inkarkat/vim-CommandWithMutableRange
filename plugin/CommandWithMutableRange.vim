" CommandWithMutableRange.vim: Execute commands which may add or remove lines
" for each line in the range. 
"
" DESCRIPTION:
"   The built-in :normal[!] and :call commands can take a [range], and are then
"   executed for each line in the range. If the supplied command / function
"   modifies the number of lines in the buffer, the iteration continues over the
"   initially supplied range of line numbers, totally oblivious to the changes.
"   Thus, if you want to apply modifications that add or delete lines before or
"   inside the [range], this built-in Vim functionality isn't much of a help.
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
"   Put the script into your user or system Vim plugin directory (e.g.
"   ~/.vim/plugin). 
"
" DEPENDENCIES:
"   - ingomarks.vim autoload script. 
"
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
" Copyright: (C) 2009-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	29-Sep-2010	Split off reserving of marks to ingomarks.vim
"				autoload plugin to allow reuse. 
"				Moved functions from plugin to separate autoload
"				script.
"	001	10-Jan-2009	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_CommandWithMutableRange') || (v:version < 700)
    finish
endif
let g:loaded_CommandWithMutableRange = 1

"- configuration --------------------------------------------------------------
if ! exists('g:CommandWithMutableRange_marks')
    let g:CommandWithMutableRange_marks = ''
endif

"- commands -------------------------------------------------------------------
command! -range -nargs=1 ExecuteWithMutableRange	call CommandWithMutableRange#CommandWithMutableRange('', <line1>, <line2>, <q-args>)
command! -range -nargs=1 CallWithMutableRange		call CommandWithMutableRange#CommandWithMutableRange('call', <line1>, <line2>, <q-args>)
command! -range -nargs=1 -bang NormalWithMutableRange	call CommandWithMutableRange#CommandWithMutableRange('normal<bang>', <line1>, <line2>, <q-args>)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
