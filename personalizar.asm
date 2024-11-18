extern printf
extern scanf
extern getchar
extern ficha_soldado
extern ficha_oficial
extern board
extern turnoActual
extern exit
extern game

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
    global clear_input_buffer
    texto_personalizar db 'Desea personalizar las fichas? (s/n): ', 0
    texto_ficha_soldados db 'Ingrese el caracter para las fichas de los soldados: ', 0
    texto_ficha_oficiales db 'Ingrese el caracter para las fichas de los oficiales: ', 0
    inputFormat db "%c", 0
    mensaje_personalizando db 'Personalizando fichas', 10, 0
    mensaje_no_personalizando db 'No se personalizarán las fichas', 10, 0
    texto_quien_comienza db 'Quien comienza? (1: Soldados, 2: Oficiales): ', 0
    comienza db 0

section .bss
    respuesta_personalizar resb 1

section .text
global personalizar_fichas
global reemplazar_simbolos
global reemplazar_soldados
global reemplazar_oficiales
global quien_comienza

personalizar_fichas:
    printCadena texto_personalizar
    call clear_input_buffer  ; Limpiar el buffer de entrada
    call getchar
    cmp al, '1'
    jl exit
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
    mov byte[ficha_soldado], 88
    mov byte[ficha_oficial], 79

fin_personalizar:
    mov al, [ficha_soldado]
    mov byte[turnoActual], al
    ret

personalizar_soldados:
    printCadena texto_ficha_soldados
    call clear_input_buffer  ; Limpiar el buffer de entrada
    call getchar
    mov [ficha_soldado], al
    ret

personalizar_oficiales:
    printCadena texto_ficha_oficiales
    call clear_input_buffer  ; Limpiar el buffer de entrada
    call getchar
    mov [ficha_oficial], al
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
    cmp byte [rdi], 88      ; Comparar si es 'X'
    jne siguiente_elemento_soldados
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
    cmp byte [rdi], 79      ; Comparar si es 'O'
    jne siguiente_elemento_oficiales
    mov byte [rdi], al       ; Reemplazar en la matriz

siguiente_elemento_oficiales:
    inc rdi                  ; Mover al siguiente elemento de la matriz
    loop modificar_loop_oficiales       ; Si no hemos recorrido todos los elementos, continuar el loop

    ret

quien_comienza:
    ; Solicitar al usuario que elija quién comienza
    mov rdi, texto_quien_comienza
    call_function printf
    call_function clear_input_buffer
    call_function getchar
    mov [comienza], al
    cmp byte[comienza], "1"
    je game
    cmp byte[comienza], "2"
    je cambiar_turno
    ret

cambiar_turno:
    mov al, [ficha_oficial]
    mov byte [turnoActual], al ; Cambiar turno a los oficiales
    jmp game