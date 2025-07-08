## C64 KERNAL ROUTINES
clear_screen: $FF5B, $FF81
SETLFS(set file parameters): $FFBA
SETNAM(set filename): $FFBD
OPEN(open a file): $FFC0
CLOSE(close a file): $FFC3

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
```text
ll "hello.lbl"
bk .main
g .main
z (step)
n (next)
m (memory map)
```

## TODO
  - read file and print file content on the screen
    - compare with C code for reading a file
  - solve AOC day 1 problem
  - compare line by line implementation of "If Else" block written by the complier

## TWO's Complement Reminders
  - (~B) + 1 
  - apply two's complement before adding two numbers with neg

## Floating point Reminders


## 6502 Architecture Misc.
  - SBC requires Carry to correctly handle minus
