# 完整最小示例：Linux64汇编 程序退出
# AT&T 语法（GAS / GNU as 默认）
# nasm汇编，生成目标文件：as miniLinux64.s -o miniLinux64.o
# ld链接生成可执行程序：ld miniLinux64.o -o miniLinux64
# 运行：./miniLinux64
# 查看退出码：echo $?

.section .text
.global _start # 链接器入口标记

_start:
    mov $60, %rax     # linux系统调用号60 = exit退出程序
    mov $0, %rdi       # exit返回码0，代表正常结束
    syscall                 # 触发系统调用，交给内核执行
