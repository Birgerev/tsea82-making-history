;
; Labb3.asm

;;;;;;;;;;;;;;;;;;;;
;; START OF LOGIC ;;
;; Property of	  ;;
;; BB & SS		  ;;
;;;;;;;;;;;;;;;;;;;;

	.org $0000
	jmp		MAIN   ;startar i main
	.org 0x0002   ;Addressen för INT0
	jmp		EXT_INT0
	.org 0x0004	  ;Addressen för INT1
	jmp		EXT_INT1

MAIN:
	;initiera stacken
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

INIT_INT0:
	ldi r16,(1 << INT0)
	sts	EIMSK, r16
	ldi r16,(1<<<ISC01)|(1<<ISC00)
	sts EICRA, r16
	ret
