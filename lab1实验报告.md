<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：Lab0.5 & Lab1    实验地点：实验楼A316</h3>

<h4 align = "center">组号：      小组成员：刘俊彤，孙启森，刘玉菡</h4>

## 操作系统lab0.5

### 实验过程：

1、打开终端，输入make debug 编译生成了obj文件夹，同时开启另一个终端输入make gdb进行调试。

2、gbd指令x/10i $pc 显示最开始要执行的10条汇编语句如下：

```
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp
```

可以看到程序执行的第一条指令位于0x1000，这是CPU在上电或者复位时，PC被赋的初始值。QEMU的复位地址就是0x1000。这里即是复位过程，将计算机各个组件（包括处理器、内存、设备等）至于初始装态，并启动Bootloader。

这段汇编代码对寄存器t0进行一系列操作后，使用jr t0跳转到t0指示的地址。

3、使用si单步执行到jr t0

```
(gdb) si
0x0000000000001004 in ?? ()
(gdb) si
0x0000000000001008 in ?? ()
(gdb) si
0x000000000000100c in ?? ()
(gdb) si
0x0000000000001010 in ?? ()
(gdb) si
0x0000000080000000 in ?? ()
```

可以看到jr t0指令执行后pc变为了0x80000000

4、 x/10i $pc查看当前的10条指令

```
(gdb) x/10i $pc
=> 0x80000000:  csrr    a6,mhartid  # a6 = mhartid (获取当前硬件线程的ID)
   0x80000004:  bgtz    a6,0x80000108 # 如果 a6 > 0，则跳转到0x80000108
   0x80000008:  auipc   t0,0x0 # t0 = pc + (0x0 << 12) = 0x80000008
   0x8000000c:  addi    t0,t0,1032 # t0 = t0 + 1032 = 0x80000408
   0x80000010:  auipc   t1,0x0 # t1 = pc + (0x0 << 12) = 0x80000010
   0x80000014:  addi    t1,t1,-16 # t1 = t1 - 16 = 0x80000000
   0x80000018:  sd      t1,0(t0) # 将t1的值（0x80000000）存储在地址0x80000408处
   0x8000001c:  auipc   t0,0x0 # t0 = pc + (0x0 << 12) = 0x8000001c
   0x80000020:  addi    t0,t0,1020 # t0 = t0 + 1020 = 0x80000400
   0x80000024:  ld      t0,0(t0) # t0 = [t0 + 0] = [0x80000400] (从地址0x80000400加载一个双字到t0)

```

在最初OpenSBI.bin被加载到了0x80000000，在这里启动了Bootloader，也就是OpenSBI.bin。t他需要负责加载操作系统内核并启动操作系统执行。这段代码由OpenSBI获取计算机控制权后实现，负责加载启动代码地址、设置寄存器、获取处理器信息等。

5、 我们知道操作系统的内核镜像os.bin被预先加载到了0x80200000位置。使用break *0x80200000在内个镜像位置设置断点，执行到断点

```
(gdb) break *0x80200000
Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7.
(gdb) continue
Continuing.

Breakpoint 1, kern_entry () at kern/init/entry.S:7
7           la sp, bootstacktop
```

此时进行make debug的终端出现以下内容，说明OpenSBI已经启动

```
OpenSBI v0.4 (Jul  2 2019 11:53:53)
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name          : QEMU Virt Machine
Platform HART Features : RV64ACDFIMSU
Platform Max HARTs     : 8
Current Hart           : 0
Firmware Base          : 0x80000000
Firmware Size          : 112 KB
Runtime SBI Version    : 0.1

PMP0: 0x0000000080000000-0x000000008001ffff (A)
PMP1: 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
```

x/10i $pc查看当前十条指令

可以看到这里是kern_entry，也就是内核开始位置。kern_entry进行了内核栈分配工作，并将PC移动到kern_init，启动操作系统。

```
(gdb) x/10i $pc
=> 0x80200000 <kern_entry>:     auipc   sp,0x3  # sp = 当前指令地址的高 20 位加偏移量（0x3）
   0x80200004 <kern_entry+4>:   mv      sp,sp 
   0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init> # 跳转到kern_init
   0x8020000a <kern_init>:      auipc   a0,0x3
   0x8020000e <kern_init+4>:    addi    a0,a0,-2
   0x80200012 <kern_init+8>:    auipc   a2,0x3
   0x80200016 <kern_init+12>:   addi    a2,a2,-10
   0x8020001a <kern_init+16>:   addi    sp,sp,-16
   0x8020001c <kern_init+18>:   li      a1,0
   0x8020001e <kern_init+20>:   sub     a2,a2,a0
```

