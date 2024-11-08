global main
extern printf 
extern scanf

%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro
 

section .data
    board   db 32, 32, 88, 88, 88, 32, 32
            db 32, 32, 88, 88, 88, 32, 32
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 95, 95, 95, 88, 88
            db 32, 32, 95, 95, 79, 32, 32
            db 32, 32, 79, 95, 95, 32, 32
 
    textoTurnoJuego db  10,'Turno jugador [%c]',10,'Ingrese ficha a mover: ',

    turnoActual       db  'O',0
    formatoTurno      db  '%d',0 
       

section .bss 
    posicion_a_mover    resb    1

section .text
    extern print_menu 
    extern print_tablero_new

main:

menu:
    
    call_function print_menu ; Imprime el menu y procesa el input
 
    cmp     ah, 1       ; Salta al codigo del juego
    je      game

    ; Hay que agregar el jmp a la carga de partida y para personalizar

    cmp     ah, 4       ; Termina la ejecucion
    je      exit

    jmp menu

game:
    lea rdi, [board]
    call_function    print_tablero_new   ; Imprime el tablero 

    mov rdi, textoTurnoJuego 
    mov rsi, [turnoActual]
    call_function    printf   ; Imprime texto para solicitar movimiento


    ; mov rsi, 0
    ; mov rdi, formatoTurno
    ; lea rsi, [posicion_a_mover]
    ; call_function    scanf

    ; mov rdi, textoTurnoJuego 
    ; mov rsi, [posicion_a_mover]
    ; call_function    printf




    jmp game

exit:
    ret
   