; Number-Guessing Game for 8051 in Assembly
; Assumes a standard 8051 microcontroller with UART and LCD connected

ORG 0000H
SJMP START

ORG 0030H

; LCD Commands and Functions
LCD_INIT:
    MOV DPTR, #LCD_INIT_CMDS
    MOV R0, #LCD_INIT_CMDS_LEN
LCD_INIT_LOOP:
    MOVX A, @DPTR
    ACALL LCD_CMD
    INC DPTR
    DJNZ R0, LCD_INIT_LOOP
    RET

LCD_CMD:
    MOV P2, A
    CLR P3.0  ; RS = 0
    SETB P3.1 ; EN = 1
    ACALL DELAY
    CLR P3.1  ; EN = 0
    RET

LCD_DATA:
    MOV P2, A
    SETB P3.0 ; RS = 1
    SETB P3.1 ; EN = 1
    ACALL DELAY
    CLR P3.1  ; EN = 0
    RET

LCD_STRING:
    MOV R1, DPL
    MOV R2, DPH
    LCD_STRING_LOOP:
        MOVX A, @DPTR
        JZ LCD_STRING_END
        ACALL LCD_DATA
        INC DPTR
        SJMP LCD_STRING_LOOP
    LCD_STRING_END:
        RET

LCD_CLEAR:
    MOV A, #01H
    ACALL LCD_CMD
    ACALL DELAY
    RET

; UART Initialization and Functions
UART_INIT:
    MOV TMOD, #20H ; Timer1 Mode 2
    MOV TH1, #0FDH ; 9600 baud rate
    MOV SCON, #50H ; 8-bit UART, Mode 1
    SETB TR1       ; Start Timer1
    RET

UART_TX:
    MOV SBUF, A
WAIT_TX:
    JNB TI, WAIT_TX
    CLR TI
    RET

UART_RX:
WAIT_RX:
    JNB RI, WAIT_RX
    MOV A, SBUF
    CLR RI
    RET

UART_STRING:
    MOV R1, DPL
    MOV R2, DPH
    UART_STRING_LOOP:
        MOVX A, @DPTR
        JZ UART_STRING_END
        ACALL UART_TX
        INC DPTR
        SJMP UART_STRING_LOOP
    UART_STRING_END:
        RET

DELAY:
    MOV R3, #250
DELAY_LOOP1:
    MOV R4, #250
DELAY_LOOP2:
    DJNZ R4, DELAY_LOOP2
    DJNZ R3, DELAY_LOOP1
    RET

START:
    MOV SP, #60H  ; Set stack pointer
    ACALL UART_INIT
    ACALL LCD_INIT

    ; Seed random number generator (simplified)
    MOV DPTR, #0FE00H
    MOV A, #55H
    MOVX @DPTR, A

    ; Generate random number between 0 and 99
    ACALL RAND
    MOV R7, A ; Store random number in R7

    ; Send initial message
    MOV DPTR, #MSG_PROMPT
    ACALL UART_STRING

    MOV DPTR, #MSG_GUESS
    ACALL LCD_STRING

    GUESS_LOOP:
        ACALL UART_RX
        MOV B, A
        ACALL UART_RX
        MOV A, B
        SUBB A, #'0'
        MOV B, A
        MOV A, B
        ACALL UART_TX
        MOV A, B
        MOV A, B
        MOV B, #'0'
        SUBB A, B
        MOV B, A
        ACALL UART_RX
        MOV A, B
        ACALL UART_TX
        MOV A, B
        SUBB A, #'0'
        MOV B, A
        MOV A, B
        ACALL UART_TX
        MOV A, B
        MOV A, B
        ADD A, #'0'
        MOV B, A

        MOV A, B
        CJNE A, R7, CHECK_HIGH_LOW
        ; Correct guess
        MOV DPTR, #MSG_CORRECT
        ACALL UART_STRING
        MOV DPTR, #MSG_CORRECT_LCD
        ACALL LCD_STRING
        SJMP END_GAME

CHECK_HIGH_LOW:
        MOV A, B
        SUBB A, R7
        JC TOO_LOW

TOO_HIGH:
        MOV DPTR, #MSG_HIGH
        ACALL UART_STRING
        MOV DPTR, #MSG_HIGH_LCD
        ACALL LCD_STRING
        SJMP GUESS_LOOP

TOO_LOW:
        MOV DPTR, #MSG_LOW
        ACALL UART_STRING
        MOV DPTR, #MSG_LOW_LCD
        ACALL LCD_STRING
        SJMP GUESS_LOOP

END_GAME:
    SJMP END_GAME ; Endlessly loop to stop program

RAND:
    MOV DPTR, #0FE00H
    MOVX A, @DPTR
    CPL A
    MOVX @DPTR, A
    MOV B, #100
    DIV AB
    MOV A, B
    RET

; Data
LCD_INIT_CMDS: DB 38H, 0CH, 06H, 01H, 00H
LCD_INIT_CMDS_LEN EQU ($ - LCD_INIT_CMDS)
MSG_PROMPT: DB 'Guess a number between 0 and 99:', 0DH, 0AH, 00H
MSG_GUESS: DB 'Guess a number:', 00H
MSG_HIGH: DB 'Too high!', 0DH, 0AH, 00H
MSG_LOW: DB 'Too low!', 0DH, 0AH, 00H
MSG_CORRECT: DB 'Correct! You win!', 0DH, 0AH, 00H
MSG_HIGH_LCD: DB 'Too high!   ', 00H
MSG_LOW_LCD: DB 'Too low!    ', 00H
MSG_CORRECT_LCD: DB 'Correct! You win!', 00H

END
