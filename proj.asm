TITLE PGM4_1: soma subtracao multiplicacao divisao
.MODEL SMALL
.STACK 100H
.DATA
menu db "Seja Bemvindo! Escolha das operacoes abaixo:",13,10
     db "0. Sair;",13,10
	 db "1. AND;",13,10
     db "2. OR;",13,10
     db "3. XOR;",13,10
	 db "4. NOT;",13,10
     db "5. Soma;",13,10
     db "6. Subtracao;",13,10
	 db "7. Multiplicacao;",13,10
     db "8. Divisao;",13,10
     db "9. Multiplicacao (varias vezes por 2)",13,10
     db "10. Divisao (varias vezes por 2)",13,10,'$'
MSG 	DB		'Digite um numero: $'
MSG1 	DB		'Digite outro numero: $'
MSG2	DB		'O resultado da operacao foi: $'
MSG3	DB		'Aperte qualquer tecla para continuar... $'
MSG4	DB		'Escolha o numero de vezes: $'


.CODE
MAIN PROC
;
	MOV AX,@DATA   		;Inicializa segmento de data
	MOV DS,AX
;	
START:
	call clear_screen     
	call display_menu

;
	MOV AH,1 
	INT 21H 			;leitura da escolha
	MOV BL,AL
;
	CMP BL,'0'
	JE FIM
	CMP BL,'1'
	JE FUNC_AND
	CMP BL,'2'
	JE FUNC_OR
	CMP BL,'3'
	JE FUNC_XOR
	CMP BL,'4'
	JE FUNC_NOT
	CMP BL,'5'
	JE FUNC_SOMA
	CMP BL,'6'
	JE FUNC_SUB
	CMP BL,'7'
	JE FUNC_MUL
	CMP BL,'8'
	JE FUNC_DIV
	CMP BL,'9'
	JE FUNC_MUL2
	JNE START
;
FUNC_AND:
	call and_func
	call wait_key
	JMP START
;
FUNC_OR:
	call or_func
	call wait_key
	JMP START
;
FUNC_XOR:
	call xor_func
	call wait_key
	JMP START
;
FUNC_NOT:
	call not_func
	call wait_key
	JMP START
;
FUNC_SOMA:
	call sum_func
	call wait_key
	JMP START
;
FUNC_SUB:
	call sub_func
	call wait_key
	JMP START
;
FUNC_MUL:
	call mul_func
	call wait_key
	JMP START
;
FUNC_DIV:
	call div_func
	call wait_key
	JMP START
;
FUNC_MUL2:
	call mul2_func
	call wait_key
	JMP START
FIM:
	MOV AH,4CH 			;funcao para saida
	INT 21H
;
;--------------------------------------------
display_menu proc
  MOV  DX, offset menu
  MOV  AH, 9
  INT  21H
  RET
display_menu endp

clear_screen proc
  MOV  AH, 0
  MOV  AL, 3
  INT  10H
  RET
clear_screen endp

break_line proc
	MOV AH,2 
	MOV DL,0DH
	INT 21H       
	MOV DL,0AH 
	INT 21H
	RET
break_line endp

wait_key proc
	MOV AH, 7
	INT 21H
	RET
wait_key endp

decimal_input proc 
	PUSH BX
	PUSH CX
	PUSH DX ;salvando registradores que serão usados
	XOR BX,BX ;BX acumula o total, valor inicial 0
	XOR CX,CX ;CX indicador de sinal (negativo = 1), inicial = 0
	MOV AH,1h
	INT 21h ;le caracter no AL
	CMP AL, '-' ;sinal negativo?
	JE MENOS
	CMP AL,'+' ;sinal positivo?
	JE MAIS
	JMP NUM ;se nao é sinal, então vá processar o caracter
MENOS: 
	MOV CX,1 ;negativo = verdadeiro
MAIS: 
	INT 21h ;le um outro caracter
NUM: 
	AND AX,000Fh ;junta AH a AL, converte caracter para binário
	PUSH AX ;salva AX (valor binário) na pilha
	MOV AX,10 ;prepara constante 10
	MUL BX ;AX = 10 x total, total está em BX
	POP BX ;retira da pilha o valor salvo, vai para BX
	ADD BX,AX ;total = total x 10 + valor binário
	MOV AH,1h
	INT 21h ;le um caracter
	CMP AL,0Dh ;é o CR ?
	JNE NUM ;se não, vai processar outro dígito em NUM
	MOV AX,BX ;se é CR, então coloca o total calculado em AX
	CMP CX,1 ;o numero é negativo?
	JNE SAIDA ;não
	NEG AX ;sim, faz-se seu complemento de 2
SAIDA: 
	POP DX
	POP CX
	POP BX ;restaura os conteúdos originais
	RET ;retorna a rotina que chamou
decimal_input endp

