# Definitions
FILENAME="main"
OUTPUT="$FILENAME.out"
FLAGS=$1

checkError () {
    if [ ! -f $1 ]; then
        echo "$2: ❌"
        exit 1 
    fi
}

# Script 
nasm -f elf64 -g -F dwarf -o save_load.o save_load.asm
nasm -f elf64 -g -F dwarf -o logic.o logic.asm
nasm -f elf64 -g -F dwarf -o graphics.o graphics.asm
nasm -f elf64 -g -F dwarf -o end_game.o end_game.asm
nasm -f elf64 -g -F dwarf -o personalizar.o personalizar.asm
nasm -f elf64 -g -F dwarf -l main.lst -o $FILENAME.o $FILENAME.asm
checkError $FILENAME.o "NASM"

gcc $FILENAME.o graphics.o save_load.o logic.o end_game.o personalizar.o -o $OUTPUT -no-pie
checkError $OUTPUT "GCC"
 
if [[ $FLAGS =~ "-d" ]] ; then
    gdb ./$OUTPUT
    exit 1
fi
./$OUTPUT
