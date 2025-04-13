
; Initialize IO ports
INIT_IO:
	; PIN A - Ingång
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ingång

	; PIN B - Utgång
	ldi		r16,$FF			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utgång (övriga blir ingång)

	ret

;;; Prints content of r17 to 7-seg Display ;;;
PRINT:
	;;TODO PB7 oscilloskop
	andi	r17,$0F		; nollstället registrets övre halva, bevara lägre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller