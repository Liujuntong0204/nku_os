
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
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0206570 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	50c010ef          	jal	ra,ffffffffc0201556 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	51650513          	addi	a0,a0,1302 # ffffffffc0201568 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	601000ef          	jal	ra,ffffffffc0200e66 <pmm_init>

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
ffffffffc02000a6:	7c1000ef          	jal	ra,ffffffffc0201066 <vprintfmt>
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
ffffffffc02000dc:	78b000ef          	jal	ra,ffffffffc0201066 <vprintfmt>
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
ffffffffc0200140:	44c50513          	addi	a0,a0,1100 # ffffffffc0201588 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	45650513          	addi	a0,a0,1110 # ffffffffc02015a8 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	40a58593          	addi	a1,a1,1034 # ffffffffc0201568 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	46250513          	addi	a0,a0,1122 # ffffffffc02015c8 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	46e50513          	addi	a0,a0,1134 # ffffffffc02015e8 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3ea58593          	addi	a1,a1,1002 # ffffffffc0206570 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	47a50513          	addi	a0,a0,1146 # ffffffffc0201608 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	7d558593          	addi	a1,a1,2005 # ffffffffc020696f <end+0x3ff>
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
ffffffffc02001c0:	46c50513          	addi	a0,a0,1132 # ffffffffc0201628 <etext+0xc0>
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
ffffffffc02001ce:	48e60613          	addi	a2,a2,1166 # ffffffffc0201658 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	49a50513          	addi	a0,a0,1178 # ffffffffc0201670 <etext+0x108>
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
ffffffffc02001ea:	4a260613          	addi	a2,a2,1186 # ffffffffc0201688 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	4ba58593          	addi	a1,a1,1210 # ffffffffc02016a8 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	4ba50513          	addi	a0,a0,1210 # ffffffffc02016b0 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	4bc60613          	addi	a2,a2,1212 # ffffffffc02016c0 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	4dc58593          	addi	a1,a1,1244 # ffffffffc02016e8 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	49c50513          	addi	a0,a0,1180 # ffffffffc02016b0 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	4d860613          	addi	a2,a2,1240 # ffffffffc02016f8 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	4f058593          	addi	a1,a1,1264 # ffffffffc0201718 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	48050513          	addi	a0,a0,1152 # ffffffffc02016b0 <etext+0x148>
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
ffffffffc020026e:	4be50513          	addi	a0,a0,1214 # ffffffffc0201728 <etext+0x1c0>
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
ffffffffc0200290:	4c450513          	addi	a0,a0,1220 # ffffffffc0201750 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	51ec0c13          	addi	s8,s8,1310 # ffffffffc02017c0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	4ce90913          	addi	s2,s2,1230 # ffffffffc0201778 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	4ce48493          	addi	s1,s1,1230 # ffffffffc0201780 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	4ccb0b13          	addi	s6,s6,1228 # ffffffffc0201788 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	3e4a0a13          	addi	s4,s4,996 # ffffffffc02016a8 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	118010ef          	jal	ra,ffffffffc02013e8 <readline>
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
ffffffffc02002ea:	4dad0d13          	addi	s10,s10,1242 # ffffffffc02017c0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	22e010ef          	jal	ra,ffffffffc0201522 <strcmp>
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
ffffffffc0200308:	21a010ef          	jal	ra,ffffffffc0201522 <strcmp>
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
ffffffffc0200346:	1fa010ef          	jal	ra,ffffffffc0201540 <strchr>
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
ffffffffc0200384:	1bc010ef          	jal	ra,ffffffffc0201540 <strchr>
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
ffffffffc02003a2:	40a50513          	addi	a0,a0,1034 # ffffffffc02017a8 <etext+0x240>
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
ffffffffc02003b0:	17430313          	addi	t1,t1,372 # ffffffffc0206520 <is_panic>
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
ffffffffc02003de:	42e50513          	addi	a0,a0,1070 # ffffffffc0201808 <commands+0x48>
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
ffffffffc02003f4:	26050513          	addi	a0,a0,608 # ffffffffc0201650 <etext+0xe8>
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
ffffffffc0200420:	096010ef          	jal	ra,ffffffffc02014b6 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1007b123          	sd	zero,258(a5) # ffffffffc0206528 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201828 <commands+0x68>
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
ffffffffc0200446:	0700106f          	j	ffffffffc02014b6 <sbi_set_timer>

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
ffffffffc0200450:	04c0106f          	j	ffffffffc020149c <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	07c0106f          	j	ffffffffc02014d0 <sbi_console_getchar>

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
ffffffffc0200482:	3ca50513          	addi	a0,a0,970 # ffffffffc0201848 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	3d250513          	addi	a0,a0,978 # ffffffffc0201860 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	3dc50513          	addi	a0,a0,988 # ffffffffc0201878 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	3e650513          	addi	a0,a0,998 # ffffffffc0201890 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	3f050513          	addi	a0,a0,1008 # ffffffffc02018a8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	3fa50513          	addi	a0,a0,1018 # ffffffffc02018c0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	40450513          	addi	a0,a0,1028 # ffffffffc02018d8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	40e50513          	addi	a0,a0,1038 # ffffffffc02018f0 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	41850513          	addi	a0,a0,1048 # ffffffffc0201908 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	42250513          	addi	a0,a0,1058 # ffffffffc0201920 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	42c50513          	addi	a0,a0,1068 # ffffffffc0201938 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	43650513          	addi	a0,a0,1078 # ffffffffc0201950 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	44050513          	addi	a0,a0,1088 # ffffffffc0201968 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	44a50513          	addi	a0,a0,1098 # ffffffffc0201980 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	45450513          	addi	a0,a0,1108 # ffffffffc0201998 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	45e50513          	addi	a0,a0,1118 # ffffffffc02019b0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	46850513          	addi	a0,a0,1128 # ffffffffc02019c8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	47250513          	addi	a0,a0,1138 # ffffffffc02019e0 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	47c50513          	addi	a0,a0,1148 # ffffffffc02019f8 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	48650513          	addi	a0,a0,1158 # ffffffffc0201a10 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	49050513          	addi	a0,a0,1168 # ffffffffc0201a28 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	49a50513          	addi	a0,a0,1178 # ffffffffc0201a40 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	4a450513          	addi	a0,a0,1188 # ffffffffc0201a58 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201a70 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4b850513          	addi	a0,a0,1208 # ffffffffc0201a88 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4c250513          	addi	a0,a0,1218 # ffffffffc0201aa0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4cc50513          	addi	a0,a0,1228 # ffffffffc0201ab8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	4d650513          	addi	a0,a0,1238 # ffffffffc0201ad0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	4e050513          	addi	a0,a0,1248 # ffffffffc0201ae8 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201b00 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	4f450513          	addi	a0,a0,1268 # ffffffffc0201b18 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201b30 <commands+0x370>
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
ffffffffc020064e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201b48 <commands+0x388>
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
ffffffffc0200666:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201b60 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	50650513          	addi	a0,a0,1286 # ffffffffc0201b78 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	50e50513          	addi	a0,a0,1294 # ffffffffc0201b90 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	51250513          	addi	a0,a0,1298 # ffffffffc0201ba8 <commands+0x3e8>
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
ffffffffc02006b4:	5d870713          	addi	a4,a4,1496 # ffffffffc0201c88 <commands+0x4c8>
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
ffffffffc02006c6:	55e50513          	addi	a0,a0,1374 # ffffffffc0201c20 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	53450513          	addi	a0,a0,1332 # ffffffffc0201c00 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201bc0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	56050513          	addi	a0,a0,1376 # ffffffffc0201c40 <commands+0x480>
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
ffffffffc02006f6:	e3668693          	addi	a3,a3,-458 # ffffffffc0206528 <ticks>
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
ffffffffc0200714:	55850513          	addi	a0,a0,1368 # ffffffffc0201c68 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	4c650513          	addi	a0,a0,1222 # ffffffffc0201be0 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200726:	06400593          	li	a1,100
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	52e50513          	addi	a0,a0,1326 # ffffffffc0201c58 <commands+0x498>
ffffffffc0200732:	981ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                PRINT_NUM++;
ffffffffc0200736:	00006717          	auipc	a4,0x6
ffffffffc020073a:	dfa70713          	addi	a4,a4,-518 # ffffffffc0206530 <PRINT_NUM>
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
ffffffffc0200750:	59d0006f          	j	ffffffffc02014ec <sbi_shutdown>

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
ffffffffc0200774:	54850513          	addi	a0,a0,1352 # ffffffffc0201cb8 <commands+0x4f8>
ffffffffc0200778:	93bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);
ffffffffc020077c:	10843583          	ld	a1,264(s0)
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	56050513          	addi	a0,a0,1376 # ffffffffc0201ce0 <commands+0x520>
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
ffffffffc02007b2:	56250513          	addi	a0,a0,1378 # ffffffffc0201d10 <commands+0x550>
ffffffffc02007b6:	8fdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007ba:	10843583          	ld	a1,264(s0)
ffffffffc02007be:	00001517          	auipc	a0,0x1
ffffffffc02007c2:	57250513          	addi	a0,a0,1394 # ffffffffc0201d30 <commands+0x570>
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
#define IS_POWER_OF_2(x) (!((x) & ((x) - 1)))

static void
buddy_system_init(void)
{
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc020089e:	00005797          	auipc	a5,0x5
ffffffffc02008a2:	77a78793          	addi	a5,a5,1914 # ffffffffc0206018 <free_area>
ffffffffc02008a6:	00006717          	auipc	a4,0x6
ffffffffc02008aa:	87a70713          	addi	a4,a4,-1926 # ffffffffc0206120 <buf>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008ae:	e79c                	sd	a5,8(a5)
ffffffffc02008b0:	e39c                	sd	a5,0(a5)
    {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc02008b2:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02008b6:	07e1                	addi	a5,a5,24
ffffffffc02008b8:	fee79be3          	bne	a5,a4,ffffffffc02008ae <buddy_system_init+0x10>
    }
}
ffffffffc02008bc:	8082                	ret

ffffffffc02008be <split_page>:
    }
}

// 取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
static void split_page(int order)
{
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
ffffffffc02008d4:	74898993          	addi	s3,s3,1864 # ffffffffc0206018 <free_area>
ffffffffc02008d8:	014987b3          	add	a5,s3,s4
ffffffffc02008dc:	ec26                	sd	s1,24(sp)
ffffffffc02008de:	6784                	ld	s1,8(a5)
ffffffffc02008e0:	f022                	sd	s0,32(sp)
ffffffffc02008e2:	f406                	sd	ra,40(sp)
ffffffffc02008e4:	842a                	mv	s0,a0
    if (list_empty(&(free_list(order))))
ffffffffc02008e6:	08f48063          	beq	s1,a5,ffffffffc0200966 <split_page+0xa8>
        split_page(order + 1);
    }
    list_entry_t *le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
