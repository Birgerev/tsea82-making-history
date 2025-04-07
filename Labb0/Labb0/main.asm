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

	ldi		r16,HIGH(RAMEND)	;stack f�r subrutiner
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	call	INIT				; initiera portriktningar
	clr		r17					; B�rja r�kna fr�n 0
	; -- MAIN

LOOP:
	call	KEY
	inc		r17
	cpi		r17,MAX_NUM
	brne	NUT_MAXX
	clr		r17
NUT_MAXX:;PROPERTY OF H�VDING BIRGER
	call	PRINT
	jmp		LOOP

; Replace with your application code
INIT:
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ing�ng
	ldi		r16,$0F			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utg�ng (�vriga blir ing�ng)
	ret

READ_BIT0:
	in		r16,PINA	; l�s in hela porten
	andi	r16,$01		; maska ut bit0, flaggor p�verkas
	ret					; l�st bits v�rde signaleras i Z-flaggan
KEY:
	call	READ_BIT0
	brne	KEY			; v�nta p� att den sl�pps
KEY_WAIT:
	call	READ_BIT0
	breq	KEY_WAIT	; v�nta p� tryck
	ret					; nu �r den tryckt, returna

PRINT:
	andi	r17,$0F		; nollst�llet registrets �vre halva, bevara l�gre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller

