TITLE Animation example
;; http://stackoverflow.com/questions/34217344/clear-screen-without-interrupt

INCLUDE Irvine32.inc

CHARTYPE UNION
UnicodeChar    WORD ?
AsciiChar      DB ?
CHARTYPE ENDS

CHAR_INFO STRUCT
Char          CHARTYPE <>
Attributes    WORD ?
CHAR_INFO ENDS

WriteConsoleOutput EQU <WriteConsoleOutputA>

WriteConsoleOutput PROTO,
hConsoleOutput : HANDLE,
    lpBuffer : PTR CHAR_INFO,
    dwBufferSize : COORD,
    dwBufferCoord : COORD,
    lpWriteRegion : PTR SMALL_RECT


    COLS = 120; number of columns
    ROWS = 30; number of rows
    CHAR_ATTRIBUTE = 0Fh; bright white foreground


.data
    console HANDLE 0
    buffer CHAR_INFO ROWS * COLS DUP(<< '-' > , CHAR_ATTRIBUTE > )
    bufferSize COORD <COLS, ROWS>
    bufferCoord COORD <0, 0>
    region SMALL_RECT <0, 0, COLS - 1, ROWS - 1>

    x DWORD 0; current position
    y DWORD 2; of the figure
    character WORD 023h ; filled with this symbol

    CONTROLE byte 0


.code
main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov console, eax; save console handle

    mov ecx, 100; draw 70 frames
ANIMATION :
    push ecx
    call RenderScene
    invoke WriteConsoleOutput, console,
    ADDR buffer, bufferSize, bufferCoord, ADDR region
    INVOKE Sleep, 100; delay between frames
    pop ecx
    loop ANIMATION

exit
main ENDP


ClearBuffer PROC USES eax
    xor eax, eax

BLANKS :
    mov buffer[eax * CHAR_INFO].Char, ' '
    inc eax
    cmp eax, ROWS * COLS
    jl BLANKS

    ret
ClearBuffer ENDP


CharToBuffer PROC USES eax edx bufx : DWORD, bufy : DWORD, char : WORD
    mov eax, bufy
    mov edx, COLS
    mul edx
    add eax, bufx
    mov dx, char
    mov buffer[eax * CHAR_INFO].Char, dx
    ret
CharToBuffer ENDP


RenderScene PROC USES eax edx ecx
    CALL ClearBuffer

    ; render 10 by 7 rectangle
    mov edx, y
    mov ecx, 1
ONELINE:
    mov eax, x

    push ecx
    mov ecx, 1

ONECHAR :
    INVOKE CharToBuffer, eax, edx, character
    inc eax
    loop ONECHAR; inner loop prints characters

    inc edx
    pop ecx
    loop ONELINE; outer loop prints lines

    cmp CONTROLE, 0
    jz INCREMENTO
    jmp DECREMENTO

DECREMENTO:
    dec y;
    cmp y, 0d
    je SWITCH
    jmp RESUME

INCREMENTO:
    inc y; increment x for the next frame
    cmp y, 29d
    je SWITCH

RESUME:
    ;inc character; change fill character for the next frame

    ret

SWITCH:
    cmp CONTROLE, 0
    je RECEBE_1
    jmp RECEBE_0
RECEBE_1: 
    mov CONTROLE, 1
    jmp RESUME
RECEBE_0:
    mov CONTROLE, 0
    jmp RESUME


    RenderScene ENDP

END main