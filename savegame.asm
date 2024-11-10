extern fopen
extern fclose
extern puts
extern scanf
extern fread
extern printf

%macro call_function 1
sub     rsp,8
call    %1
add     rsp,8
%endmacro

section .data
    NOMBRE_ARCHIVO              db      "partidas_guardadas.dat", 0
    MODO_LECTURA                db      "rb", 0
    MODO_AGREGAR                db      "ab", 0
    ERROR_APERTURA              db      "Hubo un error al abrir el archivo.", 10, 0
    EXISTE_ARCHIVO              db      0                                               ; Se asume que el archivo no existe
    MENSAJE_CARGA_PARTIDA       db      "Ingrese la partida que desea cargar: ", 0
    MENSAJE_ERROR_NUM_PARTIDA   db      "El numero de partida no existe. Intente nuevamente.", 10, 0
    FORMATO_ENTRADA             db      "%i", 0
    TAMANIO_REGISTRO            db      168
    MENSAJE_DATOS_PARTIDA       db      "%i. %s.", 10, 0                        ; %i = numero de partida
                                                                                ; %s = nombre de partida

section .bss
    nombre_partida              resb    100
    id_archivo                  resq    1
    partida_elegida             resw    1
    numero_partidas_guardadas   resw    1
    tablero                     resb    49                                      ; Matriz 7x7 de elementos de un byte
    turno_actual                resb    1
    vector_movimientos          resw    4                                       ; Vector de movimientos:
                                                                                ; Vector[0] = Cantidad movimientos izquierda
                                                                                ; Vector[1] = Cantidad movimientos abajo
                                                                                ; Vector[2] = Cantidad movimientos derecha
                                                                                ; Vector[3] = Cantidad movimientos arriba
   fichas_oficiales             resb    1
   fichas_soldados              resb    1
   registro                     resb    TAMANIO_REGISTRO                        ; Formato del Registro:
                                                                                ; bytes 0-99 --> nombre de la partida
                                                                                ; bytes 100-148 --> tablero
                                                                                ; byte 149 --> turno actual
                                                                                ; bytes 150-157 --> vector de movimientos
                                                                                ; byte 158 --> ficha oficiales
                                                                                ; byte 159 --> ficha soldados

section .text

cargar_partida:
    call_function   mostrar_juegos_guardados

    mov             rdi, MENSAJE_CARGA
    call_function   puts

    mov             rdi, FORMATO_ENTRADA
    mov             rsi, partida_elegida
    call_function   scanf

    mov             ax, [partida_elegida]
    cmp             ax, [numero_partidas_guardadas]
    jg              error_numero_partida

    call_function   obtener_datos_partida
    call_function   cargar_datos_partida

    jmp             volver

error_numero_partida:
    mov             rdi, MENSAJE_ERROR_NUM_PARTIDA
    call_function   puts
    jmp             cargar_partida

mostrar_juegos_guardados:
    call_function   existe_archivo                                              ; Verifica si existe el archivo, y si no existe, lo crea
    call_function   abrir_archivo_lectura
    mov             r9, 1
    jmp             leer_registros

leer_registros:
    call_function   leer_archivo
    call_function   procesar_datos_partida
    mov             rdi, r9
    mov             rsi, nombre_partida
    call_function   printf
    inc             r9
    cmp             rax, 0
    jg              leer_registros

    jmp             volver

leer_archivo:
    mov             rdi, registro
    mov             rsi, [TAMANIO_REGISTRO]
    mov             rdx, 1
    mov             rcx, [id_archivo]
    call            fread

    cmp             rax, 0
    jle             EOF

    jmp             volver

EOF:
    jmp             volver

obtener_datos_partida:
    call_function   abrir_archivo_lectura
    mov             r8, [partida_elegida]

encontrar_partida:
    cmp             r8, 0
    jle             procesar_datos_partida

    mov             rdi, registro
    mov             rsi, [TAMANIO_REGISTRO]
    mov             rdx, 1
    mov             rcx, [id_archivo]
    call            fread

    cmp             rax, 0
    jle             EOF

    dec             r8
    jmp             encontrar_partida


procesar_datos_partida:
    lea             rsi, [registro]
    lea             rdi, [nombre_partida]
    mov             rcx, 100
    rep             movsb

    lea             rdi, [tablero]
    mov             rcx, 49
    rep             movsb

    lea             rdi, [turno_actual]
    mov             rcx, 1
    rep             movsb

    lea             rdi, [vector_movimientos]
    mov             rcx, 8
    rep             movsb

    lea             rdi, [ficha_oficial]
    mov             rcx, 1
    rep             movsb

    lea             rdi, [ficha_soldado]
    mov             rcx, 1
    rep             movsb

cargar_datos_partida:
    mov             rdi, tablero
    mov             rsi, [turno_actual]
    mov             rdx, vector_movimientos
    mov             rcx, fichas_oficiales
    mov             r8, fichas_soldados
    jmp             volver

existe_archivo:
    mov     al, [EXISTE_ARCHIVO]
    cmp     al, 1
    je      volver

    call_function   abrir_archivo_agregar
    call_function   cerrar_archivo
    jmp     volver

volver:
    ret

abrir_archivo_agregar:
     mov     rdi, NOMBRE_ARCHIVO
     mov     rsi, MODO_AGREGAR
     call_function   fopen

     cmp     rax, 0
     jle     manejar_error
     mov     byte [EXISTE_ARCHIVO], 1                                           ; Indica que el archivo existe
     mov     qword[id_archivo], rax
     jmp     volver

abrir_archivo_lectura:
    mov     rdi, NOMBRE_ARCHIVO
    mov     rsi, MODO_LECTURA
    call_function   fopen

    cmp     rax, 0
    jle     manejar_error
    mov     qword[id_archivo], rax
    jmp     volver

cerrar_archivo:
    mov     rdi, [id_archivo]
    call_function   fclose

