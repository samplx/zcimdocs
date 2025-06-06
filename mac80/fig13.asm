;	construct a data table
;
;	save relevant registers
enter:	irpc	reg,bdh
	push	reg	;;save reg
	endm
;
;	initialize a partial ascii table
	irpc 	c,lAb$?@
data&c:	db	'&C'
	endm
;
;	restore	registers
	irpc	reg,hdb
	pop	reg	;;recall reg
	endm
	ret
	end
