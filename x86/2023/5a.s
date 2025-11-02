extern mmap, atol, put_long, put_newline, exit_sucess, search_not_num

%define curr r12
%define end_of_file r13
%define array r14
%define map r15

; src, dest, range
global _start:function
_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr, rax
  lea end_of_file, [rax+rdx] 

  add curr, 6 ; remove 'seeds: '

  mov array, seeds   
  call fill_array

.end_save_seeds:
  exit_sucess

fill_array:
  
.loop:
  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol
  
  mov [rdx], rax
  jmp .save_seeds
  ret


section .bss
  seeds: resq 32
  seed_to_soil: resq 128 * 3
  soil_to_fertilizer: resq 128 * 3
  fertilizer_to_water: resq 128 * 3
  water_to_light: resq 128 * 3
  light_to_temperature: resq 128 * 3
  temperature_to_humidity: resq 128 * 3
  humidity_to_location: resq 128 * 3