;
; Labb2.asm
;
; Created: 2025-04-20 14:06:46
; Author : itmokarn
;

; Huvudloop som sänder en hel sträng
MORSE:
	.equ T, 0			; Tone frequency constant
	.equ N, 20			; Morse Delay constant (frequency we send characters at)

	call BTAB_INIT

	;TODO pusha alla register vi använder till stacken
	; De måste enl instruktionerna vara opåverkade (höhö som jag ;) )
	; efter vi kört programmet

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

; Rutinen DELAY är en vänteloop som samtidigt
; avger en skvallersignal på PB7.
; PB7 är hög (jag med) när rutinen körs
;
; Med angivet värde i r16 väntar rutinen
; ungefär en millisekund @ 1 MHz
;
; PORTB måste konfigureras separat.
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

; BTAB – Morse binärkod för A–Z (0x41–0x5A)
; Index = ASCII - 0x41
BTAB_INIT:
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
