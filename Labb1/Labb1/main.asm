


MAIN:
	; r17 is number 0-9 for print

	.equ	T_INTERVAL = 10		; global konstant

	; Initiera Stacken
	ldi		r16,HIGH(RAMEND)
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16

	; initiera portriktningar
	call	INIT_IO		

	clr		r17					; B�rja r�kna fr�n 0
	
	jmp LOOP		
	; -- MAIN


; Initialize IO ports
INIT_IO:
	; PIN A - Ing�ng
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ing�ng

	; PIN B - Utg�ng
	ldi		r16,$FF			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utg�ng (�vriga blir ing�ng)

	ret

; Prints content of r17 to 7-seg Display 
PRINT:
	;;TODO PB7 oscilloskop
	andi	r17,$0F		; nollst�llet registrets �vre halva, bevara l�gre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller

	
LOOP:
	call WAIT_FOR_START_BIT
	;; TODO DELAY WITH T/2

	jmp LOOP			; Loopa f�ralltid

WAIT_FOR_START_BIT:
	
	jmp WAIT_FOR_START_BIT
	;; TODO while loopa h�r tills vi hittar startbit