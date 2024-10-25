
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area1>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	58660613          	addi	a2,a2,1414 # ffffffffc02065c0 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	48c010ef          	jal	ra,ffffffffc02014d6 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	49650513          	addi	a0,a0,1174 # ffffffffc02014e8 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	59b000ef          	jal	ra,ffffffffc0200e00 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	75b000ef          	jal	ra,ffffffffc0201000 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	725000ef          	jal	ra,ffffffffc0201000 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	3cc50513          	addi	a0,a0,972 # ffffffffc0201508 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	3d650513          	addi	a0,a0,982 # ffffffffc0201528 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	38a58593          	addi	a1,a1,906 # ffffffffc02014e8 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	3e250513          	addi	a0,a0,994 # ffffffffc0201548 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area1>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0201568 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	43a58593          	addi	a1,a1,1082 # ffffffffc02065c0 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201588 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00007597          	auipc	a1,0x7
ffffffffc020019e:	82558593          	addi	a1,a1,-2011 # ffffffffc02069bf <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02015a8 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	40e60613          	addi	a2,a2,1038 # ffffffffc02015d8 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	41a50513          	addi	a0,a0,1050 # ffffffffc02015f0 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	42260613          	addi	a2,a2,1058 # ffffffffc0201608 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	43a58593          	addi	a1,a1,1082 # ffffffffc0201628 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	43a50513          	addi	a0,a0,1082 # ffffffffc0201630 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	43c60613          	addi	a2,a2,1084 # ffffffffc0201640 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	45c58593          	addi	a1,a1,1116 # ffffffffc0201668 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	41c50513          	addi	a0,a0,1052 # ffffffffc0201630 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	45860613          	addi	a2,a2,1112 # ffffffffc0201678 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	47058593          	addi	a1,a1,1136 # ffffffffc0201698 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	40050513          	addi	a0,a0,1024 # ffffffffc0201630 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	43e50513          	addi	a0,a0,1086 # ffffffffc02016a8 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	44450513          	addi	a0,a0,1092 # ffffffffc02016d0 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	49ec0c13          	addi	s8,s8,1182 # ffffffffc0201740 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	44e90913          	addi	s2,s2,1102 # ffffffffc02016f8 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	44e48493          	addi	s1,s1,1102 # ffffffffc0201700 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	44cb0b13          	addi	s6,s6,1100 # ffffffffc0201708 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	364a0a13          	addi	s4,s4,868 # ffffffffc0201628 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	0b2010ef          	jal	ra,ffffffffc0201382 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	45ad0d13          	addi	s10,s10,1114 # ffffffffc0201740 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	1ae010ef          	jal	ra,ffffffffc02014a2 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	19a010ef          	jal	ra,ffffffffc02014a2 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	17a010ef          	jal	ra,ffffffffc02014c0 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	13c010ef          	jal	ra,ffffffffc02014c0 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	38a50513          	addi	a0,a0,906 # ffffffffc0201728 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	1cc30313          	addi	t1,t1,460 # ffffffffc0206578 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	3ae50513          	addi	a0,a0,942 # ffffffffc0201788 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	1e050513          	addi	a0,a0,480 # ffffffffc02015d0 <etext+0xe8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	030010ef          	jal	ra,ffffffffc0201450 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1407bd23          	sd	zero,346(a5) # ffffffffc0206580 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	37a50513          	addi	a0,a0,890 # ffffffffc02017a8 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	00a0106f          	j	ffffffffc0201450 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	7e70006f          	j	ffffffffc0201436 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	0160106f          	j	ffffffffc020146a <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	34a50513          	addi	a0,a0,842 # ffffffffc02017c8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	35250513          	addi	a0,a0,850 # ffffffffc02017e0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	35c50513          	addi	a0,a0,860 # ffffffffc02017f8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	36650513          	addi	a0,a0,870 # ffffffffc0201810 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	37050513          	addi	a0,a0,880 # ffffffffc0201828 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	37a50513          	addi	a0,a0,890 # ffffffffc0201840 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	38450513          	addi	a0,a0,900 # ffffffffc0201858 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	38e50513          	addi	a0,a0,910 # ffffffffc0201870 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	39850513          	addi	a0,a0,920 # ffffffffc0201888 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	3a250513          	addi	a0,a0,930 # ffffffffc02018a0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	3ac50513          	addi	a0,a0,940 # ffffffffc02018b8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	3b650513          	addi	a0,a0,950 # ffffffffc02018d0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	3c050513          	addi	a0,a0,960 # ffffffffc02018e8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	3ca50513          	addi	a0,a0,970 # ffffffffc0201900 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	3d450513          	addi	a0,a0,980 # ffffffffc0201918 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	3de50513          	addi	a0,a0,990 # ffffffffc0201930 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	3e850513          	addi	a0,a0,1000 # ffffffffc0201948 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	3f250513          	addi	a0,a0,1010 # ffffffffc0201960 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	3fc50513          	addi	a0,a0,1020 # ffffffffc0201978 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	40650513          	addi	a0,a0,1030 # ffffffffc0201990 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	41050513          	addi	a0,a0,1040 # ffffffffc02019a8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	41a50513          	addi	a0,a0,1050 # ffffffffc02019c0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	42450513          	addi	a0,a0,1060 # ffffffffc02019d8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	42e50513          	addi	a0,a0,1070 # ffffffffc02019f0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	43850513          	addi	a0,a0,1080 # ffffffffc0201a08 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	44250513          	addi	a0,a0,1090 # ffffffffc0201a20 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	44c50513          	addi	a0,a0,1100 # ffffffffc0201a38 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	45650513          	addi	a0,a0,1110 # ffffffffc0201a50 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	46050513          	addi	a0,a0,1120 # ffffffffc0201a68 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	46a50513          	addi	a0,a0,1130 # ffffffffc0201a80 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	47450513          	addi	a0,a0,1140 # ffffffffc0201a98 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	47a50513          	addi	a0,a0,1146 # ffffffffc0201ab0 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	47e50513          	addi	a0,a0,1150 # ffffffffc0201ac8 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	47e50513          	addi	a0,a0,1150 # ffffffffc0201ae0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	48650513          	addi	a0,a0,1158 # ffffffffc0201af8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	48e50513          	addi	a0,a0,1166 # ffffffffc0201b10 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	49250513          	addi	a0,a0,1170 # ffffffffc0201b28 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	55870713          	addi	a4,a4,1368 # ffffffffc0201c08 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	4de50513          	addi	a0,a0,1246 # ffffffffc0201ba0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	4b450513          	addi	a0,a0,1204 # ffffffffc0201b80 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	46a50513          	addi	a0,a0,1130 # ffffffffc0201b40 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	4e050513          	addi	a0,a0,1248 # ffffffffc0201bc0 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	e8e68693          	addi	a3,a3,-370 # ffffffffc0206580 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	4d850513          	addi	a0,a0,1240 # ffffffffc0201be8 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	44650513          	addi	a0,a0,1094 # ffffffffc0201b60 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201bd8 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <default_init>:
#define free_list(property) (free_area1[(property)].free_list)
#define nr_free(property) (free_area1[(property)].nr_free)

static void
default_init(void) {
    for(int i=0;i<MAX_ORDER+1;i++)
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area1>
ffffffffc020080a:	00006717          	auipc	a4,0x6
ffffffffc020080e:	96e70713          	addi	a4,a4,-1682 # ffffffffc0206178 <buf>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200812:	e79c                	sd	a5,8(a5)
ffffffffc0200814:	e39c                	sd	a5,0(a5)
    {
    list_init(&(free_area1[i].free_list));
     free_area1[i].nr_free = 0;
ffffffffc0200816:	0007a823          	sw	zero,16(a5)
    for(int i=0;i<MAX_ORDER+1;i++)
ffffffffc020081a:	07e1                	addi	a5,a5,24
ffffffffc020081c:	fee79be3          	bne	a5,a4,ffffffffc0200812 <default_init+0x10>
    }
}
ffffffffc0200820:	8082                	ret

ffffffffc0200822 <split_page>:
    remain=remain-(1<<(order));
    
}
    

static void split_page(int order) {
ffffffffc0200822:	7179                	addi	sp,sp,-48
ffffffffc0200824:	e84a                	sd	s2,16(sp)
ffffffffc0200826:	00151913          	slli	s2,a0,0x1
ffffffffc020082a:	e052                	sd	s4,0(sp)
ffffffffc020082c:	00a90a33          	add	s4,s2,a0
ffffffffc0200830:	e44e                	sd	s3,8(sp)
ffffffffc0200832:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200834:	00005997          	auipc	s3,0x5
ffffffffc0200838:	7dc98993          	addi	s3,s3,2012 # ffffffffc0206010 <free_area1>
ffffffffc020083c:	014987b3          	add	a5,s3,s4
ffffffffc0200840:	f022                	sd	s0,32(sp)
ffffffffc0200842:	6780                	ld	s0,8(a5)
ffffffffc0200844:	ec26                	sd	s1,24(sp)
ffffffffc0200846:	f406                	sd	ra,40(sp)
ffffffffc0200848:	84aa                	mv	s1,a0
    if(list_empty(&(free_area1[order].free_list))) {
ffffffffc020084a:	08f40463          	beq	s0,a5,ffffffffc02008d2 <split_page+0xb0>
    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page= le2page(le, page_link);
    list_del(&(page->page_link));
   free_area1[order].nr_free-=1;
ffffffffc020084e:	9926                	add	s2,s2,s1
ffffffffc0200850:	090e                	slli	s2,s2,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200852:	6410                	ld	a2,8(s0)
ffffffffc0200854:	600c                	ld	a1,0(s0)
    size_t n = 1 << (order - 1);
ffffffffc0200856:	34fd                	addiw	s1,s1,-1
   free_area1[order].nr_free-=1;
ffffffffc0200858:	994e                	add	s2,s2,s3
    size_t n = 1 << (order - 1);
ffffffffc020085a:	4785                	li	a5,1
   free_area1[order].nr_free-=1;
ffffffffc020085c:	01092683          	lw	a3,16(s2)
    size_t n = 1 << (order - 1);
ffffffffc0200860:	0097973b          	sllw	a4,a5,s1
    struct Page *p = page + n;
ffffffffc0200864:	00271793          	slli	a5,a4,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200868:	e590                	sd	a2,8(a1)
ffffffffc020086a:	97ba                	add	a5,a5,a4
    next->prev = prev;
ffffffffc020086c:	e20c                	sd	a1,0(a2)
   free_area1[order].nr_free-=1;
ffffffffc020086e:	fff6871b          	addiw	a4,a3,-1
    struct Page *p = page + n;
ffffffffc0200872:	078e                	slli	a5,a5,0x3
   free_area1[order].nr_free-=1;
ffffffffc0200874:	00e92823          	sw	a4,16(s2)
    struct Page *p = page + n;
ffffffffc0200878:	17a1                	addi	a5,a5,-24
ffffffffc020087a:	97a2                	add	a5,a5,s0
    page->property = order-1;
ffffffffc020087c:	fe942c23          	sw	s1,-8(s0)
    size_t n = 1 << (order - 1);
ffffffffc0200880:	0004869b          	sext.w	a3,s1
    p->property = order-1;
ffffffffc0200884:	cb84                	sw	s1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200886:	4709                	li	a4,2
ffffffffc0200888:	00878613          	addi	a2,a5,8
ffffffffc020088c:	40e6302f          	amoor.d	zero,a4,(a2)
ffffffffc0200890:	ff040613          	addi	a2,s0,-16
ffffffffc0200894:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200898:	00169713          	slli	a4,a3,0x1
ffffffffc020089c:	9736                	add	a4,a4,a3
ffffffffc020089e:	070e                	slli	a4,a4,0x3
ffffffffc02008a0:	974e                	add	a4,a4,s3
ffffffffc02008a2:	6710                	ld	a2,8(a4)
    SetPageProperty(p);
    SetPageProperty(page);
    list_add(&(free_area1[order-1].free_list),&(page->page_link));
ffffffffc02008a4:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc02008a6:	e700                	sd	s0,8(a4)
ffffffffc02008a8:	99d2                	add	s3,s3,s4
    elm->prev = prev;
ffffffffc02008aa:	01343023          	sd	s3,0(s0)
    list_add(&(page->page_link),&(p->page_link));
ffffffffc02008ae:	01878593          	addi	a1,a5,24
    free_area1[order-1].nr_free += 2;
ffffffffc02008b2:	4b14                	lw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc02008b4:	e20c                	sd	a1,0(a2)
ffffffffc02008b6:	e40c                	sd	a1,8(s0)
    elm->prev = prev;
ffffffffc02008b8:	ef80                	sd	s0,24(a5)
    return;
}
ffffffffc02008ba:	70a2                	ld	ra,40(sp)
ffffffffc02008bc:	7402                	ld	s0,32(sp)
    elm->next = next;
ffffffffc02008be:	f390                	sd	a2,32(a5)
    free_area1[order-1].nr_free += 2;
ffffffffc02008c0:	0026879b          	addiw	a5,a3,2
ffffffffc02008c4:	cb1c                	sw	a5,16(a4)
}
ffffffffc02008c6:	64e2                	ld	s1,24(sp)
ffffffffc02008c8:	6942                	ld	s2,16(sp)
ffffffffc02008ca:	69a2                	ld	s3,8(sp)
ffffffffc02008cc:	6a02                	ld	s4,0(sp)
ffffffffc02008ce:	6145                	addi	sp,sp,48
ffffffffc02008d0:	8082                	ret
        split_page(order + 1);
