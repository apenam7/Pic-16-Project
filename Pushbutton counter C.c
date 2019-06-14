/*
 * File:   Pushbutton counter C.c
 * Author: Ariel Pena-Martinez
 *
 * This program should count the number of times the pushbutton on the board has
 been pressed and display that count in binary using the LEDs, with the leftmost LED (DS1)
 displaying the most significant bit of the count.
 Note that, since there are only four LEDs, the maximum count value you can represent is 15.
 Once the count reaches 16, the LEDs should all reset to 0 and restart the count at that point.
 
 * Created on April 24, 2019, 4:30 PM
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
#pragma config LVP = ON        // Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.





#define DOWN        0
#define UP          1
#define SWITCH      PORTAbits.RA2
#define LED         LATCbits.LATC0

#define _XTAL_FREQ 500000       //Used by the XC8 delay_ms(x) macro

#include <xc.h>

void main(void) {
   
    OSCCON = 0b00111000;                              //500KHz clock speed
    TRISC = 0;                                        //all LED pins are outputs
    LATC = 0;
    int i =0;                                           //start with all LEDs OFF
                                                       //setup switch (SW1)
    TRISAbits.TRISA2 = 1;                             //switch as input
    ANSELAbits.ANSA2 = 0;                             //digital switch
    const unsigned char counter[] = {0b0000, 0b1000, 0b0100, 0b1100, 0b0010, 0b1010, 0b0110, 0b1110,
            0b0001, 0b1001, 0b0101, 0b1101, 0b0011, 0b1011, 0b0111, 0b1111};
    while (1)
     { 
        if (SWITCH == DOWN)
            { 
            __delay_ms(200);
            i++;
         
            LATC = counter[i];
            if(i==16)
                {
                    i=0;
                    LATC=0b0000;
                }
            }
        
     }
}
