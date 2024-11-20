extern board
extern turnoActual
extern menu
extern ficha_soldado
extern ficha_oficial
extern orientacion_tablero
extern oficiales_eliminados

section .data
    archivoGuardado    db 'saved_game.bin', 0
    mode_write_flags   dq 0x241         ; O_WRONLY | O_CREAT | O_TRUNC
    permisos           dq 0644          ; Permisos de archivo
    
    error_cargar       db "Error al cargar", 10, 0
    error_guardado     db "Error al guardar", 10, 0
    no_guardado        db "No hay partida guardada. Selecciona otra opción", 10, 0

section .bss
    fileDescriptor resq 1
    fileHandle resq 1

section .text
    extern printf, open, write, close, access
    global save_game, load_game

save_game:
    sub rsp, 8

    ; Abre el archivo en modo de escritura, crea el archivo si no existe, y trunca si existe
    mov rdi, archivoGuardado        ; Nombre del archivo
    mov rsi, 0x241                  ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0644                   ; Permisos del archivo (rw-r--r--)
    call open

    test rax, rax                   ; Verifica si open falló
    js save_game_error              ; Salta a error si open devuelve un valor negativo

    ; Guarda el descriptor de archivo en fileHandle
    mov [fileHandle], rax

   
    ; Escribimos el turno actual (1 byte)
    mov rdi, [fileHandle]           ; Descriptor de archivo
    mov rsi, turnoActual            ; Turno actual
    mov rdx, 1                      ; Tamaño: 1 byte
    call write

    ; Escribimos el tablero completo (49 bytes)
    mov rdi, [fileHandle]           ; Descriptor de archivo
    mov rsi, board                  ; Dirección del tablero
    mov rdx, 49                     ; Tamaño del tablero
    call write

    ; Escribimos el oficial (1 byte)
    mov rdi, [fileHandle]           
    mov rsi, ficha_oficial           
    mov rdx, 1                      ; Tamaño: 1 byte
    call write

    ; Escribimos el soldado(1 byte)
    mov rdi, [fileHandle]           
    mov rsi, ficha_soldado            
    mov rdx, 1                      ; Tamaño: 1 byte
    call write

    ; Escribimos la orientacion (1 byte)
    mov rdi, [fileHandle]           
    mov rsi, orientacion_tablero    ; orientacion
    mov rdx, 1                      ; Tamaño: 1 byte
    call write

    ; Escribimos cantidad oficiales eliminados (1 byte)
    mov rdi, [fileHandle]           
    mov rsi, oficiales_eliminados   
    mov rdx, 1                      ; Tamaño: 1 byte
    call write

    ; Cierra el archivo
    mov rdi, [fileHandle]
    call close

    add rsp, 8
    ret

save_game_error:
    mov rdi, error_guardado
    call printf
    add rsp, 8
    ret

section .text
    extern printf, open, read, close, access
    global load_game

load_game:
    sub rsp, 8

    ; Verificar si el archivo existe
    mov rdi, archivoGuardado
    mov rsi, 0          ; F_OK (verifica existencia del archivo)
    call access
    test rax, rax
    jnz no_saved_game   ; Si el archivo no existe, mostrar mensaje de error y regresar al menú

    ; Abrimos el archivo en modo de solo lectura
    mov rdi, archivoGuardado   ; Nombre del archivo
    mov rsi, 0                 ; Modo de solo lectura
    call open

    ; Verifica si el archivo se abrió correctamente
    test rax, rax
    js load_game_error         ; Salta a error si open devuelve un valor negativo

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

    ; Cargamos el oficial (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, ficha_oficial              ; Turno actual
    mov rdx, 1                        ; Tamaño: 1 byte
    call read

    ; Cargamos el soldado (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, ficha_soldado              ; Turno actual
    mov rdx, 1                        ; Tamaño: 1 byte
    call read

    ; Cargamos la orientacion (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, orientacion_tablero              ; Turno actual
    mov rdx, 1                        ; Tamaño: 1 byte
    call read

    ; Cargamos oficiales_eliminados (1 byte)
    mov rdi, [fileDescriptor]         ; Descriptor de archivo
    mov rsi, oficiales_eliminados         
    mov rdx, 1                        ; Tamaño: 1 byte
    call read

    ; Cerramos el archivo
    mov rdi, [fileDescriptor]
    call close
    add rsp, 8
    ret


no_saved_game:
    mov rdi, no_guardado
    call printf
    add rsp, 8
    jmp menu   ; Regresar al menú principal

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
    jmp menu   ; Regresar al menú principal
