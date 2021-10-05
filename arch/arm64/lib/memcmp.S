/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (c) 2013-2021, Arm Limited.
 *
 * Adapted from the original at:
 * https://github.com/ARM-software/optimized-routines/blob/e823e3abf5f89ecb/string/aarch64/memcmp.S
 */

#include <linux/linkage.h>
#include <asm/assembler.h>

/* Assumptions:
 *
 * ARMv8-a, AArch64, unaligned accesses.
 */

#define L(label) .L ## label

/* Parameters and result.  */
#define src1		x0
#define src2		x1
#define limit		x2
#define result		w0

/* Internal variables.  */
#define data1		x3
#define data1w		w3
#define data1h		x4
#define data2		x5
#define data2w		w5
#define data2h		x6
#define tmp1		x7
#define tmp2		x8

SYM_FUNC_START_WEAK_PI(memcmp)
	subs	limit, limit, 8
	b.lo	L(less8)
	ldr	data1, [src1], 8
	ldr	data2, [src2], 8
	cmp	data1, data2
	b.ne	L(return)

	subs	limit, limit, 8
	b.gt	L(more16)

	ldr	data1, [src1, limit]
	ldr	data2, [src2, limit]
	b	L(return)

L(more16):
	ldr	data1, [src1], 8
	ldr	data2, [src2], 8
	cmp	data1, data2
	bne	L(return)

	/* Jump directly to comparing the last 16 bytes for 32 byte (or less)
	   strings.  */
	subs	limit, limit, 16
	b.ls	L(last_bytes)

	/* We overlap loads between 0-32 bytes at either side of SRC1 when we
	   try to align, so limit it only to strings larger than 128 bytes.  */
	cmp	limit, 96
	b.ls	L(loop16)

	/* Align src1 and adjust src2 with bytes not yet done.  */
	and	tmp1, src1, 15
	add	limit, limit, tmp1
	sub	src1, src1, tmp1
	sub	src2, src2, tmp1

	/* Loop performing 16 bytes per iteration using aligned src1.
	   Limit is pre-decremented by 16 and must be larger than zero.
	   Exit if <= 16 bytes left to do or if the data is not equal.  */
	.p2align 4
L(loop16):
	ldp	data1, data1h, [src1], 16
	ldp	data2, data2h, [src2], 16
	subs	limit, limit, 16
	ccmp	data1, data2, 0, hi
	ccmp	data1h, data2h, 0, eq
	b.eq	L(loop16)

	cmp	data1, data2
	bne	L(return)
	mov	data1, data1h
	mov	data2, data2h
	cmp	data1, data2
	bne	L(return)

	/* Compare last 1-16 bytes using unaligned access.  */
L(last_bytes):
	add	src1, src1, limit
	add	src2, src2, limit
	ldp	data1, data1h, [src1]
	ldp	data2, data2h, [src2]
	cmp	data1, data2
	bne	L(return)
	mov	data1, data1h
	mov	data2, data2h
	cmp	data1, data2

	/* Compare data bytes and set return value to 0, -1 or 1.  */
L(return):
#ifndef __AARCH64EB__
	rev	data1, data1
	rev	data2, data2
#endif
	cmp	data1, data2
L(ret_eq):
	cset	result, ne
	cneg	result, result, lo
	ret

	.p2align 4
	/* Compare up to 8 bytes.  Limit is [-8..-1].  */
L(less8):
	adds	limit, limit, 4
	b.lo	L(less4)
	ldr	data1w, [src1], 4
	ldr	data2w, [src2], 4
	cmp	data1w, data2w
	b.ne	L(return)
	sub	limit, limit, 4
L(less4):
	adds	limit, limit, 4
	beq	L(ret_eq)
L(byte_loop):
	ldrb	data1w, [src1], 1
	ldrb	data2w, [src2], 1
	subs	limit, limit, 1
	ccmp	data1w, data2w, 0, ne	/* NZCV = 0b0000.  */
	b.eq	L(byte_loop)
	sub	result, data1w, data2w
	ret

<<<<<<< HEAD
.Lstart_align:
	lsr	limit_wd, limit, #3
	cbz	limit_wd, .Lremain8

	ands	xzr, src1, #7
	b.eq	.Lrecal_offset
	/*process more leading bytes to make src1 aligned...*/
	add	src1, src1, tmp3 /*backwards src1 to alignment boundary*/
	add	src2, src2, tmp3
	sub	limit, limit, tmp3
	lsr	limit_wd, limit, #3
	cbz	limit_wd, .Lremain8
	/*load 8 bytes from aligned SRC1..*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8

	subs	limit_wd, limit_wd, #1
	eor	diff, data1, data2  /*Non-zero if differences found.*/
	csinv	endloop, diff, xzr, ne
	cbnz	endloop, .Lunequal_proc
	/*How far is the current SRC2 from the alignment boundary...*/
	and	tmp3, tmp3, #7

.Lrecal_offset:/*src1 is aligned now..*/
	neg	pos, tmp3
.Lloopcmp_proc:
	/*
	* Divide the eight bytes into two parts. First,backwards the src2
	* to an alignment boundary,load eight bytes and compare from
	* the SRC2 alignment boundary. If all 8 bytes are equal,then start
	* the second part's comparison. Otherwise finish the comparison.
	* This special handle can garantee all the accesses are in the
	* thread/task space in avoid to overrange access.
	*/
	ldr	data1, [src1,pos]
	ldr	data2, [src2,pos]
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	cbnz	diff, .Lnot_limit

	/*The second part process*/
	ldr	data1, [src1], #8
	ldr	data2, [src2], #8
	eor	diff, data1, data2  /* Non-zero if differences found.  */
	subs	limit_wd, limit_wd, #1
	csinv	endloop, diff, xzr, ne/*if limit_wd is 0,will finish the cmp*/
	cbz	endloop, .Lloopcmp_proc
.Lunequal_proc:
	cbz	diff, .Lremain8

/* There is difference occurred in the latest comparison. */
.Lnot_limit:
/*
* For little endian,reverse the low significant equal bits into MSB,then
* following CLZ can find how many equal bits exist.
*/
CPU_LE( rev	diff, diff )
CPU_LE( rev	data1, data1 )
CPU_LE( rev	data2, data2 )

	/*
	* The MS-non-zero bit of DIFF marks either the first bit
	* that is different, or the end of the significant data.
	* Shifting left now will bring the critical information into the
	* top bits.
	*/
	clz	pos, diff
	lsl	data1, data1, pos
	lsl	data2, data2, pos
	/*
	* We need to zero-extend (char is unsigned) the value and then
	* perform a signed subtraction.
	*/
	lsr	data1, data1, #56
	sub	result, data1, data2, lsr #56
	ret

.Lremain8:
	/* Limit % 8 == 0 =>. all data are equal.*/
	ands	limit, limit, #7
	b.eq	.Lret0

.Ltiny8proc:
	ldrb	data1w, [src1], #1
	ldrb	data2w, [src2], #1
	subs	limit, limit, #1

	ccmp	data1w, data2w, #0, ne  /* NZCV = 0b0000. */
	b.eq	.Ltiny8proc
	sub	result, data1, data2
	ret
.Lret0:
	mov	result, #0
	ret
ENDPIPROC(memcmp)
=======
SYM_FUNC_END_PI(memcmp)
>>>>>>> a8a4adb42f59 (arm64: Import latest version of Cortex Strings' memcmp)
