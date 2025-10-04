; convert registers into names
; define putlong function

%define end_of_file r12
%define curr_line r13
%define accumulator r14
%define curr_char r15
%define curr_charb r15b
%define end_of_line r13

section .text
  global _start:function                        

_start:
  call mmap

  mov curr_line, rax
  lea end_of_file, [rax+rdx]
  
  xor accumulator, accumulator
loop:

  mov curr_char, curr_line

find_num_left:
  mov dil, [curr_char]
  call is_num
  test al, al
  jnz end_find_num_left

  inc curr_char
  jmp find_num_left

end_find_num_left:

  mov curr_charb, [curr_char]
  sub curr_charb, '0'
  movzx curr_char, curr_charb

  lea accumulator, [accumulator+curr_char*8]
  lea accumulator, [accumulator+curr_char*2]

  mov rdi, 0x0a
  call find_char
  lea end_of_line, [rax+curr_line]; r12+r14: end of line

  lea curr_char, [end_of_line-1]
find_num_right:
  mov dil, [curr_char]
  call is_num
  test al, al
  jnz end_find_num_right

  dec curr_char
  jmp find_num_right

end_find_num_right:
  mov curr_charb, [curr_char]
  sub curr_charb, '0'
  movzx curr_char, curr_charb

  lea accumulator, [accumulator+curr_char]
  inc end_of_line
  mov curr_line, end_of_line

  cmp curr_line, end_of_file
  jl loop

  call putlong
  call put_newline

  mov rax, 60
  mov rdi, 0
  syscall

find_char:
  mov rax, 0
.loop:
  cmp [curr_line+rax], dil
  je .end

  mov rsi, curr_line
  add rsi, rax
  cmp rsi, end_of_file
  jge .end

  inc rax
  jmp .loop

.end:
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

putlong:
  mov rdi, rsp
  mov rsi , 10
  mov rax, accumulator

.loop:
  test rax, rax
  jz .end

  dec rdi

  xor rdx, rdx
  div rsi ; remainder rdx
  add dl, '0'
  mov [rdi], dl

  jmp .loop

.end:
  mov rax, 1
  mov rsi, rdi
  mov rdi, 1
  mov rdx, rsp
  sub rdx, rsi
  syscall
  
  ret

put_newline:
  mov byte [rsp-1], 0x0a

  mov rax, 1
  lea rsi, [rsp-1]
  mov rdi, 1
  mov rdx, 1
  syscall
  
  ret

is_num:
  mov al, 0

  cmp dil, '0'
  jl .end
  cmp dil, '9'
  jg .end

  mov al, 1
.end:
  ret

section .data
  file_name: db "./input.txt",0

section .bss
  statbuf: resb 144