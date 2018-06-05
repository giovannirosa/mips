# Arquitetura Trabalho 1

Trabalho 1 da matéria de Arquitetura do primeiro semestre de 2018, Universidade Federal do Paraná - UFPR.

## Início

Existe um makefile neste diretório com os seguintes comandos disponíveis:

* make sim: compila os arquivos basic_types.vhd, reg.vhd, add32.vhd, mux2.vhd, mux3.vhd, mux4.vhd, rom32.vhd, reg32_ce.vhd, reg_bank.vhd, control_pipeline.vhd, shift_left.vhd, alu.vhd, alu_ctl.vhd, mem32.vhd, hazard_unit.vhd, forward_unit.vhd, mips_pipeline.vhd, mips_tb.vhd e produz o arquivo de simulação mips.vcd
* make clean: limpa os arquivos .o e .cf

### Pré-requisitos

É necessario ter os programas ghdl e gtkwave devidamente instalados e configurados.

## Modificações

### Formato das instruções 

* R:                opcode[6 bits] rs[5 bits] rt[5 bits] rd[5 bits] shamt[5 bits] funct[6 bits]
* LW/SW/ADDI/BEQ:   opcode[6 bits] rs[5 bits] rt[5 bits] immediate[16 bits]
* LWDI:             opcode[6 bits] rs[5 bits] rt[5 bits] unused[16 bits]

### Arquivos alterados

* basic_types.vhd: Foram inseridas as constantes ADDI e LWDI.
* rom32.vhd: Foi modificado para testes.
* reg_bank.vhd: Foi modificado para ser possível a leitura de um dado que acabou de ser escrito, invertendo o clock.
* control_pipeline.vhd: Foram inseridos os sinais "ReadBack" [para controlar a instrução LWDI] e "SelExt" [para decidir se usa o extend na ULA]. Foram adicionados os casos de saída para ADDI e LWDI.
* mips_pipeline.vhd: Foi modificado para suportar Hazard, Forward, Branch, ADDI e LWDI.
    - Estágio IF: MUX para decidir entre PC+4 ou branch e um processo para aplicar o stall.
    - Estágio ID: unidade de hazard, processo para aplicar o stall, lógica para definir o RegWrite, processo para definir o registrador de destino final, processo para definir forward para branch, MUX para as entradas da ULA, cálculo do endereço do branch, lógica para PCSrc vir do branch.
    - Estágio EX: processo para aplicar stall no caso do LWDI, unidade de adiantamento, MUX para adiantamentos, MUX para usar o extend, MUX para somar 0 no caso do LWDI.
    - Estágio MEM: processo para definir o seletor para usar como endereço a saída da ULA ou a saída da Memória, MUX para definir o endereço da Memória, lógica para definir o MemRead.
    - Estágio WB: processo para propagar o sinal ReadBack e o registrador de destino por mais um ciclo para usar no caso do LWDI.
    - Sinais UP para utilizar no caso do LWDI, propagando-os por mais um ciclo, evitando assim penalizar as outras instruções.

### Arquivos criados

* hazard_unit.vhd
* forward_unit.vhd

## Testando

É possível testar o programa alterando o arquivo rom32.vhd para modificar as instruções que serão processadas.

### Como testar

Verifique o arquivo basic_types.vhd para encontrar os op codes corretos. Então modifique o arquivo rom32.vhd e execute o seguinte comando:

```
make sim
```

Isso irá gerar ou sobrescrever o arquivo mips.vcd.

### Como visualizar a simulação gerada

Para facilitar a correção é recomendado a utilização do gtkwave:
```
gtkwave mips.vcd
```
**Também está incluso nesse diretório o executável mips.gtkw que já contém a janela de sinais montada no gtkwave.**

## Bibliotecas Utilizadas

