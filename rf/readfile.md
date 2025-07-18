### reading a file

1. dec stack pointer by 4
2. save pointer for file name string to stack
3. save pointer for file mode string to stack
\_fopen  
  1. __fdesc: Allocate a new file stream
    1. read file table 
    2. for each FILE struct, find if file is closed(available)
    3. if open slot is FOUND, calculate the offset from filetab, save the address is register A and X and return
    4. Otherwise, if the file slots are all full, return 0.
  2. __fopen: pass name, mode in stack. file pointer in register A and X.
    1. save file pointer to 'file' pointer variable (if you can call it a variable)
    2. read mode and save it to 'ptr1'
    3. parse mode by looking at each character
    4. if invliad mode, set a, x to 0, increase stack size by 4 
    5. if mode is ok, save the parsed mode in stack and call _open
      _open: 
        1. if param is ok, get flag and name
          1. fnparse: parse the file name
            1. if the first char in 0, check if it is digit
            2. if digit, and second char is ':', jump to drive done
            3. Otherwise, use the default drive '0:'
            4. length of file is 2
            5. if file is a 'file', read the name one char by char, save in 'fnbuf', and save length in 'fnlen'
            6. return
        2. free_fd: get a free file handle and remember it in tmp2
        3. compare tmp3 (mode) with read and write flags set
        4. if doread: add '.r' to filename and jump to common
        5. if dowrite: 
        # TODO: LFN? vs file table vs file handle?
        6. common: 
          1. tell kernal about filenameL pass in file length and file pointer
          2. tell kernal about file parameter: pass in Logic File Number and device
          3. tell kernal to open the file
          4. open device channel, if disk is 0, simply return 0
          5. load current LNF mode to file handle offset by tmp2
          6. also save device number to unittab
          7. transfer file handle offset from x to a, load 0 to a, return
    6. if open was ok, save file pointer to ptr1
    7. load file handle offset to file table 'fd'
    8. store file table flag to '_FOPEN'
    9. load prt1 address to register A and X, return (file table)
4. save register A and X (file table (_FILE)) to stack
5. Load ax from offset in stack
6. _fgetc
  1. _FILE to ptr1
  2. baskup A and X register
  3. checkferror: check if file is open
  4. check if there is no push back char call do_read
  5. do_read
    1. push fd to stack
    2. push buffer (size: byte 1) to stack
    3. load 1 to a, 0 to x
    4. call _read: int read (int fd, void* buf, unsigned count);
      # TODO: how to handle params in stack and a & x register
      _read


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

