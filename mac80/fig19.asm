	IF	NUL
	DB	'true case'
	ELSE
	DB	'false case'
	ENDIF
;
	IF	NUL XXX
	DB	'xxx is nul'
	ELSE
	DB 	'xxx is not nul'
	ENDIF
;
NULMAC 	MACRO 	A,B,C
	IF	NOT NUL A
	DB	'a = &A is not nul'
	ENDIF
	IF	NOT NUL B
	DB	'b = &B is not nul'
	ENDIF
	IF	NOT NUL B&C
	DB	'bc = &B&C is not nul'
	ENDM
;
	NULMAC
	NULMAC	XXX
	NULMAC	,XXX
	NULMAC	XXX,,YYY
	NULMAC	,,YYY
	NULMAC	,,,
	NULMAC	,'',''
	END

