/*
 * a4.c
 *
 * Created: 12/1/2018 4:53:46 PM
 * Author : xiaoqingzhang
 */ 

#include <avr/io.h>


/*
 * a4.c
 *
 * Created: 11/27/2018 3:42:21 PM
 * Author : xiaoqingzhang
 */ 

#include "CSC230.h"

#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316



unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}


char *j; //pointer
void short_to_hex1(unsigned short v, char* str){
	if(j>17){
		j=0;//set pointer back
	}
	char hex_chars[] = "hello world abcde;";
	int k=j;//k copy from the pointer position
	int i;
	for(i=0;i<16;i++){
		if (k>17){
			k=0;
		}		
		str[i]=hex_chars[k];
		k++;
	}
	str[16]='\0';	
	j++;
		
}

char *n; //pointer
void short_to_hex2(unsigned short v, char* str){
	char hex_chars[] = "hello last assignment;";
	if(n>21){
		n=0;//set pointer back
	}
	int l = n;//l copy from the pointer position
	int i;
	for(i=0;i<16;i++){
		if (l>21){
			l=0;
		}
		str[i]=hex_chars[l];			
		l++;
	}
	str[16]='\0';
	n++;
		
}

int main(){
	
	//ADC Set up
	ADCSRA = 0x87;
	ADMUX = 0x40;

	lcd_init();
	
	
	int a=1;
	while(1){
		
			
			unsigned short adc_result = poll_adc();
			if(adc_result>=ADC_BTN_RIGHT&&adc_result<ADC_BTN_UP){
				a=0;  // Up button pause
			}else if(adc_result>=ADC_BTN_UP&&adc_result<ADC_BTN_DOWN) {
				a=1; //Down button resume 
			}else if(adc_result>=ADC_BTN_DOWN&&adc_result<ADC_BTN_LEFT) {
				a=2; //increase speed 
			}else if(adc_result<ADC_BTN_RIGHT) {
				a=3; //decrease speed 
			}
		
			
			if(a==1){
				char s[17];
				short_to_hex1(adc_result,s);
				lcd_xy(0,0);
				lcd_puts(s);
		
				char m[17];
				short_to_hex2(adc_result,m);
				lcd_xy(0,1);
				lcd_puts(m);
				_delay_ms(500);
			}
			if(a==2){
				char s[17];
				short_to_hex1(adc_result,s);
				lcd_xy(0,0);
				lcd_puts(s);
				
				char m[17];
				short_to_hex2(adc_result,m);
				lcd_xy(0,1);
				lcd_puts(m);
				_delay_ms(250);
			}
			if(a==3){
				char s[17];
				short_to_hex1(adc_result,s);
				lcd_xy(0,0);
				lcd_puts(s);
				
				char m[17];
				short_to_hex2(adc_result,m);
				lcd_xy(0,1);
				lcd_puts(m);
				_delay_ms(1000);
			}
		}
			
	return 0;			
			
}


