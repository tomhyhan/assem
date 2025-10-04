

%define curr_line r13
%define end_of_file r12
%define accumulator r14
%define curr_char r15
%define curr_charb r15b
%define end_of_line r12

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr_line, rax
  lea end_of_file, [curr_line+rdx]

  mov curr_char, curr_line
.search_left:
  mov dil, [curr_char]
  call is_num
  test al, al
  jnz .end_search_left

  mov rdi, curr_char
  call is_str_num


  inc curr_char
  jmp .search_left

.end_search_left:

  mov curr_charb, [curr_char]
  sub curr_charb, '0'
  movzx curr_char, curr_charb

  ret

is_str_num:
  mov al, 0; flag
  mov rdx, 0
.loop:
  cmp rdx, 9
  jge .end ; they are equal

  lea rsi, [table+rdx*8]
.is_equal:
  mov r8, [rsi]
  mov r9, [rdi]

  test r8, r8
  test rsi, rsi
  jz .next_loop

  cmp [rsi], [rdi]
  inc rsi
  inc rdi

  inc rax

.next_loop
  jmp .loop

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

