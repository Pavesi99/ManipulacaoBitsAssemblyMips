
.data
  aula: .word  0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF
  msga: .asciiz "Entre com o número da aula (de 0 a 15):"
  msgb: .asciiz "Entre com o número do aluno (de 0 a 31):"
  msgc: .asciiz "Entre com o tipo do registro (presença = 1; ausência = 0):"
  msge: .asciiz "Valor invalido!\n"
  
  #  variaveis syscall
  printi: .word   1   # print_int
  printf: .word   2   # print_float
  prints: .word   4   # print_string
  readi:  .word   5   # read_int 
  readf:  .word   6   # read_float
  sbrk:   .word   9
  exit:   .word   10
.text

main:
  # inicializando e descrevendo os registradores
  li $t0, 0      # armazena o o valor para interagir com o loop principal 'while'
  li $s0, 0      # armazena o valor do numero da aula
  li $s1, 0      # armazena o valor do numero do aluno
  li $s2, 0      # armazena o valor do tipo de registro (presenca ou falta)
  li $s3, 0      #armazena temporariamente a aula
  li $s6, 16     #tamanho do vetor
  li $t6,0xFFFFFFFF # valor temporario para comparacao 
  
  # aloca dinamicamente o vetor_A
  mul $t1, $s6, 4     # coloca o tamanho * 4 no $t1
  add $a0, $zero, $t1 # coloca o resultado de mul em $a0
  lw $v0, sbrk        # aloca tamanho * 4 bytes na memoria
  syscall
  sw $v0, aula      # coloca o valor retornado por sbrk em aula
  
  addi $t0, $0, 0 	#i=o
  lw $s7, aula
  jal inicializa_array
  
  j while
  saida_while:
  b end
  
while:
  blt $t0, -1, saida_while #Desvia se i for igual -1

  ## SEQUENCIA DE COMANDOS PARA SELECIONAR O NUMERO DA AULA
  la $a0, msga 		#Coloca A mensagem em a0
  lw $v0, prints 	#v0 recebe o comando de imprimir string
  syscall		#executa o comando de v0
  
  lw $v0, readi	#v0 recebe comando de ler int
  syscall
  add $s0, $0, $v0 	#colocando em s0 o numero da aula
  
  
  ## VERIFICA SE $s0 É UM VALOR VALIDO
  bltz $s0, valor_invalido_while	 	
  bgt $s0, 15, valor_invalido_while
  
  ## SEQUENCIA DE COMANDOS PARA SELECIONAR O NUMERO DO ALUNO
  la $a0, msgb 		
  lw $v0, prints	
  syscall		
  
  lw $v0, readi	
  syscall
  add $s1, $0, $v0  # Salva o numero do aluno em $s1
  
  ## VERIFICA SE $s1 É UM VALOR VALIDO
  bltz $s1, valor_invalido_while	 	
  bgt $s1, 31, valor_invalido_while
  
  ## SEQUENCIA DE COMANDOS PARA SELECIONAR O TIPO DE REGISTRO
  la $a0, msgc	
  lw $v0, prints	
  syscall		
  
  lw $v0, readi	
  syscall
  add $s2, $0, $v0 # armazena o valor que representa falta ou presenca em $s2
  
 ## VERIFICA SE $s0 É UM VALOR VALIDO
  bltz $s2, valor_invalido_while	 	
  bgt $s2, 1, valor_invalido_while
  
  ## REGISTRAR FALTA/PRESENÇA
  jal altera_registro
  
  j while	#Retorna para o inicio do laço 
  
valor_invalido_while:
  ###  IMPRIMIR MENSAGEM DE ERRO
  la $a0, msge 	
  lw $v0, prints 	
  syscall
  b end
 
## REGISTRAR FALTA/PRESENÇA 
altera_registro:
  lw $s3, aula
  la $t9, ($zero)     # coloca iterator para 0
  altera_registro_for:
  bge $t9, $s0, end_altera_registro_for # enquanto o contador nao for igual a aula continua
  addi $t9, $t9, 1 #incrementa o interator
  addi $s3, $s3, 4 #pega a proxima aula
  j altera_registro_for
  end_altera_registro_for:
  li $v0,1 # coloca o valor em 1
  sllv $v0, $v0, $s1 # move o bit conforme o aluno selecionado  
  lw $t5, ($s3) # salva o valor dessa posicao do array em t5 
  sllv $s2, $s2, $s1 # move o bit conforme o aluno selecionado
  and $t6, $t5,$v0 # compara se o valor que o usuario quer inserir é diferente do atual
  beq $s2,$t6, end_altera_registro # se for igual volta pro inicio do while
  xor  $v0, $v0, $t5 # altera o valor 
  sw  $v0, ($s3) # salva no array o novo valor
end_altera_registro:
  jr $ra
  
inicializa_array:
    la $t9, ($zero)     # coloca iterator para 0
    inicializa_array_for: 
    bge $t9, $s6, end_inicializa_array
    
    sw $t6, ($s7)       # coloca 0 no atual index
    
    add $s7, $s7, 4     # pega o endereco do proximo elemento
    add $t9, $t9, 1     # incrementa o  iterator
    b inicializa_array_for
end_inicializa_array:
    jr $ra
   
 end:
    lw $v0, exit
    syscall
