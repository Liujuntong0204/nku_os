
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
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area1>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	59660613          	addi	a2,a2,1430 # ffffffffc02065d0 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	624010ef          	jal	ra,ffffffffc020166e <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	62e50513          	addi	a0,a0,1582 # ffffffffc0201680 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	719000ef          	jal	ra,ffffffffc0200f7e <pmm_init>

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
ffffffffc02000a6:	0d8010ef          	jal	ra,ffffffffc020117e <vprintfmt>
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
ffffffffc02000dc:	0a2010ef          	jal	ra,ffffffffc020117e <vprintfmt>
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
ffffffffc0200140:	56450513          	addi	a0,a0,1380 # ffffffffc02016a0 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	56e50513          	addi	a0,a0,1390 # ffffffffc02016c0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	52258593          	addi	a1,a1,1314 # ffffffffc0201680 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	57a50513          	addi	a0,a0,1402 # ffffffffc02016e0 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area1>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	58650513          	addi	a0,a0,1414 # ffffffffc0201700 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	44a58593          	addi	a1,a1,1098 # ffffffffc02065d0 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	59250513          	addi	a0,a0,1426 # ffffffffc0201720 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00007597          	auipc	a1,0x7
ffffffffc020019e:	83558593          	addi	a1,a1,-1995 # ffffffffc02069cf <end+0x3ff>
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
ffffffffc02001c0:	58450513          	addi	a0,a0,1412 # ffffffffc0201740 <etext+0xc0>
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
ffffffffc02001ce:	5a660613          	addi	a2,a2,1446 # ffffffffc0201770 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5b250513          	addi	a0,a0,1458 # ffffffffc0201788 <etext+0x108>
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
ffffffffc02001ea:	5ba60613          	addi	a2,a2,1466 # ffffffffc02017a0 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	5d258593          	addi	a1,a1,1490 # ffffffffc02017c0 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	5d250513          	addi	a0,a0,1490 # ffffffffc02017c8 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	5d460613          	addi	a2,a2,1492 # ffffffffc02017d8 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	5f458593          	addi	a1,a1,1524 # ffffffffc0201800 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	5b450513          	addi	a0,a0,1460 # ffffffffc02017c8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	5f060613          	addi	a2,a2,1520 # ffffffffc0201810 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	60858593          	addi	a1,a1,1544 # ffffffffc0201830 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	59850513          	addi	a0,a0,1432 # ffffffffc02017c8 <etext+0x148>
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
ffffffffc020026e:	5d650513          	addi	a0,a0,1494 # ffffffffc0201840 <etext+0x1c0>
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
ffffffffc0200290:	5dc50513          	addi	a0,a0,1500 # ffffffffc0201868 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	636c0c13          	addi	s8,s8,1590 # ffffffffc02018d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	5e690913          	addi	s2,s2,1510 # ffffffffc0201890 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	5e648493          	addi	s1,s1,1510 # ffffffffc0201898 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	5e4b0b13          	addi	s6,s6,1508 # ffffffffc02018a0 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	4fca0a13          	addi	s4,s4,1276 # ffffffffc02017c0 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	230010ef          	jal	ra,ffffffffc0201500 <readline>
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
ffffffffc02002ea:	5f2d0d13          	addi	s10,s10,1522 # ffffffffc02018d8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	346010ef          	jal	ra,ffffffffc020163a <strcmp>
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
ffffffffc0200308:	332010ef          	jal	ra,ffffffffc020163a <strcmp>
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
ffffffffc0200346:	312010ef          	jal	ra,ffffffffc0201658 <strchr>
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
ffffffffc0200384:	2d4010ef          	jal	ra,ffffffffc0201658 <strchr>
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
ffffffffc02003a2:	52250513          	addi	a0,a0,1314 # ffffffffc02018c0 <etext+0x240>
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
ffffffffc02003b0:	1d430313          	addi	t1,t1,468 # ffffffffc0206580 <is_panic>
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
ffffffffc02003de:	54650513          	addi	a0,a0,1350 # ffffffffc0201920 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	aa850513          	addi	a0,a0,-1368 # ffffffffc0201e98 <commands+0x5c0>
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
ffffffffc0200420:	1ae010ef          	jal	ra,ffffffffc02015ce <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1607b123          	sd	zero,354(a5) # ffffffffc0206588 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	51250513          	addi	a0,a0,1298 # ffffffffc0201940 <commands+0x68>
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
ffffffffc0200446:	1880106f          	j	ffffffffc02015ce <sbi_set_timer>

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
ffffffffc0200450:	1640106f          	j	ffffffffc02015b4 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1940106f          	j	ffffffffc02015e8 <sbi_console_getchar>

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
ffffffffc020046c:	38078793          	addi	a5,a5,896 # ffffffffc02007e8 <__alltraps>
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
ffffffffc0200482:	4e250513          	addi	a0,a0,1250 # ffffffffc0201960 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201978 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	4f450513          	addi	a0,a0,1268 # ffffffffc0201990 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	4fe50513          	addi	a0,a0,1278 # ffffffffc02019a8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	50850513          	addi	a0,a0,1288 # ffffffffc02019c0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	51250513          	addi	a0,a0,1298 # ffffffffc02019d8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	51c50513          	addi	a0,a0,1308 # ffffffffc02019f0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	52650513          	addi	a0,a0,1318 # ffffffffc0201a08 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	53050513          	addi	a0,a0,1328 # ffffffffc0201a20 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	53a50513          	addi	a0,a0,1338 # ffffffffc0201a38 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	54450513          	addi	a0,a0,1348 # ffffffffc0201a50 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	54e50513          	addi	a0,a0,1358 # ffffffffc0201a68 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	55850513          	addi	a0,a0,1368 # ffffffffc0201a80 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	56250513          	addi	a0,a0,1378 # ffffffffc0201a98 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	56c50513          	addi	a0,a0,1388 # ffffffffc0201ab0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	57650513          	addi	a0,a0,1398 # ffffffffc0201ac8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	58050513          	addi	a0,a0,1408 # ffffffffc0201ae0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	58a50513          	addi	a0,a0,1418 # ffffffffc0201af8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	59450513          	addi	a0,a0,1428 # ffffffffc0201b10 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	59e50513          	addi	a0,a0,1438 # ffffffffc0201b28 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5a850513          	addi	a0,a0,1448 # ffffffffc0201b40 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5b250513          	addi	a0,a0,1458 # ffffffffc0201b58 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0201b70 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5c650513          	addi	a0,a0,1478 # ffffffffc0201b88 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	5d050513          	addi	a0,a0,1488 # ffffffffc0201ba0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	5da50513          	addi	a0,a0,1498 # ffffffffc0201bb8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	5e450513          	addi	a0,a0,1508 # ffffffffc0201bd0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201be8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	5f850513          	addi	a0,a0,1528 # ffffffffc0201c00 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	60250513          	addi	a0,a0,1538 # ffffffffc0201c18 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	60c50513          	addi	a0,a0,1548 # ffffffffc0201c30 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	61250513          	addi	a0,a0,1554 # ffffffffc0201c48 <commands+0x370>
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
ffffffffc020064e:	61650513          	addi	a0,a0,1558 # ffffffffc0201c60 <commands+0x388>
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
ffffffffc0200666:	61650513          	addi	a0,a0,1558 # ffffffffc0201c78 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	61e50513          	addi	a0,a0,1566 # ffffffffc0201c90 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	62650513          	addi	a0,a0,1574 # ffffffffc0201ca8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	62a50513          	addi	a0,a0,1578 # ffffffffc0201cc0 <commands+0x3e8>
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
ffffffffc02006b4:	6f070713          	addi	a4,a4,1776 # ffffffffc0201da0 <commands+0x4c8>
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
ffffffffc02006c6:	67650513          	addi	a0,a0,1654 # ffffffffc0201d38 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	64c50513          	addi	a0,a0,1612 # ffffffffc0201d18 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	60250513          	addi	a0,a0,1538 # ffffffffc0201cd8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	67850513          	addi	a0,a0,1656 # ffffffffc0201d58 <commands+0x480>
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
ffffffffc02006f6:	e9668693          	addi	a3,a3,-362 # ffffffffc0206588 <ticks>
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
ffffffffc0200714:	67050513          	addi	a0,a0,1648 # ffffffffc0201d80 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	5de50513          	addi	a0,a0,1502 # ffffffffc0201cf8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200726:	06400593          	li	a1,100
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	64650513          	addi	a0,a0,1606 # ffffffffc0201d70 <commands+0x498>
ffffffffc0200732:	981ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                PRINT_NUM++;
ffffffffc0200736:	00006717          	auipc	a4,0x6
ffffffffc020073a:	e5a70713          	addi	a4,a4,-422 # ffffffffc0206590 <PRINT_NUM>
ffffffffc020073e:	431c                	lw	a5,0(a4)
                if(PRINT_NUM == 10){
ffffffffc0200740:	46a9                	li	a3,10
                PRINT_NUM++;
ffffffffc0200742:	0017861b          	addiw	a2,a5,1
ffffffffc0200746:	c310                	sw	a2,0(a4)
                if(PRINT_NUM == 10){
ffffffffc0200748:	fcd611e3          	bne	a2,a3,ffffffffc020070a <interrupt_handler+0x68>
}
ffffffffc020074c:	60a2                	ld	ra,8(sp)
ffffffffc020074e:	0141                	addi	sp,sp,16
            	   sbi_shutdown();
ffffffffc0200750:	6b50006f          	j	ffffffffc0201604 <sbi_shutdown>

ffffffffc0200754 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200754:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200758:	1141                	addi	sp,sp,-16
ffffffffc020075a:	e022                	sd	s0,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc020075e:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200760:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200762:	04e78663          	beq	a5,a4,ffffffffc02007ae <exception_handler+0x5a>
ffffffffc0200766:	02f76c63          	bltu	a4,a5,ffffffffc020079e <exception_handler+0x4a>
ffffffffc020076a:	4709                	li	a4,2
ffffffffc020076c:	02e79563          	bne	a5,a4,ffffffffc0200796 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213244: */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction \n");
ffffffffc0200770:	00001517          	auipc	a0,0x1
ffffffffc0200774:	66050513          	addi	a0,a0,1632 # ffffffffc0201dd0 <commands+0x4f8>
ffffffffc0200778:	93bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);
ffffffffc020077c:	10843583          	ld	a1,264(s0)
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	67850513          	addi	a0,a0,1656 # ffffffffc0201df8 <commands+0x520>
ffffffffc0200788:	92bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc += 4;
ffffffffc020078c:	10843783          	ld	a5,264(s0)
ffffffffc0200790:	0791                	addi	a5,a5,4
ffffffffc0200792:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200796:	60a2                	ld	ra,8(sp)
ffffffffc0200798:	6402                	ld	s0,0(sp)
ffffffffc020079a:	0141                	addi	sp,sp,16
ffffffffc020079c:	8082                	ret
    switch (tf->cause) {
ffffffffc020079e:	17f1                	addi	a5,a5,-4
ffffffffc02007a0:	471d                	li	a4,7
ffffffffc02007a2:	fef77ae3          	bgeu	a4,a5,ffffffffc0200796 <exception_handler+0x42>
}
ffffffffc02007a6:	6402                	ld	s0,0(sp)
ffffffffc02007a8:	60a2                	ld	ra,8(sp)
ffffffffc02007aa:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007ac:	bd59                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception type: breakpoint \n");
ffffffffc02007ae:	00001517          	auipc	a0,0x1
ffffffffc02007b2:	67a50513          	addi	a0,a0,1658 # ffffffffc0201e28 <commands+0x550>
ffffffffc02007b6:	8fdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007ba:	10843583          	ld	a1,264(s0)
ffffffffc02007be:	00001517          	auipc	a0,0x1
ffffffffc02007c2:	68a50513          	addi	a0,a0,1674 # ffffffffc0201e48 <commands+0x570>
ffffffffc02007c6:	8edff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc += 2;//ebreak指令长度为2个字节
ffffffffc02007ca:	10843783          	ld	a5,264(s0)
}
ffffffffc02007ce:	60a2                	ld	ra,8(sp)
            tf->epc += 2;//ebreak指令长度为2个字节
ffffffffc02007d0:	0789                	addi	a5,a5,2
ffffffffc02007d2:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007d6:	6402                	ld	s0,0(sp)
ffffffffc02007d8:	0141                	addi	sp,sp,16
ffffffffc02007da:	8082                	ret

ffffffffc02007dc <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007dc:	11853783          	ld	a5,280(a0)
ffffffffc02007e0:	0007c363          	bltz	a5,ffffffffc02007e6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007e4:	bf85                	j	ffffffffc0200754 <exception_handler>
        interrupt_handler(tf);
