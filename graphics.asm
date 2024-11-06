extern printf 
extern scanf 

%macro printCadena 1
mov rdi,%1
sub     rsp,8
call    printf
add     rsp,8
%endmacro

section .data
    titulo  db ' $$$$$$\                      $$\   $$\                     ', 10
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
            db '2. Salir', 10
            db 10
            db 'Opcion: ', 0
 
section .text
    global print_menu 

print_menu:
    printCadena titulo
    printCadena menu
    ret
 