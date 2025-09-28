; TODO: Lets read a file put file into memory and print first 5 chars


section .text
  global _start:function                        

_start:
  call mmap

  mov r12, rax
  lea r13, [rax+rdx]

.loop:
  mov r14, '\n'
  call find
  mov r14, rax; r12+r14: end of line

  mov rax, 0
find_num_left:
  
  inc rax
  cmp r13+rax, 0xa
  jg  find_num


  ; System call exit (sys_exit)
  ; rax = 60 (syscall number for exit)
  ; rdi = 0 (exit status 0, success)
  mov rax, 60
  mov rdi, 0
  syscall

find_char:
  move rax, 0
find:
  cmp r12+rax, r14
  inc rax
  jne find

  ret

mmap:
  ; syscall open
  mov rax, 2
  mov rdi, file_name
  mov rsi, 0
  syscall

  ; syscall fstat
  mov rdi, rax
  mov rax, 5
  mov rsi, statbuf
  syscall

  ; unsigned long addr, unsigned long len, unsigned long prot, unsigned long flags, unsigned long fd, unsigned long off
  ;syscall mmap
  mov rax, 9
  mov r8, rdi ; rdi has opned fd
  mov rdi, 0
  mov rsi, [statbuf + 48]
  mov rdx, 3
  mov r10, 2
  mov r9, 0
  syscall 

  mov rdx, rsi
  ret


section .data
  file_name: db "./input.txt",0
  ; msg: times 16 db 0  
  ; len equ $ - msg                     

section .bss
  statbuf: resb 144
  msg:     resb 0x10


