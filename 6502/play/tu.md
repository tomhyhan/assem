cc65 -O -t c64 hello.c
ca65 hello.s
ca65 -t c64 text.s

ld65 -o hello -t c64 hello.o text.o c64.lib

OR

cl65 -O hello.c text.s
