## OS_Lab4实验报告

组员：刘俊彤，刘玉菡，孙启森

### 练习一：分配并初始化一个进程控制块

`struct proc_struct` 是一个用于表示进程的结构体，包含描述进程的各种信息和状态，主要用于内核中的进程调度与管理。

```c
struct proc_struct {
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
```

各个字段的作用：

1. **state**: 表示进程的当前状态（例如：就绪、运行、阻塞等），`PROC_UNINIT`，表示进程未初始化。
2. **pid**: 进程的唯一标识符（进程ID），`-1`表示该进程没有分配实际的进程ID。
3. **runs**: 记录进程已经运行的次数， `0`表示进程还未运行。
4. **kstack**: 进程的内核栈，内核栈在进程上下文切换时使用，存储该进程的函数调用信息和局部变量等。`0`表示暂时没有分配内核栈。
5. **need_resched**: 布尔值，标识该进程是否需要重新调度。如果需要重新调度，调度器会将其放回就绪队列。`0`表示不需要立即调度。
6. **parent**: 指向父进程的指针。如果该进程是由另一个进程通过 `fork` 创建的，那么它的父进程会被存储在这个字段中。`NULL`表示该进程没有父进程。
7. **mm**: 进程的内存管理结构体，通常包含该进程的地址空间等信息，但内核线程通常不需要内存管理。 `NULL`表示进程没有内存管理信息（内核线程通常不需要）。
8. **context**: 用于保存进程的上下文信息（如寄存器等），用于进程间的上下文切换。使用 `memset` 清零，初始化上下文为全零。
9. **tf**: 指向当前进程的 Trap Frame 的指针，用于中断处理时保存进程的寄存器状态。
10. **cr3**: 该进程的页目录基址（Page Directory Base Register）。它指定了进程的页目录，用于虚拟地址到物理地址的映射。设置为 `boot_cr3`表示初始化进程的页目录基址为启动时的 CR3 值。
11. **flags**: 进程的标志位，表示该进程的一些特性或状态。
12. **name**: 进程的名称，方便调试时查看进程信息。
13. **list_link**: 用于进程链表的链接，用于在进程调度队列中管理进程。
14. **hash_link**: 用于进程哈希表的链接，用于进程ID到进程的快速查找。

`alloc_proc` 函数的作用是分配并初始化一个新的进程控制块 `struct proc_struct`。

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1
    proc->state=PROC_UNINIT;
    proc->pid=-1;
    proc->runs=0;
    proc->kstack=0;
    proc->need_resched =0;
    proc->parent=NULL;
    proc->mm=NULL;
    memset(&(proc->context), 0, sizeof(struct context));
    proc->tf=NULL;
    proc->cr3=boot_cr3;
    proc->flags=0;
    memset(proc->name, 0, PROC_NAME_LEN + 1);

    }
    return proc;
}
```

##### struct context context 和 struct trapframe *tf 成员变量的含义：

1. **`context` (struct context)**:
   - `context` 存储了进程切换时需要保存的寄存器状态，即上下文切换时保存当前进程的执行状态，通常包括栈指针、程序计数器（PC）等寄存器的值，方便在切换回该进程时恢复它的执行。
   - 在本实验中，`context` 的作用主要是支持上下文切换（通过 `switch_to()` 函数），以便在不同进程间切换时正确恢复状态。
2. **`tf` (struct trapframe \*)**:
   - `trapframe` 结构体用于保存中断或系统调用触发时的上下文。当进程发生异常、系统调用或中断时，`trapframe` 保存了必要的寄存器值，包括程序计数器（PC）、栈指针（SP）等，以便在中断处理完成后恢复执行。
   - 在本实验中，`tf` 用来保存内核线程的陷入状态，并确保进程在切换后能够从适当的地方继续执行。例如，`forkret()` 函数会通过 `trapframe` 中的信息来恢复内核线程的执行。

### 练习二：为新创建的内核线程分配资源

```c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 
    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if((proc = alloc_proc())==NULL)
    {
        goto fork_out;
    }
    proc->parent=current;
    if(setup_kstack(proc))
    {
        goto bad_fork_cleanup_kstack;
    }
    if(copy_mm(clone_flags,proc))
    {
        goto bad_fork_cleanup_proc;
    }
    copy_thread(proc,stack,tf);
   bool intr_flag;
   local_intr_save(intr_flag);
    {
        proc->pid=get_pid();
        hash_proc(proc);
        list_add(&proc_list,&(proc->list_link));
        nr_process++;
    }
   local_intr_restore(intr_flag);

    wakeup_proc(proc);
    ret = proc->pid;
