
%define end_of_file r12
%define curr r13
%define id    [rsp + 0 * 8]
%define red   [rsp + 1 * 8]
%define blue  [rsp + 2 * 8]
%define green [rsp + 3 * 8]
%define accumulator r14

global _start:function
_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr, rax
  lea end_of_file, [rax+rdx]

  sub rsp, 4 * 8 ; 4 stack spaces (qword) 

.loop:
  add curr, 5 ; skip 'Game '

  ; find game id
  mov rdi, curr 
  mov sil, ':'
  call find_char
  mov curr, rax
  mov rsi, rax
  call atol

  mov id, rax ; save id 

  add curr, 2 ; find next num

  mov qword red, 0
  mov qword green, 0
  mov qword blue, 0

.loop_colors:
  ; find game color quantity
  mov rdi, curr 
  mov sil, ' '
  call find_char
  mov curr, rax
  mov rsi, rax
  call atol

  inc curr ; skip space

  cmp byte [curr], 'r'
  jne .not_red

  ; it is red
  add curr, 3 ; skip 'red'

  cmp rax, red ; max red
  jle .end_colors

  mov red, rax
  jmp .end_colors

.not_red:
  cmp byte [curr], 'g'
  jne .not_green

  ; it is green
  add curr, 5 ; skip 'green'

  cmp rax, green ; max green
  jle .end_colors

  mov green, rax
  jmp .end_colors

.not_green:
  ; it is blue
  add curr, 4 ; skip 'green'

  cmp rax, blue ; max blue
  jle .end_colors

  mov blue, rax

.end_colors:
  cmp byte [curr], ';'
  je .end_basket
  cmp byte [curr], 0x0a
  je .end_basket

  add curr, 2 ; skip ', '
  jmp .loop_colors

.end_basket:
  cmp byte [curr], 0x0a
  je .end_line

  add curr, 2 ; skip '; '
  jmp .loop_colors

.end_line:
  inc curr ; skip \n

  mov rax, 1
  imul rax, red
  imul rax, blue
  imul rax, green
  add accumulator, rax

  cmp curr, end_of_file
  jl .loop

  call put_long
  call put_newline

  mov rax, 60
  mov rdi, 0
  syscall

put_newline:
  mov dil, 0x0a
  mov [rsp-1], dil

  mov rax, 1
  lea rsi, [rsp-1]
  mov rdi, 1
  mov rdx, 1
  syscall
  ret

put_long:
  mov rax, accumulator
  mov rdi, rsp
  mov rsi, 10
.loop:
  test rax, rax
  je .end

  dec rdi
  
  mov rdx, 0
  div rsi
  
  add dl, '0'
  mov byte [rdi], dl

  jmp .loop 

.end:
  mov rax, 1
  mov rsi, rdi
  mov rdi, 1
  mov rdx, rsp
  sub rdx, rsi
  syscall
  ret

atol:
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

  ; read fstat
  mov rdi, rax
  mov rax, 5
  mov rsi, statbuf
  syscall

  ; mmap
  mov r8, rdi ; fd
  mov rax, 9 ; mmap
  mov rdi, 0 ; address
  mov rsi, [statbuf+48]
  mov rdx, 3 ; protection (read | write)
  mov r10, 2 ; private
  mov r9, 0; offset
  syscall

  mov rdx, [statbuf+48]

  ret

section .bss
  statbuf: resb 144