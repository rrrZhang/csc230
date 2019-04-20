;
; a2q4.asm
;
; Fix the button subroutine program so that it returns
; a different value for each button
;
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		ldi r16, high(0x21ff) ; set up stack pointer to 0x21ff
		out SPH, r16
		ldi r16, low(0x21ff)
		out SPL, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

		clr r0
		call display
lp:
		call check_button
		tst r24
		breq lp
		mov	r0, r24

		call display
		ldi r20, 99
		call delay
		ldi r20, 0
		mov r0, r20
		call display
		rjmp lp

;
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r24
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

		; put your new logic here:
		clr r24
		ldi r29, 0x32 ;right low
		ldi r28, 0x00 ;right high

		ldi r27,0xc3 ;up low
		ldi r26, 0x00 ;up high

		ldi r25,0x7c ;down low
		ldi r23, 0x01 ;down high

		ldi r22,0x2b ;left low
		ldi r21, 0x02 ;left high

		ldi	r31, 0x16 ;select low
		ldi	r30, 0x03 ;select high

		cp r16,r29 ;compare right low
		cpc r17,r28 ;compare right high
		brlo right

		cp r16,r27 ;compare up low
		cpc r17,r26 ;compare up high
		brlo up
	
		cp r16,r25 ;compare down low
		cpc r17,r23 ;compare down high
		brlo down
	
		cp r16,r22 ;compare left low
		cpc r17,r21 ;compare left high
		brlo left
	
		cp r16,r31 ;compare select low
		cpc r17,r30 ;compare select high
		brlo select
		jmp back

right:  ldi r24,0x01
		jmp back
up:		ldi r24,0x02
		jmp back
down:	ldi r24,0x04
		jmp back
left:	ldi r24,0x08
		jmp back
select:	ldi r24,0x10
back:
		
		ret

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
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		; copy your code from a2q2.asm here
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

		ret