ffffffffc02008ea:	9922                	add	s2,s2,s0
    uint32_t n = 1 << (order - 1);
ffffffffc02008ec:	4705                	li	a4,1
ffffffffc02008ee:	347d                	addiw	s0,s0,-1
ffffffffc02008f0:	0087173b          	sllw	a4,a4,s0
    nr_free(order) -= 1;
ffffffffc02008f4:	090e                	slli	s2,s2,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc02008f6:	608c                	ld	a1,0(s1)
ffffffffc02008f8:	6490                	ld	a2,8(s1)
ffffffffc02008fa:	994e                	add	s2,s2,s3
    struct Page *p = page + n;
ffffffffc02008fc:	02071513          	slli	a0,a4,0x20
    nr_free(order) -= 1;
ffffffffc0200900:	01092683          	lw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200904:	9101                	srli	a0,a0,0x20
ffffffffc0200906:	00251793          	slli	a5,a0,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020090a:	e590                	sd	a2,8(a1)
ffffffffc020090c:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc020090e:	e20c                	sd	a1,0(a2)
    nr_free(order) -= 1;
ffffffffc0200910:	36fd                	addiw	a3,a3,-1
    struct Page *p = page + n;
ffffffffc0200912:	078e                	slli	a5,a5,0x3
    nr_free(order) -= 1;
ffffffffc0200914:	00d92823          	sw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200918:	17a1                	addi	a5,a5,-24
ffffffffc020091a:	97a6                	add	a5,a5,s1
    page->property = n;
ffffffffc020091c:	fee4ac23          	sw	a4,-8(s1)
    p->property = n;
ffffffffc0200920:	cb98                	sw	a4,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200922:	00878693          	addi	a3,a5,8
ffffffffc0200926:	4709                	li	a4,2
ffffffffc0200928:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020092c:	00141513          	slli	a0,s0,0x1
ffffffffc0200930:	942a                	add	s0,s0,a0
ffffffffc0200932:	040e                	slli	s0,s0,0x3
ffffffffc0200934:	944e                	add	s0,s0,s3
ffffffffc0200936:	6414                	ld	a3,8(s0)
    SetPageProperty(p);
    list_add(&(free_list(order - 1)), &(page->page_link));
ffffffffc0200938:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc020093a:	e404                	sd	s1,8(s0)
ffffffffc020093c:	99d2                	add	s3,s3,s4
    list_add(&(page->page_link), &(p->page_link));
    nr_free(order - 1) += 2;
ffffffffc020093e:	4818                	lw	a4,16(s0)
    elm->prev = prev;
ffffffffc0200940:	0134b023          	sd	s3,0(s1)
    list_add(&(page->page_link), &(p->page_link));
ffffffffc0200944:	01878613          	addi	a2,a5,24
    prev->next = next->prev = elm;
ffffffffc0200948:	e290                	sd	a2,0(a3)
ffffffffc020094a:	e490                	sd	a2,8(s1)
    elm->prev = prev;
ffffffffc020094c:	ef84                	sd	s1,24(a5)
    elm->next = next;
ffffffffc020094e:	f394                	sd	a3,32(a5)
    nr_free(order - 1) += 2;
ffffffffc0200950:	0027079b          	addiw	a5,a4,2
    return;
}
ffffffffc0200954:	70a2                	ld	ra,40(sp)
    nr_free(order - 1) += 2;
ffffffffc0200956:	c81c                	sw	a5,16(s0)
}
ffffffffc0200958:	7402                	ld	s0,32(sp)
ffffffffc020095a:	64e2                	ld	s1,24(sp)
ffffffffc020095c:	6942                	ld	s2,16(sp)
ffffffffc020095e:	69a2                	ld	s3,8(sp)
ffffffffc0200960:	6a02                	ld	s4,0(sp)
ffffffffc0200962:	6145                	addi	sp,sp,48
ffffffffc0200964:	8082                	ret
        split_page(order + 1);
ffffffffc0200966:	2505                	addiw	a0,a0,1
ffffffffc0200968:	f57ff0ef          	jal	ra,ffffffffc02008be <split_page>
    return listelm->next;
ffffffffc020096c:	6484                	ld	s1,8(s1)
ffffffffc020096e:	bfb5                	j	ffffffffc02008ea <split_page+0x2c>

ffffffffc0200970 <add_page>:
}

// 先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page *base)
{
    if (list_empty(&(free_list(order))))
ffffffffc0200970:	02051793          	slli	a5,a0,0x20
ffffffffc0200974:	9381                	srli	a5,a5,0x20
ffffffffc0200976:	00179693          	slli	a3,a5,0x1
ffffffffc020097a:	96be                	add	a3,a3,a5
ffffffffc020097c:	00369793          	slli	a5,a3,0x3
ffffffffc0200980:	00005697          	auipc	a3,0x5
ffffffffc0200984:	69868693          	addi	a3,a3,1688 # ffffffffc0206018 <free_area>
ffffffffc0200988:	96be                	add	a3,a3,a5
    return list->next == list;
ffffffffc020098a:	669c                	ld	a5,8(a3)
        while ((le = list_next(le)) != &(free_list(order)))
        {
            struct Page *page = le2page(le, page_link);
            if (base < page)
            {
                list_add_before(le, &(base->page_link));
ffffffffc020098c:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order))))
ffffffffc0200990:	02f68c63          	beq	a3,a5,ffffffffc02009c8 <add_page+0x58>
            struct Page *page = le2page(le, page_link);
ffffffffc0200994:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0200998:	00e5ea63          	bltu	a1,a4,ffffffffc02009ac <add_page+0x3c>
    return listelm->next;
ffffffffc020099c:	6798                	ld	a4,8(a5)
                break;
            }
            else if (list_next(le) == &(free_list(order)))
ffffffffc020099e:	00e68d63          	beq	a3,a4,ffffffffc02009b8 <add_page+0x48>
{
ffffffffc02009a2:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02009a4:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02009a8:	fee5fae3          	bgeu	a1,a4,ffffffffc020099c <add_page+0x2c>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02009ac:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02009ae:	e390                	sd	a2,0(a5)
ffffffffc02009b0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02009b2:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc02009b4:	ed98                	sd	a4,24(a1)
}
ffffffffc02009b6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02009b8:	e290                	sd	a2,0(a3)
ffffffffc02009ba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02009bc:	f194                	sd	a3,32(a1)
    return listelm->next;
ffffffffc02009be:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02009c0:	ed9c                	sd	a5,24(a1)
        while ((le = list_next(le)) != &(free_list(order)))
ffffffffc02009c2:	fee690e3          	bne	a3,a4,ffffffffc02009a2 <add_page+0x32>
            {
                list_add(le, &(base->page_link));
            }
        }
    }
}
ffffffffc02009c6:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc02009c8:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc02009cc:	e29c                	sd	a5,0(a3)
ffffffffc02009ce:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc02009d0:	f194                	sd	a3,32(a1)
    elm->prev = prev;
ffffffffc02009d2:	ed94                	sd	a3,24(a1)
}
ffffffffc02009d4:	8082                	ret

ffffffffc02009d6 <buddy_system_nr_free_pages>:

static size_t
buddy_system_nr_free_pages(void)
{ // 计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02009d6:	00005697          	auipc	a3,0x5
ffffffffc02009da:	65268693          	addi	a3,a3,1618 # ffffffffc0206028 <free_area+0x10>
ffffffffc02009de:	4701                	li	a4,0
    size_t num = 0;
ffffffffc02009e0:	4501                	li	a0,0
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02009e2:	462d                	li	a2,11
    {
        num += nr_free(i) << i;
ffffffffc02009e4:	429c                	lw	a5,0(a3)
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02009e6:	06e1                	addi	a3,a3,24
        num += nr_free(i) << i;
ffffffffc02009e8:	00e797bb          	sllw	a5,a5,a4
ffffffffc02009ec:	1782                	slli	a5,a5,0x20
ffffffffc02009ee:	9381                	srli	a5,a5,0x20
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02009f0:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc02009f2:	953e                	add	a0,a0,a5
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc02009f4:	fec718e3          	bne	a4,a2,ffffffffc02009e4 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc02009f8:	8082                	ret

ffffffffc02009fa <buddy_system_free_pages>:
{
ffffffffc02009fa:	7139                	addi	sp,sp,-64
ffffffffc02009fc:	fc06                	sd	ra,56(sp)
ffffffffc02009fe:	f822                	sd	s0,48(sp)
ffffffffc0200a00:	f426                	sd	s1,40(sp)
ffffffffc0200a02:	f04a                	sd	s2,32(sp)
ffffffffc0200a04:	ec4e                	sd	s3,24(sp)
ffffffffc0200a06:	e852                	sd	s4,16(sp)
ffffffffc0200a08:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200a0a:	18058c63          	beqz	a1,ffffffffc0200ba2 <buddy_system_free_pages+0x1a8>
    assert(IS_POWER_OF_2(n));
ffffffffc0200a0e:	fff58793          	addi	a5,a1,-1
ffffffffc0200a12:	8fed                	and	a5,a5,a1
ffffffffc0200a14:	16079763          	bnez	a5,ffffffffc0200b82 <buddy_system_free_pages+0x188>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200a18:	3ff00793          	li	a5,1023
ffffffffc0200a1c:	1ab7e363          	bltu	a5,a1,ffffffffc0200bc2 <buddy_system_free_pages+0x1c8>
    for (; p != base + n; p++)
ffffffffc0200a20:	00259693          	slli	a3,a1,0x2
ffffffffc0200a24:	96ae                	add	a3,a3,a1
ffffffffc0200a26:	068e                	slli	a3,a3,0x3
ffffffffc0200a28:	892a                	mv	s2,a0
ffffffffc0200a2a:	96aa                	add	a3,a3,a0
ffffffffc0200a2c:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a2e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面没有被保留且没有属性标志
ffffffffc0200a30:	8b05                	andi	a4,a4,1
ffffffffc0200a32:	12071863          	bnez	a4,ffffffffc0200b62 <buddy_system_free_pages+0x168>
ffffffffc0200a36:	6798                	ld	a4,8(a5)
ffffffffc0200a38:	8b09                	andi	a4,a4,2
ffffffffc0200a3a:	12071463          	bnez	a4,ffffffffc0200b62 <buddy_system_free_pages+0x168>
        p->flags = 0;
ffffffffc0200a3e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a42:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200a46:	02878793          	addi	a5,a5,40
ffffffffc0200a4a:	fed792e3          	bne	a5,a3,ffffffffc0200a2e <buddy_system_free_pages+0x34>
    base->property = n;
ffffffffc0200a4e:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a52:	4789                	li	a5,2
ffffffffc0200a54:	00890713          	addi	a4,s2,8
ffffffffc0200a58:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1)
ffffffffc0200a5c:	4785                	li	a5,1
ffffffffc0200a5e:	0ef58c63          	beq	a1,a5,ffffffffc0200b56 <buddy_system_free_pages+0x15c>
    uint32_t order = 0;
ffffffffc0200a62:	4481                	li	s1,0
        temp >>= 1;
ffffffffc0200a64:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc0200a66:	2485                	addiw	s1,s1,1
    while (temp != 1)
ffffffffc0200a68:	fef59ee3          	bne	a1,a5,ffffffffc0200a64 <buddy_system_free_pages+0x6a>
    add_page(order, base);
ffffffffc0200a6c:	85ca                	mv	a1,s2
ffffffffc0200a6e:	8526                	mv	a0,s1
ffffffffc0200a70:	f01ff0ef          	jal	ra,ffffffffc0200970 <add_page>
    if (order == MAX_ORDER - 1)
ffffffffc0200a74:	47a9                	li	a5,10
ffffffffc0200a76:	06f48763          	beq	s1,a5,ffffffffc0200ae4 <buddy_system_free_pages+0xea>
ffffffffc0200a7a:	00005a97          	auipc	s5,0x5
ffffffffc0200a7e:	59ea8a93          	addi	s5,s5,1438 # ffffffffc0206018 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a82:	59f5                	li	s3,-3
ffffffffc0200a84:	4a29                	li	s4,10
    if (le != &(free_list(order)))
ffffffffc0200a86:	02049793          	slli	a5,s1,0x20
ffffffffc0200a8a:	9381                	srli	a5,a5,0x20
ffffffffc0200a8c:	00179413          	slli	s0,a5,0x1
ffffffffc0200a90:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc0200a92:	01893703          	ld	a4,24(s2)
ffffffffc0200a96:	040e                	slli	s0,s0,0x3
ffffffffc0200a98:	9456                	add	s0,s0,s5
                add_page(order + 1, base);
ffffffffc0200a9a:	2485                	addiw	s1,s1,1
    if (le != &(free_list(order)))
ffffffffc0200a9c:	02870063          	beq	a4,s0,ffffffffc0200abc <buddy_system_free_pages+0xc2>
        if (p + p->property == base)
ffffffffc0200aa0:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200aa4:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc0200aa8:	02061693          	slli	a3,a2,0x20
ffffffffc0200aac:	9281                	srli	a3,a3,0x20
ffffffffc0200aae:	00269793          	slli	a5,a3,0x2
ffffffffc0200ab2:	97b6                	add	a5,a5,a3
ffffffffc0200ab4:	078e                	slli	a5,a5,0x3
ffffffffc0200ab6:	97ae                	add	a5,a5,a1
ffffffffc0200ab8:	06f90963          	beq	s2,a5,ffffffffc0200b2a <buddy_system_free_pages+0x130>
    return listelm->next;
ffffffffc0200abc:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order)))
ffffffffc0200ac0:	02e40063          	beq	s0,a4,ffffffffc0200ae0 <buddy_system_free_pages+0xe6>
        if (base + base->property == p)
ffffffffc0200ac4:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc0200ac8:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p)
ffffffffc0200acc:	02059613          	slli	a2,a1,0x20
ffffffffc0200ad0:	9201                	srli	a2,a2,0x20
ffffffffc0200ad2:	00261793          	slli	a5,a2,0x2
ffffffffc0200ad6:	97b2                	add	a5,a5,a2
ffffffffc0200ad8:	078e                	slli	a5,a5,0x3
ffffffffc0200ada:	97ca                	add	a5,a5,s2
ffffffffc0200adc:	00f68d63          	beq	a3,a5,ffffffffc0200af6 <buddy_system_free_pages+0xfc>
    if (order == MAX_ORDER - 1)
ffffffffc0200ae0:	fb4493e3          	bne	s1,s4,ffffffffc0200a86 <buddy_system_free_pages+0x8c>
}
ffffffffc0200ae4:	70e2                	ld	ra,56(sp)
ffffffffc0200ae6:	7442                	ld	s0,48(sp)
ffffffffc0200ae8:	74a2                	ld	s1,40(sp)
ffffffffc0200aea:	7902                	ld	s2,32(sp)
ffffffffc0200aec:	69e2                	ld	s3,24(sp)
ffffffffc0200aee:	6a42                	ld	s4,16(sp)
ffffffffc0200af0:	6aa2                	ld	s5,8(sp)
ffffffffc0200af2:	6121                	addi	sp,sp,64
ffffffffc0200af4:	8082                	ret
            base->property += p->property;
ffffffffc0200af6:	ff872783          	lw	a5,-8(a4)
ffffffffc0200afa:	9dbd                	addw	a1,a1,a5
ffffffffc0200afc:	00b92823          	sw	a1,16(s2)
ffffffffc0200b00:	ff070793          	addi	a5,a4,-16
ffffffffc0200b04:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b08:	671c                	ld	a5,8(a4)
ffffffffc0200b0a:	6314                	ld	a3,0(a4)
                add_page(order + 1, base);
ffffffffc0200b0c:	85ca                	mv	a1,s2
ffffffffc0200b0e:	8526                	mv	a0,s1
    prev->next = next;
ffffffffc0200b10:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b12:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b14:	01893703          	ld	a4,24(s2)
ffffffffc0200b18:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200b1c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b1e:	e398                	sd	a4,0(a5)
ffffffffc0200b20:	e51ff0ef          	jal	ra,ffffffffc0200970 <add_page>
    if (order == MAX_ORDER - 1)
ffffffffc0200b24:	f74491e3          	bne	s1,s4,ffffffffc0200a86 <buddy_system_free_pages+0x8c>
ffffffffc0200b28:	bf75                	j	ffffffffc0200ae4 <buddy_system_free_pages+0xea>
            p->property += base->property;
ffffffffc0200b2a:	01092783          	lw	a5,16(s2)
ffffffffc0200b2e:	9e3d                	addw	a2,a2,a5
ffffffffc0200b30:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200b34:	00890793          	addi	a5,s2,8
ffffffffc0200b38:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b3c:	02093783          	ld	a5,32(s2)
                add_page(order + 1, base);
ffffffffc0200b40:	8526                	mv	a0,s1
            base = p;
ffffffffc0200b42:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200b44:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200b46:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b48:	6314                	ld	a3,0(a4)
ffffffffc0200b4a:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200b4c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b4e:	e394                	sd	a3,0(a5)
                add_page(order + 1, base);
ffffffffc0200b50:	e21ff0ef          	jal	ra,ffffffffc0200970 <add_page>
ffffffffc0200b54:	b7a5                	j	ffffffffc0200abc <buddy_system_free_pages+0xc2>
    add_page(order, base);
ffffffffc0200b56:	85ca                	mv	a1,s2
ffffffffc0200b58:	4501                	li	a0,0
ffffffffc0200b5a:	e17ff0ef          	jal	ra,ffffffffc0200970 <add_page>
    uint32_t order = 0;
ffffffffc0200b5e:	4481                	li	s1,0
ffffffffc0200b60:	bf29                	j	ffffffffc0200a7a <buddy_system_free_pages+0x80>
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面没有被保留且没有属性标志
ffffffffc0200b62:	00001697          	auipc	a3,0x1
ffffffffc0200b66:	26668693          	addi	a3,a3,614 # ffffffffc0201dc8 <commands+0x608>
ffffffffc0200b6a:	00001617          	auipc	a2,0x1
ffffffffc0200b6e:	1ee60613          	addi	a2,a2,494 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200b72:	0bf00593          	li	a1,191
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	1fa50513          	addi	a0,a0,506 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200b7e:	82fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200b82:	00001697          	auipc	a3,0x1
ffffffffc0200b86:	20e68693          	addi	a3,a3,526 # ffffffffc0201d90 <commands+0x5d0>
ffffffffc0200b8a:	00001617          	auipc	a2,0x1
ffffffffc0200b8e:	1ce60613          	addi	a2,a2,462 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200b92:	0ba00593          	li	a1,186
ffffffffc0200b96:	00001517          	auipc	a0,0x1
ffffffffc0200b9a:	1da50513          	addi	a0,a0,474 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200b9e:	80fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200ba2:	00001697          	auipc	a3,0x1
ffffffffc0200ba6:	1ae68693          	addi	a3,a3,430 # ffffffffc0201d50 <commands+0x590>
ffffffffc0200baa:	00001617          	auipc	a2,0x1
ffffffffc0200bae:	1ae60613          	addi	a2,a2,430 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200bb2:	0b900593          	li	a1,185
ffffffffc0200bb6:	00001517          	auipc	a0,0x1
ffffffffc0200bba:	1ba50513          	addi	a0,a0,442 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200bbe:	feeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200bc2:	00001697          	auipc	a3,0x1
ffffffffc0200bc6:	1e668693          	addi	a3,a3,486 # ffffffffc0201da8 <commands+0x5e8>
ffffffffc0200bca:	00001617          	auipc	a2,0x1
ffffffffc0200bce:	18e60613          	addi	a2,a2,398 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200bd2:	0bb00593          	li	a1,187
ffffffffc0200bd6:	00001517          	auipc	a0,0x1
ffffffffc0200bda:	19a50513          	addi	a0,a0,410 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200bde:	fceff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200be2 <buddy_system_alloc_pages.part.0>:
    while (n < (1 << order))
ffffffffc0200be2:	3ff00713          	li	a4,1023
ffffffffc0200be6:	47a9                	li	a5,10
ffffffffc0200be8:	4685                	li	a3,1
ffffffffc0200bea:	0aa76963          	bltu	a4,a0,ffffffffc0200c9c <buddy_system_alloc_pages.part.0+0xba>
        order -= 1;
ffffffffc0200bee:	0007859b          	sext.w	a1,a5
ffffffffc0200bf2:	37fd                	addiw	a5,a5,-1
    while (n < (1 << order))