ffffffffc02007e6:	bd75                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc02007e8 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007e8:	14011073          	csrw	sscratch,sp
ffffffffc02007ec:	712d                	addi	sp,sp,-288
ffffffffc02007ee:	e002                	sd	zero,0(sp)
ffffffffc02007f0:	e406                	sd	ra,8(sp)
ffffffffc02007f2:	ec0e                	sd	gp,24(sp)
ffffffffc02007f4:	f012                	sd	tp,32(sp)
ffffffffc02007f6:	f416                	sd	t0,40(sp)
ffffffffc02007f8:	f81a                	sd	t1,48(sp)
ffffffffc02007fa:	fc1e                	sd	t2,56(sp)
ffffffffc02007fc:	e0a2                	sd	s0,64(sp)
ffffffffc02007fe:	e4a6                	sd	s1,72(sp)
ffffffffc0200800:	e8aa                	sd	a0,80(sp)
ffffffffc0200802:	ecae                	sd	a1,88(sp)
ffffffffc0200804:	f0b2                	sd	a2,96(sp)
ffffffffc0200806:	f4b6                	sd	a3,104(sp)
ffffffffc0200808:	f8ba                	sd	a4,112(sp)
ffffffffc020080a:	fcbe                	sd	a5,120(sp)
ffffffffc020080c:	e142                	sd	a6,128(sp)
ffffffffc020080e:	e546                	sd	a7,136(sp)
ffffffffc0200810:	e94a                	sd	s2,144(sp)
ffffffffc0200812:	ed4e                	sd	s3,152(sp)
ffffffffc0200814:	f152                	sd	s4,160(sp)
ffffffffc0200816:	f556                	sd	s5,168(sp)
ffffffffc0200818:	f95a                	sd	s6,176(sp)
ffffffffc020081a:	fd5e                	sd	s7,184(sp)
ffffffffc020081c:	e1e2                	sd	s8,192(sp)
ffffffffc020081e:	e5e6                	sd	s9,200(sp)
ffffffffc0200820:	e9ea                	sd	s10,208(sp)
ffffffffc0200822:	edee                	sd	s11,216(sp)
ffffffffc0200824:	f1f2                	sd	t3,224(sp)
ffffffffc0200826:	f5f6                	sd	t4,232(sp)
ffffffffc0200828:	f9fa                	sd	t5,240(sp)
ffffffffc020082a:	fdfe                	sd	t6,248(sp)
ffffffffc020082c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200830:	100024f3          	csrr	s1,sstatus
ffffffffc0200834:	14102973          	csrr	s2,sepc
ffffffffc0200838:	143029f3          	csrr	s3,stval
ffffffffc020083c:	14202a73          	csrr	s4,scause
ffffffffc0200840:	e822                	sd	s0,16(sp)
ffffffffc0200842:	e226                	sd	s1,256(sp)
ffffffffc0200844:	e64a                	sd	s2,264(sp)
ffffffffc0200846:	ea4e                	sd	s3,272(sp)
ffffffffc0200848:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020084a:	850a                	mv	a0,sp
    jal trap
ffffffffc020084c:	f91ff0ef          	jal	ra,ffffffffc02007dc <trap>

ffffffffc0200850 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200850:	6492                	ld	s1,256(sp)
ffffffffc0200852:	6932                	ld	s2,264(sp)
ffffffffc0200854:	10049073          	csrw	sstatus,s1
ffffffffc0200858:	14191073          	csrw	sepc,s2
ffffffffc020085c:	60a2                	ld	ra,8(sp)
ffffffffc020085e:	61e2                	ld	gp,24(sp)
ffffffffc0200860:	7202                	ld	tp,32(sp)
ffffffffc0200862:	72a2                	ld	t0,40(sp)
ffffffffc0200864:	7342                	ld	t1,48(sp)
ffffffffc0200866:	73e2                	ld	t2,56(sp)
ffffffffc0200868:	6406                	ld	s0,64(sp)
ffffffffc020086a:	64a6                	ld	s1,72(sp)
ffffffffc020086c:	6546                	ld	a0,80(sp)
ffffffffc020086e:	65e6                	ld	a1,88(sp)
ffffffffc0200870:	7606                	ld	a2,96(sp)
ffffffffc0200872:	76a6                	ld	a3,104(sp)
ffffffffc0200874:	7746                	ld	a4,112(sp)
ffffffffc0200876:	77e6                	ld	a5,120(sp)
ffffffffc0200878:	680a                	ld	a6,128(sp)
ffffffffc020087a:	68aa                	ld	a7,136(sp)
ffffffffc020087c:	694a                	ld	s2,144(sp)
ffffffffc020087e:	69ea                	ld	s3,152(sp)
ffffffffc0200880:	7a0a                	ld	s4,160(sp)
ffffffffc0200882:	7aaa                	ld	s5,168(sp)
ffffffffc0200884:	7b4a                	ld	s6,176(sp)
ffffffffc0200886:	7bea                	ld	s7,184(sp)
ffffffffc0200888:	6c0e                	ld	s8,192(sp)
ffffffffc020088a:	6cae                	ld	s9,200(sp)
ffffffffc020088c:	6d4e                	ld	s10,208(sp)
ffffffffc020088e:	6dee                	ld	s11,216(sp)
ffffffffc0200890:	7e0e                	ld	t3,224(sp)
ffffffffc0200892:	7eae                	ld	t4,232(sp)
ffffffffc0200894:	7f4e                	ld	t5,240(sp)
ffffffffc0200896:	7fee                	ld	t6,248(sp)
ffffffffc0200898:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020089a:	10200073          	sret

ffffffffc020089e <buddy_system_init>:
#define free_list(property) (free_area1[(property)].free_list)
#define nr_free(property) (free_area1[(property)].nr_free)

static void
buddy_system_init(void) {
    for(int i=0;i<MAX_ORDER+1;i++)
ffffffffc020089e:	00005797          	auipc	a5,0x5
ffffffffc02008a2:	77a78793          	addi	a5,a5,1914 # ffffffffc0206018 <free_area1>
ffffffffc02008a6:	00006717          	auipc	a4,0x6
ffffffffc02008aa:	8da70713          	addi	a4,a4,-1830 # ffffffffc0206180 <buf>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008ae:	e79c                	sd	a5,8(a5)
ffffffffc02008b0:	e39c                	sd	a5,0(a5)
    {
    list_init(&(free_area1[i].free_list));
     free_area1[i].nr_free = 0;
ffffffffc02008b2:	0007a823          	sw	zero,16(a5)
    for(int i=0;i<MAX_ORDER+1;i++)
ffffffffc02008b6:	07e1                	addi	a5,a5,24
ffffffffc02008b8:	fee79be3          	bne	a5,a4,ffffffffc02008ae <buddy_system_init+0x10>
    }
}
ffffffffc02008bc:	8082                	ret

ffffffffc02008be <split_page>:
        remain=remain-(1<<(order));
    }   
}
    

static void split_page(int order) {
ffffffffc02008be:	7179                	addi	sp,sp,-48
ffffffffc02008c0:	e84a                	sd	s2,16(sp)
ffffffffc02008c2:	00151913          	slli	s2,a0,0x1
ffffffffc02008c6:	e052                	sd	s4,0(sp)
ffffffffc02008c8:	00a90a33          	add	s4,s2,a0
ffffffffc02008cc:	e44e                	sd	s3,8(sp)
ffffffffc02008ce:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02008d0:	00005997          	auipc	s3,0x5
ffffffffc02008d4:	74898993          	addi	s3,s3,1864 # ffffffffc0206018 <free_area1>
ffffffffc02008d8:	014987b3          	add	a5,s3,s4
ffffffffc02008dc:	f022                	sd	s0,32(sp)
ffffffffc02008de:	6780                	ld	s0,8(a5)
ffffffffc02008e0:	ec26                	sd	s1,24(sp)
ffffffffc02008e2:	f406                	sd	ra,40(sp)
ffffffffc02008e4:	84aa                	mv	s1,a0
    if(list_empty(&(free_area1[order].free_list))) {
ffffffffc02008e6:	08f40463          	beq	s0,a5,ffffffffc020096e <split_page+0xb0>
    struct Page *page = NULL;
    list_entry_t *le = &(free_area1[order].free_list);
    le = list_next(le);
    page= le2page(le, page_link);
    list_del(&(page->page_link));
    free_area1[order].nr_free-=1;
ffffffffc02008ea:	9926                	add	s2,s2,s1
ffffffffc02008ec:	090e                	slli	s2,s2,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc02008ee:	6410                	ld	a2,8(s0)
ffffffffc02008f0:	600c                	ld	a1,0(s0)
    size_t n = 1 << (order - 1);
ffffffffc02008f2:	34fd                	addiw	s1,s1,-1
    free_area1[order].nr_free-=1;
ffffffffc02008f4:	994e                	add	s2,s2,s3
    size_t n = 1 << (order - 1);
ffffffffc02008f6:	4785                	li	a5,1
    free_area1[order].nr_free-=1;
ffffffffc02008f8:	01092683          	lw	a3,16(s2)
    size_t n = 1 << (order - 1);
ffffffffc02008fc:	0097973b          	sllw	a4,a5,s1
    struct Page *p = page + n;
ffffffffc0200900:	00271793          	slli	a5,a4,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200904:	e590                	sd	a2,8(a1)
ffffffffc0200906:	97ba                	add	a5,a5,a4
    next->prev = prev;
ffffffffc0200908:	e20c                	sd	a1,0(a2)
    free_area1[order].nr_free-=1;
ffffffffc020090a:	fff6871b          	addiw	a4,a3,-1
    struct Page *p = page + n;
ffffffffc020090e:	078e                	slli	a5,a5,0x3
    free_area1[order].nr_free-=1;
ffffffffc0200910:	00e92823          	sw	a4,16(s2)
    struct Page *p = page + n;
ffffffffc0200914:	17a1                	addi	a5,a5,-24
ffffffffc0200916:	97a2                	add	a5,a5,s0
    page->property = order-1;
ffffffffc0200918:	fe942c23          	sw	s1,-8(s0)
    size_t n = 1 << (order - 1);
ffffffffc020091c:	0004869b          	sext.w	a3,s1
    p->property = order-1;
ffffffffc0200920:	cb84                	sw	s1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200922:	4709                	li	a4,2
ffffffffc0200924:	00878613          	addi	a2,a5,8
ffffffffc0200928:	40e6302f          	amoor.d	zero,a4,(a2)
ffffffffc020092c:	ff040613          	addi	a2,s0,-16
ffffffffc0200930:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200934:	00169713          	slli	a4,a3,0x1
ffffffffc0200938:	9736                	add	a4,a4,a3
ffffffffc020093a:	070e                	slli	a4,a4,0x3
ffffffffc020093c:	974e                	add	a4,a4,s3
ffffffffc020093e:	6710                	ld	a2,8(a4)
    SetPageProperty(p);
    SetPageProperty(page);
    list_add(&(free_area1[order-1].free_list),&(page->page_link));
ffffffffc0200940:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc0200942:	e700                	sd	s0,8(a4)
ffffffffc0200944:	99d2                	add	s3,s3,s4
    elm->prev = prev;
ffffffffc0200946:	01343023          	sd	s3,0(s0)
    list_add(&(page->page_link),&(p->page_link));
ffffffffc020094a:	01878593          	addi	a1,a5,24
    free_area1[order-1].nr_free += 2;
ffffffffc020094e:	4b14                	lw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc0200950:	e20c                	sd	a1,0(a2)
ffffffffc0200952:	e40c                	sd	a1,8(s0)
    elm->prev = prev;
ffffffffc0200954:	ef80                	sd	s0,24(a5)
    return;
}
ffffffffc0200956:	70a2                	ld	ra,40(sp)
ffffffffc0200958:	7402                	ld	s0,32(sp)
    elm->next = next;
ffffffffc020095a:	f390                	sd	a2,32(a5)
    free_area1[order-1].nr_free += 2;
ffffffffc020095c:	0026879b          	addiw	a5,a3,2
ffffffffc0200960:	cb1c                	sw	a5,16(a4)
}
ffffffffc0200962:	64e2                	ld	s1,24(sp)
ffffffffc0200964:	6942                	ld	s2,16(sp)
ffffffffc0200966:	69a2                	ld	s3,8(sp)
ffffffffc0200968:	6a02                	ld	s4,0(sp)
ffffffffc020096a:	6145                	addi	sp,sp,48
ffffffffc020096c:	8082                	ret
        split_page(order + 1);
ffffffffc020096e:	2505                	addiw	a0,a0,1
ffffffffc0200970:	f4fff0ef          	jal	ra,ffffffffc02008be <split_page>
    return listelm->next;
ffffffffc0200974:	6400                	ld	s0,8(s0)
ffffffffc0200976:	bf95                	j	ffffffffc02008ea <split_page+0x2c>

ffffffffc0200978 <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200978:	00005697          	auipc	a3,0x5
ffffffffc020097c:	6b068693          	addi	a3,a3,1712 # ffffffffc0206028 <free_area1+0x10>
ffffffffc0200980:	4701                	li	a4,0
    size_t num = 0;
