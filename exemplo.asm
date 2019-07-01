TITLE LAbrinto

;//--------------------------------------- Inclusoes e definicoes ----------------------------------------------

INCLUDE Irvine32.inc
INCLUDELIB Winmm.lib ;//Usada para reproduzir sons

;//Union-type CHARTYPE: permite a definicao de um char unicode ou ascii sem perda de compatibilidade
CHARTYPE UNION
	UnicodeChar    WORD ?
	AsciiChar      DB ?
CHARTYPE ENDS

;//Struct CHAR_INFO: elemento passado ao buffer e que sera impresso no console
CHAR_INFO STRUCT
	Char          CHARTYPE <> ;//Elemento do tipo CHARTYPE que representa o caracter
	Attributes    WORD ? ;//Atributos passados para o terminal, como cor de texto e fundo do caracter
CHAR_INFO ENDS

;//Struct SSTRING: estrutura para agilizar a manipulacao e uso de strings a serem impressas na tela
SSTRING STRUCT
	PtrString DWORD ? ;//Ponteiro para a string na memoria
	TmString  WORD ? ;//Tamanho da string. Permite ultrapassar o limite do MASM de 512 caracteres
	CorString WORD ? ;//Cor de impressao da string no terminal 
SSTRING ENDS

;//Struct OBSTACULO_FASE: define um obstaculo presente no mapa, seus eixos de movimentacao e posicao inicial
OBSTACULO_FASE STRUCT
	Movimento	  BYTE ? ;//Para onde ira se mover: 0 estatico, 1 cima, 2 baixo, 3 direita, 4 esquerda
	X			  DWORD ? ;//Posicao inicial x
	Y			  DWORD ? ;//Posicao inicial y
OBSTACULO_FASE ENDS

;//Struct DADOS_FASE: encapsula uma fase, permitindo a presenca de varios obstaculos
DADOS_FASE STRUCT
	Endr   DWORD ? ;//Endereço da fase, que e um vetor de OBSTACULO_FASE
	QtdEl  WORD ? ;//Quantidade de elementos na fase
	PosObj BYTE ? ;//Posicao do objetivo na primeira coluna do mapa
DADOS_FASE ENDS

;//Definicoes presente nas referencias do professor. Para impressao no buffer e consequentemente no console
;// -----------------------------------------
WriteConsoleOutput EQU <WriteConsoleOutputA>

WriteConsoleOutput PROTO,
hConsoleOutput : HANDLE,
	lpBuffer : PTR CHAR_INFO,
	dwBufferSize : COORD,
	dwBufferCoord : COORD,
	lpWriteRegion : PTR SMALL_RECT

;//CharToBuffer: insere no buffer um dado char com uma dada cor, nas posicoes x e y informadas
;//Definicioes mais detalhadas na area de implementacao
CharToBuffer PROTO,
	bufx: DWORD,
	bufy: DWORD,
	char: WORD,
	cor:  WORD  

;// -----------------------------------------

;//LimpaBuffer: preenche o buffer (todas as posicoes) com um dado elemento de uma dada cor
;//Definicioes mais detalhadas na area de implementacao
LimpaBuffer PROTO,
	elBuff: WORD, ;//Elemento
	crBuff: WORD ;//Cor do elemento

;//StringParaBuffer: insere no buffer uma string inteira (com cor personalizavel), a partir das posicoes x e y informadas
;//Definicioes mais detalhadas na area de implementacao
StringParaBuffer PROTO,
	endString: DWORD, ;//Endereco da string
	stX:	   DWORD, ;//Posicao x onde comecar a insercao
	stY:       DWORD, ;//Posicao y onde comecar a insercao
	corSt:     WORD ;//Cor de cada char

;//ExibeMenu: carrega no buffer o menu inicial do jogo, dado um array de strings e a quantidade de SSTRINGs
;//Definicioes mais detalhadas na area de implementacao
ExibeMenu PROTO,
	endMenu: DWORD, ;//Endereco para array de SSTRINGS
	tamMenu: BYTE ;//Tamanho do array de SSTRINGs

;//RenderScene: carrega no buffer o grid e mapa atual do jogo, dada uma fase, seu tamanho e a posicao do objetivo
;//Definicioes mais detalhadas na area de implementacao
RenderScene PROTO,
    addrFase: DWORD, ;//Endereco para um array de OBSTACULO_FASE
	tFase:	  WORD, ;//Tamanho do array de fase
	psObj:	  BYTE ;//Posicao do objetivo na fase

