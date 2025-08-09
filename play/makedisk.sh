#
/bin/bash
rm mydisk.d64
../start $1
~/fun/Vice/bin/c1541.exe -format "mydisk,id" d64 mydisk.d64
~/fun/Vice/bin/c1541.exe -attach mydisk.d64 -write file.prg -write input.txt 
sc -moncommand $1.lbl
