;	SAMPLE BRACKETED PARAMETERS, WITH ESCAPE CHARACTER
;
MAC1	MACRO	X,Y
	DB	'&X'		;(ONE)
	IF	NUL Y
	EXITM
	ENDIF
	DB	Y		;(TWO)
	ENDM
;
	MAC1	<<LEFT SIDE> MIDDLE <RIGHT SIDE>>
;
	MAC1	<>,<'string of pearls',34H>
;
	MAC1	<A QUOTE IS A '', RIGHT?>
;
	MAC1	<>,<'right, but also '''''>
;
	MAC1	,<'is this ','''''confusing''''', 63>
;
	MAC1	<HERE IS A ^> AND A ^^>
;
MAC2	MACRO	APAR,BPAR
	LOCAL	X
X	EQU	10
	DB	APAR
	MAC1	^APAR,BPAR
	ENDM
;
	MAC2	(X+5)*4,'what''''''''s qoing on?'
	END
