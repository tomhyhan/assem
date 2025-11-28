extern mmap, exit_sucess, search_not_num, atol

; plan
; 1. Save input into an array (qword): hhhhhpbb
; 2. sort the array using qsort
; 3. compare function uses count and square them up 
;   - 2 2 2 2 2: 6*6+12 = 48
;   - 2 2 2 2 9: 5*5+2*2+11 = 40
;   - 2 2 2 1 1: 4*4+3*3+11 = 36  
; 4. now add the card to accumulator
%define curr r12
%define end_of_file [rsp + 0 * 8]
%define array_p r13

global _start:function
_start:
  mov rdi, [rsp + 16]
  call mmap 

  sub rsp, 1 * 8

  mov curr, rax
  lea rdi, [rax+rdx]
  mov end_of_file, rdi


  mov array_p, hands
  mov rdi, hands ; debug
.save_cards:
  call read_card  
  call read_card  
  call read_card  
  call read_card  
  call read_card  

  inc curr ; skip ' '
  inc array_p ; skip padding

  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol

  mov word [array_p], ax

  add array_p, 2

  inc curr ; skip '\n'
  cmp curr, end_of_file
  jb .save_cards

; now sort!
  mov rdi, hands ; start of hands
  mov rsi, hands ; end of hands
.find_array_end:
  add rsi, 8

  cmp rsi, 0
  jne .find_array_end



  
  call exit_sucess

read_card:
  cmp byte [curr], 'A'
  jne .not_A

  mov byte [array_p], 14
  jmp .end

.not_A:
  cmp byte [curr], 'K'
  jne .not_K

  mov byte [array_p], 13
  jmp .end

.not_K:
  cmp byte [curr], 'Q'
  jne .not_Q

  mov byte [array_p], 12
  jmp .end

.not_Q:
  cmp byte [curr], 'J'
  jne .not_J

  mov byte [array_p], 11
  jmp .end

.not_J:
  cmp byte [curr], 'T'
  jne .not_T

  mov byte [array_p], 10
  jmp .end

.not_T:
  mov al, [curr]
  sub al, '0'
  mov byte [array_p], al

.end:
  inc array_p
  inc curr
  ret


section .bss
  hands: resq 1001
  counts: resq 15
  hand: resq 1