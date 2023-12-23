%include "../stud_io.inc"
section .data
size dw 80
section .bss
array resb 80                       ;array of length 50

section .text
global _start

_start: mov ecx, 0                  ;put zero in counter
        mov al, 20                  ;put '1' in al
array_fill:
        mov [array + ecx], al       ;put char from al in array 
        inc ecx                     ;increase counter
        inc al                      ;put in al next ASCII char
        cmp ecx, [size]             ;if counter lesss then array size
        jl array_fill               ;jump to array_fill
        mov ecx, 0                  ;put zero in counter
array_print:
        PUTCHAR [array + ecx]       ;print element of array
        inc ecx                     ;increase counter
        cmp ecx, [size]             ;if conter less then array size
        jl array_print              ;jump to array_print
        PUTCHAR 10                  ;print '\n'
        FINISH

