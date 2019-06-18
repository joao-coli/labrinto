;//Exercicio 1 Aula 6
INCLUDE Irvine32.inc

.data
    var WORD 1000h
    var2 WORD 2000h
.code

main PROC
mov ax, 0A698Bh
movzx bx, al
movzx ecx, ah
movzx edx, ax
    exit
main ENDP

END main