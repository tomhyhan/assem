; Define KERNAL routine addresses
SETLFS  = $FFBA   ; Set Logical File, First Address, Second Address
SETNAM  = $FFBD   ; Set Filename
OPEN    = $FFC0   ; Open a File
CHKIN   = $FFC6   ; Set Input Channel
CHRIN   = $FFCF   ; Read a Character from Channel
CLOSE   = $FFC3   ; Close a File
CHROUT  = $FFD2   ; Output a Character
READST  = $FFB7   ; *** ADD THIS: Read I/O Status Byte ***
CLRCH   = $FFCC
; Define Zeropage addresses for our variables
FILENAME_PTR = $FB

; I/O Status bit for End Of File
EOF_BIT = %01000000

.segment "RODATA"
filename: .byte "mytext.txt", 0 ; Null-terminated filename

.segment "CODE"
.proc main
    ; Set the filename for the KERNAL
    lda #$0a
    ldx #<filename      ; Load low byte of filename address
    ldy #>filename      ; Load high byte of filename address
    jsr SETNAM

    ; Set up the logical file information
    lda #4              ; Logical file number
    ldx #8              ; Device number (disk drive)
    ldy #4              ; Secondary address for LOAD
    jsr SETLFS

    ; Open the file
    jsr OPEN
    bcs error           ; If carry is set, there was an error opening the file

    ; Set the input channel to the opened file (logical file 1)
    ldx #4
    jsr CHKIN
    bcs error           ; If carry is set, there was an error

; ===================================================================
; CORRECTED READ LOOP STARTS HERE
; ===================================================================
read_loop:
    ; First, check the status BEFORE reading. This prevents reading past EOF.
    jsr READST
    and #%01000000       ; Check for the End Of File bit
    bne end_of_file     ; If it's set, we are done.

    ; If not EOF, read the next character
    jsr CHRIN
    bcs error           ; Check for a read error

    ; Print the character to the screen
    jsr CHROUT

    jmp read_loop
; ===================================================================
; CORRECTED READ LOOP ENDS HERE
; ===================================================================

end_of_file:
    jsr CLRCH
    ; Close the file
    lda #4              ; Logical file number to close
    jsr CLOSE

    rts                 ; Return from subroutine

error:
    jsr CLRCH
    ; In case of an error, it's good practice to also close any open files.
    lda #4
    jsr CLOSE
    rts
.endproc