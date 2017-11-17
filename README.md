# 汇编程序设计 - X86Assembler

## 描述
该项目基于汇编语言实现了一个简单的X86汇编器。它的输入为一个文件，内部包含一份精简后的X86汇编代码；最终将每条指令翻译成标准的机器代码，打印在屏幕上。

## 使用
该项目使用`masm32`进行汇编，需要使用`Irvine32.lib`库。

程序需要在命令行下运行，需要一个命令行参数，为需要被汇编的文件名。如：`X86Assembler.exe  test.asm`。

## 功能

### 指令
该项目实现了21个最常用的汇编指令，包括
`ADD`、`AND`、`CALL` 、`CMP`、`DEC`、`INC`、`JMP`、`LEA`、`MOV`、`NEG`、`OR` `POP`、`PUSH`、`RET`、`SAL`、`SAR`、`SHL`、`SHR`、`SUB` 、`XCHG`、`XOR` 

### 操作数
该项目支持了12最常用的操作数类型，包括
`rel8/16/32`、 `r8/16/32`、`imm8/16/32`、`m8/16/32`。

### 文件格式
输入文件除了需要符合标准的X86汇编格式之外，还需要
* 文件中需出现且只能出现一个`data`段和一个`code`段，且`data`段需要位于`code`段之前。
* 两个操作数之间以空格分隔，不使用逗号（,）分隔

在项目的同级目录下有一个test.input文件，该文件可被本汇编器正确地汇编，可作为进一步使用或验收本项目的凭据。

### 其他
本项目专注于对汇编指令的精准翻译，因此没有实现对全部X86指令的支持、同时也不支持绝大部分的伪指令。

## 参考
以下链接提供了关于本项目的关键信息：
* [Intel® 64 and IA-32 Architectures Software Developer’s Manual](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)：完整的指令集参考。重点参照
    * 35-41页：指令编码格式，包括`opcode`、`ModR/M`、`SIB`、`displacement`和`immediate`的介绍与编码方法。
    * 104-110页：对指令集表格的解读方法。
    * 120-1356页：完整的X86指令集表格。
* [x86/x64 指令编码内幕](http://www.mouseos.com/x64/index.html)：一份简单的中文X86编码教程。

## 作者
[Bill Jia](https://github.com/MrJia1997)：负责顶层架构设计、间接寻址的子parser的实现。
[Arsenal591](https://github.com/Arsenal591)：负责细节部分、整体parser的实现。
