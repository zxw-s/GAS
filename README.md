# GAS汇编语言入门（Linux，x86‑64）

汇编语言是**机器码的助记符**，和CPU架构强绑定，最常见：x86（32位）、x86‑64（64位）、ARM。

> 汇编没有统一标准，Windows用MASM，Linux用NASM/GAS。下面以 **Linux x86‑64 AT&T汇编** 入门，通俗易懂。

## AT&T最基础指令

### mov 数据传送

```asm
mov $10, %rax # 立即数10送入rax，$代表立即数，%代表寄存器
mov %rax, %rbx # rax → rbx
```

### 算术运算 add sub inc dec

```asm
add $5, %rax # rax = rax +5
sub $3, %rax # rax = rax -3
inc %rax # rax++
dec %rax # rax--
```

### 比较 cmp + 跳转

 cmp a,b  做  b‑a  比较，只改标志寄存器，不改变原数据。

```asm
cmp $10, %rax
je label1 # equal 相等跳转到label1
jg label2 # greater 大于跳转
jl label3 # less 小于跳转
jmp label4 # 无条件跳转
```

### 栈操作 push pop

栈：后进先出， rsp 指向栈顶。push会自动减小rsp，pop自动增大rsp。

```asm
push %rax # 把rax压入栈
pop %rbx # 栈顶弹出到rbx
```

### 调用函数 call ret

```asm
call myfunc # 调用函数，把返回地址压栈，跳转到myfunc
ret # 弹出返回地址，回到call下一条指令
```

### 完整最小示例：Linux64汇编 程序退出（AT&T 语法）

文件： mini.s

```asm
.section .text
.global _start # 链接器入口标记

_start:
    mov $60, %rax # linux系统调用号60 = exit退出程序
    mov $0, %rdi # exit返回码0，代表正常结束
    syscall # 触发系统调用，交给内核执行

```

#### 编译运行（Linux）

**写 AT&T 汇编 → 优先用 `as`（GAS）**，完整原生支持，没有各种伪指令兼容坑

```bash
# nasm汇编，生成目标文件
as mini.s -o mini.o
# ld链接生成可执行程序
ld mini.o -o mini
# 运行
./mini
# 查看退出码
echo $?
```

> `syscall`  是64位Linux触发系统调用的指令，rax存系统调用编号，rdi rsi rdx依次传参数。

## 带字符串输出例子（调用write系统调用）

 hello.s 

```nasm
.section .data
msg: .asciz "Hello gas!\n"
len = . - msg   # GAS 计算长度，等价于 equ

.section .text
.global _start
_start:
    mov $1, %rax # write系统调用号1
    mov $1, %rdi # 文件描述符1=标准输出屏幕
    leaq msg(%rip), %rsi    # 字符串内存地址，rip相对取地址 ✅
    mov $len, %rdx # 字符串长度
    syscall

    mov $60, %rax
    mov $0, %rdi
    syscall

```

编译同上，运行打印  `Hello Assembly! `

## 关键概念：内存寻址

```nasm
mov (%rbx), %rax # 把rbx存的地址对应的内存数据读入rax
mov $0x10, (%rbx) # 将立即数0x10写入rbx指向的内存
```

括号 () 代表访问内存。

## 简单分支示例：if逻辑

```nasm
_start:
    mov $5, %rax
    cmp $5, %rax
    je equal_case # 如果rax==5就跳走

    # 不相等执行这里
    mov $1, %rdi
    jmp exit_prog

equal_case:
    mov $0, %rdi

exit_prog:
    mov $60, %rax
    syscall
```

## 栈与函数示例

```nasm
.section .text
.global _start

add_two:
    push %rbp # 保存旧栈基址，栈帧开始
    mov %rsp, %rbp

    mov %rdi, %rax
    add %rsi, %rax ; rax = rdi + rsi

    pop %rbp
    ret

_start:
    mov $3, %rdi
    mov $4, %rsi
    call add_two # 调用函数，rax得到7
    mov $60, %rax
    syscall

```

> x86‑64 System V ABI：函数前6个参数依次放  `rdi,rsi,rdx,rcx,r8,r9` ，返回值在 `rax` 。

## 重要区分

1. **AT&T(GAS/NASM)**：Linux默认，源在前目的在后，寄存器带%，立即数带$

2. **Intel语法**：Windows MASM，目的在前源在后，没有$%符号。

```nasm
# Intel语法
mov rax, 10
```

# README.md · GNU AS (gas) x86_64 Linux 汇编项目

> gas = GNU Assembler，AT&T 语法，搭配 ld，Linux 平台

# GNU AS (gas) 汇编项目

GNU Assembler (gas) AT&T syntax assembly demo for Linux x86_64.

## 项目目录结构

```plaintext
gas-demo/
├── src/
│ └── main.s
├── build/ # auto-generated artifacts
├── Makefile
├── README.md
└── .gitignore
```

## 编译环境

安装 binutils（包括 gas 和 ld）:

```bash
sudo apt install binutils make
```

## ⚙️ 编译与运行

### 一键编译

```bash
make
./build/main
make clean
```

### 手动编译命令

```bash
# assemble: .s -> .o
as src/main.s -o build/main.o
# link: .o -> executable
ld build/main.o -o build/main
```

### 调试

增加调试信息 `-g`:

```bash
as -g src/main.s -o build/main.o
gdb ./build/main
```

## License

MIT

# Makefile（gas 专用，GNU，x86_64 AT&T）

```makefile
SRC_DIR := src
BUILD_DIR := build
ASM_SRC := $(SRC_DIR)/main.s
OBJ := $(BUILD_DIR)/main.o
BIN := $(BUILD_DIR)/main

.PHONY: all clean

all: $(BIN)

$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

$(OBJ): $(ASM_SRC) | $(BUILD_DIR)
    as -g $< -o $@

$(BIN): $(OBJ)
    ld $(OBJ) -o $(BIN)

clean:
    rm -rf $(BUILD_DIR)
```


