

%define curr_line r13
%define end_of_file r12
%define accumulator r14
%define curr_char r15
%define curr_charb r15b
%define end_of_line r13

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr_line, rax
  lea end_of_file, [curr_line+rdx]

.loop:
  mov curr_char, curr_line
.search_left:
  mov dil, [curr_char]
  call is_num
  test al, al
  jnz .num2int_left

  call find_str_num
  test dl, dl
  jnz .end_search_left

  inc curr_char
  jmp .search_left

.num2int_left:
  mov curr_charb, [curr_char]
  sub curr_charb, '0'
  movzx curr_char, curr_charb
.end_search_left:

  lea accumulator, [accumulator+curr_char*8]
  lea accumulator, [accumulator+curr_char*2]

  mov dil, 0x0a 
  mov rsi, curr_line
  call find_char
  mov end_of_line, rax

  mov curr_char, end_of_line
.search_right:
  mov dil, [curr_char]
  call is_num
  test al, al
  jnz .num2int_right

  call find_str_num
  test dl, dl
  jnz .end_search_right

  dec curr_char
  jmp .search_right

.num2int_right:
  mov curr_charb, [curr_char]
  sub curr_charb, '0'
  movzx curr_char, curr_charb
.end_search_right:
  lea accumulator, [accumulator+curr_char]

  inc end_of_line
  mov curr_line, end_of_line

  cmp curr_line, end_of_file
  jl .loop

  call putlong
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


find_char:
  mov rax, rsi
.loop:
  cmp rax, end_of_file
  jge .end

  cmp dil, [rax]
  je .end

  inc rax
  jmp .loop

.end:
  ret

find_str_num:
  mov rax, 0
  mov rdx, 0; flag
.loop:
  cmp rax, 9
  jge .end ; they are equal

  mov rdi, curr_char
  mov rsi, [table+rax*8]
.is_equal:
  mov r8b, [rsi]; num from table
  mov r9b, [rdi]; current char

  test r8, r8
  jz .found

  cmp r8, r9
  jne .next_loop

  inc rsi
  inc rdi
  jmp .is_equal

.next_loop:
  inc rax
  jmp .loop

.found:
  mov rdx, 1
  lea curr_char, [rax+1]

.end:
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

  ; allocate memory
  mov rax, 9              ; call mmap
  mov r8, rdi             ; fd 
  mov rdi, 0              ; address
  mov rsi, [statbuf+48]   ; size
  mov rdx, 3              ; READ | WRITE
  mov r10, 2              ; MAP_PRIVATE
  mov r9, 0               ; OFFSET
  syscall

  mov rdx, rsi
  ret


section .rodata
  one: db "one", 0
  two: db "two", 0
  three: db "three", 0
  four: db "four", 0
  five: db "five", 0
  six: db "six", 0
  seven: db "seven", 0
  eight: db "eight", 0
  nine: db "nine", 0
table:
  dq one
  dq two
  dq three
  dq four
  dq five
  dq six
  dq seven
  dq eight
  dq nine

section .bss
  statbuf: resb 144

