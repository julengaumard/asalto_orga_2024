global main
extern printf 
extern scanf
 
%macro imprimir_tablero 0
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
    mov rdi,formatoTablero
continuo_imprimendo: 
    mov rsi,[board+r8]
    ; add sil, 2 ; En principio podria agregar para mostrar el que desee
    sub     rsp,8
    call    printf
    add     rsp,8

    mov rcx, 49 
    sub rcx, [aux]

    loop imprimir_tablero

    mov     rdi,textoTurnoJuego
    sub     rsp,8
    call    printf
    add     rsp,8

    jmp proceso_logica
 
hay_salto: 
    mov rdi,formatoTableroSalto
    jmp continuo_imprimendo
%endmacro


section .data
    board   db 32, 32, 88, 88, 88, 32, 32
            db 32, 32, 88, 88, 88, 32, 32
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 95, 95, 95, 88, 88
            db 32, 32, 95, 95, 79, 32, 32
            db 32, 32, 79, 95, 95, 32, 32

    formatoTablero      db  ' %c ',0 
    formatoTableroSalto db  ' %c ',10,0
    textoTurnoJuego db  10,'Turno jugador %i:',10,0

    largo   db 2
    largo_linea   db 7
    unidad   db 1

    formatoTurno      db  ' %c ',0 

section .bss
    aux         resq 1 

section .text
    extern print_menu 

main:

menu:
    
    sub     rsp,8
    call    print_menu  ; Imprime el menu y procesa el input
    add     rsp,8
 
    cmp     ah, 1       ; Salta al codigo del juego
    je      game

    ; Hay que agregar el jmp a la carga de partida y para personalizar

    cmp     ah, 4       ; Termina la ejecucion
    je      exit

    jmp menu

game:
    imprimir_tablero
    ; procesar logica juego
proceso_logica:

    mov rdi, formatoTurno
    sub     rsp,8
    call    scanf   
    add     rsp,8

    jmp game

exit:
    ret
   