ffffffffc0200bf4:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200bf8:	fee56be3          	bltu	a0,a4,ffffffffc0200bee <buddy_system_alloc_pages.part.0+0xc>
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200bfc:	47a9                	li	a5,10
ffffffffc0200bfe:	0005869b          	sext.w	a3,a1
ffffffffc0200c02:	08b7cd63          	blt	a5,a1,ffffffffc0200c9c <buddy_system_alloc_pages.part.0+0xba>
ffffffffc0200c06:	4629                	li	a2,10
ffffffffc0200c08:	9e0d                	subw	a2,a2,a1
ffffffffc0200c0a:	1602                	slli	a2,a2,0x20
ffffffffc0200c0c:	9201                	srli	a2,a2,0x20
ffffffffc0200c0e:	00d60733          	add	a4,a2,a3
ffffffffc0200c12:	00171613          	slli	a2,a4,0x1
ffffffffc0200c16:	00169793          	slli	a5,a3,0x1
buddy_system_alloc_pages(size_t n)
ffffffffc0200c1a:	1101                	addi	sp,sp,-32
ffffffffc0200c1c:	963a                	add	a2,a2,a4
ffffffffc0200c1e:	97b6                	add	a5,a5,a3
ffffffffc0200c20:	00005717          	auipc	a4,0x5
ffffffffc0200c24:	41070713          	addi	a4,a4,1040 # ffffffffc0206030 <free_area+0x18>
ffffffffc0200c28:	e426                	sd	s1,8(sp)
ffffffffc0200c2a:	078e                	slli	a5,a5,0x3
ffffffffc0200c2c:	00005497          	auipc	s1,0x5
ffffffffc0200c30:	3ec48493          	addi	s1,s1,1004 # ffffffffc0206018 <free_area>
ffffffffc0200c34:	060e                	slli	a2,a2,0x3
ffffffffc0200c36:	963a                	add	a2,a2,a4
ffffffffc0200c38:	ec06                	sd	ra,24(sp)
ffffffffc0200c3a:	e822                	sd	s0,16(sp)
ffffffffc0200c3c:	97a6                	add	a5,a5,s1
    uint32_t flag = 0;
ffffffffc0200c3e:	4701                	li	a4,0
        flag += nr_free(i);
ffffffffc0200c40:	4b94                	lw	a3,16(a5)
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200c42:	07e1                	addi	a5,a5,24
        flag += nr_free(i);
ffffffffc0200c44:	9f35                	addw	a4,a4,a3
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200c46:	fec79de3          	bne	a5,a2,ffffffffc0200c40 <buddy_system_alloc_pages.part.0+0x5e>
    if (flag == 0)
ffffffffc0200c4a:	c339                	beqz	a4,ffffffffc0200c90 <buddy_system_alloc_pages.part.0+0xae>
    if (list_empty(&(free_list(order))))
ffffffffc0200c4c:	02059713          	slli	a4,a1,0x20
ffffffffc0200c50:	9301                	srli	a4,a4,0x20
ffffffffc0200c52:	00171793          	slli	a5,a4,0x1
ffffffffc0200c56:	97ba                	add	a5,a5,a4
ffffffffc0200c58:	078e                	slli	a5,a5,0x3
ffffffffc0200c5a:	94be                	add	s1,s1,a5
    return list->next == list;
ffffffffc0200c5c:	6480                	ld	s0,8(s1)
ffffffffc0200c5e:	02848263          	beq	s1,s0,ffffffffc0200c82 <buddy_system_alloc_pages.part.0+0xa0>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c62:	6018                	ld	a4,0(s0)
ffffffffc0200c64:	641c                	ld	a5,8(s0)
    page = le2page(le, page_link);
ffffffffc0200c66:	fe840513          	addi	a0,s0,-24
    prev->next = next;
ffffffffc0200c6a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c6c:	e398                	sd	a4,0(a5)
ffffffffc0200c6e:	57f5                	li	a5,-3
ffffffffc0200c70:	ff040713          	addi	a4,s0,-16
ffffffffc0200c74:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200c78:	60e2                	ld	ra,24(sp)
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	64a2                	ld	s1,8(sp)
ffffffffc0200c7e:	6105                	addi	sp,sp,32
ffffffffc0200c80:	8082                	ret
        split_page(order + 1);
ffffffffc0200c82:	0015851b          	addiw	a0,a1,1
ffffffffc0200c86:	c39ff0ef          	jal	ra,ffffffffc02008be <split_page>
    return list->next == list;
ffffffffc0200c8a:	6400                	ld	s0,8(s0)
    if (list_empty(&(free_list(order))))
ffffffffc0200c8c:	fc849be3          	bne	s1,s0,ffffffffc0200c62 <buddy_system_alloc_pages.part.0+0x80>
}
ffffffffc0200c90:	60e2                	ld	ra,24(sp)
ffffffffc0200c92:	6442                	ld	s0,16(sp)
ffffffffc0200c94:	64a2                	ld	s1,8(sp)
        return NULL;
ffffffffc0200c96:	4501                	li	a0,0
}
ffffffffc0200c98:	6105                	addi	sp,sp,32
ffffffffc0200c9a:	8082                	ret
        return NULL;
ffffffffc0200c9c:	4501                	li	a0,0
}
ffffffffc0200c9e:	8082                	ret

