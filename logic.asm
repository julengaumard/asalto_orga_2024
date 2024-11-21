extern printf 
extern scanf
extern puts
extern board
extern turnoActual 
extern capturas
extern formatoTurno
extern ficha_a_mover
extern mov_valido
extern ingrese_nuevamente
extern mover

extern oficiales_eliminados
extern posicion_destino
extern orientacion_tablero
extern ficha_soldado
extern ficha_oficial

%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro


section .data
    global movimiento_realizado
    global oficial_arriba
    global oficial_abajo 
    global oficial_derecha 
    global oficial_izquierda
    global oficial_diagonalsupizq
    global oficial_diagonalsupder
    global oficial_diagonalinfizq
    global oficial_diagonalinfder
    global es_movimiento_valido
    global hay_captura_posible
    global es_captura
    global es_movimiento_posible
    txtdestino db 'Ingrese la casilla de destino: ',0
    destino_invalido db  10, 'La posicion de destino no es valida',10, 'Ingrese nuevamente la ficha que quiere mover :',0
    mensaje_error_orientacion_tablero db 10, "La orientación del tablero no es válida.", 10, 0
    movimiento_valido db 0
    vector_desplazamientos db -8, -7, -6, -1, 1, 6, 7, 8 
    movimiento_realizado db 0
    es_movimiento_posible db 0
    es_movimiento_valido db 0
    hay_captura_posible db 0
    es_captura db 0
    oficial_arriba dq 0
    oficial_abajo dq 0
    oficial_derecha dq 0
    oficial_izquierda dq 0
    oficial_diagonalsupizq dq 0
    oficial_diagonalsupder dq 0
    oficial_diagonalinfizq dq 0
    oficial_diagonalinfder dq 0

section .bss
    casilla_roja_1  resb    1
    casilla_roja_2  resb    1
    casilla_roja_3  resb    1
    casilla_roja_4  resb    1
    direccion_posible_1     resb    1
    direccion_posible_2     resb    1
    direccion_posible_3     resb    1
    direccion_posible_costado_1     resb    1
    direccion_posible_costado_2     resb    1

   

section .text 
global validar_movimiento_oficial
global validar_movimiento_soldado
global verificar_salto_y_eliminar_oficial
global verificar_mov_oficial 
global verificar_movimiento_soldado
global comprobar_captura


; Si el movimiento es posible, establece true en es_movimiento_valido
verificar_mov_oficial:
    mov byte[es_movimiento_valido], 0                   ; Establece que es_movimiento_valido es false
    lea r11, [vector_desplazamientos]                   ; Carga el puntero al primer elemento del vector_desplazamiento
    mov cx, 15                                          ; Espacio para hacer todos los chequeos en 8 direcciones  
    xor r14, r14                                        ; Inicializa contador de iteraciones

; Verifica si los alrededores del oficial están libres o si hay un soldado y se puede capturar
loop_verificar_mov_oficial:
    mov byte[es_movimiento_posible], 1                  ; Si es true, verifica si es un movimiento válido. Si es false, salta a la siguiente iteración o termina el ciclo
    mov r10, [ficha_a_mover]                            ; Posición actual de la ficha a mover
    sub r10, 1                                          ; Se ajusta a 0-index
    lea r12, [board]                                    ; Guarda el puntero al primer elemento del tablero
    add r12, r10                                        ; El puntero del tablero apunta a la posición de la ficha a mover             

    call esta_borde_lateral_tablero                     ; Verifica si la ficha se encuentra en los bordes laterales del tablero
    call esta_borde_superior_inferior_tablero           ; Verifica si la ficha se encuentra en el borde superior o en el borde inferior del tablero

    cmp byte [es_movimiento_posible], 1
    jne continuar_verificacion_mov_oficial

    mov dl, [r11]
    movsx rdx, dl
    lea r13, [r12 + rdx]                                ; Calcula la posición adyacente   
    mov r15, r13
    add r15, rdx                                        ; Almacena adyacente del adyacente (en la direccion apuntada por r11)                  
            
    mov al, [ficha_soldado]
    cmp byte [r13], al                                  ; Verifica si hay un soldado en la posición y si se puede capturar
    je captura_posible                                  ; Chequea 8 veces (1 en cada direccion) antes de saltar a la siguiente iteración
    cmp r14, 8
    jl continuar_verificacion_mov_oficial
    cmp r14, 8
    je reiniciar_vector
    cmp r14, 8
    jg chequear_vacio                                   ; Verifica si hay un espacio sin ocupar

