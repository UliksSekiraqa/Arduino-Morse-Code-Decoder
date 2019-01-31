	;; init.S 
#define __SFR_OFFSET 0
#include <avr/io.h> 				

	;; this pseudo op ensures the following code will be placed right at the start of the program memory
	.section .vectors

	
				
	.org 0x0		; ensures we start from address 0x0 (redundant)
reset_v:
	rjmp init ; after a reset, code execution starts here

	;; interrupt vector addresses in the manual are in words, but
	;; gnu-as expects address in bytes so we << the word addresses 
	.org 0x14 << 1 ; advancing to word address 0x14, byte
				; address 0x28
timer1_cpt_v:
	jmp timer1_cpt_isr	; execution starts here after an
				; interrupt from input capture at ICP1, register A

	.org 0x16 << 1	 	
timer1_compa_v:
	jmp timer1_compa_isr   	; execution starts here after an interrupt from compare match timer 1, register A
	

	.org 0x1a << 1   
timer1_ovr_v:	
	jmp timer1_ovr_isr 	; timer1 overrun interrupt starts from here.


;;; we make the symbols that point to ISR as weak reference. This means
;;; if you define them otherwise in your own code and export them as
;;; .global, their address will be taken, not the one in this file.
	.weak timer1_compa_isr
	.weak timer1_cpt_isr
	.weak timer1_ovr_isr
;;; make the week isr label point to a dummy isr:
timer1_compa_isr:	
timer1_ovr_isr:
timer1_cpt_isr:
	reti
	
init:	

	;; setting up the stack.
	ldi r16, hi8(RAMEND)
	out SPH, r16
	ldi r16, lo8(RAMEND)
	out SPL, r16

	;; The Arduino has a bootloader, and the bootloader is
	;; executed before the reset jump to 0x0. However it seems the
	;; bootloader does not reset bits 0,1 of PORTD which it uses as
	;; a serial interface TX/RX to communicate over USB to default
	;; values -- so we do this here to make at least PORTD1
	;; available as a normal output. PORTD0 has too much on-board
	;; circuitry attached to it -- better not use it at all for
	;; input/output. 
	
	ldi r16, 0
	sts UCSR0B, r16 	; reset serial interface pin.

	jmp main		; and off we go to the user code --
				; your program must somewhere define a
; .global main label
