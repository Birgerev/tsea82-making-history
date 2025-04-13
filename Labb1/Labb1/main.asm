


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
	; PIN A - Ingång
	ldi		r16,$00			; $00 = 00000000
	out		DDRA,r16		; hela PINA ingång

	; PIN B - Utgång
	ldi		r16,$FF			; $FF = 11111111
	out		DDRB,r16		; PORTB bit3..0 utgång (övriga blir ingång)

	ret

; Prints content of r18 to 7-seg Display 
PRINT:
	;;TODO PB7 oscilloskop
	andi	r18,$0F		; nollstället registrets övre halva, bevara lägre halva
						; $0F = 00001111
	out		PORTB,r18	; skriv ut hela register r18
	ret					; return till caller

; Rutinen DELAY är en vänteloop som samtidigt
; avger en skvallersignal på PB7.
; PB7 är hög (jag med) när rutinen körs
;
; Med angivet värde i r16 väntar rutinen
; ungefär en millisekund @ 1 MHz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					START OF LOGIC					;
;					PROPERTY OF	BB					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



LOOP:
	call WAIT_FOR_START_BIT

	;; TODO DELAY WITH T/2 (so we are in 'middle' of bit signal)

	;; TODO checkbit (check that A0 is still high after T/2 delay)

	; Serially read incomming data bits, result written to r18
	call READ_DATA_BITS

	; Print contents of r18 to 7-Seg Display
	call PRINT

	jmp LOOP			; Loopa föralltid

WAIT_FOR_START_BIT:
	
	jmp WAIT_FOR_START_BIT ;; TODO keep looping while (startbit == 0)
	; ret

READ_DATA_BITS:
	;; TODO loop 4 times (for the 4 data bits)

	;; TODO read PINA-0
	;; TODO congruate all bits to a byte, then
	;; TODO delay with T



;; TODO copy over DELAY method
