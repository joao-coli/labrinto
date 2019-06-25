TITLE Animation example
;; http://stackoverflow.com/questions/34217344/clear-screen-without-interrupt

INCLUDE Irvine32.inc
INCLUDELIB Winmm.lib

CHARTYPE UNION
	UnicodeChar    WORD ?
	AsciiChar      DB ?
CHARTYPE ENDS

CHAR_INFO STRUCT
	Char          CHARTYPE <>
	Attributes    WORD ?
CHAR_INFO ENDS

OBSTACULO_FASE STRUCT
	Movimento	  BYTE ? ;//0 estatico, 1 cima, 2 baixo, 3 direita, 4 esquerda
	X			  DWORD ? ;//Posicao x
	Y			  DWORD ? ;//Posicao y
OBSTACULO_FASE ENDS

WriteConsoleOutput EQU <WriteConsoleOutputA>

WriteConsoleOutput PROTO,
hConsoleOutput : HANDLE,
    lpBuffer : PTR CHAR_INFO,
    dwBufferSize : COORD,
    dwBufferCoord : COORD,
	lpWriteRegion : PTR SMALL_RECT

CharToBuffer PROTO,
	bufx: DWORD,
	bufy: DWORD,
	char: WORD,
	cor: WORD

RenderScene PROTO,
    posx: DWORD,
    posy: DWORD

ChecaColisao PROTO,
    px: DWORD,
    py: DWORD

MovimentaJogador PROTO, 
	px: DWORD,
	py: DWORD

AtualizaFase PROTO, 
	pFase: DWORD,
	cFase: WORD

AtualizaObstaculo PROTO,
	pObstaculo: DWORD

PlaySound PROTO,
    pszSound : PTR BYTE,
    hmod : DWORD,
    fdwSound : DWORD


.data
    deviceConnect BYTE "DeviceConnect", 0

    SND_ALIAS    DWORD 00010000h
    SND_RESOURCE DWORD 00040005h
    SND_FILENAME DWORD 00020000h
    SND_ASYNC DWORD    00000001h

    file BYTE "C:\Users\vitor\Downloads\2019.1\Arq2\Projeto\labrinto\Debug\fail.wav", 0


	COLS = 120; number of columns;//Quantidade de colunas do mapa
	ROWS = 30; number of rows;//Quantidade de linhas do mapa
	COR_OBSTACULO = 6Fh;//Cor dos elementos do buffer
	COR_FUNDO = 60h
	COR_OBJETIVO = 6Bh
	COR_PERSONAGEM = 64h
	ELEMENTO_FUNDO = ' '
	ELEMENTO_OBSTACULO = '#'
	ELEMENTO_OBJETIVO = 'O'
	INI_X = COLS - 1
	INI_Y = 15


	fase1 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 13d, 15d>, <1d, 15d, 15d>, <2d, 21d, 15d>, <1d, 25d, 15d>, <2d, 33d, 15d>,
		<1d, 38d, 15d>, <2d, 40d, 15d>, <2d, 77d, 15d>, <1d, 75d, 15d>, <2d, 87d, 15d>, <1d, 89d, 15d>, <2d, 95d, 15d>,
		<1d, 99d, 15d>, <2d, 103d, 15d>, <1d, 110d, 15d>

	fase2 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 6d, 15d>, <1d, 7d, 15d>, <2d, 8d, 15d>, <1d, 9d, 15d>, <2d, 10d, 15d>,
		<1d, 57d, 8d>, <2d, 58d, 8d>, <1d, 59d, 8d>, <2d, 60d, 8d>, <1d, 61d, 8d>, <2d, 62d, 8d>,
		<1d, 105d, 25d>, <2d, 106d, 25d>, <1d, 107d, 25d>, <2d, 108d, 25d>, <1d, 109d, 25d>, <2d, 110d, 25d>

     fase3 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 7d, 15d>, <1d, 9d, 15d>,  <2d, 11d, 15d>, <1d, 13d, 15d>, <2d, 15d, 15d>,
	    <1d, 17d, 15d>, <2d, 19d, 15d>, <1d, 21d, 15d>, <2d, 23d, 15d>, <1d, 25d, 15d>, <2d, 27d, 15d>,<1d, 29d, 15d>,
	    <2d, 31d, 15d>, <1d, 33d, 15d>,  <2d, 35d, 15d>, <1d, 37d, 15d>, <2d, 39d, 15d>, <1d, 41d, 15d>, <2d, 43d, 15d>,
	    <1d, 45d, 15d>, <2d, 47d, 15d>

	fases DWORD OFFSET fase1, OFFSET fase2, OFFSET fase3

    console HANDLE 0
    buffer CHAR_INFO ROWS * COLS DUP(<<ELEMENTO_FUNDO>, COR_FUNDO>)
    bufferSize COORD <COLS, ROWS>
    bufferCoord COORD <0, 0>
    region SMALL_RECT <0, 0, COLS - 1, ROWS - 1>

    x DWORD INI_X; current position
    y DWORD INI_Y; of the figure
    character WORD 0FEh ;//Personagem principal

