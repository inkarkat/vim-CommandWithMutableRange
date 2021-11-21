" Test mutation that deletes the current line and joins the next two. 

edit la-li-lu.in
delmarks pqr
/^#begin/+1,/^#end/-1 NormalWithMutableRange! ddJ
call vimtest#SaveOut()
call vimtest#Quit()

