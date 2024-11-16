extern printf 
extern scanf
extern puts
extern board
extern turnoActual 
extern capturas
extern formatoTurno
extern ficha_a_mover
extern mov_valido
extern invalido_movimiento
extern posicion_destino


%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro


section .data
    txtdestino db 'Ingrese la casilla de destino: ',0
    mensaje_verificacion_mov_oficial db 10, "El oficial seleccionado no posee movimientos válidos", 10, 0
    movimiento_valido db 0
    vector_desplazamientos db -8, -7, -6, -1, 1, 6, 7, 8 

section .bss
   

section .text 
global validar_movimiento_oficial
global verificar_salto_y_eliminar_oficial
global verificar_mov_oficial 


; Si el movimiento es posible, establece true en movimiento_valido
verificar_mov_oficial:
    mov byte[movimiento_valido], 0                      ; Establece que movimiento_valido es false
    lea r11, [vector_desplazamientos]                   ; Carga el puntero al primer elemento del vector_desplazamiento
    mov cx, 8                                           ; Carga 8 en CX para utilizar un loop

; Verifica si los alrededores del oficial están libres o si hay un soldado y se puede capturar
loop_verificar_mov_oficial:
    mov r10, [ficha_a_mover]                            ; Posición actual de la ficha a mover
    sub r10, 1                                          ; Se ajusta a 0-index
    lea r12, [board]                                    ; Guarda el puntero al primer elemento del tablero
    add r12, r10                                        ; El puntero del tablero apunta a la posición de la ficha a mover

    call_function esta_borde_lateral_tablero                 ; Verifica si la ficha se encuentra en los bordes laterales del tablero
    call_function esta_borde_superior_inferior_tablero       ; Verifica si la ficha se encuentra en el borde superior o en el borde inferior del tablero

    mov dl, [r11]
    movsx rdx, dl
    add r12, rdx                                        ; Calcula el desplazamiento respecto a la posición de la ficha
    cmp byte[r12], 95                                   ; Verifica si hay un espacio libre
    je movimiento_posible

    cmp byte[r12], 32                                   ; Verifica si está fuera de los movimientos permitidos pero dentro del tablero (Los espacios en las esquinas del tablero)
    je continuar_verificacion_mov_oficial

    cmp byte[r12], 79
    je continuar_verificacion_mov_oficial               ; Verifica si hay otro oficial en la posición

    ; (Debería compararse con una variable que contenga la ficha de los soldados)
    cmp byte[r12], 88                                   ; Verifica si hay un soldado en la posición y si se puede capturar 
    je captura_posible

continuar_verificacion_mov_oficial:
    cmp byte[movimiento_valido], 1                      ; Un solo movimiento válido es suficiente por lo tanto termina la subrutina
    je finalizar_verificacion_mov_oficial

    inc r11                                             ; Mueve el puntero del vector_desplazamiento a la siguietne posición
    loop loop_verificar_mov_oficial                     ; Si no encontró un movimiento válido, intenta nuevamente pero con otro desplazamiento
    mov rdi, mensaje_verificacion_mov_oficial
    call_function puts                                  ; Imprime por pantalla que el oficial no tiene movimientos válidos


    ; (Faltaría tener en cuenta, en otra función podría ser, que si ambos oficiales no pueden moverse, el juego termina y ganan los soldados)

finalizar_verificacion_mov_oficial:
    ret

esta_borde_lateral_tablero:
    xor rdx, rdx
    xor rax, rax
    mov ax, r10w                                    ; Copia la posicion del oficial a AX
    xor rbx, rbx
    mov bx, 7
    idiv bx                                           
    cmp dx, 0                                       ; Si el resto es 0, se encuentra en el borde izquierdo del tablero
    je verificar_desplazamiento_izquierda

    cmp dx, 6                                       ; Si el resto es 6, se encuentra en el borde derecho del tablero
    je verificar_desplazamiento_derecha

    ret

verificar_desplazamiento_derecha:
    cmp byte[r11], -6                                   ; Diagonal superior derecha
    je continuar_verificacion_mov_oficial
    cmp byte[r11], 1                                    ; Posición del medio derecha
    je continuar_verificacion_mov_oficial
    cmp byte[r11], 8                                    ; Diagonal inferior derecha
    je continuar_verificacion_mov_oficial

    ret

verificar_desplazamiento_izquierda:
    cmp byte[r11], -8                                   ; Diagonal superior izquierda
    je continuar_verificacion_mov_oficial
    cmp byte[r11], -1                                   ; Posición del medio izquierda
    je continuar_verificacion_mov_oficial
    cmp byte[r11], 6                                    ; Diagonal inferior izquierda
    je continuar_verificacion_mov_oficial

    ret

