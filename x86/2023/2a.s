

%define end_of_file, r12
%define curr_char, r13

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov rax, 60
  mov rdi, 0
  syscall


mmap:
  ; open file
  mov rax, 2
  mov rsi, 0 
  syscall 
  ; read file stat
  ; memory allocationg
  ret

section .bss
  statbuf: resb 144