* [ghdl](http://ghdl.free.fr) - GHDL is an open-source simulator for the VHDL language
* [gtkwave](http://gtkwave.sourceforge.net) - GTKWave is open source vhdl visualization software

## Autores

* **Giovanni Rosa** - [giovannirosa](https://github.com/giovannirosa)
* **Roberta Samistraro** - [rosamis](https://github.com/rosamis)

## Licença

Código aberto, qualquer um pode usar para qualquer propósito.

## Reconhecimentos

* GHDL não é produtivo nem intuitivo.
* GTKWave funciona bem mas não é intuitivo também.

## Desenvolvimento

* Tempo estimado: 40 horas.
* Ponto positivo: Entender o funcionamento de um microprocessador em baixo nível.
* Pontos negativos: Implementar a lógica em VHDL, testar usando gtkwave e lidar com processamento em baixo nível. Também não conseguimos instalar o ghdl em nossas máquinas pessoais, tendo que utilizar ssh para compilação correta.
* Sugestões: Dar uma aula prática e objetiva sobre a linguagem VHDL e disponibilizar mais aulas de laboratório para o desenvolvimento do projeto.

## Testes

### Casos de sucesso testados
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0002"; -- addi $1, $0, 2
when 	"000001" => data_out <= "001000" & "00000" & "00010" & x"0001"; -- addi $2, $0, 1
when 	"000010" => data_out <= "000000" & "00001" & "00010" & "00110" & "00000" & "100000"; -- add $6, $1, $2
```
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0002"; -- addi $1, $0, 2
when 	"000001" => data_out <= "101011" & "00001" & "00001" & x"0000"; -- sw $1, 0($1)
```
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0002"; -- addi $1, $0, 2
when 	"000001" => data_out <= "001000" & "00000" & "00010" & x"0001"; -- addi $2, $0, 1
when 	"000010" => data_out <= "101011" & "00010" & "00010" & x"0000"; -- sw $2, 0($2)
when 	"000011" => data_out <= "101011" & "00001" & "00001" & x"0000"; -- sw $1, 0($1)
```
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0002"; -- addi $1, $0, 2
when 	"000001" => data_out <= "101011" & "00001" & "00001" & x"0000"; -- sw $1, 0($1)
when 	"000010" => data_out <= "010011" & "00001" & "00100" & x"0000"; -- lwdi $4, $1
```
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0001"; -- addi $1, $0, 1
when 	"000001" => data_out <= "001000" & "00000" & "00010" & x"0002"; -- addi $2, $0, 2
when 	"000010" => data_out <= "101011" & "00010" & "00010" & x"0000"; -- sw $2, 0($2)
when 	"000011" => data_out <= "101011" & "00001" & "00001" & x"0000"; -- sw $1, 0($1)
when 	"000100" => data_out <= "010011" & "00001" & "00100" & x"0000"; -- lwdi $4, $1
when 	"000101" => data_out <= "000000" & "00000" & "00000" & "00000" & "00000" & "100000"; -- nop
when 	"000110" => data_out <= "010011" & "00010" & "00101" & x"0000"; -- lwdi $5, $2
```

### Casos de fracasso testados [BUGS]

Não é possível processar duas instruções LWDI seguidas, deve haver ao menos 1 instrução entre as duas, senão o programa entra em loop.
```
when 	"000000" => data_out <= "001000" & "00000" & "00001" & x"0001"; -- addi $1, $0, 1
when 	"000001" => data_out <= "001000" & "00000" & "00010" & x"0002"; -- addi $2, $0, 2
when 	"000010" => data_out <= "101011" & "00010" & "00010" & x"0000"; -- sw $2, 0($2)
when 	"000011" => data_out <= "101011" & "00001" & "00001" & x"0000"; -- sw $1, 0($1)
when 	"000100" => data_out <= "010011" & "00001" & "00100" & x"0000"; -- lwdi $4, $1
when 	"000101" => data_out <= "010011" & "00010" & "00101" & x"0000"; -- lwdi $5, $2
```