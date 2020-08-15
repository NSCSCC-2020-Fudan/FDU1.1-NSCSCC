
cache.o:     file format elf32-tradlittlemips


Disassembly of section .text:

00000000 <_start>:
   0:	3c1d8fc0 	lui	sp,0x8fc0
   4:	37bd8000 	ori	sp,sp,0x8000
   8:	3c108fc0 	lui	s0,0x8fc0
   c:	36104000 	ori	s0,s0,0x4000
  10:	3c11bfc0 	lui	s1,0xbfc0
  14:	36314000 	ori	s1,s1,0x4000
  18:	3c121926 	lui	s2,0x1926
  1c:	36520817 	ori	s2,s2,0x817
  20:	3c138fc0 	lui	s3,0x8fc0
  24:	10000076 	b	200 <main>
  28:	36732000 	ori	s3,s3,0x2000

0000002c <memset>:
  2c:	00104021 	addu	t0,zero,s0
  30:	25090200 	addiu	t1,t0,512

00000034 <loop>:
  34:	ad120000 	sw	s2,0(t0)
  38:	0109502a 	slt	t2,t0,t1
  3c:	1540fffd 	bnez	t2,34 <loop>
  40:	25080004 	addiu	t0,t0,4
  44:	03e00008 	jr	ra
  48:	00000000 	nop

0000004c <store_tag>:
  4c:	00002825 	move	a1,zero
  50:	00001025 	move	v0,zero
  54:	00002025 	move	a0,zero

00000058 <AHA3>:
  58:	34038000 	li	v1,0x8000
  5c:	00a3582a 	slt	t3,a1,v1
  60:	11600008 	beqz	t3,84 <AHA4>
  64:	00851821 	addu	v1,a0,a1
  68:	00431021 	addu	v0,v0,v1
  6c:	24a50040 	addiu	a1,a1,64
  70:	3c0fa000 	lui	t7,0xa000
  74:	bde90000 	cache	0x9,0(t7)
  78:	bde80000 	cache	0x8,0(t7)
  7c:	1000fff6 	b	58 <AHA3>
  80:	01e37821 	addu	t7,t7,v1

00000084 <AHA4>:
  84:	03e00008 	jr	ra
  88:	00000000 	nop

0000008c <index_writeback>:
  8c:	00002825 	move	a1,zero
  90:	00001025 	move	v0,zero
  94:	00002025 	move	a0,zero

00000098 <AHA7>:
  98:	34038000 	li	v1,0x8000
  9c:	00a3582a 	slt	t3,a1,v1
  a0:	11600008 	beqz	t3,c4 <AHA8>
  a4:	00851821 	addu	v1,a0,a1
  a8:	3c0fa000 	lui	t7,0xa000
  ac:	01e37821 	addu	t7,t7,v1
  b0:	bde00000 	cache	0x0,0(t7)
  b4:	00431021 	addu	v0,v0,v1
  b8:	bde10000 	cache	0x1,0(t7)
  bc:	1000fff6 	b	98 <AHA7>
  c0:	24a50040 	addiu	a1,a1,64

000000c4 <AHA8>:
  c4:	03e00008 	jr	ra
  c8:	00000000 	nop

000000cc <sheetcpy>:
  cc:	00001821 	move	v1,zero

000000d0 <AHA11>:
  d0:	286a0040 	slti	t2,v1,64
  d4:	11400007 	beqz	t2,f4 <AHA12>
  d8:	00031080 	sll	v0,v1,0x2
  dc:	00a23021 	addu	a2,a1,v0
  e0:	00821021 	addu	v0,a0,v0
  e4:	24630001 	addiu	v1,v1,1
  e8:	8c420000 	lw	v0,0(v0)
  ec:	1000fff8 	b	d0 <AHA11>
  f0:	acc20000 	sw	v0,0(a2)

000000f4 <AHA12>:
  f4:	03e00008 	jr	ra
  f8:	00000000 	nop

000000fc <hit_invalidate>:
  fc:	00001021 	move	v0,zero
 100:	00132021 	addu	a0,zero,s3

00000104 <AHA15>:
 104:	284b0040 	slti	t3,v0,64
 108:	11600007 	beqz	t3,128 <AHA16>
 10c:	00021880 	sll	v1,v0,0x2
 110:	00831821 	addu	v1,a0,v1
 114:	24050123 	li	a1,291
 118:	bc700000 	cache	0x10,0(v1)
 11c:	bc750000 	cache	0x15,0(v1)
 120:	1000fff8 	b	104 <AHA15>
 124:	24420001 	addiu	v0,v0,1

00000128 <AHA16>:
 128:	03e00008 	jr	ra
 12c:	00000000 	nop