6、执行到kern_init，debug出现以下内容：

```
(THU.CST) os is loading ...
```

输入disassemble kern_init查看kern_init的汇编代码，如下：

```
(gdb) disassemble kern_init
Dump of assembler code for function kern_init:
   0x000000008020000a <+0>:     auipc   a0,0x3
   0x000000008020000e <+4>:     addi    a0,a0,-2 # 0x80203008
   0x0000000080200012 <+8>:     auipc   a2,0x3
   0x0000000080200016 <+12>:    addi    a2,a2,-10 # 0x80203008
   0x000000008020001a <+16>:    addi    sp,sp,-16
   0x000000008020001c <+18>:    li      a1,0
   0x000000008020001e <+20>:    sub     a2,a2,a0
   0x0000000080200020 <+22>:    sd      ra,8(sp)
   0x0000000080200022 <+24>:    jal     ra,0x802004b6 <memset>
   0x0000000080200026 <+28>:    auipc   a1,0x0
   0x000000008020002a <+32>:    addi    a1,a1,1186 # 0x802004c8
   0x000000008020002e <+36>:    auipc   a0,0x0
   0x0000000080200032 <+40>:    addi    a0,a0,1210 # 0x802004e8
   0x0000000080200036 <+44>:    jal     ra,0x80200056 <cprintf>
   0x000000008020003a <+48>:    j       0x8020003a <kern_init+48>
```

最终  j   0x8020003a <kern_init+48>为跳转到当前指令，也就是进入死循环。



流程总结：

Qume启动时，首先CPU加电，PC初始化为0x1000，openSBI.bin被加载到0x80000000；跳转到0x80000000启动Bootloader，进行启动操作系统的准备，并加载os.bin到0x80200000；跳转到0x80200000，也就是os.bin被加载的位置，首先执行kern_entry部分，分配内核栈，再进入kern_init函数进行初始化，会调用cprintf()函数输出(THU.CST) os is loading ...，后进入循环



### 知识点：

1、RISC-V硬件加电后执行了一小段固化在Qemu内的汇编代码，位于地址0x1000处，进行程序控制加载，以及跳转到0x80000000处启动Bootloader。

2、Bootloader作用是加载操作系统到内存，这部分指令的功能包括加载启动代码地址、设置寄存器、获取处理器信息等。

3、内核os.bin启动时会先执行kern_entry部分代码，用于分配内核栈，该栈用于存储内核函数调用的局部变量和参数、 支持中断和异常处理、保存线程或进程切换时的上下文信息。



### 练习1：使用GDB验证启动流程

RISC-V硬件加电后执行的指令在地址0x1000，具体如下：

```
   0x1000:      auipc   t0,0x0  # 将当前PC存入寄存器 t0
   0x1004:      addi    a1,t0,32  # t0 加上 32，存入 a1
   0x1008:      csrr    a0,mhartid # 读取状态寄存器mhartid(正在运行的硬件线程的整数ID)，存入a0中
   0x100c:      ld      t0,24(t0) # t0+24地址处读取8个字节，存入t0
   0x1010:      jr      t0 # 跳转到t0，也就是0x80000000
```

最终跳转到加载了OpenSBI.bin的0x80000000处，启动Bootloader，加载操作系统。

## LAB0.1
## 一、实验目的
实验1主要讲解的是中断处理机制。操作系统是计算机系统的监管者，必须能对计算机系统状态的突发变化做出反应，这些系统状态可能是程序执行出现异常，或者是突发的外设请求。当计算机系统遇到突发情况时，不得不停止当前的正常工作，应急响应一下，这是需要操作系统来接管，并跳转到对应处理函数进行处理，处理结束后再回到原来的地方继续执行指令。这个过程就是中断处理过程。

## 二、实验内容

### 练习1：理解内核启动中的程序入口操作

1.`la sp, bootstacktop`
`la sp, bootstacktop`即是将`bootstacktop`的地址赋值给`sp`寄存器，`bootstack`是一段栈空间，`bootstack`则是该栈空间的顶部，而执行赋值操作则相当于初始化了栈空间，用于`bootloader`事务的进行。



2.`tail kern_init`
`tail`是尾调用，即执行调用的函数后不会再返回，而是在调用的函数处接着执行，使用该函数即进行内核的初始化。


