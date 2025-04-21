;
; Labb2.asm
;
; Created: 2025-04-20 14:06:46
; Author : itmokarn
;

; Huvudloop som s�nder en hel str�ng
MORSE:
	.equ T, 0			; Tone frequency constant
	.equ N, 20			; Morse Delay constant (frequency we send characters at)

	;TODO pusha alla register vi anv�nder till stacken
	; De m�ste enl instruktionerna vara op�verkade (h�h� som jag ;) )
	; efter vi k�rt programmet

	;TODO save MORSE table in BTAB memory
	


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
	; TODO we bitshift the character byte
	; Next bit is found in the carry flag

	;When whole byte is 0 and carry flag is 1,
	; we know character is done
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

; Rutinen DELAY �r en v�nteloop som samtidigt
; avger en skvallersignal p� PB7.
; PB7 �r h�g (jag med) n�r rutinen k�rs
;
; Med angivet v�rde i r16 v�ntar rutinen
; ungef�r en millisekund @ 1 MHz
;
; PORTB m�ste konfigureras separat.
DELAY:
	sbi		PORTB,7
	ldi		r16,10		; Decimal bas
delayYttreLoop:
	ldi		r17,$1F
delayInreLoop:
	dec		r17
	brne	delayInreLoop
	dec		r16
	brne	delayYttreLoop
	cbi		PORTB,7
	ret