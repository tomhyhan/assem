; allocate memory
; rdi = file string
; returns void
global mmap:function
mmap:
  ; open a file
  mov rax, 2
  mov rsi, 0
  syscall

  ; get file stat
  mov rdi, rax
  mov rax, 5
  mov rsi, statbuf
  syscall

  ; mmap
  mov r8, rdi  ; fd
  mov rax, 9 
  mov rdi, 0; addr
  mov rsi, [statbuf+48]; length
  mov rdx, 3 ; protection
  mov r10, 2 ; flags
  mov r9, 0 ; offset
  syscall

  mov rdx, [statbuf+48]
  
  ret

; is current character a number?
; dil: current char
; returns 0 or 1
global is_num:function
is_num:
  mov al, 0
  cmp dil, '0'
  jl .end
  cmp dil, '9'
  jg .end
  mov al, 1
.end:
  ret


global search_not_num:function
search_not_num:
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


global skip_space:function
skip_space:
  mov rax, rdi
.loop:
  cmp byte [rax], ' '
  jne .end

  inc rax
  jmp .loop

.end:
  ret

; convert string to num
; rdi = current char
; rsi = last char
; returns number
global atol:function
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

; find matching char 
; rdi = current address
; sil =  char (byte) to find 
; returns address
global find_char:function
find_char:
  mov rax, rdi
.loop:
  cmp sil, [rax]
  je .end

  inc rax
  jmp .loop
.end:
  ret

; print number on screen
; rdi: num in hex
; return void
global put_long:function
put_long:
  mov rax, rdi
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

; add new line on screen
; returns void
global put_newline:function
put_newline:
  mov dil, 0x0a
  mov [rsp-1], dil

  mov rax, 1
  lea rsi, [rsp-1]
  mov rdi, 1
  mov rdx, 1
  syscall

  ret

; exit program successfully
global exit_sucess:function
exit_sucess:
  mov rax, 60
  mov rdi, 0
  syscall
  

section .bss
  statbuf resb 144