ffffffffc0200ca0 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0200ca0:	c901                	beqz	a0,ffffffffc0200cb0 <buddy_system_alloc_pages+0x10>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200ca2:	40000713          	li	a4,1024
ffffffffc0200ca6:	00a76363          	bltu	a4,a0,ffffffffc0200cac <buddy_system_alloc_pages+0xc>
ffffffffc0200caa:	bf25                	j	ffffffffc0200be2 <buddy_system_alloc_pages.part.0>
}
ffffffffc0200cac:	4501                	li	a0,0
ffffffffc0200cae:	8082                	ret
{
ffffffffc0200cb0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200cb2:	00001697          	auipc	a3,0x1
ffffffffc0200cb6:	09e68693          	addi	a3,a3,158 # ffffffffc0201d50 <commands+0x590>
ffffffffc0200cba:	00001617          	auipc	a2,0x1
ffffffffc0200cbe:	09e60613          	addi	a2,a2,158 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200cc2:	05100593          	li	a1,81
ffffffffc0200cc6:	00001517          	auipc	a0,0x1
ffffffffc0200cca:	0aa50513          	addi	a0,a0,170 # ffffffffc0201d70 <commands+0x5b0>
{
ffffffffc0200cce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cd4 <buddy_system_check>:
// buddy_system_check(){
//     cprintf("buddy system tests passed.\n");
// }

static void buddy_system_check(void)
{
ffffffffc0200cd4:	1141                	addi	sp,sp,-16
ffffffffc0200cd6:	4505                	li	a0,1
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	e022                	sd	s0,0(sp)
ffffffffc0200cdc:	f07ff0ef          	jal	ra,ffffffffc0200be2 <buddy_system_alloc_pages.part.0>
    struct Page *p0, *p1, *p2, *p3;

    // 测试 1 页的分配和释放
    p0 = buddy_system_alloc_pages(1);
    assert(p0 != NULL);
ffffffffc0200ce0:	c125                	beqz	a0,ffffffffc0200d40 <buddy_system_check+0x6c>
    buddy_system_free_pages(p0, 1);
ffffffffc0200ce2:	4585                	li	a1,1
ffffffffc0200ce4:	d17ff0ef          	jal	ra,ffffffffc02009fa <buddy_system_free_pages>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200ce8:	4509                	li	a0,2
ffffffffc0200cea:	ef9ff0ef          	jal	ra,ffffffffc0200be2 <buddy_system_alloc_pages.part.0>
ffffffffc0200cee:	842a                	mv	s0,a0
ffffffffc0200cf0:	4511                	li	a0,4
ffffffffc0200cf2:	ef1ff0ef          	jal	ra,ffffffffc0200be2 <buddy_system_alloc_pages.part.0>

    // 测试 2 页和 4 页的分配
    p1 = buddy_system_alloc_pages(2);
    p2 = buddy_system_alloc_pages(4);
    assert(p1 != NULL && p2 != NULL);
ffffffffc0200cf6:	c40d                	beqz	s0,ffffffffc0200d20 <buddy_system_check+0x4c>
ffffffffc0200cf8:	c505                	beqz	a0,ffffffffc0200d20 <buddy_system_check+0x4c>

    // 测试释放并合并
    buddy_system_free_pages(p2, 4);
ffffffffc0200cfa:	4591                	li	a1,4
ffffffffc0200cfc:	cffff0ef          	jal	ra,ffffffffc02009fa <buddy_system_free_pages>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200d00:	4521                	li	a0,8
ffffffffc0200d02:	ee1ff0ef          	jal	ra,ffffffffc0200be2 <buddy_system_alloc_pages.part.0>

    // 测试 8 页分配
    p3 = buddy_system_alloc_pages(8);
    assert(p3 != NULL);
ffffffffc0200d06:	cd29                	beqz	a0,ffffffffc0200d60 <buddy_system_check+0x8c>
    buddy_system_free_pages(p3, 8);
ffffffffc0200d08:	45a1                	li	a1,8
ffffffffc0200d0a:	cf1ff0ef          	jal	ra,ffffffffc02009fa <buddy_system_free_pages>

    cprintf("buddy system tests passed.\n");
}
ffffffffc0200d0e:	6402                	ld	s0,0(sp)
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
    cprintf("buddy system tests passed.\n");
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	11e50513          	addi	a0,a0,286 # ffffffffc0201e30 <commands+0x670>
}
ffffffffc0200d1a:	0141                	addi	sp,sp,16
    cprintf("buddy system tests passed.\n");
ffffffffc0200d1c:	b96ff06f          	j	ffffffffc02000b2 <cprintf>
    assert(p1 != NULL && p2 != NULL);
ffffffffc0200d20:	00001697          	auipc	a3,0x1
ffffffffc0200d24:	0e068693          	addi	a3,a3,224 # ffffffffc0201e00 <commands+0x640>
ffffffffc0200d28:	00001617          	auipc	a2,0x1
ffffffffc0200d2c:	03060613          	addi	a2,a2,48 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200d30:	12600593          	li	a1,294
ffffffffc0200d34:	00001517          	auipc	a0,0x1
ffffffffc0200d38:	03c50513          	addi	a0,a0,60 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200d3c:	e70ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200d40:	00001697          	auipc	a3,0x1
ffffffffc0200d44:	0b068693          	addi	a3,a3,176 # ffffffffc0201df0 <commands+0x630>
ffffffffc0200d48:	00001617          	auipc	a2,0x1
ffffffffc0200d4c:	01060613          	addi	a2,a2,16 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200d50:	12000593          	li	a1,288
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	01c50513          	addi	a0,a0,28 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200d5c:	e50ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 != NULL);
ffffffffc0200d60:	00001697          	auipc	a3,0x1
ffffffffc0200d64:	0c068693          	addi	a3,a3,192 # ffffffffc0201e20 <commands+0x660>
ffffffffc0200d68:	00001617          	auipc	a2,0x1
ffffffffc0200d6c:	ff060613          	addi	a2,a2,-16 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200d70:	12d00593          	li	a1,301
ffffffffc0200d74:	00001517          	auipc	a0,0x1
ffffffffc0200d78:	ffc50513          	addi	a0,a0,-4 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200d7c:	e30ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d80 <buddy_system_init_memmap>:
{
ffffffffc0200d80:	1141                	addi	sp,sp,-16
ffffffffc0200d82:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d84:	c1f1                	beqz	a1,ffffffffc0200e48 <buddy_system_init_memmap+0xc8>
    for (; p != base + n; p++)
ffffffffc0200d86:	00259693          	slli	a3,a1,0x2
ffffffffc0200d8a:	96ae                	add	a3,a3,a1
ffffffffc0200d8c:	068e                	slli	a3,a3,0x3
ffffffffc0200d8e:	96aa                	add	a3,a3,a0
ffffffffc0200d90:	87aa                	mv	a5,a0
ffffffffc0200d92:	00d50f63          	beq	a0,a3,ffffffffc0200db0 <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d96:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d98:	8b05                	andi	a4,a4,1
ffffffffc0200d9a:	c759                	beqz	a4,ffffffffc0200e28 <buddy_system_init_memmap+0xa8>
        p->flags = p->property = 0;
ffffffffc0200d9c:	0007a823          	sw	zero,16(a5)
ffffffffc0200da0:	0007b423          	sd	zero,8(a5)
ffffffffc0200da4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200da8:	02878793          	addi	a5,a5,40
ffffffffc0200dac:	fed795e3          	bne	a5,a3,ffffffffc0200d96 <buddy_system_init_memmap+0x16>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200db0:	4729                	li	a4,10
    uint32_t order_size = 1 << order;
ffffffffc0200db2:	40000693          	li	a3,1024
ffffffffc0200db6:	00005e17          	auipc	t3,0x5
ffffffffc0200dba:	262e0e13          	addi	t3,t3,610 # ffffffffc0206018 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dbe:	4309                	li	t1,2
        p->property = order_size;
ffffffffc0200dc0:	c914                	sw	a3,16(a0)
ffffffffc0200dc2:	00850793          	addi	a5,a0,8
ffffffffc0200dc6:	4067b02f          	amoor.d	zero,t1,(a5)
        nr_free(order) += 1;
ffffffffc0200dca:	02071613          	slli	a2,a4,0x20
ffffffffc0200dce:	9201                	srli	a2,a2,0x20
ffffffffc0200dd0:	00161793          	slli	a5,a2,0x1
ffffffffc0200dd4:	97b2                	add	a5,a5,a2
ffffffffc0200dd6:	078e                	slli	a5,a5,0x3
ffffffffc0200dd8:	97f2                	add	a5,a5,t3
ffffffffc0200dda:	0107a803          	lw	a6,16(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200dde:	0007b883          	ld	a7,0(a5)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200de2:	01850613          	addi	a2,a0,24
        nr_free(order) += 1;
ffffffffc0200de6:	2805                	addiw	a6,a6,1
ffffffffc0200de8:	0107a823          	sw	a6,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200dec:	e390                	sd	a2,0(a5)
ffffffffc0200dee:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0200df2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200df4:	01153c23          	sd	a7,24(a0)
        curr_size -= order_size;
ffffffffc0200df8:	02069793          	slli	a5,a3,0x20
ffffffffc0200dfc:	9381                	srli	a5,a5,0x20
ffffffffc0200dfe:	8d95                	sub	a1,a1,a3
        while (order > 0 && curr_size < order_size)
ffffffffc0200e00:	cb19                	beqz	a4,ffffffffc0200e16 <buddy_system_init_memmap+0x96>
ffffffffc0200e02:	00f5fa63          	bgeu	a1,a5,ffffffffc0200e16 <buddy_system_init_memmap+0x96>
            order_size >>= 1;
ffffffffc0200e06:	0016d79b          	srliw	a5,a3,0x1
ffffffffc0200e0a:	0007869b          	sext.w	a3,a5
            order -= 1;
ffffffffc0200e0e:	377d                	addiw	a4,a4,-1
        while (order > 0 && curr_size < order_size)
ffffffffc0200e10:	1782                	slli	a5,a5,0x20
ffffffffc0200e12:	9381                	srli	a5,a5,0x20
ffffffffc0200e14:	f77d                	bnez	a4,ffffffffc0200e02 <buddy_system_init_memmap+0x82>
        p += order_size;
ffffffffc0200e16:	00279613          	slli	a2,a5,0x2
ffffffffc0200e1a:	97b2                	add	a5,a5,a2
ffffffffc0200e1c:	078e                	slli	a5,a5,0x3
ffffffffc0200e1e:	953e                	add	a0,a0,a5
    while (curr_size != 0)
ffffffffc0200e20:	f1c5                	bnez	a1,ffffffffc0200dc0 <buddy_system_init_memmap+0x40>
}
ffffffffc0200e22:	60a2                	ld	ra,8(sp)
ffffffffc0200e24:	0141                	addi	sp,sp,16
ffffffffc0200e26:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	02868693          	addi	a3,a3,40 # ffffffffc0201e50 <commands+0x690>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	f2860613          	addi	a2,a2,-216 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200e38:	02000593          	li	a1,32
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	f3450513          	addi	a0,a0,-204 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200e44:	d68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	f0868693          	addi	a3,a3,-248 # ffffffffc0201d50 <commands+0x590>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	f0860613          	addi	a2,a2,-248 # ffffffffc0201d58 <commands+0x598>
ffffffffc0200e58:	45f1                	li	a1,28
ffffffffc0200e5a:	00001517          	auipc	a0,0x1
ffffffffc0200e5e:	f1650513          	addi	a0,a0,-234 # ffffffffc0201d70 <commands+0x5b0>
ffffffffc0200e62:	d4aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e66 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200e66:	00001797          	auipc	a5,0x1
ffffffffc0200e6a:	01a78793          	addi	a5,a5,26 # ffffffffc0201e80 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e6e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e70:	1101                	addi	sp,sp,-32
ffffffffc0200e72:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e74:	00001517          	auipc	a0,0x1
ffffffffc0200e78:	04450513          	addi	a0,a0,68 # ffffffffc0201eb8 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200e7c:	00005497          	auipc	s1,0x5
ffffffffc0200e80:	6cc48493          	addi	s1,s1,1740 # ffffffffc0206548 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e84:	ec06                	sd	ra,24(sp)
ffffffffc0200e86:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200e88:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e8a:	a28ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200e8e:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e90:	00005417          	auipc	s0,0x5
ffffffffc0200e94:	6d040413          	addi	s0,s0,1744 # ffffffffc0206560 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200e98:	679c                	ld	a5,8(a5)
ffffffffc0200e9a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e9c:	57f5                	li	a5,-3
ffffffffc0200e9e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ea0:	00001517          	auipc	a0,0x1
ffffffffc0200ea4:	03050513          	addi	a0,a0,48 # ffffffffc0201ed0 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ea8:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200eaa:	a08ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200eae:	46c5                	li	a3,17
ffffffffc0200eb0:	06ee                	slli	a3,a3,0x1b
ffffffffc0200eb2:	40100613          	li	a2,1025
ffffffffc0200eb6:	16fd                	addi	a3,a3,-1
ffffffffc0200eb8:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ebc:	0656                	slli	a2,a2,0x15
ffffffffc0200ebe:	00001517          	auipc	a0,0x1
ffffffffc0200ec2:	02a50513          	addi	a0,a0,42 # ffffffffc0201ee8 <buddy_system_pmm_manager+0x68>
ffffffffc0200ec6:	9ecff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eca:	777d                	lui	a4,0xfffff
ffffffffc0200ecc:	00006797          	auipc	a5,0x6
ffffffffc0200ed0:	6a378793          	addi	a5,a5,1699 # ffffffffc020756f <end+0xfff>
ffffffffc0200ed4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ed6:	00005517          	auipc	a0,0x5
ffffffffc0200eda:	66250513          	addi	a0,a0,1634 # ffffffffc0206538 <npage>
ffffffffc0200ede:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ee2:	00005597          	auipc	a1,0x5
ffffffffc0200ee6:	65e58593          	addi	a1,a1,1630 # ffffffffc0206540 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200eea:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eec:	e19c                	sd	a5,0(a1)
ffffffffc0200eee:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200ef0:	4701                	li	a4,0
ffffffffc0200ef2:	4885                	li	a7,1
ffffffffc0200ef4:	fff80837          	lui	a6,0xfff80
ffffffffc0200ef8:	a011                	j	ffffffffc0200efc <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200efa:	619c                	ld	a5,0(a1)
ffffffffc0200efc:	97b6                	add	a5,a5,a3
ffffffffc0200efe:	07a1                	addi	a5,a5,8
ffffffffc0200f00:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f04:	611c                	ld	a5,0(a0)
ffffffffc0200f06:	0705                	addi	a4,a4,1
ffffffffc0200f08:	02868693          	addi	a3,a3,40
ffffffffc0200f0c:	01078633          	add	a2,a5,a6
ffffffffc0200f10:	fec765e3          	bltu	a4,a2,ffffffffc0200efa <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f14:	6190                	ld	a2,0(a1)
ffffffffc0200f16:	00279713          	slli	a4,a5,0x2
ffffffffc0200f1a:	973e                	add	a4,a4,a5
ffffffffc0200f1c:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f20:	070e                	slli	a4,a4,0x3
ffffffffc0200f22:	96b2                	add	a3,a3,a2
ffffffffc0200f24:	96ba                	add	a3,a3,a4
ffffffffc0200f26:	c0200737          	lui	a4,0xc0200
ffffffffc0200f2a:	08e6ef63          	bltu	a3,a4,ffffffffc0200fc8 <pmm_init+0x162>
ffffffffc0200f2e:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f30:	45c5                	li	a1,17
ffffffffc0200f32:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f34:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f36:	04b6e863          	bltu	a3,a1,ffffffffc0200f86 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f3a:	609c                	ld	a5,0(s1)
ffffffffc0200f3c:	7b9c                	ld	a5,48(a5)
ffffffffc0200f3e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	04050513          	addi	a0,a0,64 # ffffffffc0201f80 <buddy_system_pmm_manager+0x100>
ffffffffc0200f48:	96aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f4c:	00004597          	auipc	a1,0x4
ffffffffc0200f50:	0b458593          	addi	a1,a1,180 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f54:	00005797          	auipc	a5,0x5
ffffffffc0200f58:	60b7b223          	sd	a1,1540(a5) # ffffffffc0206558 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f5c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f60:	08f5e063          	bltu	a1,a5,ffffffffc0200fe0 <pmm_init+0x17a>
ffffffffc0200f64:	6010                	ld	a2,0(s0)
}
ffffffffc0200f66:	6442                	ld	s0,16(sp)
ffffffffc0200f68:	60e2                	ld	ra,24(sp)
ffffffffc0200f6a:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f6c:	40c58633          	sub	a2,a1,a2
ffffffffc0200f70:	00005797          	auipc	a5,0x5
ffffffffc0200f74:	5ec7b023          	sd	a2,1504(a5) # ffffffffc0206550 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f78:	00001517          	auipc	a0,0x1
ffffffffc0200f7c:	02850513          	addi	a0,a0,40 # ffffffffc0201fa0 <buddy_system_pmm_manager+0x120>
}
ffffffffc0200f80:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f82:	930ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f86:	6705                	lui	a4,0x1
ffffffffc0200f88:	177d                	addi	a4,a4,-1
ffffffffc0200f8a:	96ba                	add	a3,a3,a4
ffffffffc0200f8c:	777d                	lui	a4,0xfffff
ffffffffc0200f8e:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f90:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200f94:	00f57e63          	bgeu	a0,a5,ffffffffc0200fb0 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f98:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f9a:	982a                	add	a6,a6,a0
ffffffffc0200f9c:	00281513          	slli	a0,a6,0x2
ffffffffc0200fa0:	9542                	add	a0,a0,a6
ffffffffc0200fa2:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fa4:	8d95                	sub	a1,a1,a3
ffffffffc0200fa6:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fa8:	81b1                	srli	a1,a1,0xc
ffffffffc0200faa:	9532                	add	a0,a0,a2
ffffffffc0200fac:	9782                	jalr	a5
}
ffffffffc0200fae:	b771                	j	ffffffffc0200f3a <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200fb0:	00001617          	auipc	a2,0x1
ffffffffc0200fb4:	fa060613          	addi	a2,a2,-96 # ffffffffc0201f50 <buddy_system_pmm_manager+0xd0>
ffffffffc0200fb8:	06b00593          	li	a1,107
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	fb450513          	addi	a0,a0,-76 # ffffffffc0201f70 <buddy_system_pmm_manager+0xf0>
ffffffffc0200fc4:	be8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fc8:	00001617          	auipc	a2,0x1
ffffffffc0200fcc:	f5060613          	addi	a2,a2,-176 # ffffffffc0201f18 <buddy_system_pmm_manager+0x98>
ffffffffc0200fd0:	06f00593          	li	a1,111
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0201f40 <buddy_system_pmm_manager+0xc0>
ffffffffc0200fdc:	bd0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fe0:	86ae                	mv	a3,a1
ffffffffc0200fe2:	00001617          	auipc	a2,0x1
ffffffffc0200fe6:	f3660613          	addi	a2,a2,-202 # ffffffffc0201f18 <buddy_system_pmm_manager+0x98>
ffffffffc0200fea:	08a00593          	li	a1,138
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	f5250513          	addi	a0,a0,-174 # ffffffffc0201f40 <buddy_system_pmm_manager+0xc0>
ffffffffc0200ff6:	bb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ffa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200ffa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ffe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201000:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201004:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201006:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020100a:	f022                	sd	s0,32(sp)
ffffffffc020100c:	ec26                	sd	s1,24(sp)
ffffffffc020100e:	e84a                	sd	s2,16(sp)
ffffffffc0201010:	f406                	sd	ra,40(sp)
ffffffffc0201012:	e44e                	sd	s3,8(sp)
ffffffffc0201014:	84aa                	mv	s1,a0
ffffffffc0201016:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201018:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020101c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020101e:	03067e63          	bgeu	a2,a6,ffffffffc020105a <printnum+0x60>
ffffffffc0201022:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201024:	00805763          	blez	s0,ffffffffc0201032 <printnum+0x38>
ffffffffc0201028:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020102a:	85ca                	mv	a1,s2
ffffffffc020102c:	854e                	mv	a0,s3
ffffffffc020102e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201030:	fc65                	bnez	s0,ffffffffc0201028 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201032:	1a02                	slli	s4,s4,0x20
ffffffffc0201034:	00001797          	auipc	a5,0x1
ffffffffc0201038:	fac78793          	addi	a5,a5,-84 # ffffffffc0201fe0 <buddy_system_pmm_manager+0x160>
ffffffffc020103c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201040:	9a3e                	add	s4,s4,a5
}
ffffffffc0201042:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201044:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201048:	70a2                	ld	ra,40(sp)
ffffffffc020104a:	69a2                	ld	s3,8(sp)
ffffffffc020104c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020104e:	85ca                	mv	a1,s2
ffffffffc0201050:	87a6                	mv	a5,s1
}
ffffffffc0201052:	6942                	ld	s2,16(sp)
ffffffffc0201054:	64e2                	ld	s1,24(sp)
ffffffffc0201056:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201058:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020105a:	03065633          	divu	a2,a2,a6
ffffffffc020105e:	8722                	mv	a4,s0
ffffffffc0201060:	f9bff0ef          	jal	ra,ffffffffc0200ffa <printnum>
ffffffffc0201064:	b7f9                	j	ffffffffc0201032 <printnum+0x38>