continuar_verificacion_mov_oficial:
    inc r11                                             ; Avanza al siguiente desplazamiento
    inc r14                                             
    loop loop_verificar_mov_oficial                     ; Si no encontró un movimiento válido, intenta nuevamente pero con otro desplazamiento

    ; Iteró con todos los desplazamientos y no tiene movimientos válidos
    xor rax, rax
    mov al, [es_movimiento_valido]
    ret
    
chequear_vacio: 
    cmp byte [r13], 95                                  ; Verifica si hay un espacio libre
    je finalizar_verificacion_mov_oficial               ; Un solo movimiento válido es suficiente por lo tanto termina la subrutina
    cmp r14, 15
    jl continuar_verificacion_mov_oficial               ; Si no encontró un movimiento válido, intenta nuevamente pero con otro desplazamiento

finalizar_verificacion_mov_oficial:
    call_function movimiento_posible
    xor rax, rax
    mov al, [es_movimiento_valido]
    ret

reiniciar_vector:
    lea r11, [vector_desplazamientos]
    dec r11
    jmp continuar_verificacion_mov_oficial 
    

esta_borde_lateral_tablero:
    xor rdx, rdx
    xor rax, rax
    mov ax, r10w                                    ; Copia la posicion de la ficha a AX
    xor rbx, rbx
    mov bx, 7
    idiv bx                                           
    
    call_function verificar_desplazamientos_borde

    ret

verificar_desplazamientos_borde:
    cmp dx, 0                                       ; Si el resto es 0, se encuentra en el borde izquierdo del tablero
    je verificar_movimiento_soldado_90              ; Se usa esta función para utilizar los 3 posibles desplazamientos y verificar si se mueve hacia el borde derecho
    jne no_esta_borde_tablero

    cmp dx, 6                                       ; Si el resto es 6, se encuentra en el borde derecho del tablero
    je verificar_movimiento_soldado_270             ; Se usa esta función para utilizar los 3 posibles desplazamientos y verificar si se mueve hacia el borde izquierdo
    jne no_esta_borde_tablero

    mov dl, byte[direccion_posible_1]
    cmp byte[r11], dl                       
    je movimiento_no_posible

    mov dl, byte[direccion_posible_2]
    cmp byte[r11], dl                                   
    je movimiento_no_posible

    mov dl, byte[direccion_posible_3]
    cmp byte[r11], dl                                   
    je movimiento_no_posible

no_esta_borde_tablero:
    ret

movimiento_no_posible:
    mov byte[es_movimiento_posible], 0
    ret

esta_borde_superior_inferior_tablero:
    mov rax, r12                                            ; Carga la dirección del tablero con la posición de la ficha en RAX
    xor rdx, rdx                                            ; Limpia RDX
    mov dl, [r11]                                           ; Carga el desplazamiento de la posición almacenada en el vector al que apunta R11
    movsx rdx, dl
    add rax, rdx                                            ; Suma a la posición del oficial el desplazamiento
    lea rbx, [board]
    cmp rax, rbx                                            ; Verifica si la posición del desplazamiento se sale del rango del tablero
    jl movimiento_no_posible

    add rbx, 48
    cmp rax, rbx
    jg movimiento_no_posible

    ret    

movimiento_posible:
    mov byte[es_movimiento_valido], 1
    ret

