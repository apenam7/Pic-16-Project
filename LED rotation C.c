/*
 * File:   LED rotation C.c
 * Author: Ariel Pena-Martinez
 *
 * Created on April 24, 2019, 5:26 PM
 * 
 * This program should rotate the LEDs using both variable delay and direction.
 The delay and direction should be controlled by the on-board potentiometer, which is read by the
 analog to digital converter (ADC) on the microcontroller.
 When the arrow on the potentiometer is pointing straight up (toward the edge of the board where
 the PICkit3 programmer connects), the LEDs should not change at all. (Note that it may be
 difficult to determine this exact position.) If the arrow points to the left of that position, the LEDs
 should rotate left; if the arrow points to the right of that position, the LEDs should rotate right.
 The speed of rotation is dependent on how far from the center the arrow is, as shown below.
 Please note that “fast rotation” should still be slow enough that you can see the LEDs
 rotating—they shouldn’t change so fast that all lights appear to be on.
     
 In addition to using the potentiometer to control direction and speed of rotation, this exercise
 should use the switch to enable and disable rotation. If the switch is pressed while the LEDs are
 rotating, the system should pause in its current position, regardless of whether the ADC input
 value changes. If the switch is pressed while everything is paused, the system should resume
 rotating in the appropriate direction based on the ADC input value.
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



#define DOWN         0
#define UP           1

#define LED_RIGHT           1
#define LED_LEFT            0

#define SWITCH              PORTAbits.RA2

                                                   //PIC hardware mapping
#define _XTAL_FREQ 500000                                           //Used by the XC8 delay_ms(x) macro


#include <xc.h>

unsigned char adc(void);

void main(void) {
    unsigned char reading;
    unsigned int pause = 0;
    unsigned int press = 0;
    
    LATCbits.LATC3 = 1;
    OSCCON = 0b00111000;                 //500KHz clock speed
    TRISC = 0;                           //all LED pins are outputs

    LATC = 0b00001000;                    //start with DS4 lit
                                                    //setup switch (SW1)
    TRISAbits.TRISA2 = 1;                           //switch as input
    ANSELAbits.ANSA2 = 0;                           //digital switch

                                                    //setup ADC
    TRISAbits.TRISA4 = 1;                           //Potentiamtor is connected to RA4...set as input
    ANSELAbits.ANSA4 = 1;                           //analog
    ADCON0 = 0b00001101;                            //select RA4 as source of ADC and enable the module (AN3)
    ADCON1 = 0b00010000;                            //left justified - FOSC/8 speed - Vref is Vdd
    
    while(1){
    
        if (SWITCH == DOWN && press == 0) {
            __delay_ms(8);
            press = 1;
            pause ^= 1;
        }
        if (SWITCH == UP) {
            __delay_ms(8);
            press = 0;
        }
        
    if(pause == 0){                             //checks that the button hasnt been pressed
        reading = adc();
        
    if (reading >= 200) {
            __delay_ms(200);                    //delay half a second
            LATC <<= 1;                        //shift to the left by 1
            if(STATUSbits.C)                    //when the last LED is lit, restart the pattern
                LATCbits.LATC0 = 1;
    }


    if ((reading >= 140) && (reading < 200)) {
            __delay_ms(400);                   //delay 1 second
            LATC <<=  1;                        //shift to the left by 1
            if(STATUSbits.C)                    //when the last LED is lit, restart the pattern
                LATCbits.LATC0 = 1;
    }


    if (reading <=50) {
            __delay_ms(200);                    //delay half a second
            LATC >>=  1;                        //shift to the right by 1
            if(STATUSbits.C)                    //when the last LED is lit, restart the pattern
                LATCbits.LATC3 = 1;
    }


    if ((reading <= 100) && (reading > 50)) {  
            __delay_ms(400);                   //delay 1 second
            LATC >>=  1;                        //shift to the right by 1
            if(STATUSbits.C)                    //when the last LED is lit, restart the pattern
                LATCbits.LATC3 = 1;
    }
    }
    }
}

unsigned char adc(void) {
    __delay_us(5);                              //wait for ADC charging cap to settle
    GO = 1;
    while (GO) continue;                        //wait for conversion to be finished

    return ADRESH;                              //grab the top 8 MSbs

}