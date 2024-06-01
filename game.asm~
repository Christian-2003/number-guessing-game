; ===========================================================================
;             N U M B E R     G U E S S I N G     G A M E
;
; The game generates a pseudorandom number. Afterwards, the user can enter a
; number (with multiple digits) through the matrix keypad. The program shows
; whether the entered number is greater or less than the randomly generated
; number. This is continued until the generated number is correctly guessed.
;
; The following memory addresses are used:
;	30H	Stores the pseudorandom number
;	31H	Stores the number entered by the user
; ===========================================================================
ORG 0
AJMP INIT

; ---------------------------------------------------------------------------
; The following section contains subprograms used for setup and the main
; game loop.
; ---------------------------------------------------------------------------
INIT:
	MOV 30H, #0x69		; Set seed for pseudorandom numbers to 105.
	ACALL RAND		; Generate random number.
	; Init game here...
LOOP:
	ACALL READ_KEYPAD
	; TODO: Compare entered number (in 31H) and generated number (in 30H)
	SJMP LOOP





; ---------------------------------------------------------------------------
; The following section contains subprograms used to read numbers (with
; multiple digits) from the matrix keypad. See README.md for further info on
; how to configure the keypad.
; Call READ_KEYPAD to read a number from the keypad.
; ---------------------------------------------------------------------------
READ_KEYPAD:
	MOV P0, #0FFH		; Set P0 as input for the matrix keypad
	MOV DPTR, #KEYS		; POINTER TO KEY VALUES
	MOV R0, #0		; Init pointer for rows
	MOV R1, #0		; Init pointer for coumns
	MOV 31H, #0		; Init read number in memory
	MOV B, #10		; Init multiplication factor for decimal places



CHECK_ROW:
	MOV P0, #0F0H
	JNB P0.4, ROW0
	JNB P0.5, ROW1
	JNB P0.6, ROW2
	JNB P0.7, ROW3
	SJMP CHECK_ROW		; No row pressed. Loop.
ROW0:
	MOV R0, #0
	SJMP CHECK_COL
ROW1:
	MOV R0, #1
	SJMP CHECK_COL
ROW2:
	MOV R0, #2
	SJMP CHECK_COL
ROW3:
	MOV R0, #3
	SJMP CHECK_COL



CHECK_COL:
	MOV P0, #0F0H
	CLR P0.0
	JNB P0.0, COL0		; Test whether key in column 1 is clicked.
	SETB P0.0
	CLR P0.1
	JNB P0.1, COL1		; Test whether key in column 2 is clicked.
	SETB P0.1
	CLR P0.2
	JNB P0.2, COL2		; Test whether key in column 3 is clicked.
	SETB P0.2
	CLR P0.3
	JNB P0.3, COL3		; Test whether key in column 4 is clicked.
	SETB P0.3
	SJMP CHECK_ROW		; No key clicked.
COL0:
	MOV R1, #0
	SJMP GET_KEY
COL1:
	MOV R1, #1
	SJMP GET_KEY
COL2:
	MOV R1, #2
	SJMP GET_KEY
COL3:
	MOV R1, #3
	SJMP GET_KEY



GET_KEY:
	MOV A, R0
	ADD A, A		; A = R0 * 4
	ADD A, A		; A = R0 * 4 * 4
	ADD A, R1		; A = R0 * 4 + R1
	MOVC A, @A+DPTR		; Get key value from #KEYS
	MOV R2, A		; Save key value to R2
	CJNE A, #'#', STORE_OR_CONVERT_NUM ; If pressed key is not '#'
	RET			; '#' pressed - finish reading keys
STORE_OR_CONVERT_NUM:
	CJNE A, #'0', CONVERT_TO_NUM ; If key not '0', convert digit
	SJMP STORE_NUM		; Number is '0', skip conversion
CONVERT_TO_NUM:
	SUBB A, #'0'		; Convert ASCII char to number
	MOV R3, A		; Save converted number to R3
STORE_NUM:
	MOV A, 31H
	MOV B, #10		; Get multiplication factor
	MUL AB			; A * 10 (B is 10)
	ADD A, R3		; Add new digit
	MOV 31H, A
WAIT_KEY_RELEASE:
	MOV P0, #0F0H
WAIT_RELEASE_LOOP:
	JNB P0.4, WAIT_RELEASE_LOOP
	JNB P0.5, WAIT_RELEASE_LOOP
	JNB P0.6, WAIT_RELEASE_LOOP
	JNB P0.7, WAIT_RELEASE_LOOP
	SJMP CHECK_ROW		; Read next digit





; ---------------------------------------------------------------------------
; The following section contains subprograms used to generate pseudorandom
; numbers using a linear congruential generator (LCG).
; Call RAND to generate a pseudorandom number that is stored in address 30H.
; ---------------------------------------------------------------------------
RAND:
	MOV A, 30H
	; LCG: X = (a * X + c) % 256
	MOV B, #0x3A		; a = 58
	MUL AB
	ADD A, #0x13		; c = 19
	MOV 30H, A
	RET

END
