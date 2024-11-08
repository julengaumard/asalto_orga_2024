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
 
    textoTurnoJuego db  10,'Turno [%c]',10,'(Ingrese -1 para salir)',10,'Ingrese posicion de ficha a mover: ',0
    posicion_invalida db  'La posicion no es valida, ingrese nuevamente: ',0

    
    turnoActual       db  'X',0
    formatoTurno      db  '%d',0 
       

section .bss 
    ficha_a_mover    resq    1

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



ingrese_nuevamente:
    ; Solicita posicion a mover
    mov rdi, formatoTurno
    mov rsi, ficha_a_mover
    call_function    scanf

    ; Chequea si la posicion es externa al tablero
    cmp qword[ficha_a_mover], 48 
    jg posicion_no_valida
 
    ; Chequea si la ficha a mover corresponde a tu turno.
    mov r9, [ficha_a_mover] 
    sub r9, 1        
    lea r8, [board + r9]                 
    mov al, byte[r8]                    
    cmp al, byte[turnoActual] 
    jne posicion_no_valida

    ; Hay que chequear si es una ficha que se puede mover
    ; Hay que pedir la posicion a la que se va a mover. Chequear si es valida
    ; Modificar la matris y evaluar si hay que eliminar un valor del enemigo
    ; Cambiar variable de tunro


    jmp game

exit:
    ret

   
posicion_no_valida:
    mov rdi, posicion_invalida 
    call_function    printf
    jmp ingrese_nuevamente  






; debug_print       db  'Valores: %c - %c',0 
; mov rdi,debug_print
; mov rsi, [turnoActual]
; mov rdx, [r9]
; sub     rsp,8
; call    printf
; add     rsp,8 