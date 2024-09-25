
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	201000ef          	jal	ra,80200a22 <memset>

    cons_init();  // init the console
    80200026:	150000ef          	jal	ra,80200176 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a0e58593          	addi	a1,a1,-1522 # 80200a38 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a2650513          	addi	a0,a0,-1498 # 80200a58 <etext+0x24>
    8020003a:	036000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    8020003e:	068000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	144000ef          	jal	ra,80200186 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0ee000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	136000ef          	jal	ra,80200180 <intr_enable>
    asm("mret");
    8020004e:	30200073          	mret
    asm("ebreak");
    80200052:	9002                	ebreak
    while (1)
    80200054:	a001                	j	80200054 <kern_init+0x4a>

0000000080200056 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    cons_putc(c);
    8020005e:	11a000ef          	jal	ra,80200178 <cons_putc>
    (*cnt)++;
    80200062:	401c                	lw	a5,0(s0)
}
    80200064:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
}
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200070:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200076:	8e2a                	mv	t3,a0
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	00000517          	auipc	a0,0x0
    80200082:	fd850513          	addi	a0,a0,-40 # 80200056 <cputch>
    80200086:	004c                	addi	a1,sp,4
    80200088:	869a                	mv	a3,t1
    8020008a:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	59c000ef          	jal	ra,80200636 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	9b850513          	addi	a0,a0,-1608 # 80200a60 <etext+0x2c>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fbfff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5458593          	addi	a1,a1,-172 # 8020000a <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	9c250513          	addi	a0,a0,-1598 # 80200a80 <etext+0x4c>
    802000c6:	fabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	96a58593          	addi	a1,a1,-1686 # 80200a34 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	9ce50513          	addi	a0,a0,-1586 # 80200aa0 <etext+0x6c>
    802000da:	f97ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <ticks>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	9da50513          	addi	a0,a0,-1574 # 80200ac0 <etext+0x8c>
    802000ee:	f83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	9e650513          	addi	a0,a0,-1562 # 80200ae0 <etext+0xac>
    80200102:	f6fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efc78793          	addi	a5,a5,-260 # 8020000a <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	9d850513          	addi	a0,a0,-1576 # 80200b00 <etext+0xcc>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	bf3d                	j	80200070 <cprintf>

0000000080200134 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200140:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	087000ef          	jal	ra,802009d2 <sbi_set_timer>
}
    80200150:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ea07bf23          	sd	zero,-322(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	9d650513          	addi	a0,a0,-1578 # 80200b30 <etext+0xfc>
}
    80200162:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200164:	b731                	j	80200070 <cprintf>

0000000080200166 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200166:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	0610006f          	j	802009d2 <sbi_set_timer>

0000000080200176 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200176:	8082                	ret

0000000080200178 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200178:	0ff57513          	zext.b	a0,a0
    8020017c:	03d0006f          	j	802009b8 <sbi_console_putchar>

0000000080200180 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200186:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	38a78793          	addi	a5,a5,906 # 80200514 <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
}
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	9b050513          	addi	a0,a0,-1616 # 80200b50 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	ec7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	9b850513          	addi	a0,a0,-1608 # 80200b68 <etext+0x134>
    802001b8:	eb9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	9c250513          	addi	a0,a0,-1598 # 80200b80 <etext+0x14c>
    802001c6:	eabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	9cc50513          	addi	a0,a0,-1588 # 80200b98 <etext+0x164>
    802001d4:	e9dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	9d650513          	addi	a0,a0,-1578 # 80200bb0 <etext+0x17c>
    802001e2:	e8fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	9e050513          	addi	a0,a0,-1568 # 80200bc8 <etext+0x194>
    802001f0:	e81ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	9ea50513          	addi	a0,a0,-1558 # 80200be0 <etext+0x1ac>
    802001fe:	e73ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	9f450513          	addi	a0,a0,-1548 # 80200bf8 <etext+0x1c4>
    8020020c:	e65ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	9fe50513          	addi	a0,a0,-1538 # 80200c10 <etext+0x1dc>
    8020021a:	e57ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	a0850513          	addi	a0,a0,-1528 # 80200c28 <etext+0x1f4>
    80200228:	e49ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	a1250513          	addi	a0,a0,-1518 # 80200c40 <etext+0x20c>
    80200236:	e3bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	a1c50513          	addi	a0,a0,-1508 # 80200c58 <etext+0x224>
    80200244:	e2dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	a2650513          	addi	a0,a0,-1498 # 80200c70 <etext+0x23c>
    80200252:	e1fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	a3050513          	addi	a0,a0,-1488 # 80200c88 <etext+0x254>
    80200260:	e11ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	a3a50513          	addi	a0,a0,-1478 # 80200ca0 <etext+0x26c>
    8020026e:	e03ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	a4450513          	addi	a0,a0,-1468 # 80200cb8 <etext+0x284>
    8020027c:	df5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	a4e50513          	addi	a0,a0,-1458 # 80200cd0 <etext+0x29c>
    8020028a:	de7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	a5850513          	addi	a0,a0,-1448 # 80200ce8 <etext+0x2b4>
    80200298:	dd9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	a6250513          	addi	a0,a0,-1438 # 80200d00 <etext+0x2cc>
    802002a6:	dcbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	a6c50513          	addi	a0,a0,-1428 # 80200d18 <etext+0x2e4>
    802002b4:	dbdff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	a7650513          	addi	a0,a0,-1418 # 80200d30 <etext+0x2fc>
    802002c2:	dafff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	a8050513          	addi	a0,a0,-1408 # 80200d48 <etext+0x314>
    802002d0:	da1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	a8a50513          	addi	a0,a0,-1398 # 80200d60 <etext+0x32c>
    802002de:	d93ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	a9450513          	addi	a0,a0,-1388 # 80200d78 <etext+0x344>
    802002ec:	d85ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	a9e50513          	addi	a0,a0,-1378 # 80200d90 <etext+0x35c>
    802002fa:	d77ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	aa850513          	addi	a0,a0,-1368 # 80200da8 <etext+0x374>
    80200308:	d69ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	ab250513          	addi	a0,a0,-1358 # 80200dc0 <etext+0x38c>
    80200316:	d5bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	abc50513          	addi	a0,a0,-1348 # 80200dd8 <etext+0x3a4>
    80200324:	d4dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	ac650513          	addi	a0,a0,-1338 # 80200df0 <etext+0x3bc>
    80200332:	d3fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	ad050513          	addi	a0,a0,-1328 # 80200e08 <etext+0x3d4>
    80200340:	d31ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	ada50513          	addi	a0,a0,-1318 # 80200e20 <etext+0x3ec>
    8020034e:	d23ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	7c6c                	ld	a1,248(s0)
}
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	ae050513          	addi	a0,a0,-1312 # 80200e38 <etext+0x404>
}
    80200360:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	b339                	j	80200070 <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	ae450513          	addi	a0,a0,-1308 # 80200e50 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cfbff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1dff0ef          	jal	ra,80200198 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	ae450513          	addi	a0,a0,-1308 # 80200e68 <etext+0x434>
    8020038c:	ce5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	aec50513          	addi	a0,a0,-1300 # 80200e80 <etext+0x44c>
    8020039c:	cd5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	af450513          	addi	a0,a0,-1292 # 80200e98 <etext+0x464>
    802003ac:	cc5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	af850513          	addi	a0,a0,-1288 # 80200eb0 <etext+0x47c>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	b17d                	j	80200070 <cprintf>

