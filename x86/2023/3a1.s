extern put_long, put_newline, mmap, find_char

; used for parsing
%define num_len r15
%define curr r12
%define currCell r13
%define parsed rbx

%define end_of_file [rsp + 0 * 8]
%define size [rsp + 1 * 8]

; used for adding nums
%define x r13
%define y r14
%define accumulator r15
%define sizer r12

section .text
global _start:function

_start:
  mov rdi, [rsp+16]
  call mmap

  sub rsp, 2*8

  mov curr, rax
  lea rdi, [rax+rdx]
  mov end_of_file, rdi

; get num of cols
  mov rdi, curr
  mov sil, 0x0a
  call find_char

  sub rax, rdi
  mov size, rax 

  mov rdi, size
  add rdi, 2
  imul rdi, rdi
  imul rdi, 2 ; alloc word for each slot
  mov r14, rdi
  call alloc ; now you are working with heap

  mov parsed, rax

  mov rdi, rax
  mov rcx, r14
  mov al, 0
  rep stosb

  ; mov top and left padding
  add parsed, size
  add parsed, size
  add parsed, 6

  mov currCell, parsed
.loop:
  cmp byte [curr], 0x0a
  jne .not_newline

  add currCell, 4
  inc curr

  jmp .continue_loop

.not_newline:
  cmp byte [curr], '.'
  jne .not_dot

  add currCell, 2
  inc curr

  jmp .continue_loop

.not_dot:
  mov dil, [curr]
  call is_num
  test al, al
  jz .not_number

  ; it is a num: save num
  mov rdi, curr
  call search_right_num

  mov num_len, rax
  sub num_len, curr

  mov rdi, curr
  mov rsi, rax
  call atol

.store_loop:
  mov [currCell], ax

  add currCell, 2
  inc curr

  dec num_len
  test num_len, num_len
  jnz .store_loop

  jmp .continue_loop

.not_number: ; it must be symbol
  mov al, [curr]
  movzx ax, al
  or ax, 0x8000
  mov [currCell], ax 
  inc curr
  add currCell, 2

.continue_loop:
  cmp curr, end_of_file
  jl .loop

; traverse grid

  mov accumulator, 0
  mov sizer, size

  mov y, 0
.y_loop:
  mov x, 0

.x_loop:
  bt word [parsed], 15
  jnc .not_symbol

.debug:
  ; left
  movzx rax, word [parsed-2]
  add accumulator, rax
  ; right
  movzx rax, word [parsed+2]
  add accumulator, rax
  mov rdi, sizer
  neg rdi
  ; top
  movzx rax, word [parsed + rdi * 2 - 4]
  add accumulator, rax
  ; bottom
  movzx rax, word [parsed + sizer * 2 + 4]
  add accumulator, rax

  mov ax, word [parsed + rdi * 2 - 4]
  test ax, ax
  jnz .skip_top

  ; top left
  movzx rax, word [parsed + rdi * 2 - 6]
  add accumulator, rax
  ; top right
  movzx rax, word [parsed + rdi * 2 - 2]
  add accumulator, rax

.skip_top:
  mov ax, word [parsed + sizer * 2 + 4]
  test ax, ax
  jnz .skip_bottom
  ; bottom left
  movzx rax, word [parsed + sizer * 2 + 2]
  add accumulator, rax
  ; bottom right
  movzx rax, word [parsed + sizer * 2 + 6]
  add accumulator, rax

.skip_bottom:
.not_symbol:
  inc x
  add parsed, 2

  cmp x, sizer
  jl .x_loop

  inc y
  add parsed, 4

  cmp y, sizer
  jl .y_loop

.end:
  mov rdi, accumulator
  call put_long
  call put_newline

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


search_right_num:
  mov rsi, rdi
.loop:
  mov dil, [rsi]
  call is_num
  test al, al
  je .end
  
  inc rsi
  jmp .loop

.end:
  mov rax, rsi
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


section .bss
  oldbrk: resq 1

