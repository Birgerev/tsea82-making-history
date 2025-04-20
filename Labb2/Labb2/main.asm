;
; Labb2.asm
;
; Created: 2025-04-20 14:06:46
; Author : itmokarn
;

; Huvudloop som sänder en hel sträng
MORSE:
	.equ T, 0			; Tone frequency constant
	.equ N, 0			; Morse Delay constant (frequency we send characters at)

	;TODO this is all pseudo code
	call HW_INIT
	call GET_CHAR
	;TODO while loop as long as there are characters
	;while(char!=0):
	call LOOKUP
	call SEND
	call NOBEEP			;TODO NOBEEP over 2N
	CALL GET_CHAR		; Get next character

; Initialize hardware
HW_INIT:
	ret

; Get next ASCII-character from string
GET_CHAR:
	ret

; Logic for sending one character
ONE_CHAR:
	ret

; Sends morse character
BEEP_CHAR:
	ret

; Translates ASCII-character to binary
LOOKUP:
	ret
	
; Sends a character
SEND:
	call GET_BIT
	;TODO while loop till there are no more bits for character
	;if bit == 0
	call BEEP			; 1N Beep, Morse '.'
	;else
	call BEEP3			; 1N Beep, Morse '-'

	call NOBEEP			; 1N Silence, space between next character
	call GET_BIT		; Get next bit to send

; Get the next bit to send
GET_BIT:
	ret

; Sends all bits for a character
SEND_BITS
	ret

;
BIT:
	ret

BEEP:
	ret

BEEP3:
	call BEEP
	call BEEP
	call BEEP
	ret

NOBEEP:
	ret

NOBEEP3:
	call NOBEEP
	call NOBEEP
	call NOBEEP
	ret