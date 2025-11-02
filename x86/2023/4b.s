extern mmap, skip_space, find_char, search_not_num, atol, put_long, put_newline, exit_sucess

%define curr r12
%define end_of_file [rsp+0]
%define card_id [rsp+8]
%define num_matches [rsp+16]
%define array_end r13
%define table_end r14
%define accumulator r15

global _start:function
_start:
  mov rdi, [rsp + 16]
  call mmap

  sub rsp, 3 * 8

  mov curr, rax
  lea rdi, [rax + rdx]
  mov end_of_file, rdi

  mov accumulator, 0

.loop:
  mov qword num_matches, 0

  add curr, 5 ; skip 'Card'

  mov rdi, curr
  call skip_space
  mov curr, rax

  mov rdi, curr
  mov rsi, ':'
  call find_char
  mov rsi, rax
  mov curr, rax
  call atol

  mov card_id, rax ; save card id

  inc curr; skip ':'

mov array_end, array
.loop_nums:
  mov rdi, curr
  call skip_space
  mov curr, rax

  cmp byte [curr], '|'
  je .end_loop_nums
  
  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol

  mov [array_end], al
  inc array_end

  jmp .loop_nums

.end_loop_nums:
  inc curr ; skip '|'

.loop_matches:
  mov rdi, curr
  call skip_space
  mov curr, rax

  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol

  mov rdi, array
.loop_array:

  cmp byte [rdi], al
  jne .continue_loop_array

  inc qword num_matches
  jmp .end_loop_matches

.continue_loop_array:
  inc rdi

  cmp rdi, array_end
  jl .loop_array

.end_loop_matches:
  cmp byte [curr], 0x0a
  jne .loop_matches
.debug:
  ; found all matching nums in array

  ; get id 
  ; increase table of following cards
  mov rax, num_matches
  mov rsi, card_id
  lea rdi, [match_table + rsi * 8]
  inc qword [rdi]
  mov rcx, [rdi]
  add rdi, 8
.loop_add_table:
  test rax, rax
  jz .end_loop_add_table  

  add [rdi], rcx
  add rdi, 8

  dec rax
  jmp .loop_add_table

.end_loop_add_table:
  inc curr
  cmp curr, end_of_file
  jl .loop

mov rax, 264
mov rdi, match_table
.loop_table:
  test rax, rax
  jz .end

  mov rsi, [rdi]
  add accumulator, rsi

  add rdi, 8
  dec rax
  jmp .loop_table
.end:
  mov rdi, accumulator
  call put_long
  call put_newline

  call exit_sucess
  ret

section .bss
  array resb 15
  match_table resq 264
