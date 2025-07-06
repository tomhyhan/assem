## C64 KERNAL ROUTINES
clear_screen = $FF5B, $FF81

## COMMANDS
*** compile example ***
cl65 -o file.prg -u __EXEHDR__ -g -d -Ln hello.lbl -t c64 -m hello.map -C c64-asm.cfg hello.s

*** vice example ***
x64sc

// attach without run?
sc -moncommands hello.lbl file.prg

## 6502 ASSEMBLY

*** addressing ***
immediate
absolute
zero page
indirect

## PROGRAM STRUCTURE
.bss
.data
.rodata
.code

stack
heap

## C64 MEMORY MAP
$400: start of screen

## DEBUG
ll "hello.lbl"
bk .main
g .main
z (step)
n (next)
m (memory map)

## TODO
1. use pointers to print out hello world
  - dont use sub when byte is not CHAR
2. read file and print file content on the screen
3. solve AOC day 1 problem