00000130 <test1>:
 130:	00001021 	move	v0,zero
 134:	00001821 	move	v1,zero

00000138 <AHA19>:
 138:	28440064 	slti	a0,v0,100
 13c:	10800005 	beqz	a0,154 <AHA18>
 140:	00420018 	mult	v0,v0
 144:	00002012 	mflo	a0
 148:	00641821 	addu	v1,v1,a0
 14c:	1000fffa 	b	138 <AHA19>
 150:	24420001 	addiu	v0,v0,1

00000154 <AHA18>:
 154:	00031080 	sll	v0,v1,0x2
 158:	00031900 	sll	v1,v1,0x4
 15c:	00431821 	addu	v1,v0,v1
 160:	00031080 	sll	v0,v1,0x2
 164:	03e00008 	jr	ra
 168:	00621021 	addu	v0,v1,v0

0000016c <test2>:
 16c:	00001821 	move	v1,zero
 170:	00001021 	move	v0,zero
 174:	24050001 	li	a1,1
 178:	00002021 	move	a0,zero

0000017c <AHA22>:
 17c:	286e0080 	slti	t6,v1,128
 180:	11c00006 	beqz	t6,19c <AHA23>
 184:	00853021 	addu	a2,a0,a1
 188:	00441021 	addu	v0,v0,a0
 18c:	24a40001 	addiu	a0,a1,1
 190:	24630001 	addiu	v1,v1,1
 194:	1000fff9 	b	17c <AHA22>
 198:	00c02821 	move	a1,a2

0000019c <AHA23>:
 19c:	03e00008 	jr	ra
 1a0:	00000000 	nop

000001a4 <test3>:
 1a4:	24030001 	li	v1,1
 1a8:	00001021 	move	v0,zero

000001ac <AHA27>:
 1ac:	286c2401 	slti	t4,v1,9217
 1b0:	11800011 	beqz	t4,1f8 <AHA28>
 1b4:	24042400 	li	a0,9216
 1b8:	14600002 	bnez	v1,1c4 <safe1>
 1bc:	0083001a 	div	zero,a0,v1
 1c0:	0007000d 	break	0x7

000001c4 <safe1>:
 1c4:	00002010 	mfhi	a0
 1c8:	00640018 	mult	v1,a0
 1cc:	00002812 	mflo	a1
 1d0:	1c800007 	bgtz	a0,1f0 <AHA26>
 1d4:	00451021 	addu	v0,v0,a1
 1d8:	24042400 	li	a0,9216
 1dc:	14600002 	bnez	v1,1e8 <safe2>
 1e0:	0083001a 	div	zero,a0,v1
 1e4:	0007000d 	break	0x7

000001e8 <safe2>:
 1e8:	00002012 	mflo	a0
 1ec:	00441021 	addu	v0,v0,a0

000001f0 <AHA26>:
 1f0:	1000ffee 	b	1ac <AHA27>
 1f4:	24630001 	addiu	v1,v1,1

000001f8 <AHA28>:
 1f8:	03e00008 	jr	ra
 1fc:	00000000 	nop

00000200 <main>:
 200:	0411ff8a 	bal	2c <memset>
 204:	00000000 	nop
 208:	8e080000 	lw	t0,0(s0)
 20c:	8e280000 	lw	t0,0(s1)
 210:	8e080030 	lw	t0,48(s0)
 214:	8e280030 	lw	t0,48(s1)
 218:	2408001d 	li	t0,29
 21c:	40804000 	mtc0	zero,c0_badvaddr
 220:	10000001 	b	228 <treap>
 224:	40804002 	mtc0	zero,$8,2