ffffffffc0201066 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201066:	7119                	addi	sp,sp,-128
ffffffffc0201068:	f4a6                	sd	s1,104(sp)
ffffffffc020106a:	f0ca                	sd	s2,96(sp)
ffffffffc020106c:	ecce                	sd	s3,88(sp)
ffffffffc020106e:	e8d2                	sd	s4,80(sp)
ffffffffc0201070:	e4d6                	sd	s5,72(sp)
ffffffffc0201072:	e0da                	sd	s6,64(sp)
ffffffffc0201074:	fc5e                	sd	s7,56(sp)
ffffffffc0201076:	f06a                	sd	s10,32(sp)
ffffffffc0201078:	fc86                	sd	ra,120(sp)
ffffffffc020107a:	f8a2                	sd	s0,112(sp)
ffffffffc020107c:	f862                	sd	s8,48(sp)
ffffffffc020107e:	f466                	sd	s9,40(sp)
ffffffffc0201080:	ec6e                	sd	s11,24(sp)
ffffffffc0201082:	892a                	mv	s2,a0
ffffffffc0201084:	84ae                	mv	s1,a1
ffffffffc0201086:	8d32                	mv	s10,a2
ffffffffc0201088:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020108a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020108e:	5b7d                	li	s6,-1
ffffffffc0201090:	00001a97          	auipc	s5,0x1
ffffffffc0201094:	f84a8a93          	addi	s5,s5,-124 # ffffffffc0202014 <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201098:	00001b97          	auipc	s7,0x1
ffffffffc020109c:	158b8b93          	addi	s7,s7,344 # ffffffffc02021f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010a0:	000d4503          	lbu	a0,0(s10)
ffffffffc02010a4:	001d0413          	addi	s0,s10,1
ffffffffc02010a8:	01350a63          	beq	a0,s3,ffffffffc02010bc <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010ac:	c121                	beqz	a0,ffffffffc02010ec <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010ae:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010b0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010b2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010b4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010b8:	ff351ae3          	bne	a0,s3,ffffffffc02010ac <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010bc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010c0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010c4:	4c81                	li	s9,0
ffffffffc02010c6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010c8:	5c7d                	li	s8,-1
ffffffffc02010ca:	5dfd                	li	s11,-1
ffffffffc02010cc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02010d0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010d2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010d6:	0ff5f593          	zext.b	a1,a1
ffffffffc02010da:	00140d13          	addi	s10,s0,1
ffffffffc02010de:	04b56263          	bltu	a0,a1,ffffffffc0201122 <vprintfmt+0xbc>
ffffffffc02010e2:	058a                	slli	a1,a1,0x2
ffffffffc02010e4:	95d6                	add	a1,a1,s5
ffffffffc02010e6:	4194                	lw	a3,0(a1)
ffffffffc02010e8:	96d6                	add	a3,a3,s5
ffffffffc02010ea:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02010ec:	70e6                	ld	ra,120(sp)
ffffffffc02010ee:	7446                	ld	s0,112(sp)
ffffffffc02010f0:	74a6                	ld	s1,104(sp)
ffffffffc02010f2:	7906                	ld	s2,96(sp)
ffffffffc02010f4:	69e6                	ld	s3,88(sp)
ffffffffc02010f6:	6a46                	ld	s4,80(sp)
ffffffffc02010f8:	6aa6                	ld	s5,72(sp)
ffffffffc02010fa:	6b06                	ld	s6,64(sp)
ffffffffc02010fc:	7be2                	ld	s7,56(sp)
ffffffffc02010fe:	7c42                	ld	s8,48(sp)
ffffffffc0201100:	7ca2                	ld	s9,40(sp)
ffffffffc0201102:	7d02                	ld	s10,32(sp)
ffffffffc0201104:	6de2                	ld	s11,24(sp)
ffffffffc0201106:	6109                	addi	sp,sp,128
ffffffffc0201108:	8082                	ret
            padc = '0';
