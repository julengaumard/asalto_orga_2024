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
 
section .bss
    opcion resw 1

section .text
    global print_menu 

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