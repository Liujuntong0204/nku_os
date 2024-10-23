
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
ffffffffc020004a:	586010ef          	jal	ra,ffffffffc02015d0 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	59650513          	addi	a0,a0,1430 # ffffffffc02015e8 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	695000ef          	jal	ra,ffffffffc0200efa <pmm_init>

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
ffffffffc02000a6:	054010ef          	jal	ra,ffffffffc02010fa <vprintfmt>
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
ffffffffc02000dc:	01e010ef          	jal	ra,ffffffffc02010fa <vprintfmt>
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
ffffffffc0200140:	4cc50513          	addi	a0,a0,1228 # ffffffffc0201608 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	4d650513          	addi	a0,a0,1238 # ffffffffc0201628 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	48458593          	addi	a1,a1,1156 # ffffffffc02015e2 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	4e250513          	addi	a0,a0,1250 # ffffffffc0201648 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area1>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201668 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	43a58593          	addi	a1,a1,1082 # ffffffffc02065c0 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201688 <etext+0xa6>
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
ffffffffc02001c0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02016a8 <etext+0xc6>
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
ffffffffc02001ce:	50e60613          	addi	a2,a2,1294 # ffffffffc02016d8 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	51a50513          	addi	a0,a0,1306 # ffffffffc02016f0 <etext+0x10e>
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
ffffffffc02001ea:	52260613          	addi	a2,a2,1314 # ffffffffc0201708 <etext+0x126>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	53a58593          	addi	a1,a1,1338 # ffffffffc0201728 <etext+0x146>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	53a50513          	addi	a0,a0,1338 # ffffffffc0201730 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	53c60613          	addi	a2,a2,1340 # ffffffffc0201740 <etext+0x15e>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	55c58593          	addi	a1,a1,1372 # ffffffffc0201768 <etext+0x186>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	51c50513          	addi	a0,a0,1308 # ffffffffc0201730 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	55860613          	addi	a2,a2,1368 # ffffffffc0201778 <etext+0x196>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	57058593          	addi	a1,a1,1392 # ffffffffc0201798 <etext+0x1b6>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	50050513          	addi	a0,a0,1280 # ffffffffc0201730 <etext+0x14e>
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
ffffffffc020026e:	53e50513          	addi	a0,a0,1342 # ffffffffc02017a8 <etext+0x1c6>
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
ffffffffc0200290:	54450513          	addi	a0,a0,1348 # ffffffffc02017d0 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	59ec0c13          	addi	s8,s8,1438 # ffffffffc0201840 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	54e90913          	addi	s2,s2,1358 # ffffffffc02017f8 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	54e48493          	addi	s1,s1,1358 # ffffffffc0201800 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	54cb0b13          	addi	s6,s6,1356 # ffffffffc0201808 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	464a0a13          	addi	s4,s4,1124 # ffffffffc0201728 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	1ac010ef          	jal	ra,ffffffffc020147c <readline>
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
ffffffffc02002ea:	55ad0d13          	addi	s10,s10,1370 # ffffffffc0201840 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	2a8010ef          	jal	ra,ffffffffc020159c <strcmp>
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
ffffffffc0200308:	294010ef          	jal	ra,ffffffffc020159c <strcmp>
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
ffffffffc0200346:	274010ef          	jal	ra,ffffffffc02015ba <strchr>
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
ffffffffc0200384:	236010ef          	jal	ra,ffffffffc02015ba <strchr>
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
ffffffffc02003a2:	48a50513          	addi	a0,a0,1162 # ffffffffc0201828 <etext+0x246>
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
ffffffffc02003de:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201888 <commands+0x48>
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
ffffffffc02003f4:	2e050513          	addi	a0,a0,736 # ffffffffc02016d0 <etext+0xee>
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
ffffffffc0200420:	12a010ef          	jal	ra,ffffffffc020154a <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1407bd23          	sd	zero,346(a5) # ffffffffc0206580 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	47a50513          	addi	a0,a0,1146 # ffffffffc02018a8 <commands+0x68>
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
ffffffffc0200446:	1040106f          	j	ffffffffc020154a <sbi_set_timer>

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
ffffffffc0200450:	0e00106f          	j	ffffffffc0201530 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1100106f          	j	ffffffffc0201564 <sbi_console_getchar>

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
ffffffffc0200482:	44a50513          	addi	a0,a0,1098 # ffffffffc02018c8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	45250513          	addi	a0,a0,1106 # ffffffffc02018e0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	45c50513          	addi	a0,a0,1116 # ffffffffc02018f8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	46650513          	addi	a0,a0,1126 # ffffffffc0201910 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	47050513          	addi	a0,a0,1136 # ffffffffc0201928 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	47a50513          	addi	a0,a0,1146 # ffffffffc0201940 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	48450513          	addi	a0,a0,1156 # ffffffffc0201958 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	48e50513          	addi	a0,a0,1166 # ffffffffc0201970 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	49850513          	addi	a0,a0,1176 # ffffffffc0201988 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	4a250513          	addi	a0,a0,1186 # ffffffffc02019a0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	4ac50513          	addi	a0,a0,1196 # ffffffffc02019b8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	4b650513          	addi	a0,a0,1206 # ffffffffc02019d0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	4c050513          	addi	a0,a0,1216 # ffffffffc02019e8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201a00 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	4d450513          	addi	a0,a0,1236 # ffffffffc0201a18 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	4de50513          	addi	a0,a0,1246 # ffffffffc0201a30 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	4e850513          	addi	a0,a0,1256 # ffffffffc0201a48 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	4f250513          	addi	a0,a0,1266 # ffffffffc0201a60 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201a78 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	50650513          	addi	a0,a0,1286 # ffffffffc0201a90 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	51050513          	addi	a0,a0,1296 # ffffffffc0201aa8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	51a50513          	addi	a0,a0,1306 # ffffffffc0201ac0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	52450513          	addi	a0,a0,1316 # ffffffffc0201ad8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	52e50513          	addi	a0,a0,1326 # ffffffffc0201af0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	53850513          	addi	a0,a0,1336 # ffffffffc0201b08 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	54250513          	addi	a0,a0,1346 # ffffffffc0201b20 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	54c50513          	addi	a0,a0,1356 # ffffffffc0201b38 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	55650513          	addi	a0,a0,1366 # ffffffffc0201b50 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	56050513          	addi	a0,a0,1376 # ffffffffc0201b68 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	56a50513          	addi	a0,a0,1386 # ffffffffc0201b80 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	57450513          	addi	a0,a0,1396 # ffffffffc0201b98 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	57a50513          	addi	a0,a0,1402 # ffffffffc0201bb0 <commands+0x370>
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
ffffffffc020064e:	57e50513          	addi	a0,a0,1406 # ffffffffc0201bc8 <commands+0x388>
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
ffffffffc0200666:	57e50513          	addi	a0,a0,1406 # ffffffffc0201be0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	58650513          	addi	a0,a0,1414 # ffffffffc0201bf8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	58e50513          	addi	a0,a0,1422 # ffffffffc0201c10 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	59250513          	addi	a0,a0,1426 # ffffffffc0201c28 <commands+0x3e8>
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
ffffffffc02006b4:	65870713          	addi	a4,a4,1624 # ffffffffc0201d08 <commands+0x4c8>
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
ffffffffc02006c6:	5de50513          	addi	a0,a0,1502 # ffffffffc0201ca0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	5b450513          	addi	a0,a0,1460 # ffffffffc0201c80 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	56a50513          	addi	a0,a0,1386 # ffffffffc0201c40 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	5e050513          	addi	a0,a0,1504 # ffffffffc0201cc0 <commands+0x480>
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
ffffffffc0200714:	5d850513          	addi	a0,a0,1496 # ffffffffc0201ce8 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	54650513          	addi	a0,a0,1350 # ffffffffc0201c60 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	5ac50513          	addi	a0,a0,1452 # ffffffffc0201cd8 <commands+0x498>
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

ffffffffc0200802 <buddy_system_init>:
#define free_list(property) (free_area1[(property)].free_list)
#define nr_free(property) (free_area1[(property)].nr_free)

static void
buddy_system_init(void) {
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
ffffffffc020081c:	fee79be3          	bne	a5,a4,ffffffffc0200812 <buddy_system_init+0x10>
    }
}
ffffffffc0200820:	8082                	ret

ffffffffc0200822 <split_page>:
        remain=remain-(1<<(order));
    }   
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
}

// 添加页到链表数组 页大小为1<<order
static void add_page(struct Page *base, int order)
{
    if (list_empty(&(free_area1[order].free_list))) {
ffffffffc02008dc:	00159693          	slli	a3,a1,0x1
ffffffffc02008e0:	96ae                	add	a3,a3,a1
ffffffffc02008e2:	00369593          	slli	a1,a3,0x3
ffffffffc02008e6:	00005697          	auipc	a3,0x5
ffffffffc02008ea:	72a68693          	addi	a3,a3,1834 # ffffffffc0206010 <free_area1>
ffffffffc02008ee:	96ae                	add	a3,a3,a1
    return list->next == list;
ffffffffc02008f0:	669c                	ld	a5,8(a3)
    else {
        list_entry_t* le = &(free_area1[order].free_list);
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
ffffffffc02008f2:	01850613          	addi	a2,a0,24
    if (list_empty(&(free_area1[order].free_list))) {
ffffffffc02008f6:	02f68c63          	beq	a3,a5,ffffffffc020092e <add_page+0x52>
            struct Page* page = le2page(le, page_link);
ffffffffc02008fa:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02008fe:	00e56a63          	bltu	a0,a4,ffffffffc0200912 <add_page+0x36>
    return listelm->next;
ffffffffc0200902:	6798                	ld	a4,8(a5)
                break;
            } else if (list_next(le) == &(free_area1[order].free_list)) {
ffffffffc0200904:	00e68d63          	beq	a3,a4,ffffffffc020091e <add_page+0x42>
{
ffffffffc0200908:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020090a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020090e:	fee57ae3          	bgeu	a0,a4,ffffffffc0200902 <add_page+0x26>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200912:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200914:	e390                	sd	a2,0(a5)
ffffffffc0200916:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200918:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020091a:	ed18                	sd	a4,24(a0)
}
ffffffffc020091c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020091e:	e290                	sd	a2,0(a3)
ffffffffc0200920:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200922:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200924:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200926:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &(free_area1[order].free_list)) {
ffffffffc0200928:	fee690e3          	bne	a3,a4,ffffffffc0200908 <add_page+0x2c>
                list_add(le, &(base->page_link));
            }
        }
    }
}
ffffffffc020092c:	8082                	ret
        list_add(&(free_area1[order].free_list), &(base->page_link));
