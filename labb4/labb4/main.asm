;
; labb4.asm
;
; Created: 2025-05-09 12:50:14
; Author : itmokarn
;
;


	.equ	VMEM_SZ     = 5		; #rows on display
	.equ	AD_CHAN_X   = 0		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = 1		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 70	; inter-run delay (millisecs)
	.equ	PRESCALE    = 3		; AD-prescaler value
	.equ	BEEP_PITCH  = 6	; Victory beep pitch
	.equ	BEEP_LENGTH = 100	; Victory beep length
	; ---------------------------------------
	; --- Memory layout in SRAM
	.dseg
	.org	SRAM_START
POSX:	.byte	1	; Own position
POSY:	.byte 	1
TPOSX:	.byte	1	; Target position
TPOSY:	.byte	1
LINE:	.byte	1	; Current line	
VMEM:	.byte	VMEM_SZ ; Video MEMory
SEED:	.byte	1	; Seed for Random

	; ---------------------------------------
	; --- Macros for inc/dec-rementing
	; --- a byte in SRAM
	.macro INCSRAM	; inc byte in SRAM
		lds	r16,@0
		inc	r16
		sts	@0,r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16,@0
		dec	r16
		sts	@0,r16
	.endmacro

	.macro	PUSH_SREG
		push r16
		in	r16, SREG
		push r16
	.endmacro
	
	.macro	POP_SREG
		pop r16
		out SREG, r16
		pop r16
	.endmacro

	; ---------------------------------------
	; --- Code
	.cseg
	.org 	0x00
	jmp	START
	.org	INT0addr
	jmp	MUX
	;.def r2 = r2


START:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	rcall	INIT_INTX
	rcall	HW_INIT	
	rcall	WARM
RUN:
	rcall	JOYSTICK
	rcall	ERASE_VMEM
	rcall	UPDATE
	rcall	DELAY_GAME		 	
	lds		r16, POSX
	lds		r17, TPOSX
	cp		r16, r17
	brne	NO_HIT	
	lds		r16, POSY
	lds		r17, TPOSY
	cp		r16, r17
	brne	NO_HIT
	ldi		r16, BEEP_LENGTH
	rcall	BEEP
	rcall	WARM
NO_HIT:
	jmp	RUN

	; ---------------------------------------
	; --- Multiplex display
MUX:	
	PUSH_SREG
	push	ZH
	push	ZL
	push	r17
MUX_LINE:
	ldi		ZH, HIGH(LINE)
	ldi		ZL, LOW(LINE)
	ld		r16, Z
	inc		r16
	cpi		r16, 0x05
	brlt	MUX_OUT_LINE
	clr		r16
MUX_OUT_LINE:
	clr r2
	st		Z, r16	
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r16
	adc		ZH, r2
	swap	r16
	out		PORTB, r2
	out		PORTD, r16
	ld		r16, Z
	out		PORTB, r16
MUX_SEED:
	INCSRAM SEED
MUX_EXIT:
	pop		r17
	pop		ZL
	pop		ZH
	POP_SREG
	reti

AD_X:
	ldi		r16, AD_CHAN_X
	jmp		ADC10
AD_Y:
	ldi		r16, AD_CHAN_Y
