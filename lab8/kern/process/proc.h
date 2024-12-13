#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>
#include <skew_heap.h>

// process's state in his life cycle
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized
    PROC_SLEEPING,    // sleeping
    PROC_RUNNABLE,    // runnable(maybe running)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource
};

struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;

struct inode;

struct proc_struct {
    enum proc_state state;                      // Process state 进程状态
    int pid;                                    // Process ID 进程id
    int runs;                                   // the running times of Proces 进程运行次数
    uintptr_t kstack;                           // Process kernel stack 进程内核栈的基地址
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU? 进程需要被调度
    struct proc_struct *parent;                 // the parent process 父进程指针
    struct mm_struct *mm;                       // Process's memory management field 进程的内存管理器
    struct context context;                     // Switch here to run process 进程上下文 保存进程状态 在切换出cpu时保存，切换回cpu时读取，继续运行
    struct trapframe *tf;                       // Trap frame for current interrupt 中断帧，用于保存中断信息，以处理中断后继续执行
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT) 进程页目录表的基地址
    uint32_t flags;                             // Process flag 进程标志位
    char name[PROC_NAME_LEN + 1];               // Process name 进程名字
    list_entry_t list_link;                     // Process link list 进程链表的连接项，用于将进程连接到进程列表中
    list_entry_t hash_link;                     // Process hash list 进程的哈希表连接项，用于将进程连接到哈希表中，快速查找进程
    int exit_code;                              // exit code (be sent to parent proc) 进程退出代码，用于终止时向父进程传递推出状态
    uint32_t wait_state;                        // waiting state 等待状态 
    struct proc_struct *cptr, *yptr, *optr;     // relations between processes 子进程/较新的兄弟进程/较老的兄弟进程
    struct run_queue *rq;                       // running queue contains Process 运行队列指针，用于进程调度
    list_entry_t run_link;                      // the entry linked in run queue 运行队列的连接项
    int time_slice;                             // time slice for occupying the CPU 进程时间片，表示进程能连续占用CPU的时间长度
    skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
    uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
    uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
    struct files_struct *filesp;                // the file related info(pwd, files_count, files_array, fs_semaphore) of process
};

#define PF_EXITING                  0x00000001      // getting shutdown

#define WT_CHILD                    (0x00000001 | WT_INTERRUPTED)
#define WT_INTERRUPTED               0x80000000                    // the wait state could be interrupted

#define WT_CHILD                    (0x00000001 | WT_INTERRUPTED)  // wait child process
#define WT_KSEM                      0x00000100                    // wait kernel semaphore
#define WT_TIMER                    (0x00000002 | WT_INTERRUPTED)  // wait timer
#define WT_KBD                      (0x00000004 | WT_INTERRUPTED)  // wait the input of keyboard

#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority);


struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);
int do_yield(void);
int do_execve(const char *name, int argc, const char **argv);
int do_wait(int pid, int *code_store);
int do_kill(int pid);
int do_sleep(unsigned int time);
#endif /* !__KERN_PROCESS_PROC_H__ */

