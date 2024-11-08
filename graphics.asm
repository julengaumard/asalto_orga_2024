extern printf 
extern scanf 

%macro printCadena 1
mov rdi,%1
sub     rsp,8
call    printf
add     rsp,8
%endmacro
 
section .data
    titulo  db 10
            db ' $$$$$$\                      $$\   $$\                     ', 10
            db  '$$  __$$\                     $$ |  $$ |                   ', 10
            db '$$ /  $$ | $$$$$$$\  $$$$$$\  $$ |$$$$$$\    $$$$$$\        ', 10
            db '$$$$$$$$ |$$  _____| \____$$\ $$ |\_$$  _|  $$  __$$\       ', 10
            db '$$  __$$ |\$$$$$$\   $$$$$$$ |$$ |  $$ |    $$ /  $$ |      ', 10
            db '$$ |  $$ | \____$$\ $$  __$$ |$$ |  $$ |$$\ $$ |  $$ |      ', 10
            db '$$ |  $$ |$$$$$$$  |\$$$$$$$ |$$ |  \$$$$  |\$$$$$$  |      ', 10
            db '\__|  \__|\_______/  \_______|\__|   \____/  \______/       ', 10
            db 0

    menu    db 10
            db '1. Iniciar Juego', 10
            db '2. Crear Juego Personalizado', 10
            db '3. Cargar Partida', 10
            db '4. Salir', 10
            db 10
            db 'Opcion: ', 0

    inputFormat      db      "%i",0 
    emsg             db      10,'ERROR: Ingrese un numero valido.',10,10,0 

    posicion_tablero    db 88, 88,  3,  4,  5, 88, 88
                        db 88, 88, 10, 11, 12, 88, 88
                        db 15, 16, 17, 18, 19, 20, 21
                        db 22, 23, 24, 25, 26, 27, 28
                        db 29, 30, 31, 32, 33, 34, 35
                        db 88, 88, 38, 39, 40, 88, 88
                        db 88, 88, 45, 46, 47, 88, 88

    formato_tablero         db  ' %c ',0 
    formato_tablero_salto   db  ' %c ',10,0
    titulo_tablero          db  10,'Tablero:                                Posiciones del tablero:',10,0
    desplaza_tablero        dq  0
    contador_numeros        dq  0
    largo_linea2            db  7
    contador_fila           db  0

    separador_nums          db  '                  ',0 
    formato_nums            db  ' %d ',0
    formato_nums_espacio    db  ' %d  ',0
    formato_nums_no_num     db  '    ',0
    salto_linea             db  10,0
    
 
section .bss
    opcion resw 1
    puntero_tablero resq 1

section .text
    global print_menu 
    global print_tablero_new

print_menu:
    printCadena titulo
    printCadena menu

    mov rdi,inputFormat
    mov rsi,opcion
    sub     rsp,8
    call    scanf   
    add     rsp,8
    cmp     rax,1
    jl      error
    cmp     dword[opcion],4
    jg      error
    cmp     dword[opcion],1
    jl      error

    mov     ah, [opcion]
    ret
 
error: 
    mov     al, 0
    printCadena emsg
    ret



print_tablero_new:

    mov     [puntero_tablero], rdi 

    mov     rdi,titulo_tablero
    sub     rsp,8
    call    printf
    add     rsp,8
 
continue_print:
    
    mov r15, [puntero_tablero]
    add r15, [desplaza_tablero]
    
    mov     rsi,[r15]
    mov     rdi,formato_tablero

    sub     rsp,8
    call    printf
    add     rsp,8 

    mov ax, word[desplaza_tablero] 
    div byte[largo_linea2]
    cmp ah, 6
    je imprimir_fila_numeros

continuar_tablero:
    add qword[desplaza_tablero], 1
    cmp qword[desplaza_tablero], 49
    jne continue_print

    ret


imprimir_fila_numeros: 

    mov     qword[contador_numeros], 0
    mov     rdi,separador_nums
    sub     rsp,8
    call    printf
    add     rsp,8 


resto_numeros:

    lea rax, [contador_fila]         
    movzx rax, byte [rax] 

    lea rsi, [contador_numeros]         
    movzx rsi, byte [rsi]    
    add rsi,rax 

    lea rdi, [posicion_tablero]    
    movzx rsi, byte [rdi + rsi]

    cmp rsi, 10
    jl  agregar_espacio_num
    cmp rsi, 88
    je  imprimir_espacio_vacio

    mov     rdi,formato_nums
    
imprimir_numero:
    sub     rsp,8
    call    printf
    add     rsp,8 

    
    add qword[contador_numeros], 1
    cmp qword[contador_numeros], 7
    
    jne resto_numeros

    add qword[contador_fila],7

    mov     rdi,salto_linea
    sub     rsp,8
    call    printf
    add     rsp,8 

    jmp     continuar_tablero


agregar_espacio_num:
    mov     rdi,formato_nums_espacio
    jmp     imprimir_numero

imprimir_espacio_vacio:
    mov     rdi,formato_nums_no_num
    jmp     imprimir_numero

    