extern board
extern turnoActual 

section .data
    archivoGuardado    db 'saved_game.bin', 0
    mode_write_text    db 'w', 0         ; Modo de texto de escritura (asegúrate de solo usar 'w' si quieres truncar)
    mode_write_bin     db 'wb', 0        ; Modo binario de escritura para fwrit
    error_cargar            db "Error al cargar"
    error_guardado          db "Error al guardar"
section .bss
    fileDescriptor resq 1
    fileHandle resq 1

section .text
    extern printf, fopen, write, fclose
    global save_game

save_game:
    sub rsp, 8

    ; Abre el archivo en modo binario de escritura
    mov rdi, archivoGuardado
    mov rsi, mode_write_bin
    call fopen

    test rax, rax             ; Verifica si fopen falló
    jz save_game_error        ; Salta a error si fopen devuelve 0

    ; Guarda el descriptor de archivo en fileHandle
    mov [fileHandle], rax

    
    ; Escribimos el turno actual (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, turnoActual              ; Turno actual
    mov rdx, 1                        ; Tamaño: 1 byte
    call write

    ; Escribimos el tablero completo (49 bytes)
    mov rdi, [fileDescriptor]
    mov rsi, board                    ; Dirección del tablero
    mov rdx, 49                       ; Tamaño del tablero
    call write

    ; Cierra el archivo
    mov rdi, [fileHandle]
    call fclose
    add rsp, 8
    ret

save_game_error:
    ; Imprime mensaje de error
    mov rdi, error_guardado
    call printf
    add rsp, 8
    ret

section .text
    extern printf, open, read, close
    global load_game

load_game:
    sub rsp, 8

    ; Abrimos el archivo en modo de solo lectura
    mov rdi, archivoGuardado   ; Nombre del archivo
    mov rsi, 0                        ; Modo de solo lectura
    call open

    ; Verifica si el archivo se abrió correctamente
    test rax, rax
    js load_game_error                ; Salta a error si open devuelve un valor negativo

    ; Guarda el descriptor de archivo en fileDescriptor
    mov [fileDescriptor], rax

    ; Cargamos el turno actual (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, turnoActual              ; Turno actual
    mov rdx, 1                        ; Tamaño: 1 byte
    call read

    ; Cargamos el tablero completo (49 bytes)
    mov rdi, [fileDescriptor]
    mov rsi, board                    ; Dirección del tablero
    mov rdx, 49                       ; Tamaño del tablero
    call read

    ; Cerramos el archivo
    mov rdi, [fileDescriptor]
    call close
    add rsp, 8
    ret

load_game_error:
    mov rdi, error_cargar
    call printf
    ; Cierra el archivo si fue abierto
    mov rax, [fileDescriptor]
    test rax, rax
    js .done
    mov rdi, rax
    call close
.done:
    add rsp, 8
    ret