global main
global menu
extern printf 
extern puts
extern scanf
extern movimiento_realizado
extern print_menu 
extern print_tablero_new
extern save_game
extern load_game
extern verificar_mov_oficial 
extern validar_movimiento_oficial
extern validar_movimiento_soldado
extern verificar_salto_y_eliminar_oficial
extern seleccionar_orientacion
extern comprobar_fin_juego
extern clear_screen
extern personalizar_fichas
extern reemplazar_simbolos
extern getchar
extern verificar_movimiento_soldado

%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro
 

section .data
    global turnoActual
    global board 
    global capturas
    global orientacion_tablero
    global ficha_soldado
    global ficha_oficial
    global turnoActual

    board   db 32, 32, 88, 88, 88, 32, 32
            db 32, 32, 88, 88, 88, 32, 32
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 88, 88, 88, 88, 88
            db 88, 88, 95, 95, 95, 88, 88
            db 32, 32, 95, 95, 79, 32, 32
            db 32, 32, 79, 95, 95, 32, 32

    board_inicial   db 32, 32, 88, 88, 88, 32, 32
                    db 32, 32, 88, 88, 88, 32, 32
                    db 88, 88, 88, 88, 88, 88, 88
                    db 88, 88, 88, 88, 88, 88, 88
                    db 88, 88, 95, 95, 95, 88, 88
                    db 32, 32, 95, 95, 79, 32, 32
                    db 32, 32, 79, 95, 95, 32, 32
    ;Tableros para las rotaciones
    tablero_rotado_90 db 32, 32, 88, 88, 88, 32, 32
                      db 32, 32, 88, 88, 88, 32, 32
                      db 88, 88, 88, 88, 95, 79, 95
                      db 88, 88, 88, 88, 95, 95, 95
                      db 88, 88, 88, 88, 95, 95, 79
                      db 32, 32, 88, 88, 88, 32, 32
                      db 32, 32, 88, 88, 88, 32, 32

    tablero_rotado_180 db 32, 32, 79, 95, 95, 32, 32
                       db 32, 32, 95, 95, 79, 32, 32
                       db 88, 88, 95, 95, 95, 88, 88
                       db 88, 88, 88, 88, 88, 88, 88
                       db 88, 88, 88, 88, 88, 88, 88
                       db 32, 32, 88, 88, 88, 32, 32
                       db 32, 32, 88, 88, 88, 32, 32

    tablero_rotado_270 db 32, 32, 88, 88, 88, 32, 32
                       db 32, 32, 88, 88, 88, 32, 32
                       db 79, 95, 95, 88, 88, 88, 88
                       db 95, 95, 95, 88, 88, 88, 88
                       db 95, 79, 95, 88, 88, 88, 88
                       db 32, 32, 88, 88, 88, 32, 32
                       db 32, 32, 88, 88, 88, 32, 32
 
    textoTurnoJuego db  10,'[Opciones: "0" para salir - "1" para guardar]',10,'Ingrese posicion de ficha [%c] a mover: ',0
    posicion_invalida db  'La posicion no es valida : ',0
    textoCargar db 'Deseas cargar la partida guardada? (1 para cargar, 0 para continuar): ', 0
    txtdestino db 'Ingrese la casilla de destino: ',0
    movimiento_valido db 0    
    turnoActual       db  'X',0
    formatoTurno      db  '%d',0 
    capturas          dq   0
    orientacion_tablero db  1

    ficha_soldado       db  88
    ficha_oficial       db  79
    ; Tomo como orientacion 1 fortaleza abajo, orientacion 2 fortaleza a la derecha, orientacion 3 arriba,orientacion 4 izquierda

section .bss 
    global ficha_a_mover
    global posicion_destino
    ficha_a_mover    resq    1
    posicion_destino resq    1
   


section .text
    global main
    global mov_valido
    global ingrese_nuevamente
    global reiniciar_juego

main:

menu:
    
    call_function print_menu ; Imprime el menu y procesa el input
    
    mov byte [orientacion_tablero], 1

    
    cmp ah, 1        ; Opción 1: Iniciar juego
    je iniciar_juego

    cmp ah, 2
    je crear_juego_personalizado

    cmp ah, 3
    je cargar_partida

 
    cmp ah, 4        ; Opción 4: Salir
    je exit

    jmp menu

iniciar_juego:
    call_function reiniciar_juego
    jmp game

crear_juego_personalizado:
    call_function configurar_tablero
    call_function personalizar_fichas
    jmp game

game:
    call_function clear_screen

    lea rdi, [board]
    call_function    print_tablero_new   ; Imprime el tablero 

    call_function    comprobar_fin_juego

    mov rdi, textoTurnoJuego 
    mov rsi, [turnoActual]
    mov rdx, [capturas]
    call_function    printf   ; Imprime texto para solicitar movimiento



ingrese_nuevamente:
    ; Solicita posicion a mover
    mov rdi, formatoTurno
    mov rsi, ficha_a_mover
    call_function    scanf
    cmp    rax,0
    je     posicion_no_valida

    ; Verifica si la entrada es '0' para guardar la partida
    mov al, [ficha_a_mover]
    cmp al, 1        ; Compara si la entrada es 0
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
    cmp byte[turnoActual], 79               ; Verifica que sea un oficial (Debería compararse con una variable que contenga la ficha del oficial)
    jne no_es_oficial
    call_function verificar_mov_oficial     ; Verifica si hay movimientos válidos para el oficial (Falta hacer que si no hay movimientos válidos, no pueda elegir una casilla destino)

