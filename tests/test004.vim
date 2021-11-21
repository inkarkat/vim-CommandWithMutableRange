" Test non-mutable normal mode command. 
" Tests that bang uses :normal! and no bang uses :normal. 

nmap g~~ I^<Esc>A^

edit la-li-lu.in
delmarks a-z
/^#begin/+1,/^#begin/+5 NormalWithMutableRange g~~
/^#end/-5,/^#end/-1 NormalWithMutableRange! g~~
call vimtest#SaveOut()
call vimtest#Quit()