ffffffffc020110a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020110c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201110:	846a                	mv	s0,s10
ffffffffc0201112:	00140d13          	addi	s10,s0,1
ffffffffc0201116:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020111a:	0ff5f593          	zext.b	a1,a1
ffffffffc020111e:	fcb572e3          	bgeu	a0,a1,ffffffffc02010e2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201122:	85a6                	mv	a1,s1
ffffffffc0201124:	02500513          	li	a0,37
ffffffffc0201128:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020112a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020112e:	8d22                	mv	s10,s0
ffffffffc0201130:	f73788e3          	beq	a5,s3,ffffffffc02010a0 <vprintfmt+0x3a>
ffffffffc0201134:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201138:	1d7d                	addi	s10,s10,-1
ffffffffc020113a:	ff379de3          	bne	a5,s3,ffffffffc0201134 <vprintfmt+0xce>
ffffffffc020113e:	b78d                	j	ffffffffc02010a0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201140:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201144:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201148:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020114a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020114e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201152:	02d86463          	bltu	a6,a3,ffffffffc020117a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201156:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020115a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020115e:	0186873b          	addw	a4,a3,s8
ffffffffc0201162:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201166:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201168:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020116c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020116e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201172:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201176:	fed870e3          	bgeu	a6,a3,ffffffffc0201156 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020117a:	f40ddce3          	bgez	s11,ffffffffc02010d2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020117e:	8de2                	mv	s11,s8
ffffffffc0201180:	5c7d                	li	s8,-1
ffffffffc0201182:	bf81                	j	ffffffffc02010d2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201184:	fffdc693          	not	a3,s11
ffffffffc0201188:	96fd                	srai	a3,a3,0x3f
ffffffffc020118a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020118e:	00144603          	lbu	a2,1(s0)
ffffffffc0201192:	2d81                	sext.w	s11,s11
ffffffffc0201194:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201196:	bf35                	j	ffffffffc02010d2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201198:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02011a0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011a4:	bfd9                	j	ffffffffc020117a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011ac:	01174463          	blt	a4,a7,ffffffffc02011b4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011b0:	1a088e63          	beqz	a7,ffffffffc020136c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011b4:	000a3603          	ld	a2,0(s4)
ffffffffc02011b8:	46c1                	li	a3,16
ffffffffc02011ba:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011bc:	2781                	sext.w	a5,a5
ffffffffc02011be:	876e                	mv	a4,s11
ffffffffc02011c0:	85a6                	mv	a1,s1
ffffffffc02011c2:	854a                	mv	a0,s2
ffffffffc02011c4:	e37ff0ef          	jal	ra,ffffffffc0200ffa <printnum>
            break;
ffffffffc02011c8:	bde1                	j	ffffffffc02010a0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011ca:	000a2503          	lw	a0,0(s4)
ffffffffc02011ce:	85a6                	mv	a1,s1
ffffffffc02011d0:	0a21                	addi	s4,s4,8
ffffffffc02011d2:	9902                	jalr	s2
            break;
ffffffffc02011d4:	b5f1                	j	ffffffffc02010a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011d6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011d8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011dc:	01174463          	blt	a4,a7,ffffffffc02011e4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02011e0:	18088163          	beqz	a7,ffffffffc0201362 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02011e4:	000a3603          	ld	a2,0(s4)
ffffffffc02011e8:	46a9                	li	a3,10
ffffffffc02011ea:	8a2e                	mv	s4,a1
ffffffffc02011ec:	bfc1                	j	ffffffffc02011bc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02011f2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011f6:	bdf1                	j	ffffffffc02010d2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02011f8:	85a6                	mv	a1,s1
ffffffffc02011fa:	02500513          	li	a0,37
ffffffffc02011fe:	9902                	jalr	s2
            break;
ffffffffc0201200:	b545                	j	ffffffffc02010a0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201202:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201206:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201208:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020120a:	b5e1                	j	ffffffffc02010d2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020120c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020120e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201212:	01174463          	blt	a4,a7,ffffffffc020121a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201216:	14088163          	beqz	a7,ffffffffc0201358 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020121a:	000a3603          	ld	a2,0(s4)
ffffffffc020121e:	46a1                	li	a3,8
ffffffffc0201220:	8a2e                	mv	s4,a1
ffffffffc0201222:	bf69                	j	ffffffffc02011bc <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201224:	03000513          	li	a0,48
ffffffffc0201228:	85a6                	mv	a1,s1
ffffffffc020122a:	e03e                	sd	a5,0(sp)
ffffffffc020122c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020122e:	85a6                	mv	a1,s1
ffffffffc0201230:	07800513          	li	a0,120
ffffffffc0201234:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201236:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201238:	6782                	ld	a5,0(sp)
ffffffffc020123a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020123c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201240:	bfb5                	j	ffffffffc02011bc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201242:	000a3403          	ld	s0,0(s4)
ffffffffc0201246:	008a0713          	addi	a4,s4,8
ffffffffc020124a:	e03a                	sd	a4,0(sp)
ffffffffc020124c:	14040263          	beqz	s0,ffffffffc0201390 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201250:	0fb05763          	blez	s11,ffffffffc020133e <vprintfmt+0x2d8>
ffffffffc0201254:	02d00693          	li	a3,45
ffffffffc0201258:	0cd79163          	bne	a5,a3,ffffffffc020131a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020125c:	00044783          	lbu	a5,0(s0)
ffffffffc0201260:	0007851b          	sext.w	a0,a5
ffffffffc0201264:	cf85                	beqz	a5,ffffffffc020129c <vprintfmt+0x236>
ffffffffc0201266:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020126a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020126e:	000c4563          	bltz	s8,ffffffffc0201278 <vprintfmt+0x212>
ffffffffc0201272:	3c7d                	addiw	s8,s8,-1
ffffffffc0201274:	036c0263          	beq	s8,s6,ffffffffc0201298 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201278:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020127a:	0e0c8e63          	beqz	s9,ffffffffc0201376 <vprintfmt+0x310>
ffffffffc020127e:	3781                	addiw	a5,a5,-32
ffffffffc0201280:	0ef47b63          	bgeu	s0,a5,ffffffffc0201376 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201284:	03f00513          	li	a0,63
ffffffffc0201288:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020128a:	000a4783          	lbu	a5,0(s4)
ffffffffc020128e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201290:	0a05                	addi	s4,s4,1
ffffffffc0201292:	0007851b          	sext.w	a0,a5
ffffffffc0201296:	ffe1                	bnez	a5,ffffffffc020126e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201298:	01b05963          	blez	s11,ffffffffc02012aa <vprintfmt+0x244>
ffffffffc020129c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020129e:	85a6                	mv	a1,s1
ffffffffc02012a0:	02000513          	li	a0,32
ffffffffc02012a4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012a6:	fe0d9be3          	bnez	s11,ffffffffc020129c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012aa:	6a02                	ld	s4,0(sp)
ffffffffc02012ac:	bbd5                	j	ffffffffc02010a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012b0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012b4:	01174463          	blt	a4,a7,ffffffffc02012bc <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012b8:	08088d63          	beqz	a7,ffffffffc0201352 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012bc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012c0:	0a044d63          	bltz	s0,ffffffffc020137a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012c4:	8622                	mv	a2,s0
ffffffffc02012c6:	8a66                	mv	s4,s9
ffffffffc02012c8:	46a9                	li	a3,10
ffffffffc02012ca:	bdcd                	j	ffffffffc02011bc <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02012cc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012d0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02012d2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02012d4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02012d8:	8fb5                	xor	a5,a5,a3
ffffffffc02012da:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012de:	02d74163          	blt	a4,a3,ffffffffc0201300 <vprintfmt+0x29a>
ffffffffc02012e2:	00369793          	slli	a5,a3,0x3
ffffffffc02012e6:	97de                	add	a5,a5,s7
ffffffffc02012e8:	639c                	ld	a5,0(a5)
ffffffffc02012ea:	cb99                	beqz	a5,ffffffffc0201300 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02012ec:	86be                	mv	a3,a5
ffffffffc02012ee:	00001617          	auipc	a2,0x1
ffffffffc02012f2:	d2260613          	addi	a2,a2,-734 # ffffffffc0202010 <buddy_system_pmm_manager+0x190>
ffffffffc02012f6:	85a6                	mv	a1,s1
ffffffffc02012f8:	854a                	mv	a0,s2
ffffffffc02012fa:	0ce000ef          	jal	ra,ffffffffc02013c8 <printfmt>
ffffffffc02012fe:	b34d                	j	ffffffffc02010a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201300:	00001617          	auipc	a2,0x1
ffffffffc0201304:	d0060613          	addi	a2,a2,-768 # ffffffffc0202000 <buddy_system_pmm_manager+0x180>
ffffffffc0201308:	85a6                	mv	a1,s1
ffffffffc020130a:	854a                	mv	a0,s2
ffffffffc020130c:	0bc000ef          	jal	ra,ffffffffc02013c8 <printfmt>
ffffffffc0201310:	bb41                	j	ffffffffc02010a0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201312:	00001417          	auipc	s0,0x1
ffffffffc0201316:	ce640413          	addi	s0,s0,-794 # ffffffffc0201ff8 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020131a:	85e2                	mv	a1,s8
ffffffffc020131c:	8522                	mv	a0,s0
ffffffffc020131e:	e43e                	sd	a5,8(sp)
ffffffffc0201320:	1e6000ef          	jal	ra,ffffffffc0201506 <strnlen>
ffffffffc0201324:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201328:	01b05b63          	blez	s11,ffffffffc020133e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020132c:	67a2                	ld	a5,8(sp)
ffffffffc020132e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201332:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201334:	85a6                	mv	a1,s1
ffffffffc0201336:	8552                	mv	a0,s4
ffffffffc0201338:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020133a:	fe0d9ce3          	bnez	s11,ffffffffc0201332 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020133e:	00044783          	lbu	a5,0(s0)
ffffffffc0201342:	00140a13          	addi	s4,s0,1
ffffffffc0201346:	0007851b          	sext.w	a0,a5
ffffffffc020134a:	d3a5                	beqz	a5,ffffffffc02012aa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020134c:	05e00413          	li	s0,94
ffffffffc0201350:	bf39                	j	ffffffffc020126e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201352:	000a2403          	lw	s0,0(s4)
ffffffffc0201356:	b7ad                	j	ffffffffc02012c0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201358:	000a6603          	lwu	a2,0(s4)
ffffffffc020135c:	46a1                	li	a3,8
ffffffffc020135e:	8a2e                	mv	s4,a1
ffffffffc0201360:	bdb1                	j	ffffffffc02011bc <vprintfmt+0x156>
ffffffffc0201362:	000a6603          	lwu	a2,0(s4)
ffffffffc0201366:	46a9                	li	a3,10
ffffffffc0201368:	8a2e                	mv	s4,a1
ffffffffc020136a:	bd89                	j	ffffffffc02011bc <vprintfmt+0x156>
ffffffffc020136c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201370:	46c1                	li	a3,16
ffffffffc0201372:	8a2e                	mv	s4,a1
ffffffffc0201374:	b5a1                	j	ffffffffc02011bc <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201376:	9902                	jalr	s2
ffffffffc0201378:	bf09                	j	ffffffffc020128a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020137a:	85a6                	mv	a1,s1
ffffffffc020137c:	02d00513          	li	a0,45
ffffffffc0201380:	e03e                	sd	a5,0(sp)
ffffffffc0201382:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201384:	6782                	ld	a5,0(sp)
ffffffffc0201386:	8a66                	mv	s4,s9
ffffffffc0201388:	40800633          	neg	a2,s0
ffffffffc020138c:	46a9                	li	a3,10
ffffffffc020138e:	b53d                	j	ffffffffc02011bc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201390:	03b05163          	blez	s11,ffffffffc02013b2 <vprintfmt+0x34c>
ffffffffc0201394:	02d00693          	li	a3,45
ffffffffc0201398:	f6d79de3          	bne	a5,a3,ffffffffc0201312 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020139c:	00001417          	auipc	s0,0x1
ffffffffc02013a0:	c5c40413          	addi	s0,s0,-932 # ffffffffc0201ff8 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013a4:	02800793          	li	a5,40
ffffffffc02013a8:	02800513          	li	a0,40
ffffffffc02013ac:	00140a13          	addi	s4,s0,1
ffffffffc02013b0:	bd6d                	j	ffffffffc020126a <vprintfmt+0x204>
ffffffffc02013b2:	00001a17          	auipc	s4,0x1
ffffffffc02013b6:	c47a0a13          	addi	s4,s4,-953 # ffffffffc0201ff9 <buddy_system_pmm_manager+0x179>
ffffffffc02013ba:	02800513          	li	a0,40
ffffffffc02013be:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013c2:	05e00413          	li	s0,94
ffffffffc02013c6:	b565                	j	ffffffffc020126e <vprintfmt+0x208>

