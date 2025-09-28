#!/usr/bin/env bash

nasm -g -F dwarf -f elf64 $1.s
nasm -g -F dwarf -f elf64 ../common/common.s
ld -o $1 $1.o ../common/common.o