.code
main PROC
    INVOKE PlaySound, OFFSET deviceConnect, NULL, SND_ALIAS
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov console, eax; save console handle

	ANIMATION:
    invoke RenderScene, x, y
	invoke MovimentaJogador, OFFSET x, OFFSET y
    invoke ChecaColisao, x, y
    cmp eax, 0
    jz CONTINUE
    cmp eax, 1
    jmp RESTART
    ;jmp PROXIMA_FASE

	RESTART:
    mov x, INI_X
    mov y, INI_Y
    INVOKE PlaySound, OFFSET file, NULL, SND_ASYNC
	CONTINUE:
	INVOKE CharToBuffer, x, y, character, COR_PERSONAGEM
    invoke WriteConsoleOutput, console,
    ADDR buffer, bufferSize, bufferCoord, ADDR region
    jmp ANIMATION

exit
main ENDP


ClearBuffer PROC USES eax ecx edx
    xor eax, eax	;//EAX = 0

	LINHA1:
	mov buffer[eax * CHAR_INFO].Char, ELEMENTO_OBSTACULO
	mov buffer[eax * CHAR_INFO].Attributes, COR_OBSTACULO
	inc eax
	cmp eax, COLS
	jl LINHA1

	COLUNAS:
	mov buffer[eax * CHAR_INFO].Char, ELEMENTO_OBSTACULO
	mov buffer[eax * CHAR_INFO].Attributes, COR_OBSTACULO
	add eax, COLS-1
	mov buffer[eax * CHAR_INFO].Char, ELEMENTO_OBSTACULO
	mov buffer[eax * CHAR_INFO].Attributes, COR_OBSTACULO
	inc eax
	cmp eax, (ROWS - 1)*(COLS - 2)
	jl COLUNAS

	LINHANROWS:
	mov buffer[eax * CHAR_INFO].Char, ELEMENTO_OBSTACULO
	mov buffer[eax * CHAR_INFO].Attributes, COR_OBSTACULO
	inc eax
	cmp eax, ROWS*COLS
	jl LINHANROWS

	;//Bloco do objetivo
	mov buffer[(15 * COLS) * CHAR_INFO].Char, ELEMENTO_OBJETIVO
		mov buffer[(15 * COLS) * CHAR_INFO].Attributes, COR_OBJETIVO

	;//Remove o obstáculo da posição inicial
	mov buffer[(16 * COLS - 1) * CHAR_INFO].Char, ELEMENTO_FUNDO
	mov buffer[(16 * COLS - 1) * CHAR_INFO].Attributes, COR_FUNDO


    ret
ClearBuffer ENDP


CharToBuffer PROC USES eax edx bufx: DWORD, bufy: DWORD, char: WORD, cor: WORD
    mov eax, bufy
    mov edx, COLS
    mul edx
    add eax, bufx
    mov dx, char
    mov buffer[eax * CHAR_INFO].Char, dx
	mov dx, cor
    mov buffer[eax * CHAR_INFO].Attributes, dx
    ret
CharToBuffer ENDP

