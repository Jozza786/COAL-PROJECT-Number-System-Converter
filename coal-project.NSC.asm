; NUMBER SYSTEM CONVERTER - 8086 Assembly Language
; Members : Jozza | Zarnaina | Adeena
; Tool    : EMU8086 | Spring 2026

.model small
.stack 100h

.data
    w1  db '  ==========================================', 13, 10, '$'
    w2  db '  =     NUMBER  SYSTEM  CONVERTER         =', 13, 10, '$'
    w3  db '  =   Jozza  |  Zarnaina  |  Adeena      =', 13, 10, '$'
    w4  db '  =     COAL Project  -  Spring 2026      =', 13, 10, '$'
    w5  db '  ==========================================', 13, 10, '$'
    m0  db 13, 10, '$'
    m1  db '  +----------------------------------------+', 13, 10, '$'
    m2  db '  |  [1]  Decimal     to  Binary           |', 13, 10, '$'
    m3  db '  |  [2]  Decimal     to  Hexadecimal      |', 13, 10, '$'
    m4  db '  |  [3]  Decimal     to  Octal            |', 13, 10, '$'
    m5  db '  |  [4]  Binary      to  Decimal          |', 13, 10, '$'
    m6  db '  |  [5]  Hex         to  Decimal          |', 13, 10, '$'
    m7  db '  |  [6]  Exit                             |', 13, 10, '$'
    m8  db '  +----------------------------------------+', 13, 10, '$'
    m9  db 13, 10, '  Your choice: $'
    inp_dec db 13, 10, '  Enter decimal number (0-255): $'
    inp_bin db 13, 10, '  Enter binary number (only 0s and 1s): $'
    inp_hex db 13, 10, '  Enter hex number (0-9, A-F): $'
    inp_end db 13, 10, '  Press ENTER when done.', 13, 10, '$'
    rb  db 13, 10, '  Binary      result : $'
    rh  db 13, 10, '  Hex         result : $'
    ro  db 13, 10, '  Octal       result : $'
    rd  db 13, 10, '  Decimal     result : $'
    err db 13, 10, '  Invalid! Press 1-6 only.', 13, 10, '$'
    bye db 13, 10, '  Thank you! Goodbye :)', 13, 10, '$'
    pr2 db 13, 10, '  Press any key to return to menu...', 13, 10, '$'
    num   db 0
    digit db 0

.code

clear_screen PROC
    mov  ax, 0003h
    int  10h
    ret
clear_screen ENDP

print_newline PROC
    mov  ah, 9
    lea  dx, m0
    int  21h
    ret
print_newline ENDP

wait_key PROC
    mov  ah, 9
    lea  dx, pr2
    int  21h
    mov  ah, 1
    int  21h
    ret
wait_key ENDP

; FAST print - uses DOS INT 21h AH=9 (no color, instant)
print_fast PROC
    mov  ah, 9
    int  21h
    ret
print_fast ENDP

; COLORED print - char by char via BIOS (used for results only)
print_str_col PROC
    push si
    push ax
    push bx
    mov  si, dx
psc_loop:
    mov  al, [si]
    cmp  al, '$'
    je   psc_done
    cmp  al, 13
    je   psc_special
    cmp  al, 10
    je   psc_special
    mov  ah, 09h
    mov  bh, 0
    mov  cx, 1
    int  10h
    mov  ah, 0Eh
    int  10h
    inc  si
    jmp  psc_loop
psc_special:
    mov  ah, 2
    mov  dl, al
    int  21h
    inc  si
    jmp  psc_loop
psc_done:
    pop  bx
    pop  ax
    pop  si
    ret
print_str_col ENDP

; prints ONE char in AL with color in BL (used for result digits only)
print_char_col PROC
    push bx
    push cx
    mov  ah, 09h
    mov  bh, 0
    mov  cx, 1
    int  10h
    mov  ah, 0Eh
    int  10h
    pop  cx
    pop  bx
    ret
print_char_col ENDP

