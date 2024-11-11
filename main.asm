global main
extern printf 
extern scanf

extern print_menu 
extern print_tablero_new
extern save_game
extern load_game
%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro
 

section .data
     global turnoActual
     global board 

    board   db 32, 32, 88, 88, 88, 32, 32
            db 32, 32, 88, 88, 88, 32, 32
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 95, 95, 95, 88, 88
            db 32, 32, 95, 95, 79, 32, 32
            db 32, 32, 79, 95, 95, 32, 32
 
    textoTurnoJuego db  10,'Turno [%c]',10,'(Ingrese -1 para salir)',10,'Ingrese posicion de ficha a mover o "0" para guardar: ',0
    posicion_invalida db  'La posicion no es valida, ingrese nuevamente: ',0
    textoCargar db 'Deseas cargar la partida guardada? (1 para cargar, 0 para continuar): ', 0
    
    turnoActual       db  'X',0
    formatoTurno      db  '%d',0 
       

section .bss 
    ficha_a_mover    resq    1
    opcion_personalizar resb 1

section .text
    global main

main:

menu:
    
    call_function print_menu ; Imprime el menu y procesa el input
    
    
    cmp ah, 1        ; Opción 1: Iniciar juego
    je game

    cmp ah, 3
    je cargar_partida

 
    cmp ah, 4        ; Opción 4: Salir
    je exit

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

    ; Verifica si la entrada es '0' para guardar la partida
    mov al, [ficha_a_mover]
    cmp al, 0        ; Compara si la entrada es 0
    jl exit
    je guardar_partida ; Si es 0, guarda la partida

    ; Si no es '0', sigue con el flujo normal de juego


    cmp qword[ficha_a_mover], 48 
    jg posicion_no_valida

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
    cmp byte [turnoActual], 'X'
    je cambiar_a_soldado
    cmp byte [turnoActual], 'O'
    je cambiar_a_oficial
    ret

    
cambiar_a_soldado:
    mov byte [turnoActual], 'O'
     jmp game

cambiar_a_oficial:
    mov byte [turnoActual], 'X' ; Cambiar turno a los soldados
    jmp game



guardar_partida:
    ; Guardar el estado actual en un archivo
    call save_game
    jmp menu


cargar_partida:
    ; Preguntar si desea cargar la partida guardada
    call load_game
    jmp game



exit:
    ; Código para salir del programa (terminar ejecución)
    mov rax, 60             ; Syscall para salir (exit)
    xor rdi, rdi            ; Código de salida 0
    syscall

   
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
