COMMAND WITH MUTABLE RANGE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin offers enhanced versions of the :[range]normal[!] and :[range]call
commands which allow for additions and deletions of lines during iteration,
and adapt the initially supplied [range] accordingly.

The built-in |:normal|[!] and :call commands can take a [range], and are then
executed for each line in the range. If the supplied command / function
modifies the number of lines in the buffer, the iteration continues over the
initially supplied range of line numbers, totally oblivious to the changes.
Thus, if you want to apply modifications that add or delete lines before or
inside the [range], this built-in Vim functionality isn't much of a help. (You
can work around this by recording a macro and then manually repeating it over
each line, until you reach the end of the range, but you need to do the
checking.)

### HOW IT WORKS

Before invoking the command, three marks are used to mark the current line,
the next line and the last line of the range. As long as all marks are left
intact by the command, the second mark still points to the next line for
iteration. But even if one or multiple marks have been removed by the command
(e.g. by |:delete|ing the current line), the next line can still often be
figured out by inspecting how the remaining marks have moved. The
...WithMutableRange commands will abort with an error if they lost track and
cannot continue with the iteration; see CommandWithMutableRange-integration
below on how you can help avoid this situation.

### RELATED WORKS

- RangeMacro.vim ([vimscript #3271](http://www.vim.org/scripts/script.php?script_id=3271)) executes macros repeatedly until the end of
  a range is reached, also taking addition / removal of lines into account.

USAGE
------------------------------------------------------------------------------

    The plugin provides enhanced versions of the :call, :normal and :execute
    Vim commands:

    :[range]CallWithMutableRange {name}([arguments])
                            Call a function (that does not need to accept a range)
                            once for every line in [range].

    :[range]NormalWithMutableRange[!] {commands}
                            Execute Normal mode commands {commands} for each line
                            in the [range].

    :[range]ExecuteWithMutableRange {expr1} ...
                            Execute the string that results from the evaluation of
                            {expr1} as an Ex command, once for every line in
                            [range]. {expr1} is re-evaluated on each line.
                            Normally, (custom) commands that can operate over
                            multiple lines should take an optional [range], but
                            sometimes this wasn't implemented, and the command
                            only operates on the current position. In these cases,
                            (in addition to ad-hoc expressions) this command is
                            useful, and also handles (most) deletions and
                            insertions gracefully.

    For each iteration, the cursor is positioned in the first column of that line.
    Folding is temporarily disabled. The cursor is left at the last line (possibly
    moved by the last invocation). The arguments are re-evaluated for each line.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-CommandWithMutableRange
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim CommandWithMutableRange*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.037 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

By default, the commands try to find 3 unused marks in the current buffer, and
will refuse to work if no unused marks can be found. Alternatively, you can
reserve any number of marks (but a maximum of 3 will be used) for use by the
commands by setting a global variable (either temporarily in a user function,
or permanently in your vimrc file):

    let g:CommandWithMutableRange_marks = 'abc'

The existing mark positions will still be saved and restored (but only to
their pre-iteration line numbers, not adapted to the modifications!), but you
really shouldn't use these marks inside the commands executed by the
...WithMutableRange commands. (Except for helping our command to keep track of
the next line, see CommandWithMutableRange-integration below.)

INTEGRATION
------------------------------------------------------------------------------

This section describes what your commands / functions executed by the
...WithMutableRange command should and shouldn't do in order to succeed.

- You do not need to restore the cursor position or move back to the current
  line, this is taken care of automatically.

- Deleting lines removes the line's marks; joining lines together moves marks,
  etc. Try to keep the marks on the current and next line intact. For example,
  to add "vv" / "^^" markers vertically above / below each line, you could
  either use
 <!-- -->

    :NormalWithMutableRange! Ovv^M^^^[jddkP

  which temporarily deletes the current line, thereby removing its mark, or

    :NormalWithMutableRange! Ovv^[jo^^

  which keeps all marks intact.
  (Though in this simple case, our commands can recover from the lost mark
  because the next line is left untouched.)

- If the commands cannot continue with the iteration, you can help by
  re-setting any deleted marks yourself. First, you need to avoid that
  arbitrary marks are used:
 <!-- -->

    :let g:CommandWithMutableRange_marks = 'uvw'

  Then, re-set any deleted mark inside your command / function. (In this
  example, the "current line" mark (u) is restored:)

    :ExecuteWithMutableRange if getline('.') =~ 'Heading' |
    \   execute 'normal! 2ddOHHH' | execute 'normal! mu' | endif

  (Don't forget to reset g:CommandWithMutableRange\_marks to its previous
  contents (default is '', don't :unset the variable!))

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-CommandWithMutableRange/issues or email
(address below).

HISTORY
------------------------------------------------------------------------------

##### 1.01    RELEASEME
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

##### 1.00    07-Oct-2010
- First published version.

##### 0.01    10-Jan-2009
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2009-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin see copyright.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