;//ChecaColisao: checa se um elemento do mapa colidiu com algum outro elemento
;//Definicioes mais detalhadas na area de implementacao
ChecaColisao PROTO,
    px:	DWORD, ;//Posicao x a ser analisada
    py: DWORD ;//Posicao y a ser analisada

;//MovimentaJogador: move o personagem principal para as posicoes x e y dadas
;//Definicioes mais detalhadas na area de implementacao
MovimentaJogador PROTO, 
	px: DWORD, ;//Posicao x
	py: DWORD ;//Posicao y

;//AtualizaFase: dada uma fase, seu tamanho e posicao de objetivo, atualiza a posicao dos obstaculos moveis
;//Definicioes mais detalhadas na area de implementacao
AtualizaFase PROTO, 
	pFase: DWORD, ;//Endereco para a fase
	cFase: WORD, ;//Tamanho da fase (qtd. de obstaculos)
	pObj:  BYTE ;//Posicao do objetivo na fase

;//AtualizaObstaculo: atualiza a posicao de um obstaculo especifico
;//Definicioes mais detalhadas na area de implementacao
AtualizaObstaculo PROTO,
	pObstaculo: DWORD ;//Endereco do OBSTACULO_FASE

;//Parte de biblioteca do windows citada no moodle da disciplina. Referente a reproducao de sons
;//------------------------
PlaySound PROTO,
pszSound: PTR BYTE,
	hmod : DWORD,
	fdwSound : DWORD
;//-------------------------

;//------------------------------------- Constantes e elementos de memoria ------------------------------------------

