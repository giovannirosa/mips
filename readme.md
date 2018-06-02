# Arquitetura Trabalho 1

Trabalho 1 da matéria de Arquitetura do primeiro semestre de 2018, Universidade Federal do Paraná - UFPR.

## Início

Existe um makefile neste diretório com os seguintes comandos disponíveis:

* make sim: compila os arquivos teste.c, recomenda.c, grafo.c, lista.c e produz o arquivo de simulação mips.vcd
* make clean: limpa os arquivos .o e .cf

### Pré-requisitos

É necessario ter o ghdl e o programa gtkwave.

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

## Autor

* **Giovanni Rosa** - [giovannirosa](https://github.com/giovannirosa)
* **Roberta Samistraro** - [rosamis](https://github.com/rosamis)

## Licença

Código aberto, qualquer um pode usar para qualquer propósito.

## Reconhecimentos

* GHDL não é produtivo nem intuitivo
* GTKWave funciona bem mas não é intuitivo também

## Bugs

Nenhum bug reconhecido nos testes, porém existem muitos casos que não foram testados.