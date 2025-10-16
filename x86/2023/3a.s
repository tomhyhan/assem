

%define end_of_file r12
%define curr r13
%define end_of_line r14
%define accumulator r15
%define nrows [rsp + 0 * 8]
%define ncols [rsp + 1 * 8]
%define curr_char rbx

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr, rax
  lea end_of_file, [rax+rdx]

  sub rsp, 2*8

; get num of cols
  mov rdi, curr
  mov sil, 0x0a
  call find_char

  sub rax, curr
  mov ncols, rax
  inc qword ncols ; also count '\n'

  ; mov rax, ncols
  ; mov dl, [curr+rax]

.loop:
  mov dil, [curr]
  call is_num
  test al, al
  jnz .end_loop

  ; is dot
  cmp dil, '.'
  je .end_loop

  ; is new line
  cmp dil, 0x0a
  je .end_loop
  ; it is speical char
  ; check 8 directions

.top_center:
  lea curr_char, curr
  sub curr_char, ncols

  mov dil, [curr_char]
  call is_num
  test al, al
  je .top_left

  ; it is num
  call add_num

  jmp .left

.top_left:
  mov curr_char, curr
  sub curr_char, ncols
  dec curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .top_right

  ; it is num
  call add_num

.top_right:
  mov curr_char, curr
  sub curr_char, ncols
  inc curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .left

  ; it is num
  call add_num

.left:
  mov curr_char, curr
  dec curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .right

  ; it is num
  call add_num

.right:
  mov curr_char, curr
  inc curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .bottom_center

  ; it is num
  call add_num

.bottom_center:
  mov curr_char, curr
  add curr_char, ncols

  mov dil, [curr_char]
  call is_num
  test al, al
  je .bottom_left

  ; it is num
  call add_num

  jmp .end_loop

.bottom_left:
  mov curr_char, curr
  add curr_char, ncols
  dec curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .bottom_right

  ; it is num
  call add_num

.bottom_right:
  mov curr_char, curr
  add curr_char, ncols
  inc curr_char

  mov dil, [curr_char]
  call is_num
  test al, al
  je .end_loop

  ; it is num
  call add_num


.end_loop:
  inc curr
  
  cmp curr, end_of_file
  jl .loop

.end:
  mov rax, 60
  mov rdi, 0
  syscall

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
