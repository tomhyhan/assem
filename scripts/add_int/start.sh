#!/bin/bash

#cl65 -o file.prg -u __EXEHDR__ -t c64 -C c64-asm.cfg $1
cl65 -o file.prg -u __EXEHDR__ -g -d -Ln $1.lbl -t c64 -m $1.map -C c64.cfg $1