ffffffffc020092e:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc0200932:	e29c                	sd	a5,0(a3)
ffffffffc0200934:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0200936:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200938:	ed14                	sd	a3,24(a0)
}
ffffffffc020093a:	8082                	ret

ffffffffc020093c <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc020093c:	00005697          	auipc	a3,0x5
ffffffffc0200940:	6e468693          	addi	a3,a3,1764 # ffffffffc0206020 <free_area1+0x10>
ffffffffc0200944:	4701                	li	a4,0
    size_t num = 0;
ffffffffc0200946:	4501                	li	a0,0
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200948:	463d                	li	a2,15
    {
        num+=free_area1[i].nr_free<<i;
ffffffffc020094a:	429c                	lw	a5,0(a3)
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc020094c:	06e1                	addi	a3,a3,24
        num+=free_area1[i].nr_free<<i;
ffffffffc020094e:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200952:	1782                	slli	a5,a5,0x20
ffffffffc0200954:	9381                	srli	a5,a5,0x20
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc0200956:	2705                	addiw	a4,a4,1
        num+=free_area1[i].nr_free<<i;
ffffffffc0200958:	953e                	add	a0,a0,a5
    for(int i=0;i<=MAX_ORDER;i++)
ffffffffc020095a:	fec718e3          	bne	a4,a2,ffffffffc020094a <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc020095e:	8082                	ret

ffffffffc0200960 <buddy_system_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
ffffffffc0200960:	1101                	addi	sp,sp,-32
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200962:	4505                	li	a0,1
buddy_system_check(void) {
ffffffffc0200964:	ec06                	sd	ra,24(sp)
ffffffffc0200966:	e822                	sd	s0,16(sp)
ffffffffc0200968:	e426                	sd	s1,8(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc020096a:	552000ef          	jal	ra,ffffffffc0200ebc <alloc_pages>
ffffffffc020096e:	10050f63          	beqz	a0,ffffffffc0200a8c <buddy_system_check+0x12c>
ffffffffc0200972:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200974:	4505                	li	a0,1
ffffffffc0200976:	546000ef          	jal	ra,ffffffffc0200ebc <alloc_pages>
ffffffffc020097a:	84aa                	mv	s1,a0
ffffffffc020097c:	0e050863          	beqz	a0,ffffffffc0200a6c <buddy_system_check+0x10c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200980:	4505                	li	a0,1
ffffffffc0200982:	53a000ef          	jal	ra,ffffffffc0200ebc <alloc_pages>
ffffffffc0200986:	c179                	beqz	a0,ffffffffc0200a4c <buddy_system_check+0xec>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200988:	08940263          	beq	s0,s1,ffffffffc0200a0c <buddy_system_check+0xac>
ffffffffc020098c:	08a40063          	beq	s0,a0,ffffffffc0200a0c <buddy_system_check+0xac>
ffffffffc0200990:	06a48e63          	beq	s1,a0,ffffffffc0200a0c <buddy_system_check+0xac>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200994:	401c                	lw	a5,0(s0)
ffffffffc0200996:	ebd9                	bnez	a5,ffffffffc0200a2c <buddy_system_check+0xcc>
ffffffffc0200998:	409c                	lw	a5,0(s1)
ffffffffc020099a:	ebc9                	bnez	a5,ffffffffc0200a2c <buddy_system_check+0xcc>
ffffffffc020099c:	411c                	lw	a5,0(a0)
ffffffffc020099e:	e7d9                	bnez	a5,ffffffffc0200a2c <buddy_system_check+0xcc>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009a0:	00006597          	auipc	a1,0x6
ffffffffc02009a4:	bf05b583          	ld	a1,-1040(a1) # ffffffffc0206590 <pages>
ffffffffc02009a8:	40b407b3          	sub	a5,s0,a1
ffffffffc02009ac:	878d                	srai	a5,a5,0x3
ffffffffc02009ae:	00002617          	auipc	a2,0x2
ffffffffc02009b2:	90263603          	ld	a2,-1790(a2) # ffffffffc02022b0 <error_string+0x38>
ffffffffc02009b6:	02c787b3          	mul	a5,a5,a2
ffffffffc02009ba:	00002697          	auipc	a3,0x2
ffffffffc02009be:	8fe6b683          	ld	a3,-1794(a3) # ffffffffc02022b8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009c2:	00006717          	auipc	a4,0x6
ffffffffc02009c6:	bc673703          	ld	a4,-1082(a4) # ffffffffc0206588 <npage>
ffffffffc02009ca:	0732                	slli	a4,a4,0xc
ffffffffc02009cc:	97b6                	add	a5,a5,a3

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ce:	07b2                	slli	a5,a5,0xc
ffffffffc02009d0:	10e7fe63          	bgeu	a5,a4,ffffffffc0200aec <buddy_system_check+0x18c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009d4:	40b487b3          	sub	a5,s1,a1
ffffffffc02009d8:	878d                	srai	a5,a5,0x3
ffffffffc02009da:	02c787b3          	mul	a5,a5,a2
ffffffffc02009de:	97b6                	add	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009e2:	0ee7f563          	bgeu	a5,a4,ffffffffc0200acc <buddy_system_check+0x16c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009e6:	40b507b3          	sub	a5,a0,a1
ffffffffc02009ea:	878d                	srai	a5,a5,0x3
ffffffffc02009ec:	02c787b3          	mul	a5,a5,a2
ffffffffc02009f0:	97b6                	add	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02009f2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009f4:	0ae7fc63          	bgeu	a5,a4,ffffffffc0200aac <buddy_system_check+0x14c>
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
ffffffffc02009f8:	6442                	ld	s0,16(sp)
ffffffffc02009fa:	60e2                	ld	ra,24(sp)
ffffffffc02009fc:	64a2                	ld	s1,8(sp)
    cprintf("success!!");
ffffffffc02009fe:	00001517          	auipc	a0,0x1
ffffffffc0200a02:	49a50513          	addi	a0,a0,1178 # ffffffffc0201e98 <commands+0x658>
}
ffffffffc0200a06:	6105                	addi	sp,sp,32
    cprintf("success!!");
ffffffffc0200a08:	eaaff06f          	j	ffffffffc02000b2 <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a0c:	00001697          	auipc	a3,0x1
ffffffffc0200a10:	3c468693          	addi	a3,a3,964 # ffffffffc0201dd0 <commands+0x590>
ffffffffc0200a14:	00001617          	auipc	a2,0x1
ffffffffc0200a18:	34460613          	addi	a2,a2,836 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200a1c:	0e700593          	li	a1,231
ffffffffc0200a20:	00001517          	auipc	a0,0x1
ffffffffc0200a24:	35050513          	addi	a0,a0,848 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200a28:	985ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a2c:	00001697          	auipc	a3,0x1
ffffffffc0200a30:	3cc68693          	addi	a3,a3,972 # ffffffffc0201df8 <commands+0x5b8>
ffffffffc0200a34:	00001617          	auipc	a2,0x1
ffffffffc0200a38:	32460613          	addi	a2,a2,804 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200a3c:	0e800593          	li	a1,232
ffffffffc0200a40:	00001517          	auipc	a0,0x1
ffffffffc0200a44:	33050513          	addi	a0,a0,816 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200a48:	965ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a4c:	00001697          	auipc	a3,0x1
ffffffffc0200a50:	36468693          	addi	a3,a3,868 # ffffffffc0201db0 <commands+0x570>
ffffffffc0200a54:	00001617          	auipc	a2,0x1
ffffffffc0200a58:	30460613          	addi	a2,a2,772 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200a5c:	0e500593          	li	a1,229
ffffffffc0200a60:	00001517          	auipc	a0,0x1
ffffffffc0200a64:	31050513          	addi	a0,a0,784 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200a68:	945ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a6c:	00001697          	auipc	a3,0x1
ffffffffc0200a70:	32468693          	addi	a3,a3,804 # ffffffffc0201d90 <commands+0x550>
ffffffffc0200a74:	00001617          	auipc	a2,0x1
ffffffffc0200a78:	2e460613          	addi	a2,a2,740 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200a7c:	0e400593          	li	a1,228
ffffffffc0200a80:	00001517          	auipc	a0,0x1
ffffffffc0200a84:	2f050513          	addi	a0,a0,752 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200a88:	925ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a8c:	00001697          	auipc	a3,0x1
ffffffffc0200a90:	2ac68693          	addi	a3,a3,684 # ffffffffc0201d38 <commands+0x4f8>
ffffffffc0200a94:	00001617          	auipc	a2,0x1
ffffffffc0200a98:	2c460613          	addi	a2,a2,708 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200a9c:	0e300593          	li	a1,227
ffffffffc0200aa0:	00001517          	auipc	a0,0x1
ffffffffc0200aa4:	2d050513          	addi	a0,a0,720 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200aa8:	905ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200aac:	00001697          	auipc	a3,0x1
ffffffffc0200ab0:	3cc68693          	addi	a3,a3,972 # ffffffffc0201e78 <commands+0x638>
ffffffffc0200ab4:	00001617          	auipc	a2,0x1
ffffffffc0200ab8:	2a460613          	addi	a2,a2,676 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200abc:	0ec00593          	li	a1,236
ffffffffc0200ac0:	00001517          	auipc	a0,0x1
ffffffffc0200ac4:	2b050513          	addi	a0,a0,688 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200ac8:	8e5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200acc:	00001697          	auipc	a3,0x1
ffffffffc0200ad0:	38c68693          	addi	a3,a3,908 # ffffffffc0201e58 <commands+0x618>
ffffffffc0200ad4:	00001617          	auipc	a2,0x1
ffffffffc0200ad8:	28460613          	addi	a2,a2,644 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200adc:	0eb00593          	li	a1,235
ffffffffc0200ae0:	00001517          	auipc	a0,0x1
ffffffffc0200ae4:	29050513          	addi	a0,a0,656 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200ae8:	8c5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200aec:	00001697          	auipc	a3,0x1
ffffffffc0200af0:	34c68693          	addi	a3,a3,844 # ffffffffc0201e38 <commands+0x5f8>
ffffffffc0200af4:	00001617          	auipc	a2,0x1
ffffffffc0200af8:	26460613          	addi	a2,a2,612 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200afc:	0ea00593          	li	a1,234
ffffffffc0200b00:	00001517          	auipc	a0,0x1
ffffffffc0200b04:	27050513          	addi	a0,a0,624 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200b08:	8a5ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b0c <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200b0c:	715d                	addi	sp,sp,-80
ffffffffc0200b0e:	e486                	sd	ra,72(sp)
ffffffffc0200b10:	e0a2                	sd	s0,64(sp)
ffffffffc0200b12:	fc26                	sd	s1,56(sp)
ffffffffc0200b14:	f84a                	sd	s2,48(sp)
ffffffffc0200b16:	f44e                	sd	s3,40(sp)
ffffffffc0200b18:	f052                	sd	s4,32(sp)
ffffffffc0200b1a:	ec56                	sd	s5,24(sp)
ffffffffc0200b1c:	e85a                	sd	s6,16(sp)
ffffffffc0200b1e:	e45e                	sd	s7,8(sp)
ffffffffc0200b20:	e062                	sd	s8,0(sp)
    assert(n > 0);
ffffffffc0200b22:	18058463          	beqz	a1,ffffffffc0200caa <buddy_system_free_pages+0x19e>
    for (; p != base + n; p ++) {
ffffffffc0200b26:	00259693          	slli	a3,a1,0x2
ffffffffc0200b2a:	96ae                	add	a3,a3,a1
ffffffffc0200b2c:	068e                	slli	a3,a3,0x3
ffffffffc0200b2e:	96aa                	add	a3,a3,a0
ffffffffc0200b30:	842a                	mv	s0,a0
ffffffffc0200b32:	87aa                	mv	a5,a0
ffffffffc0200b34:	02d50263          	beq	a0,a3,ffffffffc0200b58 <buddy_system_free_pages+0x4c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b38:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200b3a:	8b05                	andi	a4,a4,1
ffffffffc0200b3c:	14071763          	bnez	a4,ffffffffc0200c8a <buddy_system_free_pages+0x17e>
ffffffffc0200b40:	6798                	ld	a4,8(a5)
ffffffffc0200b42:	8b09                	andi	a4,a4,2
ffffffffc0200b44:	14071363          	bnez	a4,ffffffffc0200c8a <buddy_system_free_pages+0x17e>
        p->flags = 0;
ffffffffc0200b48:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b4c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200b50:	02878793          	addi	a5,a5,40
ffffffffc0200b54:	fed792e3          	bne	a5,a3,ffffffffc0200b38 <buddy_system_free_pages+0x2c>
    while(n!=(1<<order))
ffffffffc0200b58:	4785                	li	a5,1
    int order = 0;
ffffffffc0200b5a:	4a01                	li	s4,0
    while(n!=(1<<order))
ffffffffc0200b5c:	4705                	li	a4,1
ffffffffc0200b5e:	12f58463          	beq	a1,a5,ffffffffc0200c86 <buddy_system_free_pages+0x17a>
        order++;
ffffffffc0200b62:	2a05                	addiw	s4,s4,1
    while(n!=(1<<order))
ffffffffc0200b64:	014717bb          	sllw	a5,a4,s4
ffffffffc0200b68:	fef59de3          	bne	a1,a5,ffffffffc0200b62 <buddy_system_free_pages+0x56>
    base->property = order;
ffffffffc0200b6c:	000a079b          	sext.w	a5,s4
ffffffffc0200b70:	c81c                	sw	a5,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b72:	00840713          	addi	a4,s0,8
ffffffffc0200b76:	4789                	li	a5,2
ffffffffc0200b78:	40f7302f          	amoor.d	zero,a5,(a4)
    add_page(base, order);
ffffffffc0200b7c:	85d2                	mv	a1,s4
ffffffffc0200b7e:	8522                	mv	a0,s0
ffffffffc0200b80:	d5dff0ef          	jal	ra,ffffffffc02008dc <add_page>
    free_area1[order].nr_free += 1;
ffffffffc0200b84:	001a1793          	slli	a5,s4,0x1
ffffffffc0200b88:	97d2                	add	a5,a5,s4
ffffffffc0200b8a:	00005917          	auipc	s2,0x5
ffffffffc0200b8e:	48690913          	addi	s2,s2,1158 # ffffffffc0206010 <free_area1>
ffffffffc0200b92:	078e                	slli	a5,a5,0x3
ffffffffc0200b94:	97ca                	add	a5,a5,s2
ffffffffc0200b96:	4b98                	lw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc0200b98:	46b9                	li	a3,14
ffffffffc0200b9a:	84be                	mv	s1,a5
    free_area1[order].nr_free += 1;
ffffffffc0200b9c:	2705                	addiw	a4,a4,1
ffffffffc0200b9e:	cb98                	sw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc0200ba0:	001a0a9b          	addiw	s5,s4,1
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200ba4:	4b85                	li	s7,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ba6:	59f5                	li	s3,-3
    if(order == MAX_ORDER)
ffffffffc0200ba8:	4c39                	li	s8,14
ffffffffc0200baa:	06da1563          	bne	s4,a3,ffffffffc0200c14 <buddy_system_free_pages+0x108>
ffffffffc0200bae:	a069                	j	ffffffffc0200c38 <buddy_system_free_pages+0x12c>
        if (p + (1<<(p->property)) == base) {
ffffffffc0200bb0:	ff87a683          	lw	a3,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0200bb4:	fe878b13          	addi	s6,a5,-24
        if (p + (1<<(p->property)) == base) {
ffffffffc0200bb8:	00db963b          	sllw	a2,s7,a3
ffffffffc0200bbc:	00261713          	slli	a4,a2,0x2
ffffffffc0200bc0:	9732                	add	a4,a4,a2
ffffffffc0200bc2:	070e                	slli	a4,a4,0x3
ffffffffc0200bc4:	975a                	add	a4,a4,s6
ffffffffc0200bc6:	04e41a63          	bne	s0,a4,ffffffffc0200c1a <buddy_system_free_pages+0x10e>
            p->property += 1;
ffffffffc0200bca:	2685                	addiw	a3,a3,1
ffffffffc0200bcc:	fed7ac23          	sw	a3,-8(a5)
ffffffffc0200bd0:	00840713          	addi	a4,s0,8
ffffffffc0200bd4:	6137302f          	amoand.d	zero,s3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bd8:	7014                	ld	a3,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200bda:	4898                	lw	a4,16(s1)
            add_page(base,order+1);
ffffffffc0200bdc:	000a8a1b          	sext.w	s4,s5
    prev->next = next;
ffffffffc0200be0:	e794                	sd	a3,8(a5)
    next->prev = prev;
ffffffffc0200be2:	e29c                	sd	a5,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200be4:	6390                	ld	a2,0(a5)
ffffffffc0200be6:	6794                	ld	a3,8(a5)
            free_area1[order].nr_free -= 2;
ffffffffc0200be8:	ffe7079b          	addiw	a5,a4,-2
            add_page(base,order+1);
ffffffffc0200bec:	85d2                	mv	a1,s4
    prev->next = next;
ffffffffc0200bee:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0200bf0:	e290                	sd	a2,0(a3)
            free_area1[order].nr_free -= 2;
ffffffffc0200bf2:	c89c                	sw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200bf4:	855a                	mv	a0,s6
ffffffffc0200bf6:	ce7ff0ef          	jal	ra,ffffffffc02008dc <add_page>
            free_area1[order+1].nr_free += 1;
ffffffffc0200bfa:	001a1793          	slli	a5,s4,0x1
ffffffffc0200bfe:	97d2                	add	a5,a5,s4
ffffffffc0200c00:	078e                	slli	a5,a5,0x3
ffffffffc0200c02:	97ca                	add	a5,a5,s2
ffffffffc0200c04:	4b98                	lw	a4,16(a5)
ffffffffc0200c06:	845a                	mv	s0,s6
ffffffffc0200c08:	2705                	addiw	a4,a4,1
ffffffffc0200c0a:	cb98                	sw	a4,16(a5)
    if(order == MAX_ORDER)
ffffffffc0200c0c:	04e1                	addi	s1,s1,24
ffffffffc0200c0e:	2a85                	addiw	s5,s5,1
ffffffffc0200c10:	038a0463          	beq	s4,s8,ffffffffc0200c38 <buddy_system_free_pages+0x12c>
    return listelm->prev;
ffffffffc0200c14:	6c1c                	ld	a5,24(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200c16:	f8979de3          	bne	a5,s1,ffffffffc0200bb0 <buddy_system_free_pages+0xa4>
    return listelm->next;
ffffffffc0200c1a:	7018                	ld	a4,32(s0)
    if (le != &(free_area1[order].free_list)) {
ffffffffc0200c1c:	00e48e63          	beq	s1,a4,ffffffffc0200c38 <buddy_system_free_pages+0x12c>
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200c20:	4810                	lw	a2,16(s0)
        struct Page *p = le2page(le, page_link);
ffffffffc0200c22:	fe870593          	addi	a1,a4,-24
        if (has_merge == 0 && base + (1<<(base->property)) == p ) {
ffffffffc0200c26:	00cb96bb          	sllw	a3,s7,a2
ffffffffc0200c2a:	00269793          	slli	a5,a3,0x2
ffffffffc0200c2e:	97b6                	add	a5,a5,a3
ffffffffc0200c30:	078e                	slli	a5,a5,0x3
ffffffffc0200c32:	97a2                	add	a5,a5,s0
ffffffffc0200c34:	00f58e63          	beq	a1,a5,ffffffffc0200c50 <buddy_system_free_pages+0x144>
}
ffffffffc0200c38:	60a6                	ld	ra,72(sp)
ffffffffc0200c3a:	6406                	ld	s0,64(sp)
ffffffffc0200c3c:	74e2                	ld	s1,56(sp)
ffffffffc0200c3e:	7942                	ld	s2,48(sp)
ffffffffc0200c40:	79a2                	ld	s3,40(sp)
ffffffffc0200c42:	7a02                	ld	s4,32(sp)
ffffffffc0200c44:	6ae2                	ld	s5,24(sp)
ffffffffc0200c46:	6b42                	ld	s6,16(sp)
ffffffffc0200c48:	6ba2                	ld	s7,8(sp)
ffffffffc0200c4a:	6c02                	ld	s8,0(sp)
ffffffffc0200c4c:	6161                	addi	sp,sp,80
ffffffffc0200c4e:	8082                	ret
            base->property += 1;
ffffffffc0200c50:	2605                	addiw	a2,a2,1
ffffffffc0200c52:	c810                	sw	a2,16(s0)
ffffffffc0200c54:	ff070793          	addi	a5,a4,-16
ffffffffc0200c58:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c5c:	6314                	ld	a3,0(a4)
ffffffffc0200c5e:	6718                	ld	a4,8(a4)
            free_area1[order].nr_free -= 2;
ffffffffc0200c60:	489c                	lw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200c62:	000a8a1b          	sext.w	s4,s5
    prev->next = next;
ffffffffc0200c66:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200c68:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c6a:	6c14                	ld	a3,24(s0)
ffffffffc0200c6c:	7018                	ld	a4,32(s0)
            free_area1[order].nr_free -= 2;
ffffffffc0200c6e:	37f9                	addiw	a5,a5,-2
            add_page(base,order+1);
ffffffffc0200c70:	85d2                	mv	a1,s4
    prev->next = next;
ffffffffc0200c72:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200c74:	e314                	sd	a3,0(a4)
            free_area1[order].nr_free -= 2;
ffffffffc0200c76:	c89c                	sw	a5,16(s1)
            add_page(base,order+1);
ffffffffc0200c78:	8522                	mv	a0,s0
ffffffffc0200c7a:	c63ff0ef          	jal	ra,ffffffffc02008dc <add_page>
            free_area1[order].nr_free += 1;
ffffffffc0200c7e:	489c                	lw	a5,16(s1)
ffffffffc0200c80:	2785                	addiw	a5,a5,1
ffffffffc0200c82:	c89c                	sw	a5,16(s1)
    if(has_merge == 1) //成功merge则递归调用上一级merge
ffffffffc0200c84:	b761                	j	ffffffffc0200c0c <buddy_system_free_pages+0x100>
    while(n!=(1<<order))
ffffffffc0200c86:	4781                	li	a5,0
ffffffffc0200c88:	b5e5                	j	ffffffffc0200b70 <buddy_system_free_pages+0x64>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200c8a:	00001697          	auipc	a3,0x1
ffffffffc0200c8e:	22668693          	addi	a3,a3,550 # ffffffffc0201eb0 <commands+0x670>
ffffffffc0200c92:	00001617          	auipc	a2,0x1
ffffffffc0200c96:	0c660613          	addi	a2,a2,198 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200c9a:	0c000593          	li	a1,192
ffffffffc0200c9e:	00001517          	auipc	a0,0x1
ffffffffc0200ca2:	0d250513          	addi	a0,a0,210 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200ca6:	f06ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200caa:	00001697          	auipc	a3,0x1
ffffffffc0200cae:	1fe68693          	addi	a3,a3,510 # ffffffffc0201ea8 <commands+0x668>
ffffffffc0200cb2:	00001617          	auipc	a2,0x1
ffffffffc0200cb6:	0a660613          	addi	a2,a2,166 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200cba:	0bd00593          	li	a1,189
ffffffffc0200cbe:	00001517          	auipc	a0,0x1
ffffffffc0200cc2:	0b250513          	addi	a0,a0,178 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200cc6:	ee6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cca <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t n) {
ffffffffc0200cca:	7179                	addi	sp,sp,-48
ffffffffc0200ccc:	f406                	sd	ra,40(sp)
ffffffffc0200cce:	f022                	sd	s0,32(sp)
ffffffffc0200cd0:	ec26                	sd	s1,24(sp)
ffffffffc0200cd2:	e84a                	sd	s2,16(sp)
ffffffffc0200cd4:	e44e                	sd	s3,8(sp)
ffffffffc0200cd6:	e052                	sd	s4,0(sp)
    assert(n > 0);
ffffffffc0200cd8:	c57d                	beqz	a0,ffffffffc0200dc6 <buddy_system_alloc_pages+0xfc>
    if (n > (1 << (MAX_ORDER))) {
ffffffffc0200cda:	6791                	lui	a5,0x4
ffffffffc0200cdc:	0ca7e463          	bltu	a5,a0,ffffffffc0200da4 <buddy_system_alloc_pages+0xda>
    while (n > (1 << (order))) {
ffffffffc0200ce0:	4785                	li	a5,1
ffffffffc0200ce2:	0cf50a63          	beq	a0,a5,ffffffffc0200db6 <buddy_system_alloc_pages+0xec>
    int order=0;
ffffffffc0200ce6:	4401                	li	s0,0
    while (n > (1 << (order))) {
ffffffffc0200ce8:	4705                	li	a4,1
        order++;
ffffffffc0200cea:	2405                	addiw	s0,s0,1
    while (n > (1 << (order))) {
ffffffffc0200cec:	008717bb          	sllw	a5,a4,s0
ffffffffc0200cf0:	fea7ede3          	bltu	a5,a0,ffffffffc0200cea <buddy_system_alloc_pages+0x20>
    for (;i<=MAX_ORDER;i++)
ffffffffc0200cf4:	47b9                	li	a5,14
ffffffffc0200cf6:	0687ca63          	blt	a5,s0,ffffffffc0200d6a <buddy_system_alloc_pages+0xa0>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200cfa:	00141493          	slli	s1,s0,0x1
ffffffffc0200cfe:	008489b3          	add	s3,s1,s0
ffffffffc0200d02:	00005917          	auipc	s2,0x5
ffffffffc0200d06:	30e90913          	addi	s2,s2,782 # ffffffffc0206010 <free_area1>
ffffffffc0200d0a:	098e                	slli	s3,s3,0x3
ffffffffc0200d0c:	99ca                	add	s3,s3,s2
ffffffffc0200d0e:	008487b3          	add	a5,s1,s0
ffffffffc0200d12:	078e                	slli	a5,a5,0x3
ffffffffc0200d14:	97ca                	add	a5,a5,s2
    int order=0;
ffffffffc0200d16:	8722                	mv	a4,s0
    for (;i<=MAX_ORDER;i++)
ffffffffc0200d18:	463d                	li	a2,15
ffffffffc0200d1a:	a029                	j	ffffffffc0200d24 <buddy_system_alloc_pages+0x5a>
ffffffffc0200d1c:	2705                	addiw	a4,a4,1
ffffffffc0200d1e:	07e1                	addi	a5,a5,24
ffffffffc0200d20:	08c70263          	beq	a4,a2,ffffffffc0200da4 <buddy_system_alloc_pages+0xda>
        if(!list_empty(&(free_area1[i].free_list)))
ffffffffc0200d24:	6794                	ld	a3,8(a5)
ffffffffc0200d26:	fef68be3          	beq	a3,a5,ffffffffc0200d1c <buddy_system_alloc_pages+0x52>
    return list->next == list;
ffffffffc0200d2a:	00848a33          	add	s4,s1,s0
ffffffffc0200d2e:	0a0e                	slli	s4,s4,0x3
ffffffffc0200d30:	9a4a                	add	s4,s4,s2
ffffffffc0200d32:	008a3783          	ld	a5,8(s4)
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200d36:	05378f63          	beq	a5,s3,ffffffffc0200d94 <buddy_system_alloc_pages+0xca>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d3a:	6798                	ld	a4,8(a5)
ffffffffc0200d3c:	6394                	ld	a3,0(a5)
    page= le2page(le, page_link);
ffffffffc0200d3e:	fe878513          	addi	a0,a5,-24 # 3fe8 <kern_entry-0xffffffffc01fc018>
ffffffffc0200d42:	17c1                	addi	a5,a5,-16
    prev->next = next;
ffffffffc0200d44:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200d46:	e314                	sd	a3,0(a4)
ffffffffc0200d48:	5775                	li	a4,-3
ffffffffc0200d4a:	60e7b02f          	amoand.d	zero,a4,(a5)
    free_area1[order].nr_free-=1;
ffffffffc0200d4e:	9426                	add	s0,s0,s1
ffffffffc0200d50:	040e                	slli	s0,s0,0x3
ffffffffc0200d52:	944a                	add	s0,s0,s2
ffffffffc0200d54:	481c                	lw	a5,16(s0)
}
ffffffffc0200d56:	70a2                	ld	ra,40(sp)
ffffffffc0200d58:	64e2                	ld	s1,24(sp)
    free_area1[order].nr_free-=1;
ffffffffc0200d5a:	37fd                	addiw	a5,a5,-1
ffffffffc0200d5c:	c81c                	sw	a5,16(s0)
}
ffffffffc0200d5e:	7402                	ld	s0,32(sp)
ffffffffc0200d60:	6942                	ld	s2,16(sp)
ffffffffc0200d62:	69a2                	ld	s3,8(sp)
ffffffffc0200d64:	6a02                	ld	s4,0(sp)
ffffffffc0200d66:	6145                	addi	sp,sp,48
ffffffffc0200d68:	8082                	ret
    if(i==MAX_ORDER+1)
ffffffffc0200d6a:	47bd                	li	a5,15
ffffffffc0200d6c:	02f40c63          	beq	s0,a5,ffffffffc0200da4 <buddy_system_alloc_pages+0xda>
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200d70:	00141493          	slli	s1,s0,0x1
    return list->next == list;
ffffffffc0200d74:	00848a33          	add	s4,s1,s0
ffffffffc0200d78:	00005917          	auipc	s2,0x5
ffffffffc0200d7c:	29890913          	addi	s2,s2,664 # ffffffffc0206010 <free_area1>
ffffffffc0200d80:	0a0e                	slli	s4,s4,0x3
ffffffffc0200d82:	9a4a                	add	s4,s4,s2
ffffffffc0200d84:	008489b3          	add	s3,s1,s0
ffffffffc0200d88:	008a3783          	ld	a5,8(s4)
ffffffffc0200d8c:	098e                	slli	s3,s3,0x3
ffffffffc0200d8e:	99ca                	add	s3,s3,s2
ffffffffc0200d90:	fb3795e3          	bne	a5,s3,ffffffffc0200d3a <buddy_system_alloc_pages+0x70>
         split_page(order + 1);
ffffffffc0200d94:	0014051b          	addiw	a0,s0,1
ffffffffc0200d98:	a8bff0ef          	jal	ra,ffffffffc0200822 <split_page>
ffffffffc0200d9c:	008a3783          	ld	a5,8(s4)
    if(list_empty(&(free_area1[order].free_list)))
ffffffffc0200da0:	f9379de3          	bne	a5,s3,ffffffffc0200d3a <buddy_system_alloc_pages+0x70>
}
ffffffffc0200da4:	70a2                	ld	ra,40(sp)
ffffffffc0200da6:	7402                	ld	s0,32(sp)
ffffffffc0200da8:	64e2                	ld	s1,24(sp)
ffffffffc0200daa:	6942                	ld	s2,16(sp)
ffffffffc0200dac:	69a2                	ld	s3,8(sp)
ffffffffc0200dae:	6a02                	ld	s4,0(sp)
        return NULL;
ffffffffc0200db0:	4501                	li	a0,0
}
ffffffffc0200db2:	6145                	addi	sp,sp,48
ffffffffc0200db4:	8082                	ret
    while (n > (1 << (order))) {
ffffffffc0200db6:	00005917          	auipc	s2,0x5
ffffffffc0200dba:	25a90913          	addi	s2,s2,602 # ffffffffc0206010 <free_area1>
ffffffffc0200dbe:	89ca                	mv	s3,s2
    int order=0;
ffffffffc0200dc0:	4401                	li	s0,0
ffffffffc0200dc2:	4481                	li	s1,0
ffffffffc0200dc4:	b7a9                	j	ffffffffc0200d0e <buddy_system_alloc_pages+0x44>
    assert(n > 0);
ffffffffc0200dc6:	00001697          	auipc	a3,0x1
ffffffffc0200dca:	0e268693          	addi	a3,a3,226 # ffffffffc0201ea8 <commands+0x668>
ffffffffc0200dce:	00001617          	auipc	a2,0x1
ffffffffc0200dd2:	f8a60613          	addi	a2,a2,-118 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200dd6:	04b00593          	li	a1,75
ffffffffc0200dda:	00001517          	auipc	a0,0x1
ffffffffc0200dde:	f9650513          	addi	a0,a0,-106 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200de2:	dcaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200de6 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200de6:	1141                	addi	sp,sp,-16
ffffffffc0200de8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200dea:	c9d5                	beqz	a1,ffffffffc0200e9e <buddy_system_init_memmap+0xb8>
    for (; p != base + n; p ++) {
ffffffffc0200dec:	00259693          	slli	a3,a1,0x2
ffffffffc0200df0:	96ae                	add	a3,a3,a1
ffffffffc0200df2:	068e                	slli	a3,a3,0x3
ffffffffc0200df4:	96aa                	add	a3,a3,a0
ffffffffc0200df6:	87aa                	mv	a5,a0
ffffffffc0200df8:	00d50f63          	beq	a0,a3,ffffffffc0200e16 <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200dfc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200dfe:	8b05                	andi	a4,a4,1
ffffffffc0200e00:	c341                	beqz	a4,ffffffffc0200e80 <buddy_system_init_memmap+0x9a>
        p->flags = p->property = 0;
ffffffffc0200e02:	0007a823          	sw	zero,16(a5)
ffffffffc0200e06:	0007b423          	sd	zero,8(a5)
ffffffffc0200e0a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200e0e:	02878793          	addi	a5,a5,40
ffffffffc0200e12:	fed795e3          	bne	a5,a3,ffffffffc0200dfc <buddy_system_init_memmap+0x16>
ffffffffc0200e16:	00005e17          	auipc	t3,0x5
ffffffffc0200e1a:	1fae0e13          	addi	t3,t3,506 # ffffffffc0206010 <free_area1>
        while (remain >= (1 << (order))) {
ffffffffc0200e1e:	4605                	li	a2,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e20:	4309                	li	t1,2
        int order=0;
ffffffffc0200e22:	4781                	li	a5,0
        order++;
ffffffffc0200e24:	86be                	mv	a3,a5
ffffffffc0200e26:	2785                	addiw	a5,a5,1
        while (remain >= (1 << (order))) {
ffffffffc0200e28:	00f6173b          	sllw	a4,a2,a5
ffffffffc0200e2c:	fee5fce3          	bgeu	a1,a4,ffffffffc0200e24 <buddy_system_init_memmap+0x3e>
        p=p+(1<<(order));
ffffffffc0200e30:	00d6183b          	sllw	a6,a2,a3
ffffffffc0200e34:	00281793          	slli	a5,a6,0x2
ffffffffc0200e38:	97c2                	add	a5,a5,a6
ffffffffc0200e3a:	078e                	slli	a5,a5,0x3
ffffffffc0200e3c:	00f50733          	add	a4,a0,a5
        remain=remain-(1<<(order));
ffffffffc0200e40:	410585b3          	sub	a1,a1,a6
        p->property=order;
ffffffffc0200e44:	c914                	sw	a3,16(a0)
ffffffffc0200e46:	00850793          	addi	a5,a0,8
ffffffffc0200e4a:	4067b02f          	amoor.d	zero,t1,(a5)
        free_area1[order].nr_free+=1;
ffffffffc0200e4e:	00169793          	slli	a5,a3,0x1
ffffffffc0200e52:	96be                	add	a3,a3,a5
ffffffffc0200e54:	068e                	slli	a3,a3,0x3
ffffffffc0200e56:	96f2                	add	a3,a3,t3
ffffffffc0200e58:	4a9c                	lw	a5,16(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e5a:	0086b803          	ld	a6,8(a3)
        list_add(&(free_area1[order].free_list), &(p->page_link));
ffffffffc0200e5e:	01850893          	addi	a7,a0,24
        free_area1[order].nr_free+=1;
ffffffffc0200e62:	2785                	addiw	a5,a5,1
ffffffffc0200e64:	ca9c                	sw	a5,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200e66:	01183023          	sd	a7,0(a6)
ffffffffc0200e6a:	0116b423          	sd	a7,8(a3)
    elm->next = next;
ffffffffc0200e6e:	03053023          	sd	a6,32(a0)
    elm->prev = prev;
ffffffffc0200e72:	ed14                	sd	a3,24(a0)
    while(remain!=0)
ffffffffc0200e74:	c199                	beqz	a1,ffffffffc0200e7a <buddy_system_init_memmap+0x94>
        p=p+(1<<(order));
ffffffffc0200e76:	853a                	mv	a0,a4
ffffffffc0200e78:	b76d                	j	ffffffffc0200e22 <buddy_system_init_memmap+0x3c>
}
ffffffffc0200e7a:	60a2                	ld	ra,8(sp)
ffffffffc0200e7c:	0141                	addi	sp,sp,16
ffffffffc0200e7e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200e80:	00001697          	auipc	a3,0x1
ffffffffc0200e84:	05868693          	addi	a3,a3,88 # ffffffffc0201ed8 <commands+0x698>
ffffffffc0200e88:	00001617          	auipc	a2,0x1
ffffffffc0200e8c:	ed060613          	addi	a2,a2,-304 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200e90:	45ed                	li	a1,27
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	ede50513          	addi	a0,a0,-290 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200e9a:	d12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	00a68693          	addi	a3,a3,10 # ffffffffc0201ea8 <commands+0x668>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	eb260613          	addi	a2,a2,-334 # ffffffffc0201d58 <commands+0x518>
ffffffffc0200eae:	45e1                	li	a1,24
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	ec050513          	addi	a0,a0,-320 # ffffffffc0201d70 <commands+0x530>
ffffffffc0200eb8:	cf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ebc <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ebc:	100027f3          	csrr	a5,sstatus
ffffffffc0200ec0:	8b89                	andi	a5,a5,2
ffffffffc0200ec2:	e799                	bnez	a5,ffffffffc0200ed0 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200ec4:	00005797          	auipc	a5,0x5
ffffffffc0200ec8:	6d47b783          	ld	a5,1748(a5) # ffffffffc0206598 <pmm_manager>
ffffffffc0200ecc:	6f9c                	ld	a5,24(a5)
ffffffffc0200ece:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200ed0:	1141                	addi	sp,sp,-16
ffffffffc0200ed2:	e406                	sd	ra,8(sp)
ffffffffc0200ed4:	e022                	sd	s0,0(sp)
ffffffffc0200ed6:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200ed8:	d86ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200edc:	00005797          	auipc	a5,0x5
ffffffffc0200ee0:	6bc7b783          	ld	a5,1724(a5) # ffffffffc0206598 <pmm_manager>
ffffffffc0200ee4:	6f9c                	ld	a5,24(a5)
ffffffffc0200ee6:	8522                	mv	a0,s0
ffffffffc0200ee8:	9782                	jalr	a5
ffffffffc0200eea:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200eec:	d6cff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200ef0:	60a2                	ld	ra,8(sp)
ffffffffc0200ef2:	8522                	mv	a0,s0
ffffffffc0200ef4:	6402                	ld	s0,0(sp)
ffffffffc0200ef6:	0141                	addi	sp,sp,16
ffffffffc0200ef8:	8082                	ret

ffffffffc0200efa <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200efa:	00001797          	auipc	a5,0x1
ffffffffc0200efe:	00e78793          	addi	a5,a5,14 # ffffffffc0201f08 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f02:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f04:	1101                	addi	sp,sp,-32
ffffffffc0200f06:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	03850513          	addi	a0,a0,56 # ffffffffc0201f40 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f10:	00005497          	auipc	s1,0x5
ffffffffc0200f14:	68848493          	addi	s1,s1,1672 # ffffffffc0206598 <pmm_manager>
void pmm_init(void) {
ffffffffc0200f18:	ec06                	sd	ra,24(sp)
ffffffffc0200f1a:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f1c:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f1e:	994ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200f22:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f24:	00005417          	auipc	s0,0x5
ffffffffc0200f28:	68c40413          	addi	s0,s0,1676 # ffffffffc02065b0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200f2c:	679c                	ld	a5,8(a5)
ffffffffc0200f2e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f30:	57f5                	li	a5,-3
ffffffffc0200f32:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	02450513          	addi	a0,a0,36 # ffffffffc0201f58 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f3c:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200f3e:	974ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200f42:	46c5                	li	a3,17
ffffffffc0200f44:	06ee                	slli	a3,a3,0x1b
ffffffffc0200f46:	40100613          	li	a2,1025
ffffffffc0200f4a:	16fd                	addi	a3,a3,-1
ffffffffc0200f4c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200f50:	0656                	slli	a2,a2,0x15
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	01e50513          	addi	a0,a0,30 # ffffffffc0201f70 <buddy_system_pmm_manager+0x68>
ffffffffc0200f5a:	958ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f5e:	777d                	lui	a4,0xfffff
ffffffffc0200f60:	00006797          	auipc	a5,0x6
ffffffffc0200f64:	65f78793          	addi	a5,a5,1631 # ffffffffc02075bf <end+0xfff>
ffffffffc0200f68:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200f6a:	00005517          	auipc	a0,0x5
ffffffffc0200f6e:	61e50513          	addi	a0,a0,1566 # ffffffffc0206588 <npage>
ffffffffc0200f72:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f76:	00005597          	auipc	a1,0x5
ffffffffc0200f7a:	61a58593          	addi	a1,a1,1562 # ffffffffc0206590 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200f7e:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f80:	e19c                	sd	a5,0(a1)
ffffffffc0200f82:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f84:	4701                	li	a4,0
ffffffffc0200f86:	4885                	li	a7,1
ffffffffc0200f88:	fff80837          	lui	a6,0xfff80
ffffffffc0200f8c:	a011                	j	ffffffffc0200f90 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200f8e:	619c                	ld	a5,0(a1)
ffffffffc0200f90:	97b6                	add	a5,a5,a3
ffffffffc0200f92:	07a1                	addi	a5,a5,8
ffffffffc0200f94:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f98:	611c                	ld	a5,0(a0)
ffffffffc0200f9a:	0705                	addi	a4,a4,1
ffffffffc0200f9c:	02868693          	addi	a3,a3,40
ffffffffc0200fa0:	01078633          	add	a2,a5,a6
ffffffffc0200fa4:	fec765e3          	bltu	a4,a2,ffffffffc0200f8e <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fa8:	6190                	ld	a2,0(a1)
ffffffffc0200faa:	00279713          	slli	a4,a5,0x2
ffffffffc0200fae:	973e                	add	a4,a4,a5
ffffffffc0200fb0:	fec006b7          	lui	a3,0xfec00
ffffffffc0200fb4:	070e                	slli	a4,a4,0x3
ffffffffc0200fb6:	96b2                	add	a3,a3,a2
ffffffffc0200fb8:	96ba                	add	a3,a3,a4
ffffffffc0200fba:	c0200737          	lui	a4,0xc0200
ffffffffc0200fbe:	08e6ef63          	bltu	a3,a4,ffffffffc020105c <pmm_init+0x162>
ffffffffc0200fc2:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200fc4:	45c5                	li	a1,17
ffffffffc0200fc6:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fc8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200fca:	04b6e863          	bltu	a3,a1,ffffffffc020101a <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200fce:	609c                	ld	a5,0(s1)
ffffffffc0200fd0:	7b9c                	ld	a5,48(a5)
ffffffffc0200fd2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	03450513          	addi	a0,a0,52 # ffffffffc0202008 <buddy_system_pmm_manager+0x100>
ffffffffc0200fdc:	8d6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200fe0:	00004597          	auipc	a1,0x4
ffffffffc0200fe4:	02058593          	addi	a1,a1,32 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200fe8:	00005797          	auipc	a5,0x5
ffffffffc0200fec:	5cb7b023          	sd	a1,1472(a5) # ffffffffc02065a8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ff0:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ff4:	08f5e063          	bltu	a1,a5,ffffffffc0201074 <pmm_init+0x17a>
ffffffffc0200ff8:	6010                	ld	a2,0(s0)
}
ffffffffc0200ffa:	6442                	ld	s0,16(sp)
ffffffffc0200ffc:	60e2                	ld	ra,24(sp)
ffffffffc0200ffe:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201000:	40c58633          	sub	a2,a1,a2
ffffffffc0201004:	00005797          	auipc	a5,0x5
ffffffffc0201008:	58c7be23          	sd	a2,1436(a5) # ffffffffc02065a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	01c50513          	addi	a0,a0,28 # ffffffffc0202028 <buddy_system_pmm_manager+0x120>
}
ffffffffc0201014:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201016:	89cff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020101a:	6705                	lui	a4,0x1
ffffffffc020101c:	177d                	addi	a4,a4,-1
ffffffffc020101e:	96ba                	add	a3,a3,a4
ffffffffc0201020:	777d                	lui	a4,0xfffff
ffffffffc0201022:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201024:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201028:	00f57e63          	bgeu	a0,a5,ffffffffc0201044 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc020102c:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020102e:	982a                	add	a6,a6,a0
ffffffffc0201030:	00281513          	slli	a0,a6,0x2
ffffffffc0201034:	9542                	add	a0,a0,a6
ffffffffc0201036:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201038:	8d95                	sub	a1,a1,a3
ffffffffc020103a:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020103c:	81b1                	srli	a1,a1,0xc
ffffffffc020103e:	9532                	add	a0,a0,a2
ffffffffc0201040:	9782                	jalr	a5
}
ffffffffc0201042:	b771                	j	ffffffffc0200fce <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201044:	00001617          	auipc	a2,0x1
ffffffffc0201048:	f9460613          	addi	a2,a2,-108 # ffffffffc0201fd8 <buddy_system_pmm_manager+0xd0>
ffffffffc020104c:	06b00593          	li	a1,107
ffffffffc0201050:	00001517          	auipc	a0,0x1
ffffffffc0201054:	fa850513          	addi	a0,a0,-88 # ffffffffc0201ff8 <buddy_system_pmm_manager+0xf0>
ffffffffc0201058:	b54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	f4460613          	addi	a2,a2,-188 # ffffffffc0201fa0 <buddy_system_pmm_manager+0x98>
ffffffffc0201064:	06f00593          	li	a1,111
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	f6050513          	addi	a0,a0,-160 # ffffffffc0201fc8 <buddy_system_pmm_manager+0xc0>
ffffffffc0201070:	b3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201074:	86ae                	mv	a3,a1
ffffffffc0201076:	00001617          	auipc	a2,0x1
ffffffffc020107a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0201fa0 <buddy_system_pmm_manager+0x98>
ffffffffc020107e:	08a00593          	li	a1,138
ffffffffc0201082:	00001517          	auipc	a0,0x1
ffffffffc0201086:	f4650513          	addi	a0,a0,-186 # ffffffffc0201fc8 <buddy_system_pmm_manager+0xc0>
ffffffffc020108a:	b22ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020108e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020108e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201092:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201094:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201098:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020109a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020109e:	f022                	sd	s0,32(sp)
ffffffffc02010a0:	ec26                	sd	s1,24(sp)
ffffffffc02010a2:	e84a                	sd	s2,16(sp)
ffffffffc02010a4:	f406                	sd	ra,40(sp)
ffffffffc02010a6:	e44e                	sd	s3,8(sp)
ffffffffc02010a8:	84aa                	mv	s1,a0
ffffffffc02010aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02010ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02010b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02010b2:	03067e63          	bgeu	a2,a6,ffffffffc02010ee <printnum+0x60>
ffffffffc02010b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02010b8:	00805763          	blez	s0,ffffffffc02010c6 <printnum+0x38>
ffffffffc02010bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02010be:	85ca                	mv	a1,s2
ffffffffc02010c0:	854e                	mv	a0,s3
ffffffffc02010c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02010c4:	fc65                	bnez	s0,ffffffffc02010bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010c6:	1a02                	slli	s4,s4,0x20
ffffffffc02010c8:	00001797          	auipc	a5,0x1
ffffffffc02010cc:	fa078793          	addi	a5,a5,-96 # ffffffffc0202068 <buddy_system_pmm_manager+0x160>
ffffffffc02010d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02010d4:	9a3e                	add	s4,s4,a5
}
ffffffffc02010d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02010dc:	70a2                	ld	ra,40(sp)
ffffffffc02010de:	69a2                	ld	s3,8(sp)
ffffffffc02010e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010e2:	85ca                	mv	a1,s2
ffffffffc02010e4:	87a6                	mv	a5,s1
}
ffffffffc02010e6:	6942                	ld	s2,16(sp)
ffffffffc02010e8:	64e2                	ld	s1,24(sp)
ffffffffc02010ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02010ee:	03065633          	divu	a2,a2,a6
ffffffffc02010f2:	8722                	mv	a4,s0
ffffffffc02010f4:	f9bff0ef          	jal	ra,ffffffffc020108e <printnum>
ffffffffc02010f8:	b7f9                	j	ffffffffc02010c6 <printnum+0x38>

ffffffffc02010fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02010fa:	7119                	addi	sp,sp,-128
ffffffffc02010fc:	f4a6                	sd	s1,104(sp)
ffffffffc02010fe:	f0ca                	sd	s2,96(sp)
ffffffffc0201100:	ecce                	sd	s3,88(sp)
ffffffffc0201102:	e8d2                	sd	s4,80(sp)
ffffffffc0201104:	e4d6                	sd	s5,72(sp)
ffffffffc0201106:	e0da                	sd	s6,64(sp)
ffffffffc0201108:	fc5e                	sd	s7,56(sp)
ffffffffc020110a:	f06a                	sd	s10,32(sp)
ffffffffc020110c:	fc86                	sd	ra,120(sp)
ffffffffc020110e:	f8a2                	sd	s0,112(sp)
ffffffffc0201110:	f862                	sd	s8,48(sp)
ffffffffc0201112:	f466                	sd	s9,40(sp)
ffffffffc0201114:	ec6e                	sd	s11,24(sp)
ffffffffc0201116:	892a                	mv	s2,a0
ffffffffc0201118:	84ae                	mv	s1,a1
ffffffffc020111a:	8d32                	mv	s10,a2
ffffffffc020111c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020111e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201122:	5b7d                	li	s6,-1
ffffffffc0201124:	00001a97          	auipc	s5,0x1
ffffffffc0201128:	f78a8a93          	addi	s5,s5,-136 # ffffffffc020209c <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020112c:	00001b97          	auipc	s7,0x1
ffffffffc0201130:	14cb8b93          	addi	s7,s7,332 # ffffffffc0202278 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201134:	000d4503          	lbu	a0,0(s10)
ffffffffc0201138:	001d0413          	addi	s0,s10,1
ffffffffc020113c:	01350a63          	beq	a0,s3,ffffffffc0201150 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201140:	c121                	beqz	a0,ffffffffc0201180 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201142:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201144:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201146:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201148:	fff44503          	lbu	a0,-1(s0)
ffffffffc020114c:	ff351ae3          	bne	a0,s3,ffffffffc0201140 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201150:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201154:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201158:	4c81                	li	s9,0
ffffffffc020115a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020115c:	5c7d                	li	s8,-1
ffffffffc020115e:	5dfd                	li	s11,-1
ffffffffc0201160:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201164:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201166:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020116a:	0ff5f593          	zext.b	a1,a1
ffffffffc020116e:	00140d13          	addi	s10,s0,1
ffffffffc0201172:	04b56263          	bltu	a0,a1,ffffffffc02011b6 <vprintfmt+0xbc>
ffffffffc0201176:	058a                	slli	a1,a1,0x2
ffffffffc0201178:	95d6                	add	a1,a1,s5
ffffffffc020117a:	4194                	lw	a3,0(a1)
ffffffffc020117c:	96d6                	add	a3,a3,s5
ffffffffc020117e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201180:	70e6                	ld	ra,120(sp)
ffffffffc0201182:	7446                	ld	s0,112(sp)
ffffffffc0201184:	74a6                	ld	s1,104(sp)
ffffffffc0201186:	7906                	ld	s2,96(sp)
ffffffffc0201188:	69e6                	ld	s3,88(sp)
ffffffffc020118a:	6a46                	ld	s4,80(sp)
ffffffffc020118c:	6aa6                	ld	s5,72(sp)
ffffffffc020118e:	6b06                	ld	s6,64(sp)
ffffffffc0201190:	7be2                	ld	s7,56(sp)
ffffffffc0201192:	7c42                	ld	s8,48(sp)
ffffffffc0201194:	7ca2                	ld	s9,40(sp)
ffffffffc0201196:	7d02                	ld	s10,32(sp)
ffffffffc0201198:	6de2                	ld	s11,24(sp)
ffffffffc020119a:	6109                	addi	sp,sp,128
ffffffffc020119c:	8082                	ret
            padc = '0';
ffffffffc020119e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02011a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a4:	846a                	mv	s0,s10
ffffffffc02011a6:	00140d13          	addi	s10,s0,1
ffffffffc02011aa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02011ae:	0ff5f593          	zext.b	a1,a1
ffffffffc02011b2:	fcb572e3          	bgeu	a0,a1,ffffffffc0201176 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02011b6:	85a6                	mv	a1,s1
ffffffffc02011b8:	02500513          	li	a0,37
ffffffffc02011bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02011be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02011c2:	8d22                	mv	s10,s0
ffffffffc02011c4:	f73788e3          	beq	a5,s3,ffffffffc0201134 <vprintfmt+0x3a>
ffffffffc02011c8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02011cc:	1d7d                	addi	s10,s10,-1
ffffffffc02011ce:	ff379de3          	bne	a5,s3,ffffffffc02011c8 <vprintfmt+0xce>
ffffffffc02011d2:	b78d                	j	ffffffffc0201134 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02011d4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02011d8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011dc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02011de:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02011e2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02011e6:	02d86463          	bltu	a6,a3,ffffffffc020120e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02011ea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02011ee:	002c169b          	slliw	a3,s8,0x2
ffffffffc02011f2:	0186873b          	addw	a4,a3,s8
ffffffffc02011f6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02011fa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02011fc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201200:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201202:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201206:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020120a:	fed870e3          	bgeu	a6,a3,ffffffffc02011ea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020120e:	f40ddce3          	bgez	s11,ffffffffc0201166 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201212:	8de2                	mv	s11,s8
ffffffffc0201214:	5c7d                	li	s8,-1
ffffffffc0201216:	bf81                	j	ffffffffc0201166 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201218:	fffdc693          	not	a3,s11
ffffffffc020121c:	96fd                	srai	a3,a3,0x3f
ffffffffc020121e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201222:	00144603          	lbu	a2,1(s0)
ffffffffc0201226:	2d81                	sext.w	s11,s11
ffffffffc0201228:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020122a:	bf35                	j	ffffffffc0201166 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020122c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201230:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201234:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201236:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201238:	bfd9                	j	ffffffffc020120e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020123a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020123c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201240:	01174463          	blt	a4,a7,ffffffffc0201248 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201244:	1a088e63          	beqz	a7,ffffffffc0201400 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201248:	000a3603          	ld	a2,0(s4)
ffffffffc020124c:	46c1                	li	a3,16
ffffffffc020124e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201250:	2781                	sext.w	a5,a5
ffffffffc0201252:	876e                	mv	a4,s11
ffffffffc0201254:	85a6                	mv	a1,s1
ffffffffc0201256:	854a                	mv	a0,s2
ffffffffc0201258:	e37ff0ef          	jal	ra,ffffffffc020108e <printnum>
            break;
ffffffffc020125c:	bde1                	j	ffffffffc0201134 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020125e:	000a2503          	lw	a0,0(s4)
ffffffffc0201262:	85a6                	mv	a1,s1
ffffffffc0201264:	0a21                	addi	s4,s4,8
ffffffffc0201266:	9902                	jalr	s2
            break;
ffffffffc0201268:	b5f1                	j	ffffffffc0201134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020126a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020126c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201270:	01174463          	blt	a4,a7,ffffffffc0201278 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201274:	18088163          	beqz	a7,ffffffffc02013f6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201278:	000a3603          	ld	a2,0(s4)
ffffffffc020127c:	46a9                	li	a3,10
ffffffffc020127e:	8a2e                	mv	s4,a1
ffffffffc0201280:	bfc1                	j	ffffffffc0201250 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201282:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201286:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201288:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020128a:	bdf1                	j	ffffffffc0201166 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020128c:	85a6                	mv	a1,s1
ffffffffc020128e:	02500513          	li	a0,37
ffffffffc0201292:	9902                	jalr	s2
            break;
ffffffffc0201294:	b545                	j	ffffffffc0201134 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201296:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020129a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020129c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020129e:	b5e1                	j	ffffffffc0201166 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02012a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012a6:	01174463          	blt	a4,a7,ffffffffc02012ae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02012aa:	14088163          	beqz	a7,ffffffffc02013ec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02012ae:	000a3603          	ld	a2,0(s4)
ffffffffc02012b2:	46a1                	li	a3,8
ffffffffc02012b4:	8a2e                	mv	s4,a1
ffffffffc02012b6:	bf69                	j	ffffffffc0201250 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02012b8:	03000513          	li	a0,48
ffffffffc02012bc:	85a6                	mv	a1,s1
ffffffffc02012be:	e03e                	sd	a5,0(sp)
ffffffffc02012c0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02012c2:	85a6                	mv	a1,s1
ffffffffc02012c4:	07800513          	li	a0,120
ffffffffc02012c8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012ca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02012cc:	6782                	ld	a5,0(sp)
ffffffffc02012ce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012d0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02012d4:	bfb5                	j	ffffffffc0201250 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012d6:	000a3403          	ld	s0,0(s4)
ffffffffc02012da:	008a0713          	addi	a4,s4,8
ffffffffc02012de:	e03a                	sd	a4,0(sp)
ffffffffc02012e0:	14040263          	beqz	s0,ffffffffc0201424 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02012e4:	0fb05763          	blez	s11,ffffffffc02013d2 <vprintfmt+0x2d8>
ffffffffc02012e8:	02d00693          	li	a3,45
ffffffffc02012ec:	0cd79163          	bne	a5,a3,ffffffffc02013ae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012f0:	00044783          	lbu	a5,0(s0)
ffffffffc02012f4:	0007851b          	sext.w	a0,a5
ffffffffc02012f8:	cf85                	beqz	a5,ffffffffc0201330 <vprintfmt+0x236>
ffffffffc02012fa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012fe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201302:	000c4563          	bltz	s8,ffffffffc020130c <vprintfmt+0x212>
ffffffffc0201306:	3c7d                	addiw	s8,s8,-1
ffffffffc0201308:	036c0263          	beq	s8,s6,ffffffffc020132c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020130c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020130e:	0e0c8e63          	beqz	s9,ffffffffc020140a <vprintfmt+0x310>
ffffffffc0201312:	3781                	addiw	a5,a5,-32
ffffffffc0201314:	0ef47b63          	bgeu	s0,a5,ffffffffc020140a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201318:	03f00513          	li	a0,63
ffffffffc020131c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020131e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201322:	3dfd                	addiw	s11,s11,-1
ffffffffc0201324:	0a05                	addi	s4,s4,1
ffffffffc0201326:	0007851b          	sext.w	a0,a5
ffffffffc020132a:	ffe1                	bnez	a5,ffffffffc0201302 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020132c:	01b05963          	blez	s11,ffffffffc020133e <vprintfmt+0x244>
ffffffffc0201330:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201332:	85a6                	mv	a1,s1
ffffffffc0201334:	02000513          	li	a0,32
ffffffffc0201338:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020133a:	fe0d9be3          	bnez	s11,ffffffffc0201330 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020133e:	6a02                	ld	s4,0(sp)
ffffffffc0201340:	bbd5                	j	ffffffffc0201134 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201342:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201344:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201348:	01174463          	blt	a4,a7,ffffffffc0201350 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020134c:	08088d63          	beqz	a7,ffffffffc02013e6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201350:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201354:	0a044d63          	bltz	s0,ffffffffc020140e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201358:	8622                	mv	a2,s0
ffffffffc020135a:	8a66                	mv	s4,s9
ffffffffc020135c:	46a9                	li	a3,10
ffffffffc020135e:	bdcd                	j	ffffffffc0201250 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201360:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201364:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201366:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201368:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020136c:	8fb5                	xor	a5,a5,a3
ffffffffc020136e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201372:	02d74163          	blt	a4,a3,ffffffffc0201394 <vprintfmt+0x29a>
ffffffffc0201376:	00369793          	slli	a5,a3,0x3
ffffffffc020137a:	97de                	add	a5,a5,s7
ffffffffc020137c:	639c                	ld	a5,0(a5)
ffffffffc020137e:	cb99                	beqz	a5,ffffffffc0201394 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201380:	86be                	mv	a3,a5
ffffffffc0201382:	00001617          	auipc	a2,0x1
ffffffffc0201386:	d1660613          	addi	a2,a2,-746 # ffffffffc0202098 <buddy_system_pmm_manager+0x190>
ffffffffc020138a:	85a6                	mv	a1,s1
ffffffffc020138c:	854a                	mv	a0,s2
ffffffffc020138e:	0ce000ef          	jal	ra,ffffffffc020145c <printfmt>
ffffffffc0201392:	b34d                	j	ffffffffc0201134 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201394:	00001617          	auipc	a2,0x1
ffffffffc0201398:	cf460613          	addi	a2,a2,-780 # ffffffffc0202088 <buddy_system_pmm_manager+0x180>
ffffffffc020139c:	85a6                	mv	a1,s1
ffffffffc020139e:	854a                	mv	a0,s2
ffffffffc02013a0:	0bc000ef          	jal	ra,ffffffffc020145c <printfmt>
ffffffffc02013a4:	bb41                	j	ffffffffc0201134 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02013a6:	00001417          	auipc	s0,0x1
ffffffffc02013aa:	cda40413          	addi	s0,s0,-806 # ffffffffc0202080 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013ae:	85e2                	mv	a1,s8
ffffffffc02013b0:	8522                	mv	a0,s0
ffffffffc02013b2:	e43e                	sd	a5,8(sp)
ffffffffc02013b4:	1cc000ef          	jal	ra,ffffffffc0201580 <strnlen>
ffffffffc02013b8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02013bc:	01b05b63          	blez	s11,ffffffffc02013d2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02013c0:	67a2                	ld	a5,8(sp)
ffffffffc02013c2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02013c8:	85a6                	mv	a1,s1
ffffffffc02013ca:	8552                	mv	a0,s4
ffffffffc02013cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013ce:	fe0d9ce3          	bnez	s11,ffffffffc02013c6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013d2:	00044783          	lbu	a5,0(s0)
ffffffffc02013d6:	00140a13          	addi	s4,s0,1
ffffffffc02013da:	0007851b          	sext.w	a0,a5
ffffffffc02013de:	d3a5                	beqz	a5,ffffffffc020133e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013e0:	05e00413          	li	s0,94
ffffffffc02013e4:	bf39                	j	ffffffffc0201302 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02013e6:	000a2403          	lw	s0,0(s4)
ffffffffc02013ea:	b7ad                	j	ffffffffc0201354 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02013ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02013f0:	46a1                	li	a3,8
ffffffffc02013f2:	8a2e                	mv	s4,a1
ffffffffc02013f4:	bdb1                	j	ffffffffc0201250 <vprintfmt+0x156>
ffffffffc02013f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02013fa:	46a9                	li	a3,10
ffffffffc02013fc:	8a2e                	mv	s4,a1
ffffffffc02013fe:	bd89                	j	ffffffffc0201250 <vprintfmt+0x156>
ffffffffc0201400:	000a6603          	lwu	a2,0(s4)
ffffffffc0201404:	46c1                	li	a3,16
ffffffffc0201406:	8a2e                	mv	s4,a1
ffffffffc0201408:	b5a1                	j	ffffffffc0201250 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020140a:	9902                	jalr	s2
ffffffffc020140c:	bf09                	j	ffffffffc020131e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020140e:	85a6                	mv	a1,s1
ffffffffc0201410:	02d00513          	li	a0,45
ffffffffc0201414:	e03e                	sd	a5,0(sp)
ffffffffc0201416:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201418:	6782                	ld	a5,0(sp)
ffffffffc020141a:	8a66                	mv	s4,s9
ffffffffc020141c:	40800633          	neg	a2,s0
ffffffffc0201420:	46a9                	li	a3,10
ffffffffc0201422:	b53d                	j	ffffffffc0201250 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201424:	03b05163          	blez	s11,ffffffffc0201446 <vprintfmt+0x34c>
ffffffffc0201428:	02d00693          	li	a3,45
ffffffffc020142c:	f6d79de3          	bne	a5,a3,ffffffffc02013a6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201430:	00001417          	auipc	s0,0x1
ffffffffc0201434:	c5040413          	addi	s0,s0,-944 # ffffffffc0202080 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201438:	02800793          	li	a5,40
ffffffffc020143c:	02800513          	li	a0,40
ffffffffc0201440:	00140a13          	addi	s4,s0,1
ffffffffc0201444:	bd6d                	j	ffffffffc02012fe <vprintfmt+0x204>
ffffffffc0201446:	00001a17          	auipc	s4,0x1
ffffffffc020144a:	c3ba0a13          	addi	s4,s4,-965 # ffffffffc0202081 <buddy_system_pmm_manager+0x179>
ffffffffc020144e:	02800513          	li	a0,40
ffffffffc0201452:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201456:	05e00413          	li	s0,94
ffffffffc020145a:	b565                	j	ffffffffc0201302 <vprintfmt+0x208>

ffffffffc020145c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020145c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020145e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201462:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201464:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201466:	ec06                	sd	ra,24(sp)
ffffffffc0201468:	f83a                	sd	a4,48(sp)
ffffffffc020146a:	fc3e                	sd	a5,56(sp)
ffffffffc020146c:	e0c2                	sd	a6,64(sp)
ffffffffc020146e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201470:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201472:	c89ff0ef          	jal	ra,ffffffffc02010fa <vprintfmt>
}
ffffffffc0201476:	60e2                	ld	ra,24(sp)
ffffffffc0201478:	6161                	addi	sp,sp,80
ffffffffc020147a:	8082                	ret

ffffffffc020147c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020147c:	715d                	addi	sp,sp,-80
ffffffffc020147e:	e486                	sd	ra,72(sp)
ffffffffc0201480:	e0a6                	sd	s1,64(sp)
ffffffffc0201482:	fc4a                	sd	s2,56(sp)
ffffffffc0201484:	f84e                	sd	s3,48(sp)
ffffffffc0201486:	f452                	sd	s4,40(sp)
ffffffffc0201488:	f056                	sd	s5,32(sp)
ffffffffc020148a:	ec5a                	sd	s6,24(sp)
ffffffffc020148c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020148e:	c901                	beqz	a0,ffffffffc020149e <readline+0x22>
ffffffffc0201490:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201492:	00001517          	auipc	a0,0x1
ffffffffc0201496:	c0650513          	addi	a0,a0,-1018 # ffffffffc0202098 <buddy_system_pmm_manager+0x190>
ffffffffc020149a:	c19fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020149e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014a0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02014a2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02014a4:	4aa9                	li	s5,10
ffffffffc02014a6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02014a8:	00005b97          	auipc	s7,0x5
ffffffffc02014ac:	cd0b8b93          	addi	s7,s7,-816 # ffffffffc0206178 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014b0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02014b4:	c77fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02014b8:	00054a63          	bltz	a0,ffffffffc02014cc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014bc:	00a95a63          	bge	s2,a0,ffffffffc02014d0 <readline+0x54>
ffffffffc02014c0:	029a5263          	bge	s4,s1,ffffffffc02014e4 <readline+0x68>
        c = getchar();
ffffffffc02014c4:	c67fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02014c8:	fe055ae3          	bgez	a0,ffffffffc02014bc <readline+0x40>
            return NULL;
ffffffffc02014cc:	4501                	li	a0,0
ffffffffc02014ce:	a091                	j	ffffffffc0201512 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02014d0:	03351463          	bne	a0,s3,ffffffffc02014f8 <readline+0x7c>
ffffffffc02014d4:	e8a9                	bnez	s1,ffffffffc0201526 <readline+0xaa>
        c = getchar();
ffffffffc02014d6:	c55fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02014da:	fe0549e3          	bltz	a0,ffffffffc02014cc <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014de:	fea959e3          	bge	s2,a0,ffffffffc02014d0 <readline+0x54>
ffffffffc02014e2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02014e4:	e42a                	sd	a0,8(sp)
ffffffffc02014e6:	c03fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02014ea:	6522                	ld	a0,8(sp)
ffffffffc02014ec:	009b87b3          	add	a5,s7,s1
ffffffffc02014f0:	2485                	addiw	s1,s1,1
ffffffffc02014f2:	00a78023          	sb	a0,0(a5)
ffffffffc02014f6:	bf7d                	j	ffffffffc02014b4 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02014f8:	01550463          	beq	a0,s5,ffffffffc0201500 <readline+0x84>
ffffffffc02014fc:	fb651ce3          	bne	a0,s6,ffffffffc02014b4 <readline+0x38>
            cputchar(c);
ffffffffc0201500:	be9fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201504:	00005517          	auipc	a0,0x5
ffffffffc0201508:	c7450513          	addi	a0,a0,-908 # ffffffffc0206178 <buf>
ffffffffc020150c:	94aa                	add	s1,s1,a0
ffffffffc020150e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201512:	60a6                	ld	ra,72(sp)
ffffffffc0201514:	6486                	ld	s1,64(sp)
ffffffffc0201516:	7962                	ld	s2,56(sp)
ffffffffc0201518:	79c2                	ld	s3,48(sp)
ffffffffc020151a:	7a22                	ld	s4,40(sp)
ffffffffc020151c:	7a82                	ld	s5,32(sp)
ffffffffc020151e:	6b62                	ld	s6,24(sp)
ffffffffc0201520:	6bc2                	ld	s7,16(sp)
ffffffffc0201522:	6161                	addi	sp,sp,80
ffffffffc0201524:	8082                	ret
            cputchar(c);
ffffffffc0201526:	4521                	li	a0,8
ffffffffc0201528:	bc1fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc020152c:	34fd                	addiw	s1,s1,-1
ffffffffc020152e:	b759                	j	ffffffffc02014b4 <readline+0x38>

ffffffffc0201530 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201530:	4781                	li	a5,0
ffffffffc0201532:	00005717          	auipc	a4,0x5
ffffffffc0201536:	ad673703          	ld	a4,-1322(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020153a:	88ba                	mv	a7,a4
ffffffffc020153c:	852a                	mv	a0,a0
ffffffffc020153e:	85be                	mv	a1,a5
ffffffffc0201540:	863e                	mv	a2,a5
ffffffffc0201542:	00000073          	ecall
ffffffffc0201546:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201548:	8082                	ret

ffffffffc020154a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc020154a:	4781                	li	a5,0
ffffffffc020154c:	00005717          	auipc	a4,0x5
ffffffffc0201550:	06c73703          	ld	a4,108(a4) # ffffffffc02065b8 <SBI_SET_TIMER>
ffffffffc0201554:	88ba                	mv	a7,a4
ffffffffc0201556:	852a                	mv	a0,a0
ffffffffc0201558:	85be                	mv	a1,a5
ffffffffc020155a:	863e                	mv	a2,a5
ffffffffc020155c:	00000073          	ecall
ffffffffc0201560:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201562:	8082                	ret

ffffffffc0201564 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201564:	4501                	li	a0,0
ffffffffc0201566:	00005797          	auipc	a5,0x5
ffffffffc020156a:	a9a7b783          	ld	a5,-1382(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020156e:	88be                	mv	a7,a5
ffffffffc0201570:	852a                	mv	a0,a0
ffffffffc0201572:	85aa                	mv	a1,a0
ffffffffc0201574:	862a                	mv	a2,a0
ffffffffc0201576:	00000073          	ecall
ffffffffc020157a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020157c:	2501                	sext.w	a0,a0
ffffffffc020157e:	8082                	ret

ffffffffc0201580 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201580:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201582:	e589                	bnez	a1,ffffffffc020158c <strnlen+0xc>
ffffffffc0201584:	a811                	j	ffffffffc0201598 <strnlen+0x18>
        cnt ++;
ffffffffc0201586:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201588:	00f58863          	beq	a1,a5,ffffffffc0201598 <strnlen+0x18>
ffffffffc020158c:	00f50733          	add	a4,a0,a5
ffffffffc0201590:	00074703          	lbu	a4,0(a4)
ffffffffc0201594:	fb6d                	bnez	a4,ffffffffc0201586 <strnlen+0x6>
ffffffffc0201596:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201598:	852e                	mv	a0,a1
ffffffffc020159a:	8082                	ret

ffffffffc020159c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020159c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015a0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015a4:	cb89                	beqz	a5,ffffffffc02015b6 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02015a6:	0505                	addi	a0,a0,1
ffffffffc02015a8:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015aa:	fee789e3          	beq	a5,a4,ffffffffc020159c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015ae:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02015b2:	9d19                	subw	a0,a0,a4
ffffffffc02015b4:	8082                	ret
ffffffffc02015b6:	4501                	li	a0,0
ffffffffc02015b8:	bfed                	j	ffffffffc02015b2 <strcmp+0x16>

ffffffffc02015ba <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02015ba:	00054783          	lbu	a5,0(a0)
ffffffffc02015be:	c799                	beqz	a5,ffffffffc02015cc <strchr+0x12>
        if (*s == c) {
ffffffffc02015c0:	00f58763          	beq	a1,a5,ffffffffc02015ce <strchr+0x14>
    while (*s != '\0') {
ffffffffc02015c4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02015c8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02015ca:	fbfd                	bnez	a5,ffffffffc02015c0 <strchr+0x6>
    }
    return NULL;
ffffffffc02015cc:	4501                	li	a0,0
}
ffffffffc02015ce:	8082                	ret

ffffffffc02015d0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02015d0:	ca01                	beqz	a2,ffffffffc02015e0 <memset+0x10>
ffffffffc02015d2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02015d4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015d6:	0785                	addi	a5,a5,1
ffffffffc02015d8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02015dc:	fec79de3          	bne	a5,a2,ffffffffc02015d6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02015e0:	8082                	ret