no_es_oficial:
    call_function verificar_movimiento_soldado

    ; Hay que pedir la posicion a la que se va a mover. Chequear si es valida
     

    ; Modificar la matris y evaluar si hay que eliminar un valor del enemigo
    ;Cambiar variable de turno
    mov al, [ficha_soldado]
    cmp byte [turnoActual], al
    je cambiar_soldado
    mov al, [ficha_oficial]
    cmp byte [turnoActual], al
    je cambiar_oficial
    ret

    
cambiar_soldado:
    call_function pedir_posicion
    call validar_movimiento_soldado
    cmp byte [movimiento_realizado],0
    jne game
    mov al, [ficha_oficial]
    mov byte [turnoActual], al; Cambiar turno a los oficiales
    jmp game

cambiar_oficial:
    call_function pedir_posicion
    call validar_movimiento_oficial
    cmp byte [movimiento_realizado],1
    jmp game
    mov al, [ficha_soldado]
    mov byte [turnoActual], al; Cambiar turno a los soldados
    jmp game



pedir_posicion:
    mov rdi, txtdestino  ; Imprime texto para pedir destino
    call_function    printf
    mov rdi, formatoTurno
    mov rsi, posicion_destino
    call_function    scanf; Leer la posición de destino

    ret

mover:
    mov r9, [posicion_destino]   ; Cargar la posición de destino
    sub r9, 1                    ; Ajustar a índice 0
    lea r8, [board + r9]         ; Apuntar a la nueva posición en el tablero
    mov al, byte [r8]            ; Cargar el valor en la posición de destino

    cmp al, 95                   ; Comprobar si la posición contiene '95' (vacía)
    jne posicion_no_valida       ; Si no está vacía, saltar a error o mensaje de posición no válida

    mov r9, [ficha_a_mover]      ; Cargar la ficha a mover ('X' o 'O')
    sub r9, 1                    ; Ajustar la posición de la ficha (de 1 a 0-indexado)
    lea r8, [board + r9]         ; Apuntamos a la posición de la ficha original
    mov byte[r8], 95             ; Colocamos un espacio vacío (32) en la posición original

    ; Ahora colocamos la ficha en la nueva posición
    mov r9, [posicion_destino]   ; Cargar la posición de destino
    sub r9, 1   
    lea r8, [board + r9]         ; Apuntamos nuevamente al tablero, ya que actualizamos r8
    mov al, byte [turnoActual]     ; Cargar la ficha a mover (X o O) en AL
    mov byte [r8], al            ; Colocar el valor de AL en la nueva posición
ret






mov_valido:
    ; Si el movimiento es válido, puedes continuar llamando a la función `mover`
    call_function mover
    ret


fuera_de_tablero:
    ret

    
valido_movimiento:
    call_function pedir_posicion
    ret


cargar_partida:
    ; Preguntar si desea cargar la partida guardada
    call_function load_game
    jmp game

guardar_partida:
    ; Guardar el estado actual en un archivo
    call save_game
    jmp menu

salir:
    ; Salir del programa
    mov rax, 60             ; Syscall para salir (exit)
    xor rdi, rdi            ; Código de salida 0
    syscall

exit:
    ; Código para salir del programa (terminar ejecución)
    mov rax, 60             ; Syscall para salir (exit)
    xor rdi, rdi            ; Código de salida 0
    syscall

   
posicion_no_valida:
    sub     rsp, 8
clear_loop:
    call    getchar
    cmp     al, 10
    jne     clear_loop
    add     rsp, 8
    mov rdi, posicion_invalida 
    call_function    printf
    jmp ingrese_nuevamente  



reiniciar_juego:
    ; Reiniciar el tablero
    lea rsi, [board_inicial]
    lea rdi, [board]
    mov rcx, 49  ; Tamaño del tablero (7x7)
    rep movsb

    ; Reiniciar otras variables del juego
    mov byte [turnoActual], 'X'
    mov qword [capturas], 0

    mov word [ficha_soldado], 88
    mov word [ficha_oficial], 79

    ret


configurar_tablero:
    ; Configurar el tablero con los símbolos personalizados

    ; Solicita al usuario la orientacion
   call_function seleccionar_orientacion
    ; Seleccionar el tablero según la orientación
    cmp ah, 1
    je usar_tablero_normal
    cmp ah, 2
    je usar_tablero_90
    cmp ah, 3
    je usar_tablero_180
    cmp ah, 4
    je usar_tablero_270

usar_tablero_normal:
    lea rsi, [board_inicial]
    jmp copiar_tablero

usar_tablero_90:
    lea rsi, [tablero_rotado_90]
    jmp copiar_tablero

usar_tablero_180:
    lea rsi, [tablero_rotado_180]
    jmp copiar_tablero

usar_tablero_270:
    lea rsi, [tablero_rotado_270]
    jmp copiar_tablero

copiar_tablero:
    ; Copiar el tablero rotado al tablero principal
    lea rdi, [board]
    mov rcx, 49  ; Tamaño del tablero (7x7)
    rep movsb ; Copiar el tablero rotado al tablero principal
    ret



