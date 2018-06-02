# Arquitetura Trabalho 1

Trabalho 1 da matéria de Arquitetura do primeiro semestre de 2018, Universidade Federal do Paraná - UFPR.

## Início

Existe um makefile neste diretório com os seguintes comandos disponíveis:

* make sim: compila os arquivos basic_types.vhd, reg.vhd, add32.vhd, mux2.vhd, mux3.vhd, mux4.vhd, rom32.vhd, reg32_ce.vhd, reg_bank.vhd, control_pipeline.vhd, shift_left.vhd, alu.vhd, alu_ctl.vhd, mem32.vhd, hazard_unit.vhd, forward_unit.vhd, mips_pipeline.vhd, mips_tb.vhd e produz o arquivo de simulação mips.vcd
* make clean: limpa os arquivos .o e .cf

### Pré-requisitos

É necessario ter o ghdl e o programa gtkwave.

## Modificações

### Formato das instruções 

* R: opcode[6 bits] rs[5 bits] rt[5 bits] rd[5 bits] shamt[5 bits] funct[6 bits]
* LW/SW/ADDI/BEQ: opcode[6 bits] rs[5 bits] rt[5 bits] immediate[16 bits]
* LWDI: opcode[6 bits] rs[5 bits] rt[5 bits] unused[16 bits]

### Arquivos alterados

* basic_types.vhd: Foram inseridas as constantes ADDI e LWDI.
* rom32.vhd: Foi modificado para testes.
* control_pipeline.vhd: Foram inseridos os sinais "ReadBack" [para controlar a instrução LWDI] e "SelExt" [para decidir se usa o extend na ULA]. Foram adicionados os casos de saída para ADDI e LWDI.
* mips_pipeline.vhd: Foi modificado para suportar Hazard, Forward, Branch, ADDI e LWDI. Foram inseridos MUX no estágio IF para decidir entre PC+4 ou branch ou stall, no estágio ID para aplicar o stall

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

## Bibliotecas Utilizadas

* [ghdl](http://ghdl.free.fr) - GHDL is an open-source simulator for the VHDL language
* [gtkwave](http://gtkwave.sourceforge.net) - GTKWave is open source vhdl visualization software

## Autores

* **Giovanni Rosa** - [giovannirosa](https://github.com/giovannirosa)
* **Roberta Samistraro** - [rosamis](https://github.com/rosamis)

## Licença

Código aberto, qualquer um pode usar para qualquer propósito.

## Reconhecimentos

* GHDL não é produtivo nem intuitivo
* GTKWave funciona bem mas não é intuitivo também

## Desenvolvimento

* Tempo estimado: 40 horas
* Ponto positivo: Entender o funcionamento de um microprocessador em baixo nível.
* Pontos negativos: Implementar a lógica em VHDL, testar usando gtkwave e lidar com processamento em baixo nível.
* Sugestões: Dar uma aula prática e objetiva sobre a linguagem VHDL e disponibilizar mais aulas de laboratório para o desenvolvimento do projeto. 

## Bugs

Nenhum bug reconhecido nos testes, porém existem muitos casos que não foram testados.