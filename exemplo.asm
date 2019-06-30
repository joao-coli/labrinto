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

SSTRING STRUCT
	PtrString DWORD ?
	TmString  WORD ?
	CorString WORD ?
SSTRING ENDS

OBSTACULO_FASE STRUCT
	Movimento	  BYTE ? ;//0 estatico, 1 cima, 2 baixo, 3 direita, 4 esquerda
	X			  DWORD ? ;//Posicao x
	Y			  DWORD ? ;//Posicao y
OBSTACULO_FASE ENDS

DADOS_FASE STRUCT
	Endr   DWORD ? ;//Endereço da fase
	QtdEl  WORD ? ;//Quantidade de elementos na fase
	PosObj BYTE ? ;//Posicao do objetivo na primeira coluna do mapa
DADOS_FASE ENDS

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
	cor:  WORD

LimpaBuffer PROTO,
	elBuff: WORD,
	crBuff: WORD

StringParaBuffer PROTO,
	endString: DWORD,
	stX:	   DWORD,
	stY:       DWORD,
	corSt:     WORD

ExibeMenu PROTO,
	endMenu: DWORD,
	tamMenu: BYTE

RenderScene PROTO,
    addrFase: DWORD,
	tFase:	  WORD,
	psObj:	  BYTE

ChecaColisao PROTO,
    px:	DWORD,
    py: DWORD

MovimentaJogador PROTO, 
	px: DWORD,
	py: DWORD

AtualizaFase PROTO, 
	pFase: DWORD,
	cFase: WORD,
	pObj:  BYTE

AtualizaObstaculo PROTO,
	pObstaculo: DWORD

PlaySound PROTO,
    pszSound: PTR BYTE,
    hmod:	  DWORD,
    fdwSound: DWORD


