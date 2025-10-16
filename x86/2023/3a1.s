%define accumulator r15
%define end_of_file [rsp + 0 * 8]
%define size [rsp + 1 * 8]
%define curr r12
%define x r13
%define y r14
%define sizer r12

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  sub rsp, 2*8

  mov curr, rax
  lea end_of_file, [rax+rdx]

; get num of cols
  mov rdi, curr
  mov sil, 0x0a
  call find_char
  
  mov size, rax 

  mov rdi, size
  add rdi, 2
  imul rdi, rdi
  imul rdi ; alloc word for each slot
  call alloc ; now you are working with heap


.end:
  mov rax, 60
  mov rdi, 0
  syscall


alloc:
  ; align memory to 16 bytes
  mov rsi, rdi
  test rsi, 0xf
  jz .nopad

  and rsi, ~0xf
  add rsi, 16 

.nopad:
  cmp [oldbrk], 0
  jne .brk_exist

  mov rax, 12
  mov rdi, 0
  syscall

  jmp .map

.brk_exist:
  mov rax, [oldbrk]

.map:

  mov rdi, rax
  mov rax, 12
  add rdi, rsi
  syscall

  ret

put_newline:
  mov dil, 0x0a
  mov [rsp-1], dil

  mov rax, 1
  mov rdi, 1
  lea rsi, [rsp-1]
  mov rdx, 1
  syscall

  ret

put_long:
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

  
add_num:
  mov rsi, curr_char
  call search_left_num

  mov rsi, rax; rax: left most num
  call search_right_num
  mov rdi, rsi
  mov rsi, rdx
  call atol

debug:
  add accumulator, rax
  call put_long
  call put_newline
  ret

search_right_num:
  mov rdx, rsi
.loop:
  mov dil, [rdx]
  call is_num
  test al, al
  je .end
  
  inc rdx
  jmp .loop

.end:
  ret

atol:
  mov rax, 0
.loop:
  cmp rdi, rsi
  jge .end

  imul rax, 10

  mov cl, [rdi]
  sub cl, '0'
  movzx rcx, cl
  add rax, rcx

  inc rdi
  jmp .loop

.end:
  ret

search_left_num:
  mov rdx, 0
.loop:
  cmp rdx, 3
  je .end

  mov dil, [rsi]
  call is_num
  test al, al
  je .end
  
  dec rsi
  inc rdx
  jmp .loop

.end:
  mov rax, rsi
  inc rax
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
  jge .end

  inc rax
  jmp .loop
.end:
  ret

mmap:
  ; read file
  mov rax, 2
  mov rsi, 0
  syscall

  ; fstat
  mov rdi, rax
  mov rax, 5
  mov rsi, statbuf
  syscall

  ; mmap
  mov r8, rdi   ; fd
  mov rax, 9
  mov rdi, 0 ; address
  mov rsi, [statbuf+48]   ; length
  mov rdx, 3   ; prot
  mov r10, 2   ; flags
  mov r9,  0    ; offset
  syscall

  mov rdx, [statbuf+48]
  ret

section .bss
  statbuf: resb 144
  oldbrk: resq 1

