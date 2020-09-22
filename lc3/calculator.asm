.orig	x3000

; EXECUTABLE PORTION
;---------------------------------------------------------- 
MAIN	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#4	; R1 = 4 (example data)
	ADD	R2,	R0,	#5	; R2 = 5 (example data)
	JSR	PLUS			; R0 = R1 + R2
	JSR	PRINT			; Should print "9"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#12	; R1 = 12 (example data)
	ADD	R2,	R0,	#4	; R2 = 4 (example data)
	JSR	SUB			; R0 = R1 - R2
	JSR	PRINT			; Should print "8"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#7	; R1 = 7 (example data)
	ADD	R2,	R0,	#3	; R2 = 3 (example data)
	JSR	MULT			; R0 = R1 * R2
	JSR	PRINT			; Should print "21"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#11	; R1 = 11 (example data)
	ADD	R2,	R0,	#4	; R2 = 4 (example data)
	JSR	DIV			; R0 = R1 / R2
	JSR	PRINT			; Should print "2"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#11	; R1 = 11 (example data)
	ADD	R2,	R0,	#4	; R2 = 4 (example data)
	JSR	MOD			; R0 = R1 % R2
	JSR	PRINT			; Should print "3"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#2	; R1 = 3 (example data)
	ADD	R2,	R0,	#3	; R2 = 5 (example data)
	JSR	POW			; R0 = R1 ^ R2
	JSR	PRINT			; Should print "243"

	AND	R0,	R0,	#0	; R0 = 0
	ADD	R1,	R0,	#7	; R1 = 7 (example data)
	JSR	FACT			; R0 = R1!
	JSR	PRINT			; Should print "5040"

	HALT				;


; SUBROUTINES FOR PRINTING INTEGERS
;----------------------------------------------------------
;  Precondition: R0 = a 16-bit integer value 
; Postcondition: R0 is printed to the console in decimal 
PRINT	ST	R7,	PRNT_R7		; R6 = R7 (saves return address)
	ADD	R1,	R0,	#0
	BRZ	PRINT_P
	BRN	PRINT_N

PRINT_N	LD	R1,	ZERO
	ADD	R1,	R1,	xFFFD
	BR	PRINT_M


PRINT_P	BR	PRINT_M

PRINT_M
	
	; ---------------------------- REPLACE THIS SECTION
	JSR	TODIGIT			; !!!only good for printing single digits!!!
	OUT				; print(R0)
	; ---------------------------- REPLACE THIS SECTION


PRINT_V	LEA	R0,	SIGN
	PUTS
	JSR	CLEAR
	
	LD	R0,	NEWLINE	; 
	OUT				; print('\n')

	LD	R7,	PRNT_R7		; R7 = R6 (restores return address)
	RET				;


;  Precondition: R0 = a positive, single-digit integer value
; Postcondition: R0 = the ASCII character for the digit originally in R0
TODIGIT	LD	R1,	ZERO	; R1 = '0'
	ADD	R0,	R0,	R1	; R0 = R0 + '0'
	RET		;


; DATA PORTION
;---------------------------------------------------------- 
ZERO	.fill	x30			; ASCII Digit '0'
NEWLINE	.fill	#10			; ASCII '\n'


; SUBROUTINES FOR MATH OPERATIONS
;----------------------------------------------------------

SWAP	ST	R7,	SWAP_R7
	ST	R0,	SWAP_R0
	ADD	R0,	R1,	x0000
	ADD	R1,	R2,	x0000
	ADD	R2,	R0,	x0000
	LD	R7,	SWAP_R7
	LD	R0,	SWAP_R0
	RET

SWAP0	ST	R7,	SWAP_R7
	ST	R2,	SWAP_R2
	ADD	R2,	R1,	x0000
	ADD	R1,	R0,	x0000
	ADD	R0,	R2,	x0000
	LD	R7,	SWAP_R7
	LD	R2,	SWAP_R2
	RET


; NEGATION...
;  Precondition: R1 = x
; Postcondition: R0 = -x
NEG	NOT	R0,	R1
	ADD	R0,	R0,	#1
	RET


; ADDITION...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = x + y
PLUS	ADD	R0,	R1,	R2
	RET


; SUBTRACTION...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = x - y
SUB	ST	R7,	SUBT_R7
	JSR	SWAP
	JSR	NEG
	JSR	SWAP0
	JSR	PLUS
	LD	R7,	SUBT_R7
	RET


; MULTIPLICATION...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = x * y
MULT	ST	R7,	MULT_R7
	ST	R1,	MULT_R1
	ST	R2,	MULT_R2
	ST	R3,	MULT_R3

	AND	R0,	R0,	x0000

	ADD	R1,	R1,	x0000
	BRZ	MULT_0
	ADD	R2,	R2,	x0000
	BRZ	MULT_0
	BRN	MULT_N

MULT_P	AND	R0,	R0,	x0000
	ADD	R3,	R0,	xFFFF
	BR	MULT_L

