extern board
extern ficha_soldado
extern ficha_oficial
extern printf
extern exit
extern capturas

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
    motivo_soldado          db  "Los soldados invadieron la base.",0
    motivo_oficial          db  "Los oficiales capturaron suficientes soldados.",0

    estadisiticas_texto     db  'Estadisticas:', 10, '~ Capturas: %i', 10, 0

section .text
    global comprobar_fin_juego

comprobar_fin_juego:
    cmp qword[capturas], 41
    jge juego_finalizado

    mov al, [board + 46]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 45]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 44]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 38]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 37]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 36]
    cmp al, [ficha_soldado]
    jne continue

    mov al, [board + 31]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 30]
    cmp al, [ficha_soldado]
    jne continue
    mov al, [board + 29]
    cmp al, [ficha_soldado]
    jne continue

    jge juego_finalizado

continue:   
    ret

juego_finalizado:
    mov rdi, fin_del_juego_texto
    call_function printf

    mov rdi, ganador_es
    mov rsi, [ficha_oficial]
    mov rdx, motivo_oficial

    cmp qword[capturas], 41
    jge gano_oficial
    mov rsi, [ficha_soldado]
    mov rdx, motivo_soldado
    
gano_oficial:
    call_function printf

    mov rdi, estadisiticas_texto
    mov rsi, [capturas]
    call_function printf

    jmp exit