;
; Labb1.asm
;
; Created: 2025-04-13 15:39:42
; Author : itmokarn
;




PRINT:
	andi	r17,$0F		; nollst�llet registrets �vre halva, bevara l�gre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller