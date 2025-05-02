;
; Labb3.asm

;;;;;;;;;;;;;;;;;;;;
;; START OF LOGIC ;;
;; Property of	  ;;
;; BB & SS		  ;;
;;;;;;;;;;;;;;;;;;;;


;;;;REGISTER 18 tillhor turkiska raven, 
;ingen ror register 18, r18 ar mitt omrade
;Jag kommer knulla dig topp till tå bror

.include "m16adef.inc"

	.org $0000
	jmp		MAIN   ;startar i main
	.org 0x0002   ;Addressen för INT0
	jmp		EXT_INT0
	.org 0x0004	  ;Addressen för INT1
	jmp		EXT_INT1

;Time is stored in 4 memory cells starting at address TIME
.equ TIME = 0x0100
.equ TIME1 = 0x0101
.equ TIME2 = 0x0102
.equ TIME3 = 0x0103

;Tabell för BCD-kod till avkodad för displayen
SEG_TABLE:
	.db 0b01111111 ;0 
	.db 0b00001101 ;1
	.db 0b10110111 ;2
	.db 0b10011111 ;3
	.db 0b11001101 ;4
	.db 0b11011011 ;5
	.db 0b11111011 ;6
	.db 0b00001111 ;7
	.db 0b11111111 ;8
	.db 0b11001111 ;9


MAIN:
	;initiera stacken
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	;Initiera avbrott
	call INIT_INT0
	call INIT_INT1

	;Prepare PIN A & B as output
	ldi r16, $FF
	out DDRA, r16
	out DDRB, r16

	sei			;Aktivera avbrott (i-flaggan måste vara 1)


MAIN_LOOP:
	jmp MAIN_LOOP
	;TODO infinite loop
	
INIT_INT0:
	;Aktivera avbrott på INT0, (INT0 är konstant)
	ldi r16,(1 << INT0)
	sts	EIMSK, r16 ;(EIMSK = registret för externa avbrott
	;Sätter rising edge m.h.a eicra register
	ldi r16,(1<<ISC01)|(1<<ISC00)
	sts EICRA, r16
	ret

INIT_INT1:
	;Aktivera avbrott på INT1
	ldi r16,(1 << INT1)
	sts	EIMSK, r16 ;(EIMSK = registret för externa avbrott
	;Sätter rising edge m.h.a eicra register
	ldi r16,(0<<ISC11)|(1<<ISC10)
	sts EICRA, r16
	ret
	

EXT_INT0:
	;increase BCD COUNT
	push r16
	push r17

	clr r16 ;används senare för carry

	;entalsekunder
	lds r17, TIME ;ladda värdet från minnet
	inc r17
	cpi r17, 0x0A ; jämför med tio
	brlo no_carry_sec1  ; (branch if lower)
	clr r17  ;nollställ om det var carry
	sts TIME, 17

	;tiotal sekunder
	lds r17, TIME1  ;TIME1 är andra minnescellen i time
	
	pop r17
	pop r16

	reti

EXT_INT1:
	call MULTIPLEX_DISPLAY
	reti

MULTIPLEX_DISPLAY:
	;r18 - current active display (0 - 3)
	
	;use r18 to update active display
	call UPDATE_ACTIVE_DISPLAY

	;Get 7-seg representation of number in r18 display
	call SEG_LOOKUP
	;Output 7-seg to current active display
	call UPDATE_7SEG

	inc r18			;Increment active display
	andi r18, 3		;Mask out only bit 0 & 1, 
					;so it loops back to 0 after 3
					;3 = 00000011

	ret

UPDATE_ACTIVE_DISPLAY:
	out		PORTB,r18	; skriv ut aktiv display på PORT-B
	ret

;Uses r18 to lookup 7-seg representation of number
;7-seg output => r16
SEG_LOOKUP:
	;We use r16 as offset
	mov r16, r18

	; Ladda addressen till Lookup table i Z-pointer
	ldi r30, low(SEG_TABLE << 1)
	ldi r31, high(SEG_TABLE << 1)
	
    ; Varje steg i Lookup är egentligen 2 steg, därav multiplicera offset med 2
    lsl  r16    ; r16 *= 2

	; Add r16 offset to Z-pointer
	clr r1
	add r30, r16
	add r31, r1	;r1 should be carry

	; Read 7-seg representation from Lookup into r16
	lpm r16, Z
	ret

;Update 7-seg values A - F, r16 is number in 7-seg format
UPDATE_7SEG:
	out		PORTA,r16	; skriv ut hela register r16
	ret