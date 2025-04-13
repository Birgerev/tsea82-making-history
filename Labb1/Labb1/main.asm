


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

	clr		r17					; Börja räkna från 0
	
	jmp LOOP		
	; -- MAIN


; Initialize IO ports
INIT_IO:
	; PIN A - Ingång
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ingång

	; PIN B - Utgång
	ldi		r16,$FF			; $0F = 00001111
	out		DDRB,r16		; PORTB bit3..0 utgång (övriga blir ingång)

	ret

; Prints content of r17 to 7-seg Display 
PRINT:
	;;TODO PB7 oscilloskop
	andi	r17,$0F		; nollstället registrets övre halva, bevara lägre halva
						; $0F = 00001111
	out		PORTB,r17	; skriv ut hela register r17
	ret					; return till caller

	
LOOP:
	call WAIT_FOR_START_BIT
	;; TODO DELAY WITH T/2

	jmp LOOP			; Loopa föralltid

WAIT_FOR_START_BIT:
	
	jmp WAIT_FOR_START_BIT
	;; TODO while loopa här tills vi hittar startbit