MULT_N	JSR	NEG
	JSR	SWAP0
	AND	R0,	R0,	x0000
	ADD	R3,	R0,	x0001

MULT_L	ADD	R0,	R0,	R1
	ADD	R2,	R2,	R3
	BRNP	MULT_L
	BR	MULT_D

MULT_0	AND	R0,	R0,	x0000

MULT_D	LD	R7,	MULT_R7
	LD	R1,	MULT_R1
	LD	R2,	MULT_R2
	LD	R3,	MULT_R3
	RET


; DIVISION...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = x / y
DIV	ST	R7,	DIV_R7
	ST	R1,	DIV_R1
	ST	R2,	DIV_R2
	ST	R3,	DIV_R3
	ST	R4,	DIV_R4

	AND	R0,	R0,	x0000

	ADD	R1,	R1,	x0000
	BRZ	DIV_0
	ADD	R2,	R2,	x0000
	BRZ	DIV_0
	BRN	DIV_N

DIV_P	AND	R0,	R0,	x0000
	ADD	R3,	R0,	xFFFF
	BR	DIV_L

DIV_N	JSR	NEG
	JSR	SWAP0
	AND	R0,	R0,	x0000
	ADD	R3,	R0,	x0001

DIV_L	ADD	R2,	R1,	R1
	ADD	R2,	R2,	R3
	BRNP	DIV_L
	BR	DIV_D

DIV_0	AND	R0,	R0,	x0000

DIV_D	LD	R7,	DIV_R7
	LD	R1,	DIV_R1
	LD	R2,	DIV_R2
	LD	R3,	DIV_R3
	LD	R4,	DIV_R4
	RET


; MODULUS...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = x % y
MOD	ST	R7,	MOD_R7
	ST	R1,	MOD_R1
	ST	R2,	MOD_R2
	ST	R3,	MOD_R3
	

	
MOD_D	LD	R7,	MOD_R7
	LD	R1,	MOD_R1
	LD	R2,	MOD_R2
	LD	R3,	MOD_R3
	RET


; EXPONENTIATION...
;  Precondition: R1 = x
;                R2 = y
; Postcondition: R0 = Math.pow(x,y)
POW	ST	R7,	POW_R7
	ST	R1,	POW_R1
	ST	R2,	POW_R2
	ST	R3,	POW_R3
	
	ADD	R1,	R1,	x0000
	BRZ	POW_0
	ADD	R0,	R2,	xFFFF
	BRZ	POW_1
	ADD	R2,	R2,	x0000
	BRZ	POW_0
	BRN	POW_N

POW_P	AND	R0,	R0,	x0000
	ADD	R3,	R2,	xFFFF
	ADD	R2,	R1,	x0000
	BR	POW_L

POW_N	AND	R0,	R0,	x0000
	BR	POW_D

POW_L	JSR	MULT
	ADD	R1,	R0,	x0000
	ADD	R3,	R3,	xFFFF
	BRP	POW_L
	BR	POW_D

POW_0	AND	R0,	R0,	x0000
	ADD	R0,	R0,	x0001
	BR	POW_D

POW_1	JSR	SWAP0

POW_D	LD	R7,	POW_R7
	LD	R1,	POW_R1
	LD	R2,	POW_R2
	LD	R3,	POW_R3
	RET


; FACTORIAL...
;  Precondition: R1 = x
; Postcondition: R0 = x!
FACT	; todo
	
	RET


CLEAR	LD	R0,	ZERO
	ST	R0,	TTHS
	ST	R0,	THOS
	ST	R0,	HUNS
	ST	R0,	TENS
	ST	R0,	ONES
	ADD	R0,	R0,	xFFFB
	ST	R0,	SIGN
	RET


PRNT_R7	.fill	x0000

SWAP_R7	.fill	x0000
SWAP_R0	.fill	x0000
SWAP_R2	.fill	x0000

SUBT_R7	.fill	x0000

MULT_R7	.fill	x0000
MULT_R1	.fill	x0000
MULT_R2	.fill	x0000
MULT_R3	.fill	x0000

DIV_R7	.fill	x0000
DIV_R1	.fill	x0000
DIV_R2	.fill	x0000
DIV_R3	.fill	x0000
DIV_R4	.fill	x0000

MOD_R7	.fill	x0000
MOD_R1	.fill	x0000
MOD_R2	.fill	x0000
MOD_R3	.fill	x0000

POW_R7	.fill	x0000
POW_R1	.fill	x0000
POW_R2	.fill	x0000
POW_R3	.fill	x0000

FACT_R7	.fill	x0000
FACT_R1	.fill	x0000
FACT_R2	.fill	x0000
FACT_R3	.fill	x0000


SIGN	.fill	x002B
TTHS	.fill	x0030
THOS	.fill	x0030
HUNS	.fill	x0030
TENS	.fill	x0030
ONES	.fill	x0030
NULL	.fill	x0000

.end