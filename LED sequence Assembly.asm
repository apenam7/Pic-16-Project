; *******************************************************************
; Program 1 - "LED sequence"
;
; This program should repeatedly go through the sequence below, showing each
; set of values on the LEDs for approximately one second before switching. A value of ?1?
; indicates the LED is on; a value of ?0? indicates the LED is off.
; 0011? 0001? 0111 ? 1000 ? 1001 ? 0110 ? 0101 ? 1010 return to first step (0011)
;
;
; PIC: 16F1829
; Assembler: MPASM v5.43
; IDE: MPLABX v1.10
;
; Board: PICkit 3 Low Pin Count Demo Board
; Date: 04/24/2019

#include <p16F1829.inc>

     __CONFIG _CONFIG1, (_FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_OFF);
     __CONFIG _CONFIG2, (_WRT_OFF & _PLLEN_OFF & _STVREN_OFF & _LVP_OFF);

    errorlevel -302                     ;suppress the 'not in bank0' warning
    cblock 0x70                         ;shared memory location that is accessible from all banks
Delay1                                  ;Define two file registers for the delay loop in shared memory
Delay2         
     endc

    ; -------------------LATC-----------------
    ; Bit#:  -7---6---5---4---3---2---1---0---
    ; LED:   ---------------|DS4|DS3|DS2|DS1|-
    ; -----------------------------------------

    ORG 0
Start:
     banksel        OSCCON		    ;bank1
     movlw          b'00111000'		    ;set cpu clock speed of 500KHz ->correlates to (1/(500K/4)) for each instruction
     movwf          OSCCON		    ;move contents of the working register into OSCCON
     clrf           TRISC		    ;Initialize LEDs all at zero
     banksel        LATC              	
     movlw          b'00001100'		    ;Set first LED configuration
     movwf          LATC               
MainLoop:
     call	    OneSecDelay		    ;pause for 1 second
     movlw	    b'00001000'		    ;Set second LED configuation
     movwf	    LATC
     call	    OneSecDelay		    ;Repeat for other LED configuations in sequence
     movlw	    b'00001110'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00000001'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00001001'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00000110'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00001010'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00000101'
     movwf	    LATC
     call	    OneSecDelay
     movlw	    b'00001100'
     movwf	    LATC
     bra	    MainLoop		; do it again?..

OneSecDelay:
     movlw	    d'162'		;set delay outerloop to 162 loops
     movwf	    Delay2
OneSecDelayLoop:
     decfsz         Delay1,f		;delay innerloop is 255 loops, around 6ms
     bra            OneSecDelayLoop   ;(4/500k)*(255*3) = 6 ms
     decfsz         Delay2,f		;delay outerloop is 6ms * 162 loops = 0.9s, around 1 second total
     bra            OneSecDelayLoop    
     return
    
    end                  
