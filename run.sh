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
nasm -f elf64 -g -F dwarf -o graphics.o graphics.asm
nasm -f elf64 -g -F dwarf -l main.lst -o $FILENAME.o $FILENAME.asm
checkError $FILENAME.o "NASM"

gcc $FILENAME.o graphics.o -o $OUTPUT -no-pie
checkError $OUTPUT "GCC"
 
if [[ $FLAGS =~ "-d" ]] ; then
    gdb ./$OUTPUT
    exit 1
fi
./$OUTPUT