; welcome uses FAST print - instant display
show_welcome PROC
    call clear_screen
    call print_newline
    lea  dx, w1
    call print_fast
    lea  dx, w2
    call print_fast
    lea  dx, w3
    call print_fast
    lea  dx, w4
    call print_fast
    lea  dx, w5
    call print_fast
    ret
show_welcome ENDP

; menu uses FAST print - instant display
show_menu PROC
    call print_newline
    lea  dx, m1
    call print_fast
    lea  dx, m2
    call print_fast
    lea  dx, m3
    call print_fast
    lea  dx, m4
    call print_fast
    lea  dx, m5
    call print_fast
    lea  dx, m6
    call print_fast
    lea  dx, m7
    call print_fast
    lea  dx, m8
    call print_fast
    lea  dx, m9
    call print_fast
    ret
show_menu ENDP

; prompts use FAST print
read_decimal PROC
    lea  dx, inp_dec
    call print_fast
    lea  dx, inp_end
    call print_fast
    mov  num, 0
rd_loop:
    mov  ah, 1
    int  21h
    cmp  al, 13
    je   rd_done
    cmp  al, '0'
    jl   rd_loop
    cmp  al, '9'
    jg   rd_loop
    sub  al, '0'
    mov  digit, al
    mov  al, num
    mov  bl, 10
    mul  bl
    add  al, digit
    mov  num, al
    jmp  rd_loop
rd_done:
    ret
read_decimal ENDP

; result label fast, result digits YELLOW colored
dec_to_binary PROC
    lea  dx, rb
    call print_fast
    mov  al, num
    mov  ah, 0
    mov  cx, 0
    cmp  al, 0
    jne  dtb_loop
    mov  bl, 0Eh
    mov  al, '0'
    call print_char_col
    jmp  dtb_done
dtb_loop:
    cmp  al, 0
    je   dtb_print
    mov  bl, 2
    div  bl
    push ax
    inc  cx
    mov  ah, 0
    jmp  dtb_loop
dtb_print:
    pop  ax
    add  ah, '0'
    mov  al, ah
    mov  bl, 0Eh
    push cx
    call print_char_col
    pop  cx
    dec  cx
    jnz  dtb_print
dtb_done:
    call wait_key
    ret
dec_to_binary ENDP

dec_to_hex PROC
    lea  dx, rh
    call print_fast
    mov  al, num
    mov  ah, 0
    mov  cx, 0
    cmp  al, 0
    jne  dth_loop
    mov  bl, 0Eh
    mov  al, '0'
    call print_char_col
    jmp  dth_done
dth_loop:
    cmp  al, 0
    je   dth_print
    mov  bl, 16
    div  bl
    push ax
    inc  cx
    mov  ah, 0
    jmp  dth_loop
dth_print:
    pop  ax
    cmp  ah, 10
    jl   dth_digit
    sub  ah, 10
    add  ah, 'A'
    jmp  dth_char
dth_digit:
    add  ah, '0'
dth_char:
    mov  al, ah
    mov  bl, 0Eh
    push cx
    call print_char_col
    pop  cx
    dec  cx
    jnz  dth_print
dth_done:
    call wait_key
    ret
dec_to_hex ENDP

dec_to_octal PROC
    lea  dx, ro
    call print_fast
    mov  al, num
    mov  ah, 0
    mov  cx, 0
    cmp  al, 0
    jne  dto_loop
    mov  bl, 0Eh
    mov  al, '0'
    call print_char_col
    jmp  dto_done
dto_loop:
    cmp  al, 0
    je   dto_print
    mov  bl, 8
    div  bl
    push ax
    inc  cx
    mov  ah, 0
    jmp  dto_loop
dto_print:
    pop  ax
    add  ah, '0'
    mov  al, ah
    mov  bl, 0Eh
    push cx
    call print_char_col
    pop  cx
    dec  cx
    jnz  dto_print
dto_done:
    call wait_key
    ret
dec_to_octal ENDP

binary_to_decimal PROC
    lea  dx, inp_bin
    call print_fast
    lea  dx, inp_end
    call print_fast
    mov  num, 0
