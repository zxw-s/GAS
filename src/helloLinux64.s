# 带字符串输出例子（调用write系统调用）
# 64 位 Linux，AT&T 语法，只能用as（GAS）编译，不能直接交给 NASM。
# 汇编，生成目标文件：as helloLinux64.s -o helloLinux64.o
# ld链接生成可执行程序：ld helloLinux64.o -o helloLinux64
# 运行：./helloLinux64
# 查看退出码：echo $?

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
