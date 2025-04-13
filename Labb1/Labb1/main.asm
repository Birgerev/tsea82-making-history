
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