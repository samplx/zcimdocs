	org	100h	;transient program area
bdos	equ	0005h	;bdos entry point
wchar	equ	2	;write character function
;	enter with ccp's return address in the stack
;	write a single character (?) and return
	mvi c,wchar	;write character function
	mvi e,'?'	;character to write
	call	bdos	;write the character
	ret		;return to the ccp
	end	100h	;start address is 100h
