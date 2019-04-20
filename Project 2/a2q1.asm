;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;

		ldi r16, high(0x21ff) ; set up stack pointer to 0x21ff
		out SPH, r16
		ldi r16, low(0x21ff)
		out SPL, r16

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x13		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
		clr r18
		clr r19
		mov r17, r0	
			
		push r17
		andi r17,0x08 ;known portL bit1
		cpi r17, 0x08
		brne nothing1

		ldi r31, 0x02 ;add portL bit1
		add r18, r31
nothing1:
		pop r17

		push r17
		andi r17,0x04 ;know portL bit3
		cpi r17, 0x04
		brne nothing2

		ldi r31, 0x08 ;add portL bit3
		add r18, r31		
nothing2:
		pop r17

		push r17
		andi r17,0x02 ;know portL bit5
		cpi r17, 0x02
		brne nothing3

		ldi r31, 0x20 ;add portL bit5
		add r18, r31
nothing3:
		pop r17

		push r17
		andi r17,0x01 ;know portL bit7
		cpi r17, 0x01
		brne nothing4

		ldi r31, 0x80 ;add portL bit7
		add r18, r31
nothing4:		
		pop r17
		
		sts PORTL, r18 ; portL lights 

		push r17
		andi r17, 0x20 ;known portB bit1
		cpi r17, 0x20
		brne nothing5
		
		ldi r31, 0x02 ;add portB bit1
		add r19, r31
nothing5:
		pop r17

		push r17
		andi r17, 0x10 ;known portB bit3
		cpi r17, 0x10
		brne nothing6

		ldi r31, 0x08 ;add portB bit3
		add r19, r31
nothing6:
		pop r17

		out PORTB, r19 ; portB lights



;
; Don't change anything below here
;
done:	jmp done




