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
;
; The following ports are used:
;	P0	Input from the matrix keypad
;	P1	Output for the LED panel
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
	MOV A, 30H
	MOV B, 31H
	SUBB A, B
	JC NUM_LESS		; A < B: Generated number < Guessed number
	MOV A, 31H
	MOV B, 30H
	SUBB A, B
	JC NUM_GREATER		; A < B: Generated number > Guessed number
	SJMP NUM_EQUAL		; A = B: Generated number = Guessed number
NUM_EQUAL:
	; User 'won':
	ACALL DISPLAY_EQUAL
	ACALL RAND		; Generate new random number.
	SJMP WAIT_RELEASE_KEY	; Continue to let the user guess the new random number.
NUM_LESS:
	ACALL DISPLAY_LESS
	SJMP WAIT_RELEASE_KEY
NUM_GREATER:
	ACALL DISPLAY_GREATER
	SJMP WAIT_RELEASE_KEY
WAIT_RELEASE_KEY:
	MOV P0, #0F0H
LOOP_RELEASE_KEY:
	JNB P0.4, LOOP_RELEASE_KEY
	JNB P0.5, LOOP_RELEASE_KEY
	JNB P0.6, LOOP_RELEASE_KEY
	JNB P0.7, LOOP_RELEASE_KEY
	SJMP LOOP





; ---------------------------------------------------------------------------
; The following section contains subprograms used to read numbers (with
; multiple digits) from the matrix keypad. See README.md for further info on
; how to configure the keypad.
; Call READ_KEYPAD to read a number from the keypad.
; ---------------------------------------------------------------------------

; Array stores keys for the matrix keypad
KEYS:	DB '1', '2', '3', 'A'
	DB '4', '5', '6', 'B'
	DB '7', '8', '9', 'C'
	DB '*', '0', '#', 'D'

READ_KEYPAD:
	MOV P0, #0FFH		; Set P0 as input for the matrix keypad.
	MOV DPTR, #KEYS		; Pointer to key values.
	MOV R0, #0		; Init pointer for rows.
	MOV R1, #5		; Init pointer for coumns.
	MOV 31H, #0		; Init number that was already read in memory.
	MOV B, #10		; Init multiplication factor for decimal places.



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
	MOV P0, #0FFH
	CLR P0.4
	CLR P0.5
	CLR P0.6
	CLR P0.7
	JNB P0.0, COL0
	JNB P0.1, COL1
	JNB P0.2, COL2
	JNB P0.3, COL3
	SJMP CHECK_ROW		; No key pressed.
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
	ADD A, A
	ADD A, A
	ADD A, R1		; A + R1 (Pressed row * 4 + Pressed column)
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
	AJMP CHECK_ROW		; Read next digit





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





; ---------------------------------------------------------------------------
; The following section contains subprograms used to display information to
; the user, after a number was entered.
; Call DISPLAY_GREATER to inform the user that the randomly generated number
;	is greater than the entered number.
; Call DISPLAY_LESS to inform the user that the randomly generated number is
;	less than the entered number.
; Call DISPLAY_EQUAL to inform the user that the randomly generated number is
;	equal to the entered number.
; ---------------------------------------------------------------------------
DISPLAY_GREATER:
	MOV P1, #0FFH
	CLR P1.2
	RET

DISPLAY_LESS:
	MOV P1, #0FFH
	CLR P1.0
	RET

DISPLAY_EQUAL:
	MOV P1, #0FFH
	CLR P1.1
	RET

END