00000000802003c4 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c4:	11853783          	ld	a5,280(a0)
    802003c8:	472d                	li	a4,11
    802003ca:	0786                	slli	a5,a5,0x1
    802003cc:	8385                	srli	a5,a5,0x1
    802003ce:	06f76f63          	bltu	a4,a5,8020044c <interrupt_handler+0x88>
    802003d2:	00001717          	auipc	a4,0x1
    802003d6:	ba670713          	addi	a4,a4,-1114 # 80200f78 <etext+0x544>
    802003da:	078a                	slli	a5,a5,0x2
    802003dc:	97ba                	add	a5,a5,a4
    802003de:	439c                	lw	a5,0(a5)
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	b4450513          	addi	a0,a0,-1212 # 80200f28 <etext+0x4f4>
    802003ec:	b151                	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	b1a50513          	addi	a0,a0,-1254 # 80200f08 <etext+0x4d4>
    802003f6:	b9ad                	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	ad050513          	addi	a0,a0,-1328 # 80200ec8 <etext+0x494>
    80200400:	b985                	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200402:	00001517          	auipc	a0,0x1
    80200406:	ae650513          	addi	a0,a0,-1306 # 80200ee8 <etext+0x4b4>
    8020040a:	b19d                	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040c:	1141                	addi	sp,sp,-16
    8020040e:	e406                	sd	ra,8(sp)
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2213244 :  */
            
             // (1) 设置下次时钟中断
            clock_set_next_event();
    80200410:	d57ff0ef          	jal	ra,80200166 <clock_set_next_event>
            
            // (2) 计数器（ticks）加一
            ticks++;
    80200414:	00004797          	auipc	a5,0x4
    80200418:	bfc78793          	addi	a5,a5,-1028 # 80204010 <ticks>
    8020041c:	6398                	ld	a4,0(a5)
    8020041e:	0705                	addi	a4,a4,1
    80200420:	e398                	sd	a4,0(a5)

            // (3) 当计数器加到100时输出`100 ticks`
            if (ticks % TICK_NUM == 0) {
    80200422:	639c                	ld	a5,0(a5)
    80200424:	06400713          	li	a4,100
    80200428:	02e7f7b3          	remu	a5,a5,a4
    8020042c:	c38d                	beqz	a5,8020044e <interrupt_handler+0x8a>
                print_ticks();
                print_num++;  // 打印次数加一
            }

            // (4) 判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数
            if (print_num == 10) {
    8020042e:	00004717          	auipc	a4,0x4
    80200432:	bea72703          	lw	a4,-1046(a4) # 80204018 <print_num>
    80200436:	47a9                	li	a5,10
    80200438:	02f70c63          	beq	a4,a5,80200470 <interrupt_handler+0xac>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020043c:	60a2                	ld	ra,8(sp)
    8020043e:	0141                	addi	sp,sp,16
    80200440:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200442:	00001517          	auipc	a0,0x1
    80200446:	b1650513          	addi	a0,a0,-1258 # 80200f58 <etext+0x524>
    8020044a:	b11d                	j	80200070 <cprintf>
            print_trapframe(tf);
    8020044c:	bf21                	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044e:	06400593          	li	a1,100
    80200452:	00001517          	auipc	a0,0x1
    80200456:	af650513          	addi	a0,a0,-1290 # 80200f48 <etext+0x514>
    8020045a:	c17ff0ef          	jal	ra,80200070 <cprintf>
                print_num++;  // 打印次数加一
    8020045e:	00004697          	auipc	a3,0x4
    80200462:	bba68693          	addi	a3,a3,-1094 # 80204018 <print_num>
    80200466:	429c                	lw	a5,0(a3)
    80200468:	0017871b          	addiw	a4,a5,1
    8020046c:	c298                	sw	a4,0(a3)
    8020046e:	b7e1                	j	80200436 <interrupt_handler+0x72>
}
    80200470:	60a2                	ld	ra,8(sp)
    80200472:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200474:	aba5                	j	802009ec <sbi_shutdown>