captura_posible:
    mov byte [hay_captura_posible], 0
    xor rdx, rdx
    mov dl, [r11]
    movsx rdx, dl
    add r10, rdx                                            ; Desplaza la posición cargada en R10 a la posición donde se encuentra el soldado
      ; Verifica si la ficha se encuentra en el borde superior o en el borde inferior del tablero
 

    ; En este punto, se verifica que el desplazamiento del salto respecto al soldado está dentro del tablero
    xor rdx, rdx
    mov dl, [r11]
    movsx rdx, dl
    add r10, rdx                                            ; Desplaza la posición cargada en R10 a la posición donde se debe hacer el salto

    lea r12, [board]
    add r12, r10
    
    mov al, [ficha_soldado]
    cmp byte[r15], al                                       ; Verifica si hay un soldado en la posición
    je continuar_verificacion_mov_oficial

    cmp byte[r15], 32                                       ; Verifica si hay un casillero inválido o " " en la posición
    je continuar_verificacion_mov_oficial

    mov al, [ficha_oficial]
    cmp byte[r15], al                                       ; Verifica si hay otro oficial en la posición
    je continuar_verificacion_mov_oficial

    cmp byte[r15], 95
    jne continuar_verificacion_mov_oficial                                       ; Verifica si la posición está vacía

    ; Si llega hasta este punto, la captura es posible y es un movimiento válido, por lo cual termina la verificación
    mov byte[hay_captura_posible], 1
    jmp finalizar_verificacion_mov_oficial


verificar_movimiento_soldado:
    mov byte[es_movimiento_valido], 0              ; Establece que no tiene movimientos válidos al inicio
    call_function verificar_rotacion_tablero

    mov byte[es_movimiento_posible], 1          
    mov r10, [ficha_a_mover]                    ; Carga la posición de la ficha a mover
    sub r10, 1                                  ; Pasa a 0-index
    lea r12, [board]                            ; Carga el tablero en R12
    add r12, r10                                ; Se posiciona el puntero del tablero en la posición de la ficha 

    cmp byte[orientacion_tablero], 2
    je rotacion_90_270

    cmp byte[orientacion_tablero], 4
    je rotacion_90_270

    ; Para rotaciones de 0 y 180 grados
    lea r11, [direccion_posible_1]
    call_function esta_borde_superior_inferior_tablero         ; Verifican si se sale del borde superior o inferior
   
    cmp byte[es_movimiento_posible], 1
    jne soldado_sin_movimientos_validos         ; No hay movimientos posibles ya que el soldado se encuentra en el borde inferior o superior del tablero.
    jmp continuar_verificacion_movimiento_soldado

rotacion_90_270:
    ; Para rotaciones de 90 y 270 grados
    lea r11, [direccion_posible_1]
    call_function esta_borde_lateral_tablero    ; Verifican si se sale del borde lateral
   
    cmp byte[es_movimiento_posible], 1
    jne soldado_sin_movimientos_validos         ; No hay movimientos posibles ya que el soldado se encuentra en el borde inferior o superior del tablero.

continuar_verificacion_movimiento_soldado:
    cmp r10b, [casilla_roja_1]
    je verificar_movimiento_soldado_costado     ; Verifica si el soldado se puede mover a los costados (solo en el caso de estar en una casilla roja)
    cmp r10b, [casilla_roja_2]
    je verificar_movimiento_soldado_costado
    cmp r10b, [casilla_roja_3]
    je verificar_movimiento_soldado_costado
    cmp r10b, [casilla_roja_4]
    je verificar_movimiento_soldado_costado

    mov r13, r12
    movsx rdx, byte[direccion_posible_1]
    add r13, rdx     
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina

    mov r13, r12
    movsx rdx, byte[direccion_posible_2]
    add r13, rdx                
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina

    mov r13, r12
    movsx rdx, byte[direccion_posible_2]
    add r13, rdx
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina

    ; No tiene movimientos válidos
soldado_sin_movimientos_validos:
    mov byte[es_movimiento_valido], 0
    ret

finalizar_verificacion_movimiento_soldado:
    ret

error_orientacion_tablero:
    mov rdi, mensaje_error_orientacion_tablero
    call_function puts
    jmp finalizar_verificacion_movimiento_soldado

movimiento_soldado_posible:
    mov byte[es_movimiento_valido], 1
    jmp finalizar_verificacion_movimiento_soldado
    ret