btd_read:
    mov  ah, 1
    int  21h
    cmp  al, 13
    je   btd_show
    cmp  al, '0'
    je   btd_valid
    cmp  al, '1'
    je   btd_valid
    jmp  btd_read
btd_valid:
    sub  al, '0'
    mov  digit, al
    mov  al, num
    mov  bl, 2
    mul  bl
    add  al, digit
    mov  num, al
    jmp  btd_read
btd_show:
    lea  dx, rd
    call print_fast
    mov  al, num
    mov  ah, 0
    mov  cx, 0
    cmp  al, 0
    jne  btd_div
    mov  bl, 0Eh
    mov  al, '0'
    call print_char_col
    jmp  btd_done
btd_div:
    cmp  al, 0
    je   btd_pop
    mov  bl, 10
    div  bl
    push ax
    inc  cx
    mov  ah, 0
    jmp  btd_div
btd_pop:
    pop  ax
    add  ah, '0'
    mov  al, ah
    mov  bl, 0Eh
    push cx
    call print_char_col
    pop  cx
    dec  cx
    jnz  btd_pop
btd_done:
    call wait_key
    ret
binary_to_decimal ENDP

hex_to_decimal PROC
    lea  dx, inp_hex
    call print_fast
    lea  dx, inp_end
    call print_fast
    mov  num, 0
htd_read:
    mov  ah, 1
    int  21h
    cmp  al, 13
    je   htd_show
    cmp  al, '0'
    jl   htd_upper
    cmp  al, '9'
    jg   htd_upper
    sub  al, '0'
    jmp  htd_got
htd_upper:
    cmp  al, 'A'
    jl   htd_lower
    cmp  al, 'F'
    jg   htd_lower
    sub  al, 'A'
    add  al, 10
    jmp  htd_got
htd_lower:
    cmp  al, 'a'
    jl   htd_read
    cmp  al, 'f'
    jg   htd_read
    sub  al, 'a'
    add  al, 10
htd_got:
    mov  digit, al
    mov  al, num
    mov  ah, 0
    mov  bl, 16
    mul  bl
    add  al, digit
    mov  num, al
    jmp  htd_read
htd_show:
    lea  dx, rd
    call print_fast
    mov  al, num
    mov  ah, 0
    mov  cx, 0
    cmp  al, 0
    jne  htd_div
    mov  bl, 0Eh
    mov  al, '0'
    call print_char_col
    jmp  htd_done
htd_div:
    cmp  al, 0
    je   htd_pop
    mov  bl, 10
    div  bl
    push ax
    inc  cx
    mov  ah, 0
    jmp  htd_div
htd_pop:
    pop  ax
    add  ah, '0'
    mov  al, ah
    mov  bl, 0Eh
    push cx
    call print_char_col
    pop  cx
    dec  cx
    jnz  htd_pop
htd_done:
    call wait_key
    ret
hex_to_decimal ENDP

main PROC
    mov  ax, @data
    mov  ds, ax
    call show_welcome
menu_loop:
    call show_menu
    mov  ah, 1
    int  21h
    cmp  al, '1'
    je   do_dec_bin
    cmp  al, '2'
    je   do_dec_hex
    cmp  al, '3'
    je   do_dec_oct
    cmp  al, '4'
    je   do_bin_dec
    cmp  al, '5'
    je   do_hex_dec
    cmp  al, '6'
    je   do_exit
    mov  ah, 9
    lea  dx, err
    int  21h
    jmp  menu_loop
do_dec_bin:
    call read_decimal
    call dec_to_binary
    jmp  menu_loop
do_dec_hex:
    call read_decimal
    call dec_to_hex
    jmp  menu_loop
do_dec_oct:
    call read_decimal
    call dec_to_octal
    jmp  menu_loop
do_bin_dec:
    call binary_to_decimal
    jmp  menu_loop
do_hex_dec:
    call hex_to_decimal
    jmp  menu_loop
do_exit:
    mov  ah, 9
    lea  dx, bye
    int  21h
    mov  ah, 4Ch
    int  21h
main ENDP
END main