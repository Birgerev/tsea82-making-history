
.equ T = 500			; Tone frequency constant
.equ N = 100			; Morse Delay constant (frequency we send characters at)
	
;STR: .db "ABAB", 0
STR: .db "DATORTEKNIK", 0
;STR: .db "AAAAAAAAA", 0

; BTAB – Morse binärkod för A–Z (0x41–0x5A)
; Index = ASCII - 0x41
BTAB:
	.db 0x60; A
	.db 0x88; B
	.db 0xA8; C
	.db 0x90; D
	.db 0x40; E
	.db 0x28; F
	.db 0xD0; G
	.db 0x10; H
	.db 0x20; I
	.db 0x78; J
	.db 0xB0; K
	.db 0x48; L
	.db 0xE0; M
	.db 0xA0; N
	.db 0xF0; O
	.db 0x68; P
	.db 0xD8; Q
	.db 0x50; R
	.db 0x10; S
	.db 0xC0; T
	.db 0x30; U
	.db 0x18; V
	.db 0x70; W
	.db 0x98; X
	.db 0xB8; Y
	.db 0xC8; Z

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;		START OF LOGIC	;;;
;;;		PROPERTY OF		;;;
;;;		BIG BIRGER		;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Initialize hardware
HW_INIT:
	; PIN A - Ingång
	sbi DDRB, 7      ; sätter pin 7B som utgång

; Huvudloop som sänder en hel sträng
MORSE:
	; pushar alla register vi använder till stacken (inklusive Z etc)
	; De måste enl instruktionerna vara opåverkade (höhö som jag ;) )
	; efter vi kört programmet	
	push r16
	push r30
	push r31

	ldi r30, low(STR << 1)	; Ladda ZL-pekare (för strängen)
	ldi r31, high(STR << 1)	; Ladda ZH-pekare
	
	call GET_CHAR		; Get first character in string
	call BEEP_CHARS

	pop r31
	pop r30
	pop r16

	rjmp MORSE			; Loop again

; Logic for sending one character
; Call 'GET_CHAR' first
BEEP_CHARS:
	; We have ASCII-character in r16
	call LOOKUP			; Convert character to morse representation
	; Binary Morse-representation will now be in r16

	call SEND_CHAR
	call NOBEEP			; Silence over 2N
	call NOBEEP

	CALL GET_CHAR		; Get next character in string
	cpi r16, 0			; Loop until no more chars (r16 == 0)
	brne BEEP_CHARS

; Get next ASCII-character from string
; Next character byte is saved to r16
GET_CHAR:
	lpm r16, Z+			; Read character byte from Z-pointer, then increment pointer
	ret

; Translates ASCII-character to binary
; Character in r16
; Output morse representation in r16
LOOKUP:
	push r30			; Store Z-pointer on stack
	push r31
	
	; Subtrahera ASCII-kod för första bokstaven 'A' ($41)
	subi r16, 'A'		; r16 = index i BTAB

	; Ladda addressen till BTAB i Z-pointer
	ldi r30, low(BTAB << 1)
	ldi r31, high(BTAB << 1)

    ; convert index to a byte?offset in FLASH (each entry is 2 bytes)
    lsl  r16            ; r16 = r16 * 2

	; Add r16 offset to Z-pointer
	clr r1
	add r30, r16
	add r31, r1
	;adc r31, __zero_reg__	; Handle pointer carry overflow

	; Read Morse representation from BTAB
	lpm r16, Z
	
	pop r31
	pop r30 
	ret
	
; Sends a character
; Character Morse representation in r16
SEND_CHAR:
	call SEND_BITS_LOOP

	call NOBEEP			; 1N Silence, space between next character
	ret
	
SEND_BITS_LOOP:
	call NOBEEP
	lsl r16					; Bitshift character left
	; Bit to send is now found in carry flag
	call SEND_BIT
	
	cpi r16, $80				; Keep looping until r16 == 10000000 == $80
	brne SEND_BITS_LOOP			; as it marks end bit
	
	ret

; Uses carry flag 
SEND_BIT:
	brcc BEEP			; Branch to beep if carry is not set
	brcs BEEP3			; Branch to long beep if carry is set
	ret

BEEP:
	push r18
	ldi r18, N  ; Vi loopar N gånger
BEEPLOOP:
	;Vi växlar mellan 1 och 0 med en frekvens på 500 hz
	cbi PORTB, 7; sätt utgången till 1
	call DELAY
	sbi PORTB, 7; sättutgången till 0
	call DELAY
	dec r18 ; minskar loopen med et

	cpi r18,$00		; Sluta loopa då r18 == $00
	brne BEEPLOOP	; om
	pop r18
	ret

BEEP3:
	call BEEP
	call BEEP
	call BEEP
	ret

NOBEEP:
	push r18
	ldi r18, N  ; Vi loopar N gånger
NOBEEPLOOP:
	cbi PORTB, 7; sättutgången till 0
	call DELAY
	call DELAY
	
	dec r18 ; minskar loopen med et

	cpi r18,$00		; Sluta loopa då r18 == $00
	brne NOBEEPLOOP
	pop r18
	ret

NOBEEP3:
	call NOBEEP
	call NOBEEP
	call NOBEEP
	ret

; Rutinen DELAY är en vänteloop som samtidigt
; avger en skvallersignal på PB7.
; PB7 är hög (jag med) när rutinen körs
;
; Med angivet värde i r16 väntar rutinen
; ungefär en millisekund @ 1 MHz
;
; PORTB måste konfigureras separat.
DELAY:
	push	r19
	push	r17
	ldi		r19,10		; Decimal bas
delayYttreLoop:
	ldi		r17,$1F
delayInreLoop:
	dec		r17
	brne	delayInreLoop
	dec		r19
	brne	delayYttreLoop
	pop		r17
	pop		r19
	ret