.data

	;//Parte de biblioteca do windows citada no moodle da disciplina. Referente a reproducao de sons
	;//------------------------------------
    deviceConnect BYTE "DeviceConnect", 0

    SND_ALIAS    DWORD 00010000h
    SND_RESOURCE DWORD 00040005h
    SND_FILENAME DWORD 00020000h
    SND_ASYNC    DWORD 00000001h ;//Executa um audio de forma assincrona (pode ser interrompido por outro)
	SND_LOOP	 DWORD 00000008h ;//Executa um audio em loop
	SND_ALOOP    DWORD 00000009h ;//Executa um audio em loop de forma assincrona

	;//Definicao dos arquivos de audio a serem usados
    fail BYTE "colisao.wav", 0
	prox_fasew BYTE "p_fase.wav", 0
	congrats BYTE "fim_jogo.wav", 0
	menu_music BYTE "menu_music.wav", 0
	;//------------------------------------

	;//Constantes utilizadas para a implementacao
	;//--------------------------------------------------------------------------------------------------------------------
	COLS = 120 ;//Quantidade de colunas do mapa
	ROWS = 30 ;//Quantidade de linhas do mapa
	COR_OBSTACULO = 6Fh ;//Cor dos elementos do buffer
	COR_FUNDO = 60h ;//Cor do fundo do mapa
	COR_OBJETIVO = 6Bh ;// ... demais elementos sao auto-explicativos
	COR_PERSONAGEM = 64h
	COR_MENU = 0Fh
	COR_RODAPE = 06h
	ELEMENTO_FUNDO = ' '
	ELEMENTO_OBSTACULO = '#'
	ELEMENTO_OBJETIVO = 'O'
	ELEMENTO_PERSONAGEM = 0FEh
	CONTAGEM = 5 ;//Indicador de contagem antes de iniciar o jogo
	DELAY_ENTRADA = 25 ;//Quanto tempo dar para a deteccao da entrada
	character WORD 0FEh;//Personagem principal
	INI_X = COLS - 1 ;//Posicao x inicial do personagem
	INI_Y = 15 ;//Posicao y inicial do personagem

	sBLine     BYTE " ", 0 ;//Representa uma linha em branco
	addrBLine = OFFSET sBLine ;//Endereco da linha em branco
	cpBLine = LENGTHOF sBLine - 1 ;//Tamanho da linha em branco
	sRdp	   BYTE "LABrinto - 2019", 0 ;//Representa um texto de 'rodape'
	addrRdp = OFFSET sRdp ;//Endereco da string
	cpRdp = LENGTHOF sRdp ;//Tamanho da string
	sRdp2	   BYTE "Por Joao Gabriel Coli e Vitor Hugo Chaves", 0 ;//Representa outro texto de 'rodape'
	addrRdp2 = OFFSET sRdp2 ;//Endereco da string
	cpRdp2 = LENGTHOF sRdp2 ;//Tamanho da string

	;//Definicao de strings para o menu principal
	sMenu      BYTE "Menu:", 0
	sMenuJogar BYTE "Jogar (J)", 0
	sMenuInst  BYTE "Visualizar instrucoes (I)", 0
	sMenuSair  BYTE "Sair do jogo (S)", 0
	;//Criacao das SSTRINGs para o menu principal
	aMenu      SSTRING <OFFSET sMenu, LENGTHOF sMenu - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					   <OFFSET sMenuJogar, LENGTHOF sMenuJogar - 1, COR_MENU>,
					   <OFFSET sMenuInst, LENGTHOF sMenuInst - 1, COR_MENU>, <OFFSET sMenusair, LENGTHOF sMenuSair - 1, COR_MENU>,
					   <addrBLine, cpBLine, COR_MENU>, <addrRdp, cpRdp, COR_RODAPE>,
					   <addrRdp2, cpRdp2, COR_RODAPE>

	;//Definicao de strings para o menu instrucoes
	sInstrucoes BYTE "Instrucoes:", 0
	sInstL1     BYTE "O objetivo do jogo e chegar ao final do LABrinto, representado", 0
	sInstL2		BYTE " pelo caracter O ao final do mapa.", 0
	sInstL3     BYTE "A movimentacao do personagem, ", ELEMENTO_PERSONAGEM, ", se da com o uso das setas. 'P' pausa o jogo e 'S' retorna ao menu.", 0
	sInstL4     BYTE "Colidir com qualquer obstaculo, ", ELEMENTO_OBSTACULO, ", ocasiona no reinicio do jogo.", 0
	sInstL5     BYTE "Vence aquele que conseguir passar por todas as fases.", 0
	sInstL6     BYTE "Sair (S)", 0
	;//Criacao das SSTRINGs para o menu instrucoes
	aInstrucoes SSTRING <OFFSET sInstrucoes, LENGTHOF sInstrucoes - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
						<OFFSET sInstL1, LENGTHOF sInstL1 - 1, COR_MENU>, <OFFSET sInstL2, LENGTHOF sInstL2 - 1, COR_MENU>,
						<OFFSET sInstL3, LENGTHOF sInstL3 - 1, COR_MENU>, <OFFSET sInstL4, LENGTHOF sInstL4 - 1, COR_MENU>, 
						<OFFSET sInstL5, LENGTHOF sInstL5 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
						<OFFSET sInstL6, LENGTHOF sInstL6 - 1, COR_MENU>

	;//Definicao de strings para os creditos
	sCrdtL1 BYTE "Obrigado por jogar!", 0
	sCrdtL2 BYTE "O LABrinto foi desenvolvido para a disciplina a disciplina de", 0
	sCrdtL3 BYTE "Laboratorio de Arquitetura e Organizacao de Computadores 2,", 0
	sCrdtL4 BYTE "ministrada pelo Prof. Dr. Luciano Neris.", 0
	sCrdtL5 BYTE "May the force be with you.", 0
	sCrdtL6 BYTE "Pressione qualquer tecla para sair.", 0
	;//Criacao das SSTRINGs para os creditos
	aCreditos SSTRING <OFFSET sCrdtL1, LENGTHOF sCrdtL1 - 1, COR_MENU>, <OFFSET sCrdtL2, LENGTHOF sCrdtL2 - 1, COR_MENU>,
				      <OFFSET sCrdtL3, LENGTHOF sCrdtL3 - 1, COR_MENU>, <OFFSET sCrdtL4, LENGTHOF sCrdtL4 - 1, COR_MENU>,
					  <OFFSET sCrdtL5, LENGTHOF sCrdtL5 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					  <OFFSET sCrdtL6, LENGTHOF sCrdtL6 - 1, COR_MENU>, <addrBLine, cpBLine, COR_MENU>,
					  <addrRdp, cpRdp, COR_RODAPE>, <addrRdp2, cpRdp2, COR_RODAPE>
	;//------------------------------------------------------------------------------------------------------------------

	;//Definicao dos elementos de mapa
	;//------------------------------------------------------------------------------------------------------------------
	fase1 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 13d, 15d>, <1d, 15d, 15d>, <2d, 21d, 15d>, <1d, 25d, 15d>, <2d, 33d, 15d>,
		<1d, 38d, 15d>, <2d, 40d, 15d>, <1d, 50d, 15d>, <2d, 55d, 15d>, <1d, 60d, 15d>, <2d, 77d, 15d>, <1d, 75d, 15d>,
		<2d, 87d, 15d>, <1d, 89d, 15d>, <2d, 95d, 15d>, <1d, 99d, 15d>, <2d, 103d, 15d>, <1d, 110d, 15d>, <1d, 65d, 15d>,
		<2d, 70d, 15d>

	fase2 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 6d, 15d>, <1d, 7d, 15d>, <2d, 8d, 15d>, <1d, 9d, 15d>, <2d, 10d, 15d>,
		<1d, 57d, 8d>, <2d, 58d, 8d>, <1d, 59d, 8d>, <2d, 60d, 8d>, <1d, 61d, 8d>, <2d, 62d, 8d>,
		<1d, 105d, 25d>, <2d, 106d, 25d>, <1d, 107d, 25d>, <2d, 108d, 25d>, <1d, 109d, 25d>, <2d, 110d, 25d>

     fase3 OBSTACULO_FASE <1d, 5d, 15d>, <2d, 7d, 15d>, <1d, 9d, 15d>,  <2d, 11d, 15d>, <1d, 13d, 15d>, <2d, 15d, 15d>,
	    <1d, 17d, 15d>, <2d, 19d, 15d>, <1d, 21d, 15d>, <2d, 23d, 15d>, <1d, 25d, 15d>, <2d, 27d, 15d>,<1d, 29d, 15d>,
	    <2d, 31d, 15d>, <1d, 33d, 15d>,  <2d, 35d, 15d>, <1d, 37d, 15d>, <2d, 39d, 15d>, <1d, 41d, 15d>, <2d, 43d, 15d>,
	    <1d, 45d, 15d>, <2d, 47d, 15d>

	fase4 OBSTACULO_FASE  <1d, 5d, 15d>, <2d, 13d, 15d>, <1d, 15d, 15d>, <2d, 21d, 15d>, <1d, 25d, 15d>, <2d, 33d, 15d>,
		<1d, 38d, 15d>, <1d, 50d, 15d>, <2d, 55d, 15d>, <2d, 77d, 15d>, <1d, 75d, 15d>,
		<2d, 87d, 15d>, <1d, 89d, 15d>, <2d, 95d, 15d>, <1d, 99d, 15d>, <2d, 103d, 15d>,  <1d, 65d, 15d>,
		<2d, 70d, 15d>, <3d, 3d, 5d>, <4d, 2d, 25d>, <3d, 20d, 8d>, <4d, 70d, 20d>, <3d, 10d, 14d>, <4d, 1d, 16d>,
		<2d, 1d, 5d>, <4d, 1d, 15d>

	fases DADOS_FASE <OFFSET fase4, LENGTHOF fase4, 4d>, <OFFSET fase2, LENGTHOF fase2, 18d>, <OFFSET fase3, LENGTHOF fase3, 15d>
	;//------------------------------------------------------------------------------------------------------------------


	;//Definicao dos elementos do buffer
	;//--------------------------------------------------------------
    console HANDLE 0
    buffer CHAR_INFO ROWS * COLS DUP(<<ELEMENTO_FUNDO>, COR_FUNDO>)
    bufferSize COORD <COLS, ROWS>
    bufferCoord COORD <0, 0>
    region SMALL_RECT <0, 0, COLS - 1, ROWS - 1>
	;//--------------------------------------------------------------


	;//Definicao das variaveis de posicao do personagem (character)
    x DWORD INI_X; current position
    y DWORD INI_Y; of the figure