ffffffffc02008d2:	2505                	addiw	a0,a0,1
ffffffffc02008d4:	f4fff0ef          	jal	ra,ffffffffc0200822 <split_page>
    return listelm->next;
ffffffffc02008d8:	6400                	ld	s0,8(s0)
ffffffffc02008da:	bf95                	j	ffffffffc020084e <split_page+0x2c>

ffffffffc02008dc <add_page>:
    free_area1[order].nr_free-=1;
    return page;
}
static void add_page(struct Page *base, int order)
{
    if (list_empty(&(free_area1[order].free_list))) {
ffffffffc02008dc:	00159713          	slli	a4,a1,0x1
ffffffffc02008e0:	972e                	add	a4,a4,a1
ffffffffc02008e2:	00371593          	slli	a1,a4,0x3
ffffffffc02008e6:	00005717          	auipc	a4,0x5
ffffffffc02008ea:	72a70713          	addi	a4,a4,1834 # ffffffffc0206010 <free_area1>
ffffffffc02008ee:	972e                	add	a4,a4,a1
ffffffffc02008f0:	671c                	ld	a5,8(a4)
ffffffffc02008f2:	00f71963          	bne	a4,a5,ffffffffc0200904 <add_page+0x28>
ffffffffc02008f6:	a821                	j	ffffffffc020090e <add_page+0x32>
    } 
    else {
        list_entry_t* le = &(free_area1[order].free_list);
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
ffffffffc02008f8:	02d56263          	bltu	a0,a3,ffffffffc020091c <add_page+0x40>
ffffffffc02008fc:	6794                	ld	a3,8(a5)
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_area1[order].free_list)) {
ffffffffc02008fe:	02d70763          	beq	a4,a3,ffffffffc020092c <add_page+0x50>
ffffffffc0200902:	87b6                	mv	a5,a3
            struct Page* page = le2page(le, page_link);
ffffffffc0200904:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
ffffffffc0200908:	fef718e3          	bne	a4,a5,ffffffffc02008f8 <add_page+0x1c>
                list_add(le, &(base->page_link));
                break;
            }
        }
    }
}
ffffffffc020090c:	8082                	ret
        list_add(&(free_area1[order].free_list), &(base->page_link));
ffffffffc020090e:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc0200912:	e31c                	sd	a5,0(a4)
ffffffffc0200914:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0200916:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200918:	ed18                	sd	a4,24(a0)
}
ffffffffc020091a:	8082                	ret
    __list_add(elm, listelm->prev, listelm);
ffffffffc020091c:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc020091e:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc0200922:	e394                	sd	a3,0(a5)
ffffffffc0200924:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200926:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200928:	ed18                	sd	a4,24(a0)
}
ffffffffc020092a:	8082                	ret
                list_add(le, &(base->page_link));
ffffffffc020092c:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc0200930:	e314                	sd	a3,0(a4)
ffffffffc0200932:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0200934:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200936:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200938:	8082                	ret

ffffffffc020093a <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    size_t num = 0;
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc020093a:	00005697          	auipc	a3,0x5
ffffffffc020093e:	6e668693          	addi	a3,a3,1766 # ffffffffc0206020 <free_area1+0x10>
ffffffffc0200942:	4701                	li	a4,0
    size_t num = 0;