0000000080200476 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200476:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    8020047a:	1141                	addi	sp,sp,-16
    8020047c:	e022                	sd	s0,0(sp)
    8020047e:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200480:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200482:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200484:	04e78863          	beq	a5,a4,802004d4 <exception_handler+0x5e>
    80200488:	02f76e63          	bltu	a4,a5,802004c4 <exception_handler+0x4e>
    8020048c:	4709                	li	a4,2
    8020048e:	02e79763          	bne	a5,a4,802004bc <exception_handler+0x46>
        case CAUSE_ILLEGAL_INSTRUCTION:
             // 非法指令异常处理
             /* LAB1 CHALLENGE3   2213244 :  */

            // (1) 输出指令异常类型（Illegal instruction）
            cprintf("Illegal instruction exception at 0x%08x\n", tf->epc);
    80200492:	10853583          	ld	a1,264(a0)
    80200496:	00001517          	auipc	a0,0x1
    8020049a:	b1250513          	addi	a0,a0,-1262 # 80200fa8 <etext+0x574>
    8020049e:	bd3ff0ef          	jal	ra,80200070 <cprintf>
            // (2) 输出异常指令地址
            cprintf("Exception address: 0x%08x\n", tf->epc);  
    802004a2:	10843583          	ld	a1,264(s0)
    802004a6:	00001517          	auipc	a0,0x1
    802004aa:	b3250513          	addi	a0,a0,-1230 # 80200fd8 <etext+0x5a4>
    802004ae:	bc3ff0ef          	jal	ra,80200070 <cprintf>
            // (3) 更新 tf->epc 寄存器以跳过非法指令
            tf->epc += 4;  // 假设每条指令为 4 字节，跳过非法指令
    802004b2:	10843783          	ld	a5,264(s0)
    802004b6:	0791                	addi	a5,a5,4
    802004b8:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004bc:	60a2                	ld	ra,8(sp)
    802004be:	6402                	ld	s0,0(sp)
    802004c0:	0141                	addi	sp,sp,16
    802004c2:	8082                	ret
    switch (tf->cause) {
    802004c4:	17f1                	addi	a5,a5,-4
    802004c6:	471d                	li	a4,7
    802004c8:	fef77ae3          	bgeu	a4,a5,802004bc <exception_handler+0x46>
}
    802004cc:	6402                	ld	s0,0(sp)
    802004ce:	60a2                	ld	ra,8(sp)
    802004d0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004d2:	bd49                	j	80200364 <print_trapframe>
            cprintf("Breakpoint exception at 0x%08x\n", tf->epc);
    802004d4:	10853583          	ld	a1,264(a0)
    802004d8:	00001517          	auipc	a0,0x1
    802004dc:	b2050513          	addi	a0,a0,-1248 # 80200ff8 <etext+0x5c4>
    802004e0:	b91ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Breakpoint address: 0x%08x\n", tf->epc);
    802004e4:	10843583          	ld	a1,264(s0)
    802004e8:	00001517          	auipc	a0,0x1
    802004ec:	b3050513          	addi	a0,a0,-1232 # 80201018 <etext+0x5e4>
    802004f0:	b81ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 4;  // 假设每条指令为 4 字节，跳过断点指令
    802004f4:	10843783          	ld	a5,264(s0)
}
    802004f8:	60a2                	ld	ra,8(sp)
            tf->epc += 4;  // 假设每条指令为 4 字节，跳过断点指令
    802004fa:	0791                	addi	a5,a5,4
    802004fc:	10f43423          	sd	a5,264(s0)
}
    80200500:	6402                	ld	s0,0(sp)
    80200502:	0141                	addi	sp,sp,16
    80200504:	8082                	ret

0000000080200506 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200506:	11853783          	ld	a5,280(a0)
    8020050a:	0007c363          	bltz	a5,80200510 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020050e:	b7a5                	j	80200476 <exception_handler>
        interrupt_handler(tf);
    80200510:	bd55                	j	802003c4 <interrupt_handler>
	...

