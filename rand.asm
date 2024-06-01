; Linearer Kongruenzgenerator zur Erzeugung von Pseudozufallszahlen
; Eigentlich handelt es sich dabei eher um eine Zahlenfolge, bei welcher
; die Folgenglieder zufällig aussehen, es aber nicht sind. Ist mir aber
; gerade herzlich egal.

ORG 0H

; Startpunkt für das Programm
START:
    MOV R0, #0x69	; Seed für Zufallszahlen auf 105 setzen

; Hauptprogramm
MAIN:
	ACALL RAND
	ACALL DELAY
	SJMP MAIN





; Unterprogramm generiert eine Pseudozufallszahl mittels einem linearen Kongruenzgenerator.
; Das Ergebnis wird in R0 gespeichert.
RAND:
	MOV A, R0

	; LCG-Berechnung: X = (a * X + c) % 256
	MOV B, #0x3A	; a = 58
	MUL AB
	ADD A, #0x13	; c = 19
	MOV R0, A
	RET





; Unterprogramm zur Verzögerung
DELAY:
    MOV R1, #0xFF

DELAY_LOOP:
    DJNZ R1, DELAY_LOOP
    RET

END