ffffffffc0200944:	4501                	li	a0,0
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200946:	463d                	li	a2,15
    {
        num+=free_area1[i].nr_free<<i;
ffffffffc0200948:	429c                	lw	a5,0(a3)
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc020094a:	06e1                	addi	a3,a3,24
        num+=free_area1[i].nr_free<<i;
ffffffffc020094c:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200950:	1782                	slli	a5,a5,0x20
ffffffffc0200952:	9381                	srli	a5,a5,0x20
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200954:	2705                	addiw	a4,a4,1
        num+=free_area1[i].nr_free<<i;
ffffffffc0200956:	953e                	add	a0,a0,a5
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200958:	fec718e3          	bne	a4,a2,ffffffffc0200948 <default_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc020095c:	8082                	ret

ffffffffc020095e <default_free_pages.part.0>:
    for (; p != base + n; p ++) {
ffffffffc020095e:	00259793          	slli	a5,a1,0x2
ffffffffc0200962:	97ae                	add	a5,a5,a1
default_free_pages(struct Page *base, size_t n) {
ffffffffc0200964:	715d                	addi	sp,sp,-80
    for (; p != base + n; p ++) {
ffffffffc0200966:	078e                	slli	a5,a5,0x3
default_free_pages(struct Page *base, size_t n) {
ffffffffc0200968:	e0a2                	sd	s0,64(sp)
    for (; p != base + n; p ++) {
ffffffffc020096a:	00f506b3          	add	a3,a0,a5
default_free_pages(struct Page *base, size_t n) {
ffffffffc020096e:	e486                	sd	ra,72(sp)
ffffffffc0200970:	fc26                	sd	s1,56(sp)
ffffffffc0200972:	f84a                	sd	s2,48(sp)
ffffffffc0200974:	f44e                	sd	s3,40(sp)
ffffffffc0200976:	f052                	sd	s4,32(sp)
ffffffffc0200978:	ec56                	sd	s5,24(sp)
ffffffffc020097a:	e85a                	sd	s6,16(sp)
ffffffffc020097c:	e45e                	sd	s7,8(sp)
ffffffffc020097e:	e062                	sd	s8,0(sp)
ffffffffc0200980:	842a                	mv	s0,a0
    for (; p != base + n; p ++) {
ffffffffc0200982:	87aa                	mv	a5,a0
ffffffffc0200984:	02d50263          	beq	a0,a3,ffffffffc02009a8 <default_free_pages.part.0+0x4a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200988:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020098a:	8b05                	andi	a4,a4,1
ffffffffc020098c:	14071763          	bnez	a4,ffffffffc0200ada <default_free_pages.part.0+0x17c>
ffffffffc0200990:	6798                	ld	a4,8(a5)
ffffffffc0200992:	8b09                	andi	a4,a4,2
ffffffffc0200994:	14071363          	bnez	a4,ffffffffc0200ada <default_free_pages.part.0+0x17c>
        p->flags = 0;
ffffffffc0200998:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020099c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02009a0:	02878793          	addi	a5,a5,40
ffffffffc02009a4:	fed792e3          	bne	a5,a3,ffffffffc0200988 <default_free_pages.part.0+0x2a>
    while(n!=(1<<order))
ffffffffc02009a8:	4785                	li	a5,1
    int order = 0;
ffffffffc02009aa:	4a01                	li	s4,0
    while(n!=(1<<order))
ffffffffc02009ac:	4705                	li	a4,1
ffffffffc02009ae:	12f58463          	beq	a1,a5,ffffffffc0200ad6 <default_free_pages.part.0+0x178>
        order++;
ffffffffc02009b2:	2a05                	addiw	s4,s4,1
    while(n!=(1<<order))
ffffffffc02009b4:	014717bb          	sllw	a5,a4,s4
ffffffffc02009b8:	fef59de3          	bne	a1,a5,ffffffffc02009b2 <default_free_pages.part.0+0x54>
    base->property = order;
ffffffffc02009bc:	000a079b          	sext.w	a5,s4
ffffffffc02009c0:	c81c                	sw	a5,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009c2:	00840713          	addi	a4,s0,8
ffffffffc02009c6:	4789                	li	a5,2
ffffffffc02009c8:	40f7302f          	amoor.d	zero,a5,(a4)
    add_page(base, order);
ffffffffc02009cc:	85d2                	mv	a1,s4
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	f0dff0ef          	jal	ra,ffffffffc02008dc <add_page>
    free_area1[order].nr_free += 1;
ffffffffc02009d4:	001a1793          	slli	a5,s4,0x1
ffffffffc02009d8:	97d2                	add	a5,a5,s4
ffffffffc02009da:	00005917          	auipc	s2,0x5
ffffffffc02009de:	63690913          	addi	s2,s2,1590 # ffffffffc0206010 <free_area1>
ffffffffc02009e2:	078e                	slli	a5,a5,0x3
ffffffffc02009e4:	97ca                	add	a5,a5,s2
ffffffffc02009e6:	4b98                	lw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc02009e8:	46b9                	li	a3,14
ffffffffc02009ea:	84be                	mv	s1,a5
    free_area1[order].nr_free += 1;
ffffffffc02009ec:	2705                	addiw	a4,a4,1
ffffffffc02009ee:	cb98                	sw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc02009f0:	001a0a9b          	addiw	s5,s4,1
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc02009f4:	4b85                	li	s7,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02009f6:	59f5                	li	s3,-3
    if(order == MAX_ORDER)
ffffffffc02009f8:	4c39                	li	s8,14
ffffffffc02009fa:	06da1563          	bne	s4,a3,ffffffffc0200a64 <default_free_pages.part.0+0x106>
ffffffffc02009fe:	a069                	j	ffffffffc0200a88 <default_free_pages.part.0+0x12a>
        if (p + (1<<(p->property)) == base) {
ffffffffc0200a00:	ff87a683          	lw	a3,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a04:	fe878b13          	addi	s6,a5,-24
        if (p + (1<<(p->property)) == base) {
ffffffffc0200a08:	00db963b          	sllw	a2,s7,a3
ffffffffc0200a0c:	00261713          	slli	a4,a2,0x2
ffffffffc0200a10:	9732                	add	a4,a4,a2
ffffffffc0200a12:	070e                	slli	a4,a4,0x3
ffffffffc0200a14:	975a                	add	a4,a4,s6
ffffffffc0200a16:	04e41a63          	bne	s0,a4,ffffffffc0200a6a <default_free_pages.part.0+0x10c>
            p->property += 1;
ffffffffc0200a1a:	2685                	addiw	a3,a3,1
ffffffffc0200a1c:	fed7ac23          	sw	a3,-8(a5)
ffffffffc0200a20:	00840713          	addi	a4,s0,8
ffffffffc0200a24:	6137302f          	amoand.d	zero,s3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a28:	7014                	ld	a3,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200a2a:	4898                	lw	a4,16(s1)
            add_page(base,order+1);
ffffffffc0200a2c:	000a8a1b          	sext.w	s4,s5
    prev->next = next;
ffffffffc0200a30:	e794                	sd	a3,8(a5)
    next->prev = prev;
ffffffffc0200a32:	e29c                	sd	a5,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a34:	6390                	ld	a2,0(a5)
ffffffffc0200a36:	6794                	ld	a3,8(a5)
            free_area1[order].nr_free -= 2;
ffffffffc0200a38:	ffe7079b          	addiw	a5,a4,-2
            add_page(base,order+1);
ffffffffc0200a3c:	85d2                	mv	a1,s4
    prev->next = next;
ffffffffc0200a3e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0200a40:	e290                	sd	a2,0(a3)
            free_area1[order].nr_free -= 2;
ffffffffc0200a42:	c89c                	sw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200a44:	855a                	mv	a0,s6
ffffffffc0200a46:	e97ff0ef          	jal	ra,ffffffffc02008dc <add_page>
            free_area1[order+1].nr_free += 1;
ffffffffc0200a4a:	001a1793          	slli	a5,s4,0x1
ffffffffc0200a4e:	97d2                	add	a5,a5,s4
ffffffffc0200a50:	078e                	slli	a5,a5,0x3
ffffffffc0200a52:	97ca                	add	a5,a5,s2
ffffffffc0200a54:	4b98                	lw	a4,16(a5)
ffffffffc0200a56:	845a                	mv	s0,s6
ffffffffc0200a58:	2705                	addiw	a4,a4,1
ffffffffc0200a5a:	cb98                	sw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc0200a5c:	04e1                	addi	s1,s1,24
ffffffffc0200a5e:	2a85                	addiw	s5,s5,1
ffffffffc0200a60:	038a0463          	beq	s4,s8,ffffffffc0200a88 <default_free_pages.part.0+0x12a>
    return listelm->prev;
ffffffffc0200a64:	6c1c                	ld	a5,24(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200a66:	f8979de3          	bne	a5,s1,ffffffffc0200a00 <default_free_pages.part.0+0xa2>
    return listelm->next;
ffffffffc0200a6a:	7018                	ld	a4,32(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200a6c:	00e48e63          	beq	s1,a4,ffffffffc0200a88 <default_free_pages.part.0+0x12a>
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200a70:	4810                	lw	a2,16(s0)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a72:	fe870593          	addi	a1,a4,-24
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200a76:	00cb96bb          	sllw	a3,s7,a2
ffffffffc0200a7a:	00269793          	slli	a5,a3,0x2
ffffffffc0200a7e:	97b6                	add	a5,a5,a3
ffffffffc0200a80:	078e                	slli	a5,a5,0x3
ffffffffc0200a82:	97a2                	add	a5,a5,s0
ffffffffc0200a84:	00f58e63          	beq	a1,a5,ffffffffc0200aa0 <default_free_pages.part.0+0x142>
}
ffffffffc0200a88:	60a6                	ld	ra,72(sp)
ffffffffc0200a8a:	6406                	ld	s0,64(sp)
ffffffffc0200a8c:	74e2                	ld	s1,56(sp)
ffffffffc0200a8e:	7942                	ld	s2,48(sp)
ffffffffc0200a90:	79a2                	ld	s3,40(sp)
ffffffffc0200a92:	7a02                	ld	s4,32(sp)
ffffffffc0200a94:	6ae2                	ld	s5,24(sp)
ffffffffc0200a96:	6b42                	ld	s6,16(sp)
ffffffffc0200a98:	6ba2                	ld	s7,8(sp)
ffffffffc0200a9a:	6c02                	ld	s8,0(sp)
ffffffffc0200a9c:	6161                	addi	sp,sp,80
ffffffffc0200a9e:	8082                	ret
            base->property += 1;
ffffffffc0200aa0:	2605                	addiw	a2,a2,1
ffffffffc0200aa2:	c810                	sw	a2,16(s0)
ffffffffc0200aa4:	ff070793          	addi	a5,a4,-16
ffffffffc0200aa8:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200aac:	6314                	ld	a3,0(a4)
ffffffffc0200aae:	6718                	ld	a4,8(a4)
            free_area1[order].nr_free -= 2;
ffffffffc0200ab0:	489c                	lw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200ab2:	000a8a1b          	sext.w	s4,s5
    prev->next = next;
ffffffffc0200ab6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200ab8:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200aba:	6c14                	ld	a3,24(s0)
ffffffffc0200abc:	7018                	ld	a4,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200abe:	37f9                	addiw	a5,a5,-2
            add_page(base,order+1);
ffffffffc0200ac0:	85d2                	mv	a1,s4
    prev->next = next;
ffffffffc0200ac2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200ac4:	e314                	sd	a3,0(a4)
            free_area1[order].nr_free -= 2;
ffffffffc0200ac6:	c89c                	sw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200ac8:	8522                	mv	a0,s0
ffffffffc0200aca:	e13ff0ef          	jal	ra,ffffffffc02008dc <add_page>
            free_area1[order].nr_free += 1;
ffffffffc0200ace:	489c                	lw	a5,16(s1)
ffffffffc0200ad0:	2785                	addiw	a5,a5,1
ffffffffc0200ad2:	c89c                	sw	a5,16(s1)
    if(has_merge == 1) //成功merge则递归调用上一级merge
ffffffffc0200ad4:	b761                	j	ffffffffc0200a5c <default_free_pages.part.0+0xfe>
    while(n!=(1<<order))
ffffffffc0200ad6:	4781                	li	a5,0
ffffffffc0200ad8:	b5e5                	j	ffffffffc02009c0 <default_free_pages.part.0+0x62>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ada:	00001697          	auipc	a3,0x1
ffffffffc0200ade:	15e68693          	addi	a3,a3,350 # ffffffffc0201c38 <commands+0x4f8>
ffffffffc0200ae2:	00001617          	auipc	a2,0x1
ffffffffc0200ae6:	17e60613          	addi	a2,a2,382 # ffffffffc0201c60 <commands+0x520>
ffffffffc0200aea:	0eb00593          	li	a1,235
ffffffffc0200aee:	00001517          	auipc	a0,0x1
ffffffffc0200af2:	18a50513          	addi	a0,a0,394 # ffffffffc0201c78 <commands+0x538>
ffffffffc0200af6:	8b7ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200afa <default_free_pages>:
    assert(n > 0);
ffffffffc0200afa:	c191                	beqz	a1,ffffffffc0200afe <default_free_pages+0x4>
ffffffffc0200afc:	b58d                	j	ffffffffc020095e <default_free_pages.part.0>
default_free_pages(struct Page *base, size_t n) {
ffffffffc0200afe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200b00:	00001697          	auipc	a3,0x1
ffffffffc0200b04:	19068693          	addi	a3,a3,400 # ffffffffc0201c90 <commands+0x550>
ffffffffc0200b08:	00001617          	auipc	a2,0x1
ffffffffc0200b0c:	15860613          	addi	a2,a2,344 # ffffffffc0201c60 <commands+0x520>
ffffffffc0200b10:	0e800593          	li	a1,232
ffffffffc0200b14:	00001517          	auipc	a0,0x1
ffffffffc0200b18:	16450513          	addi	a0,a0,356 # ffffffffc0201c78 <commands+0x538>
default_free_pages(struct Page *base, size_t n) {
ffffffffc0200b1c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b1e:	88fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b22 <default_alloc_pages.part.0>:
default_alloc_pages(size_t n) {
ffffffffc0200b22:	7179                	addi	sp,sp,-48
ffffffffc0200b24:	f406                	sd	ra,40(sp)
ffffffffc0200b26:	f022                	sd	s0,32(sp)
ffffffffc0200b28:	ec26                	sd	s1,24(sp)
ffffffffc0200b2a:	e84a                	sd	s2,16(sp)
ffffffffc0200b2c:	e44e                	sd	s3,8(sp)
    while (n > (1 << (order))) {
ffffffffc0200b2e:	4785                	li	a5,1
ffffffffc0200b30:	0ca7f763          	bgeu	a5,a0,ffffffffc0200bfe <default_alloc_pages.part.0+0xdc>
     int order=0;
ffffffffc0200b34:	4401                	li	s0,0
    while (n > (1 << (order))) {
ffffffffc0200b36:	4705                	li	a4,1
        order++;
ffffffffc0200b38:	2405                	addiw	s0,s0,1
    while (n > (1 << (order))) {
ffffffffc0200b3a:	008717bb          	sllw	a5,a4,s0
ffffffffc0200b3e:	fea7ede3          	bltu	a5,a0,ffffffffc0200b38 <default_alloc_pages.part.0+0x16>
    for (;i<=MAX_ORDER;i++)
ffffffffc0200b42:	47b9                	li	a5,14
ffffffffc0200b44:	0887c163          	blt	a5,s0,ffffffffc0200bc6 <default_alloc_pages.part.0+0xa4>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200b48:	00141493          	slli	s1,s0,0x1
ffffffffc0200b4c:	008485b3          	add	a1,s1,s0
ffffffffc0200b50:	00005917          	auipc	s2,0x5
ffffffffc0200b54:	4c090913          	addi	s2,s2,1216 # ffffffffc0206010 <free_area1>
ffffffffc0200b58:	058e                	slli	a1,a1,0x3
ffffffffc0200b5a:	95ca                	add	a1,a1,s2
ffffffffc0200b5c:	008487b3          	add	a5,s1,s0
ffffffffc0200b60:	078e                	slli	a5,a5,0x3
ffffffffc0200b62:	97ca                	add	a5,a5,s2
     int order=0;
ffffffffc0200b64:	8722                	mv	a4,s0
    for (;i<=MAX_ORDER;i++)
ffffffffc0200b66:	463d                	li	a2,15
ffffffffc0200b68:	a021                	j	ffffffffc0200b70 <default_alloc_pages.part.0+0x4e>
ffffffffc0200b6a:	07e1                	addi	a5,a5,24
ffffffffc0200b6c:	04c70563          	beq	a4,a2,ffffffffc0200bb6 <default_alloc_pages.part.0+0x94>
        if(!list_empty(&(free_area1[i].free_list)))
ffffffffc0200b70:	6794                	ld	a3,8(a5)
    for (;i<=MAX_ORDER;i++)
ffffffffc0200b72:	2705                	addiw	a4,a4,1
        if(!list_empty(&(free_area1[i].free_list)))
ffffffffc0200b74:	fef68be3          	beq	a3,a5,ffffffffc0200b6a <default_alloc_pages.part.0+0x48>
    return list->next == list;
ffffffffc0200b78:	008489b3          	add	s3,s1,s0
ffffffffc0200b7c:	098e                	slli	s3,s3,0x3
ffffffffc0200b7e:	99ca                	add	s3,s3,s2
ffffffffc0200b80:	0089b783          	ld	a5,8(s3)
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200b84:	06b78663          	beq	a5,a1,ffffffffc0200bf0 <default_alloc_pages.part.0+0xce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b88:	6798                	ld	a4,8(a5)
ffffffffc0200b8a:	6394                	ld	a3,0(a5)
    page= le2page(le, page_link);
ffffffffc0200b8c:	fe878513          	addi	a0,a5,-24
ffffffffc0200b90:	17c1                	addi	a5,a5,-16
    prev->next = next;
ffffffffc0200b92:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200b94:	e314                	sd	a3,0(a4)
ffffffffc0200b96:	5775                	li	a4,-3
ffffffffc0200b98:	60e7b02f          	amoand.d	zero,a4,(a5)
    free_area1[order].nr_free-=1;
ffffffffc0200b9c:	9426                	add	s0,s0,s1
ffffffffc0200b9e:	040e                	slli	s0,s0,0x3
ffffffffc0200ba0:	944a                	add	s0,s0,s2
ffffffffc0200ba2:	481c                	lw	a5,16(s0)
}
ffffffffc0200ba4:	70a2                	ld	ra,40(sp)
ffffffffc0200ba6:	64e2                	ld	s1,24(sp)
    free_area1[order].nr_free-=1;
ffffffffc0200ba8:	37fd                	addiw	a5,a5,-1
ffffffffc0200baa:	c81c                	sw	a5,16(s0)
}
ffffffffc0200bac:	7402                	ld	s0,32(sp)
ffffffffc0200bae:	6942                	ld	s2,16(sp)
ffffffffc0200bb0:	69a2                	ld	s3,8(sp)
ffffffffc0200bb2:	6145                	addi	sp,sp,48
ffffffffc0200bb4:	8082                	ret
ffffffffc0200bb6:	70a2                	ld	ra,40(sp)
ffffffffc0200bb8:	7402                	ld	s0,32(sp)
ffffffffc0200bba:	64e2                	ld	s1,24(sp)
ffffffffc0200bbc:	6942                	ld	s2,16(sp)
ffffffffc0200bbe:	69a2                	ld	s3,8(sp)
        return NULL;
ffffffffc0200bc0:	4501                	li	a0,0
}
ffffffffc0200bc2:	6145                	addi	sp,sp,48
ffffffffc0200bc4:	8082                	ret
    if(i==MAX_ORDER+1)
ffffffffc0200bc6:	47bd                	li	a5,15
ffffffffc0200bc8:	fef407e3          	beq	s0,a5,ffffffffc0200bb6 <default_alloc_pages.part.0+0x94>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200bcc:	00141493          	slli	s1,s0,0x1
    return list->next == list;
ffffffffc0200bd0:	008489b3          	add	s3,s1,s0
ffffffffc0200bd4:	00005917          	auipc	s2,0x5
ffffffffc0200bd8:	43c90913          	addi	s2,s2,1084 # ffffffffc0206010 <free_area1>
ffffffffc0200bdc:	098e                	slli	s3,s3,0x3
ffffffffc0200bde:	99ca                	add	s3,s3,s2
ffffffffc0200be0:	008485b3          	add	a1,s1,s0
ffffffffc0200be4:	0089b783          	ld	a5,8(s3)
ffffffffc0200be8:	058e                	slli	a1,a1,0x3
ffffffffc0200bea:	95ca                	add	a1,a1,s2
ffffffffc0200bec:	f8b79ee3          	bne	a5,a1,ffffffffc0200b88 <default_alloc_pages.part.0+0x66>
         split_page(order + 1);
ffffffffc0200bf0:	0014051b          	addiw	a0,s0,1
ffffffffc0200bf4:	c2fff0ef          	jal	ra,ffffffffc0200822 <split_page>
    return listelm->next;
ffffffffc0200bf8:	0089b783          	ld	a5,8(s3)
ffffffffc0200bfc:	b771                	j	ffffffffc0200b88 <default_alloc_pages.part.0+0x66>
    while (n > (1 << (order))) {
ffffffffc0200bfe:	00005917          	auipc	s2,0x5
ffffffffc0200c02:	41290913          	addi	s2,s2,1042 # ffffffffc0206010 <free_area1>
ffffffffc0200c06:	85ca                	mv	a1,s2
     int order=0;
ffffffffc0200c08:	4401                	li	s0,0
ffffffffc0200c0a:	4481                	li	s1,0
ffffffffc0200c0c:	bf81                	j	ffffffffc0200b5c <default_alloc_pages.part.0+0x3a>

ffffffffc0200c0e <default_alloc_pages>:
    assert(n > 0);
ffffffffc0200c0e:	c519                	beqz	a0,ffffffffc0200c1c <default_alloc_pages+0xe>
    if (n > (1 << (MAX_ORDER))) {
ffffffffc0200c10:	6711                	lui	a4,0x4
ffffffffc0200c12:	00a76363          	bltu	a4,a0,ffffffffc0200c18 <default_alloc_pages+0xa>
ffffffffc0200c16:	b731                	j	ffffffffc0200b22 <default_alloc_pages.part.0>
}
ffffffffc0200c18:	4501                	li	a0,0
ffffffffc0200c1a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0200c1c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c1e:	00001697          	auipc	a3,0x1
ffffffffc0200c22:	07268693          	addi	a3,a3,114 # ffffffffc0201c90 <commands+0x550>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	03a60613          	addi	a2,a2,58 # ffffffffc0201c60 <commands+0x520>
ffffffffc0200c2e:	07b00593          	li	a1,123
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	04650513          	addi	a0,a0,70 # ffffffffc0201c78 <commands+0x538>
default_alloc_pages(size_t n) {
ffffffffc0200c3a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c3c:	f70ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c40 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200c40:	715d                	addi	sp,sp,-80
ffffffffc0200c42:	fc26                	sd	s1,56(sp)
    cprintf("Starting buddy_system_basic_check...\n");
ffffffffc0200c44:	00001517          	auipc	a0,0x1
ffffffffc0200c48:	05450513          	addi	a0,a0,84 # ffffffffc0201c98 <commands+0x558>
ffffffffc0200c4c:	00005497          	auipc	s1,0x5
ffffffffc0200c50:	3d448493          	addi	s1,s1,980 # ffffffffc0206020 <free_area1+0x10>
default_check(void) {
ffffffffc0200c54:	e0a2                	sd	s0,64(sp)
ffffffffc0200c56:	f84a                	sd	s2,48(sp)
ffffffffc0200c58:	f44e                	sd	s3,40(sp)
ffffffffc0200c5a:	f052                	sd	s4,32(sp)
ffffffffc0200c5c:	e486                	sd	ra,72(sp)
ffffffffc0200c5e:	ec56                	sd	s5,24(sp)
ffffffffc0200c60:	e85a                	sd	s6,16(sp)
ffffffffc0200c62:	e45e                	sd	s7,8(sp)
    cprintf("Starting buddy_system_basic_check...\n");
ffffffffc0200c64:	8926                	mv	s2,s1
ffffffffc0200c66:	c4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200c6a:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200c6c:	00001a17          	auipc	s4,0x1
ffffffffc0200c70:	054a0a13          	addi	s4,s4,84 # ffffffffc0201cc0 <commands+0x580>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200c74:	49bd                	li	s3,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200c76:	00092603          	lw	a2,0(s2)
ffffffffc0200c7a:	85a2                	mv	a1,s0
ffffffffc0200c7c:	8552                	mv	a0,s4
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200c7e:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200c80:	c32ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200c84:	0961                	addi	s2,s2,24
ffffffffc0200c86:	ff3418e3          	bne	s0,s3,ffffffffc0200c76 <default_check+0x36>
    if (n > (1 << (MAX_ORDER))) {
ffffffffc0200c8a:	4521                	li	a0,8
ffffffffc0200c8c:	e97ff0ef          	jal	ra,ffffffffc0200b22 <default_alloc_pages.part.0>
ffffffffc0200c90:	8aaa                	mv	s5,a0
ffffffffc0200c92:	4521                	li	a0,8
ffffffffc0200c94:	e8fff0ef          	jal	ra,ffffffffc0200b22 <default_alloc_pages.part.0>
ffffffffc0200c98:	8baa                	mv	s7,a0
ffffffffc0200c9a:	4521                	li	a0,8
ffffffffc0200c9c:	e87ff0ef          	jal	ra,ffffffffc0200b22 <default_alloc_pages.part.0>
ffffffffc0200ca0:	8b2a                	mv	s6,a0
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200ca2:	00005917          	auipc	s2,0x5
ffffffffc0200ca6:	37e90913          	addi	s2,s2,894 # ffffffffc0206020 <free_area1+0x10>
ffffffffc0200caa:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200cac:	00001a17          	auipc	s4,0x1
ffffffffc0200cb0:	014a0a13          	addi	s4,s4,20 # ffffffffc0201cc0 <commands+0x580>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cb4:	49bd                	li	s3,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200cb6:	00092603          	lw	a2,0(s2)
ffffffffc0200cba:	85a2                	mv	a1,s0
ffffffffc0200cbc:	8552                	mv	a0,s4
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cbe:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200cc0:	bf2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cc4:	0961                	addi	s2,s2,24
ffffffffc0200cc6:	ff3418e3          	bne	s0,s3,ffffffffc0200cb6 <default_check+0x76>
    assert(n > 0);
ffffffffc0200cca:	45a1                	li	a1,8
ffffffffc0200ccc:	855e                	mv	a0,s7
ffffffffc0200cce:	c91ff0ef          	jal	ra,ffffffffc020095e <default_free_pages.part.0>
ffffffffc0200cd2:	45a1                	li	a1,8
ffffffffc0200cd4:	855a                	mv	a0,s6
ffffffffc0200cd6:	c89ff0ef          	jal	ra,ffffffffc020095e <default_free_pages.part.0>
ffffffffc0200cda:	45a1                	li	a1,8
ffffffffc0200cdc:	8556                	mv	a0,s5
ffffffffc0200cde:	c81ff0ef          	jal	ra,ffffffffc020095e <default_free_pages.part.0>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200ce2:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200ce4:	00001997          	auipc	s3,0x1
ffffffffc0200ce8:	fdc98993          	addi	s3,s3,-36 # ffffffffc0201cc0 <commands+0x580>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cec:	493d                	li	s2,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200cee:	4090                	lw	a2,0(s1)
ffffffffc0200cf0:	85a2                	mv	a1,s0
ffffffffc0200cf2:	854e                	mv	a0,s3
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cf4:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200cf6:	bbcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200cfa:	04e1                	addi	s1,s1,24
ffffffffc0200cfc:	ff2419e3          	bne	s0,s2,ffffffffc0200cee <default_check+0xae>
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
ffffffffc0200d00:	60a6                	ld	ra,72(sp)
ffffffffc0200d02:	6406                	ld	s0,64(sp)
ffffffffc0200d04:	74e2                	ld	s1,56(sp)
ffffffffc0200d06:	7942                	ld	s2,48(sp)
ffffffffc0200d08:	79a2                	ld	s3,40(sp)
ffffffffc0200d0a:	7a02                	ld	s4,32(sp)
ffffffffc0200d0c:	6ae2                	ld	s5,24(sp)
ffffffffc0200d0e:	6b42                	ld	s6,16(sp)
ffffffffc0200d10:	6ba2                	ld	s7,8(sp)
ffffffffc0200d12:	6161                	addi	sp,sp,80
ffffffffc0200d14:	8082                	ret

ffffffffc0200d16 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d16:	1101                	addi	sp,sp,-32
ffffffffc0200d18:	ec06                	sd	ra,24(sp)
ffffffffc0200d1a:	e822                	sd	s0,16(sp)
ffffffffc0200d1c:	e426                	sd	s1,8(sp)
ffffffffc0200d1e:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200d20:	c1e1                	beqz	a1,ffffffffc0200de0 <default_init_memmap+0xca>
    for (; p != base + n; p ++) {
ffffffffc0200d22:	00259693          	slli	a3,a1,0x2
ffffffffc0200d26:	96ae                	add	a3,a3,a1
ffffffffc0200d28:	068e                	slli	a3,a3,0x3
ffffffffc0200d2a:	96aa                	add	a3,a3,a0
ffffffffc0200d2c:	842e                	mv	s0,a1
ffffffffc0200d2e:	892a                	mv	s2,a0
ffffffffc0200d30:	87aa                	mv	a5,a0
ffffffffc0200d32:	00a68f63          	beq	a3,a0,ffffffffc0200d50 <default_init_memmap+0x3a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d36:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d38:	8b05                	andi	a4,a4,1
ffffffffc0200d3a:	c359                	beqz	a4,ffffffffc0200dc0 <default_init_memmap+0xaa>
        p->flags = p->property = 0;
ffffffffc0200d3c:	0007a823          	sw	zero,16(a5)
ffffffffc0200d40:	0007b423          	sd	zero,8(a5)
ffffffffc0200d44:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d48:	02878793          	addi	a5,a5,40
ffffffffc0200d4c:	fef695e3          	bne	a3,a5,ffffffffc0200d36 <default_init_memmap+0x20>
        int order=0;//jie shu
ffffffffc0200d50:	4781                	li	a5,0
        while (remain >= (1 << (order))) {
ffffffffc0200d52:	4685                	li	a3,1
        order++;
ffffffffc0200d54:	84be                	mv	s1,a5
ffffffffc0200d56:	2785                	addiw	a5,a5,1
        while (remain >= (1 << (order))) {
ffffffffc0200d58:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200d5c:	fee47ce3          	bgeu	s0,a4,ffffffffc0200d54 <default_init_memmap+0x3e>
    cprintf("The value of i is %d\n", order);
ffffffffc0200d60:	85a6                	mv	a1,s1
ffffffffc0200d62:	00001517          	auipc	a0,0x1
ffffffffc0200d66:	f8650513          	addi	a0,a0,-122 # ffffffffc0201ce8 <commands+0x5a8>
ffffffffc0200d6a:	b48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
     cprintf("The value of n is %d\n", n);
ffffffffc0200d6e:	85a2                	mv	a1,s0
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	f9050513          	addi	a0,a0,-112 # ffffffffc0201d00 <commands+0x5c0>
ffffffffc0200d78:	b3aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d7c:	4789                	li	a5,2
    p->property=order;
ffffffffc0200d7e:	00992823          	sw	s1,16(s2)
ffffffffc0200d82:	00890713          	addi	a4,s2,8
ffffffffc0200d86:	40f7302f          	amoor.d	zero,a5,(a4)
    free_area1[order].nr_free+=1;
ffffffffc0200d8a:	00149793          	slli	a5,s1,0x1
ffffffffc0200d8e:	94be                	add	s1,s1,a5
ffffffffc0200d90:	048e                	slli	s1,s1,0x3
ffffffffc0200d92:	00005797          	auipc	a5,0x5
ffffffffc0200d96:	27e78793          	addi	a5,a5,638 # ffffffffc0206010 <free_area1>
ffffffffc0200d9a:	97a6                	add	a5,a5,s1
ffffffffc0200d9c:	4b98                	lw	a4,16(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d9e:	6794                	ld	a3,8(a5)
    list_add(&(free_area1[order].free_list), &(p->page_link));
ffffffffc0200da0:	01890613          	addi	a2,s2,24
    free_area1[order].nr_free+=1;
ffffffffc0200da4:	2705                	addiw	a4,a4,1
ffffffffc0200da6:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200da8:	e290                	sd	a2,0(a3)
}
ffffffffc0200daa:	60e2                	ld	ra,24(sp)
ffffffffc0200dac:	6442                	ld	s0,16(sp)
ffffffffc0200dae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200db0:	02d93023          	sd	a3,32(s2)
    elm->prev = prev;
ffffffffc0200db4:	00f93c23          	sd	a5,24(s2)
ffffffffc0200db8:	64a2                	ld	s1,8(sp)
ffffffffc0200dba:	6902                	ld	s2,0(sp)
ffffffffc0200dbc:	6105                	addi	sp,sp,32
ffffffffc0200dbe:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200dc0:	00001697          	auipc	a3,0x1
ffffffffc0200dc4:	f1868693          	addi	a3,a3,-232 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200dc8:	00001617          	auipc	a2,0x1
ffffffffc0200dcc:	e9860613          	addi	a2,a2,-360 # ffffffffc0201c60 <commands+0x520>
ffffffffc0200dd0:	04c00593          	li	a1,76
ffffffffc0200dd4:	00001517          	auipc	a0,0x1
ffffffffc0200dd8:	ea450513          	addi	a0,a0,-348 # ffffffffc0201c78 <commands+0x538>
ffffffffc0200ddc:	dd0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200de0:	00001697          	auipc	a3,0x1
ffffffffc0200de4:	eb068693          	addi	a3,a3,-336 # ffffffffc0201c90 <commands+0x550>
ffffffffc0200de8:	00001617          	auipc	a2,0x1
ffffffffc0200dec:	e7860613          	addi	a2,a2,-392 # ffffffffc0201c60 <commands+0x520>
ffffffffc0200df0:	04900593          	li	a1,73
ffffffffc0200df4:	00001517          	auipc	a0,0x1
ffffffffc0200df8:	e8450513          	addi	a0,a0,-380 # ffffffffc0201c78 <commands+0x538>
ffffffffc0200dfc:	db0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e00 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;
ffffffffc0200e00:	00001797          	auipc	a5,0x1
ffffffffc0200e04:	f3078793          	addi	a5,a5,-208 # ffffffffc0201d30 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e08:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e0a:	1101                	addi	sp,sp,-32
ffffffffc0200e0c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e0e:	00001517          	auipc	a0,0x1
ffffffffc0200e12:	f5a50513          	addi	a0,a0,-166 # ffffffffc0201d68 <default_pmm_manager+0x38>
    pmm_manager = &default_pmm_manager;
ffffffffc0200e16:	00005497          	auipc	s1,0x5
ffffffffc0200e1a:	78248493          	addi	s1,s1,1922 # ffffffffc0206598 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e1e:	ec06                	sd	ra,24(sp)
ffffffffc0200e20:	e822                	sd	s0,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200e22:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e24:	a8eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200e28:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e2a:	00005417          	auipc	s0,0x5
ffffffffc0200e2e:	78640413          	addi	s0,s0,1926 # ffffffffc02065b0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200e32:	679c                	ld	a5,8(a5)
ffffffffc0200e34:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e36:	57f5                	li	a5,-3
ffffffffc0200e38:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200e3a:	00001517          	auipc	a0,0x1
ffffffffc0200e3e:	f4650513          	addi	a0,a0,-186 # ffffffffc0201d80 <default_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e42:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200e44:	a6eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200e48:	46c5                	li	a3,17
ffffffffc0200e4a:	06ee                	slli	a3,a3,0x1b
ffffffffc0200e4c:	40100613          	li	a2,1025
ffffffffc0200e50:	16fd                	addi	a3,a3,-1
ffffffffc0200e52:	07e005b7          	lui	a1,0x7e00
ffffffffc0200e56:	0656                	slli	a2,a2,0x15
ffffffffc0200e58:	00001517          	auipc	a0,0x1
ffffffffc0200e5c:	f4050513          	addi	a0,a0,-192 # ffffffffc0201d98 <default_pmm_manager+0x68>
ffffffffc0200e60:	a52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e64:	777d                	lui	a4,0xfffff
ffffffffc0200e66:	00006797          	auipc	a5,0x6
ffffffffc0200e6a:	75978793          	addi	a5,a5,1881 # ffffffffc02075bf <end+0xfff>
ffffffffc0200e6e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200e70:	00005517          	auipc	a0,0x5
ffffffffc0200e74:	71850513          	addi	a0,a0,1816 # ffffffffc0206588 <npage>
ffffffffc0200e78:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e7c:	00005597          	auipc	a1,0x5
ffffffffc0200e80:	71458593          	addi	a1,a1,1812 # ffffffffc0206590 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e84:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e86:	e19c                	sd	a5,0(a1)
ffffffffc0200e88:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e8a:	4701                	li	a4,0
ffffffffc0200e8c:	4885                	li	a7,1
ffffffffc0200e8e:	fff80837          	lui	a6,0xfff80
ffffffffc0200e92:	a011                	j	ffffffffc0200e96 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200e94:	619c                	ld	a5,0(a1)
ffffffffc0200e96:	97b6                	add	a5,a5,a3
ffffffffc0200e98:	07a1                	addi	a5,a5,8
ffffffffc0200e9a:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e9e:	611c                	ld	a5,0(a0)
ffffffffc0200ea0:	0705                	addi	a4,a4,1
ffffffffc0200ea2:	02868693          	addi	a3,a3,40
ffffffffc0200ea6:	01078633          	add	a2,a5,a6
ffffffffc0200eaa:	fec765e3          	bltu	a4,a2,ffffffffc0200e94 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200eae:	6190                	ld	a2,0(a1)
ffffffffc0200eb0:	00279713          	slli	a4,a5,0x2
ffffffffc0200eb4:	973e                	add	a4,a4,a5
ffffffffc0200eb6:	fec006b7          	lui	a3,0xfec00
ffffffffc0200eba:	070e                	slli	a4,a4,0x3
ffffffffc0200ebc:	96b2                	add	a3,a3,a2
ffffffffc0200ebe:	96ba                	add	a3,a3,a4
ffffffffc0200ec0:	c0200737          	lui	a4,0xc0200
ffffffffc0200ec4:	08e6ef63          	bltu	a3,a4,ffffffffc0200f62 <pmm_init+0x162>
ffffffffc0200ec8:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200eca:	45c5                	li	a1,17
ffffffffc0200ecc:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ece:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200ed0:	04b6e863          	bltu	a3,a1,ffffffffc0200f20 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ed4:	609c                	ld	a5,0(s1)
ffffffffc0200ed6:	7b9c                	ld	a5,48(a5)
ffffffffc0200ed8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200eda:	00001517          	auipc	a0,0x1
ffffffffc0200ede:	f5650513          	addi	a0,a0,-170 # ffffffffc0201e30 <default_pmm_manager+0x100>
ffffffffc0200ee2:	9d0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ee6:	00004597          	auipc	a1,0x4
ffffffffc0200eea:	11a58593          	addi	a1,a1,282 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200eee:	00005797          	auipc	a5,0x5
ffffffffc0200ef2:	6ab7bd23          	sd	a1,1722(a5) # ffffffffc02065a8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ef6:	c02007b7          	lui	a5,0xc0200
ffffffffc0200efa:	08f5e063          	bltu	a1,a5,ffffffffc0200f7a <pmm_init+0x17a>
ffffffffc0200efe:	6010                	ld	a2,0(s0)
}
ffffffffc0200f00:	6442                	ld	s0,16(sp)
ffffffffc0200f02:	60e2                	ld	ra,24(sp)
ffffffffc0200f04:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f06:	40c58633          	sub	a2,a1,a2
ffffffffc0200f0a:	00005797          	auipc	a5,0x5
ffffffffc0200f0e:	68c7bb23          	sd	a2,1686(a5) # ffffffffc02065a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	f3e50513          	addi	a0,a0,-194 # ffffffffc0201e50 <default_pmm_manager+0x120>
}
ffffffffc0200f1a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f1c:	996ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f20:	6705                	lui	a4,0x1
ffffffffc0200f22:	177d                	addi	a4,a4,-1
ffffffffc0200f24:	96ba                	add	a3,a3,a4
ffffffffc0200f26:	777d                	lui	a4,0xfffff
ffffffffc0200f28:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f2a:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200f2e:	00f57e63          	bgeu	a0,a5,ffffffffc0200f4a <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f32:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f34:	982a                	add	a6,a6,a0
ffffffffc0200f36:	00281513          	slli	a0,a6,0x2
ffffffffc0200f3a:	9542                	add	a0,a0,a6
ffffffffc0200f3c:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f3e:	8d95                	sub	a1,a1,a3
ffffffffc0200f40:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f42:	81b1                	srli	a1,a1,0xc
ffffffffc0200f44:	9532                	add	a0,a0,a2
ffffffffc0200f46:	9782                	jalr	a5
}
ffffffffc0200f48:	b771                	j	ffffffffc0200ed4 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	eb660613          	addi	a2,a2,-330 # ffffffffc0201e00 <default_pmm_manager+0xd0>
ffffffffc0200f52:	06b00593          	li	a1,107
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	eca50513          	addi	a0,a0,-310 # ffffffffc0201e20 <default_pmm_manager+0xf0>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	e6660613          	addi	a2,a2,-410 # ffffffffc0201dc8 <default_pmm_manager+0x98>
ffffffffc0200f6a:	06e00593          	li	a1,110
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	e8250513          	addi	a0,a0,-382 # ffffffffc0201df0 <default_pmm_manager+0xc0>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f7a:	86ae                	mv	a3,a1
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	e4c60613          	addi	a2,a2,-436 # ffffffffc0201dc8 <default_pmm_manager+0x98>
ffffffffc0200f84:	08a00593          	li	a1,138
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	e6850513          	addi	a0,a0,-408 # ffffffffc0201df0 <default_pmm_manager+0xc0>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f94 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200f94:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f98:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200f9a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f9e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200fa0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fa4:	f022                	sd	s0,32(sp)
ffffffffc0200fa6:	ec26                	sd	s1,24(sp)
ffffffffc0200fa8:	e84a                	sd	s2,16(sp)
ffffffffc0200faa:	f406                	sd	ra,40(sp)
ffffffffc0200fac:	e44e                	sd	s3,8(sp)
ffffffffc0200fae:	84aa                	mv	s1,a0
ffffffffc0200fb0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200fb2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200fb6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200fb8:	03067e63          	bgeu	a2,a6,ffffffffc0200ff4 <printnum+0x60>
ffffffffc0200fbc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200fbe:	00805763          	blez	s0,ffffffffc0200fcc <printnum+0x38>
ffffffffc0200fc2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200fc4:	85ca                	mv	a1,s2
ffffffffc0200fc6:	854e                	mv	a0,s3
ffffffffc0200fc8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200fca:	fc65                	bnez	s0,ffffffffc0200fc2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fcc:	1a02                	slli	s4,s4,0x20
ffffffffc0200fce:	00001797          	auipc	a5,0x1
ffffffffc0200fd2:	ec278793          	addi	a5,a5,-318 # ffffffffc0201e90 <default_pmm_manager+0x160>
ffffffffc0200fd6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200fda:	9a3e                	add	s4,s4,a5
}
ffffffffc0200fdc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fde:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200fe2:	70a2                	ld	ra,40(sp)
ffffffffc0200fe4:	69a2                	ld	s3,8(sp)
ffffffffc0200fe6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fe8:	85ca                	mv	a1,s2
ffffffffc0200fea:	87a6                	mv	a5,s1
}
ffffffffc0200fec:	6942                	ld	s2,16(sp)
ffffffffc0200fee:	64e2                	ld	s1,24(sp)
ffffffffc0200ff0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ff2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200ff4:	03065633          	divu	a2,a2,a6
ffffffffc0200ff8:	8722                	mv	a4,s0
ffffffffc0200ffa:	f9bff0ef          	jal	ra,ffffffffc0200f94 <printnum>
ffffffffc0200ffe:	b7f9                	j	ffffffffc0200fcc <printnum+0x38>

ffffffffc0201000 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201000:	7119                	addi	sp,sp,-128
ffffffffc0201002:	f4a6                	sd	s1,104(sp)
ffffffffc0201004:	f0ca                	sd	s2,96(sp)
ffffffffc0201006:	ecce                	sd	s3,88(sp)
ffffffffc0201008:	e8d2                	sd	s4,80(sp)
ffffffffc020100a:	e4d6                	sd	s5,72(sp)
ffffffffc020100c:	e0da                	sd	s6,64(sp)
ffffffffc020100e:	fc5e                	sd	s7,56(sp)
ffffffffc0201010:	f06a                	sd	s10,32(sp)
ffffffffc0201012:	fc86                	sd	ra,120(sp)
ffffffffc0201014:	f8a2                	sd	s0,112(sp)
ffffffffc0201016:	f862                	sd	s8,48(sp)
ffffffffc0201018:	f466                	sd	s9,40(sp)
ffffffffc020101a:	ec6e                	sd	s11,24(sp)
ffffffffc020101c:	892a                	mv	s2,a0
ffffffffc020101e:	84ae                	mv	s1,a1
ffffffffc0201020:	8d32                	mv	s10,a2
ffffffffc0201022:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201024:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201028:	5b7d                	li	s6,-1
ffffffffc020102a:	00001a97          	auipc	s5,0x1
ffffffffc020102e:	e9aa8a93          	addi	s5,s5,-358 # ffffffffc0201ec4 <default_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201032:	00001b97          	auipc	s7,0x1
ffffffffc0201036:	06eb8b93          	addi	s7,s7,110 # ffffffffc02020a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020103a:	000d4503          	lbu	a0,0(s10)
ffffffffc020103e:	001d0413          	addi	s0,s10,1
ffffffffc0201042:	01350a63          	beq	a0,s3,ffffffffc0201056 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201046:	c121                	beqz	a0,ffffffffc0201086 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201048:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020104a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020104c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020104e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201052:	ff351ae3          	bne	a0,s3,ffffffffc0201046 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201056:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020105a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020105e:	4c81                	li	s9,0
ffffffffc0201060:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201062:	5c7d                	li	s8,-1
ffffffffc0201064:	5dfd                	li	s11,-1
ffffffffc0201066:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020106a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020106c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201070:	0ff5f593          	zext.b	a1,a1
ffffffffc0201074:	00140d13          	addi	s10,s0,1
ffffffffc0201078:	04b56263          	bltu	a0,a1,ffffffffc02010bc <vprintfmt+0xbc>
ffffffffc020107c:	058a                	slli	a1,a1,0x2
ffffffffc020107e:	95d6                	add	a1,a1,s5
ffffffffc0201080:	4194                	lw	a3,0(a1)
ffffffffc0201082:	96d6                	add	a3,a3,s5
ffffffffc0201084:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201086:	70e6                	ld	ra,120(sp)
ffffffffc0201088:	7446                	ld	s0,112(sp)
ffffffffc020108a:	74a6                	ld	s1,104(sp)
ffffffffc020108c:	7906                	ld	s2,96(sp)
ffffffffc020108e:	69e6                	ld	s3,88(sp)
ffffffffc0201090:	6a46                	ld	s4,80(sp)
ffffffffc0201092:	6aa6                	ld	s5,72(sp)
ffffffffc0201094:	6b06                	ld	s6,64(sp)
ffffffffc0201096:	7be2                	ld	s7,56(sp)
ffffffffc0201098:	7c42                	ld	s8,48(sp)
ffffffffc020109a:	7ca2                	ld	s9,40(sp)
ffffffffc020109c:	7d02                	ld	s10,32(sp)
ffffffffc020109e:	6de2                	ld	s11,24(sp)
ffffffffc02010a0:	6109                	addi	sp,sp,128
ffffffffc02010a2:	8082                	ret
            padc = '0';
ffffffffc02010a4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02010a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010aa:	846a                	mv	s0,s10
ffffffffc02010ac:	00140d13          	addi	s10,s0,1
ffffffffc02010b0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010b4:	0ff5f593          	zext.b	a1,a1
ffffffffc02010b8:	fcb572e3          	bgeu	a0,a1,ffffffffc020107c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02010bc:	85a6                	mv	a1,s1
ffffffffc02010be:	02500513          	li	a0,37
ffffffffc02010c2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02010c4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02010c8:	8d22                	mv	s10,s0
ffffffffc02010ca:	f73788e3          	beq	a5,s3,ffffffffc020103a <vprintfmt+0x3a>
ffffffffc02010ce:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02010d2:	1d7d                	addi	s10,s10,-1
ffffffffc02010d4:	ff379de3          	bne	a5,s3,ffffffffc02010ce <vprintfmt+0xce>
ffffffffc02010d8:	b78d                	j	ffffffffc020103a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02010da:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02010de:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010e2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02010e4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02010e8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010ec:	02d86463          	bltu	a6,a3,ffffffffc0201114 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02010f0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02010f4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02010f8:	0186873b          	addw	a4,a3,s8
ffffffffc02010fc:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201100:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201102:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201106:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201108:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020110c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201110:	fed870e3          	bgeu	a6,a3,ffffffffc02010f0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201114:	f40ddce3          	bgez	s11,ffffffffc020106c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201118:	8de2                	mv	s11,s8
ffffffffc020111a:	5c7d                	li	s8,-1
ffffffffc020111c:	bf81                	j	ffffffffc020106c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020111e:	fffdc693          	not	a3,s11
ffffffffc0201122:	96fd                	srai	a3,a3,0x3f
ffffffffc0201124:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201128:	00144603          	lbu	a2,1(s0)
ffffffffc020112c:	2d81                	sext.w	s11,s11
ffffffffc020112e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201130:	bf35                	j	ffffffffc020106c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201132:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201136:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020113a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020113c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020113e:	bfd9                	j	ffffffffc0201114 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201140:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201142:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201146:	01174463          	blt	a4,a7,ffffffffc020114e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020114a:	1a088e63          	beqz	a7,ffffffffc0201306 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020114e:	000a3603          	ld	a2,0(s4)
ffffffffc0201152:	46c1                	li	a3,16
ffffffffc0201154:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201156:	2781                	sext.w	a5,a5
ffffffffc0201158:	876e                	mv	a4,s11
ffffffffc020115a:	85a6                	mv	a1,s1
ffffffffc020115c:	854a                	mv	a0,s2
ffffffffc020115e:	e37ff0ef          	jal	ra,ffffffffc0200f94 <printnum>
            break;
ffffffffc0201162:	bde1                	j	ffffffffc020103a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201164:	000a2503          	lw	a0,0(s4)
ffffffffc0201168:	85a6                	mv	a1,s1
ffffffffc020116a:	0a21                	addi	s4,s4,8
ffffffffc020116c:	9902                	jalr	s2
            break;
ffffffffc020116e:	b5f1                	j	ffffffffc020103a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201170:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201172:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201176:	01174463          	blt	a4,a7,ffffffffc020117e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020117a:	18088163          	beqz	a7,ffffffffc02012fc <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020117e:	000a3603          	ld	a2,0(s4)
ffffffffc0201182:	46a9                	li	a3,10
ffffffffc0201184:	8a2e                	mv	s4,a1
ffffffffc0201186:	bfc1                	j	ffffffffc0201156 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201188:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020118c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020118e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201190:	bdf1                	j	ffffffffc020106c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201192:	85a6                	mv	a1,s1
ffffffffc0201194:	02500513          	li	a0,37
ffffffffc0201198:	9902                	jalr	s2
            break;
ffffffffc020119a:	b545                	j	ffffffffc020103a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02011a0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011a4:	b5e1                	j	ffffffffc020106c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02011a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011ac:	01174463          	blt	a4,a7,ffffffffc02011b4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02011b0:	14088163          	beqz	a7,ffffffffc02012f2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02011b4:	000a3603          	ld	a2,0(s4)
ffffffffc02011b8:	46a1                	li	a3,8
ffffffffc02011ba:	8a2e                	mv	s4,a1
ffffffffc02011bc:	bf69                	j	ffffffffc0201156 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02011be:	03000513          	li	a0,48
ffffffffc02011c2:	85a6                	mv	a1,s1
ffffffffc02011c4:	e03e                	sd	a5,0(sp)
ffffffffc02011c6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02011c8:	85a6                	mv	a1,s1
ffffffffc02011ca:	07800513          	li	a0,120
ffffffffc02011ce:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011d0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02011d2:	6782                	ld	a5,0(sp)
ffffffffc02011d4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011d6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02011da:	bfb5                	j	ffffffffc0201156 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02011dc:	000a3403          	ld	s0,0(s4)
ffffffffc02011e0:	008a0713          	addi	a4,s4,8
ffffffffc02011e4:	e03a                	sd	a4,0(sp)
ffffffffc02011e6:	14040263          	beqz	s0,ffffffffc020132a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02011ea:	0fb05763          	blez	s11,ffffffffc02012d8 <vprintfmt+0x2d8>
ffffffffc02011ee:	02d00693          	li	a3,45
ffffffffc02011f2:	0cd79163          	bne	a5,a3,ffffffffc02012b4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011f6:	00044783          	lbu	a5,0(s0)
ffffffffc02011fa:	0007851b          	sext.w	a0,a5
ffffffffc02011fe:	cf85                	beqz	a5,ffffffffc0201236 <vprintfmt+0x236>
ffffffffc0201200:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201204:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201208:	000c4563          	bltz	s8,ffffffffc0201212 <vprintfmt+0x212>
ffffffffc020120c:	3c7d                	addiw	s8,s8,-1
ffffffffc020120e:	036c0263          	beq	s8,s6,ffffffffc0201232 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201212:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201214:	0e0c8e63          	beqz	s9,ffffffffc0201310 <vprintfmt+0x310>
ffffffffc0201218:	3781                	addiw	a5,a5,-32
ffffffffc020121a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201310 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020121e:	03f00513          	li	a0,63
ffffffffc0201222:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201224:	000a4783          	lbu	a5,0(s4)
ffffffffc0201228:	3dfd                	addiw	s11,s11,-1
ffffffffc020122a:	0a05                	addi	s4,s4,1
ffffffffc020122c:	0007851b          	sext.w	a0,a5
ffffffffc0201230:	ffe1                	bnez	a5,ffffffffc0201208 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201232:	01b05963          	blez	s11,ffffffffc0201244 <vprintfmt+0x244>
ffffffffc0201236:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201238:	85a6                	mv	a1,s1
ffffffffc020123a:	02000513          	li	a0,32
ffffffffc020123e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201240:	fe0d9be3          	bnez	s11,ffffffffc0201236 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201244:	6a02                	ld	s4,0(sp)
ffffffffc0201246:	bbd5                	j	ffffffffc020103a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201248:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020124a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020124e:	01174463          	blt	a4,a7,ffffffffc0201256 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201252:	08088d63          	beqz	a7,ffffffffc02012ec <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201256:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020125a:	0a044d63          	bltz	s0,ffffffffc0201314 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020125e:	8622                	mv	a2,s0
ffffffffc0201260:	8a66                	mv	s4,s9
ffffffffc0201262:	46a9                	li	a3,10
ffffffffc0201264:	bdcd                	j	ffffffffc0201156 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201266:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020126a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020126c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020126e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201272:	8fb5                	xor	a5,a5,a3
ffffffffc0201274:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201278:	02d74163          	blt	a4,a3,ffffffffc020129a <vprintfmt+0x29a>
ffffffffc020127c:	00369793          	slli	a5,a3,0x3
ffffffffc0201280:	97de                	add	a5,a5,s7
ffffffffc0201282:	639c                	ld	a5,0(a5)
ffffffffc0201284:	cb99                	beqz	a5,ffffffffc020129a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201286:	86be                	mv	a3,a5
ffffffffc0201288:	00001617          	auipc	a2,0x1
ffffffffc020128c:	c3860613          	addi	a2,a2,-968 # ffffffffc0201ec0 <default_pmm_manager+0x190>
ffffffffc0201290:	85a6                	mv	a1,s1
ffffffffc0201292:	854a                	mv	a0,s2
ffffffffc0201294:	0ce000ef          	jal	ra,ffffffffc0201362 <printfmt>
ffffffffc0201298:	b34d                	j	ffffffffc020103a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020129a:	00001617          	auipc	a2,0x1
ffffffffc020129e:	c1660613          	addi	a2,a2,-1002 # ffffffffc0201eb0 <default_pmm_manager+0x180>
ffffffffc02012a2:	85a6                	mv	a1,s1
ffffffffc02012a4:	854a                	mv	a0,s2
ffffffffc02012a6:	0bc000ef          	jal	ra,ffffffffc0201362 <printfmt>
ffffffffc02012aa:	bb41                	j	ffffffffc020103a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02012ac:	00001417          	auipc	s0,0x1
ffffffffc02012b0:	bfc40413          	addi	s0,s0,-1028 # ffffffffc0201ea8 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012b4:	85e2                	mv	a1,s8
ffffffffc02012b6:	8522                	mv	a0,s0
ffffffffc02012b8:	e43e                	sd	a5,8(sp)
ffffffffc02012ba:	1cc000ef          	jal	ra,ffffffffc0201486 <strnlen>
ffffffffc02012be:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02012c2:	01b05b63          	blez	s11,ffffffffc02012d8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02012c6:	67a2                	ld	a5,8(sp)
ffffffffc02012c8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012cc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02012ce:	85a6                	mv	a1,s1
ffffffffc02012d0:	8552                	mv	a0,s4
ffffffffc02012d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012d4:	fe0d9ce3          	bnez	s11,ffffffffc02012cc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012d8:	00044783          	lbu	a5,0(s0)
ffffffffc02012dc:	00140a13          	addi	s4,s0,1
ffffffffc02012e0:	0007851b          	sext.w	a0,a5
ffffffffc02012e4:	d3a5                	beqz	a5,ffffffffc0201244 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012e6:	05e00413          	li	s0,94
ffffffffc02012ea:	bf39                	j	ffffffffc0201208 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02012ec:	000a2403          	lw	s0,0(s4)
ffffffffc02012f0:	b7ad                	j	ffffffffc020125a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02012f2:	000a6603          	lwu	a2,0(s4)
ffffffffc02012f6:	46a1                	li	a3,8
ffffffffc02012f8:	8a2e                	mv	s4,a1
ffffffffc02012fa:	bdb1                	j	ffffffffc0201156 <vprintfmt+0x156>
ffffffffc02012fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0201300:	46a9                	li	a3,10
ffffffffc0201302:	8a2e                	mv	s4,a1
ffffffffc0201304:	bd89                	j	ffffffffc0201156 <vprintfmt+0x156>
ffffffffc0201306:	000a6603          	lwu	a2,0(s4)
ffffffffc020130a:	46c1                	li	a3,16
ffffffffc020130c:	8a2e                	mv	s4,a1
ffffffffc020130e:	b5a1                	j	ffffffffc0201156 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201310:	9902                	jalr	s2
ffffffffc0201312:	bf09                	j	ffffffffc0201224 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201314:	85a6                	mv	a1,s1
ffffffffc0201316:	02d00513          	li	a0,45
ffffffffc020131a:	e03e                	sd	a5,0(sp)
ffffffffc020131c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020131e:	6782                	ld	a5,0(sp)
ffffffffc0201320:	8a66                	mv	s4,s9
ffffffffc0201322:	40800633          	neg	a2,s0
ffffffffc0201326:	46a9                	li	a3,10
ffffffffc0201328:	b53d                	j	ffffffffc0201156 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020132a:	03b05163          	blez	s11,ffffffffc020134c <vprintfmt+0x34c>
ffffffffc020132e:	02d00693          	li	a3,45
ffffffffc0201332:	f6d79de3          	bne	a5,a3,ffffffffc02012ac <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201336:	00001417          	auipc	s0,0x1
ffffffffc020133a:	b7240413          	addi	s0,s0,-1166 # ffffffffc0201ea8 <default_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020133e:	02800793          	li	a5,40
ffffffffc0201342:	02800513          	li	a0,40
ffffffffc0201346:	00140a13          	addi	s4,s0,1
ffffffffc020134a:	bd6d                	j	ffffffffc0201204 <vprintfmt+0x204>
ffffffffc020134c:	00001a17          	auipc	s4,0x1
ffffffffc0201350:	b5da0a13          	addi	s4,s4,-1187 # ffffffffc0201ea9 <default_pmm_manager+0x179>
ffffffffc0201354:	02800513          	li	a0,40
ffffffffc0201358:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020135c:	05e00413          	li	s0,94
ffffffffc0201360:	b565                	j	ffffffffc0201208 <vprintfmt+0x208>

ffffffffc0201362 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201362:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201364:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201368:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020136a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020136c:	ec06                	sd	ra,24(sp)
ffffffffc020136e:	f83a                	sd	a4,48(sp)
ffffffffc0201370:	fc3e                	sd	a5,56(sp)
ffffffffc0201372:	e0c2                	sd	a6,64(sp)
ffffffffc0201374:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201376:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201378:	c89ff0ef          	jal	ra,ffffffffc0201000 <vprintfmt>
}
ffffffffc020137c:	60e2                	ld	ra,24(sp)
ffffffffc020137e:	6161                	addi	sp,sp,80
ffffffffc0201380:	8082                	ret

ffffffffc0201382 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201382:	715d                	addi	sp,sp,-80
ffffffffc0201384:	e486                	sd	ra,72(sp)
ffffffffc0201386:	e0a6                	sd	s1,64(sp)
ffffffffc0201388:	fc4a                	sd	s2,56(sp)
ffffffffc020138a:	f84e                	sd	s3,48(sp)
ffffffffc020138c:	f452                	sd	s4,40(sp)
ffffffffc020138e:	f056                	sd	s5,32(sp)
ffffffffc0201390:	ec5a                	sd	s6,24(sp)
ffffffffc0201392:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201394:	c901                	beqz	a0,ffffffffc02013a4 <readline+0x22>
ffffffffc0201396:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201398:	00001517          	auipc	a0,0x1
ffffffffc020139c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0201ec0 <default_pmm_manager+0x190>
ffffffffc02013a0:	d13fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02013a4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013a6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02013a8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02013aa:	4aa9                	li	s5,10
ffffffffc02013ac:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02013ae:	00005b97          	auipc	s7,0x5
ffffffffc02013b2:	dcab8b93          	addi	s7,s7,-566 # ffffffffc0206178 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013b6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02013ba:	d71fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013be:	00054a63          	bltz	a0,ffffffffc02013d2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013c2:	00a95a63          	bge	s2,a0,ffffffffc02013d6 <readline+0x54>
ffffffffc02013c6:	029a5263          	bge	s4,s1,ffffffffc02013ea <readline+0x68>
        c = getchar();
ffffffffc02013ca:	d61fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013ce:	fe055ae3          	bgez	a0,ffffffffc02013c2 <readline+0x40>
            return NULL;
ffffffffc02013d2:	4501                	li	a0,0
ffffffffc02013d4:	a091                	j	ffffffffc0201418 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02013d6:	03351463          	bne	a0,s3,ffffffffc02013fe <readline+0x7c>
ffffffffc02013da:	e8a9                	bnez	s1,ffffffffc020142c <readline+0xaa>
        c = getchar();
ffffffffc02013dc:	d4ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013e0:	fe0549e3          	bltz	a0,ffffffffc02013d2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013e4:	fea959e3          	bge	s2,a0,ffffffffc02013d6 <readline+0x54>
ffffffffc02013e8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02013ea:	e42a                	sd	a0,8(sp)
ffffffffc02013ec:	cfdfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02013f0:	6522                	ld	a0,8(sp)
ffffffffc02013f2:	009b87b3          	add	a5,s7,s1
ffffffffc02013f6:	2485                	addiw	s1,s1,1
ffffffffc02013f8:	00a78023          	sb	a0,0(a5)
ffffffffc02013fc:	bf7d                	j	ffffffffc02013ba <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02013fe:	01550463          	beq	a0,s5,ffffffffc0201406 <readline+0x84>
ffffffffc0201402:	fb651ce3          	bne	a0,s6,ffffffffc02013ba <readline+0x38>
            cputchar(c);
ffffffffc0201406:	ce3fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020140a:	00005517          	auipc	a0,0x5
ffffffffc020140e:	d6e50513          	addi	a0,a0,-658 # ffffffffc0206178 <buf>
ffffffffc0201412:	94aa                	add	s1,s1,a0
ffffffffc0201414:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201418:	60a6                	ld	ra,72(sp)
ffffffffc020141a:	6486                	ld	s1,64(sp)
ffffffffc020141c:	7962                	ld	s2,56(sp)
ffffffffc020141e:	79c2                	ld	s3,48(sp)
ffffffffc0201420:	7a22                	ld	s4,40(sp)
ffffffffc0201422:	7a82                	ld	s5,32(sp)
ffffffffc0201424:	6b62                	ld	s6,24(sp)
ffffffffc0201426:	6bc2                	ld	s7,16(sp)
ffffffffc0201428:	6161                	addi	sp,sp,80
ffffffffc020142a:	8082                	ret
            cputchar(c);
ffffffffc020142c:	4521                	li	a0,8
ffffffffc020142e:	cbbfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201432:	34fd                	addiw	s1,s1,-1
ffffffffc0201434:	b759                	j	ffffffffc02013ba <readline+0x38>

ffffffffc0201436 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201436:	4781                	li	a5,0
ffffffffc0201438:	00005717          	auipc	a4,0x5
ffffffffc020143c:	bd073703          	ld	a4,-1072(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201440:	88ba                	mv	a7,a4
ffffffffc0201442:	852a                	mv	a0,a0
ffffffffc0201444:	85be                	mv	a1,a5
ffffffffc0201446:	863e                	mv	a2,a5
ffffffffc0201448:	00000073          	ecall
ffffffffc020144c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020144e:	8082                	ret

ffffffffc0201450 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201450:	4781                	li	a5,0
ffffffffc0201452:	00005717          	auipc	a4,0x5
ffffffffc0201456:	16673703          	ld	a4,358(a4) # ffffffffc02065b8 <SBI_SET_TIMER>
ffffffffc020145a:	88ba                	mv	a7,a4
ffffffffc020145c:	852a                	mv	a0,a0
ffffffffc020145e:	85be                	mv	a1,a5
ffffffffc0201460:	863e                	mv	a2,a5
ffffffffc0201462:	00000073          	ecall
ffffffffc0201466:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201468:	8082                	ret

ffffffffc020146a <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020146a:	4501                	li	a0,0
ffffffffc020146c:	00005797          	auipc	a5,0x5
ffffffffc0201470:	b947b783          	ld	a5,-1132(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201474:	88be                	mv	a7,a5
ffffffffc0201476:	852a                	mv	a0,a0
ffffffffc0201478:	85aa                	mv	a1,a0
ffffffffc020147a:	862a                	mv	a2,a0
ffffffffc020147c:	00000073          	ecall
ffffffffc0201480:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201482:	2501                	sext.w	a0,a0
ffffffffc0201484:	8082                	ret

ffffffffc0201486 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201486:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201488:	e589                	bnez	a1,ffffffffc0201492 <strnlen+0xc>
ffffffffc020148a:	a811                	j	ffffffffc020149e <strnlen+0x18>
        cnt ++;
ffffffffc020148c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020148e:	00f58863          	beq	a1,a5,ffffffffc020149e <strnlen+0x18>
ffffffffc0201492:	00f50733          	add	a4,a0,a5
ffffffffc0201496:	00074703          	lbu	a4,0(a4)
ffffffffc020149a:	fb6d                	bnez	a4,ffffffffc020148c <strnlen+0x6>
ffffffffc020149c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020149e:	852e                	mv	a0,a1
ffffffffc02014a0:	8082                	ret

ffffffffc02014a2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014a2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014a6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014aa:	cb89                	beqz	a5,ffffffffc02014bc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02014ac:	0505                	addi	a0,a0,1
ffffffffc02014ae:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014b0:	fee789e3          	beq	a5,a4,ffffffffc02014a2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014b4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02014b8:	9d19                	subw	a0,a0,a4
ffffffffc02014ba:	8082                	ret
ffffffffc02014bc:	4501                	li	a0,0
ffffffffc02014be:	bfed                	j	ffffffffc02014b8 <strcmp+0x16>

ffffffffc02014c0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02014c0:	00054783          	lbu	a5,0(a0)
ffffffffc02014c4:	c799                	beqz	a5,ffffffffc02014d2 <strchr+0x12>
        if (*s == c) {
ffffffffc02014c6:	00f58763          	beq	a1,a5,ffffffffc02014d4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02014ca:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02014ce:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02014d0:	fbfd                	bnez	a5,ffffffffc02014c6 <strchr+0x6>
    }
    return NULL;
ffffffffc02014d2:	4501                	li	a0,0
}
ffffffffc02014d4:	8082                	ret

ffffffffc02014d6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02014d6:	ca01                	beqz	a2,ffffffffc02014e6 <memset+0x10>
ffffffffc02014d8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02014da:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02014dc:	0785                	addi	a5,a5,1
ffffffffc02014de:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02014e2:	fec79de3          	bne	a5,a2,ffffffffc02014dc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02014e6:	8082                	ret
