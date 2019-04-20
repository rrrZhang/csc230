;
; a2q3.asm
;
; Write a main program that increments a counter when the buttons are pressed
;
; Use the subroutine you wrote in a2q2.asm to solve this problem.
;
		
		ldi r16, high(0x21ff) ; set up stack pointer to 0x21ff
		out SPH, r16
		ldi r16, low(0x21ff)
		out SPL, r16

		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

; Your code here
; make sure your code is an infinite loop
		ldi r16,0x00
		mov r0, r16
start:
		call check_button
		cpi r24,0x01
		brne nopress	
		inc r0
		ldi r20, 0x40
		lsr r20
		lsr r20
		call delay
nopress:
		call display
		jmp start


done:		jmp done		; if you get here, you're doing it wrong

;
; the function tests to see if the button
; UP or SELECT has been pressed
;
; on return, r24 is set to be: 0 if not pressed, 1 if pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; This function could be made much better.  Notice that the a2d
; returns a 2 byte value (actually 12 bits).
; 
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
;
; This function 'cheats' because I observed
; that ADCH is 0 when the right or up button is
; pressed, and non-zero otherwise.
; 
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		clr r24
		cpi r17, 0
		brne skip

		ldi r25,0xc3 ;up low 
		cp r16,r25 ;compare up low
		brsh skip ; if higher than c3, then it;s down button pressed
	
		ldi r24,0x01
skip:	ret

;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; this function uses registers:
;
;	r20
;	r21
;	r22
;
delay:	
del1:		nop
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret

;
; display
;
; copy your display subroutine from a2q2.asm here
 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;	r17 - value to write to PORTL
;	r18 - value to write to PORTB
;
;   r16 - scratch
display:
		clr r18
		clr r19
		mov r17, r0	
			
		push r17
		andi r17,0x08 ;known portL bit1
		cpi r17, 0x08
		brne nothing1

		ldi r16, 0x02 ;add portL bit1
		add r18, r16
nothing1:
		pop r17

		push r17
		andi r17,0x04 ;know portL bit3
		cpi r17, 0x04
		brne nothing2

		ldi r16, 0x08 ;add portL bit3
		add r18, r16		
nothing2:
		pop r17

		push r17
		andi r17,0x02 ;know portL bit5
		cpi r17, 0x02
		brne nothing3

		ldi r16, 0x20 ;add portL bit5
		add r18, r16
nothing3:
		pop r17

		push r17
		andi r17,0x01 ;know portL bit7
		cpi r17, 0x01
		brne nothing4

		ldi r16, 0x80 ;add portL bit7
		add r18, r16
nothing4:		
		pop r17
		
		push r17
		mov r17, r18
		sts PORTL, r17 ; portL lights 
		pop r17

		push r17
		andi r17, 0x20 ;known portB bit1
		cpi r17, 0x20
		brne nothing5
		
		ldi r16, 0x02 ;add portB bit1
		add r19, r16
nothing5:
		pop r17

		push r17
		andi r17, 0x10 ;known portB bit3
		cpi r17, 0x10
		brne nothing6

		ldi r16, 0x08 ;add portB bit3
		add r19, r16
nothing6:
		pop r17

		mov r18, r19
		out PORTB, r18 ; portB lights

		ret