verificar_movimiento_soldado_costado:
    cmp r10b, [casilla_roja_1]               ; La ficha está en una casilla roja y en el borde
    je verificar_movimiento_soldado_costado_borde

    cmp r10b, [casilla_roja_4]               ; La ficha está en una casilla roja y en el borde
    je verificar_movimiento_soldado_costado_borde

    ; Si no está en el borde, puede estar en casilla_roja_2 y casilla_roja_3
    cmp r10b, [casilla_roja_2]
    jne esta_casilla_roja_3
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_2]     ; Primer posible desplazamiento
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos

esta_casilla_roja_3:
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_1]      ; Segundo posible desplazamiento
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos


verificar_movimiento_soldado_costado_borde:
    xor rdx, rdx
    xor rax, rax
    mov ax, [orientacion_tablero]           
    xor rbx, rbx 
    mov bx, 2                                   ; División para ver si la orientación es par o impar
    div bx

    cmp dx, 1                                   ; Si la orientación es 0° o 180°, el resto es 1. Si la orientación es 90° o 270°, el resto es 0
    je verificar_movimiento_soldado_costado_horizontal_borde
    jne verificar_movimiento_soldado_costado_vertical_borde

verificar_movimiento_soldado_costado_horizontal_borde:
    cmp r10b, [casilla_roja_1]
    je esta_casilla_roja_1_horizontal

    ; Si no está en la casilla roja 1, entonces está en la casilla roja 4 
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_1]
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos

esta_casilla_roja_1_horizontal:
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_2]
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos

verificar_movimiento_soldado_costado_vertical_borde:
    cmp r10b, [casilla_roja_1]
    je esta_casilla_roja_1_vertical

    ; Si no está en la casilla roja 1, entonces está en la casilla roja 4 
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_1]
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos

esta_casilla_roja_1_vertical:
    mov r13, r12                                ; Mueve la matriz con el puntero apuntando a la posición de la ficha a R13
    add r13b, [direccion_posible_costado_2]
    cmp byte[r13], 95                           ; Verifica si la posición actual del soldado más el desplazamiento es válida
    je movimiento_soldado_posible               ; Con un solo movimiento válido me basta para terminar la subrutina
    jne soldado_sin_movimientos_validos


verificar_rotacion_tablero:
    cmp byte [orientacion_tablero], 1            ; Tablero rotado 0 grados
    jl error_orientacion_tablero
    je verificar_movimiento_soldado_0           ; El valor de la orientación del tablero es incorrecta

    cmp byte [orientacion_tablero], 2            ; Tablero rotado 90 grados
    je verificar_movimiento_soldado_90

    cmp byte [orientacion_tablero], 3            ; Tablero rotado 180 grados
    je verificar_movimiento_soldado_180

    cmp byte [orientacion_tablero], 4            ; Tablero rotado 270 grados
    je verificar_movimiento_soldado_270
    jg error_orientacion_tablero                ; El valor de la orientación del tablero es incorrecta
    ret

verificar_movimiento_soldado_0:
    mov byte [casilla_roja_1], 28
    mov byte [casilla_roja_2], 29
    mov byte [casilla_roja_3], 33
    mov byte [casilla_roja_4], 34
    mov byte [direccion_posible_1], 6
    mov byte [direccion_posible_2], 7
    mov byte [direccion_posible_3], 8
    jmp direccion_posible_costado_horizontal
    ret

verificar_movimiento_soldado_180:
    mov byte [casilla_roja_1], 14
    mov byte [casilla_roja_2], 15
    mov byte [casilla_roja_3], 19
    mov byte [casilla_roja_4], 20
    mov byte [direccion_posible_1], -8
    mov byte [direccion_posible_2], -7
    mov byte [direccion_posible_3], -6
    jmp direccion_posible_costado_horizontal
    ret

direccion_posible_costado_horizontal:
    mov byte [direccion_posible_costado_1], -1
    mov byte [direccion_posible_costado_2], 1
    ret


verificar_movimiento_soldado_90:
    mov byte [casilla_roja_1], 4
    mov byte [casilla_roja_2], 11
    mov byte [casilla_roja_3], 39
    mov byte [casilla_roja_4], 46
    mov byte [direccion_posible_1], -6
    mov byte [direccion_posible_2], 1
    mov byte [direccion_posible_3], 8
    jmp direccion_posible_costado_vertical
    ret