esta_borde_superior_inferior_tablero:
    mov rax, r12                                            ; Carga la dirección del tablero con la posición de la ficha en RAX
    xor rdx, rdx                                            ; Limpia RDX
    mov dl, [r11]                                           ; Carga el desplazamiento de la posición almacenada en el vector al que apunta R11
    movsx rdx, dl
    add rax, rdx                                            ; Suma a la posición del oficial el desplazamiento
    lea rbx, [board]
    cmp rax, rbx                                            ; Verifica si la posición del desplazamiento se sale del rango del tablero
    jl movimiento_fuera_tablero

    add rbx, 48
    cmp rax, rbx
    jg movimiento_fuera_tablero

    ret

movimiento_fuera_tablero:
    jmp continuar_verificacion_mov_oficial

movimiento_posible:
    mov byte[movimiento_valido], 1
    jmp continuar_verificacion_mov_oficial

captura_posible:
    xor rdx, rdx
    mov dl, [r11]
    movsx rdx, dl
    add r10, rdx                                            ; Desplaza la posición cargada en R10 a la posición donde se encuentra el soldado

    call_function esta_borde_lateral_tablero                ; Verifica si la ficha se encuentra en los bordes laterales del tablero
    call_function esta_borde_superior_inferior_tablero      ; Verifica si la ficha se encuentra en el borde superior o en el borde inferior del tablero
 

    ; En este punto, se verifica que el desplazamiento del salto respecto al soldado está dentro del tablero
    xor rdx, rdx
    mov dl, [r11]
    movsx rdx, dl
    add r10, rdx                                            ; Desplaza la posición cargada en R10 a la posición donde se debe hacer el salto

    lea r12, [board]
    add r12, r10
    ; (Debería compararse con una variable que contenga la ficha de los soldados)
    cmp byte[r12], 88                                       ; Verifica si hay un soldado en la posición
    je continuar_verificacion_mov_oficial

    cmp byte[r12], 32                                       ; Verifica si hay un casillero inválido o " " en la posición
    je continuar_verificacion_mov_oficial

    cmp byte[r12], 79                                       ; Verifica si hay otro oficial en la posición
    je continuar_verificacion_mov_oficial               

    ; Si llega hasta este punto, la captura es posible
    ret



validar_movimiento_oficial:
    mov r10, [ficha_a_mover]        ; Posición actual de la ficha a mover
    sub r10, 1                      ; Ajustar a 0-index
    mov r11, [posicion_destino]     ; Posición a la que se quiere mover
    sub r11, 1

    ; Calcula la diferencia en la posición para verificar dirección y distancia
    mov r12, r10
    sub r12, r11                    ; r12 = diferencia de posiciones

    ; Verificar si es un movimiento normal (una casilla en cualquier dirección)
    cmp r12, -7
    je mov_valido
    cmp r12, 7
    je mov_valido
    cmp r12, -1
    je mov_valido
    cmp r12, 1
    je mov_valido
    cmp r12, -8                    ; Diagonal superior izquierda
    je mov_valido
    cmp r12, -6                    ; Diagonal superior derecha
    je mov_valido
    cmp r12, 6                     ; Diagonal inferior izquierda
    je mov_valido
    cmp r12, 8                     ; Diagonal inferior derecha
    je mov_valido

    ; Verificar si es una captura (dos casillas en cualquier dirección o diagonal)
    cmp r12, -14                   ; Arriba (2 casillas)
    je verificar_salto
    cmp r12, 14                    ; Abajo (2 casillas)
    je verificar_salto
    cmp r12, -2                    ; Izquierda (2 casillas)
    je verificar_salto
    cmp r12, 2                     ; Derecha (2 casillas)
    je verificar_salto
    cmp r12, -16                   ; Diagonal superior izquierda (2 casillas)
    je verificar_salto
    cmp r12, -12                   ; Diagonal superior derecha (2 casillas)
    je verificar_salto
    cmp r12, 12                    ; Diagonal inferior izquierda (2 casillas)
    je verificar_salto
    cmp r12, 16                    ; Diagonal inferior derecha (2 casillas)
    je verificar_salto

    ; Movimiento no permitido si no cumple ninguna condición
    jmp invalido_movimiento

verificar_salto:
    ; Calcula la posición intermedia
    mov r13, r10                    ; r13 = posición inicial
    add r13, r11                    ; Suma posición inicial + destino
    shr r13, 1                      ; Divide entre 2 para obtener posición intermedia
    lea r8, [board + r13]           ; Dirección de la posición intermedia en el tablero
    cmp byte [r8], 88               ; Comprobar si es un soldado ('X')
    jne invalido_movimiento

    ; Verificar que la posición de destino esté vacía
    lea r8, [board + r11]           ; Posición de destino
    cmp byte [r8], 95               ; Debe estar vacía ('_' o espacio)
    jne invalido_movimiento

    ; Aumenta el contador de capturas y elimina el soldado capturado
    add qword [capturas], 1         ; Incrementa el contador de capturas
    mov byte [board + r13], 95      ; Elimina el soldado en la posición intermedia, colocando espacio vacío
    jmp mov_valido