00000228 <treap>:
 228:	2408001c 	li	t0,28
 22c:	40804000 	mtc0	zero,c0_badvaddr
 230:	0411ff86 	bal	4c <store_tag>
 234:	40804002 	mtc0	zero,$8,2
 238:	8e080000 	lw	t0,0(s0)
 23c:	8e280000 	lw	t0,0(s1)
 240:	8e080030 	lw	t0,48(s0)
 244:	0411ff79 	bal	2c <memset>
 248:	8e280030 	lw	t0,48(s1)
 24c:	8e080000 	lw	t0,0(s0)
 250:	8e280000 	lw	t0,0(s1)
 254:	8e080030 	lw	t0,48(s0)
 258:	0411ff8c 	bal	8c <index_writeback>
 25c:	8e280030 	lw	t0,48(s1)
 260:	8e280000 	lw	t0,0(s1)
 264:	8e280030 	lw	t0,48(s1)
 268:	8e080000 	lw	t0,0(s0)
 26c:	8e080030 	lw	t0,48(s0)
 270:	3c048fc0 	lui	a0,0x8fc0
 274:	34840130 	ori	a0,a0,0x130
 278:	0411ff94 	bal	cc <sheetcpy>
 27c:	00132821 	addu	a1,zero,s3
 280:	0411ff9e 	bal	fc <hit_invalidate>
 284:	00000000 	nop
 288:	0260f809 	jalr	s3
 28c:	00000000 	nop
 290:	00404021 	move	t0,v0
 294:	3c048fc0 	lui	a0,0x8fc0
 298:	3484016c 	ori	a0,a0,0x16c
 29c:	0411ff8b 	bal	cc <sheetcpy>
 2a0:	00132821 	addu	a1,zero,s3
 2a4:	0411ff95 	bal	fc <hit_invalidate>
 2a8:	00000000 	nop
 2ac:	0260f809 	jalr	s3
 2b0:	00000000 	nop
 2b4:	00024021 	addu	t0,zero,v0
 2b8:	3c048fc0 	lui	a0,0x8fc0
 2bc:	348401a4 	ori	a0,a0,0x1a4
 2c0:	0411ff82 	bal	cc <sheetcpy>
 2c4:	00132821 	addu	a1,zero,s3
 2c8:	0411ff8c 	bal	fc <hit_invalidate>
 2cc:	00000000 	nop
 2d0:	0260f809 	jalr	s3
 2d4:	00000000 	nop
 2d8:	00404021 	move	t0,v0
 2dc:	3c048fc0 	lui	a0,0x8fc0
 2e0:	34840130 	ori	a0,a0,0x130
 2e4:	0411ff79 	bal	cc <sheetcpy>
 2e8:	00132821 	addu	a1,zero,s3
 2ec:	0411ff83 	bal	fc <hit_invalidate>
 2f0:	00000000 	nop
 2f4:	0260f809 	jalr	s3
 2f8:	00000000 	nop
 2fc:	00404021 	move	t0,v0
 300:	3c048fc0 	lui	a0,0x8fc0
 304:	3484016c 	ori	a0,a0,0x16c
 308:	0411ff70 	bal	cc <sheetcpy>
 30c:	00132821 	addu	a1,zero,s3
 310:	0411ff7a 	bal	fc <hit_invalidate>
 314:	00000000 	nop
 318:	0260f809 	jalr	s3
 31c:	00000000 	nop
 320:	00024021 	addu	t0,zero,v0
 324:	3c048fc0 	lui	a0,0x8fc0
 328:	348401a4 	ori	a0,a0,0x1a4
 32c:	0411ff67 	bal	cc <sheetcpy>
 330:	00132821 	addu	a1,zero,s3
 334:	0411ff71 	bal	fc <hit_invalidate>
 338:	00000000 	nop
 33c:	0260f809 	jalr	s3
 340:	00000000 	nop
 344:	00404021 	move	t0,v0
 348:	3c048fc0 	lui	a0,0x8fc0
 34c:	3484016c 	ori	a0,a0,0x16c
 350:	0411ff5e 	bal	cc <sheetcpy>
 354:	00132821 	addu	a1,zero,s3
 358:	0411ff68 	bal	fc <hit_invalidate>
 35c:	00000000 	nop
 360:	0260f809 	jalr	s3
 364:	00000000 	nop
 368:	00024021 	addu	t0,zero,v0
 36c:	3c048fc0 	lui	a0,0x8fc0
 370:	34840130 	ori	a0,a0,0x130
 374:	0411ff55 	bal	cc <sheetcpy>
 378:	00132821 	addu	a1,zero,s3
 37c:	0411ff5f 	bal	fc <hit_invalidate>
 380:	00000000 	nop
 384:	0260f809 	jalr	s3
 388:	00000000 	nop
 38c:	00404021 	move	t0,v0
 390:	3c048fc0 	lui	a0,0x8fc0
 394:	348401a4 	ori	a0,a0,0x1a4
 398:	0411ff4c 	bal	cc <sheetcpy>
 39c:	00132821 	addu	a1,zero,s3
 3a0:	0411ff56 	bal	fc <hit_invalidate>
 3a4:	00000000 	nop
 3a8:	0260f809 	jalr	s3
 3ac:	00000000 	nop
 3b0:	00404021 	move	t0,v0
 3b4:	3c080100 	lui	t0,0x100
 3b8:	24087bcd 	li	t0,31693
 3bc:	00004021 	move	t0,zero
 3c0:	00004021 	move	t0,zero
 3c4:	3c08a000 	lui	t0,0xa000
 3c8:	00004021 	move	t0,zero
 3cc:	240b0001 	li	t3,1
 3d0:	016b6021 	addu	t4,t3,t3

000003d4 <over>:
 3d4:	1000ffff 	b	3d4 <over>
 3d8:	00000000 	nop
 3dc:	00000000 	nop
