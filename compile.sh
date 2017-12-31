#!/bin/bash


input=""
output=""

usage() {
    echo "usage: ./compile_asm -i <input_file> -o <output_file>"
    echo "  input     : an assembly file to compile "
    echo "  output    : output c file"
    exit 1
}


while [ -n "$1" ]; do
    case "$1" in
        -i)
            shift; input="$1";;
        -o)
            shift; output="$1";;
        *)
            echo "invalid switch"
            usage;;
    esac
    shift
done

nasm -f elf64 "$input.nasm" -o "$input.o" &&
ld "$input.o" -o "$input" ;
code=$(for i in `objdump -d "$input" | tr '\t' ' ' | tr ' ' '\n' | egrep '^[0-9a-f]{2}$' `; do echo -n "\x$i" ; done )

printf "#include<stdio.h>\r\n#include<string.h>\n\runsigned char code[] = \\ \n" > "$input.c";
echo "\"$code\";" >> "$input.c";
printf "\n\nmain()\n{\n\tprintf(\"Shellcode Length: " >> "$input.c";
echo "%d\n\", strlen(code));" >> "$input.c";
printf "\tint (*ret)() = (int(*)())code;\n\tret();\n}" >> "$input.c";

gcc -fno-stack-protector -z execstack "$input.c" -o "$output";