0000000080200514 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200514:	14011073          	csrw	sscratch,sp
    80200518:	712d                	addi	sp,sp,-288
    8020051a:	e002                	sd	zero,0(sp)
    8020051c:	e406                	sd	ra,8(sp)
    8020051e:	ec0e                	sd	gp,24(sp)
    80200520:	f012                	sd	tp,32(sp)
    80200522:	f416                	sd	t0,40(sp)
    80200524:	f81a                	sd	t1,48(sp)
    80200526:	fc1e                	sd	t2,56(sp)
    80200528:	e0a2                	sd	s0,64(sp)
    8020052a:	e4a6                	sd	s1,72(sp)
    8020052c:	e8aa                	sd	a0,80(sp)
    8020052e:	ecae                	sd	a1,88(sp)
    80200530:	f0b2                	sd	a2,96(sp)
    80200532:	f4b6                	sd	a3,104(sp)
    80200534:	f8ba                	sd	a4,112(sp)
    80200536:	fcbe                	sd	a5,120(sp)
    80200538:	e142                	sd	a6,128(sp)
    8020053a:	e546                	sd	a7,136(sp)
    8020053c:	e94a                	sd	s2,144(sp)
    8020053e:	ed4e                	sd	s3,152(sp)
    80200540:	f152                	sd	s4,160(sp)
    80200542:	f556                	sd	s5,168(sp)
    80200544:	f95a                	sd	s6,176(sp)
    80200546:	fd5e                	sd	s7,184(sp)
    80200548:	e1e2                	sd	s8,192(sp)
    8020054a:	e5e6                	sd	s9,200(sp)
    8020054c:	e9ea                	sd	s10,208(sp)
    8020054e:	edee                	sd	s11,216(sp)
    80200550:	f1f2                	sd	t3,224(sp)
    80200552:	f5f6                	sd	t4,232(sp)
    80200554:	f9fa                	sd	t5,240(sp)
    80200556:	fdfe                	sd	t6,248(sp)
    80200558:	14001473          	csrrw	s0,sscratch,zero
    8020055c:	100024f3          	csrr	s1,sstatus
    80200560:	14102973          	csrr	s2,sepc
    80200564:	143029f3          	csrr	s3,stval
    80200568:	14202a73          	csrr	s4,scause
    8020056c:	e822                	sd	s0,16(sp)
    8020056e:	e226                	sd	s1,256(sp)
    80200570:	e64a                	sd	s2,264(sp)
    80200572:	ea4e                	sd	s3,272(sp)
    80200574:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200576:	850a                	mv	a0,sp
    jal trap
    80200578:	f8fff0ef          	jal	ra,80200506 <trap>

000000008020057c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020057c:	6492                	ld	s1,256(sp)
    8020057e:	6932                	ld	s2,264(sp)
    80200580:	10049073          	csrw	sstatus,s1
    80200584:	14191073          	csrw	sepc,s2
    80200588:	60a2                	ld	ra,8(sp)
    8020058a:	61e2                	ld	gp,24(sp)
    8020058c:	7202                	ld	tp,32(sp)
    8020058e:	72a2                	ld	t0,40(sp)
    80200590:	7342                	ld	t1,48(sp)
    80200592:	73e2                	ld	t2,56(sp)
    80200594:	6406                	ld	s0,64(sp)
    80200596:	64a6                	ld	s1,72(sp)
    80200598:	6546                	ld	a0,80(sp)
    8020059a:	65e6                	ld	a1,88(sp)
    8020059c:	7606                	ld	a2,96(sp)
    8020059e:	76a6                	ld	a3,104(sp)
    802005a0:	7746                	ld	a4,112(sp)
    802005a2:	77e6                	ld	a5,120(sp)
    802005a4:	680a                	ld	a6,128(sp)
    802005a6:	68aa                	ld	a7,136(sp)
    802005a8:	694a                	ld	s2,144(sp)
    802005aa:	69ea                	ld	s3,152(sp)
    802005ac:	7a0a                	ld	s4,160(sp)
    802005ae:	7aaa                	ld	s5,168(sp)
    802005b0:	7b4a                	ld	s6,176(sp)
    802005b2:	7bea                	ld	s7,184(sp)
    802005b4:	6c0e                	ld	s8,192(sp)
    802005b6:	6cae                	ld	s9,200(sp)
    802005b8:	6d4e                	ld	s10,208(sp)
    802005ba:	6dee                	ld	s11,216(sp)
    802005bc:	7e0e                	ld	t3,224(sp)
    802005be:	7eae                	ld	t4,232(sp)
    802005c0:	7f4e                	ld	t5,240(sp)
    802005c2:	7fee                	ld	t6,248(sp)
    802005c4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005c6:	10200073          	sret

