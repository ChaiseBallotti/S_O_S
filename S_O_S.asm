;
; S_O_S.asm
;
; Created: 9/16/2020 3:40:45 PM
; Author : Chaise Ballotti
; Purpose: Blink an LED on the board to signify SOS in Morse code

.def lc_250 = r22
.def lc_100ms = r23
.def lc_set = r24
.equ DOT = 3
.equ DASH = 6
.equ NXT_WORD = 12

start:                                  ; start of the program                         
    
          ; Set the stack pointer to the end of internal SRAM
          LDI       r16, LOW(RAMEND)
          OUT       SPL, r16
          LDI       R16, HIGH(RAMEND)
          OUT       SPH, r16

          ; force clock to 1mhz          
          ldi       r16,0b10000000      ; CLKPCE mask          
          sts       CLKPR,r16           ; enable clock prescaler change          
          ldi       r16,0b00000011      ; DIV8 mask          
          sts       CLKPR,r16           ; set clock prescaler to DIV8

          ldi       r16,0xff            ; Output mask
          out       DDRB,r16            ; set PORT-b to output
          
          eor       r0, r0              ; set led off
          ldi       r16,0b00100000      ; set portB bit 5

s_o_s:
          ldi       r30,6               ; repeate 6 times for s
          call      s_mores             ; 6 to toggle the state on 3 times and off 3 times
          
          ldi       lc_set,DOT          ; additional 3ms delay after letter
          call      delay_ms

          ldi       r30,6               ; repeate 6 times for o
          call      o_mores

          ldi       r30,6               ; repeate 6 times for s
          call      s_mores

          ldi       lc_set,NXT_WORD     ; 12ms delay after word ended
          call      delay_ms

          rjmp      s_o_s

s_mores:
          eor       r0,r16              ; toggle led state on
          out       portb,r0            ; set port
          ldi       lc_set,DOT          ; set delay time
          call      delay_ms            ; call to delay

          dec       r30
          brne      s_mores
          ret

o_mores:
          eor       r0,r16              ; toggle led state on
          out       portb,r0            ; set port
          ldi       lc_set,DASH          ; set delay time
          call      delay_ms            ; call to delay

          dec       r30
          brne      o_mores
          ret
          
delay_ms:
          ldi       lc_100ms,80
delay_100ms:
          ldi       lc_250,250
delay_250:
          nop                           ;                   1 cycle
          nop                           ;                   1 cycle
          dec       lc_250              ;                   1 cycle
          brne      delay_250           ;                   2 cycle = 5 cycle * 250 ~ 1.250 ms

          dec       lc_100ms            ; dec 80 times for 100ms loop
          brne      delay_100ms         ; call to reset 250 loop        

          dec       lc_set              ; hold multiplyer for deisered time delay
          brne      delay_ms            ; call to reset the entire 100ms loop

          ret                           ; return from subrutine

