global main
extern printf  
extern scanf 
 

section .data
    board   db 32, 32, 88, 88, 88, 32, 32
            db 32, 32, 88, 88, 88, 32, 32
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 95, 95, 95, 88, 88
            db 32, 32, 95, 95, 79, 32, 32
            db 32, 32, 79, 95, 95, 32, 32

    format      db  ' %c ',0 
    formatSalto db  ' %c ',10,0

    textoOpcion db  10,'Turno jugador %i:',10,0

    largo   db 2
    largo_linea   db 7
    unidad   db 1

section .bss
    aux     resq 1

section .text
    extern print_menu 

main:

    ; sub     rsp,8
    ; call    print_menu
    ; add     rsp,8


    mov ecx, 49

imprimir_tablero:
 
    mov r8, 49
    sub r8, rcx
    mov [aux], r8

    mov ax, r8w 
    div byte[largo_linea]
    cmp ah, 6
    je hay_salto

evitamos: 
    mov rdi,format
continuo_imprimendo: 
    mov rsi,[board+r8]
    ; add sil, 2 ; En principio podria agregar para mostrar el que desee
    sub     rsp,8
    call    printf
    add     rsp,8

    mov rcx, 49 
    sub rcx, [aux]

    loop imprimir_tablero

 
    mov rdi,textoOpcion
    sub     rsp,8
    call    printf
    add     rsp,8

    ret

hay_salto: 
    mov rdi,formatSalto
    jmp continuo_imprimendo




; db 0, 1, 2, 3, 4, 5, 6
; db 7, 8, 9, 10, 11, 12, 13
; db 14, 15, 16, 17, 18, 19, 20
; db 21, 22, 23, 24, 25, 26, 27
; db 28, 29, 30, 31, 32, 33, 34
; db 35, 36, 37, 38, 39, 40, 41
; db 42, 43, 44, 45, 46, 47, 48

   
 









 
 