### 2.练习2

我们实现时钟中断的处理函数代码如下：

```C
 // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2212422 :  */
            
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
           clock_set_next_event();
           ticks+=1;
           if(num==10)
           {
            sbi_shutdown();
           }
           else if(ticks%TICK_NUM==0)
           {
            print_ticks();
            num+=1;
           }
```
如上所示，我们给出了练习的答案，首先设置下次的时钟中断，然后判断输出次数是否达到要求次数，若到达则执行关机函数，若未达到则判断ticks有没有到100，若到达则进行输出和输出次数加一。


### 3. 扩展练习 

### 3.1 扩展练习 Challenge1

1. ucore中处理中断异常的流程  
   当异常发生时，处理器会根据`stvec`寄存器的值跳转到相应的异常处理程序。具体来说，内核在初始化时将`stvec`寄存器设置为`__alltraps`的地址，这样当异常发生时，处理器就会执行`trapentry.S`中的`__alltraps`标签。

2. `mov a0, sp` 的目的  
   该指令的目的是将当前的栈指针`sp`的值存储到寄存器`a0`中，以便将当前中断帧的指针作为参数传递给后续的中断处理程序。根据RISC-V的函数调用规范，寄存器`a0`用于存储函数的第一个参数，这样可以方便地将中断相关的信息传递给处理函数。

3. SAVE_ALL中寄存器保存在栈中的位置 
   在执行`SAVE_ALL`宏时，各个寄存器保存在栈中的具体位置是通过栈指针`sp`进行索引的。栈指针在保存上下文之前会被调整，以为寄存器保留足够的空间。因此，保存的位置取决于`trapframe`结构的定义和`pushregs`宏中寄存器的顺序。

4. 需要保存所有寄存器吗？  
   不一定。是否需要保存所有寄存器取决于具体的中断处理程序的需求。有些中断可能只使用到少数几个寄存器，因此只需要保存那些寄存器就足够了。保存所有寄存器会增加上下文切换的开销，降低系统性能，尤其是在某些寄存器的值在中断期间并未改变的情况下。

### 3.2 扩展练习 Challenge2

1. `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 实现的操作  
    `csrw sscratch, sp`指令将当前的栈指针`sp`的值写入`sscratch`寄存器。此操作记录了异常发生时的栈顶位置。
    `csrrw s0, sscratch, x0`指令将`sscratch`中的值复制到`s0`寄存器，同时将`sscratch`清零。这一操作使得`sscratch`能够指示中断处理前的栈位置，同时`$s0`可以用于后续的上下文保存。

2. 不还原`stval`和`scause`的原因  
   在异常处理中，这两个CSR用于获取异常的类型和原因，处理完毕后，它们的值通常不再需要，并且可以被后续操作覆盖。因此，在恢复上下文时不需要将它们的值恢复，减少了不必要的操作，提高了效率。这些寄存器的值在中断处理期间可能需要读取，以确定异常的具体情况。

### 3.3 扩展练习 Challenge3

1. 代码实现  
   以下是对非法指令和断点异常的处理代码：
   ```c
   case CAUSE_ILLEGAL_INSTRUCTION:
       // 非法指令异常处理
       cprintf("Exception type: Illegal instruction\n");
       cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);
       tf->epc += 4;  // 将指令地址向前移动4字节，跳过非法指令
       break;
   case CAUSE_BREAKPOINT:
       // 断点异常处理
       cprintf("Exception type: breakpoint\n");
       cprintf("ebreak caught at 0x%016llx\n", tf->epc);
       tf->epc += 2;  // 将指令地址向前移动2字节，以保持4字节对齐
       break;
    ```

2.输出格式和指令地址
  使用格式化字符串`0x%016llx`来输出64位的异常指令地址，确保以十六进制格式显示，并且在前面补零至16位。
  在处理完非法指令异常后，通过将`tf->epc`增加4，确保跳过导致异常的非法指令。而在断点异常处理后，增加2以保持指令的4字节对齐，这对于后续指令的正确执行是必要的。

3.异常处理顺序
  在`kern_init`函数中，确保在调用`intr_enable()`之后再设置异常处理。这是因为`intr_enable()`会初始化`stvec`寄存器，只有在这一设置之后，才能正确捕获和处理之后的异常。为了测试异常处理功能，可以在kern_init函数中加入如下两行代码：
    ```asm("mret");  // 返回到异常发生前的状态
       asm("ebreak"); // 触发一个断点异常以测试处理
    ```