.code
main PROC
	
	;//----------------------------------------- Execucao do jogo ------------------------------------------------

	;//Inicializacao das configuracoes de som e buffer
	;//--------------------------------------------------------------
    INVOKE PlaySound, OFFSET deviceConnect, NULL, SND_ALIAS ;//Configuracao para que haja sons
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE ;//Cria o manipulador do console
    mov console, eax ;//Salva o manipulador do console
	;//--------------------------------------------------------------

	;//Estado menu
	;//-----------------------------------------------------------------------------------------
	ESTADO_MENU:
	INVOKE PlaySound, OFFSET menu_music, NULL, SND_ALOOP ;//Inicia a musica em loop assincrono
	ESTADO_MENU2:
	INVOKE ExibeMenu, OFFSET aMenu, LENGTHOF aMenu ;//Carrega os itens do menu no buffer
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region ;//Transfere o buffer para o console
		AGUARDA_MSG_MENU: ;//Espera por entrada do usuario
		call LeTecla
		cmp al, 'j'
		jz ESTADO_CONTAGEM ;//Inicia o jogo com j
		cmp al, 'i'
		jz ESTADO_INSTRUCOES ;//Carrega as intrucoes com i
		cmp al, 's'
		jz SAIR ;//Finaliza o programa com s
		jmp AGUARDA_MSG_MENU
	;//-----------------------------------------------------------------------------------------


	;//Estado instrucoes
	;//-----------------------------------------------------------------------------------------
	ESTADO_INSTRUCOES:
	INVOKE ExibeMenu, OFFSET aInstrucoes, LENGTHOF aInstrucoes ;//Carrega os itens de instrucoes no buffer
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		AGUARDA_MSG_INSTRUCOES: ;//Espera por entrada do usuario
		call LeTecla
		cmp al, 's'
		jz ESTADO_MENU2 ;//Retorna ao estado de menu sem reiniciar a musica
		jmp AGUARDA_MSG_INSTRUCOES
	;//-----------------------------------------------------------------------------------------


	;//Estado instrucoes
	;//-----------------------------------------------------------------------------------------
	ESTADO_CREDITOS:
		INVOKE PlaySound, NULL, NULL, SND_ASYNC ;//Finaliza outros sons em execucao
		INVOKE PlaySound, OFFSET congrats, NULL, SND_ASYNC ;//Reproduz musica de final de jogo
		INVOKE ExibeMenu, OFFSET aCreditos, LENGTHOF aCreditos ;//Carrega os itens de creditos no buffer
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		AGUARDA_MSG_CREDITOS: ;//Espera por entrada do usuario
			call LeTecla
			cmp eax, 0
			jne ESTADO_MENU
			jmp AGUARDA_MSG_CREDITOS
	;//-----------------------------------------------------------------------------------------


	;//Estado contagem (pre inicio de jogo)
	;//-----------------------------------------------------------------------------------------
	ESTADO_CONTAGEM:
	INVOKE PlaySound, NULL, NULL, SND_ASYNC ;//Finaliza outros sons em execucao
	INVOKE LimpaBuffer, 0, COR_MENU ;//Preenche o buffer com zeros (0)
	mov esi, CONTAGEM ;//Define de onde comeca a contagem regressiva
		REGRESSIVA:
		mov eax, esi
		add eax, 30h ;//Transforma um int em um caracter ascii
		INVOKE CharToBuffer, ((COLS - 1) / 2), ((ROWS - 1) / 2), ax, COR_MENU ;//Coloca o caracter no buffer
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region
		INVOKE Sleep, 900 ;//Espera um pouco menos de um segundo
		dec esi
		cmp esi, 1 ;//Verifica se a contagem passou de 1 (para baixo)
		jge REGRESSIVA
	;//-----------------------------------------------------------------------------------------


	;//Estado jogo (ou estado Fase)
	;//-----------------------------------------------------------------------------------------------------------------------------------
	ESTADO_JOGO:
	INVOKE LimpaBuffer, ELEMENTO_FUNDO, COR_FUNDO ;//Prenche o buffer com elementos inicais de fase
		LOOP_JOGO:
		INVOKE RenderScene, (DADOS_FASE PTR fases[esi]).Endr, (DADOS_FASE PTR fases[esi]).qtdEl, (DADOS_FASE PTR fases[esi]).PosObj ;//Carrega no buffer a fase[esi]
		call LeTecla ;//Escuta entrada do usuario
		cmp al, 's'
		jz ESTADO_MENU
		cmp al, 'p'
		jz ESTADO_PAUSA
		INVOKE MovimentaJogador, OFFSET x, OFFSET y ;//Atualiza por referencia a posicao do jogador se o usuario tiver pressionado algum direcional
		INVOKE ChecaColisao, x, y ;//Checa se a nova posicao do personagem nao colidiu com algum elemento
		cmp eax, 0
		jz CONTINUE ;//Continua se nao colidiu
		cmp eax, 1
		jz REINICIA ;//Reinicia se colidiu com obstaculo
		jmp ESTADO_TROCA_FASE ;//Troca de fase se colidiu com objetivo

			REINICIA:
			mov x, INI_X ;//Reinicia posicoes
			mov y, INI_Y
			INVOKE PlaySound, OFFSET fail, NULL, SND_ASYNC ;//Reproduz som de colisao
			mov esi, 0 ;//Forca fase inicial
			jmp ESTADO_JOGO

		CONTINUE:
		INVOKE CharToBuffer, x, y, character, COR_PERSONAGEM ;//Imprime o personagem em sua posicao atual
		INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region ;//Imprime no console o buffer
		jmp LOOP_JOGO
	;//-----------------------------------------------------------------------------------------------------------------------------------


	;//Estado troca fase
	;//------------------------------------------------------
	ESTADO_TROCA_FASE:
	add esi, SIZEOF DADOS_FASE ;//Incrementa o indice para o vetor de fases
	cmp esi, SIZEOF fases - 1 ;//Verifica se ha proxima fase no vetor de fases
	jae ESTADO_CREDITOS ;//Se nao ha proxima fase, finalizar o jogo
	mov x, INI_X ;//Havendo proxima fase, reiniciar posicao do personagem, 
	mov y, INI_Y
	INVOKE PlaySound,NULL,NULL,SND_ASYNC ;//reproduzir som de passagem
	INVOKE PlaySound, OFFSET prox_fasew, NULL, SND_ASYNC ;//reproduzir som de passagem
	jmp ESTADO_JOGO ;//Retorna ao jogo
	;//------------------------------------------------------

	;//Estado pausa -> apenas para a mudanca do mapa e do personagem
	;//------------------------------------------------------
	ESTADO_PAUSA:
	call LeTecla
	cmp al, 's'
	jz ESTADO_MENU
	cmp al, 'p'
	jz LOOP_JOGO
	jmp ESTADO_PAUSA
	;//------------------------------------------------------

	SAIR:
	INVOKE LimpaBuffer, 0, COR_MENU
	INVOKE WriteConsoleOutput, console, ADDR buffer, bufferSize, bufferCoord, ADDR region

	exit
