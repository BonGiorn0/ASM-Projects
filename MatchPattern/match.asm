%include "../stud_io.inc"

section .bss
pattern_string resb 100 
source_string resb 100 
section .text
global _start

;print_line(esi = string)
print_line:
    xor ecx, ecx
.again:
    cmp [esi + ecx], byte 0 ;if string[ecx] == '\0'
    je .quit                ;   quit
    PUTCHAR [esi + ecx]     ;else print char
    inc ecx
    jmp .again            
.quit:
    PUTCHAR 10
    ret

;read_line(stack string adress, stack string length)
read_line:
    xor ecx, ecx
    push ebp
    mov ebp, esp
    sub esp, 4                      

    push esi
    mov esi, [ebp + 12]         ;esi = string adress

.again:
    GETCHAR                     ;read char to al
    cmp al, 10                  ;if char == '\n'
    je .finish                  ;   quit
    mov [esi + ecx] , al        ;else string[ecx] = char
    inc ecx                     ;increase counter
    cmp ecx, [ebp + 8]          ;if counter == string length
    je .finish                  ;   quit
    jmp .again                  ;repeat
.finish:
    mov [esi + ecx + 1], byte 0 ;put '\0' in the end of string

    pop esi
    mov esp, ebp
    pop ebp
    ret

;match(esi = source string adress, edi = pattern string adress)
;@return eax = 1 if source matches pattern
;              0 if doesn't
match:
    push ebp
    mov ebp, esp
    sub esp, 4              ;I variable for cutting string

    push esi
    push edi

    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
.again:
    cmp [edi], byte 0       ;pattern ends?
    jne .not_end            ;   if not jump
    cmp [esi], byte 0       ;pattern ends but string doesn't?
    jne .false              ;   then they don't match
    jmp .true               ;if both end then they match
.not_end:
    cmp [edi], byte '*'     ;if pattern char is the star
    jne .not_star           ;   jump

    mov [ebp - 4], dword 0   ;else I = 0
.star_loop:                 ;start of recursive call
    mov eax, edi            ;   of match function
    inc eax                 ;arguments are pattern without star
    push eax                ;   and string without first
    mov eax, esi            ;   I charachters
    add eax, [ebp - 4]
    push eax
    call match
    add esp, 8

    test eax, eax           ;if they match
    jnz .true               ;   return true

    mov eax, [ebp - 4]      
    cmp [esi + eax], byte 0 ;does cutted string ends?
    je .false               ;   if does return false
    inc dword [ebp - 4]     ;else increase the I
    jmp .star_loop          ;   and repeat 
.not_star:
    mov al, [edi]
    cmp al, '?'             ;if pattern char is question mark
    je .quest               ;   jump
    cmp al, [esi]           ;else compare pattern char and string char
    jne .false              ;   if  they aren't equal return false
    jmp .go_on
.quest:
    cmp [esi], byte 0       ;if pattern char is '?' but
    je .false               ;   string is over then return false
.go_on:                     
    inc esi                 ;move in pattern and string by one char
    inc edi
    jmp .again              ;repeat
.true:
    mov eax, 1              
    jmp .quit
.false:
    mov eax, 0
.quit:
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret

    
;main program
_start:
main:
    PRINT "Enter the pattern string:"
    PUTCHAR 10
    push dword pattern_string
    push dword 100
    call read_line
    add esp, 8

    PRINT "Enter the source string:"
    PUTCHAR 10
    push dword source_string
    push dword 100
    call read_line
    add esp, 8

    ;mov esi, pattern_string
    ;call print_line

    ;mov esi, source_string
    ;call print_line

    push dword pattern_string
    push dword source_string
    call match
    add esp, 8

    cmp al, 1
    jne .false
    PRINT "Match"
    PUTCHAR 10
    jmp .quit
.false:
    PRINT "Don't match"
    PUTCHAR 10
.quit:
    FINISH


