#include "7segment.S"

	.global get_length

;; Gets length of signal input
get_length:
	cpi r23, 0x00	;; When signal length is 0
	breq 1f
	cpi r23, 0x01	;; When signal length is 1
	breq first_input	;; Branches to loop for inputs of length 1, repeats below as length increases.
	cpi r23, 0x02	;
	breq second_input	;
	cpi r23, 0x03	;
	breq third_input	;
	cpi r23, 0x04	;
	breq fourth_input	;
	rjmp error		; otherwise jump to error display

1:
	ret

	.global first_input

;; linking characters to their respective segments from 7segment.S
first_input:
	ldi r18, CHAR_E	; CHAR_E is one press (dot)
	cpi r24, 0x00	;; Compares register to hex value 0.
	breq 1f		; next routine.

	ldi r18, CHAR_T ;; CHAR_T is also one press (dash)
	cpi r24, 0x08	;; Compares input with the sequence.
	breq 1f		; next routine.

	rjmp error	; jump to error

1:
	ret

	.global second_input

;; the above routines apply for the remaining 3 length routines below.
second_input:

	ldi r18, CHAR_I
	cpi r24, 0x00
	breq 1f

	ldi r18, CHAR_A
	cpi r24, 0x04
	breq 1f

	ldi r18, CHAR_N
	cpi r24, 0x08
	breq 1f

	ldi r18, CHAR_M
	cpi r24, 0x0C
	breq 1f

	rjmp error

1:
	ret

	.global third_input

third_input:

	ldi r18, CHAR_D
	cpi r24, 0x08
	breq 1f

  ldi r18, CHAR_G
	cpi r24, 0x0C
	breq 1f

	ldi r18, CHAR_K
	cpi r24, 0x0A
	breq 1f

	ldi r18, CHAR_O
	cpi r24, 0x0E
	breq 1f

	ldi r18, CHAR_R
	cpi r24, 0x04
	breq 1f

	ldi r18, CHAR_S
	cpi r24, 0x00
	breq 1f

	ldi r18, CHAR_U
	cpi r24, 0x02
	breq 1f

	ldi r18, CHAR_W
	cpi r24, 0x06
	breq 1f

	rjmp error

1:
	ret

	.global fourth_input
fourth_input:
	ldi r18, CHAR_B
	cpi r24, 0x08
	breq 1f

	ldi 18, CHAR_C
	cpi r24, 0x0A
	breq 1f

	ldi r18, CHAR_F
	cpi r24, 0x02
	breq 1f

	ldi r18, CHAR_H
	cpi r24, 0x00
	breq 1f

	ldi r18, CHAR_J
	cpi r24, 0x07
	breq 1f

	ldi r18, CHAR_L
	cpi r24, 0x04
	breq 1f

	ldi r18, CHAR_P
	cpi r24, 0x06
	breq 1f

	ldi r18, CHAR_Q
	cpi r24, 0x0D
	breq 1f

	ldi r18, CHAR_V
	cpi r24, 0x01
	breq 1f

	ldi r18, CHAR_X
	cpi r24, 0x09
	breq 1f

	ldi r18, CHAR_Y
	cpi r24, 0x0B
	breq 1f

	ldi r18, CHAR_Z
	cpi r24, 0x0C
	breq 1f

	rjmp error

1:
	ret

	.global error
;; When inputs exceed 4 presses and/or inputs do not match the defined presses...
error:
	ldi r18, ERROR ; loads morse input for the error.
ret
