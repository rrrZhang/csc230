#define LCD_LIBONLY
.include "lcd.asm"


.cseg
		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		ldi r16, high(0x21ff) ; set up stack pointer to 0x21ff
		out SPH, r16
		ldi r16, low(0x21ff)
		out SPL, r16


	call lcd_init ; call lcd_init to Initialize the LCD
	call lcd_clr ; clear up the led
	call init_strings ; copy the strings from program to data memory
	call set_pointer ; set l1ptr and l2ptr to point at the start of the display strings
	ldi r18,1
	ldi r24,0x20
loop_forever:
	call check_button
	cpi r18,1
	brne loop_forever
	call clear_line1_line2
	call display_strings
	call copy
	call display_strings
	call move_pointers
	mov r20, r24
	call delay
	jmp loop_forever

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
		ldi r29, 0x32 ;right low
		ldi r28, 0x00 ;right high
		cp r16,r29 ;compare right low
		cpc r17,r28 ;compare right high
		brlo right

		ldi r29,0xc3 ;up low
		ldi r28, 0x00 ;up high
		cp r16,r29 ;compare up low
		cpc r17,r28 ;compare up high
		brlo up

		ldi r29,0x7c ;down low
		ldi r28, 0x01 ;down high
		cp r16,r29 ;compare down low
		cpc r17,r28 ;compare down high
		brlo down

		ldi r29,0x2b ;left low
		ldi r28, 0x02 ;left high
		cp r16,r29 ;compare left low
		cpc r17,r28 ;compare left high
		brlo left

		ldi	r29, 0x16 ;select low
		ldi	r28, 0x03 ;select high
		cp r16,r29 ;compare select low
		cpc r17,r28 ;compare select high
		brlo select
		jmp back

right:  ldi r24,0x10; increase
		jmp back
				
up:		ldi r18,0 ;pause
		jmp back

down:	ldi r18,1
		jmp back

left:	ldi r24,0x60;decrease
		jmp back

select:	ldi r24,0x20
		jmp back

back: ret



display_strings:
	push r16
	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16

	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display line2 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret



move_pointers:
	push ZH
	push ZL
	push r16
	lds ZH, (l1ptr+1)
	lds ZL, (l1ptr)
	
	adiw ZH:ZL,1 
	ld r16, Z
	cpi r16,0
	breq point_at_end1

	sts l1ptr, ZL
	sts (l1ptr+1), ZH
	jmp pointer2

point_at_end1:
	push r17
	ldi r17, high(msg1)
	sts (l1ptr+1), r17
	ldi r17, low(msg1)
	sts l1ptr,r17
	pop r17


pointer2:
	lds ZL, l2ptr
	lds ZH, (l2ptr+1)
	
	adiw ZL,1 
	ld r16, Z
	cpi r16,0
	breq point_at_end2

	sts l2ptr, ZL
	sts (l2ptr+1), ZH
	jmp end_move

point_at_end2:
	push r17
	ldi r17, high(msg2)
	sts (l2ptr+1), r17
	ldi r17, low(msg2)
	sts l2ptr,r17
	pop r17

end_move:
	pop r16
	pop ZH
	pop ZL
	ret


copy:
	push XH
	push XL
	push ZH
	push ZL
	lds ZH, (l1ptr+1)
	lds ZL, (l1ptr)
	ldi XH, high(line1)
	ldi XL, low(line1)
	push r17
	push r18
	ldi r18,16
str_copy_loop1:
	ld r17,Z+
	cpi r17,0
	breq str_copy_zero_found1
	st X+,r17
	dec r18
	cpi r18,0
	breq done_copy1	
	jmp str_copy_loop1
str_copy_zero_found1:
	ldi ZH, high(msg1)
	ldi ZL, low(msg1)
	jmp str_copy_loop1
done_copy1:
	pop r18
	pop r17
	pop ZL
	pop ZH
	pop XL
	pop XH	



	push XH
	push XL
	push ZH
	push ZL
	lds ZH, (l2ptr+1)
	lds ZL, (l2ptr)
	ldi XH, high(line2)
	ldi XL, low(line2)
	push r17
	push r18
	ldi r18,16	
str_copy_loop2:
	ld r17,Z+
	cpi r17,0
	breq str_copy_zero_found2
	st X+,r17
	dec r18
	cpi r18,0
	breq done_copy2	
	jmp str_copy_loop2
str_copy_zero_found2:
	ldi ZH, high(msg2)
	ldi ZL, low(msg2)
	jmp str_copy_loop2
done_copy2:
	pop r18
	pop r17
	pop ZL
	pop ZH
	pop XL
	pop XH	
	ret



set_pointer:
	push r16
	ldi r16, high(msg1)
	sts (l1ptr+1), r16
	ldi r16, low(msg1)
	sts l1ptr,r16
	pop r16

	push r16
	ldi r16, high(msg2)
	sts (l2ptr+1), r16
	ldi r16, low(msg2)
	sts l2ptr,r16
	pop r16
	ret



clear_line1_line2:
	push XH
	push XL
	push r16
	push r31
	ldi XH, high(line1)
	ldi XL, low(line1)
	ldi r16,' '
	ldi r31, 16
loop1:
	st X+, r16	
	dec r31
	cpi r31,0
	brne loop1
	pop r31
	pop r16
	pop XL
	pop XH

	push XH
	push XL
	push r16
	push r31
	ldi XH, high(line2)
	ldi XL, low(line2)
	ldi r16,' '
	ldi r31, 16
loop2:
	st X+, r16	
	dec r31
	cpi r31,0	
	brne loop2
	pop r31
	pop r16
	pop XL
	pop XH
	ret

init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret



delay:

del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1
		
		ret




msg1_p:	.db "01230123012301230123.", 0	
msg2_p: .db "hell.", 0

.dseg
; *****  !!!!WARNING!!!!  *****
; Do NOT put a .org directive here.  The
; LCD library does that for you.
; *****  !!!!WARNING!!!!  *****
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

line1:  .byte 17
line2:  .byte 17

l1ptr:  .byte 2
l2ptr:  .byte 2