main ENDP

;//-------------------------------------- Funcoes do jogo ---------------------------------------------

;//LimpaBuffer: Preenche o buffer com o elemento informado
;//		Parametros: - elBuff -> char a ser usado no preenchimento 
;//					- crBuff -> cor do char
;//		Retorno: --
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


;//LeTecla: Aguarda um tempo fixo para a entrada do jogador. Retorna a entrada se houver
;//		Parametros:  --
;//		Retorno:  - eax -> valor de ReadKey se houve tecla pressionada, 0 se nao houve
LeTecla PROC
	mov eax, DELAY_ENTRADA
	call Delay
	call ReadKey
	jz SEM_TECLA

	RETORNA:
	ret

	SEM_TECLA:
	mov eax, 0
	jmp RETORNA
LeTecla ENDP


;//StringParaBuffer: insere no buffer uma string inteira (com cor personalizavel), a partir das posicoes x e y informadas
	;//		Parametros: - endString -> endereco para uma string 
	;//					- stX -> posicao x onde comecar o preenchimento
	;//					- stY -> posicao y onde comecar o preenchimento
	;//					- corSt -> cor dos caracteres da string
	;//		Retorno: --
StringParaBuffer PROC USES edx esi eax endString: DWORD, stX: DWORD, stY: DWORD, corSt: WORD
	mov edx, endString
	mov esi, stX

	ETP1: ;//Ate ser encontrado o finalizador 0
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