AtualizaFase PROC USES eax ecx edx pFase: DWORD, cFase: WORD
	mov eax, pFase
	mov ecx, DWORD PTR cFase

	ATUALIZACAO:
	INVOKE CharToBuffer, DWORD PTR (OBSTACULO_FASE PTR [eax]).X, DWORD PTR (OBSTACULO_FASE PTR [eax]).Y, ELEMENTO_FUNDO, COR_FUNDO ;//Limpa a posição antiga
	INVOKE AtualizaObstaculo, eax ;//Atualiza a posição do obstáculo
	INVOKE CharToBuffer, (OBSTACULO_FASE PTR [eax]).X, DWORD PTR (OBSTACULO_FASE PTR [eax]).Y, ELEMENTO_OBSTACULO, COR_OBSTACULO
	add eax, TYPE OBSTACULO_FASE
	loop ATUALIZACAO

	ret
AtualizaFase ENDP

AtualizaObstaculo PROC USES eax edx ecx ebx esi pObstaculo: DWORD

	mov edx, pObstaculo

	mov ebx, DWORD PTR(OBSTACULO_FASE PTR[edx]).X
	mov ecx, DWORD PTR(OBSTACULO_FASE PTR[edx]).Y
	movzx esi, BYTE PTR (OBSTACULO_FASE PTR [edx]).Movimento
	cmp esi, 0
	jz case0
	cmp esi, 1
	jz case1
	cmp esi, 2
	jz case2
	cmp esi, 3
	jz case3
	cmp esi, 4
	jz case4


	case0:
	jmp FIM

	case1:
	inc ecx
	INVOKE ChecaColisao, ebx, ecx
	cmp eax, 0
	jnz INVERTEY

	jmp FIM

		INVERTEY:
		mov BYTE PTR (OBSTACULO_FASE PTR[edx]).Movimento, 02h
		jmp FIM

	case2:
	dec ecx
	INVOKE ChecaColisao, ebx, ecx
	cmp eax, 0
	jnz INVERTEY2

	jmp FIM

		INVERTEY2:
		mov BYTE PTR (OBSTACULO_FASE PTR[edx]).Movimento, 01h
		jmp FIM

	case3:
	inc ebx
	INVOKE ChecaColisao, ebx, ecx
	cmp eax, 0
	jnz INVERTEX

	jmp FIM

		INVERTEX:
		mov BYTE PTR (OBSTACULO_FASE PTR[edx]).Movimento, 04h
		jmp FIM

	case4:
	dec ebx
	INVOKE ChecaColisao, ebx, ecx
	cmp eax, 0
	jnz INVERTEX2

	jmp FIM

		INVERTEX2:
		mov BYTE PTR (OBSTACULO_FASE PTR[edx]).Movimento, 03h


	FIM:
	mov DWORD PTR(OBSTACULO_FASE PTR[edx]).X, ebx
	mov DWORD PTR(OBSTACULO_FASE PTR[edx]).Y, ecx
	ret
AtualizaObstaculo ENDP

RenderScene PROC USES eax edx ecx posx: DWORD, posy: DWORD
    call ClearBuffer ;//Grid padrão do mapa
	INVOKE AtualizaFase, OFFSET fase2, LENGTHOF fase2
    ret

RenderScene ENDP

MovimentaJogador PROC USES eax px: DWORD, py: DWORD

	mov edx, py
	mov ecx, px

	mov eax, 25
	call Delay
	call ReadKey
	jz RESUME

	mov edx, py ;//Sobrescrevendo edx com posy; ReadKey altera EDX

	INVOKE CharToBuffer, [ecx], [edx], ELEMENTO_FUNDO, COR_FUNDO

	cmp ah, 50h
	jz INCREMENTO_Y ;//Cima
	cmp ah, 48h
	jz DECREMENTO_Y ;//Baixo
	cmp ah, 4Dh
	jz INCREMENTO_X ;//Direita
	cmp ah, 4Bh
	jz DECREMENTO_X ;//Esquerda
	jmp RESUME

	DECREMENTO_Y :
	dec DWORD PTR [edx]
	jmp RESUME

	DECREMENTO_X :
	dec DWORD PTR[ecx]
	jmp RESUME

	INCREMENTO_X :
	inc DWORD PTR[ecx]
	jmp RESUME

	INCREMENTO_Y :
	inc DWORD PTR[edx]

	RESUME:
	ret
MovimentaJogador ENDP

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