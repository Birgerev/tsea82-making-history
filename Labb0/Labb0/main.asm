;
; Labb0.asm
;
; Created: 2025-04-06 17:11:50
; Author : itmokarn
;

MAIN:
	; r16 used for reading
	; r17 is number 0-9 (print)
	.equ	MAX_NUM = 10		; global konstant

	ldi		r16,HIGH(RAMEND)	;stack för subrutiner
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	call	INIT				; initiera portriktningar
	clr		r17					; Börja räkna från 0
	; -- MAIN

LOOP:
	call	KEY
	inc		r17
	cpi		r17,MAX_NUM
	brne	NUT_MAXX
	clr		r17
NUT_MAXX:;PROPERTY OF HÖVDING BIRGER
	call	PRINT
	jmp		LOOP

; Replace with your application code
INIT:
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ingång
	ldi		r16,$0F			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utgång (övriga blir ingång)
	ret

READ_BIT0:
	in		r16,PINA	; läs in hela porten
	andi	r16,$01		; maska ut bit0, flaggor påverkas
	ret					; läst bits värde signaleras i Z-flaggan
KEY:
	call	READ_BIT0
	brne	KEY			; vänta på att den släpps
KEY_WAIT:
	call	READ_BIT0
	breq	KEY_WAIT	; vänta på tryck
	ret					; nu är den tryckt, returna

PRINT:
	andi	r17,$0F		; nollstället registrets övre halva, bevara lägre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller

