extern board
extern ficha_soldado
extern ficha_oficial
extern printf
extern exit
extern capturas
extern oficial_arriba
extern oficial_abajo
extern oficial_derecha
extern oficial_izquierda
extern oficial_diagonalsupizq
extern oficial_diagonalsupder
extern oficial_diagonalinfizq
extern oficial_diagonalinfder
extern orientacion_tablero
extern oficiales_eliminados
extern verificar_mov_oficial
extern ficha_a_mover
extern es_movimiento_posible
; extern hay_captura_posible (Por si al final solo habia que eliminar al oficial que se mueve)
%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro

section .data
    fin_del_juego_texto     db 10
                            db ' ____  __  __ _    ____  ____  __        __  _  _  ____  ___   __', 10
                            db '(  __)(  )(  ( \  (    \(  __)(  )     _(  )/ )( \(  __)/ __) /  \', 10
                            db ' ) _)  )( /    /   ) D ( ) _) / (_/\  / \) \) \/ ( ) _)( (_ \(  O )', 10
                            db '(__)  (__)\_)__)  (____/(____)\____/  \____/\____/(____)\___/ \__/ ', 10,0

    ganador_es              db  10, 'EL GANADOR DE LA PARTIDA ES [%c]', 10, 'Motivo: [%s]', 10, 0
    motivo_invadieron       db  "Los soldados invadieron la base.",0
    motivo_capturaron       db  "Los oficiales capturaron suficientes soldados.",0
    motivo_sin_movimientos  db  "Los oficiales no tienen movimientos disponibles.",0
    motivo_sin_oficiales    db  "No hay mas oficiales en juego.",0

    estadisiticas_texto     db  10, 'Estadisticas:', 10, '# Capturas: %i', 10, 0
    soldado_texto           db '# Movimientos soldados:',10,0 
    oficial_texto           db '# Movimientos de los oficiales',10,0 
    movimientos_texto       db '  ~ Arriba:    %i', 10, '  ~ Abajo:     %i', 10, '  ~ Derecha:   %i', 10, '  ~ Izquierda: %i',10, 0
    diagonales_texto        db '  ~ Diagonal superior derecha:   %i',10,'  ~ Diagonal superior izquierda: %i',10 ,'  ~ Diagonal inferior derecha:   %i', 10, '  ~ Diagonal inferior izquierda: %i',10,  0
    contador                dq 1
    hay_movimientos         dq 0
    oficiales_sin_movimiento db 0 
    oficial_con_movimiento  db 0
    oficiales_chequeados db 0

section .text
    global comprobar_fin_juego

comprobar_fin_juego:
    cmp qword[capturas], 15
    jg juego_finalizado

    cmp byte[oficiales_eliminados],2
    je juego_finalizado

    jmp comprobar_sin_movimientos

seguir_comprobando:
    cmp byte[orientacion_tablero], 1
    je orientacion_original

    cmp byte[orientacion_tablero], 2
    je orientacion_90

    cmp byte[orientacion_tablero], 3
    je orientacion_180

    jmp orientacion_270

continue:   
    ret

juego_finalizado:
    mov rdi, fin_del_juego_texto
    call_function printf

    mov rdi, ganador_es
    mov rsi, [ficha_oficial]
    mov rdx, motivo_capturaron

    cmp qword[hay_movimientos], 1
    jne sin_movimientos

    cmp qword[capturas], 15
    jg no_modificar_motivo

    mov rsi, [ficha_soldado]
    mov rdx, motivo_invadieron

    cmp byte[oficiales_eliminados],2
    jne no_modificar_motivo

    mov rdx, motivo_sin_oficiales
    je no_modificar_motivo

sin_movimientos:
    mov rsi, [ficha_soldado]
    mov rdx, motivo_sin_movimientos
    
no_modificar_motivo:
    call_function printf

    mov rdi, estadisiticas_texto
    mov rsi, [capturas]
    call_function printf
    mov rdi, oficial_texto
    call_function printf
    mov rdi, movimientos_texto
    mov rsi, [oficial_arriba]
    mov rdx, [oficial_abajo]
    mov rcx, [oficial_derecha]
    mov r8, [oficial_izquierda]
    call_function printf
    mov rdi, diagonales_texto
    mov rsi, [oficial_diagonalsupder]
    mov rdx, [oficial_diagonalsupizq]
    mov rcx, [oficial_diagonalinfder]
    mov r8, [oficial_diagonalinfizq]
    call_function printf
    jmp exit


orientacion_original:
    mov al, [board + 46]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 45]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 44]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 39]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 38]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 37]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 32]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 31]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 30]
    cmp al, [ficha_soldado]
    jne continue

    jmp juego_finalizado

orientacion_90:
    mov al, [board + 18]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 19]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 20]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 25]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 26]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 27]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 32]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 33]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 34]
    cmp al, [ficha_soldado]
    jne continue

    jmp juego_finalizado

orientacion_180:
    mov al, [board + 2]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 3]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 4]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 9]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 10]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 11]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 16]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 17]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 18]
    cmp al, [ficha_soldado]
    jne continue

    jmp juego_finalizado

orientacion_270:
    mov al, [board + 14]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 15]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 16]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 21]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 22]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 23]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 28]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 29]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 30]
    cmp al, [ficha_soldado]
    jne continue

    jmp juego_finalizado


comprobar_sin_movimientos:
    mov qword [contador], 0

    
evaluar_siguiente:
    mov r9, [contador]
    inc r9
    mov qword[contador], r9

    mov qword[hay_movimientos], 0
    cmp qword[contador], 48
    je juego_finalizado
    mov qword[hay_movimientos], 1
 
    lea r8, [board + r9]            
    mov al, byte [r8]               
    cmp al, byte [ficha_oficial]   
    jne evaluar_siguiente 

    add byte[oficiales_chequeados], 1
    inc r9
    mov [ficha_a_mover], r9
    call_function verificar_mov_oficial
    cmp rax, 1
;   mov byte[hay_captura_posible], 0
    je oficial_disponible
    
    cmp byte[oficial_con_movimiento], 2
    jne comprobar_num_oficiales ; Si al menos 1 tiene, ya podes jugar asi que dejamos de buscar oficiales para chequear.


oficial_disponible:
    add byte[oficial_con_movimiento], 1
    

comprobar_num_oficiales:
    cmp byte[oficiales_eliminados], 1
    je seguir_comprobando
    jne comprobar_oficial_restante


comprobar_oficial_restante:
    cmp byte[oficiales_chequeados], 2
    jne evaluar_siguiente
    je seguir_comprobando






