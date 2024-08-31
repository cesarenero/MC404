.globl read
.globl write
.globl recursive_tree_search
.globl puts    
.globl gets       
.globl atoi
.globl itoa
.globl exit  

read:
    li a0, 0                    # file descriptor = 0 (stdin)
    li a2, 1
    li a7, 63                   # syscall read (63)
    ecall
    ret

write:
    li a0, 1                    # file descriptor = 1 (stdout)
    li a7, 64                   # syscall write (64)
    ecall
    ret

recursive_tree_search:
    # Prologus
    addi sp, sp, -8   # Ajusta o ponteiro da pilha para armazenar os registradores salvos
    sw ra, 4(sp)      # Salva o registrador de retorno
    sw a0, 0(sp)       
    
    # mv s1, a0          # s1 = root (ponteiro para o nó atual)
    # mv s2, a1          # s2 = val (valor a ser buscado)
    
    # NULL node
    beqz a0, return_zero
    
    # Load root->val
    lw t0, 0(a0)  
    
    beq t0, a1, return_one
    
    lw a0, 4(a0) 
    # mv a1, s2          # ajusta a1 para a chamada recursiva
    jal recursive_tree_search

    beqz a0, check_right # Se não encontrado, verifica a subárvore direita
    
    addi a0, a0, 1
    j remate
    
    check_right:
        lw a0, 0(sp)
        lw a0, 8(a0)
        # mv a1, s2          # ajusta a1 para a chamada recursiva
        jal recursive_tree_search
        beqz a0, return_zero # Se não encontrado, retorna 0
        
        addi a0, a0, 1
        j remate
        
    return_one:
        li a0, 1
        j remate
        
    return_zero:
        li a0, 0
        j remate
    remate:
        lw ra, 4(sp)
        addi sp, sp, 8
        ret

puts:
    addi sp, sp, -4     
    sw ra, 0(sp)

    mv t5, a0      
    li t1, 0
    lb t2, 0(t5)
    li t3, '\n'

    puts_loop:
        beqz t2, puts_end 
        addi t5, t5, 1
        addi t1, t1, 1
        lb t2, 0(t5)

        j puts_loop
    puts_end:
    sb t3, 0(t5)
    mv a1, a0
    addi a2, t1, 1
    jal write 

    lw ra, 0(sp)       
    addi sp, sp, 4
    ret

gets:
    addi sp, sp, -4     
    sw ra, 0(sp)

    mv t0, a0  
    mv t4, a0
    li t3, '\n'

    gets_loop:
        mv a1, t0
        jal read          
        lbu t2, 0(t0)      
        beq t2, t3, gets_end
        addi t0, t0, 1
        j gets_loop
    gets_end:

    sb zero, 0(t0)
    mv a0, t4

    lw ra, 0(sp)       
    addi sp, sp, 4
    ret

atoi:

    li a3, 0
    li t5, '-'

    lbu t0, 0(a0)
    li t1, 1
    bne t0, t5, loop_atoi
    li t1, -1
    addi a0, a0, 1

    loop_atoi:
        lbu t0, 0(a0)
        beqz t0, fim_loop_atoi
        li t2, 10
        mul a3, a3, t2
        addi t0, t0, -'0'
        add a3, a3, t0
        addi a0, a0, 1
        j loop_atoi
    fim_loop_atoi:
    mul a0, a3, t1
    
    ret

itoa:
    la a3, result
    li t1, 10
    li t6, '\n'
    
    li t0, 10
    bgt t0, a0, 1f
    li t0, 100
    bgt t0, a0, 2f
    li t0, 1000
    bgt t0, a0, 3f
    li t0, 10000
    bgt t0, a0, 4f

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
    4:
        li t2, 3
        sb t6, 4(a3)
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
    mv a0, a3
    ret

exit:
    li a7, 93
    ecall

.bss
    result: .skip 100