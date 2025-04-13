


MAIN:
	; r16 used for reading
	; r17 is number 0-9 (print)
	.equ	T_INTERVAL = 10		; global konstant

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


; Initialize IO ports
INIT_IO:
	; PIN A - Ing�ng
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ing�ng

	; PIN B - Utg�ng
	ldi		r16,$FF			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utg�ng (�vriga blir ing�ng)

	ret

;;; Prints content of r17 to 7-seg Display ;;;
PRINT:
	;;TODO PB7 oscilloskop
	andi	r17,$0F		; nollst�llet registrets �vre halva, bevara l�gre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller