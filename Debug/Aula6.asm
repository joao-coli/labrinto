;//Autores: João Gabriel Coli - 744339 & Vitor Hugo Chaves - 744358


INCLUDE Irvine32.inc

.data
    vA WORD 'y','l','b','m', 'e', 's', 's', 'a'
    vB WORD 20h, 20h, 20h, 20h, 20h, 20h, 20h, 20h
    vC WORD 20h
    vD WORD 0Ah

.code
main PROC

    mov dx, vA+14
    xchg dx, vB

    mov dx, vA+12
    xchg dx, vB+2

    mov dx, vA+10
    xchg dx, vB+4

    mov dx, vA+8
    xchg dx, vB+6

    mov dx, vA+6
    xchg dx, vB+8

    mov dx, vA+4
    xchg dx, vB+10

    mov dx,  vA+2
    xchg dx,  vB+12

    mov dx,  vA
    xchg dx,  vB+14

    mov edx, OFFSET vA
    call WriteString
    mov edx, OFFSET vA + 2
    call WriteString
    mov edx, OFFSET vA + 4
    call WriteString
    mov edx, OFFSET vA + 6
    call WriteString
    mov edx, OFFSET vA + 8
    call WriteString
    mov edx, OFFSET vA + 10
    call WriteString
    mov edx, OFFSET vA + 12
    call WriteString
    mov edx, OFFSET vA + 14
    call WriteString

    mov edx, OFFSET vC
    call WriteString

    mov edx, OFFSET vB
    call WriteString
    mov edx, OFFSET vB+2
    call WriteString
    mov edx, OFFSET vB+4
    call WriteString
    mov edx, OFFSET vB+6
    call WriteString
    mov edx, OFFSET vB+8
    call WriteString
    mov edx, OFFSET vB+10
    call WriteString
    mov edx, OFFSET vB+12
    call WriteString
    mov edx, OFFSET vB+14
    call WriteString

    mov edx, OFFSET vD
    call WriteString

    call WaitMsg


    exit
main ENDP
END main
