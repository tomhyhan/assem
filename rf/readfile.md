### reading a file

1. dec stack pointer by 4
2. save pointer for file name string to stack
3. save pointer for file mode string to stack
\_fopen  
4. __fdesc: Allocate a new file stream
  1. read file table 
  2. for each FILE struct, find if file is closed(available)
  3. if open slot is FOUND, calculate the offset from filetab, save the address is register A and X and return
  4. Otherwise, if the file slots are all full, return 0.



 .struct _FILE
        f_fd        .byte
        f_flags     .byte
        f_pushback  .byte
.endstruct

__filetab:
        .byte   0, _FOPEN, 0    ; stdin
        .byte   1, _FOPEN, 0    ; stdout
        .byte   2, _FOPEN, 0    ; stderr
.repeat FOPEN_MAX - 3
        .byte   0, _FCLOSED, 0  ; free slot
.endrepeat

; Standard file descriptors

_stdin:
        .word   __filetab + (STDIN_FILENO * .sizeof(_FILE))

_stdout:
        .word   __filetab + (STDOUT_FILENO * .sizeof(_FILE))

_stderr:
        .word   __filetab + (STDERR_FILENO * .sizeof(_FILE))

