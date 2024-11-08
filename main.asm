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
 
    textoTurnoJuego db  10,'Turno jugador %i:',10,0

    formatoTurno      db  ' %c ',0 

section .bss 

section .text
    extern print_menu 
    extern print_tablero_new

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
    lea rdi, [board]
    sub     rsp,8
    call    print_tablero_new   
    add     rsp,8

; proceso_logica:
;     ; Aca esta la logica del juego
;     mov rdi, formatoTurno
;     sub     rsp,8
;     call    scanf   
;     add     rsp,8
;     jmp game

exit:
    ret
   