;//ExibeMenu: carrega no buffer o menu inicial do jogo, dado um array de strings e a quantidade de SSTRINGs
	;//		Parametros: - endMenu -> endereco para um vetor de SSTRINGs 
	;//					- tamMenu -> tamanho do vetor de SSTRINGs
	;//		Retorno: --
ExibeMenu PROC USES eax esi edx ecx endMenu: DWORD, tamMenu: BYTE
	INVOKE LimpaBuffer, 0, COR_MENU

	mov eax, endMenu
	movzx esi, tamMenu
	dec esi

	LPSt:
	mov edx, DWORD PTR (SSTRING PTR [eax + esi * SSTRING]).PtrString
	mov ecx, COLS
	sub cx, WORD PTR (SSTRING PTR [eax + esi * SSTRING]).TmString
	shr ecx, 1 ;//Centraliza texto: (tamMapa - tamString)/2
	INVOKE StringParaBuffer, edx, ecx, esi, (SSTRING PTR[eax + esi * SSTRING]).CorString
	CTN:
	dec esi
	cmp esi, 0
	jge LPSt

	ret
ExibeMenu ENDP

;//MontaGridMapa: atualiza o buffer com o grid padrao de uma fase
	;//		Parametros: --
	;//		Retorno: --
MontaGridMapa PROC USES eax ecx edx
    xor eax, eax	;//EAX = 0

	LINHA1: ;//Primeira linha contendo obstaculos
	INVOKE CharToBuffer, eax, 0, ELEMENTO_OBSTACULO, COR_OBSTACULO
	inc eax
	cmp eax, COLS
	jl LINHA1

	COLUNAS: ;//Primeira e ultima colunas contendo obstaculos
	INVOKE CharToBuffer, eax, 0, ELEMENTO_OBSTACULO, COR_OBSTACULO
	add eax, COLS-1
	INVOKE CharToBuffer, eax, 0, ELEMENTO_OBSTACULO, COR_OBSTACULO
	inc eax
	cmp eax, (ROWS - 1)*(COLS - 2)
	jl COLUNAS

	LINHANROWS: ;//Ultima linha contendo obstaculos
	INVOKE CharToBuffer, eax, 0, ELEMENTO_OBSTACULO, COR_OBSTACULO
	inc eax
	cmp eax, ROWS*COLS
	jl LINHANROWS

	;//Remove o obstáculo da posição inicial
	INVOKE CharToBuffer, ((INI_Y + 1) * COLS - 1), 0, ELEMENTO_FUNDO, COR_FUNDO

    ret
