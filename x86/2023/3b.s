extern put_long, put_newline, mmap, find_char, atol, is_num, exit_sucess

; used for parsing
%define num_len r15
%define curr r12
%define currCell r13
%define parsed rbx

%define end_of_file [rsp + 0 * 8]
%define size [rsp + 1 * 8]
%define x [rsp + 2 * 8]
%define y [rsp + 3 * 8]

; used for adding nums
%define sub_mul r13
%define cnt r14
%define accumulator r15
%define sizer r12

global _start:function
_start:
  mov rdi, [rsp+16]
  call mmap

  sub rsp, 4*8;

  mov curr, rax
  lea rdi, [rax+rdx]
  mov end_of_file, rdi


  mov rdi, curr
  mov sil, 0x0a
  call find_char

  mov size, rax
  sub size, curr

  mov rdi, size
  add rdi, 2
  imul rdi, rdi
  imul rdi, 2 ; allocate word for each cell
  mov r14, rdi
  call alloc

  mov parsed, rax

  ; fill 0
  mov rdi, rax
  mov rcx, r14
  mov al, 0
  rep stosb

  ; skip first line and left padding
  add parsed, size
  add parsed, size
  add parsed, 6

  mov currCell, parsed
.loop:
  cmp byte [curr], 0x0a
  jne .not_newline

  add currCell, 4
  inc curr
  jmp .next_loop

.not_newline:
  cmp byte [curr], '.'
  jne .not_dot

  add currCell, 2
  inc curr
  jmp .next_loop

.not_dot:
  mov dil, [curr]
  call is_num
  test al, al
  jz .not_number

  mov rdi, curr
  call search_right_num

  mov num_len, rax
  sub num_len, curr

  mov rdi, curr
  lea rsi, [curr+num_len]
  call atol

.store_loop:
  mov [currCell], ax

  add currCell, 2
  inc curr

  dec num_len

  cmp num_len, 0
  jne .store_loop

  jmp .next_loop

.not_number:
  cmp byte [curr], '*'
  jne .not_star

  or word [currCell], 0x8000

.not_star:
  add currCell, 2
  inc curr

.next_loop:
  cmp curr, end_of_file
  jl .loop

  mov sizer, size

  mov accumulator, 0
  mov qword y, 0
.y_loop:
  mov qword x, 0
.x_loop:
  bt word [parsed], 15
  jnc .end

.debug:
  mov sub_mul, 1
  mov qword cnt, 0; count if number is found

  ; left
  movzx rdi, word [parsed-2]
  call mul_num
  ; right
  movzx rdi, word [parsed+2]
  call mul_num

  mov rsi, sizer
  neg rsi

  ; top
  movzx rdi, word [parsed + rsi * 2 - 4]
  call mul_num
  ; bottom
  movzx rdi, word [parsed + sizer * 2 + 4]
  call mul_num
  
  mov ax, [parsed + rsi * 2 - 4]
  test ax, ax
  jnz .skip_top

  ; top left
  movzx rdi, word [parsed + rsi * 2 - 6]
  call mul_num
  ; top right
  movzx rdi, word [parsed + rsi * 2 - 2]
  call mul_num

.skip_top:
  mov ax, [parsed + sizer * 2 + 4]
  test ax, ax
  jnz .skip_bottom

  ; bottom left
  movzx rdi, word [parsed + sizer * 2 + 2]
  call mul_num

  ; bottom right
  movzx rdi, word [parsed + sizer * 2 + 6]
  call mul_num

.skip_bottom:
  cmp cnt, 2
  jne .end
  add accumulator, sub_mul

.end:
  inc qword x
  add parsed, 2
  cmp x, sizer
  jl .x_loop

  inc qword y
  add parsed, 4
  cmp y, sizer
  jl .y_loop

  mov rdi, accumulator
  call put_long
  call put_newline

  call exit_sucess

mul_num:
  cmp rdi, 0
  je .end

  imul sub_mul, rdi
  inc cnt
.end:
  ret


search_right_num:
  mov rsi, rdi
.loop:
  mov dil, [rsi]
  call is_num
  test al, al
  jz .end

  inc rsi
  jmp .loop

.end:
  mov rax, rsi
  ret

alloc:
  mov rsi, rdi

  test sil, 0x0f
  jz .nopad

  and rsi, ~0x0f
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
  oldbrk: resq 1