ffffffffc02013c8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013c8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013ca:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013ce:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013d0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013d2:	ec06                	sd	ra,24(sp)
ffffffffc02013d4:	f83a                	sd	a4,48(sp)
ffffffffc02013d6:	fc3e                	sd	a5,56(sp)
ffffffffc02013d8:	e0c2                	sd	a6,64(sp)
ffffffffc02013da:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02013dc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013de:	c89ff0ef          	jal	ra,ffffffffc0201066 <vprintfmt>
}
ffffffffc02013e2:	60e2                	ld	ra,24(sp)
ffffffffc02013e4:	6161                	addi	sp,sp,80
ffffffffc02013e6:	8082                	ret

ffffffffc02013e8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02013e8:	715d                	addi	sp,sp,-80
ffffffffc02013ea:	e486                	sd	ra,72(sp)
ffffffffc02013ec:	e0a6                	sd	s1,64(sp)
ffffffffc02013ee:	fc4a                	sd	s2,56(sp)
ffffffffc02013f0:	f84e                	sd	s3,48(sp)
ffffffffc02013f2:	f452                	sd	s4,40(sp)
ffffffffc02013f4:	f056                	sd	s5,32(sp)
ffffffffc02013f6:	ec5a                	sd	s6,24(sp)
ffffffffc02013f8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02013fa:	c901                	beqz	a0,ffffffffc020140a <readline+0x22>
ffffffffc02013fc:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02013fe:	00001517          	auipc	a0,0x1
ffffffffc0201402:	c1250513          	addi	a0,a0,-1006 # ffffffffc0202010 <buddy_system_pmm_manager+0x190>
ffffffffc0201406:	cadfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020140a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020140c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020140e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201410:	4aa9                	li	s5,10
ffffffffc0201412:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201414:	00005b97          	auipc	s7,0x5
ffffffffc0201418:	d0cb8b93          	addi	s7,s7,-756 # ffffffffc0206120 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020141c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201420:	d0bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201424:	00054a63          	bltz	a0,ffffffffc0201438 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201428:	00a95a63          	bge	s2,a0,ffffffffc020143c <readline+0x54>
ffffffffc020142c:	029a5263          	bge	s4,s1,ffffffffc0201450 <readline+0x68>
        c = getchar();
ffffffffc0201430:	cfbfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201434:	fe055ae3          	bgez	a0,ffffffffc0201428 <readline+0x40>
            return NULL;
ffffffffc0201438:	4501                	li	a0,0
ffffffffc020143a:	a091                	j	ffffffffc020147e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020143c:	03351463          	bne	a0,s3,ffffffffc0201464 <readline+0x7c>
ffffffffc0201440:	e8a9                	bnez	s1,ffffffffc0201492 <readline+0xaa>
        c = getchar();
ffffffffc0201442:	ce9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201446:	fe0549e3          	bltz	a0,ffffffffc0201438 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020144a:	fea959e3          	bge	s2,a0,ffffffffc020143c <readline+0x54>
ffffffffc020144e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201450:	e42a                	sd	a0,8(sp)
ffffffffc0201452:	c97fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201456:	6522                	ld	a0,8(sp)
ffffffffc0201458:	009b87b3          	add	a5,s7,s1
ffffffffc020145c:	2485                	addiw	s1,s1,1
ffffffffc020145e:	00a78023          	sb	a0,0(a5)
ffffffffc0201462:	bf7d                	j	ffffffffc0201420 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201464:	01550463          	beq	a0,s5,ffffffffc020146c <readline+0x84>
ffffffffc0201468:	fb651ce3          	bne	a0,s6,ffffffffc0201420 <readline+0x38>
            cputchar(c);
ffffffffc020146c:	c7dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201470:	00005517          	auipc	a0,0x5
ffffffffc0201474:	cb050513          	addi	a0,a0,-848 # ffffffffc0206120 <buf>
ffffffffc0201478:	94aa                	add	s1,s1,a0
ffffffffc020147a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020147e:	60a6                	ld	ra,72(sp)
ffffffffc0201480:	6486                	ld	s1,64(sp)
ffffffffc0201482:	7962                	ld	s2,56(sp)
ffffffffc0201484:	79c2                	ld	s3,48(sp)
ffffffffc0201486:	7a22                	ld	s4,40(sp)
ffffffffc0201488:	7a82                	ld	s5,32(sp)
ffffffffc020148a:	6b62                	ld	s6,24(sp)
ffffffffc020148c:	6bc2                	ld	s7,16(sp)
ffffffffc020148e:	6161                	addi	sp,sp,80
ffffffffc0201490:	8082                	ret
            cputchar(c);
ffffffffc0201492:	4521                	li	a0,8
ffffffffc0201494:	c55fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201498:	34fd                	addiw	s1,s1,-1
ffffffffc020149a:	b759                	j	ffffffffc0201420 <readline+0x38>

ffffffffc020149c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020149c:	4781                	li	a5,0
ffffffffc020149e:	00005717          	auipc	a4,0x5
ffffffffc02014a2:	b6a73703          	ld	a4,-1174(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02014a6:	88ba                	mv	a7,a4
ffffffffc02014a8:	852a                	mv	a0,a0
ffffffffc02014aa:	85be                	mv	a1,a5
ffffffffc02014ac:	863e                	mv	a2,a5
ffffffffc02014ae:	00000073          	ecall
ffffffffc02014b2:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02014b4:	8082                	ret

ffffffffc02014b6 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02014b6:	4781                	li	a5,0
ffffffffc02014b8:	00005717          	auipc	a4,0x5
ffffffffc02014bc:	0b073703          	ld	a4,176(a4) # ffffffffc0206568 <SBI_SET_TIMER>
ffffffffc02014c0:	88ba                	mv	a7,a4
ffffffffc02014c2:	852a                	mv	a0,a0
ffffffffc02014c4:	85be                	mv	a1,a5
ffffffffc02014c6:	863e                	mv	a2,a5
ffffffffc02014c8:	00000073          	ecall
ffffffffc02014cc:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02014ce:	8082                	ret

ffffffffc02014d0 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02014d0:	4501                	li	a0,0
ffffffffc02014d2:	00005797          	auipc	a5,0x5
ffffffffc02014d6:	b2e7b783          	ld	a5,-1234(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02014da:	88be                	mv	a7,a5
ffffffffc02014dc:	852a                	mv	a0,a0
ffffffffc02014de:	85aa                	mv	a1,a0
ffffffffc02014e0:	862a                	mv	a2,a0
ffffffffc02014e2:	00000073          	ecall
ffffffffc02014e6:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc02014e8:	2501                	sext.w	a0,a0
ffffffffc02014ea:	8082                	ret

ffffffffc02014ec <sbi_shutdown>:
    __asm__ volatile (
ffffffffc02014ec:	4781                	li	a5,0
ffffffffc02014ee:	00005717          	auipc	a4,0x5
ffffffffc02014f2:	b2273703          	ld	a4,-1246(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc02014f6:	88ba                	mv	a7,a4
ffffffffc02014f8:	853e                	mv	a0,a5
ffffffffc02014fa:	85be                	mv	a1,a5
ffffffffc02014fc:	863e                	mv	a2,a5
ffffffffc02014fe:	00000073          	ecall
ffffffffc0201502:	87aa                	mv	a5,a0

void sbi_shutdown(void){
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201504:	8082                	ret

ffffffffc0201506 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201506:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201508:	e589                	bnez	a1,ffffffffc0201512 <strnlen+0xc>
ffffffffc020150a:	a811                	j	ffffffffc020151e <strnlen+0x18>
        cnt ++;
ffffffffc020150c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020150e:	00f58863          	beq	a1,a5,ffffffffc020151e <strnlen+0x18>
ffffffffc0201512:	00f50733          	add	a4,a0,a5
ffffffffc0201516:	00074703          	lbu	a4,0(a4)
ffffffffc020151a:	fb6d                	bnez	a4,ffffffffc020150c <strnlen+0x6>
ffffffffc020151c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020151e:	852e                	mv	a0,a1
ffffffffc0201520:	8082                	ret

ffffffffc0201522 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201522:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201526:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020152a:	cb89                	beqz	a5,ffffffffc020153c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020152c:	0505                	addi	a0,a0,1
ffffffffc020152e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201530:	fee789e3          	beq	a5,a4,ffffffffc0201522 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201534:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201538:	9d19                	subw	a0,a0,a4
ffffffffc020153a:	8082                	ret
ffffffffc020153c:	4501                	li	a0,0
ffffffffc020153e:	bfed                	j	ffffffffc0201538 <strcmp+0x16>

ffffffffc0201540 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201540:	00054783          	lbu	a5,0(a0)
ffffffffc0201544:	c799                	beqz	a5,ffffffffc0201552 <strchr+0x12>
        if (*s == c) {
ffffffffc0201546:	00f58763          	beq	a1,a5,ffffffffc0201554 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020154a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020154e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201550:	fbfd                	bnez	a5,ffffffffc0201546 <strchr+0x6>
    }
    return NULL;
ffffffffc0201552:	4501                	li	a0,0
}
ffffffffc0201554:	8082                	ret

ffffffffc0201556 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201556:	ca01                	beqz	a2,ffffffffc0201566 <memset+0x10>
ffffffffc0201558:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020155a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020155c:	0785                	addi	a5,a5,1
ffffffffc020155e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201562:	fec79de3          	bne	a5,a2,ffffffffc020155c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201566:	8082                	ret
