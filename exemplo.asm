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

RenderScene PROTO,
    posx: DWORD,
    posy: DWORD

ChecaColisao PROTO,
    px: DWORD,
    py: DWORD


.data
	COLS = 120; number of columns;//Quantidade de colunas do mapa
	ROWS = 30; number of rows;//Quantidade de linhas do mapa
	CHAR_ATTRIBUTE = 6Fh;//Cor dos elementos do buffer

    console HANDLE 0
    buffer CHAR_INFO ROWS * COLS DUP(<< '-' > , CHAR_ATTRIBUTE > )
    bufferSize COORD <COLS, ROWS>
    bufferCoord COORD <0, 0>
    region SMALL_RECT <0, 0, COLS - 1, ROWS - 1>

    x DWORD 59; current position
    y DWORD 14; of the figure
    character WORD 0FEh ;//Personagem principal

    CONTROLE byte 0


.code
main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov console, eax; save console handle

ANIMATION:
    push ecx
    invoke RenderScene, OFFSET x, OFFSET y

    invoke ChecaColisao, x, y
    cmp eax, 0
    jz CONTINUE
    cmp eax, 1
    jmp RESTART
    ;jmp PROXIMA_FASE

RESTART:
    mov x, 59
    mov y, 14

CONTINUE:
    invoke WriteConsoleOutput, console,
    ADDR buffer, bufferSize, bufferCoord, ADDR region
    INVOKE Sleep, 10; delay between frames
    pop ecx
    jmp ANIMATION

exit
main ENDP


ClearBuffer PROC USES eax ecx
    xor eax, eax	;//EAX = 0

	LINHA1:
	mov buffer[eax * CHAR_INFO].Char, '#'
	inc eax
	cmp eax, COLS
	jl LINHA1


	VAZIOS:
    mov buffer[eax * CHAR_INFO].Char, '#'
	mov ecx, COLS - 1
		VAZIOSM:
		inc eax
		mov buffer[eax * CHAR_INFO].Char, ' '
		loop VAZIOSM
	mov buffer[eax * CHAR_INFO].Char, '#'
	inc eax
    cmp eax, (ROWS - 1) * (COLS - 2)
    jl VAZIOS

	LINHANROWS:
	mov buffer[eax * CHAR_INFO].Char, '#'
	inc eax
	cmp eax, ROWS*COLS
	jl LINHANROWS

     mov buffer[(15*COLS) * CHAR_INFO].Char, '0'
	mov buffer[(15 * COLS) * CHAR_INFO].Attributes, 6Bh


    ret
ClearBuffer ENDP


CharToBuffer PROC USES eax edx bufx: DWORD, bufy: DWORD, char: WORD
    mov eax, bufy
    mov edx, COLS
    mul edx
    add eax, bufx
    mov dx, char
    mov buffer[eax * CHAR_INFO].Char, dx
    mov buffer[eax * CHAR_INFO].Attributes, 64h
    ret
CharToBuffer ENDP


RenderScene PROC USES eax edx ecx posx: DWORD, posy: DWORD
    CALL ClearBuffer

    mov edx, posy
    mov ecx, posx

    INVOKE CharToBuffer, [ecx], [edx], character

	mov eax, 50
	call Delay
	call ReadKey
	jz RESUME

     mov edx, posy	;//Sobrescrevendo edx com posy; ReadKey altera EDX

	cmp ah, 50h;//CIMA
	jz INCREMENTO_Y
	cmp ah, 48h
	jz DECREMENTO_Y;//BAIXO
	cmp ah, 4Dh
	jz INCREMENTO_X
	cmp ah, 4Bh
	jz DECREMENTO_X
	jmp RESUME

DECREMENTO_Y:
    dec DWORD PTR [edx]
    jmp RESUME

DECREMENTO_X:
	dec DWORD PTR [ecx]
	jmp RESUME

INCREMENTO_X:
	inc DWORD PTR [ecx]
	jmp RESUME

INCREMENTO_Y:
    inc DWORD PTR [edx]

RESUME:
    ret

    RenderScene ENDP

ChecaColisao PROC USES edx px: DWORD, py: DWORD
    mov eax, py
    mov edx, COLS
    mul edx
    add eax, px
    cmp buffer[eax * CHAR_INFO].Char, ' '
    jz NAO_COLIDIU
    cmp buffer[eax * CHAR_INFO].Char, 0FEh
    jz NAO_COLIDIU
    cmp buffer[eax * CHAR_INFO].Char, '#'
    jz COLIDIU_OBSTACULO
    mov eax, 2 ;Colidiu com o Objetivo!
RESUME2:
    ret

NAO_COLIDIU:
    mov eax, 0
    jmp RESUME2

COLIDIU_OBSTACULO:
    mov eax, 1
    jmp RESUME2


ChecaColisao ENDP

END main