verificar_movimiento_soldado_270:
    mov byte [casilla_roja_1], 2
    mov byte [casilla_roja_2], 9
    mov byte [casilla_roja_3], 37
    mov byte [casilla_roja_4], 44
    mov byte [direccion_posible_1], -8
    mov byte [direccion_posible_2], -1
    mov byte [direccion_posible_3], 6
    jmp direccion_posible_costado_vertical
    ret

direccion_posible_costado_vertical:
    mov byte [direccion_posible_costado_1], -7
    mov byte [direccion_posible_costado_2], 7
    ret


validar_movimiento_oficial:
    mov r9, [posicion_destino]   ; Cargar la posición de destino
    sub r9, 1                    ; Ajustar a índice 0
    lea r8, [board + r9]         ; Apuntar a la nueva posición en el tablero
    mov al, byte [r8]            ; Cargar el valor en la posición de destino

    cmp al, 95                  
    jne invalido_movimiento    

    mov byte[movimiento_realizado],0
    mov r10, [ficha_a_mover]        ; Posición actual de la ficha a mover
    sub r10, 1                      ; Ajustar a 0-index
    mov r11, [posicion_destino]     ; Posición a la que se quiere mover
    sub r11, 1

    ; Calcula la diferencia en la posición para verificar dirección y distancia
    mov r12, r10
    sub r12, r11                    ; r12 = diferencia de posiciones

    ; Verificar si es un movimiento normal (una casilla en cualquier dirección)
    cmp r12, -7
    je o_abajo
    cmp r12, 7
    je o_arriba
    cmp r12, -1
    je o_izquierda
    cmp r12, 1
    je o_derecha
    cmp r12, -8                    
    je o_diagonal_infder
    cmp r12, -6                    
    je o_diagonal_infizq
    cmp r12, 6                    
    je o_diagonal_supder
    cmp r12, 8                     
    je o_diagonal_supizq

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
    lea r8, [board + r13]   
    mov al, [ficha_soldado]        ; Dirección de la posición intermedia en el tablero
    cmp byte [r8], al          ; Comprobar si es un soldado ('X')
    jne invalido_movimiento

    ; Verificar que la posición de destino esté vacía
    lea r8, [board + r11]           ; Posición de destino
    cmp byte [r8], 95               ; Debe estar vacía ('_' o espacio)
    jne invalido_movimiento

    ; Aumenta el contador de capturas y elimina el soldado capturado
    add qword [capturas], 1         ; Incrementa el contador de capturas
    mov byte [board + r13], 95      ; Elimina el soldado en la posición intermedia, colocando espacio vacío
    mov byte[es_captura], 1      
    jmp mov_valido


o_abajo:
    add qword [oficial_abajo], 1
    jmp mov_valido

o_arriba:
    add qword [oficial_arriba], 1
    jmp mov_valido

o_diagonal_supizq:
    add qword [oficial_diagonalsupizq], 1
    jmp mov_valido

o_diagonal_supder:
    add qword [oficial_diagonalsupder], 1
    jmp mov_valido

o_diagonal_infizq:
    add qword [oficial_diagonalinfizq], 1
    jmp mov_valido

o_diagonal_infder:
    add qword [oficial_diagonalinfder], 1
    jmp mov_valido

o_derecha:
    add qword [oficial_derecha], 1
    jmp mov_valido

o_izquierda:
    add qword [oficial_izquierda], 1
    jmp mov_valido
    
    