ADC10:
	ori		r16,(1<<REFS0)
	out		ADMUX,r16
	ldi		r16,(1<<ADEN)
	ori		r16,(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	out		ADCSRA, r16
ADC10_CONVERT:
	in		r16,ADCSRA
	ori		r16,(1<<ADSC)
	out		ADCSRA,r16
ADC10_WAIT:
	sbic	ADCSRA, ADSC
	rjmp	ADC10_WAIT
	in		r16, ADCH
	ret
		
	; ---------------------------------------
	; --- JOYSTICK Sense stick and update POSX, POSY
	; --- Uses r16
JOYSTICK:	
	push	r16
	push	r17
JOY_POS_X_COMPARE:
	call	AD_X
	;ldi		r16,ADCH
	cpi		r16,0x03
	breq	JOY_POS_X_INC
	cpi		r16,0x00
	breq	JOY_POS_X_DEC
	rjmp	JOY_POS_Y_COMPARE
JOY_POS_X_INC:
	INCSRAM	POSX
	rjmp	JOY_POS_Y_COMPARE
JOY_POS_X_DEC:
	DECSRAM	POSX
JOY_POS_Y_COMPARE:
	call	AD_Y
	;ldi		r16,ADCH
	cpi		r16,0x03
	breq	JOY_POS_Y_INC
	cpi		r16,0x00
	breq	JOY_POS_Y_DEC
	rjmp	JOY_LIM
JOY_POS_Y_INC:
	INCSRAM	POSY
	rjmp	JOY_LIM
JOY_POS_Y_DEC:
	DECSRAM	POSY
JOY_LIM:
	rcall	LIMITS		; don't fall off world!
JOY_EXIT:
	pop	r17
	pop	r16
	ret

	; ---------------------------------------
	; --- LIMITS Limit POSX,POSY coordinates	
	; --- Uses r16,r17
LIMITS:
	lds		r16,POSX	; variable
	ldi		r17,7		; upper limit+1
	rcall	POS_LIM		; actual work
	sts		POSX,r16
	lds		r16,POSY	; variable
	ldi		r17,5		; upper limit+1
	rcall	POS_LIM		; actual work
	sts		POSY,r16
	ret

POS_LIM:
	ori		r16,0		; negative?
	brmi	POS_LESS	; POSX neg => add 1
	cp		r16,r17		; past edge
	
	brne	POS_OK
	subi	r16,2


POS_LESS:
	inc		r16


POS_OK:
	ret

	; ---------------------------------------
	; --- UPDATE VMEM
	; --- with POSX/Y, TPOSX/Y
	; --- Uses r16, r17
UPDATE:	
	clr		ZH 
	ldi		ZL,LOW(POSX)
	rcall 	SETPOS
	clr		ZH
	ldi		ZL,LOW(TPOSX)
	rcall	SETPOS
	ret

	; --- SETPOS Set bit pattern of r16 into *Z
	; --- Uses r16, r17
	; --- 1st call Z points to POSX at entry and POSY at exit
	; --- 2nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld		r17,Z+  	; r17=POSX
	rcall	SETBIT		; r16=bitpattern for VMEM+POSY
	ld		r17,Z		; r17=POSY Z to POSY
	ldi		ZL,LOW(VMEM)
	add		ZL,r17		; *(VMEM+T/POSY) ZL=VMEM+0..4
	ld		r17,Z		; current line in VMEM
	or		r17,r16		; OR on place
	st		Z,r17		; put back into VMEM
	ret
	
	; --- SETBIT Set bit r17 on r16
	; --- Uses r16, r17
SETBIT:
	ldi		r16, 0x01		; bit to shift
SETBIT_LOOP:
	dec 	r17			
	brmi 	SETBIT_END	; til done
	lsl 	r16		; shift
	rjmp 	SETBIT_LOOP
SETBIT_END:
	ret

	; ---------------------------------------
	; --- Hardware init
	; --- Uses r16
HW_INIT:
	clr		r2
	ldi		r16, 0x7F
	out		DDRB, r16
	ldi		r16, 0xF0
	out		DDRD, r16

	sei			; display on
	ret

INIT_INTX:
	ldi		r16, (1<<INT0)
	out		GICR, r16
	ldi		r16, (1<<ISC01) | (1<<ISC00)
	out		MCUCR, r16
	ret
	; ---------------------------------------
	; --- WARM start. Set up a new game
WARM:
	push	r0		
	push	r0		
	rcall	RANDOM		; RANDOM returns x,y on stack

	; Load pos (0,2) as starting position
	pop		r16
	sts		TPOSY, r16
	pop		r16
	sts		TPOSX, r16
	ldi		r16, 0x00
	sts		POSX, r16
	ldi		r16, 0x02
	sts		POSY, r16
	rcall	ERASE_VMEM
	ret

RANDOM:
	in		r16,SPH
	mov		ZH,r16
	in		r16,SPL
	mov		ZL,r16
	inc		ZL
	inc		ZL
	inc		ZL
POS_Y:
	lds		r16, SEED
	andi	r16, 0x07
	cpi		r16, 0x04
	brlt	POS_Y_STORE
POS_Y_BIGGER:
	subi	r16, 0x04
POS_Y_STORE:
	st		Z+, r16 ; STORE TO SRAM
POS_X:
	lds		r16, SEED
	lsl		r16
	andi	r16, 0x07
	cpi		r16, 0x04
	brlt	POS_X_STORE
POS_X_BIGGER:
	subi	r16, 0x04
POS_X_STORE:
	subi	r16, -0x02
	st		Z, r16
	ret


	; ---------------------------------------
	; --- Erase Videomemory bytes
	; --- Clears VMEM..VMEM+4
	
ERASE_VMEM:
	clr r2
	sts		VMEM+0, r2
	sts		VMEM+1, r2
	sts		VMEM+2, r2
	sts		VMEM+3, r2
	sts		VMEM+4, r2
	ret

BEEP:	
	push	r24
	push	r25
	ldi		r24, LOW(BEEP_LENGTH)
	ldi		r25, HIGH(BEEP_LENGTH)
BEEP_LOOP:
	sbi		PORTD,0x07
	rcall	DELAY_BEEP
	cbi		PORTD,0x07
	rcall	DELAY_BEEP
	sbiw	r24,0x01
	brne	BEEP_LOOP
	pop		r25
	pop		r24
	ret

DELAY_GAME:	
	push	r17
	push	r18
	ldi		r18, 0xFF
	rjmp	delayYttreLoop
DELAY_BEEP:
	push	r17
	push	r18
	ldi		r18, BEEP_PITCH
delayYttreLoop:
	ldi		r17,0x5F
delayInreLoop:
	dec		r17
	brne	delayInreLoop
	dec		r18
	brne	delayYttreLoop
DELAY_EXIT:
	pop		r18
	pop		r17
	ret