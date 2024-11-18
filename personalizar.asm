extern printf
extern scanf
extern getchar
extern ficha_soldado
extern ficha_oficial
extern board

%macro printCadena 1
    mov rdi,%1
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

%macro call_function 1
    sub     rsp,8
    call    %1
    add     rsp,8
%endmacro
 
section .data
    global personalizar_fichas
    global reemplazar_simbolos
    global reemplazar_soldados
    global reemplazar_oficiales
    texto_personalizar db 'Desea personalizar las fichas? (s/n): ', 0
    texto_ficha_soldados db 'Ingrese el caracter para las fichas de los soldados: ', 0
    texto_ficha_oficiales db 'Ingrese el caracter para las fichas de los oficiales: ', 0
    inputFormat db "%c", 0
    mensaje_personalizando db 'Personalizando fichas', 10, 0
    mensaje_no_personalizando db 'No se personalizarán las fichas', 10, 0

section .bss
    respuesta_personalizar resb 1

section .text
global personalizar_fichas
global reemplazar_simbolos
global reemplazar_soldados
global reemplazar_oficiales

personalizar_fichas:
    printCadena texto_personalizar
    call clear_input_buffer  ; Limpiar el buffer de entrada
    call getchar
    mov [respuesta_personalizar], al
    ; Asegúrate de que la entrada se haya leído correctamente
    mov al, [respuesta_personalizar]
    cmp al, 's'
    jne no_personalizar
    printCadena mensaje_personalizando
    call personalizar
    jmp fin_personalizar

personalizar:
    call personalizar_soldados
    call personalizar_oficiales
    call reemplazar_simbolos
    jmp fin_personalizar

no_personalizar:
    printCadena mensaje_no_personalizando

fin_personalizar:
    ret

personalizar_soldados:
    printCadena texto_ficha_soldados
    mov rdi, inputFormat
    mov rsi, ficha_soldado
    sub rsp, 8
    call scanf
    add rsp, 8
    call clear_input_buffer  ; Limpiar el buffer de entrada
    ret

personalizar_oficiales:
    printCadena texto_ficha_oficiales
    mov rdi, inputFormat
    mov rsi, ficha_oficial
    sub rsp, 8
    call scanf
    add rsp, 8
    call clear_input_buffer  ; Limpiar el buffer de entrada
    ret

clear_input_buffer:
    sub rsp, 8
clear_loop:
    call getchar
    cmp al, 10
    jne clear_loop
    add rsp, 8
    ret

reemplazar_simbolos:
    ; Llamamos a las funciones específicas para reemplazar soldados y oficiales
    call reemplazar_soldados
    call reemplazar_oficiales
    ret

reemplazar_soldados:
    lea rdi, [board]         ; Cargar la dirección de la matriz en RDI
    mov rcx, 49              ; Número de elementos (7x7 = 49)
    mov al, [ficha_soldado]
; Cargar ficha_soldado en AL

modificar_loop_soldados:
    cmp byte [rdi], 'X'      ; Comparar si es 'X'
    jmp siguiente_elemento_soldados
    mov byte [rdi], al       ; Reemplazar en la matriz

siguiente_elemento_soldados:
    inc rdi                  ; Mover al siguiente elemento de la matriz
    loop modificar_loop_soldados       ; Si no hemos recorrido todos los elementos, continuar el loop

    ret

reemplazar_oficiales:
    lea rdi, [board]         ; Cargar la dirección de la matriz en RDI
    mov rcx, 49              ; Número de elementos (7x7 = 49)
    mov al, [ficha_oficial]  ; Cargar ficha_oficial en AL

modificar_loop_oficiales:
    cmp byte [rdi], 'O'      ; Comparar si es 'O'
    jne siguiente_elemento_oficiales
    mov byte [rdi], al       ; Reemplazar en la matriz

siguiente_elemento_oficiales:
    inc rdi                  ; Mover al siguiente elemento de la matriz
    loop modificar_loop_oficiales       ; Si no hemos recorrido todos los elementos, continuar el loop

    ret
