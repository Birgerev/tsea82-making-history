
.equ T, 0			; Tone frequency constant
.equ N, 20			; Morse Delay constant (frequency we send characters at)
	
STR: .db "DATORTEKNIK", 0

; BTAB � Morse bin�rkod f�r A�Z (0x41�0x5A)
; Index = ASCII - 0x41
BTAB:
	.db 0x60; A
	.db 0x88; B
	.db 0xA8; C
	.db 0x90; D
	.db 0x40; E
	.db 0x28; F
	.db 0xD0; G
	.db 0x10; H
	.db 0x20; I
	.db 0x78; J
	.db 0xB0; K
	.db 0x48; L
	.db 0xE0; M
	.db 0xA0; N
	.db 0xF0; O
	.db 0x68; P
	.db 0xD8; Q
	.db 0x50; R
	.db 0x10; S
	.db 0xC0; T
	.db 0x30; U
	.db 0x18; V
	.db 0x70; W
	.db 0x98; X
	.db 0xB8; Y
	.db 0xC8; Z


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;		START OF LOGIC	;;;
;;;		PROPERTY OF		;;;
;;;		BIG BIRGER		;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Initialize hardware
HW_INIT:
	ret

; Huvudloop som s�nder en hel str�ng
MORSE:
	;TODO pusha alla register vi anv�nder till stacken (inklusive Z etc)
	; De m�ste enl instruktionerna vara op�verkade (h�h� som jag ;) )
	; efter vi k�rt programmet	

	ldi r30, low(STR << 1)	; Ladda ZL-pekare (f�r str�ngen)
	ldi r30, high(STR << 1)	; Ladda ZH-pekare
	
	call GET_CHAR			; Get first character in string
	call CHAR_LOOP

	;;TODO pop all regs

	rjmp MORSE				; Loop again

; Logic for sending one character
; Call 'GET_CHAR' first
CHAR_LOOP:
	; We have ASCII-character in r16
	call LOOKUP			; Convert character to morse representation
	; Binary Morse-representation will now be in r16

	call SEND
	call NOBEEP			; TODO NOBEEP over 2N

	CALL GET_CHAR		; Get next character in string
	cpi r16, 0			; Loop until no more chars (r16 == 0)
	brne CHAR_LOOP
	ret					; Return to MORSE routine

; Get next ASCII-character from string
; Next character byte is saved to r16
GET_CHAR:
	lpm r16, Z+			; Read character byte from Z-pointer, then increment pointer
	ret

; Sends morse character
BEEP_CHAR:
	ret

; Translates ASCII-character to binary
; Character in r16
; Output morse representation in r16
LOOKUP:
	push r30			; Store Z-pointer on stack
	push r31
	
	; Subtrahera ASCII-kod f�r f�rsta bokstaven 'A' ($41)
	subi r16, 'A'		; r16 = index i BTAB

	; Ladda addressen till BTAB i Z-pointer
	ldi r30, low(BTAB << 1)
	ldi r31, high(BTAB << 1)

	; Add r16 offset to Z-pointer
	add r30, r16
	adc r31, __zero_reg__	; Handle pointer carry overflow

	; Read Morse representation from BTAB
	lpm r16, Z
	
	pop r31
	pop r30 
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

; Sends a "-" or "." and then waits
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
