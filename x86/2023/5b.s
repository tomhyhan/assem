extern mmap, atol, put_long, put_newline, exit_sucess, search_not_num, find_char

%define curr r12
%define end_of_file r13
%define array r14
%define array_end rbx
%define map r15


global _start:function
_start:
  mov rdi, [rsp+16]
  call mmap

  mov curr, rax
  lea end_of_file, [rax+rdx] 

  add curr, 7 ; remove 'seeds: '

  ; Fill out all arrays
  mov array, seeds   
  call fill_array
  call skip2next

  mov array, seed_to_soil
  call fill_array
  call skip2next

  mov array, soil_to_fertilizer
  call fill_array
  call skip2next

  mov array, fertilizer_to_water
  call fill_array
  call skip2next

  mov array, water_to_light
  call fill_array
  call skip2next

  mov array, light_to_temperature
  call fill_array
  call skip2next

  mov array, temperature_to_humidity
  call fill_array
  call skip2next

  mov array, humidity_to_location
  call fill_array

; loop through seed ranges
; src, dest, range
  mov array_end, seeds
.get_seed_end:
  cmp [array_end], 0
  je .loop_seeds

  add array_end, 16 
  jmp .get_seed_end

.loop_seeds:
  ; seed value
  ; mov rax, [array]
  ; test rax, rax
  ; jz .end_loop_seeds

  mov array, seeds
  mov map, seed_to_soil
  call map_seed_value

  mov map, soil_to_fertilizer
  call map_seed_value

  mov map, fertilizer_to_water
  call map_seed_value

  mov map, water_to_light
  call map_seed_value

  mov map, light_to_temperature
  call map_seed_value

  mov map, temperature_to_humidity
  call map_seed_value

  mov map, humidity_to_location
  call map_seed_value

  ; mov rdi, rax
  ; call put_long
  ; call put_newline
  mov [array], rax

  add array, 8
  jmp .loop_seeds

.end_loop_seeds:

  mov array, seeds
  mov rdi, [array]
.loop_min:
  mov rax, [array]
  test rax, rax
  jz .end_loop_min

  cmp rax, rdi
  cmovl rdi, rax

  add array, 8
  jmp .loop_min

.end_loop_min:
  call put_long
  call put_newline
  call exit_sucess

map_seed_value:
.loop:
  mov rdi, array
  mov rsi, map
  call map_seed_value_range

  cmp array, array_end
  je .end

  add array, 16
  jmp .loop
.end:
  ret

; rsi: array pointer
; rdi: map pointer
map_seed_value_range:
.loop:
  ; src   [map + 0]
  ; dest  [map + 1 * 8]
  ; range [map + 2 * 8]

  ; seed value

  ; is within range?
  mov rax, [array]
  mov rdx, [map + 1 * 8]
  cmp rax, rdx
  jl .not_in_range

  add rax, [map+16]
  cmp rax, rcx
  jae .not_in_range

  ; seed + seed_end < src + src_range
  ; no_split
  
  jl .no_split 

  ; within range
  ; seed - dest + src 
  sub rax, rsi
  add rax, rdi
  jmp .end

.not_in_range:
  add map, 24
  jmp .loop

.end:
  ret

fill_array:
.loop:
  cmp byte [curr], 0xa
  je .end

  cmp curr, end_of_file
  je .end

  mov rdi, curr
  call search_not_num
  mov rdi, curr
  mov rsi, rax
  mov curr, rax
  call atol
  
  mov [array], rax

  add array, 8
  inc curr
  jmp .loop

.end:
  ret

skip2next:
  inc curr

  mov rdi, curr
  mov sil, 0xa
  call find_char
  mov curr, rax

  inc curr
  ret

section .bss
  seeds: resq 1024 * 2
  seed_to_soil: resq 128 * 3
  soil_to_fertilizer: resq 128 * 3
  fertilizer_to_water: resq 128 * 3
  water_to_light: resq 128 * 3
  light_to_temperature: resq 128 * 3
  temperature_to_humidity: resq 128 * 3
  humidity_to_location: resq 128 * 3