.data
    deviceConnect BYTE "DeviceConnect", 0

    SND_ALIAS    DWORD 00010000h
    SND_RESOURCE DWORD 00040005h
    SND_FILENAME DWORD 00020000h
    SND_ASYNC    DWORD 00000001h

    fail BYTE "colisao.wav", 0
	prox_fasew BYTE "p_fase.wav", 0
	congrats BYTE "fim_jogo.wav", 0


	COLS = 120;//Quantidade de colunas do mapa
	ROWS = 30;//Quantidade de linhas do mapa
	COR_OBSTACULO = 6Fh;//Cor dos elementos do buffer
	COR_FUNDO = 60h
	COR_OBJETIVO = 6Bh
	COR_PERSONAGEM = 64h
	COR_MENU = 0Fh
	COR_RODAPE = 06h
	ELEMENTO_FUNDO = ' '
	ELEMENTO_OBSTACULO = '#'
	ELEMENTO_OBJETIVO = 'O'
	ELEMENTO_PERSONAGEM = 0FEh
	character WORD 0FEh;//Personagem principal
	INI_X = COLS - 1
	INI_Y = 15


	sBLine     BYTE " ", 0
	addrBLine = OFFSET sBLine
	cpBLine = LENGTHOF sBLine - 1
	sRdp	   BYTE "LABrinto - 2019", 0
	addrRdp = OFFSET sRdp
	cpRdp = LENGTHOF sRdp
	sRdp2	   BYTE "Por Joao Gabriel Coli e Vitor Hugo Chaves", 0
	addrRdp2 = OFFSET sRdp2
	cpRdp2 = LENGTHOF sRdp2

	sMenu      BYTE "Menu:", 0
	sMenuJogar BYTE "Jogar (J)", 0
	sMenuInst  BYTE "Visualizar instrucoes (I)", 0
	sMenuSair  BYTE "Sair do jogo (S)", 0
	aMenu      SSTRING <OFFSET sMenu, LENGTHOF sMenu - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					   <OFFSET sMenuJogar, LENGTHOF sMenuJogar - 1, COR_MENU>,
					   <OFFSET sMenuInst, LENGTHOF sMenuInst - 1, COR_MENU>, <OFFSET sMenusair, LENGTHOF sMenuSair - 1, COR_MENU>,
					   <addrBLine, cpBLine, COR_MENU>, <addrRdp, cpRdp, COR_RODAPE>,
					   <addrRdp2, cpRdp2, COR_RODAPE>

	sInstrucoes BYTE "Instrucoes:", 0
	sInstL1     BYTE "O objetivo do jogo e chegar ao final do LABrinto, representado", 0
	sInstL2		BYTE " pelo caracter O ao final do mapa.", 0
	sInstL3     BYTE "A movimentacao do personagem principal, ", ELEMENTO_PERSONAGEM, ", se da com o uso das setas direcionais.", 0
	sInstL4     BYTE "Colidir com qualquer obstaculo, ", ELEMENTO_OBSTACULO, ", ocasiona no reinicio do jogo.", 0
	sInstL5     BYTE "Vence aquele que conseguir passar por todas as fases.", 0
	sInstL6     BYTE "Sair (S)", 0
	aInstrucoes SSTRING <OFFSET sInstrucoes, LENGTHOF sInstrucoes - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
						<OFFSET sInstL1, LENGTHOF sInstL1 - 1, COR_MENU>, <OFFSET sInstL2, LENGTHOF sInstL2 - 1, COR_MENU>,
						<OFFSET sInstL3, LENGTHOF sInstL3 - 1, COR_MENU>, <OFFSET sInstL4, LENGTHOF sInstL4 - 1, COR_MENU>, 
						<OFFSET sInstL5, LENGTHOF sInstL5 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
						<OFFSET sInstL6, LENGTHOF sInstL6 - 1, COR_MENU>

	sCrdtL1 BYTE "Obrigado por jogar!", 0
	sCrdtL2 BYTE "O LABrinto foi desenvolvido para a disciplina a disciplina de", 0
	sCrdtL3 BYTE "Laboratorio de Arquitetura e Organizacao de Computadores 2,", 0
	sCrdtL4 BYTE "ministrada pelo Prof. Dr. Luciano Neris.", 0
	sCrdtL5 BYTE "May the force be with you.", 0
	sCrdtL6 BYTE "Pressione qualquer tecla para sair.", 0
	aCreditos SSTRING <OFFSET sCrdtL1, LENGTHOF sCrdtL1 - 1, COR_MENU>, <OFFSET sCrdtL2, LENGTHOF sCrdtL2 - 1, COR_MENU>,
				      <OFFSET sCrdtL3, LENGTHOF sCrdtL3 - 1, COR_MENU>, <OFFSET sCrdtL4, LENGTHOF sCrdtL4 - 1, COR_MENU>,
					  <OFFSET sCrdtL5, LENGTHOF sCrdtL5 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					  <OFFSET sCrdtL6, LENGTHOF sCrdtL6 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					  <addrRdp, cpRdp, COR_RODAPE>, <addrRdp2, cpRdp2, COR_RODAPE>


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

	fases DADOS_FASE <OFFSET fase1, LENGTHOF fase1, 4d>, <OFFSET fase2, LENGTHOF fase2, 18d>, <OFFSET fase3, LENGTHOF fase3, 15d>


    console HANDLE 0
    buffer CHAR_INFO ROWS * COLS DUP(<<ELEMENTO_FUNDO>, COR_FUNDO>)
    bufferSize COORD <COLS, ROWS>
    bufferCoord COORD <0, 0>
    region SMALL_RECT <0, 0, COLS - 1, ROWS - 1>

    x DWORD INI_X; current position
    y DWORD INI_Y; of the figure


