.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

atoi:
    li a0, 0
    li t6, '\n'
    li t5, '-'

    lbu t0, 0(a1)
    li t1, 1
    bne t0, t5, loop_atoi
    li t1, -1
    addi a1, a1, 1

    loop_atoi:
        lbu t0, 0(a1)
        beq t0, t6, fim_loop_atoi
        li t2, 10
        mul a0, a0, t2
        addi t0, t0, -'0'
        add a0, a0, t0
        addi a1, a1, 1
        j loop_atoi
    fim_loop_atoi:
    mul a0, a0, t1
    ret


acha_indice:
    li t0, 0

    loop:
        lw t1, 0(a1)
        lw t2, 4(a1)
        add t1, t1, t2
        lw t2, 8(a1)
        add t1, t1, t2

        beq t1, a0, deu_bom

        addi t0, t0, 1
        lw a1, 12(a1)
        beqz a1, nao_deu_bom

        j loop

    deu_bom:
        mv a0, t0
        j itoa

    nao_deu_bom:
        li t0, '1'
        la a3, result
        sb t5, 0(a3) # -
        sb t0, 1(a3) # 1
        sb t6, 2(a3) # \n
        ret


itoa:
    la a3, result
    li t1, 10
    
    li t0, 10
    bgt t0, a0, 1f
    li t0, 100
    bgt t0, a0, 2f
    li t0, 1000
    bgt t0, a0, 3f

    1:
        li t2, 0
        sb t6, 1(a3)
        j itoa_for
    2:
        li t2, 1
        sb t6, 2(a3)
        j itoa_for
    3:
        li t2, 2
        sb t6, 3(a3)
        j itoa_for

    itoa_for:

        rem t4, a0, t1 # t4 = a0 % t1
        addi t4, t4, '0' # int to char 
        add t5, a3, t2 # t5 = a3 + t2
        sb t4, 0(t5) # armazena o digito
        div a0, a0, t1 # a0 /= t1

        beqz t2, itoa_end
        addi t2, t2, -1 # decrementa loop
        j itoa_for
    itoa_end:

    ret


main:
    jal read
    jal atoi
    la a1, head_node
    jal acha_indice
    jal write
    ret

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 7            # size - Reads 7 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 5            # size - Writes 5 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address: .skip 7  # buffer

result: .skip 5