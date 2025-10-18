#!/usr/bin/env bash

nasm -g -F dwarf -f elf64 $1.s
nasm -g -F dwarf -f elf64 ../lib/aoc.s
ld -o $1 $1.o ../lib/aoc.o
