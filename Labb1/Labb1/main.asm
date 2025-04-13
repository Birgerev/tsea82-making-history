


MAIN:
	; r18 is number 0-9 for print

	.equ	T_INTERVAL = 10		; global konstant

	; Initiera Stacken
	ldi		r16,HIGH(RAMEND)
	out		SPH,r16
	ldi		r16,LOW(RAMEND)
	out		SPL,r16

	; initiera portriktningar
	call	INIT_IO		

	clr		r18
	
	jmp LOOP		
	; -- MAIN


; Initialize IO ports
INIT_IO:
	; PIN A - Ing�ng
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ing�ng

	; PIN B - Utg�ng
	ldi		r16,$FF			; $FF = 11111111
	out		DDRB,r16		; PORTB bit3..0 utg�ng (�vriga blir ing�ng)

	ret

; Prints content of r18 to 7-seg Display 
PRINT:
	;;TODO PB7 oscilloskop
	andi	r18,$0F		; nollst�llet registrets �vre halva, bevara l�gre halva
						; $0F = 00001111
	out		PORTB,r18	; skriv ut hela register r18
	ret					; return till caller

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

	
READ_A0:
	in		r16,PINA	; l�s in hela porten
	andi	r16,$01		; maska ut bit0, flaggor p�verkas
	ret					; l�st bits v�rde signaleras i Z-flaggan

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					START OF LOGIC					;
;					PROPERTY OF	BB					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



LOOP:
	call	WAIT_FOR_START_BIT

	; Delay with T/2, so we are in 'middle' of signal interval
	call DELAY

	; Ensure bit is still valid (after T/2 delay)
	call CHECK_BIT

	; Serially read incomming data bits, result written to r18
	call	READ_DATA_BITS

	; Print contents of r18 to 7-Seg Display
	call	PRINT

	jmp		LOOP			; Loopa f�ralltid

WAIT_FOR_START_BIT:
	; Read current bit in to r16
	call	READ_A0
	breq	WAIT_FOR_START_BIT ; while (startbit == 0)
	ret

; Check that bit was valid, if not, return to cringe idle state (never gonna happen cuz we cool),
; Otherwise continue as normal 
CHECK_BIT:
	; Read current bit in to r16
	call	READ_A0
	breq	WAIT_FOR_START_BIT
	ret

READ_DATA_BITS:
	clr		r18		; Nollst�ll itererings-index
	ldi		r19, 4	; Loopa 4 ggr
	jmp READ_LOOP

READ_LOOP:	
	; Read A0 bit, value is in r16 and all bits except least significant = 0. example ()
	call	READ_A0

	lsl		r18			; Bitshift
	or		r18,r16		; Set last bit of r18 to value of A0, Example: A0 = x, 0000000

	call	DELAY
	
	dec		r19			; Stega ner loop-r�knaren
	brne	READ_LOOP ; Forts�tt loopa tills r19 == 0

	ret