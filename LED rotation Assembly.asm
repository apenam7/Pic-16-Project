; *******************************************************************
; Program 3 - "LED rotation"
;
; This program should rotate the LEDs using both variable delay and direction.
; The delay and direction should be controlled by the on-board potentiometer, which is read by the
; analog to digital converter (ADC) on the microcontroller.
; When the arrow on the potentiometer is pointing straight up (toward the edge of the board where
; the PICkit3 programmer connects), the LEDs should not change at all. (Note that it may be
; difficult to determine this exact position.) If the arrow points to the left of that position, the LEDs
; should rotate left; if the arrow points to the right of that position, the LEDs should rotate right.
; The speed of rotation is dependent on how far from the center the arrow is, as shown below.
; Please note that “fast rotation” should still be slow enough that you can see the LEDs
; rotating—they shouldn’t change so fast that all lights appear to be on.
     
; In addition to using the potentiometer to control direction and speed of rotation, this exercise
; should use the switch to enable and disable rotation. If the switch is pressed while the LEDs are
; rotating, the system should pause in its current position, regardless of whether the ADC input
; value changes. If the switch is pressed while everything is paused, the system should resume
; rotating in the appropriate direction based on the ADC input value.
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
    
#define	    PULL_UPS

errorlevel -302			;supress the 'not in bank0' warning
cblock	0x70			;shared memory location that is accessible from all banks
    
    Skip			; Determines the state of the machine
    Potentiometer		; Holds the ADC value of the potentiometer
    Temp			; Temporary holding variable for calculations
    Delay1			; Outer delay loop variable
    Delay2			; Inner delay loop variable
endc
    
    org	    0x0			; Start normal operation at 0x0
    bra	    Start
    org	    0x0004		; When interrupt condition happens, goto ISR
    goto    ISR

Start:
    banksel OSCCON		; Set the clock speed to 500 kHz
    movlw   b'00111000'
    movwf   OSCCON

    bsf	    TRISA, 2		; Set the button pin as an input
    bsf	    TRISA, 4		;Potentiometor is connected to RA4....set as input
    
    movlw   b'00001101'         ; Bit 0 - Turn on ADC module
    movwf   ADCON0		; Bits 2-6 - Select channel - AN3 = RA4
    movlw   b'00010000'         ; Left justified - Speed = Fosc/8- Vref = Vdd
    movwf   ADCON1

    banksel ANSELA
    bcf	    ANSELA, RA2         ; Set button as digital input
    bsf	    ANSELA, RA4		; Set potentiometer as analog input
    
    bsf	    INTCON, IOCIE	; Set interrupt-on-change for the switch
    banksel IOCAN
    bsf	    IOCAN,  IOCAN2
    bsf	    INTCON, GIE

    banksel TRISC		; Set the LEDs' pins as outputs
    clrf    TRISC

    banksel LATC		; Start with DS4 on
    movlw   b'00001000'
    movwf   LATC
    
#ifdef PULL_UPS
    banksel WPUA		; Enable weak pull up for the swtich
    bsf	    WPUA, 2
    banksel OPTION_REG		; Enable the global weak pull up bit
    bcf	    OPTION_REG, NOT_WPUEN
#endif
    
    clrf    Skip		; Initializing the variables to 0
    clrf    Potentiometer			
    clrf    Temp		
    clrf    Delay1		
    clrf    Delay2		

MainLoop:
    movlw   d'255'		; Delay2 = 255
    movwf   Delay2
    call    Catch		; Catch button press
    
A2d:
    nop				; Necessary 8 us delay for ADC to turn on
    banksel ADCON0
    bsf	    ADCON0, GO		; Turn on the ADC
    btfsc   ADCON0, GO
    goto    $-1			; Wait for the ADC to be done turning on
    movf    ADRESH, W
    movwf   Potentiometer	; Pot = Upper 8 bits of ADC reading

CheckLeft:
    movlw   0x70		; Checking if the potentiometer has been turned
    subwf   Potentiometer, W	; left (counter-clockwise) by checking if the 
    btfsc   STATUS, Z		; ADC returned less than 0x70
    bra	    MainLoop
    btfss   STATUS, C
    goto    RotateLeft

CheckRight:
    movlw   0x8F		; Checking if the potentiometer has been turned
    subwf   Potentiometer, W	; right (clockwise) by checking if the ADC
    btfsc   STATUS, Z		; returned greater than 0x8F
    bra	    MainLoop
    btfss   STATUS, C
    bra	    MainLoop

RotateRight:
    call    Catch		; Catch button press
    
    call    DelayRight		; Calculate and execute the delay time between
				; LED changes
    call    Catch		; Catch button press
    
    banksel LATC		; Rotate the LEDs right by executing a left 
    lslf    LATC, F		; shift since the LEDs are installed backwards
    btfsc   LATC, 4		; to the bit positions
    bsf	    LATC, 0		; Effectively using a modulo 16 to keep the 1
    bra	    MainLoop		; within the first 4 bits

DelayRight:
    movlw   0x77
    movwf   Delay1
    movf    Potentiometer, W
    movwf   Temp
    movlw   0x90
    subwf   Temp, W		; Temp = Pot - 90
    subwf   Delay1, F		; Delay1 = 0x77 - (Pot - 0x90)
    lslf    Delay1, F		; Delay1 = Delay1 * 2
    bra	    DelayLoop		; Multiply the outer loop for a more human-
				; friendly rotation speed
RotateLeft:
    call    Catch		; Catch button press
    
    call    DelayLeft		; Calculate and execute the delay time between
				; LED changes
    call    Catch		; Catch button press
    
    banksel LATC		; Rotate the LEDs right by executing a left 
    bcf	    STATUS, C		; shift since the LEDs are installed backwards
    rrf	    LATC, F		; to the bit positions
    btfsc   STATUS, C
    bsf	    LATC, 3		; Effectively using a modulo 16 to keep the 1
    bra	    MainLoop		; within the first 4 bits
    
DelayLeft:
    movf    Potentiometer, W	; Delay1 = Potentiometer
    movwf   Delay1		; Delay1 = Delay1 * 2
    lslf    Delay1, F		; Multiply the outer loop for a more human-
				; friendly rotation speed
DelayLoop:
    decfsz  Delay2, F		; Inner loop
    bra	    DelayLoop
    decfsz  Delay1, F		; Outer loop
    bra	    DelayLoop
				; Slowest speed, T = (4/500k)*(3*255)*(2*0x70)
    return			; = 1.37088 s

Catch:
    clrw			; Determine if the machine is in a skip state
    subwf   Skip, W		; If Skip is 1, the machine is ultimately doing
    btfss   STATUS, Z		; nothing.  This parcel of code will be repeated
    goto    MainLoop
    return
    
Debounce:
    movlw   d'208'		; T = (4/500k)*(208*3) = 4.992 ms
    movwf   Delay1

DebounceLoop:
    decfsz  Delay1, F		; Decrement variable until it has reached 0
    bra	    DebounceLoop  
    return
    
ISR:
    banksel IOCAF		; Clear the interrupt-on-change flag register
    clrf    IOCAF		; since only one interrupt is being utilized
    
    call    Debounce		; Debounce the button when it has been pressed

    comf    Skip, F		; Toggle skip variable
    retfie			; Return to program from interrupt state

end