.code
main PROC
	
    INVOKE PlaySound, OFFSET deviceConnect, NULL, SND_ALIAS ;//Configuracao para que haja sons
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov console, eax; save console handle

	ESTADO_MENU:
	INVOKE ExibeMenu, OFFSET aMenu, LENGTHOF aMenu
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		AGUARDA_MSG_MENU:
		call LeTecla
		cmp al, 'j'
		jz ESTADO_CONTAGEM
		cmp al, 'i'
		jz ESTADO_INSTRUCOES
		cmp al, 's'
		jz SAIR
		jmp AGUARDA_MSG_MENU

	ESTADO_INSTRUCOES:
	INVOKE ExibeMenu, OFFSET aInstrucoes, LENGTHOF aInstrucoes
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		AGUARDA_MSG_INSTRUCOES:
		call LeTecla
		cmp al, 's'
		jz ESTADO_MENU
		jmp AGUARDA_MSG_INSTRUCOES


	ESTADO_CREDITOS:
		INVOKE PlaySound, NULL, NULL, SND_ASYNC
		INVOKE PlaySound, OFFSET congrats, NULL, SND_ASYNC
		INVOKE ExibeMenu, OFFSET aCreditos, LENGTHOF aCreditos
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		AGUARDA_MSG_CREDITOS:
		call LeTecla
			cmp eax, 0
			jne ESTADO_MENU
			jmp AGUARDA_MSG_CREDITOS

	ESTADO_CONTAGEM:
	INVOKE LimpaBuffer, 0, COR_MENU
	mov esi, 5
		REGRESSIVA:
		mov eax, esi
		add eax, 30h
		INVOKE CharToBuffer, ((COLS - 1) / 2), ((ROWS - 1) / 2), ax, COR_MENU
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		INVOKE Sleep, 900
		dec esi
		cmp esi, 1
		jge REGRESSIVA
	

	ESTADO_JOGO:
	INVOKE LimpaBuffer, ELEMENTO_FUNDO, COR_FUNDO
		LOOP_JOGO:
		INVOKE RenderScene, (DADOS_FASE PTR fases[esi]).Endr, (DADOS_FASE PTR fases[esi]).qtdEl, (DADOS_FASE PTR fases[esi]).PosObj
		call LeTecla
		cmp al, 's'
		jz ESTADO_MENU
		INVOKE MovimentaJogador, OFFSET x, OFFSET y
		INVOKE ChecaColisao, x, y
		cmp eax, 0
		jz CONTINUE
		cmp eax, 1
		jz REINICIA
		jmp ESTADO_TROCA_FASE

			REINICIA:
			mov x, INI_X
			mov y, INI_Y
			INVOKE PlaySound, OFFSET fail, NULL, SND_ASYNC
			mov esi, 0
			jmp ESTADO_JOGO

		CONTINUE:
		INVOKE CharToBuffer, x, y, character, COR_PERSONAGEM;//Imprime o personagem em sua posicao atual
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		jmp LOOP_JOGO

	ESTADO_TROCA_FASE:
	add esi, SIZEOF DADOS_FASE
	cmp esi, SIZEOF fases - 1
	jae ESTADO_CREDITOS
	mov x, INI_X
	mov y, INI_Y
	INVOKE PlaySound,NULL,NULL,SND_ASYNC
	INVOKE PlaySound, OFFSET prox_fasew, NULL, SND_ASYNC
	jmp ESTADO_JOGO

	SAIR:
	INVOKE LimpaBuffer, 0, COR_MENU
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region

	exit
main ENDP


LimpaBuffer PROC USES eax esi elBuff: WORD, crBuff: WORD
	mov eax, (COLS * ROWS)
	mov esi, 0

	LP1:
	INVOKE CharToBuffer, esi, 0, elBuff, crBuff
	inc esi
	cmp esi, eax
	jb LP1

	ret
LimpaBuffer ENDP


LeTecla PROC
	mov eax, 25
	call Delay
	call ReadKey
	jz SEM_TECLA

	RETORNA:
	ret

	SEM_TECLA:
	mov eax, 0
	jmp RETORNA
LeTecla ENDP

StringParaBuffer PROC USES edx esi eax endString: DWORD, stX: DWORD, stY: DWORD, corSt: WORD
	mov edx, endString
	mov esi, stX

	ETP1:
	movzx eax, BYTE PTR [edx]
	cmp eax, 0
	je ENDST
	INVOKE CharToBuffer, esi, stY, ax, corSt
	inc edx
	inc esi
	jmp ETP1

	ENDST:
	ret