00000000802005ca <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ca:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005ce:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005d0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005d4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005d6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005da:	f022                	sd	s0,32(sp)
    802005dc:	ec26                	sd	s1,24(sp)
    802005de:	e84a                	sd	s2,16(sp)
    802005e0:	f406                	sd	ra,40(sp)
    802005e2:	e44e                	sd	s3,8(sp)
    802005e4:	84aa                	mv	s1,a0
    802005e6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005e8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005ec:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005ee:	03067e63          	bgeu	a2,a6,8020062a <printnum+0x60>
    802005f2:	89be                	mv	s3,a5
        while (-- width > 0)
    802005f4:	00805763          	blez	s0,80200602 <printnum+0x38>
    802005f8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005fa:	85ca                	mv	a1,s2
    802005fc:	854e                	mv	a0,s3
    802005fe:	9482                	jalr	s1
        while (-- width > 0)
    80200600:	fc65                	bnez	s0,802005f8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200602:	1a02                	slli	s4,s4,0x20
    80200604:	00001797          	auipc	a5,0x1
    80200608:	a3478793          	addi	a5,a5,-1484 # 80201038 <etext+0x604>
    8020060c:	020a5a13          	srli	s4,s4,0x20
    80200610:	9a3e                	add	s4,s4,a5
}
    80200612:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200614:	000a4503          	lbu	a0,0(s4)
}
    80200618:	70a2                	ld	ra,40(sp)
    8020061a:	69a2                	ld	s3,8(sp)
    8020061c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020061e:	85ca                	mv	a1,s2
    80200620:	87a6                	mv	a5,s1
}
    80200622:	6942                	ld	s2,16(sp)
    80200624:	64e2                	ld	s1,24(sp)
    80200626:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200628:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    8020062a:	03065633          	divu	a2,a2,a6
    8020062e:	8722                	mv	a4,s0
    80200630:	f9bff0ef          	jal	ra,802005ca <printnum>
    80200634:	b7f9                	j	80200602 <printnum+0x38>