decimal_output proc
	 PUSH AX
	 PUSH BX
	 PUSH CX
	 PUSH DX ;salva na pilha os registradores usados
	 OR AX,AX ;prepara comparação de sinal
	 JGE PT1 ;se AX maior ou igual a 0, vai para PT1
	 PUSH AX ;como AX menor que 0, salva o número na pilha
	 MOV DL,'-' ;prepara o caracter ' - ' para sair
	 MOV AH,2h ;prepara exibição
	 INT 21h ;exibe ' - '
	 POP AX ;recupera o número
	 NEG AX ;troca o sinal de AX (AX = - AX)
	;obtendo dígitos decimais e salvando-os temporariamente na pilha
	PT1: XOR CX,CX ;inicializa CX como contador de dígitos
	 MOV BX,10 ;BX possui o divisor
	PT2: XOR DX,DX ;inicializa o byte alto do dividendo em 0; restante é AX
	 DIV BX ;após a execução, AX = quociente; DX = resto
	 PUSH DX ;salva o primeiro dígito decimal na pilha (1o. resto)
	 INC CX ;contador = contador + 1
	 OR AX,AX ;quociente = 0 ? (teste de parada)
	 JNE PT2 ;não, continuamos a repetir o laço
	;exibindo os dígitos decimais (restos) no monitor, na ordem inversa
	 MOV AH,2h ;sim, termina o processo, prepara exibição dos restos
	PT3: POP DX ;recupera dígito da pilha colocando-o em DL (DH = 0)
	 ADD DL,30h ;converte valor binário do dígito para caracter ASCII
	 INT 21h ;exibe caracter
	 LOOP PT3 ;realiza o loop ate que CX = 0
	 POP DX ;restaura o conteúdo dos registros
	 POP CX
	 POP BX
	 POP AX ;restaura os conteúdos dos registradores
	 RET ;retorna à rotina que chamou
decimal_output endp

and_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input;leitura do primeiro numero
	PUSH AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input
;
	POP BX
	AND AX,BX
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output			
	RET
and_func endp

or_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input;leitura do primeiro numero
	PUSH AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input
;
	POP BX
	OR AX,BX
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output			
	RET
or_func endp

xor_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input;leitura do primeiro numero
	PUSH AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input
;
	POP BX
	XOR AX,BX
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output			
	RET
xor_func endp

not_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input	;leitura do primeiro numero
	NOT AX
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output			
	RET			
not_func endp

sum_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input;leitura do primeiro numero
	MOV BX,AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input			;leitura do segundo numero
;
	ADD AX,BX			;somando numeros digitados
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output			
	RET
sum_func endp

sub_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do primeiro numero
	MOV BX,AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do segundo numero
	MOV DX,AX
;

	SUB BX,DX			;somando numeros digitados
	MOV AX,BX
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output
	RET
sub_func endp

mul_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do primeiro numero
	MOV BX,AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do segundo numero
;

	MUL BX				;somando numeros digitados
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output
	RET
mul_func endp

div_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;	
	call break_line
;
	call decimal_input 			;leitura do primeiro numero
	PUSH AX
;
	call break_line
;
	LEA DX,MSG1           
	MOV AH,9			;Segunda mensagem 
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do segundo numero
	MOV BX,AX
	POP AX
	CWD
;
	DIV BX				;somando numeros digitados
	PUSH DX				;GUARDA DX
	PUSH AX				;GUARDA AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX			;TIRA AX
	POP DX			;TIRA DX
	CMP DX,0		;COMPARA RESTO COM 0
	JZ  PRINT		; SE FOR ZERO, PRINTA DIRETO, SE NÃO:
	call decimal_output; PRINTA O QUOCINETE
	PUSH DX				;ARMAZENA O RESTO
	MOV AH,2H	
	MOV DL, ','		
	INT 21H 			;PRINTA UMA VIRGULA
	POP DX				; TIRA O RESTO DA PILHA
	MOV CX,0			; CONTADOR PARA EVITAR DIZIMAS
REMAINDER_LOOP:
	MOV AX, 10			; ATRIBUI 10 AO AX
	MUL DX				; MULTIPLICA O DX POR 10
	DIV	BX				; DIVIDO DX PELO DIVISOR
	call decimal_output ; PRINTA CONTINUAÇÃ0 DO NÚMERO
	INC CX				
	CMP CX, 6			; SE O CONTADOR FOR 6, SAI FORA DO LOOP
	JE RETURN
	CMP DX ,0			; COMPARA O RESTO PARA VER SE ACABOU A CONTA
	JNZ REMAINDER_LOOP  ; SE NÃO, VOLTA PRO LOOP
	JMP RETURN
;
PRINT:
	call decimal_output
RETURN:
	RET
div_func endp

mul2_func proc
	call break_line
	LEA DX,MSG            
	MOV AH,9			;Digite um numero
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do primeiro numero
	PUSH AX
;
	call break_line
;
	LEA DX,MSG4           
	MOV AH,9			;escolha o numero de vezes 
	INT 21H
;
	call break_line
;
	call decimal_input 			;leitura do segundo numero
	MOV CX,AX
	CMP CX,0
	JE ZERO_TIMES
	POP AX
	MOV BX,2
;
KEEP_MULTING:
	MUL BX				;somando numeros digitados
	DEC CX
	JNZ KEEP_MULTING
	PUSH AX
;
	call break_line
;
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
;
	POP AX
	call decimal_output
	JMP RETURN1
;
ZERO_TIMES:
	LEA DX,MSG2            
	MOV AH,9			;Terceira mensagem 
	INT 21H
	
	POP AX
	call decimal_output
	JMP RETURN1

RETURN1:
	RET
mul2_func endp

;-------------------------------------------
MAIN ENDP
END MAIN