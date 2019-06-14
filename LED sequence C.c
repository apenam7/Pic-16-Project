/*
 * File:   LED sequence C.c
 * Author: Ariel Pena-Martinez
 *
 * This program should repeatedly go through the sequence below, showing each
 set of values on the LEDs for approximately one second before switching. A value of ?1?
 indicates the LED is on; a value of ?0? indicates the LED is off.
 0011-> 0001-> 0111 -> 1000 -> 1001 -> 0110 -> 0101 -> 1010 return to first step (0011)
 * Created on April 24, 2019, 12:58 PM
 */

// PIC16F1829 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTOSC    // Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
#pragma config WDTE = OFF       // Watchdog Timer Enable (WDT disabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable (PWRT disabled)
#pragma config MCLRE = OFF      // MCLR Pin Function Select (MCLR/VPP pin function is digital input)
#pragma config CP = OFF         // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = ON       // Brown-out Reset Enable (Brown-out Reset enabled)
#pragma config CLKOUTEN = OFF   // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = OFF       // Internal/External Switchover (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is disabled)

// CONFIG2
#pragma config WRT = OFF        // Flash Memory Self-Write Protection (Write protection off)
#pragma config PLLEN = OFF      // PLL Enable (4x PLL disabled)
#pragma config STVREN = OFF     // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will not cause a Reset)
#pragma config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
#pragma config LVP = OFF        // Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.


#include <xc.h>    
#define _XTAL_FREQ 500000 

const unsigned char sequ[] = {
    0b1100, 0b1000, 0b1110, 0b0001, 0b1001, 0b0110, 0b1010, 0b0101 //3,1,7,8,9,6,5,10 but reversed
            //for correct LED output
};


void main(void) {
   
    
    OSCCON = 0b00111000;    //500KHz clock speed
    TRISC = 0;             // led's as outputs

    
   
    while (1) {
           
            for(int i = 0; i <= 7;i++){
                LATC = sequ[i];         //each instruction is 8us (1/(500KHz/4))
                _delay(125000);
                }     
            }
    return;
}
