; allocate memory
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

; find matching char and return address
; rdi: current address
; sil: char (byte) to find 
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

; add new line
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

section .bss
  statbuf resb 144