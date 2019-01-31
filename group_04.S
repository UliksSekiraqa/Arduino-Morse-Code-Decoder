#define __SFR_OFFSET 0
#include <avr/io.h>
#include "7segment.S"
	CPU_FREQ = 16000000 ;; CPU Frequency in Hertz(HZ)
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) ;; Number of clock ticks per second
	SIGNAL_GAP = TICKS_PER_SEC / 4 	;; Time between every signal, 250ms.
	LETTERGAP = TICKS_PER_SEC / 2 	        ;; The time to determine if it is a gap between two letters, 500ms.
;; GROUP 04 ARDUINO COMLOGIC 1031 COURSEWORK:
;; ULIKS SEKIRAQA, ALEKSANDRA MAREVSKAIA, YOUSIF HASSAN, RISHAB JAIN
;; REGISTER DEFINITIONS
;; r18 used to display letter inputs onto 7seg.
;; r24 is the sequence of morse inputs.
;; r23 is the length of the morse input (up to 4).
;; r16 will be the timer control register
;; Button is set to 0, with 1 indicating that the button is pressed.

	BUTTON = 0

	.global main
main:

	ldi r18, ALL_SEGS						;; Loads all segments of the 7segment display to register 18.
	out DDRD, r18							;; Make register 18 output to port D.

	sbi PORTB, BUTTON 						;; Pin 0 is set as an output for port B.

;; Timer setup

	;;Clears register 16.
	clr r16
	sts TCCR1A, r16							;; Sets r16 as the timer control register.

	ldi r16, LETTERGAP					;; Loads the timer between letters to r16.
	sts OCR1AH, r16							;; Moves r16 into the high byte of Compare Match Register A

	clr r16											;; Clears r16
	sts OCR1AL, r16							;; Stores r16 in the high byte of Compare Match Register A

	ldi r16, _BV(ICIE1) | _BV(OCIE1A)				;; Enables the Input Capture Interrupt (ICIE1) - timing of button presses,
																					;; and output Compare A Match Interrupt A (OCIE1A)
	sts TIMSK1, r16													;;

	ldi r16,  _BV(ICNC1) | _BV(CS12) | _BV(CS10) | _BV(WGM12) 	;;Noise canceller, clock select, and  WGM12 (CTC, clear timer on compare) loaded into r16.
	sts TCCR1B, r16 						;; r16 stored in the Timer/Counter Control Register, where the prescaler is configured.

	clr r19
	ldi r18, ALL_SEGS						;; Clears the display for first button press.

	sei								;; Enable interrupts globally.


	;; Decoder will wait for a button press.
wait_press:	rjmp wait_press

	;; Exports symbol to overwrite the weak definition in init.S
	.global timer1_compa_isr
timer1_compa_isr:
	push r16								;;Pushes r16 onto the stack.
	in r16, SREG						 		; saves the status register of r16.
	push r16

	lds r16, TCCR1B							;; Loads r16 from Timer Control Register B.
	sbrs r16, ICES1 						;; Skip this if ICES = 1.
	rjmp wait_for_press						;; Jumps to .

wait_for_release:
	ser r19 							;; Making sure any signal longer than the overflow timer is counted as a long signal.
	rjmp 1f

wait_for_press:
	rcall get_length    ;; Recall get_length to output letter.
	rcall load_to_display				;; calls to the load_to_display routine.


;; Restoring SREG and r16, and returning from the interrupt.
1:
	pop r16				;;r16 is popped from the stack.
	out SREG, r16		;restores the status registers.
	pop r16

	reti			;;Returns from interrupt, carrying on with previous routine.

	.global timer1_cpt_isr
timer1_cpt_isr:
	push r10		;;Pushing registers onto the stack to be used in the execution.
	push r16
	push r17

	in r16, SREG 		; saves the status register

	push r16

	lds r10, ICR1L	 	;; Load r10 into ICR1L (Input capture register low).
	lds r10, ICR1H   	;; Load r10 ICR1H (Input capture register high).

	mov r17,r19  	 	;; Copy value of r19 into r17.
	or r17,r16		;; OR r17 and r16 to see if equal.

	breq debounce		; debounces the button.

;; Resets the timer, writes the high byte to the latch.
	clr r17
	sts TCNT1H, r17
	sts TCNT1L, r17

;; Checking which of the two types of edges was detected
	lds r17, TCCR1B				;; Load r17 from TCCR1B.
	sbrs  r17, ICES1			;; If rising edge, skip.

	rjmp pressed				;;When button is pressed, jump to pressed routine.
	rcall released				;;When button is released, call the released routine.


	andi r17, ~(_BV(ICES1))			;;When rising edge is done, next search for falling edge.

	rjmp 1f

pressed:
	rcall signal_start			;;When a button press is detected, routine begins searching for signal.
	ori r17, _BV(ICES1)			;; Looks for a rising edge.

1:
	sts TCCR1B, r17				;writes r17 to TCCR1B to activate
						;changes edge detection.

;;When button released, registers below are popped from stack.
debounce:
	pop r16
	out SREG, r16		;status register is restored.
	pop r17	;pops the registers from the stack
	pop r16	;to avoid accidentally calling the routines twice
	pop r10 ;as a result of the debounce

	reti

;; Tests if first signal is dot/dash or a new letter.
signal_start:
	tst r23
	breq clear		;; Keep display clear in the case when it is the first dot/dash.
	ret						;; Return to the previous routine.

;; Clears the display.
clear:
	ldi r18, ALL_SEGS				;; Load all segments of the 7segment display into r18.
	call load_to_display		;; Calls load_to_display routine.
	ret											;; Returns to the previous routine.


released:
	push r16			; Pushes r16 into stack.

	;; tests if there was a timer overflow.
	tst r19
	brne longpress				;; If r19 is set, signal is overflowed, therefore long signal is produced.
	ldi r16, SIGNAL_GAP
	cp r10,r16			;; Testing whether SIGNAL_GAP is larger than value stored in r10.
	brcs shortpress				;; If so, a dot is produced, so branch to shortpress (short press).

longpress:
	rjmp long_press		;; Jump to long_press routine.

shortpress:
	rjmp short_press	;; Jump to short_press routine.

;; resets load_to_display and loads new signal to the 7segment display.
load_to_display:
	clr r23				; clears the length of morse inputted
	clr r24				; clears the the sequence of morse inputs
								; both are done to allow a new input into the display.
	out PORTD, r18 ; loads the input in the register onto the 7segment display
ret
