                ORG          100H           ;START OF TRANSIENT
                                            ;AREA
                MVI          B, LEN         ;LENGTH OF VECTOR TO SCAN
                MVI          C, 0           ;LARGER_RST VALUE SO FAR
                LXI          H, VECT        ;BASE OF VECTOR
LOOP:           MOV          A, M           ;GET VALUE
                SUB          C              ;LARGER VALUE IN C?
                JNC          NFOUND         ;JUMP IF LARGER VALUE NOT
                                            ;FOUND
;               NEW LARGEST VALUE, STORE IT TO C
                MOV          C, A
NFOUND          INX          H              ;TO NEXT ELEMENT
                DCR          B              ;MORE TO SCAN?
                JNZ          LOOP           ;FOR ANOTHER
;
;               END OF SCAN, STORE C
                MOV          A, C           ;GET LARGEST VALUE
                STA          LARGE
                JMP          0              ;REBOOT
;
;               TEST DATA
VECT:           DB           2,0,4,3,5,6,1,5
LEN             EQU          $-VECT         ;LENGTH
LARGE:          DS           1              ;LARGEST VALUE ON EXIT
                END

