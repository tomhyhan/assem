

%define end_of_file r12
%define curr_line r13
%define id [rsp + 0 * 8]
%define red [rsp + 1 * 8]
%define green [rsp + 2 * 8]
%define blue [rsp + 3 * 8]
%define accumulator rbx

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr_line, rax
  lea end_of_file, [rax+rdx]

  sub rsp, 4*8

.loop:
  add curr_line, 5

  ; find game id
  mov rdi, curr_line
  mov sil, ':'
  call find_char
  mov curr_line, rax
  mov rsi, rax
  call atol

  mov id, rax 

  add curr_line, 2 ; num start

  mov qword red, 0
  mov qword green, 0
  mov qword blue, 0
.loop_basket:
  ; find next num
  mov rdi, curr_line
  mov sil, ' '
  call find_char
  mov curr_line, rax
  mov rsi, rax
  call atol

  add curr_line, 1 ; skip space

  mov dl, [curr_line]

  cmp dl, 'r'
  jne .not_red

  add curr_line, 3

  cmp rax, red
  jng .end_loop_basket

  mov red, rax
  jmp .end_loop_basket

.not_red:
  cmp dl, 'g'
  jne .not_green

  add curr_line, 5

  cmp rax, green
  jng .end_loop_basket

  mov green, rax
  jmp .end_loop_basket

.not_green:
  add curr_line, 4

  cmp rax, blue
  jng .end_loop_basket

  mov blue, rax
  jmp .end_loop_basket

.end_loop_basket:
  mov dl, [curr_line]

  cmp dl, ';'
  je .end_basket
  cmp dl, 0x0a
  je .end_basket
  
  add curr_line, 2
  jmp .loop_basket

.end_basket:
  cmp dl, 0x0a
  je .compare

  cmp dl, ';'

  add curr_line, 2
  jmp .loop_basket

.compare:

  add curr_line, 1

  cmp qword red, 12
  jg .end_loop
  cmp qword green, 13
  jg .end_loop
  cmp qword blue, 14
  jg .end_loop

  add accumulator, id

.end_loop:

  cmp curr_line, end_of_file
  jl .loop

  call putlong
  call put_newline
  mov rax, 60
  mov rdi, 0
  syscall

put_newline:
  mov dil, 0x0a
  mov byte [rsp-1], dil
  
  mov rax, 1
  mov rdi, 1
  lea rsi, [rsp-1]
  mov rdx, 1
  syscall

  ret

putlong:
  mov rax, accumulator
  mov rdi, rsp
  mov rsi, 10

.loop:
  test rax, rax
  jz .end

  dec rdi

  mov rdx, 0
  div rsi

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

is_num:
  mov al, 0
  cmp dil, '0'
  jl .end
  cmp dil, '9'
  jg .end
  mov al, 1
.end:
  ret

find_char:
  mov rax, rdi
.loop:
  cmp sil, [rax]
  je .end

  inc rax
  jmp .loop

.end:
  ret

mmap:
  ; open file
  mov rax, 2
  mov rsi, 0 
  syscall 

  ; read file stat
  mov rdi, rax
  mov rax, 5
  mov rsi, statbuf
  syscall

  ; memory allocationg
  mov rax, 9 ; mmap
  mov r8, rdi ; fd
  mov rdi, 0 ; address
  mov rsi, [statbuf+48] ; length
  mov rdx, 3; protection: READ | WRITE
  mov r10, 2; flags: MAP_PRIVATE
  mov r9, 0; 
  syscall

  mov rdx, [statbuf+48]
  ret

atol:
  ; rdi - start
  ; rsi - end
  mov rax, 0
  mov rdx, 10
.loop:
  cmp rdi, rsi
  jge .end

  imul rax, rdx

  mov cl, [rdi]
  sub cl, '0'
  movzx rcx, cl
  add rax, rcx

  inc rdi
  jmp .loop

.end:
  ret

section .bss
  statbuf: resb 144