MontaGridMapa ENDP


;//CharToBuffer: insere no buffer um dado char com uma dada cor, nas posicoes x e y informadas
	;//		Parametros: - bufx -> posicao x onde inserir o char, inteiro
	;//					- bufy -> posicao y onde inserir o char, inteiro
	;//					- char -> char a ser inserido
	;//					- cor -> cor do char a ser inserido
	;//		Retorno: --
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


;//AtualizaFase: dada uma fase, seu tamanho e posicao de objetivo, atualiza a posicao dos obstaculos moveis
;//		Parametros: - pFase -> endereco do array de OBSTACULO_FASE 
;//					- cFase -> tamanho do array
;//					- pObj -> posicao y do objetivo na fase
;//		Retorno: --
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
	INVOKE CharToBuffer, eax, 0, ELEMENTO_OBJETIVO, COR_OBJETIVO

	ret
AtualizaFase ENDP


;//AtualizaObstaculo: atualiza a posicao de um obstaculo especifico
	;//		Parametros: - pObstaculo -> endereco de memoria do OBSTACULO_FASE
	;//		Retorno: --
AtualizaObstaculo PROC USES eax edx ecx ebx esi pObstaculo: DWORD

	mov edx, pObstaculo

	mov ebx, DWORD PTR(OBSTACULO_FASE PTR[edx]).X
	mov ecx, DWORD PTR(OBSTACULO_FASE PTR[edx]).Y
	movzx esi, BYTE PTR (OBSTACULO_FASE PTR [edx]).Movimento ;//Checa para onde mover
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


;//RenderScene: carrega no buffer o grid e mapa atual do jogo, dada uma fase, seu tamanho e a posicao do objetivo
	;//		Parametros: - addrFase -> endereco de uma fase (vetor de obstaculos) 
	;//					- tFase -> tamanho da fase
	;//					- psObj -> posicao em y do objetivo na fase
	;//		Retorno: --
RenderScene PROC USES eax edx ecx addrFase: DWORD, tFase: WORD, psObj: BYTE
    call MontaGridMapa ;//Grid padrao do mapa
	INVOKE AtualizaFase, addrFase, tFase, psObj ;//Fase e movimentacao dos obstaculos
    ret

RenderScene ENDP

;//MovimentaJogador: move o personagem principal para as posicoes x e y dadas
	;//		Parametros: - px -> endereco da variavel de posicao atual x do personagem
	;//					- py -> endereco da variavel de posical atual y do personagem
	;//		Retorno: --
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


;//ChecaColisao: checa se um elemento do mapa colidiu com algum outro elemento
	;//		Parametros: - px -> posicao x do elemento
	;//					- py -> posicao y do elemento
	;//		Retorno: - eax -> 0 se nao colidiu, 1 se colidiu com obstaculo e 2 se colidiu com objetivo
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