extern mmap, put_long, put_newline, exit_sucess, atol, find_char, is_num, search_not_num

%define curr r12
%define currCell r13
%define end_of_file [rsp+0]
%define num_found [rsp+8]
%define array_size [rsp+16]
%define accumulator r15
%define array_len r14
%define array rbx

global _start:function
_start:
  mov rdi, [rsp+16]
  call mmap

  sub rsp, 3*8

  mov curr, rax
  lea rdi, [rax+rdx]
  mov end_of_file, rdi

  mov rdi, 15
  imul rdi, 2
  mov array_size, rdi
  call alloc

  mov array, rax
  
  mov accumulator, 0

.loop:
  add curr, 9

  mov currCell, array
  mov array_len, 0

  mov rdi, array
  mov rcx, array_size
  mov al, 0
  rep stosb

.loop_save:
  mov dil, [curr]
  call is_num
  test al, al
  jz .end_loop_save

  mov rdi, curr
  mov sil, ' '
  call find_char
  mov rsi, rax
  mov curr, rax
  call atol

  mov [currCell], ax
  add currCell, 2
  inc array_len

.end_loop_save:
  inc curr

  cmp byte [curr], '|'
  je .array_found

  jmp .loop_save

.array_found:
  inc curr ; skip '|'

  mov qword num_found, 0
.loop_nums:
  mov dil, [curr]
  call is_num
  test al, al
  jz .end_loop_nums

  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol

  mov currCell, array
  mov rdi, array_len
.loop_array:
  test rdi, rdi
  jz .end_loop_nums

  cmp [currCell], ax
  je .found_match

  add currCell, 2
  dec rdi
  jmp .loop_array

.found_match:
  inc qword num_found

.end_loop_nums:
  cmp byte [curr], 0x0a
  je .searched_array

  inc curr
  jmp .loop_nums


.searched_array:

  mov rcx, num_found
  test rcx, rcx
  jz .zero

.debug:
  mov rax, 1
  dec rcx
  shl rax, cl 

  add accumulator, rax

.zero:
  inc curr ; skip new_line

  cmp curr, end_of_file
  jl .loop

  mov rdi, accumulator
  call put_long
  call put_newline

  call exit_sucess

alloc:
  mov rsi, rdi

  test sil, 0xf
  jz .nopad

  and rsi, ~0xf
  add rsi, 16

.nopad:
  cmp qword [oldbrk], 0
  jne .has_brk

  mov rax, 12
  mov rdi, 0
  syscall 
  jmp .gotbrk

.has_brk:
  mov rax, [oldbrk]

.gotbrk:

  lea rdi, [rax+rsi] 
  mov rsi, rax
  mov rax, 12
  syscall

  mov [oldbrk], rax
  mov rax, rsi

  ret

section .bss
  oldbrk resq 1