validar_movimiento_soldado:
    mov r9, [posicion_destino]   ; Cargar la posición de destino
    sub r9, 1                    ; Ajustar a índice 0
    lea r8, [board + r9]         ; Apuntar a la nueva posición en el tablero
    mov al, byte [r8]            ; Cargar el valor en la posición de destino

    cmp al, 95                   ; Comprobar si la posición contiene '95' (vacía)
    jne invalido_movimiento   


    mov byte[movimiento_realizado],0
    mov r10, [ficha_a_mover]        ; Posición actual de la ficha a mover
    sub r10, 1                      ; Ajustar a 0-index
    mov r11, [posicion_destino]     ; Posición a la que se quiere mover
    sub r11, 1

    ; Calcula la diferencia en la posición para verificar dirección y distancia
    mov r12, r10
    sub r12, r11                    ; r12 = diferencia de posiciones


    cmp byte[orientacion_tablero], 1
    je orientacion1
    cmp byte[orientacion_tablero], 2
    je orientacion2
    cmp byte[orientacion_tablero], 3
    je orientacion3
    cmp byte[orientacion_tablero], 4
    je orientacion4
 
    ; Movimiento no permitido si no cumple ninguna condición
    jmp invalido_movimiento

; Tomo como orientacion 1 fortaleza abajo, orientacion 2 fortaleza a la derecha, orientacion 3 arriba,orientacion 4 izquierda

orientacion1:
    cmp byte[ficha_a_mover], 29
    je solo_der
    cmp byte[ficha_a_mover], 34
    je solo_izq
    cmp byte[ficha_a_mover], 35
    je solo_izq
    cmp byte[ficha_a_mover], 30
    je solo_der

    cmp r12, -7                    ; Hacia abajo
    je mov_valido
    cmp r12, -8                    ; Diagonal superior izquierda
    je mov_valido
    cmp r12, -6                    ; Diagonal superior derecha
    je mov_valido

    jmp invalido_movimiento

orientacion2:
    cmp byte[ficha_a_mover],5
    je solo_abajo
    cmp byte[ficha_a_mover],12
    je solo_abajo
    cmp byte[ficha_a_mover],40
    je solo_arriba
    cmp byte[ficha_a_mover],47
    je solo_arriba


    cmp r12, -1                     
    je mov_valido
    cmp r12, 6                     ; Diagonal inferior izquierda
    je mov_valido
    cmp r12, -8                    ; Diagonal superior izquierda
    je mov_valido
    jmp invalido_movimiento


orientacion3:
    cmp byte[ficha_a_mover],15
    je solo_der
    cmp byte[ficha_a_mover],16
    je solo_der
    cmp byte[ficha_a_mover],20
    je solo_izq
    cmp byte[ficha_a_mover],21
    je solo_izq

    cmp r12, 7                     ; Hacia arriba
    je mov_valido
    cmp r12, 6                     ; Diagonal inferior izquierda
    je mov_valido
    cmp r12, 8                     ; Diagonal inferior derecha
    je mov_valido
    jmp invalido_movimiento

orientacion4:
    cmp byte[ficha_a_mover],3
    je solo_abajo
    cmp byte[ficha_a_mover],10
    je solo_abajo
    cmp byte[ficha_a_mover],38
    je solo_arriba
    cmp byte[ficha_a_mover],45
    je solo_arriba
   
    cmp r12, 1                     
    je mov_valido
    cmp r12, 8                     ; Diagonal inferior derecha
    je mov_valido
    cmp r12, -6                    ; Diagonal superior derecha
    je mov_valido
    jmp invalido_movimiento





solo_izq:
    cmp r12, 1                    
    je mov_valido
    jmp invalido_movimiento
    

solo_der:
    cmp r12, -1                     
    je mov_valido
    jmp invalido_movimiento

solo_arriba:
    cmp r12, 7                     
    je mov_valido
    jmp invalido_movimiento

solo_abajo:
    cmp r12, -7                    
    je mov_valido
    jmp invalido_movimiento

invalido_movimiento:
    mov rdi, destino_invalido
    call   printf
    mov byte[movimiento_realizado],1
    ret

    
comprobar_captura:
    cmp byte[es_captura],0
    je eliminar_oficial
    cmp byte[es_captura],1
    je mover
    ret

eliminar_oficial:
    mov byte[hay_captura_posible], 0
    mov r9, [ficha_a_mover]      
    sub r9, 1                    ; Ajustar la posición de la ficha (de 1 a 0-indexado)
    lea r8, [board + r9]         ; Apuntamos a la posición de la ficha original
    mov byte[r8], 95
    add byte[oficiales_eliminados],1
    ret
