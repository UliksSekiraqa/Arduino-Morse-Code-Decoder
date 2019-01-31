.global long_press
;; Counts position of long presses, compares to hex values.
long_press:
	inc r23			;; Increments the counter.
	cpi r23, 0x01	;; Compares counter to 1
	breq Long_Press_1		;; First signal.
	cpi r23, 0x02	;; Compares counter to 2.
	breq Long_Press_2		;; Second signal.
	cpi r23, 0x03	;; Compares counter to 3
	breq Long_Press_3		;; Third signal.
	cpi r23, 0x04	;; Compares counter to 4
	breq Long_Press_4		;; Fourth signal.
	rjmp 1f			;; Cannot be longer than 4 inputs, morse only takes 4 inputs.

	.global Long_Press_1
Long_Press_1:
	ori r24, 0x08	;; Record a dash in the first position.
	rjmp 1f ; jumps back to the inputs routines, repeated with all presses.

	.global Long_Press_2
Long_Press_2:
	ori r24, 0x04	;; Dash in second position.
	rjmp 1f

	.global Long_Press_3
Long_Press_3:
	ori r24, 0x02	;; Dash in third position.
	rjmp 1f

	.global Long_Press_4
Long_Press_4:
	ori r24, 0x01	;; Dash in fourth position.
	rjmp 1f

	.global short_press

;; Counts position of short presses, compares to hex values.
short_press:
	inc r23			;; Increment the press (signal) counter.
	cpi r23, 0x01	;; If counter = 1,
	breq Short_Press_1		;; It is the first signal.
	cpi r23, 0x02	;; If counter = 2,
	breq Short_Press_2		;; It is the second signal.
	cpi r23, 0x03	;; If counter = 3,
	breq Short_Press_3		;; It is the third signal.
	cpi r23, 0x04	;; If counter = 4,
	breq Short_Press_4		;; It is the third signal.
	rjmp 1f			;; Cannot be longer than 4, morse code only takes 4 inputs

	.global Short_Press_1
Short_Press_1:
	ori r24, 0x00	;; Records a dot.
	rjmp 1f			; jumps back to the inputs routines, repeated with all presses.

	.global Short_Press_2
Short_Press_2:
	ori r24, 0x00	;; Records a dot on 2nd input.
	rjmp 1f

	.global Short_Press_3
Short_Press_3:
	ori r24, 0x00	;; Records a dot on 3rd input.
	rjmp 1f

	.global Short_Press_4
Short_Press_4:
	ori r24, 0x00	;; Records a dot on 4th input.
	rjmp 1f			;; Like with short_press, cannot be longer than 4 - only 4 inputs possible.

1:
	pop r16			;; Pops r16 from the stack
	clr r19			;; Clears r19 from the timer overflow
	ret			;; Return to previous method.
