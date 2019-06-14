; *******************************************************************
; Program 2 - "Pushbutton counter"
;
; This program should count the number of times the pushbutton on the board has
; been pressed and display that count in binary using the LEDs, with the leftmost LED (DS1)
; displaying the most significant bit of the count.
; Note that, since there are only four LEDs, the maximum count value you can represent is 15.
; Once the count reaches 16, the LEDs should all reset to 0 and restart the count at that point.
;
; PIC: 16F1829
; Assembler: MPASM v5.43
; IDE: MPLABX v1.10
; Creator: Ariel Pena-Martinez
; Board: PICkit 3 Low Pin Count Demo Board
; Date: 04/24/2019

#include <p16F1829.inc>
     __CONFIG _CONFIG1, (_FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_OFF);
     __CONFIG _CONFIG2, (_WRT_OFF & _PLLEN_OFF & _STVREN_OFF & _LVP_OFF);

#define     SWITCH  PORTA, 2                    

    errorlevel -302               

    cblock 0x70                    
Delay1                          
     endc

    ORG 0       
    
Start:
                                        
    banksel         OSCCON             
    movlw           b'00111000'         ;Set clockspeed to 500 khz
    movwf           OSCCON                
    bsf             TRISA, RA2		;Initialize Switch
    banksel         ANSELA            
    bcf             ANSELA, RA2        
    banksel         TRISC		;Initialize LEDs
    clrf            TRISC              
    banksel         LATC               
    clrf            LATC               

    
MainLoop:
    clrw				;Reset working register
    movwf	    LATC		;Turn all LEDs off 
    call	    Debounce		;avoid errors from mechanical switch bounce
    call	    SwitchWait  
    movlw	    b'00001000'		;move backwards version of '0001'(binary 1) to working register
    movwf	    LATC		;display binary 1 on LEDs
    call	    Debounce		;Repeat for binary 2
    call	    SwitchWait
    movlw	    b'00000100'
    movwf	    LATC
    
    call	    Debounce		;Repeat for binary 3 through binary 15
    call	    SwitchWait
    movlw	    b'00001100'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000010'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001010'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000110'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001110'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000001'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001001'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000101'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001101'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000011'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001011'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00000111'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    movlw	    b'00001111'
    movwf	    LATC
    call	    Debounce
    call	    SwitchWait
    bra		    MainLoop

SwitchWait:
    banksel	    PORTA		   ;Keep checking switch until it is pressed
    btfss	    SWITCH
    return
    goto	    SwitchWait

Debounce:                              
    decfsz         Delay1,f		  ;Delay for around 6 ms
    goto           Debounce
DebounceLoop:
    decfsz          Delay1, f           ;1 instruction to decrement,unless if branching (ie Delay1 = 0)
    bra             DebounceLoop        ;2 instructions to branch
    banksel         PORTA               ;bank0
    btfsc           SWITCH              ;check if switch is still down. If not, skip the next instruction and simply return to recheck
    return     
    goto	    DebounceLoop
    end
