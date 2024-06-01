; ===========================================================================
; Program reads a number (with multiple digits) from the matrix keypad and
; and stores the result in address 30H.
; ===========================================================================
ORG 0000
AJMP MAIN

; Array stores keys for the matrix keypad
KEYS:	DB '1', '2', '3', 'A'
	DB '4', '5', '6', 'B'
	DB '7', '8', '9', 'C'
	DB '*', '0', '#', 'D'

; Main program
MAIN:
	SJMP READ_KEYPAD





; ---------------------------------------------------------------------------
; The following section begins reading a number from the keypad.
; The read number is stored at address 30H.
; Please make sure that matrix keypad is configured at port 0. Columns need
; to be configured with bits 0 - 3 and rows with bits 4 - 7.
; ---------------------------------------------------------------------------
READ_KEYPAD:
	MOV P0, #0FFH		; Set P0 as input for the matrix keypad
	MOV DPTR, #KEYS		; POINTER TO KEY VALUES
	MOV R0, #0		; Init pointer for rows
	MOV R1, #0		; Init pointer for coumns
	MOV 30H, #0		; Init read number in memory
	MOV B, #10		; Init multiplication factor for decimal places





; ---------------------------------------------------------------------------
; The following section checks in which row the pressed key is located.
; IF a row is identified, the subprogram CHECK_COL is called.
; IF no row is identified, the subprogram loops until one is detected.
; ---------------------------------------------------------------------------
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





; ---------------------------------------------------------------------------
; The following section checks in which column the pressed key is located.
; IF a column is identified, the subprogram GET_KEY is called.
; IF no column is identified, the subprogram CHECK_ROW is called.
; ---------------------------------------------------------------------------
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
	MOV R1, #0		; Remember that column 1 is clicked.
	SJMP GET_KEY

COL1:
	MOV R1, #1		; Remember that column 1 is clicked.
	SJMP GET_KEY

COL2:
	MOV R1, #2		; Remember that column 1 is clicked.
	SJMP GET_KEY

COL3:
	MOV R1, #3		; Remember that column 1 is clicked.
	SJMP GET_KEY





; ---------------------------------------------------------------------------
; The following section reads the digit from the matrix keypad and adds it to
; the total number.
; Afterwards, the program waits until the key is released to continue reading
; the next digit by calling CHECK_ROW.
; ---------------------------------------------------------------------------
GET_KEY:
	MOV A, R0
	ADD A, A		; A = R0 * 4
	ADD A, A		; A = R0 * 4 * 4
	ADD A, R1		; A = R0 * 4 + R1
	MOVC A, @A+DPTR		; Get key value from #KEYS
	MOV R2, A		; Save key value to R2
	CJNE A, #'0', CONVERT_TO_NUM ; If key not '0', convert digit'
	SJMP STORE_NUM		; Number is '0', skip conversion

CONVERT_TO_NUM:
	SUBB A, #'0'		; Convert ASCII char to number
	MOV R3, A		; Save converted number to R3

STORE_NUM:
	MOV A, 30H
	MOV B, #10		; Get multiplication factor
	MUL AB			; A * 10 (B is 10)
	ADD A, R3		; Add new digit
	MOV 30H, A

WAIT_KEY_RELEASE:
	MOV P0, #0F0H

WAIT_RELEASE_LOOP:
	JNB P0.4, WAIT_RELEASE_LOOP
	JNB P0.5, WAIT_RELEASE_LOOP
	JNB P0.6, WAIT_RELEASE_LOOP
	JNB P0.7, WAIT_RELEASE_LOOP
	SJMP CHECK_ROW		; Read next digit

END
