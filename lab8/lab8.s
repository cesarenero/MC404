.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

# a0: coordenada x do pixel
# a1: coordenada y do pixel	Define a cor de um pixel de um canvas específico. Para escala de cinza, use os mesmos valores para as cores
# a2: cores concatenadas do pixel: R-G-B-A	(R = G = B) e alfa = 255
# A2[31..24]: Vermelho	
# A2[23..16]: Verde	
# A2[15..8]: Azul	
# A2[7..0]: Alfa
setPixel:
    li a7, 2200 # syscall setPixel (2200)
    ecall
    ret

setCanvasSize:
    mv a0, s1
    mv a1, s2
    li a7, 2201 # syscall setCanvasSize
    ecall
    ret

extrai_medidas:
    add a1, s0, a3
    li t0, ' '
    li t1, '\n'
    li t2, 10
    li s1, 0             # largura
    li s2, 0             # altura
    
    for1:
        lbu t3, 0(a1)
        beq t3, t0, end_for1

        mul s1, s1, t2
        addi t3, t3, -'0'
        add s1, s1, t3
        
        addi a1, a1, 1
        addi a3, a3, 1
        j for1
    end_for1:
    addi a1, a1, 1
    addi a3, a3, 1

    for2:
        lbu t3, 0(a1)
        beq t3, t1, end_for2

        mul s2, s2, t2
        addi t3, t3, -'0'
        add s2, s2, t3
        
        addi a1, a1, 1
        addi a3, a3, 1
        j for2
    end_for2:
    addi a3, a3, 1

    ret

main:
    jal open
    jal read
    mv s0, a1
    li a3, 3
    jal extrai_medidas
    jal setCanvasSize
    jal print
    ret

open:
    la a0, input_file    # endereço do caminho do arquivo
    li a1, 0             # flags (0: rdonly)
    li a2, 0             # mode (ignorado)
    li a7, 1024          # syscall open
    ecall
    ret

read:
    # li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 262159           # size - Reads 262159 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

print:
    addi a3, a3, 4
    add a6, s0, a3

    li t2, 0    # y
    for_i:
        li t1, 0    # x
        beq t1, s1, end_for_i

        for_j:
            beq t1, s1, end_for_j 

            lbu t0, 0(a6)
            mv a0, t1
            mv a1, t2
            li a2, 0
            # R
            sll t3, t0, 24
            or a2, a2, t3
            # G
            sll t3, t0, 16
            or a2, a2, t3
            # B
            sll t3, t0, 8
            or a2, a2, t3
            # A
            ori a2, a2, 255
            jal setPixel

            addi a6, a6, 1
            addi t1, t1, 1
            j for_j
        end_for_j:

        addi t2, t2, 1
        blt t2, s2, for_i
    end_for_i:
    ret

.data
input_file: .asciz "image.pgm"

.bss
input_address: .skip 262159  # buffer