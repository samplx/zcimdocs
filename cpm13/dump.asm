;       FILE DUMP PROGRAM, READS AN INPUT FILE AND PRINTS IN HEX
;
;       COPYRIGHT (C), DIGITAL RESEARCH, 1975, 1976
;
        ORG     100H
BDOS    EQU     0005H   ;DOS ENTRY POINT
OPENF   EQU     15      ;FILE OPEN
READF   EQU     20      ;READ FUNCTION
TYPEF   EQU     2       ;TYPE FUNCTION
CONS    EQU     1       ;READ CONSOLE
BRKF    EQU     11      ;BREAK KEY FUNCTION (TRUE IF CHAR READY)
;
FCB     EQU     5CH     ;FILE CONTROL BLOCK ADDRESS
BUFF    EQU     80H     ;INPUT DISK BUFFER ADDRESS
;
;       SET UP STACK
        LXI     H,0
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STKTOP
        JMP     MAIN
;       VARIABLES
IBP:    DS      2       ;INPUT BUFFER POINTER
;
;       STACK AREA
OLDSP:  DS      2
STACK:  DS      64
STKTOP  EQU     $
;
;       SUBROUTINES
;
BREAK:  ;CHECK BREAK KEY (ACTUALLY ANY KEY WILL DO)
        PUSH H! PUSH D! PUSH B; ENVIRONMENT SAVED
        MVI     C,BRKF
        CALL    BDOS
        POP B! POP D! POP H; ENVIRONMENT RESTORED
        RET
;
PCHAR:  ;PRINT A CHARACTER
        PUSH H! PUSH D! PUSH B; SAVED
        MVI     C,TYPEF
        MOV     E,A
        CALL    BDOS
        POP B! POP D! POP H; RESTORED
        RET
;
CRLF:
        MVI     A,0DH
        CALL    PCHAR
        MVI     A,0AH
        CALL    PCHAR
        RET
;
;
PNIB:   ;PRINT NIBBLE IN REG A
        ANI     0FH     ;LOW 4 BITS
        CPI     10
        JNC     P10
;       LESS THAN OR EQUAL TO 9
        ADI     '0'
        JMP     PRN
;
;       GREATER OR EQUAL TO 10
P10:    ADI     'A' - 10
PRN:    CALL    PCHAR
        RET
;
PHEX:   ;PRINT HEX CHAR IN REG A
        PUSH    PSW
        RRC
        RRC
        RRC
        RRC
        CALL    PNIB    ;PRINT NIBBLE
        POP     PSW
        CALL    PNIB
        RET
;
ERR:    ;PRINT ERROR MESSAGE
        CALL    CRLF
        MVI     A, '#'
        CALL    PCHAR
        MOV     A, B
        ADI     '0'
        CALL    PCHAR
        CALL    CRLF
        JMP     FINIS
;
GNB:    ;GET NEXT BYTE
        LDA     IBP
        CPI     80H
        JNZ     G0
;       READ ANOTHER BUFFER
;
;
        CALL    DISKR
        XRA     A
;
G0:     ;READ THE BYTE AT BUFF+REG A
        MOV     E,A
        MVI     D,0
        INR     A
        STA     IBP
;       POINTER IS INCREMENTED
;       SAVE THE CURRENT FILE ADDRESS
        PUSH    H
        LXI     H,BUFF
        DAD     D
        MOV     A,M
;       BYTE IS IN THE ACCUMULATOR
;
;       RESTORE FILE ADDRESS AND INCREMENT
        POP     H
        INX     H
        RET
;
MAIN:   ; READ AND PRINT SUCCESSIVE BUFFERS
        CALL    SETUP   ; SET UP INPUT FILE
        MVI     A,80H
        STA     IBP     ; SET BUFFER POINTER TO 80H
        LXI     H,0FFFFH        ;SET TO -1 TO START
;
GLOOP:
        CALL    GNB
        MOV     B,A
;       PRINT HEX VALUES

;       CHECK FOR LINE FOLD
        MOV     A,L
        ANI     0FH     ;CHECK LOW 4 BITS
        JNZ     NONUM
;       PRINT LINE NUMBER
        CALL    CRLF
;
;       CHECK FOR BREAK KEY
        CALL    BREAK
        RRC
        JC      FINIS   ;DON'T PRINT ANY MORE
;
        MOV     A,H
        CALL    PHEX
        MOV     A,L
        CALL    PHEX
NONUM:
        MVI     A,' '
        CALL    PCHAR
        MOV     A,B
        CALL    PHEX

        JMP     GLOOP
;
EPSA:   ;END PSA
        ;               END OF INPUT
FINIS:
        CALL    CRLF
        LHLD    OLDSP
        SPHL
        RET
;
;
;       FILE CONTROL BLOCK DEFINITIONS
FCBDN   EQU     FCB+0   ;DISK NAME
FCBFN   EQU     FCB+1   ;FILE NAME
FCBFT   EQU     FCB+9   ;DISK FILE TYPE (3 CHARACTERS)
FCBRL   EQU     FCB+12  ;FILE'S CURRENT REEL NUMBER
FCBRC   EQU     FCB+15  ;FILE'S RECORD COUNT (0 TO 128)
FCBCR   EQU     FCB+32  ;CURRENT (NEXT) RECORD NUMBER (0 TO 127)
FCBLN   EQU     FCB+33  ;FCB LENGTH
;
SETUP:  ;SET UP FILE
;       OPEN THE FILE FOR INPUT
        LXI     D,FCB
        MVI     C,OPENF
        CALL    BDOS
;       CHECK FOR ERRORS
        CPI     255
        JNZ     OPNOK
;       BAD OPEN
        MVI     B, 1    ;OPEN ERROR
        CALL    ERR
;
OPNOK:  ;OPEN OPERATION OK, SET BUFFER INDEX TO END
        XRA     A
        STA     FCBCR
        RET
;
DISKR:  ;READ DISK FILE RECORD
        PUSH H! PUSH D! PUSH B
        LXI     D,FCB
        MVI     C,READF
        CALL    BDOS
        POP B! POP D! POP H
        CPI     0       ;CHECK FOR ERRS
        RZ
;       MAY BE EOF
        CPI     1
        JZ      FINIS
;
        MVI     B,2     ;DISK READ ERROR
        CALL    ERR
;
        END







;       SET UP STACK
        LXI     H,0
        DAD     SP
;       ENTRY STACK POINTER IN HL FROM THE CCP
        SHLD    OLDSP
;       SET SP TO LOCAL STACK AREA (RESTORED AT FINIS)
        LXI     SP,STKTOP
;       READ AND PRINT SUCCESSIVE BUFFERS
        CALL    SETUP   ;SET UP INPUT FILE
        CPI     255     ;255 IF FILE NOT PRESENT
        JNZ     OPENOK  ;SKIP IF OPEN IS OK
;
;       FILE NOT THERE, GIVE ERROR MESSAGE AND RETURN
        LXI     D,OPNMSG
        CALL    ERR
        JMP     FINIS   ;TO RETURN
;

;
;       FIXED MESSAGE AREA
SIGNON: DB      'FILE DUMP VERSION 1.4$'
OPNMSG: DB      CR,LF,'NO INPUT FILE PRESENT ON DISK$'

;
        END
