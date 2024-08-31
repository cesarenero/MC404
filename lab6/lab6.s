.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

atoi:
    li a0, 0
    li a6, 0
    add t4, a1, a3 # t4 = a1 + a3
    
    atoi_for:
        li t1, 4
        bge a6, t1, atoi_cont # if a6 >= 4 then cont

        lb t2, 0(t4) # carrega byte
        addi t2, t2, -'0' # char to int
        li t3, 10
        mul a0, a0, t3 # a0 *= 10
        add a0, a0, t2  # a0 += t2

        addi t4, t4, 1 # incrementa endereço
        addi a6, a6, 1 # incrementa loop
        j atoi_for
    atoi_cont:

    ret

sqrt:
    li t0, 2
    div t1, a0, t0 # base do metodo babilonico

    li a6, 0
    sqrt_for:
        li t3, 10
        bge a6, t3, sqrt_cont # if a6 >= 10 then cont
        
        # metodo babilonico
        div t2, a0, t1
        add t1, t1, t2
        div t1, t1, t0

        addi a6, a6, 1 # incrementa loop
        j sqrt_for
    sqrt_cont:
    mv a0, t1 # a0 = t1

    ret

itoa:
    add t0, a4, a3
    li t1, 10

    li a6, 3
    itoa_for:
        li t3, -1
        ble a6, t3, itoa_cont # if a6 <= -1 then go to cont

        rem t4, a0, t1 # t4 = a0 % t1
        addi t4, t4, '0' # int to char 
        add t5, t0, a6 # t5 = t0 + a6
        sb t4, 0(t5) # armazena o digito
        div a0, a0, t1 # a0 /= t1

        addi a6, a6, -1 # decrementa loop
        j itoa_for
    itoa_cont:
    li t2, ' ' # adiciona espaço
    sb t2, 4(t0)

    ret

main:
    # Código aqui
    jal read # leitura

    li a3, 0
    for:
        li t1, 20
        bge a3, t1, cont # if a3 >= 20 then cont

        jal atoi # array to int
        jal sqrt # raiz quadrada babilonica
        jal itoa # int to array

        addi a3, a3, 5 # a3 += 5
        j for # volta o loop
    cont:
    li t2, '\n'
    sb t2, 19(a4) # resultado termina com \n
    jal write # escreve

    ret

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # in buffer
    la a4, result # out buffer
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 20           # size - Writes 20 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address: .skip 0x20  # buffer

result: .skip 0x20