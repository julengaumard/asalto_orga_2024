extern printf 
extern scanf
extern board
extern turnoActual 
extern capturas
extern formatoTurno
extern ficha_a_mover
extern mov_valido
extern invalido_movimiento
extern capturas
extern posicion_destino


section .data
    txtdestino db 'Ingrese la casilla de destino: ',0
    movimiento_valido db 0

section .bss
   

section .text 
global validar_movimiento_oficial
global verificar_salto_y_eliminar_oficial

verificar_mov_oficial:
; debemos verificar antes de pedir la posicion de destino si tiene a donde moverse
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

