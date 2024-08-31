.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

atoi:
    li a0, 0
    li t0, 0
    add t4, a1, a3 # t4 = a1 + a3

    atoi_for:
        li t1, 4
        bge t0, t1, atoi_cont # if t0 >= 4 then cont
        
        li t3, 10
        mul a0, a0, t3 # a0 *= 10
        lb t2, 0(t4) # carrega byte
        addi t2, t2, -'0' # char to int
        add a0, a0, t2  # a0 += t2

        addi t4, t4, 1 # incrementa endereço
        addi t0, t0, 1 # incrementa loop
        j atoi_for
    atoi_cont:

    ret

checa_sinal:

    addi a3, a3, -1
    add t0, a1, a3
    lb t1, 0(t0)
    li t2, '-'
    bne t1, t2, fim_checagem
    li t3, -1
    mul a0, a0, t3
    j fim_checagem

    fim_checagem:
    ret

sqrt:
    li t0, 2
    div t1, a0, t0 # base do metodo babilonico

    li t3, 21
    sqrt_for:
        # metodo babilonico
        div t2, a0, t1
        add t1, t1, t2
        div t1, t1, t0

        addi t3, t3, -1 # decrementa loop
        bnez t3, sqrt_for
    mv a0, t1 # a0 = t1

    ret

itoa:
    add t0, a4, a3
    li t1, 10

    bgez a0, eh_positivo
    li t2, '-'
    sb t2, 0(t0)
    li t2, -1
    mul a0, a0, t2
    j itoa_cont
    eh_positivo:
    li t2, '+'
    sb t2, 0(t0)

    itoa_cont:
    addi t0, t0, 4
    li t6, 4
    itoa_loop:

        rem t4, a0, t1 # t4 = a0 % 10
        addi t4, t4, '0' # int to char 
        sb t4, 0(t0) # armazena o digito
        div a0, a0, t1 # a0 /= 10
        addi t0, t0, -1
        addi t6, t6, -1
        bnez t6, itoa_loop

    ret

# entrada: a3 = velocidade
# saída: a0 = Da
distancia_a:
    
    sub t0, s2, s3
    mul t0, t0, a3
    li t1, 10
    div t0, t0, t1
    mv a0, t0
    ret

# entrada: a3 = velocidade
# saída: a0 = Db
distancia_b:

    sub t0, s2, s4
    mul t0, t0, a3
    li t1, 10
    div t0, t0, t1
    mv a0, t0
    ret

# entrada: a3 = velocidade
# saída: a0 = Dc
distancia_c:

    sub t0, s2, s5
    mul t0, t0, a3
    li t1, 10
    div t0, t0, t1
    mv a0, t0
    ret

calcula_y:

    mul t0, s1, s1 # Yb^2
    mul t1, s6, s6 # Da^2
    mul t2, s7, s7 # Db^2
    add t0, t0, t1
    sub t0, t0, t2
    li t3, 2
    mul t3, t3, s1
    div t0, t0, t3
    mv a0, t0

    ret

calcula_modxsq:

    mul t0, s6, s6 # Da^2
    mul t1, s9, s9 # y^2
    sub t0, t0, t1
    mv a0, t0
    ret

calcula_x:
    li t5, -1
    mul t2, s8, s8 # Dc^2

    # x positivo
    sub t0, s10, s0 # x - xc
    mul t0, t0, t0 # (x-xc)^2
    mul t1, s9, s9 # y^2
    add t0, t0, t1 # (x-xc)^2 + y^2

    beq t0, t2, xend
    /*
    sub t0, t0, t2
    mul t3, t0, t0

    # x negativo
    mul t0, s10, t5
    sub t0, t0, s0 # -x - xc
    mul t0, t0, t0 # (-x-xc)^2
    mul t1, s9, s9 # y^2
    add t0, t0, t1 # (-x-xc)^2 + y^2

    bne t0, t2, xend

    sub t0, t0, t2
    mul t4, t0, t0

    bgt t4, t3, xend
    */
    
    mul a0, a0, t5
    ret

    xend:
    ret

main:
    # Código aqui
    jal read1 # leitura da primeira linha

    # Xc
    li a3, 1
    jal atoi
    jal checa_sinal
    mv s0, a0

    # Yb
    li a3, 7
    jal atoi
    jal checa_sinal
    mv s1, a0

    jal read2

    # Tr
    li a3, 0
    jal atoi
    mv s2, a0

    # Ta
    addi a3, a3, 5
    jal atoi
    mv s3, a0

    # Tb
    addi a3, a3, 5
    jal atoi
    mv s4, a0

    # Tc
    addi a3, a3, 5
    jal atoi
    mv s5, a0

    li a3, 3
    jal distancia_a 
    mv s6, a0 # s6 = Da
    jal distancia_b
    mv s7, a0 # s7 = Db
    jal distancia_c
    mv s8, a0 # s8 = Dc

    jal calcula_y
    mv s9, a0 # s9 = y
    jal calcula_modxsq
    jal sqrt
    mv s10, a0 # s10 = x
    jal calcula_x

    li a3, 0
    jal itoa

    li t0, ' '
    sb t0, 5(a4)

    li a3, 7
    mv a0, s9
    jal itoa

    li t0, '\n'
    sb t0, 12(a4)

    jal write # escreve

    ret

read1:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address1 # in buffer 1
    li a2, 12           # size - Reads 12 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

read2:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address2 # in buffer 2
    la a4, result # out buffer
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 13           # size - Writes 12 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address1: .skip 0xc  # buffer
input_address2: .skip 0xf4 # buffer

result: .skip 0xd