StringParaBuffer ENDP

ExibeMenu PROC USES eax esi edx ecx endMenu: DWORD, tamMenu: BYTE
	INVOKE LimpaBuffer, 0, COR_MENU

	mov eax, endMenu
	movzx esi, tamMenu
	dec esi

	LPSt:
	mov edx, DWORD PTR (SSTRING PTR [eax + esi * SSTRING]).PtrString
	mov ecx, COLS
	sub cx, WORD PTR (SSTRING PTR [eax + esi * SSTRING]).TmString
	shr ecx, 1
	INVOKE StringParaBuffer, edx, ecx, esi, (SSTRING PTR[eax + esi * SSTRING]).CorString
	CTN:
	dec esi
	cmp esi, 0
	jge LPSt

	ret
ExibeMenu ENDP


MontaGridMapa PROC USES eax ecx edx
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

	;//Remove o obstáculo da posição inicial
	mov buffer[((INI_Y + 1) * COLS - 1) * CHAR_INFO].Char, ELEMENTO_FUNDO
	mov buffer[((INI_Y + 1) * COLS - 1) * CHAR_INFO].Attributes, COR_FUNDO


    ret
MontaGridMapa ENDP


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


AtualizaFase PROC USES eax ecx edx pFase: DWORD, cFase: WORD, pObj: BYTE
	mov eax, COLS
	movzx edx, pObj
	mul edx
	mov edx, pFase
	mov ecx, DWORD PTR cFase

	ATUALIZACAO:
	INVOKE CharToBuffer, DWORD PTR (OBSTACULO_FASE PTR [edx]).X, DWORD PTR (OBSTACULO_FASE PTR [edx]).Y, ELEMENTO_FUNDO, COR_FUNDO ;//Limpa a posição antiga
	INVOKE AtualizaObstaculo, edx ;//Atualiza a posição do obstáculo
	INVOKE CharToBuffer, (OBSTACULO_FASE PTR [edx]).X, DWORD PTR (OBSTACULO_FASE PTR [edx]).Y, ELEMENTO_OBSTACULO, COR_OBSTACULO
	add edx, TYPE OBSTACULO_FASE
	loop ATUALIZACAO

	;//Bloco do objetivo
	mov buffer[eax * CHAR_INFO].Char, ELEMENTO_OBJETIVO
	mov buffer[eax * CHAR_INFO].Attributes, COR_OBJETIVO

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

RenderScene PROC USES eax edx ecx addrFase: DWORD, tFase: WORD, psObj: BYTE
    call MontaGridMapa ;//Grid padrao do mapa
	INVOKE AtualizaFase, addrFase, tFase, psObj ;//Fase e movimentacao dos obstaculos
    ret

RenderScene ENDP

MovimentaJogador PROC USES ecx edx px: DWORD, py: DWORD
	
	cmp eax, 0
	jz RESUME

	mov edx, py
	mov ecx, px

	INVOKE CharToBuffer, [ecx], [edx], ELEMENTO_FUNDO, COR_FUNDO ;//Limpa posicao atual

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

ChecaColisao PROC USES edx ecx px: DWORD, py: DWORD
    mov eax, py
    mov edx, COLS
    mul edx
    add eax, px
	movzx ecx, buffer[eax * CHAR_INFO].Char
    cmp buffer[eax * CHAR_INFO].Char, ' '
    jz NAO_COLIDIU
    cmp buffer[eax * CHAR_INFO].Char, 0FEh ;//Garantir que o personagem nao 'colida' consigo mesmo
    jz NAO_COLIDIU
    cmp buffer[eax * CHAR_INFO].Char, ELEMENTO_OBSTACULO
    jz COLIDIU_OBSTACULO
    mov eax, 2 ;//Colidiu com o objetivo
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