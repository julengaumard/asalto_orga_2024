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

    posicion_tablero    db 01, 32, 88, 88, 88, 32, 32
                        db 32, 32, 88, 88, 88, 32, 32
                        db 88, 88, 88, 88, 88, 88, 88
                        db 88, 88, 88, 88, 88, 88, 88
                        db 88, 88, 95, 95, 95, 88, 88
                        db 32, 32, 95, 95, 79, 32, 32
                        db 32, 32, 79, 95, 95, 32, 32

    formato_tablero         db  ' %c ',0 
    formato_tablero_salto   db  ' %c ',10,0
    titulo_tablero          db  10,'Tablero:                        Posiciones:',10,0
    desplaza_tablero        dq  0
    largo_linea2             db  7
 
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

    mov ax, word[desplaza_tablero] 
    div byte[largo_linea2]
    cmp ah, 6
    je hay_salto

continuo_imprimendo: 
    sub     rsp,8
    call    printf
    add     rsp,8 

    add qword[desplaza_tablero], 1
    cmp qword[desplaza_tablero], 49
    jne continue_print

    ret

hay_salto: 
    mov     rdi,formato_tablero_salto
    jmp     continuo_imprimendo