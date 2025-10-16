

%define end_of_file r12
%define curr_line r13
%define end_of_line r14
%define accumulator r15
%define curr_num rbx
%define curr_numb bl

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr_line, rax
  lea end_of_file, [rax+rdx]

.loop:
  ; init game id

  add byte [game_id], 1
  ; find line end
  mov dil, 0x0a
  mov rsi, curr_line
  call find_char
  mov end_of_line, rax

  ; find game id
  mov dil, ':'
  mov rsi, curr_line
  call find_char
  inc rax
  mov curr_line, rax

  call init_state
.loop_basket:
  mov dil, [curr_line]
  call get_color

  cmp dil, 0x3b ; look for ';'
  je .compare

  cmp curr_line, end_of_line
  jge .end_loop_basket

  inc curr_line
  jmp .loop_basket

.compare:
  call compare_basket
  test al, al
  jz .end_loop ; fail to load basket

  ; init state for next basket
  call init_state
  inc curr_line
  jmp .loop_basket

.end_loop_basket:
  call compare_basket
  test al, al
  jz .end_loop ; fail to load basket
  
  movzx rax, byte [game_id]
  add accumulator, rax
  ; mov accumulator, rax

.end_loop:

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

compare_basket:
  mov al, 0
  ;12 red cubes, 13 green cubes, and 14 blue cubes
  cmp byte [red], 12
  jg .end

  cmp byte [green], 13
  jg .end

  cmp byte [blue], 14
  jg .end

  mov al, 1

.end:
  ret

init_state:
  mov byte [red], 0
  mov byte [green], 0
  mov byte [blue], 0
  ret

get_color:
  mov curr_num, 0
.quantity_loop:
  mov dil, [curr_line] 
  call is_num
  test al, al
  jz .end_quantity_loop

  mov rax, 0
  lea rax, [rax+curr_num*8]
  lea rax, [rax+curr_num*2]
  mov curr_num, rax

  mov al, [curr_line]
  sub al, '0'
  movzx rax, al  
  add curr_num, rax

  inc curr_line
  jmp .quantity_loop

.end_quantity_loop:
  cmp curr_num, 0
  jle .end

  mov al, [curr_line+1]
.red:
  cmp al, 'r'
  jne .green

  mov [red], curr_numb
  jmp .end

.green:
  cmp al, 'g'
  jne .blue

  mov [green], curr_numb
  jmp .end

.blue:
  cmp al, 'b'
  jne .wrong

  mov [blue], curr_numb
  jmp .end
.wrong:
  mov rax, 60
  mov rdi, 1
  syscall
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

; check this
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

section .data
  game_id: db 0
  red: db 0
  green: db 0
  blue: db 0

section .bss
  statbuf: resb 144