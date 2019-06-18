; // Encrypt/Decrypt  Tópico 10 

INCLUDE Irvine32.inc

.data
    msg0 BYTE "Top Secret Message!", 0

.code
main PROC
    mov edx, OFFSET msg0
    call WriteString
    call Crlf
    
    push OFFSET msg0
    push SIZEOF msg0
    
    
    call encrypt
    
    call WriteString
    call Crlf
    
    push OFFSET msg0
    push SIZEOF msg0


    call encrypt

    call WriteString
    call Crlf



exit
main ENDP

encrypt PROC
    push ebp

    mov ebp, esp
    push DWORD PTR 00011111b
    mov edx, [ebp + 12]
    mov ecx, [ebp + 8]
    mov eax, [ebp-4]


    L1 :
	   xor[edx], AL;// encrypt char pointed by edx
	   inc edx;// point to next character
    loop L1

    mov edx, [ebp + 12]

    pop eax
    pop ebp
    ret 12
encrypt ENDP

END main