```

`do_fork` 函数的主要任务是为新创建的内核线程分配资源，并完成父进程和子进程的相关初始化工作。以下为`do_fork` 实现的关键步骤：

1. **调用 `alloc_proc` 分配进程控制块（PCB）**：

   `alloc_proc` 会为新进程分配一块内存空间，并初始化其结构体 `proc_struct`。

2. **分配内核栈**：

   使用 `setup_kstack` 函数，为新进程分配一块内存来作为内核栈。这块栈内存是每个进程在内核态运行时必要的，保证进程在进行系统调用或中断时有独立的栈空间。

3. **复制内存管理信息**：

   虽然 `do_fork` 会调用 `copy_mm` 来复制内存管理信息，但因为在本实验中主要是内核线程的创建，内核线程不需要复制父进程的用户空间（`copy_mm` 只是一个占位符）。在一般的用户进程 `fork` 中，这一步会确保父进程和子进程共享或独立管理各自的虚拟内存空间。

4. **复制原进程的上下文**：

   通过 `copy_thread`，父进程的上下文（包括 `trapframe` 和 `context`）会被复制到新进程的内核栈上，以确保子进程能够从正确的位置继续执行。

5. **将新进程添加到进程列表**：

   使用 `hash_proc` 和 `list_add` 将新进程添加到进程列表和哈希列表中，对进程进行管理和调度。

6. **唤醒新进程**：

   通过 `wakeup_proc` 设置新进程的状态为 `PROC_RUNNABLE`，表示新进程已准备好运行，能够被调度器调度执行。

7. **返回新进程号**：

   - `do_fork` 最终会返回新进程的 `pid`，作为调用 `fork` 系统调用的返回值。

**ucore 是否给每个新 `fork` 的线程分配唯一的 ID？**

`ucore` 会为每个新创建的内核线程分配唯一的 `pid`。`get_pid` 函数会遍历进程列表 `proc_list`，查找已经分配的 `pid`。每次它会尝试为新进程分配一个唯一的 `pid`。当 `last_pid` 达到 `MAX_PID` 时，它会从 1 开始重新分配 `pid`，以确保在 `MAX_PID` 范围内分配到一个尚未使用的 `pid`。

```c
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

**分析和理由**：

- **进程唯一性**：通过这种方式，`get_pid` 确保每个进程（包括内核线程）都有一个唯一的 `pid`。这是因为 `pid` 在操作系统中是用于标识进程的重要标识符，具有唯一性至关重要，避免了进程间的冲突。
- **PID 重用**：在 `MAX_PID` 范围内，`pid` 会循环使用，但系统会确保每次分配的 `pid` 都是未被占用的。这种方法使得 `pid` 在有限的范围内保持唯一性，并且不会随着进程的增加而出现资源耗尽的情况。

### 练习三：编写 proc_run 函数

```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3
       bool intr_flag;
       struct proc_struct *prev = current;
       struct proc_struct *next = proc;
       local_intr_save(intr_flag); // 禁用中断
       {
            current=proc; // 更新当前线程为proc
            lcr3(next->cr3); // 更换页表
            switch_to(&(prev->context),&(next->context)); // 上下文切换
       }
       local_intr_restore(intr_flag); // 开启中断
    }
}
```

在 `ucore` 操作系统中，`proc_run` 函数负责将一个进程切换到 CPU 上运行，即保存当前进程的状态，并将 CPU 控制权交给另一个进程。以下是 `proc_run` 函数的具体实现步骤：

1. **检查要切换的进程是否与当前进程相同**：

   通过检查 `current` 进程指针与目标进程指针是否相同，如果要切换的进程是当前正在运行的进程，则不需要进行切换，直接返回。

2. **禁用中断**：

   使用 `local_intr_save(x)` 来禁用中断，并且保存中断状态，确保在上下文切换的过程中不会被打断。切换页表和上下文时，如果发生中断会影响当前进程的状态，因此需要禁止中断。`local_intr_restore(x)` 用于恢复中断。

3. **切换进程**：

   我们需要将当前进程的状态保存，并将目标进程的信息加载到当前的上下文中。这部分包括切换进程的页表和上下文。

4. **切换页表**：

   使用 `lcr3` 函数来切换 CR3 寄存器的值， `lcr3(proc->cr3)` 会将当前的 CR3 寄存器值更改为目标进程的页表基地址，从而更改当前进程的页表来确保 CPU 使用新进程的地址空间。

5. **上下文切换**：

   最后，使用 `switch_to()` 函数来进行上下文切换。这一步保存当前进程的上下文，并恢复目标进程的上下文，从而实现进程间的切换，是实现进程调度的核心部分。

6. **允许中断**：

   完成进程切换后，需要恢复中断状态，允许中断继续发生。

**在本实验的执行过程中，创建且运行了几个内核线程？**

在本实验中，创建并运行了两个内核线程：

1. **idleproc**：第一个内核进程，负责完成内核中各个子系统的初始化。初始化完成后，它进入调度状态，等待执行其他进程。

2. **initproc**：第二个内核进程，被调度执行，承担实验功能的执行任务。

   

### 扩展练习 Challenge：

**说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？**

相关代码如下：

```c++
// kern/sync/sync.h
#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}


// kern/driver/intr.c
/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }


// libs/riscv.h
#define read_csr(reg) ({ unsigned long __tmp; \
  asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
  __tmp; })
#define set_csr(reg, bit) ({ unsigned long __tmp; \
  asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })
#define clear_csr(reg, bit) ({ unsigned long __tmp; \
  asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "rK"(bit)); \
  __tmp; })

```

（1）`local_intr_save(x)`会调用`__intr_save`：

读取`sstatus`寄存器，判断`SIE`位，

+ 如果该位为1，表示当前可以中断，则调用 `intr_disable`，将该位置为0，禁用中断，返回1，将参数x赋值为1；
+ 如果该位为0，表示当前已禁用中断，返回0，将参数x赋值为0；

（2）`local_intr_restore(x)`会调用`__intr_restore`：

该函数会判断参数x的值：

+ 如果该值为1，说明是由启用中断改为了禁用中断，需要调用`intr_enable`，将sstatus的SIE位置为1，启用中断；
+ 如果该值为0，说明原本就是禁用中断状态，不需要操作。