0000000080200636 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200636:	7119                	addi	sp,sp,-128
    80200638:	f4a6                	sd	s1,104(sp)
    8020063a:	f0ca                	sd	s2,96(sp)
    8020063c:	ecce                	sd	s3,88(sp)
    8020063e:	e8d2                	sd	s4,80(sp)
    80200640:	e4d6                	sd	s5,72(sp)
    80200642:	e0da                	sd	s6,64(sp)
    80200644:	fc5e                	sd	s7,56(sp)
    80200646:	f06a                	sd	s10,32(sp)
    80200648:	fc86                	sd	ra,120(sp)
    8020064a:	f8a2                	sd	s0,112(sp)
    8020064c:	f862                	sd	s8,48(sp)
    8020064e:	f466                	sd	s9,40(sp)
    80200650:	ec6e                	sd	s11,24(sp)
    80200652:	892a                	mv	s2,a0
    80200654:	84ae                	mv	s1,a1
    80200656:	8d32                	mv	s10,a2
    80200658:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020065a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020065e:	5b7d                	li	s6,-1
    80200660:	00001a97          	auipc	s5,0x1
    80200664:	a0ca8a93          	addi	s5,s5,-1524 # 8020106c <etext+0x638>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200668:	00001b97          	auipc	s7,0x1
    8020066c:	be0b8b93          	addi	s7,s7,-1056 # 80201248 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200670:	000d4503          	lbu	a0,0(s10)
    80200674:	001d0413          	addi	s0,s10,1
    80200678:	01350a63          	beq	a0,s3,8020068c <vprintfmt+0x56>
            if (ch == '\0') {
    8020067c:	c121                	beqz	a0,802006bc <vprintfmt+0x86>
            putch(ch, putdat);
    8020067e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200680:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200682:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200684:	fff44503          	lbu	a0,-1(s0)
    80200688:	ff351ae3          	bne	a0,s3,8020067c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    8020068c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200690:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200694:	4c81                	li	s9,0
    80200696:	4881                	li	a7,0
        width = precision = -1;
    80200698:	5c7d                	li	s8,-1
    8020069a:	5dfd                	li	s11,-1
    8020069c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006a0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006a2:	fdd6059b          	addiw	a1,a2,-35
    802006a6:	0ff5f593          	zext.b	a1,a1
    802006aa:	00140d13          	addi	s10,s0,1
    802006ae:	04b56263          	bltu	a0,a1,802006f2 <vprintfmt+0xbc>
    802006b2:	058a                	slli	a1,a1,0x2
    802006b4:	95d6                	add	a1,a1,s5
    802006b6:	4194                	lw	a3,0(a1)
    802006b8:	96d6                	add	a3,a3,s5
    802006ba:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006bc:	70e6                	ld	ra,120(sp)
    802006be:	7446                	ld	s0,112(sp)
    802006c0:	74a6                	ld	s1,104(sp)
    802006c2:	7906                	ld	s2,96(sp)
    802006c4:	69e6                	ld	s3,88(sp)
    802006c6:	6a46                	ld	s4,80(sp)
    802006c8:	6aa6                	ld	s5,72(sp)
    802006ca:	6b06                	ld	s6,64(sp)
    802006cc:	7be2                	ld	s7,56(sp)
    802006ce:	7c42                	ld	s8,48(sp)
    802006d0:	7ca2                	ld	s9,40(sp)
    802006d2:	7d02                	ld	s10,32(sp)
    802006d4:	6de2                	ld	s11,24(sp)
    802006d6:	6109                	addi	sp,sp,128
    802006d8:	8082                	ret
            padc = '0';
    802006da:	87b2                	mv	a5,a2
            goto reswitch;
    802006dc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006e0:	846a                	mv	s0,s10
    802006e2:	00140d13          	addi	s10,s0,1
    802006e6:	fdd6059b          	addiw	a1,a2,-35
    802006ea:	0ff5f593          	zext.b	a1,a1
    802006ee:	fcb572e3          	bgeu	a0,a1,802006b2 <vprintfmt+0x7c>
            putch('%', putdat);
    802006f2:	85a6                	mv	a1,s1
    802006f4:	02500513          	li	a0,37
    802006f8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006fa:	fff44783          	lbu	a5,-1(s0)
    802006fe:	8d22                	mv	s10,s0
    80200700:	f73788e3          	beq	a5,s3,80200670 <vprintfmt+0x3a>
    80200704:	ffed4783          	lbu	a5,-2(s10)
    80200708:	1d7d                	addi	s10,s10,-1
    8020070a:	ff379de3          	bne	a5,s3,80200704 <vprintfmt+0xce>
    8020070e:	b78d                	j	80200670 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200710:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200714:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200718:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020071a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020071e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200722:	02d86463          	bltu	a6,a3,8020074a <vprintfmt+0x114>
                ch = *fmt;
    80200726:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    8020072a:	002c169b          	slliw	a3,s8,0x2
    8020072e:	0186873b          	addw	a4,a3,s8
    80200732:	0017171b          	slliw	a4,a4,0x1
    80200736:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200738:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020073c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020073e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200742:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200746:	fed870e3          	bgeu	a6,a3,80200726 <vprintfmt+0xf0>
            if (width < 0)
    8020074a:	f40ddce3          	bgez	s11,802006a2 <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020074e:	8de2                	mv	s11,s8
    80200750:	5c7d                	li	s8,-1
    80200752:	bf81                	j	802006a2 <vprintfmt+0x6c>
            if (width < 0)
    80200754:	fffdc693          	not	a3,s11
    80200758:	96fd                	srai	a3,a3,0x3f
    8020075a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020075e:	00144603          	lbu	a2,1(s0)
    80200762:	2d81                	sext.w	s11,s11
    80200764:	846a                	mv	s0,s10
            goto reswitch;
    80200766:	bf35                	j	802006a2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200768:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020076c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200770:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200772:	846a                	mv	s0,s10
            goto process_precision;
    80200774:	bfd9                	j	8020074a <vprintfmt+0x114>
    if (lflag >= 2) {
    80200776:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200778:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020077c:	01174463          	blt	a4,a7,80200784 <vprintfmt+0x14e>
    else if (lflag) {
    80200780:	1a088e63          	beqz	a7,8020093c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200784:	000a3603          	ld	a2,0(s4)
    80200788:	46c1                	li	a3,16
    8020078a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    8020078c:	2781                	sext.w	a5,a5
    8020078e:	876e                	mv	a4,s11
    80200790:	85a6                	mv	a1,s1
    80200792:	854a                	mv	a0,s2
    80200794:	e37ff0ef          	jal	ra,802005ca <printnum>
            break;
    80200798:	bde1                	j	80200670 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    8020079a:	000a2503          	lw	a0,0(s4)
    8020079e:	85a6                	mv	a1,s1
    802007a0:	0a21                	addi	s4,s4,8
    802007a2:	9902                	jalr	s2
            break;
    802007a4:	b5f1                	j	80200670 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007ac:	01174463          	blt	a4,a7,802007b4 <vprintfmt+0x17e>
    else if (lflag) {
    802007b0:	18088163          	beqz	a7,80200932 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007b4:	000a3603          	ld	a2,0(s4)
    802007b8:	46a9                	li	a3,10
    802007ba:	8a2e                	mv	s4,a1
    802007bc:	bfc1                	j	8020078c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007be:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007c2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007c4:	846a                	mv	s0,s10
            goto reswitch;
    802007c6:	bdf1                	j	802006a2 <vprintfmt+0x6c>
            putch(ch, putdat);
    802007c8:	85a6                	mv	a1,s1
    802007ca:	02500513          	li	a0,37
    802007ce:	9902                	jalr	s2
            break;
    802007d0:	b545                	j	80200670 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007d2:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007d6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007d8:	846a                	mv	s0,s10
            goto reswitch;
    802007da:	b5e1                	j	802006a2 <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007de:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007e2:	01174463          	blt	a4,a7,802007ea <vprintfmt+0x1b4>
    else if (lflag) {
    802007e6:	14088163          	beqz	a7,80200928 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007ea:	000a3603          	ld	a2,0(s4)
    802007ee:	46a1                	li	a3,8
    802007f0:	8a2e                	mv	s4,a1
    802007f2:	bf69                	j	8020078c <vprintfmt+0x156>
            putch('0', putdat);
    802007f4:	03000513          	li	a0,48
    802007f8:	85a6                	mv	a1,s1
    802007fa:	e03e                	sd	a5,0(sp)
    802007fc:	9902                	jalr	s2
            putch('x', putdat);
    802007fe:	85a6                	mv	a1,s1
    80200800:	07800513          	li	a0,120
    80200804:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200806:	0a21                	addi	s4,s4,8
            goto number;
    80200808:	6782                	ld	a5,0(sp)
    8020080a:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020080c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200810:	bfb5                	j	8020078c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200812:	000a3403          	ld	s0,0(s4)
    80200816:	008a0713          	addi	a4,s4,8
    8020081a:	e03a                	sd	a4,0(sp)
    8020081c:	14040263          	beqz	s0,80200960 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200820:	0fb05763          	blez	s11,8020090e <vprintfmt+0x2d8>
    80200824:	02d00693          	li	a3,45
    80200828:	0cd79163          	bne	a5,a3,802008ea <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020082c:	00044783          	lbu	a5,0(s0)
    80200830:	0007851b          	sext.w	a0,a5
    80200834:	cf85                	beqz	a5,8020086c <vprintfmt+0x236>
    80200836:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020083a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020083e:	000c4563          	bltz	s8,80200848 <vprintfmt+0x212>
    80200842:	3c7d                	addiw	s8,s8,-1
    80200844:	036c0263          	beq	s8,s6,80200868 <vprintfmt+0x232>
                    putch('?', putdat);
    80200848:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020084a:	0e0c8e63          	beqz	s9,80200946 <vprintfmt+0x310>
    8020084e:	3781                	addiw	a5,a5,-32
    80200850:	0ef47b63          	bgeu	s0,a5,80200946 <vprintfmt+0x310>
                    putch('?', putdat);
    80200854:	03f00513          	li	a0,63
    80200858:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020085a:	000a4783          	lbu	a5,0(s4)
    8020085e:	3dfd                	addiw	s11,s11,-1
    80200860:	0a05                	addi	s4,s4,1
    80200862:	0007851b          	sext.w	a0,a5
    80200866:	ffe1                	bnez	a5,8020083e <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200868:	01b05963          	blez	s11,8020087a <vprintfmt+0x244>
    8020086c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020086e:	85a6                	mv	a1,s1
    80200870:	02000513          	li	a0,32
    80200874:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200876:	fe0d9be3          	bnez	s11,8020086c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020087a:	6a02                	ld	s4,0(sp)
    8020087c:	bbd5                	j	80200670 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020087e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200880:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200884:	01174463          	blt	a4,a7,8020088c <vprintfmt+0x256>
    else if (lflag) {
    80200888:	08088d63          	beqz	a7,80200922 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    8020088c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200890:	0a044d63          	bltz	s0,8020094a <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200894:	8622                	mv	a2,s0
    80200896:	8a66                	mv	s4,s9
    80200898:	46a9                	li	a3,10
    8020089a:	bdcd                	j	8020078c <vprintfmt+0x156>
            err = va_arg(ap, int);
    8020089c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008a0:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008a2:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008a4:	41f7d69b          	sraiw	a3,a5,0x1f
    802008a8:	8fb5                	xor	a5,a5,a3
    802008aa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008ae:	02d74163          	blt	a4,a3,802008d0 <vprintfmt+0x29a>
    802008b2:	00369793          	slli	a5,a3,0x3
    802008b6:	97de                	add	a5,a5,s7
    802008b8:	639c                	ld	a5,0(a5)
    802008ba:	cb99                	beqz	a5,802008d0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008bc:	86be                	mv	a3,a5
    802008be:	00000617          	auipc	a2,0x0
    802008c2:	7aa60613          	addi	a2,a2,1962 # 80201068 <etext+0x634>
    802008c6:	85a6                	mv	a1,s1
    802008c8:	854a                	mv	a0,s2
    802008ca:	0ce000ef          	jal	ra,80200998 <printfmt>
    802008ce:	b34d                	j	80200670 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008d0:	00000617          	auipc	a2,0x0
    802008d4:	78860613          	addi	a2,a2,1928 # 80201058 <etext+0x624>
    802008d8:	85a6                	mv	a1,s1
    802008da:	854a                	mv	a0,s2
    802008dc:	0bc000ef          	jal	ra,80200998 <printfmt>
    802008e0:	bb41                	j	80200670 <vprintfmt+0x3a>
                p = "(null)";
    802008e2:	00000417          	auipc	s0,0x0
    802008e6:	76e40413          	addi	s0,s0,1902 # 80201050 <etext+0x61c>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008ea:	85e2                	mv	a1,s8
    802008ec:	8522                	mv	a0,s0
    802008ee:	e43e                	sd	a5,8(sp)
    802008f0:	116000ef          	jal	ra,80200a06 <strnlen>
    802008f4:	40ad8dbb          	subw	s11,s11,a0
    802008f8:	01b05b63          	blez	s11,8020090e <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802008fc:	67a2                	ld	a5,8(sp)
    802008fe:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200902:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200904:	85a6                	mv	a1,s1
    80200906:	8552                	mv	a0,s4
    80200908:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020090a:	fe0d9ce3          	bnez	s11,80200902 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020090e:	00044783          	lbu	a5,0(s0)
    80200912:	00140a13          	addi	s4,s0,1
    80200916:	0007851b          	sext.w	a0,a5
    8020091a:	d3a5                	beqz	a5,8020087a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    8020091c:	05e00413          	li	s0,94
    80200920:	bf39                	j	8020083e <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200922:	000a2403          	lw	s0,0(s4)
    80200926:	b7ad                	j	80200890 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200928:	000a6603          	lwu	a2,0(s4)
    8020092c:	46a1                	li	a3,8
    8020092e:	8a2e                	mv	s4,a1
    80200930:	bdb1                	j	8020078c <vprintfmt+0x156>
    80200932:	000a6603          	lwu	a2,0(s4)
    80200936:	46a9                	li	a3,10
    80200938:	8a2e                	mv	s4,a1
    8020093a:	bd89                	j	8020078c <vprintfmt+0x156>
    8020093c:	000a6603          	lwu	a2,0(s4)
    80200940:	46c1                	li	a3,16
    80200942:	8a2e                	mv	s4,a1
    80200944:	b5a1                	j	8020078c <vprintfmt+0x156>
                    putch(ch, putdat);
    80200946:	9902                	jalr	s2
    80200948:	bf09                	j	8020085a <vprintfmt+0x224>
                putch('-', putdat);
    8020094a:	85a6                	mv	a1,s1
    8020094c:	02d00513          	li	a0,45
    80200950:	e03e                	sd	a5,0(sp)
    80200952:	9902                	jalr	s2
                num = -(long long)num;
    80200954:	6782                	ld	a5,0(sp)
    80200956:	8a66                	mv	s4,s9
    80200958:	40800633          	neg	a2,s0
    8020095c:	46a9                	li	a3,10
    8020095e:	b53d                	j	8020078c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200960:	03b05163          	blez	s11,80200982 <vprintfmt+0x34c>
    80200964:	02d00693          	li	a3,45
    80200968:	f6d79de3          	bne	a5,a3,802008e2 <vprintfmt+0x2ac>
                p = "(null)";
    8020096c:	00000417          	auipc	s0,0x0
    80200970:	6e440413          	addi	s0,s0,1764 # 80201050 <etext+0x61c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200974:	02800793          	li	a5,40
    80200978:	02800513          	li	a0,40
    8020097c:	00140a13          	addi	s4,s0,1
    80200980:	bd6d                	j	8020083a <vprintfmt+0x204>
    80200982:	00000a17          	auipc	s4,0x0
    80200986:	6cfa0a13          	addi	s4,s4,1743 # 80201051 <etext+0x61d>
    8020098a:	02800513          	li	a0,40
    8020098e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200992:	05e00413          	li	s0,94
    80200996:	b565                	j	8020083e <vprintfmt+0x208>

0000000080200998 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200998:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    8020099a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020099e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a2:	ec06                	sd	ra,24(sp)
    802009a4:	f83a                	sd	a4,48(sp)
    802009a6:	fc3e                	sd	a5,56(sp)
    802009a8:	e0c2                	sd	a6,64(sp)
    802009aa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ac:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ae:	c89ff0ef          	jal	ra,80200636 <vprintfmt>
}
    802009b2:	60e2                	ld	ra,24(sp)
    802009b4:	6161                	addi	sp,sp,80
    802009b6:	8082                	ret

00000000802009b8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009b8:	4781                	li	a5,0
    802009ba:	00003717          	auipc	a4,0x3
    802009be:	64673703          	ld	a4,1606(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009c2:	88ba                	mv	a7,a4
    802009c4:	852a                	mv	a0,a0
    802009c6:	85be                	mv	a1,a5
    802009c8:	863e                	mv	a2,a5
    802009ca:	00000073          	ecall
    802009ce:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009d0:	8082                	ret

00000000802009d2 <sbi_set_timer>:
    __asm__ volatile (
    802009d2:	4781                	li	a5,0
    802009d4:	00003717          	auipc	a4,0x3
    802009d8:	64c73703          	ld	a4,1612(a4) # 80204020 <SBI_SET_TIMER>
    802009dc:	88ba                	mv	a7,a4
    802009de:	852a                	mv	a0,a0
    802009e0:	85be                	mv	a1,a5
    802009e2:	863e                	mv	a2,a5
    802009e4:	00000073          	ecall
    802009e8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009ea:	8082                	ret

00000000802009ec <sbi_shutdown>:
    __asm__ volatile (
    802009ec:	4781                	li	a5,0
    802009ee:	00003717          	auipc	a4,0x3
    802009f2:	61a73703          	ld	a4,1562(a4) # 80204008 <SBI_SHUTDOWN>
    802009f6:	88ba                	mv	a7,a4
    802009f8:	853e                	mv	a0,a5
    802009fa:	85be                	mv	a1,a5
    802009fc:	863e                	mv	a2,a5
    802009fe:	00000073          	ecall
    80200a02:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a04:	8082                	ret

0000000080200a06 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200a06:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200a08:	e589                	bnez	a1,80200a12 <strnlen+0xc>
    80200a0a:	a811                	j	80200a1e <strnlen+0x18>
        cnt ++;
    80200a0c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a0e:	00f58863          	beq	a1,a5,80200a1e <strnlen+0x18>
    80200a12:	00f50733          	add	a4,a0,a5
    80200a16:	00074703          	lbu	a4,0(a4)
    80200a1a:	fb6d                	bnez	a4,80200a0c <strnlen+0x6>
    80200a1c:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a1e:	852e                	mv	a0,a1
    80200a20:	8082                	ret

0000000080200a22 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a22:	ca01                	beqz	a2,80200a32 <memset+0x10>
    80200a24:	962a                	add	a2,a2,a0
    char *p = s;
    80200a26:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a28:	0785                	addi	a5,a5,1
    80200a2a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a2e:	fec79de3          	bne	a5,a2,80200a28 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a32:	8082                	ret