ffffffffc0200982:	4501                	li	a0,0
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200984:	463d                	li	a2,15
    {
        num+=free_area1[i].nr_free<<i;
ffffffffc0200986:	429c                	lw	a5,0(a3)
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200988:	06e1                	addi	a3,a3,24
        num+=free_area1[i].nr_free<<i;
ffffffffc020098a:	00e797bb          	sllw	a5,a5,a4
ffffffffc020098e:	1782                	slli	a5,a5,0x20
ffffffffc0200990:	9381                	srli	a5,a5,0x20
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200992:	2705                	addiw	a4,a4,1
        num+=free_area1[i].nr_free<<i;
ffffffffc0200994:	953e                	add	a0,a0,a5
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200996:	fec718e3          	bne	a4,a2,ffffffffc0200986 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc020099a:	8082                	ret

ffffffffc020099c <add_page>:
    if (list_empty(&(free_area1[order].free_list))) {
ffffffffc020099c:	00159693          	slli	a3,a1,0x1
ffffffffc02009a0:	96ae                	add	a3,a3,a1
ffffffffc02009a2:	00369593          	slli	a1,a3,0x3
ffffffffc02009a6:	00005697          	auipc	a3,0x5
ffffffffc02009aa:	67268693          	addi	a3,a3,1650 # ffffffffc0206018 <free_area1>
ffffffffc02009ae:	96ae                	add	a3,a3,a1
ffffffffc02009b0:	669c                	ld	a5,8(a3)
{
ffffffffc02009b2:	1141                	addi	sp,sp,-16
ffffffffc02009b4:	e022                	sd	s0,0(sp)
ffffffffc02009b6:	e406                	sd	ra,8(sp)
ffffffffc02009b8:	842a                	mv	s0,a0
    if (list_empty(&(free_area1[order].free_list))) {
ffffffffc02009ba:	00f69963          	bne	a3,a5,ffffffffc02009cc <add_page+0x30>
ffffffffc02009be:	a8ad                	j	ffffffffc0200a38 <add_page+0x9c>
            if (base < page) {
ffffffffc02009c0:	02b46363          	bltu	s0,a1,ffffffffc02009e6 <add_page+0x4a>
ffffffffc02009c4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &(free_area1[order].free_list)) {
ffffffffc02009c6:	04e68563          	beq	a3,a4,ffffffffc0200a10 <add_page+0x74>
ffffffffc02009ca:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02009cc:	fe878593          	addi	a1,a5,-24
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
ffffffffc02009d0:	fef698e3          	bne	a3,a5,ffffffffc02009c0 <add_page+0x24>
}
ffffffffc02009d4:	6402                	ld	s0,0(sp)
ffffffffc02009d6:	60a2                	ld	ra,8(sp)
        cprintf("加入非空链表\n");
ffffffffc02009d8:	00001517          	auipc	a0,0x1
ffffffffc02009dc:	52850513          	addi	a0,a0,1320 # ffffffffc0201f00 <commands+0x628>
}
ffffffffc02009e0:	0141                	addi	sp,sp,16
        cprintf("加入非空链表\n");
ffffffffc02009e2:	ed0ff06f          	j	ffffffffc02000b2 <cprintf>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02009e6:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc02009e8:	01840693          	addi	a3,s0,24
    prev->next = next->prev = elm;
ffffffffc02009ec:	e394                	sd	a3,0(a5)
ffffffffc02009ee:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02009f0:	f01c                	sd	a5,32(s0)
    elm->prev = prev;
ffffffffc02009f2:	ec18                	sd	a4,24(s0)
                cprintf("page1的地址为%016lx:\n",page);
ffffffffc02009f4:	00001517          	auipc	a0,0x1
ffffffffc02009f8:	48c50513          	addi	a0,a0,1164 # ffffffffc0201e80 <commands+0x5a8>
ffffffffc02009fc:	eb6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("base1的地址为：%016lx\n",base);
ffffffffc0200a00:	85a2                	mv	a1,s0
ffffffffc0200a02:	00001517          	auipc	a0,0x1
ffffffffc0200a06:	49e50513          	addi	a0,a0,1182 # ffffffffc0201ea0 <commands+0x5c8>
ffffffffc0200a0a:	ea8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                break;
ffffffffc0200a0e:	b7d9                	j	ffffffffc02009d4 <add_page+0x38>
                list_add(le, &(base->page_link));
ffffffffc0200a10:	01840713          	addi	a4,s0,24
    prev->next = next->prev = elm;
ffffffffc0200a14:	e298                	sd	a4,0(a3)
ffffffffc0200a16:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200a18:	f014                	sd	a3,32(s0)
    elm->prev = prev;
ffffffffc0200a1a:	ec1c                	sd	a5,24(s0)
                cprintf("page2的地址为%016lx:\n",page);
ffffffffc0200a1c:	00001517          	auipc	a0,0x1
ffffffffc0200a20:	4a450513          	addi	a0,a0,1188 # ffffffffc0201ec0 <commands+0x5e8>
ffffffffc0200a24:	e8eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("base2的地址为：%016lx\n",base);
ffffffffc0200a28:	85a2                	mv	a1,s0
ffffffffc0200a2a:	00001517          	auipc	a0,0x1
ffffffffc0200a2e:	4b650513          	addi	a0,a0,1206 # ffffffffc0201ee0 <commands+0x608>
ffffffffc0200a32:	e80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                break;
ffffffffc0200a36:	bf79                	j	ffffffffc02009d4 <add_page+0x38>
        list_add(&(free_area1[order].free_list), &(base->page_link));
ffffffffc0200a38:	01850793          	addi	a5,a0,24
}
ffffffffc0200a3c:	6402                	ld	s0,0(sp)
    prev->next = next->prev = elm;
ffffffffc0200a3e:	e29c                	sd	a5,0(a3)
ffffffffc0200a40:	e69c                	sd	a5,8(a3)
ffffffffc0200a42:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200a44:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200a46:	ed14                	sd	a3,24(a0)
        cprintf("加入空链表\n");
ffffffffc0200a48:	00001517          	auipc	a0,0x1
ffffffffc0200a4c:	42050513          	addi	a0,a0,1056 # ffffffffc0201e68 <commands+0x590>
}
ffffffffc0200a50:	0141                	addi	sp,sp,16
        cprintf("加入非空链表\n");
ffffffffc0200a52:	e60ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200a56 <buddy_system_free_pages.part.0>:
    for (; p != base + n; p ++) {
ffffffffc0200a56:	00259793          	slli	a5,a1,0x2
ffffffffc0200a5a:	97ae                	add	a5,a5,a1
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200a5c:	7119                	addi	sp,sp,-128
    for (; p != base + n; p ++) {
ffffffffc0200a5e:	078e                	slli	a5,a5,0x3
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200a60:	f8a2                	sd	s0,112(sp)
    for (; p != base + n; p ++) {
ffffffffc0200a62:	00f506b3          	add	a3,a0,a5
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200a66:	fc86                	sd	ra,120(sp)
ffffffffc0200a68:	f4a6                	sd	s1,104(sp)
ffffffffc0200a6a:	f0ca                	sd	s2,96(sp)
ffffffffc0200a6c:	ecce                	sd	s3,88(sp)
ffffffffc0200a6e:	e8d2                	sd	s4,80(sp)
ffffffffc0200a70:	e4d6                	sd	s5,72(sp)
ffffffffc0200a72:	e0da                	sd	s6,64(sp)
ffffffffc0200a74:	fc5e                	sd	s7,56(sp)
ffffffffc0200a76:	f862                	sd	s8,48(sp)
ffffffffc0200a78:	f466                	sd	s9,40(sp)
ffffffffc0200a7a:	f06a                	sd	s10,32(sp)
ffffffffc0200a7c:	ec6e                	sd	s11,24(sp)
ffffffffc0200a7e:	842a                	mv	s0,a0
    for (; p != base + n; p ++) {
ffffffffc0200a80:	87aa                	mv	a5,a0
ffffffffc0200a82:	02d50263          	beq	a0,a3,ffffffffc0200aa6 <buddy_system_free_pages.part.0+0x50>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a86:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a88:	8b05                	andi	a4,a4,1
ffffffffc0200a8a:	1c071d63          	bnez	a4,ffffffffc0200c64 <buddy_system_free_pages.part.0+0x20e>
ffffffffc0200a8e:	6798                	ld	a4,8(a5)
ffffffffc0200a90:	8b09                	andi	a4,a4,2
ffffffffc0200a92:	1c071963          	bnez	a4,ffffffffc0200c64 <buddy_system_free_pages.part.0+0x20e>
        p->flags = 0;
ffffffffc0200a96:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a9a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200a9e:	02878793          	addi	a5,a5,40
ffffffffc0200aa2:	fed792e3          	bne	a5,a3,ffffffffc0200a86 <buddy_system_free_pages.part.0+0x30>
    while(n!=(1<<order))
ffffffffc0200aa6:	4785                	li	a5,1
    int order = 0;
ffffffffc0200aa8:	4481                	li	s1,0
    while(n!=(1<<order))
ffffffffc0200aaa:	4705                	li	a4,1
ffffffffc0200aac:	4901                	li	s2,0
ffffffffc0200aae:	00f58963          	beq	a1,a5,ffffffffc0200ac0 <buddy_system_free_pages.part.0+0x6a>
        order++;
ffffffffc0200ab2:	2485                	addiw	s1,s1,1
    while(n!=(1<<order))
ffffffffc0200ab4:	009717bb          	sllw	a5,a4,s1
ffffffffc0200ab8:	fef59de3          	bne	a1,a5,ffffffffc0200ab2 <buddy_system_free_pages.part.0+0x5c>
    base->property = order;
ffffffffc0200abc:	0004891b          	sext.w	s2,s1
    cprintf("当前order为： %d \n",order);
ffffffffc0200ac0:	85a6                	mv	a1,s1
ffffffffc0200ac2:	00001517          	auipc	a0,0x1
ffffffffc0200ac6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201f78 <commands+0x6a0>
ffffffffc0200aca:	de8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ace:	4789                	li	a5,2
    base->property = order;
ffffffffc0200ad0:	01242823          	sw	s2,16(s0)
ffffffffc0200ad4:	00840713          	addi	a4,s0,8
ffffffffc0200ad8:	40f7302f          	amoor.d	zero,a5,(a4)
    add_page(base, order);
ffffffffc0200adc:	85a6                	mv	a1,s1
ffffffffc0200ade:	8522                	mv	a0,s0
ffffffffc0200ae0:	ebdff0ef          	jal	ra,ffffffffc020099c <add_page>
    free_area1[order].nr_free += 1;
ffffffffc0200ae4:	00149793          	slli	a5,s1,0x1
ffffffffc0200ae8:	97a6                	add	a5,a5,s1
ffffffffc0200aea:	00005c97          	auipc	s9,0x5
ffffffffc0200aee:	52ec8c93          	addi	s9,s9,1326 # ffffffffc0206018 <free_area1>
ffffffffc0200af2:	078e                	slli	a5,a5,0x3
ffffffffc0200af4:	97e6                	add	a5,a5,s9
ffffffffc0200af6:	4b98                	lw	a4,16(a5)
ffffffffc0200af8:	2485                	addiw	s1,s1,1
ffffffffc0200afa:	893e                	mv	s2,a5
ffffffffc0200afc:	2705                	addiw	a4,a4,1
ffffffffc0200afe:	cb98                	sw	a4,16(a5)
    cprintf("进入merge\n");
ffffffffc0200b00:	00001a17          	auipc	s4,0x1
ffffffffc0200b04:	490a0a13          	addi	s4,s4,1168 # ffffffffc0201f90 <commands+0x6b8>
    if(order == MAX_ORDER)
ffffffffc0200b08:	49bd                	li	s3,15
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200b0a:	4a85                	li	s5,1
        cprintf("进入第一个if\n\n");
ffffffffc0200b0c:	00001c17          	auipc	s8,0x1
ffffffffc0200b10:	494c0c13          	addi	s8,s8,1172 # ffffffffc0201fa0 <commands+0x6c8>
        cprintf("p的地址为%016lx:\n",p);
ffffffffc0200b14:	00001b97          	auipc	s7,0x1
ffffffffc0200b18:	4a4b8b93          	addi	s7,s7,1188 # ffffffffc0201fb8 <commands+0x6e0>
        cprintf("base的地址为：%016lx\n",base);
ffffffffc0200b1c:	00001b17          	auipc	s6,0x1
ffffffffc0200b20:	4b4b0b13          	addi	s6,s6,1204 # ffffffffc0201fd0 <commands+0x6f8>
ffffffffc0200b24:	a055                	j	ffffffffc0200bc8 <buddy_system_free_pages.part.0+0x172>
        cprintf("进入第一个if\n\n");
ffffffffc0200b26:	8562                	mv	a0,s8
ffffffffc0200b28:	d8aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        struct Page *p = le2page(le, page_link);
ffffffffc0200b2c:	fe8d0d93          	addi	s11,s10,-24
        cprintf("p的地址为%016lx:\n",p);
ffffffffc0200b30:	85ee                	mv	a1,s11
ffffffffc0200b32:	855e                	mv	a0,s7
ffffffffc0200b34:	d7eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        cprintf("base的地址为：%016lx\n",base);
ffffffffc0200b38:	85a2                	mv	a1,s0
ffffffffc0200b3a:	855a                	mv	a0,s6
ffffffffc0200b3c:	d76ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        cprintf("p的property为：%d\n",p->property);
ffffffffc0200b40:	ff8d2583          	lw	a1,-8(s10)
ffffffffc0200b44:	00001517          	auipc	a0,0x1
ffffffffc0200b48:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201ff0 <commands+0x718>
ffffffffc0200b4c:	d66ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        if (p + (1<<(p->property)) == base) {
ffffffffc0200b50:	ff8d2703          	lw	a4,-8(s10)
ffffffffc0200b54:	00ea96bb          	sllw	a3,s5,a4
ffffffffc0200b58:	00269713          	slli	a4,a3,0x2
ffffffffc0200b5c:	9736                	add	a4,a4,a3
ffffffffc0200b5e:	070e                	slli	a4,a4,0x3
ffffffffc0200b60:	976e                	add	a4,a4,s11
ffffffffc0200b62:	06e41c63          	bne	s0,a4,ffffffffc0200bda <buddy_system_free_pages.part.0+0x184>
            cprintf("进入merge 和前页合并\n");
ffffffffc0200b66:	00001517          	auipc	a0,0x1
ffffffffc0200b6a:	4a250513          	addi	a0,a0,1186 # ffffffffc0202008 <commands+0x730>
ffffffffc0200b6e:	d44ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            p->property += 1;
ffffffffc0200b72:	ff8d2703          	lw	a4,-8(s10)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b76:	00840793          	addi	a5,s0,8
ffffffffc0200b7a:	2705                	addiw	a4,a4,1
ffffffffc0200b7c:	feed2c23          	sw	a4,-8(s10)
ffffffffc0200b80:	5775                	li	a4,-3
ffffffffc0200b82:	60e7b02f          	amoand.d	zero,a4,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b86:	6c0c                	ld	a1,24(s0)
ffffffffc0200b88:	7014                	ld	a3,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200b8a:	01092703          	lw	a4,16(s2)
            add_page(base,order+1);
ffffffffc0200b8e:	0004841b          	sext.w	s0,s1
    prev->next = next;
ffffffffc0200b92:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc0200b94:	e28c                	sd	a1,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b96:	000d3503          	ld	a0,0(s10)
ffffffffc0200b9a:	008d3683          	ld	a3,8(s10)
            free_area1[order].nr_free -= 2;
ffffffffc0200b9e:	ffe7079b          	addiw	a5,a4,-2
            add_page(base,order+1);
ffffffffc0200ba2:	85a2                	mv	a1,s0
    prev->next = next;
ffffffffc0200ba4:	e514                	sd	a3,8(a0)
    next->prev = prev;
ffffffffc0200ba6:	e288                	sd	a0,0(a3)
            free_area1[order].nr_free -= 2;
ffffffffc0200ba8:	00f92823          	sw	a5,16(s2)
            add_page(base,order+1);
ffffffffc0200bac:	856e                	mv	a0,s11
ffffffffc0200bae:	defff0ef          	jal	ra,ffffffffc020099c <add_page>
            free_area1[order+1].nr_free += 1;
ffffffffc0200bb2:	00141793          	slli	a5,s0,0x1
ffffffffc0200bb6:	97a2                	add	a5,a5,s0
ffffffffc0200bb8:	078e                	slli	a5,a5,0x3
ffffffffc0200bba:	97e6                	add	a5,a5,s9
ffffffffc0200bbc:	4b98                	lw	a4,16(a5)
ffffffffc0200bbe:	846e                	mv	s0,s11
ffffffffc0200bc0:	2705                	addiw	a4,a4,1
ffffffffc0200bc2:	cb98                	sw	a4,16(a5)
        merge_page(base,order+1);
ffffffffc0200bc4:	2485                	addiw	s1,s1,1
ffffffffc0200bc6:	0961                	addi	s2,s2,24
    cprintf("进入merge\n");
ffffffffc0200bc8:	8552                	mv	a0,s4
ffffffffc0200bca:	ce8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if(order == MAX_ORDER)
ffffffffc0200bce:	03348563          	beq	s1,s3,ffffffffc0200bf8 <buddy_system_free_pages.part.0+0x1a2>
    return listelm->prev;
ffffffffc0200bd2:	01843d03          	ld	s10,24(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200bd6:	f5a918e3          	bne	s2,s10,ffffffffc0200b26 <buddy_system_free_pages.part.0+0xd0>
    return listelm->next;
ffffffffc0200bda:	7014                	ld	a3,32(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200bdc:	00d90e63          	beq	s2,a3,ffffffffc0200bf8 <buddy_system_free_pages.part.0+0x1a2>
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200be0:	481c                	lw	a5,16(s0)
        struct Page *p = le2page(le, page_link);
ffffffffc0200be2:	fe868613          	addi	a2,a3,-24
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200be6:	00fa973b          	sllw	a4,s5,a5
ffffffffc0200bea:	00271793          	slli	a5,a4,0x2
ffffffffc0200bee:	97ba                	add	a5,a5,a4
ffffffffc0200bf0:	078e                	slli	a5,a5,0x3
ffffffffc0200bf2:	97a2                	add	a5,a5,s0
ffffffffc0200bf4:	02f60163          	beq	a2,a5,ffffffffc0200c16 <buddy_system_free_pages.part.0+0x1c0>
}
ffffffffc0200bf8:	70e6                	ld	ra,120(sp)
ffffffffc0200bfa:	7446                	ld	s0,112(sp)
ffffffffc0200bfc:	74a6                	ld	s1,104(sp)
ffffffffc0200bfe:	7906                	ld	s2,96(sp)
ffffffffc0200c00:	69e6                	ld	s3,88(sp)
ffffffffc0200c02:	6a46                	ld	s4,80(sp)
ffffffffc0200c04:	6aa6                	ld	s5,72(sp)
ffffffffc0200c06:	6b06                	ld	s6,64(sp)
ffffffffc0200c08:	7be2                	ld	s7,56(sp)
ffffffffc0200c0a:	7c42                	ld	s8,48(sp)
ffffffffc0200c0c:	7ca2                	ld	s9,40(sp)
ffffffffc0200c0e:	7d02                	ld	s10,32(sp)
ffffffffc0200c10:	6de2                	ld	s11,24(sp)
ffffffffc0200c12:	6109                	addi	sp,sp,128
ffffffffc0200c14:	8082                	ret
            cprintf("进入merge 和后页合并\n");
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	41250513          	addi	a0,a0,1042 # ffffffffc0202028 <commands+0x750>
ffffffffc0200c1e:	e436                	sd	a3,8(sp)
ffffffffc0200c20:	c92ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            base->property += 1;
ffffffffc0200c24:	481c                	lw	a5,16(s0)
ffffffffc0200c26:	66a2                	ld	a3,8(sp)
ffffffffc0200c28:	5775                	li	a4,-3
ffffffffc0200c2a:	2785                	addiw	a5,a5,1
ffffffffc0200c2c:	c81c                	sw	a5,16(s0)
ffffffffc0200c2e:	ff068793          	addi	a5,a3,-16
ffffffffc0200c32:	60e7b02f          	amoand.d	zero,a4,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c36:	6698                	ld	a4,8(a3)
ffffffffc0200c38:	6290                	ld	a2,0(a3)
            free_area1[order].nr_free -= 2;
ffffffffc0200c3a:	01092783          	lw	a5,16(s2)
            add_page(base,order+1);
ffffffffc0200c3e:	85a6                	mv	a1,s1
    prev->next = next;
ffffffffc0200c40:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200c42:	e310                	sd	a2,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c44:	6c14                	ld	a3,24(s0)
ffffffffc0200c46:	7018                	ld	a4,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200c48:	37f9                	addiw	a5,a5,-2
            add_page(base,order+1);
ffffffffc0200c4a:	8522                	mv	a0,s0
    prev->next = next;
ffffffffc0200c4c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200c4e:	e314                	sd	a3,0(a4)
            free_area1[order].nr_free -= 2;
ffffffffc0200c50:	00f92823          	sw	a5,16(s2)
            add_page(base,order+1);
ffffffffc0200c54:	d49ff0ef          	jal	ra,ffffffffc020099c <add_page>
            free_area1[order].nr_free += 1;
ffffffffc0200c58:	01092783          	lw	a5,16(s2)
ffffffffc0200c5c:	2785                	addiw	a5,a5,1
ffffffffc0200c5e:	00f92823          	sw	a5,16(s2)
    if(has_merge == 1) //成功merge则递归调用上一级merge
ffffffffc0200c62:	b78d                	j	ffffffffc0200bc4 <buddy_system_free_pages.part.0+0x16e>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200c64:	00001697          	auipc	a3,0x1
ffffffffc0200c68:	2b468693          	addi	a3,a3,692 # ffffffffc0201f18 <commands+0x640>
ffffffffc0200c6c:	00001617          	auipc	a2,0x1
ffffffffc0200c70:	2d460613          	addi	a2,a2,724 # ffffffffc0201f40 <commands+0x668>
ffffffffc0200c74:	0ce00593          	li	a1,206
ffffffffc0200c78:	00001517          	auipc	a0,0x1
ffffffffc0200c7c:	2e050513          	addi	a0,a0,736 # ffffffffc0201f58 <commands+0x680>
ffffffffc0200c80:	f2cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c84 <buddy_system_free_pages>:
    assert(n > 0);
ffffffffc0200c84:	c191                	beqz	a1,ffffffffc0200c88 <buddy_system_free_pages+0x4>
ffffffffc0200c86:	bbc1                	j	ffffffffc0200a56 <buddy_system_free_pages.part.0>
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200c88:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c8a:	00001697          	auipc	a3,0x1
ffffffffc0200c8e:	3be68693          	addi	a3,a3,958 # ffffffffc0202048 <commands+0x770>
ffffffffc0200c92:	00001617          	auipc	a2,0x1
ffffffffc0200c96:	2ae60613          	addi	a2,a2,686 # ffffffffc0201f40 <commands+0x668>
ffffffffc0200c9a:	0cb00593          	li	a1,203
ffffffffc0200c9e:	00001517          	auipc	a0,0x1
ffffffffc0200ca2:	2ba50513          	addi	a0,a0,698 # ffffffffc0201f58 <commands+0x680>
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200ca6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ca8:	f04ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cac <buddy_system_alloc_pages.part.0>:
buddy_system_alloc_pages(size_t n) {
ffffffffc0200cac:	7179                	addi	sp,sp,-48
ffffffffc0200cae:	f406                	sd	ra,40(sp)
ffffffffc0200cb0:	f022                	sd	s0,32(sp)
ffffffffc0200cb2:	ec26                	sd	s1,24(sp)
ffffffffc0200cb4:	e84a                	sd	s2,16(sp)
ffffffffc0200cb6:	e44e                	sd	s3,8(sp)
ffffffffc0200cb8:	e052                	sd	s4,0(sp)
    while (n > (1 << (order))) {
ffffffffc0200cba:	4785                	li	a5,1
ffffffffc0200cbc:	0ca7fa63          	bgeu	a5,a0,ffffffffc0200d90 <buddy_system_alloc_pages.part.0+0xe4>
    int order=0;
ffffffffc0200cc0:	4401                	li	s0,0
    while (n > (1 << (order))) {
ffffffffc0200cc2:	4705                	li	a4,1
        order++;
ffffffffc0200cc4:	2405                	addiw	s0,s0,1
    while (n > (1 << (order))) {
ffffffffc0200cc6:	008717bb          	sllw	a5,a4,s0
ffffffffc0200cca:	fea7ede3          	bltu	a5,a0,ffffffffc0200cc4 <buddy_system_alloc_pages.part.0+0x18>
    for (;i<=MAX_ORDER;i++)
ffffffffc0200cce:	47b9                	li	a5,14
ffffffffc0200cd0:	0687ca63          	blt	a5,s0,ffffffffc0200d44 <buddy_system_alloc_pages.part.0+0x98>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200cd4:	00141493          	slli	s1,s0,0x1
ffffffffc0200cd8:	008489b3          	add	s3,s1,s0
ffffffffc0200cdc:	00005917          	auipc	s2,0x5
ffffffffc0200ce0:	33c90913          	addi	s2,s2,828 # ffffffffc0206018 <free_area1>
ffffffffc0200ce4:	098e                	slli	s3,s3,0x3
ffffffffc0200ce6:	99ca                	add	s3,s3,s2
ffffffffc0200ce8:	008487b3          	add	a5,s1,s0
ffffffffc0200cec:	078e                	slli	a5,a5,0x3
ffffffffc0200cee:	97ca                	add	a5,a5,s2
    int order=0;
ffffffffc0200cf0:	8722                	mv	a4,s0
    for (;i<=MAX_ORDER;i++)
ffffffffc0200cf2:	463d                	li	a2,15
ffffffffc0200cf4:	a021                	j	ffffffffc0200cfc <buddy_system_alloc_pages.part.0+0x50>
ffffffffc0200cf6:	07e1                	addi	a5,a5,24
ffffffffc0200cf8:	08c70363          	beq	a4,a2,ffffffffc0200d7e <buddy_system_alloc_pages.part.0+0xd2>
        if(!list_empty(&(free_area1[i].free_list)))
ffffffffc0200cfc:	6794                	ld	a3,8(a5)
    for (;i<=MAX_ORDER;i++)
ffffffffc0200cfe:	2705                	addiw	a4,a4,1
        if(!list_empty(&(free_area1[i].free_list)))
ffffffffc0200d00:	fef68be3          	beq	a3,a5,ffffffffc0200cf6 <buddy_system_alloc_pages.part.0+0x4a>
    return list->next == list;
ffffffffc0200d04:	00848a33          	add	s4,s1,s0
ffffffffc0200d08:	0a0e                	slli	s4,s4,0x3
ffffffffc0200d0a:	9a4a                	add	s4,s4,s2
ffffffffc0200d0c:	008a3783          	ld	a5,8(s4)
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200d10:	05378f63          	beq	a5,s3,ffffffffc0200d6e <buddy_system_alloc_pages.part.0+0xc2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d14:	6798                	ld	a4,8(a5)
ffffffffc0200d16:	6394                	ld	a3,0(a5)
    page= le2page(le, page_link);
ffffffffc0200d18:	fe878513          	addi	a0,a5,-24
ffffffffc0200d1c:	17c1                	addi	a5,a5,-16
    prev->next = next;
ffffffffc0200d1e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200d20:	e314                	sd	a3,0(a4)
ffffffffc0200d22:	5775                	li	a4,-3
ffffffffc0200d24:	60e7b02f          	amoand.d	zero,a4,(a5)
    free_area1[order].nr_free-=1;
ffffffffc0200d28:	9426                	add	s0,s0,s1
ffffffffc0200d2a:	040e                	slli	s0,s0,0x3
ffffffffc0200d2c:	944a                	add	s0,s0,s2
ffffffffc0200d2e:	481c                	lw	a5,16(s0)
}
ffffffffc0200d30:	70a2                	ld	ra,40(sp)
ffffffffc0200d32:	64e2                	ld	s1,24(sp)
    free_area1[order].nr_free-=1;
ffffffffc0200d34:	37fd                	addiw	a5,a5,-1
ffffffffc0200d36:	c81c                	sw	a5,16(s0)
}
ffffffffc0200d38:	7402                	ld	s0,32(sp)
ffffffffc0200d3a:	6942                	ld	s2,16(sp)
ffffffffc0200d3c:	69a2                	ld	s3,8(sp)
ffffffffc0200d3e:	6a02                	ld	s4,0(sp)
ffffffffc0200d40:	6145                	addi	sp,sp,48
ffffffffc0200d42:	8082                	ret
    if(i==MAX_ORDER+1)
ffffffffc0200d44:	47bd                	li	a5,15
ffffffffc0200d46:	02f40c63          	beq	s0,a5,ffffffffc0200d7e <buddy_system_alloc_pages.part.0+0xd2>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200d4a:	00141493          	slli	s1,s0,0x1
    return list->next == list;
ffffffffc0200d4e:	00848a33          	add	s4,s1,s0
ffffffffc0200d52:	00005917          	auipc	s2,0x5
ffffffffc0200d56:	2c690913          	addi	s2,s2,710 # ffffffffc0206018 <free_area1>
ffffffffc0200d5a:	0a0e                	slli	s4,s4,0x3
ffffffffc0200d5c:	9a4a                	add	s4,s4,s2
ffffffffc0200d5e:	008489b3          	add	s3,s1,s0
ffffffffc0200d62:	008a3783          	ld	a5,8(s4)
ffffffffc0200d66:	098e                	slli	s3,s3,0x3
ffffffffc0200d68:	99ca                	add	s3,s3,s2
ffffffffc0200d6a:	fb3795e3          	bne	a5,s3,ffffffffc0200d14 <buddy_system_alloc_pages.part.0+0x68>
         split_page(order + 1);
ffffffffc0200d6e:	0014051b          	addiw	a0,s0,1
ffffffffc0200d72:	b4dff0ef          	jal	ra,ffffffffc02008be <split_page>
ffffffffc0200d76:	008a3783          	ld	a5,8(s4)
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200d7a:	f9379de3          	bne	a5,s3,ffffffffc0200d14 <buddy_system_alloc_pages.part.0+0x68>
}
ffffffffc0200d7e:	70a2                	ld	ra,40(sp)
ffffffffc0200d80:	7402                	ld	s0,32(sp)
ffffffffc0200d82:	64e2                	ld	s1,24(sp)
ffffffffc0200d84:	6942                	ld	s2,16(sp)
ffffffffc0200d86:	69a2                	ld	s3,8(sp)
ffffffffc0200d88:	6a02                	ld	s4,0(sp)
        return NULL;
ffffffffc0200d8a:	4501                	li	a0,0
}
ffffffffc0200d8c:	6145                	addi	sp,sp,48
ffffffffc0200d8e:	8082                	ret
    while (n > (1 << (order))) {
ffffffffc0200d90:	00005917          	auipc	s2,0x5
ffffffffc0200d94:	28890913          	addi	s2,s2,648 # ffffffffc0206018 <free_area1>
ffffffffc0200d98:	89ca                	mv	s3,s2
    int order=0;
ffffffffc0200d9a:	4401                	li	s0,0
ffffffffc0200d9c:	4481                	li	s1,0
ffffffffc0200d9e:	b7a9                	j	ffffffffc0200ce8 <buddy_system_alloc_pages.part.0+0x3c>

ffffffffc0200da0 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0200da0:	c519                	beqz	a0,ffffffffc0200dae <buddy_system_alloc_pages+0xe>
    if (n > (1 << (MAX_ORDER))) {
ffffffffc0200da2:	6711                	lui	a4,0x4
ffffffffc0200da4:	00a76363          	bltu	a4,a0,ffffffffc0200daa <buddy_system_alloc_pages+0xa>
ffffffffc0200da8:	b711                	j	ffffffffc0200cac <buddy_system_alloc_pages.part.0>
}
ffffffffc0200daa:	4501                	li	a0,0
ffffffffc0200dac:	8082                	ret
buddy_system_alloc_pages(size_t n) {
ffffffffc0200dae:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200db0:	00001697          	auipc	a3,0x1
ffffffffc0200db4:	29868693          	addi	a3,a3,664 # ffffffffc0202048 <commands+0x770>
ffffffffc0200db8:	00001617          	auipc	a2,0x1
ffffffffc0200dbc:	18860613          	addi	a2,a2,392 # ffffffffc0201f40 <commands+0x668>
ffffffffc0200dc0:	04b00593          	li	a1,75
ffffffffc0200dc4:	00001517          	auipc	a0,0x1
ffffffffc0200dc8:	19450513          	addi	a0,a0,404 # ffffffffc0201f58 <commands+0x680>
buddy_system_alloc_pages(size_t n) {
ffffffffc0200dcc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200dce:	ddeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200dd2 <buddy_system_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
ffffffffc0200dd2:	715d                	addi	sp,sp,-80
ffffffffc0200dd4:	fc26                	sd	s1,56(sp)
    cprintf("Starting buddy_system_basic_check...\n");
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	27a50513          	addi	a0,a0,634 # ffffffffc0202050 <commands+0x778>
ffffffffc0200dde:	00005497          	auipc	s1,0x5
ffffffffc0200de2:	24a48493          	addi	s1,s1,586 # ffffffffc0206028 <free_area1+0x10>
buddy_system_check(void) {
ffffffffc0200de6:	e0a2                	sd	s0,64(sp)
ffffffffc0200de8:	f84a                	sd	s2,48(sp)
ffffffffc0200dea:	f44e                	sd	s3,40(sp)
ffffffffc0200dec:	f052                	sd	s4,32(sp)
ffffffffc0200dee:	e486                	sd	ra,72(sp)
ffffffffc0200df0:	ec56                	sd	s5,24(sp)
ffffffffc0200df2:	e85a                	sd	s6,16(sp)
ffffffffc0200df4:	e45e                	sd	s7,8(sp)
    cprintf("Starting buddy_system_basic_check...\n");
ffffffffc0200df6:	8926                	mv	s2,s1
ffffffffc0200df8:	abaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200dfc:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200dfe:	00001a17          	auipc	s4,0x1
ffffffffc0200e02:	27aa0a13          	addi	s4,s4,634 # ffffffffc0202078 <commands+0x7a0>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e06:	49bd                	li	s3,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e08:	00092603          	lw	a2,0(s2)
ffffffffc0200e0c:	85a2                	mv	a1,s0
ffffffffc0200e0e:	8552                	mv	a0,s4
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e10:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e12:	aa0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e16:	0961                	addi	s2,s2,24
ffffffffc0200e18:	ff3418e3          	bne	s0,s3,ffffffffc0200e08 <buddy_system_check+0x36>
    if (n > (1 << (MAX_ORDER))) {
ffffffffc0200e1c:	4521                	li	a0,8
ffffffffc0200e1e:	e8fff0ef          	jal	ra,ffffffffc0200cac <buddy_system_alloc_pages.part.0>
ffffffffc0200e22:	8aaa                	mv	s5,a0
ffffffffc0200e24:	4521                	li	a0,8
ffffffffc0200e26:	e87ff0ef          	jal	ra,ffffffffc0200cac <buddy_system_alloc_pages.part.0>
ffffffffc0200e2a:	8baa                	mv	s7,a0
ffffffffc0200e2c:	4521                	li	a0,8
ffffffffc0200e2e:	e7fff0ef          	jal	ra,ffffffffc0200cac <buddy_system_alloc_pages.part.0>
ffffffffc0200e32:	8b2a                	mv	s6,a0
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e34:	00005917          	auipc	s2,0x5
ffffffffc0200e38:	1f490913          	addi	s2,s2,500 # ffffffffc0206028 <free_area1+0x10>
ffffffffc0200e3c:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e3e:	00001a17          	auipc	s4,0x1
ffffffffc0200e42:	23aa0a13          	addi	s4,s4,570 # ffffffffc0202078 <commands+0x7a0>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e46:	49bd                	li	s3,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e48:	00092603          	lw	a2,0(s2)
ffffffffc0200e4c:	85a2                	mv	a1,s0
ffffffffc0200e4e:	8552                	mv	a0,s4
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e50:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e52:	a60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e56:	0961                	addi	s2,s2,24
ffffffffc0200e58:	ff3418e3          	bne	s0,s3,ffffffffc0200e48 <buddy_system_check+0x76>
    assert(n > 0);
ffffffffc0200e5c:	45a1                	li	a1,8
ffffffffc0200e5e:	855e                	mv	a0,s7
ffffffffc0200e60:	bf7ff0ef          	jal	ra,ffffffffc0200a56 <buddy_system_free_pages.part.0>
ffffffffc0200e64:	45a1                	li	a1,8
ffffffffc0200e66:	855a                	mv	a0,s6
ffffffffc0200e68:	befff0ef          	jal	ra,ffffffffc0200a56 <buddy_system_free_pages.part.0>
ffffffffc0200e6c:	45a1                	li	a1,8
ffffffffc0200e6e:	8556                	mv	a0,s5
ffffffffc0200e70:	be7ff0ef          	jal	ra,ffffffffc0200a56 <buddy_system_free_pages.part.0>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e74:	4401                	li	s0,0
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e76:	00001997          	auipc	s3,0x1
ffffffffc0200e7a:	20298993          	addi	s3,s3,514 # ffffffffc0202078 <commands+0x7a0>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e7e:	493d                	li	s2,15
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e80:	4090                	lw	a2,0(s1)
ffffffffc0200e82:	85a2                	mv	a1,s0
ffffffffc0200e84:	854e                	mv	a0,s3
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e86:	2405                	addiw	s0,s0,1
        cprintf(" di %d jie you %d ge \n",i,free_area1[i].nr_free);
ffffffffc0200e88:	a2aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200e8c:	04e1                	addi	s1,s1,24
ffffffffc0200e8e:	ff2419e3          	bne	s0,s2,ffffffffc0200e80 <buddy_system_check+0xae>
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
ffffffffc0200e92:	60a6                	ld	ra,72(sp)
ffffffffc0200e94:	6406                	ld	s0,64(sp)
ffffffffc0200e96:	74e2                	ld	s1,56(sp)
ffffffffc0200e98:	7942                	ld	s2,48(sp)
ffffffffc0200e9a:	79a2                	ld	s3,40(sp)
ffffffffc0200e9c:	7a02                	ld	s4,32(sp)
ffffffffc0200e9e:	6ae2                	ld	s5,24(sp)
ffffffffc0200ea0:	6b42                	ld	s6,16(sp)
ffffffffc0200ea2:	6ba2                	ld	s7,8(sp)
ffffffffc0200ea4:	6161                	addi	sp,sp,80
ffffffffc0200ea6:	8082                	ret

ffffffffc0200ea8 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200ea8:	1141                	addi	sp,sp,-16
ffffffffc0200eaa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200eac:	c9d5                	beqz	a1,ffffffffc0200f60 <buddy_system_init_memmap+0xb8>
    for (; p != base + n; p ++) {
ffffffffc0200eae:	00259693          	slli	a3,a1,0x2
ffffffffc0200eb2:	96ae                	add	a3,a3,a1
ffffffffc0200eb4:	068e                	slli	a3,a3,0x3
ffffffffc0200eb6:	96aa                	add	a3,a3,a0
ffffffffc0200eb8:	87aa                	mv	a5,a0
ffffffffc0200eba:	00d50f63          	beq	a0,a3,ffffffffc0200ed8 <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ebe:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200ec0:	8b05                	andi	a4,a4,1
ffffffffc0200ec2:	c341                	beqz	a4,ffffffffc0200f42 <buddy_system_init_memmap+0x9a>
        p->flags = p->property = 0;
ffffffffc0200ec4:	0007a823          	sw	zero,16(a5)
ffffffffc0200ec8:	0007b423          	sd	zero,8(a5)
ffffffffc0200ecc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200ed0:	02878793          	addi	a5,a5,40
ffffffffc0200ed4:	fed795e3          	bne	a5,a3,ffffffffc0200ebe <buddy_system_init_memmap+0x16>
ffffffffc0200ed8:	00005e17          	auipc	t3,0x5
ffffffffc0200edc:	140e0e13          	addi	t3,t3,320 # ffffffffc0206018 <free_area1>
        while (remain >= (1 << (order))) {
ffffffffc0200ee0:	4605                	li	a2,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ee2:	4309                	li	t1,2
        int order=0;
ffffffffc0200ee4:	4781                	li	a5,0
        order++;
ffffffffc0200ee6:	86be                	mv	a3,a5
ffffffffc0200ee8:	2785                	addiw	a5,a5,1
        while (remain >= (1 << (order))) {
ffffffffc0200eea:	00f6173b          	sllw	a4,a2,a5
ffffffffc0200eee:	fee5fce3          	bgeu	a1,a4,ffffffffc0200ee6 <buddy_system_init_memmap+0x3e>
        p=p+(1<<(order));
ffffffffc0200ef2:	00d6183b          	sllw	a6,a2,a3
ffffffffc0200ef6:	00281793          	slli	a5,a6,0x2
ffffffffc0200efa:	97c2                	add	a5,a5,a6
ffffffffc0200efc:	078e                	slli	a5,a5,0x3
ffffffffc0200efe:	00f50733          	add	a4,a0,a5
        remain=remain-(1<<(order));
ffffffffc0200f02:	410585b3          	sub	a1,a1,a6
        p->property=order;
ffffffffc0200f06:	c914                	sw	a3,16(a0)
ffffffffc0200f08:	00850793          	addi	a5,a0,8
ffffffffc0200f0c:	4067b02f          	amoor.d	zero,t1,(a5)
        free_area1[order].nr_free+=1;
ffffffffc0200f10:	00169793          	slli	a5,a3,0x1
ffffffffc0200f14:	96be                	add	a3,a3,a5
ffffffffc0200f16:	068e                	slli	a3,a3,0x3
ffffffffc0200f18:	96f2                	add	a3,a3,t3
ffffffffc0200f1a:	4a9c                	lw	a5,16(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f1c:	0086b803          	ld	a6,8(a3)
        list_add(&(free_area1[order].free_list), &(p->page_link));
ffffffffc0200f20:	01850893          	addi	a7,a0,24
        free_area1[order].nr_free+=1;
ffffffffc0200f24:	2785                	addiw	a5,a5,1
ffffffffc0200f26:	ca9c                	sw	a5,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200f28:	01183023          	sd	a7,0(a6)
ffffffffc0200f2c:	0116b423          	sd	a7,8(a3)
    elm->next = next;
ffffffffc0200f30:	03053023          	sd	a6,32(a0)
    elm->prev = prev;
ffffffffc0200f34:	ed14                	sd	a3,24(a0)
    while(remain!=0)
ffffffffc0200f36:	c199                	beqz	a1,ffffffffc0200f3c <buddy_system_init_memmap+0x94>
        p=p+(1<<(order));
ffffffffc0200f38:	853a                	mv	a0,a4
ffffffffc0200f3a:	b76d                	j	ffffffffc0200ee4 <buddy_system_init_memmap+0x3c>
}
ffffffffc0200f3c:	60a2                	ld	ra,8(sp)
ffffffffc0200f3e:	0141                	addi	sp,sp,16
ffffffffc0200f40:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	14e68693          	addi	a3,a3,334 # ffffffffc0202090 <commands+0x7b8>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	ff660613          	addi	a2,a2,-10 # ffffffffc0201f40 <commands+0x668>
ffffffffc0200f52:	45ed                	li	a1,27
ffffffffc0200f54:	00001517          	auipc	a0,0x1
ffffffffc0200f58:	00450513          	addi	a0,a0,4 # ffffffffc0201f58 <commands+0x680>
ffffffffc0200f5c:	c50ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200f60:	00001697          	auipc	a3,0x1
ffffffffc0200f64:	0e868693          	addi	a3,a3,232 # ffffffffc0202048 <commands+0x770>
ffffffffc0200f68:	00001617          	auipc	a2,0x1
ffffffffc0200f6c:	fd860613          	addi	a2,a2,-40 # ffffffffc0201f40 <commands+0x668>
ffffffffc0200f70:	45e1                	li	a1,24
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	fe650513          	addi	a0,a0,-26 # ffffffffc0201f58 <commands+0x680>
ffffffffc0200f7a:	c32ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f7e <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f7e:	00001797          	auipc	a5,0x1
ffffffffc0200f82:	14278793          	addi	a5,a5,322 # ffffffffc02020c0 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f86:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f88:	1101                	addi	sp,sp,-32
ffffffffc0200f8a:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f8c:	00001517          	auipc	a0,0x1
ffffffffc0200f90:	16c50513          	addi	a0,a0,364 # ffffffffc02020f8 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f94:	00005497          	auipc	s1,0x5
ffffffffc0200f98:	61448493          	addi	s1,s1,1556 # ffffffffc02065a8 <pmm_manager>
void pmm_init(void) {
ffffffffc0200f9c:	ec06                	sd	ra,24(sp)
ffffffffc0200f9e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200fa0:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fa2:	910ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200fa6:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fa8:	00005417          	auipc	s0,0x5
ffffffffc0200fac:	61840413          	addi	s0,s0,1560 # ffffffffc02065c0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fb0:	679c                	ld	a5,8(a5)
ffffffffc0200fb2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fb4:	57f5                	li	a5,-3
ffffffffc0200fb6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fb8:	00001517          	auipc	a0,0x1
ffffffffc0200fbc:	15850513          	addi	a0,a0,344 # ffffffffc0202110 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fc0:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200fc2:	8f0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200fc6:	46c5                	li	a3,17
ffffffffc0200fc8:	06ee                	slli	a3,a3,0x1b
ffffffffc0200fca:	40100613          	li	a2,1025
ffffffffc0200fce:	16fd                	addi	a3,a3,-1
ffffffffc0200fd0:	07e005b7          	lui	a1,0x7e00
ffffffffc0200fd4:	0656                	slli	a2,a2,0x15
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	15250513          	addi	a0,a0,338 # ffffffffc0202128 <buddy_system_pmm_manager+0x68>
ffffffffc0200fde:	8d4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200fe2:	777d                	lui	a4,0xfffff
ffffffffc0200fe4:	00006797          	auipc	a5,0x6
ffffffffc0200fe8:	5eb78793          	addi	a5,a5,1515 # ffffffffc02075cf <end+0xfff>
ffffffffc0200fec:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200fee:	00005517          	auipc	a0,0x5
ffffffffc0200ff2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206598 <npage>
ffffffffc0200ff6:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ffa:	00005597          	auipc	a1,0x5
ffffffffc0200ffe:	5a658593          	addi	a1,a1,1446 # ffffffffc02065a0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201002:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201004:	e19c                	sd	a5,0(a1)
ffffffffc0201006:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201008:	4701                	li	a4,0
ffffffffc020100a:	4885                	li	a7,1
ffffffffc020100c:	fff80837          	lui	a6,0xfff80
ffffffffc0201010:	a011                	j	ffffffffc0201014 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201012:	619c                	ld	a5,0(a1)
ffffffffc0201014:	97b6                	add	a5,a5,a3
ffffffffc0201016:	07a1                	addi	a5,a5,8
ffffffffc0201018:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020101c:	611c                	ld	a5,0(a0)
ffffffffc020101e:	0705                	addi	a4,a4,1
ffffffffc0201020:	02868693          	addi	a3,a3,40
ffffffffc0201024:	01078633          	add	a2,a5,a6
ffffffffc0201028:	fec765e3          	bltu	a4,a2,ffffffffc0201012 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020102c:	6190                	ld	a2,0(a1)
ffffffffc020102e:	00279713          	slli	a4,a5,0x2
ffffffffc0201032:	973e                	add	a4,a4,a5
ffffffffc0201034:	fec006b7          	lui	a3,0xfec00
ffffffffc0201038:	070e                	slli	a4,a4,0x3
ffffffffc020103a:	96b2                	add	a3,a3,a2
ffffffffc020103c:	96ba                	add	a3,a3,a4
ffffffffc020103e:	c0200737          	lui	a4,0xc0200
ffffffffc0201042:	08e6ef63          	bltu	a3,a4,ffffffffc02010e0 <pmm_init+0x162>
ffffffffc0201046:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201048:	45c5                	li	a1,17
ffffffffc020104a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020104c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020104e:	04b6e863          	bltu	a3,a1,ffffffffc020109e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201052:	609c                	ld	a5,0(s1)
ffffffffc0201054:	7b9c                	ld	a5,48(a5)
ffffffffc0201056:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201058:	00001517          	auipc	a0,0x1
ffffffffc020105c:	16850513          	addi	a0,a0,360 # ffffffffc02021c0 <buddy_system_pmm_manager+0x100>
ffffffffc0201060:	852ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201064:	00004597          	auipc	a1,0x4
ffffffffc0201068:	f9c58593          	addi	a1,a1,-100 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020106c:	00005797          	auipc	a5,0x5
ffffffffc0201070:	54b7b623          	sd	a1,1356(a5) # ffffffffc02065b8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201074:	c02007b7          	lui	a5,0xc0200
ffffffffc0201078:	08f5e063          	bltu	a1,a5,ffffffffc02010f8 <pmm_init+0x17a>
ffffffffc020107c:	6010                	ld	a2,0(s0)
}
ffffffffc020107e:	6442                	ld	s0,16(sp)
ffffffffc0201080:	60e2                	ld	ra,24(sp)
ffffffffc0201082:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201084:	40c58633          	sub	a2,a1,a2
ffffffffc0201088:	00005797          	auipc	a5,0x5
ffffffffc020108c:	52c7b423          	sd	a2,1320(a5) # ffffffffc02065b0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201090:	00001517          	auipc	a0,0x1
ffffffffc0201094:	15050513          	addi	a0,a0,336 # ffffffffc02021e0 <buddy_system_pmm_manager+0x120>
}
ffffffffc0201098:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020109a:	818ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020109e:	6705                	lui	a4,0x1
ffffffffc02010a0:	177d                	addi	a4,a4,-1
ffffffffc02010a2:	96ba                	add	a3,a3,a4
ffffffffc02010a4:	777d                	lui	a4,0xfffff
ffffffffc02010a6:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010a8:	00c6d513          	srli	a0,a3,0xc
ffffffffc02010ac:	00f57e63          	bgeu	a0,a5,ffffffffc02010c8 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02010b0:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010b2:	982a                	add	a6,a6,a0
ffffffffc02010b4:	00281513          	slli	a0,a6,0x2
ffffffffc02010b8:	9542                	add	a0,a0,a6
ffffffffc02010ba:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010bc:	8d95                	sub	a1,a1,a3
ffffffffc02010be:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010c0:	81b1                	srli	a1,a1,0xc
ffffffffc02010c2:	9532                	add	a0,a0,a2
ffffffffc02010c4:	9782                	jalr	a5
}
ffffffffc02010c6:	b771                	j	ffffffffc0201052 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02010c8:	00001617          	auipc	a2,0x1
ffffffffc02010cc:	0c860613          	addi	a2,a2,200 # ffffffffc0202190 <buddy_system_pmm_manager+0xd0>
ffffffffc02010d0:	06b00593          	li	a1,107
ffffffffc02010d4:	00001517          	auipc	a0,0x1
ffffffffc02010d8:	0dc50513          	addi	a0,a0,220 # ffffffffc02021b0 <buddy_system_pmm_manager+0xf0>
ffffffffc02010dc:	ad0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010e0:	00001617          	auipc	a2,0x1
ffffffffc02010e4:	07860613          	addi	a2,a2,120 # ffffffffc0202158 <buddy_system_pmm_manager+0x98>
ffffffffc02010e8:	06f00593          	li	a1,111
ffffffffc02010ec:	00001517          	auipc	a0,0x1
ffffffffc02010f0:	09450513          	addi	a0,a0,148 # ffffffffc0202180 <buddy_system_pmm_manager+0xc0>
ffffffffc02010f4:	ab8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010f8:	86ae                	mv	a3,a1
ffffffffc02010fa:	00001617          	auipc	a2,0x1
ffffffffc02010fe:	05e60613          	addi	a2,a2,94 # ffffffffc0202158 <buddy_system_pmm_manager+0x98>
ffffffffc0201102:	08a00593          	li	a1,138
ffffffffc0201106:	00001517          	auipc	a0,0x1
ffffffffc020110a:	07a50513          	addi	a0,a0,122 # ffffffffc0202180 <buddy_system_pmm_manager+0xc0>
ffffffffc020110e:	a9eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201112 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201112:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201116:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201118:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020111c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020111e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201122:	f022                	sd	s0,32(sp)
ffffffffc0201124:	ec26                	sd	s1,24(sp)
ffffffffc0201126:	e84a                	sd	s2,16(sp)
ffffffffc0201128:	f406                	sd	ra,40(sp)
ffffffffc020112a:	e44e                	sd	s3,8(sp)
ffffffffc020112c:	84aa                	mv	s1,a0
ffffffffc020112e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201130:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201134:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201136:	03067e63          	bgeu	a2,a6,ffffffffc0201172 <printnum+0x60>
ffffffffc020113a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020113c:	00805763          	blez	s0,ffffffffc020114a <printnum+0x38>
ffffffffc0201140:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201142:	85ca                	mv	a1,s2
ffffffffc0201144:	854e                	mv	a0,s3
ffffffffc0201146:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201148:	fc65                	bnez	s0,ffffffffc0201140 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020114a:	1a02                	slli	s4,s4,0x20
ffffffffc020114c:	00001797          	auipc	a5,0x1
ffffffffc0201150:	0d478793          	addi	a5,a5,212 # ffffffffc0202220 <buddy_system_pmm_manager+0x160>
ffffffffc0201154:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201158:	9a3e                	add	s4,s4,a5
}
ffffffffc020115a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020115c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201160:	70a2                	ld	ra,40(sp)
ffffffffc0201162:	69a2                	ld	s3,8(sp)
ffffffffc0201164:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201166:	85ca                	mv	a1,s2
ffffffffc0201168:	87a6                	mv	a5,s1
}
ffffffffc020116a:	6942                	ld	s2,16(sp)
ffffffffc020116c:	64e2                	ld	s1,24(sp)
ffffffffc020116e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201170:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201172:	03065633          	divu	a2,a2,a6
ffffffffc0201176:	8722                	mv	a4,s0
ffffffffc0201178:	f9bff0ef          	jal	ra,ffffffffc0201112 <printnum>
ffffffffc020117c:	b7f9                	j	ffffffffc020114a <printnum+0x38>

ffffffffc020117e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020117e:	7119                	addi	sp,sp,-128
ffffffffc0201180:	f4a6                	sd	s1,104(sp)
ffffffffc0201182:	f0ca                	sd	s2,96(sp)
ffffffffc0201184:	ecce                	sd	s3,88(sp)
ffffffffc0201186:	e8d2                	sd	s4,80(sp)
ffffffffc0201188:	e4d6                	sd	s5,72(sp)
ffffffffc020118a:	e0da                	sd	s6,64(sp)
ffffffffc020118c:	fc5e                	sd	s7,56(sp)
ffffffffc020118e:	f06a                	sd	s10,32(sp)
ffffffffc0201190:	fc86                	sd	ra,120(sp)
ffffffffc0201192:	f8a2                	sd	s0,112(sp)
ffffffffc0201194:	f862                	sd	s8,48(sp)
ffffffffc0201196:	f466                	sd	s9,40(sp)
ffffffffc0201198:	ec6e                	sd	s11,24(sp)
ffffffffc020119a:	892a                	mv	s2,a0
ffffffffc020119c:	84ae                	mv	s1,a1
ffffffffc020119e:	8d32                	mv	s10,a2
ffffffffc02011a0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011a2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011a6:	5b7d                	li	s6,-1
ffffffffc02011a8:	00001a97          	auipc	s5,0x1
ffffffffc02011ac:	0aca8a93          	addi	s5,s5,172 # ffffffffc0202254 <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011b0:	00001b97          	auipc	s7,0x1
ffffffffc02011b4:	280b8b93          	addi	s7,s7,640 # ffffffffc0202430 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011b8:	000d4503          	lbu	a0,0(s10)
ffffffffc02011bc:	001d0413          	addi	s0,s10,1
ffffffffc02011c0:	01350a63          	beq	a0,s3,ffffffffc02011d4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02011c4:	c121                	beqz	a0,ffffffffc0201204 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02011c6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011c8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011ca:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011cc:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011d0:	ff351ae3          	bne	a0,s3,ffffffffc02011c4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011d4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011d8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011dc:	4c81                	li	s9,0
ffffffffc02011de:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02011e0:	5c7d                	li	s8,-1
ffffffffc02011e2:	5dfd                	li	s11,-1
ffffffffc02011e4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02011e8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ea:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02011ee:	0ff5f593          	zext.b	a1,a1
ffffffffc02011f2:	00140d13          	addi	s10,s0,1
ffffffffc02011f6:	04b56263          	bltu	a0,a1,ffffffffc020123a <vprintfmt+0xbc>
ffffffffc02011fa:	058a                	slli	a1,a1,0x2
ffffffffc02011fc:	95d6                	add	a1,a1,s5
ffffffffc02011fe:	4194                	lw	a3,0(a1)
ffffffffc0201200:	96d6                	add	a3,a3,s5
ffffffffc0201202:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201204:	70e6                	ld	ra,120(sp)
ffffffffc0201206:	7446                	ld	s0,112(sp)
ffffffffc0201208:	74a6                	ld	s1,104(sp)
ffffffffc020120a:	7906                	ld	s2,96(sp)
ffffffffc020120c:	69e6                	ld	s3,88(sp)
ffffffffc020120e:	6a46                	ld	s4,80(sp)
ffffffffc0201210:	6aa6                	ld	s5,72(sp)
ffffffffc0201212:	6b06                	ld	s6,64(sp)
ffffffffc0201214:	7be2                	ld	s7,56(sp)
ffffffffc0201216:	7c42                	ld	s8,48(sp)
ffffffffc0201218:	7ca2                	ld	s9,40(sp)
ffffffffc020121a:	7d02                	ld	s10,32(sp)
ffffffffc020121c:	6de2                	ld	s11,24(sp)
ffffffffc020121e:	6109                	addi	sp,sp,128
ffffffffc0201220:	8082                	ret
            padc = '0';
ffffffffc0201222:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201224:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201228:	846a                	mv	s0,s10
ffffffffc020122a:	00140d13          	addi	s10,s0,1
ffffffffc020122e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201232:	0ff5f593          	zext.b	a1,a1
ffffffffc0201236:	fcb572e3          	bgeu	a0,a1,ffffffffc02011fa <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020123a:	85a6                	mv	a1,s1
ffffffffc020123c:	02500513          	li	a0,37
ffffffffc0201240:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201242:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201246:	8d22                	mv	s10,s0
ffffffffc0201248:	f73788e3          	beq	a5,s3,ffffffffc02011b8 <vprintfmt+0x3a>
ffffffffc020124c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201250:	1d7d                	addi	s10,s10,-1
ffffffffc0201252:	ff379de3          	bne	a5,s3,ffffffffc020124c <vprintfmt+0xce>
ffffffffc0201256:	b78d                	j	ffffffffc02011b8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201258:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020125c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201260:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201262:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201266:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020126a:	02d86463          	bltu	a6,a3,ffffffffc0201292 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020126e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201272:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201276:	0186873b          	addw	a4,a3,s8
ffffffffc020127a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020127e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201280:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201284:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201286:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020128a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020128e:	fed870e3          	bgeu	a6,a3,ffffffffc020126e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201292:	f40ddce3          	bgez	s11,ffffffffc02011ea <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201296:	8de2                	mv	s11,s8
ffffffffc0201298:	5c7d                	li	s8,-1
ffffffffc020129a:	bf81                	j	ffffffffc02011ea <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020129c:	fffdc693          	not	a3,s11
ffffffffc02012a0:	96fd                	srai	a3,a3,0x3f
ffffffffc02012a2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012a6:	00144603          	lbu	a2,1(s0)
ffffffffc02012aa:	2d81                	sext.w	s11,s11
ffffffffc02012ac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012ae:	bf35                	j	ffffffffc02011ea <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02012b0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012b4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012b8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ba:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02012bc:	bfd9                	j	ffffffffc0201292 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02012be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012c4:	01174463          	blt	a4,a7,ffffffffc02012cc <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02012c8:	1a088e63          	beqz	a7,ffffffffc0201484 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02012cc:	000a3603          	ld	a2,0(s4)
ffffffffc02012d0:	46c1                	li	a3,16
ffffffffc02012d2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012d4:	2781                	sext.w	a5,a5
ffffffffc02012d6:	876e                	mv	a4,s11
ffffffffc02012d8:	85a6                	mv	a1,s1
ffffffffc02012da:	854a                	mv	a0,s2
ffffffffc02012dc:	e37ff0ef          	jal	ra,ffffffffc0201112 <printnum>
            break;
ffffffffc02012e0:	bde1                	j	ffffffffc02011b8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02012e2:	000a2503          	lw	a0,0(s4)
ffffffffc02012e6:	85a6                	mv	a1,s1
ffffffffc02012e8:	0a21                	addi	s4,s4,8
ffffffffc02012ea:	9902                	jalr	s2
            break;
ffffffffc02012ec:	b5f1                	j	ffffffffc02011b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012f4:	01174463          	blt	a4,a7,ffffffffc02012fc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02012f8:	18088163          	beqz	a7,ffffffffc020147a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02012fc:	000a3603          	ld	a2,0(s4)
ffffffffc0201300:	46a9                	li	a3,10
ffffffffc0201302:	8a2e                	mv	s4,a1
ffffffffc0201304:	bfc1                	j	ffffffffc02012d4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201306:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020130a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020130c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020130e:	bdf1                	j	ffffffffc02011ea <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201310:	85a6                	mv	a1,s1
ffffffffc0201312:	02500513          	li	a0,37
ffffffffc0201316:	9902                	jalr	s2
            break;
ffffffffc0201318:	b545                	j	ffffffffc02011b8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020131a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020131e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201320:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201322:	b5e1                	j	ffffffffc02011ea <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201324:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201326:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020132a:	01174463          	blt	a4,a7,ffffffffc0201332 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020132e:	14088163          	beqz	a7,ffffffffc0201470 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201332:	000a3603          	ld	a2,0(s4)
ffffffffc0201336:	46a1                	li	a3,8
ffffffffc0201338:	8a2e                	mv	s4,a1
ffffffffc020133a:	bf69                	j	ffffffffc02012d4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020133c:	03000513          	li	a0,48
ffffffffc0201340:	85a6                	mv	a1,s1
ffffffffc0201342:	e03e                	sd	a5,0(sp)
ffffffffc0201344:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201346:	85a6                	mv	a1,s1
ffffffffc0201348:	07800513          	li	a0,120
ffffffffc020134c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020134e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201350:	6782                	ld	a5,0(sp)
ffffffffc0201352:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201354:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201358:	bfb5                	j	ffffffffc02012d4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020135a:	000a3403          	ld	s0,0(s4)
ffffffffc020135e:	008a0713          	addi	a4,s4,8
ffffffffc0201362:	e03a                	sd	a4,0(sp)
ffffffffc0201364:	14040263          	beqz	s0,ffffffffc02014a8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201368:	0fb05763          	blez	s11,ffffffffc0201456 <vprintfmt+0x2d8>
ffffffffc020136c:	02d00693          	li	a3,45
ffffffffc0201370:	0cd79163          	bne	a5,a3,ffffffffc0201432 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201374:	00044783          	lbu	a5,0(s0)
ffffffffc0201378:	0007851b          	sext.w	a0,a5
ffffffffc020137c:	cf85                	beqz	a5,ffffffffc02013b4 <vprintfmt+0x236>
ffffffffc020137e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201382:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201386:	000c4563          	bltz	s8,ffffffffc0201390 <vprintfmt+0x212>
ffffffffc020138a:	3c7d                	addiw	s8,s8,-1
ffffffffc020138c:	036c0263          	beq	s8,s6,ffffffffc02013b0 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201390:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201392:	0e0c8e63          	beqz	s9,ffffffffc020148e <vprintfmt+0x310>
ffffffffc0201396:	3781                	addiw	a5,a5,-32
ffffffffc0201398:	0ef47b63          	bgeu	s0,a5,ffffffffc020148e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020139c:	03f00513          	li	a0,63
ffffffffc02013a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013a2:	000a4783          	lbu	a5,0(s4)
ffffffffc02013a6:	3dfd                	addiw	s11,s11,-1
ffffffffc02013a8:	0a05                	addi	s4,s4,1
ffffffffc02013aa:	0007851b          	sext.w	a0,a5
ffffffffc02013ae:	ffe1                	bnez	a5,ffffffffc0201386 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02013b0:	01b05963          	blez	s11,ffffffffc02013c2 <vprintfmt+0x244>
ffffffffc02013b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013b6:	85a6                	mv	a1,s1
ffffffffc02013b8:	02000513          	li	a0,32
ffffffffc02013bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02013be:	fe0d9be3          	bnez	s11,ffffffffc02013b4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013c2:	6a02                	ld	s4,0(sp)
ffffffffc02013c4:	bbd5                	j	ffffffffc02011b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013c8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02013cc:	01174463          	blt	a4,a7,ffffffffc02013d4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02013d0:	08088d63          	beqz	a7,ffffffffc020146a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02013d4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02013d8:	0a044d63          	bltz	s0,ffffffffc0201492 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02013dc:	8622                	mv	a2,s0
ffffffffc02013de:	8a66                	mv	s4,s9
ffffffffc02013e0:	46a9                	li	a3,10
ffffffffc02013e2:	bdcd                	j	ffffffffc02012d4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02013e4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013e8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02013ea:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02013ec:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02013f0:	8fb5                	xor	a5,a5,a3
ffffffffc02013f2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013f6:	02d74163          	blt	a4,a3,ffffffffc0201418 <vprintfmt+0x29a>
ffffffffc02013fa:	00369793          	slli	a5,a3,0x3
ffffffffc02013fe:	97de                	add	a5,a5,s7
ffffffffc0201400:	639c                	ld	a5,0(a5)
ffffffffc0201402:	cb99                	beqz	a5,ffffffffc0201418 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201404:	86be                	mv	a3,a5
ffffffffc0201406:	00001617          	auipc	a2,0x1
ffffffffc020140a:	e4a60613          	addi	a2,a2,-438 # ffffffffc0202250 <buddy_system_pmm_manager+0x190>
ffffffffc020140e:	85a6                	mv	a1,s1
ffffffffc0201410:	854a                	mv	a0,s2
ffffffffc0201412:	0ce000ef          	jal	ra,ffffffffc02014e0 <printfmt>
ffffffffc0201416:	b34d                	j	ffffffffc02011b8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201418:	00001617          	auipc	a2,0x1
ffffffffc020141c:	e2860613          	addi	a2,a2,-472 # ffffffffc0202240 <buddy_system_pmm_manager+0x180>
ffffffffc0201420:	85a6                	mv	a1,s1
ffffffffc0201422:	854a                	mv	a0,s2
ffffffffc0201424:	0bc000ef          	jal	ra,ffffffffc02014e0 <printfmt>
ffffffffc0201428:	bb41                	j	ffffffffc02011b8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020142a:	00001417          	auipc	s0,0x1
ffffffffc020142e:	e0e40413          	addi	s0,s0,-498 # ffffffffc0202238 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201432:	85e2                	mv	a1,s8
ffffffffc0201434:	8522                	mv	a0,s0
ffffffffc0201436:	e43e                	sd	a5,8(sp)
ffffffffc0201438:	1e6000ef          	jal	ra,ffffffffc020161e <strnlen>
ffffffffc020143c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201440:	01b05b63          	blez	s11,ffffffffc0201456 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201444:	67a2                	ld	a5,8(sp)
ffffffffc0201446:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020144a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020144c:	85a6                	mv	a1,s1
ffffffffc020144e:	8552                	mv	a0,s4
ffffffffc0201450:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201452:	fe0d9ce3          	bnez	s11,ffffffffc020144a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201456:	00044783          	lbu	a5,0(s0)
ffffffffc020145a:	00140a13          	addi	s4,s0,1
ffffffffc020145e:	0007851b          	sext.w	a0,a5
ffffffffc0201462:	d3a5                	beqz	a5,ffffffffc02013c2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201464:	05e00413          	li	s0,94
ffffffffc0201468:	bf39                	j	ffffffffc0201386 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020146a:	000a2403          	lw	s0,0(s4)
ffffffffc020146e:	b7ad                	j	ffffffffc02013d8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201470:	000a6603          	lwu	a2,0(s4)
ffffffffc0201474:	46a1                	li	a3,8
ffffffffc0201476:	8a2e                	mv	s4,a1
ffffffffc0201478:	bdb1                	j	ffffffffc02012d4 <vprintfmt+0x156>
ffffffffc020147a:	000a6603          	lwu	a2,0(s4)
ffffffffc020147e:	46a9                	li	a3,10
ffffffffc0201480:	8a2e                	mv	s4,a1
ffffffffc0201482:	bd89                	j	ffffffffc02012d4 <vprintfmt+0x156>
ffffffffc0201484:	000a6603          	lwu	a2,0(s4)
ffffffffc0201488:	46c1                	li	a3,16
ffffffffc020148a:	8a2e                	mv	s4,a1
ffffffffc020148c:	b5a1                	j	ffffffffc02012d4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020148e:	9902                	jalr	s2
ffffffffc0201490:	bf09                	j	ffffffffc02013a2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201492:	85a6                	mv	a1,s1
ffffffffc0201494:	02d00513          	li	a0,45
ffffffffc0201498:	e03e                	sd	a5,0(sp)
ffffffffc020149a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020149c:	6782                	ld	a5,0(sp)
ffffffffc020149e:	8a66                	mv	s4,s9
ffffffffc02014a0:	40800633          	neg	a2,s0
ffffffffc02014a4:	46a9                	li	a3,10
ffffffffc02014a6:	b53d                	j	ffffffffc02012d4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02014a8:	03b05163          	blez	s11,ffffffffc02014ca <vprintfmt+0x34c>
ffffffffc02014ac:	02d00693          	li	a3,45
ffffffffc02014b0:	f6d79de3          	bne	a5,a3,ffffffffc020142a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014b4:	00001417          	auipc	s0,0x1
ffffffffc02014b8:	d8440413          	addi	s0,s0,-636 # ffffffffc0202238 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014bc:	02800793          	li	a5,40
ffffffffc02014c0:	02800513          	li	a0,40
ffffffffc02014c4:	00140a13          	addi	s4,s0,1
ffffffffc02014c8:	bd6d                	j	ffffffffc0201382 <vprintfmt+0x204>
ffffffffc02014ca:	00001a17          	auipc	s4,0x1
ffffffffc02014ce:	d6fa0a13          	addi	s4,s4,-657 # ffffffffc0202239 <buddy_system_pmm_manager+0x179>
ffffffffc02014d2:	02800513          	li	a0,40
ffffffffc02014d6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014da:	05e00413          	li	s0,94
ffffffffc02014de:	b565                	j	ffffffffc0201386 <vprintfmt+0x208>

ffffffffc02014e0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014e0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014e2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014e6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014e8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014ea:	ec06                	sd	ra,24(sp)
ffffffffc02014ec:	f83a                	sd	a4,48(sp)
ffffffffc02014ee:	fc3e                	sd	a5,56(sp)
ffffffffc02014f0:	e0c2                	sd	a6,64(sp)
ffffffffc02014f2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02014f4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014f6:	c89ff0ef          	jal	ra,ffffffffc020117e <vprintfmt>
}
ffffffffc02014fa:	60e2                	ld	ra,24(sp)
ffffffffc02014fc:	6161                	addi	sp,sp,80
ffffffffc02014fe:	8082                	ret

ffffffffc0201500 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201500:	715d                	addi	sp,sp,-80
ffffffffc0201502:	e486                	sd	ra,72(sp)
ffffffffc0201504:	e0a6                	sd	s1,64(sp)
ffffffffc0201506:	fc4a                	sd	s2,56(sp)
ffffffffc0201508:	f84e                	sd	s3,48(sp)
ffffffffc020150a:	f452                	sd	s4,40(sp)
ffffffffc020150c:	f056                	sd	s5,32(sp)
ffffffffc020150e:	ec5a                	sd	s6,24(sp)
ffffffffc0201510:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201512:	c901                	beqz	a0,ffffffffc0201522 <readline+0x22>
ffffffffc0201514:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201516:	00001517          	auipc	a0,0x1
ffffffffc020151a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0202250 <buddy_system_pmm_manager+0x190>
ffffffffc020151e:	b95fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201522:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201524:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201526:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201528:	4aa9                	li	s5,10
ffffffffc020152a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020152c:	00005b97          	auipc	s7,0x5
ffffffffc0201530:	c54b8b93          	addi	s7,s7,-940 # ffffffffc0206180 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201534:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201538:	bf3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020153c:	00054a63          	bltz	a0,ffffffffc0201550 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201540:	00a95a63          	bge	s2,a0,ffffffffc0201554 <readline+0x54>
ffffffffc0201544:	029a5263          	bge	s4,s1,ffffffffc0201568 <readline+0x68>
        c = getchar();
ffffffffc0201548:	be3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020154c:	fe055ae3          	bgez	a0,ffffffffc0201540 <readline+0x40>
            return NULL;
ffffffffc0201550:	4501                	li	a0,0
ffffffffc0201552:	a091                	j	ffffffffc0201596 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201554:	03351463          	bne	a0,s3,ffffffffc020157c <readline+0x7c>
ffffffffc0201558:	e8a9                	bnez	s1,ffffffffc02015aa <readline+0xaa>
        c = getchar();
ffffffffc020155a:	bd1fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020155e:	fe0549e3          	bltz	a0,ffffffffc0201550 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201562:	fea959e3          	bge	s2,a0,ffffffffc0201554 <readline+0x54>
ffffffffc0201566:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201568:	e42a                	sd	a0,8(sp)
ffffffffc020156a:	b7ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020156e:	6522                	ld	a0,8(sp)
ffffffffc0201570:	009b87b3          	add	a5,s7,s1
ffffffffc0201574:	2485                	addiw	s1,s1,1
ffffffffc0201576:	00a78023          	sb	a0,0(a5)
ffffffffc020157a:	bf7d                	j	ffffffffc0201538 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020157c:	01550463          	beq	a0,s5,ffffffffc0201584 <readline+0x84>
ffffffffc0201580:	fb651ce3          	bne	a0,s6,ffffffffc0201538 <readline+0x38>
            cputchar(c);
ffffffffc0201584:	b65fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201588:	00005517          	auipc	a0,0x5
ffffffffc020158c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206180 <buf>
ffffffffc0201590:	94aa                	add	s1,s1,a0
ffffffffc0201592:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201596:	60a6                	ld	ra,72(sp)
ffffffffc0201598:	6486                	ld	s1,64(sp)
ffffffffc020159a:	7962                	ld	s2,56(sp)
ffffffffc020159c:	79c2                	ld	s3,48(sp)
ffffffffc020159e:	7a22                	ld	s4,40(sp)
ffffffffc02015a0:	7a82                	ld	s5,32(sp)
ffffffffc02015a2:	6b62                	ld	s6,24(sp)
ffffffffc02015a4:	6bc2                	ld	s7,16(sp)
ffffffffc02015a6:	6161                	addi	sp,sp,80
ffffffffc02015a8:	8082                	ret
            cputchar(c);
ffffffffc02015aa:	4521                	li	a0,8
ffffffffc02015ac:	b3dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02015b0:	34fd                	addiw	s1,s1,-1
ffffffffc02015b2:	b759                	j	ffffffffc0201538 <readline+0x38>

ffffffffc02015b4 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015b4:	4781                	li	a5,0
ffffffffc02015b6:	00005717          	auipc	a4,0x5
ffffffffc02015ba:	a5273703          	ld	a4,-1454(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02015be:	88ba                	mv	a7,a4
ffffffffc02015c0:	852a                	mv	a0,a0
ffffffffc02015c2:	85be                	mv	a1,a5
ffffffffc02015c4:	863e                	mv	a2,a5
ffffffffc02015c6:	00000073          	ecall
ffffffffc02015ca:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015cc:	8082                	ret

ffffffffc02015ce <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02015ce:	4781                	li	a5,0
ffffffffc02015d0:	00005717          	auipc	a4,0x5
ffffffffc02015d4:	ff873703          	ld	a4,-8(a4) # ffffffffc02065c8 <SBI_SET_TIMER>
ffffffffc02015d8:	88ba                	mv	a7,a4
ffffffffc02015da:	852a                	mv	a0,a0
ffffffffc02015dc:	85be                	mv	a1,a5
ffffffffc02015de:	863e                	mv	a2,a5
ffffffffc02015e0:	00000073          	ecall
ffffffffc02015e4:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02015e6:	8082                	ret

ffffffffc02015e8 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02015e8:	4501                	li	a0,0
ffffffffc02015ea:	00005797          	auipc	a5,0x5
ffffffffc02015ee:	a167b783          	ld	a5,-1514(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02015f2:	88be                	mv	a7,a5
ffffffffc02015f4:	852a                	mv	a0,a0
ffffffffc02015f6:	85aa                	mv	a1,a0
ffffffffc02015f8:	862a                	mv	a2,a0
ffffffffc02015fa:	00000073          	ecall
ffffffffc02015fe:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201600:	2501                	sext.w	a0,a0
ffffffffc0201602:	8082                	ret

ffffffffc0201604 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201604:	4781                	li	a5,0
ffffffffc0201606:	00005717          	auipc	a4,0x5
ffffffffc020160a:	a0a73703          	ld	a4,-1526(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc020160e:	88ba                	mv	a7,a4
ffffffffc0201610:	853e                	mv	a0,a5
ffffffffc0201612:	85be                	mv	a1,a5
ffffffffc0201614:	863e                	mv	a2,a5
ffffffffc0201616:	00000073          	ecall
ffffffffc020161a:	87aa                	mv	a5,a0

void sbi_shutdown(void){
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc020161c:	8082                	ret

ffffffffc020161e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020161e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201620:	e589                	bnez	a1,ffffffffc020162a <strnlen+0xc>
ffffffffc0201622:	a811                	j	ffffffffc0201636 <strnlen+0x18>
        cnt ++;
ffffffffc0201624:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201626:	00f58863          	beq	a1,a5,ffffffffc0201636 <strnlen+0x18>
ffffffffc020162a:	00f50733          	add	a4,a0,a5
ffffffffc020162e:	00074703          	lbu	a4,0(a4)
ffffffffc0201632:	fb6d                	bnez	a4,ffffffffc0201624 <strnlen+0x6>
ffffffffc0201634:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201636:	852e                	mv	a0,a1
ffffffffc0201638:	8082                	ret

ffffffffc020163a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020163a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020163e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201642:	cb89                	beqz	a5,ffffffffc0201654 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201644:	0505                	addi	a0,a0,1
ffffffffc0201646:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201648:	fee789e3          	beq	a5,a4,ffffffffc020163a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020164c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201650:	9d19                	subw	a0,a0,a4
ffffffffc0201652:	8082                	ret
ffffffffc0201654:	4501                	li	a0,0
ffffffffc0201656:	bfed                	j	ffffffffc0201650 <strcmp+0x16>

ffffffffc0201658 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201658:	00054783          	lbu	a5,0(a0)
ffffffffc020165c:	c799                	beqz	a5,ffffffffc020166a <strchr+0x12>
        if (*s == c) {
ffffffffc020165e:	00f58763          	beq	a1,a5,ffffffffc020166c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201662:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201666:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201668:	fbfd                	bnez	a5,ffffffffc020165e <strchr+0x6>
    }
    return NULL;
ffffffffc020166a:	4501                	li	a0,0
}
ffffffffc020166c:	8082                	ret

ffffffffc020166e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020166e:	ca01                	beqz	a2,ffffffffc020167e <memset+0x10>
ffffffffc0201670:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201672:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201674:	0785                	addi	a5,a5,1
ffffffffc0201676:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020167a:	fec79de3          	bne	a5,a2,ffffffffc0201674 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020167e:	8082                	ret
