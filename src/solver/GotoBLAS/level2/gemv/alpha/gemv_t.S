/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2005. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"

#ifdef EV6
#ifdef DOUBLE
#define Q  	240    /* 8kB */
#else
#define Q	480
#endif
#endif

#ifdef EV5
#ifdef DOUBLE
#define Q	240    /* 8kB */
#else
#define Q	480
#endif
#endif

#ifdef EV4
#ifdef DOUBLE
#define Q	240    /* 8kB */
#else
#define Q	480
#endif
#endif

/* 
                        Register Map 
Integer:
 $0 : i		 $1 : temp	 $2 : aoffset1	 $3 : xoffset
 $4 : ---	 $5 : aoffset3	 $6 : aoffset2	 $7 : aoffset4
 $8 : yoffset	 $9 : ---	 $10: ---	 $11: ---
 $12: ---	 $13: ---	 $14: ---	 $15: ---
 $16: m		 $17: n		 $18: y		 $19: a
 $20: lda	 $21: x		 $22: incx	 $23: incy
 $24: j 	 $25: min_j	 $26: ---	 $27: js
 $28: aoffset	 $29: ---	 $30: SP	 $31: Zero
*/

	.set noat
	.set noreorder

.text
	.align 5
	.globl CNAME
	.ent CNAME
CNAME:
	.frame $sp, 80, $26, 0

#ifdef PROFILE
	ldgp	$gp, 0($27)
	lda	$28, _mcount
	jsr	$28, ($28), _mcount
#endif

	ldq	$19,    0($sp)
	ldl	$22,    8($sp)		# incx
	ldq	$18,   16($sp)		# y
	ldl	$23,   24($sp)		# incy

	ldq	$27,   32($sp)		# buffer
	cmpeq	$22, 1, $0		# if (incx == 1)
	lda	$sp,  -80($sp)
	cmovne	$0,  0, $22		#    then incx = 0

	stt	$f2,    0($sp)
	cmple	$16, 0, $2
	stt	$f3,    8($sp)
	cmple	$17, 0, $3

	stt	$f4,   16($sp)
	or	$2, $3, $2
	stt	$f5,   24($sp)
	stt	$f6,   32($sp)

	stt	$f7,   40($sp)
	stt	$f8,   48($sp)
	stt	$f9,   56($sp)
	stq	$26,   64($sp)
	clr	$26			# js = 0
#ifndef PROFILE
	.prologue	0
#else
	.prologue	1
#endif

	bne	$2,  $End
	.align 4

$L6:
	lda	$0,    Q
	subl	$16, $26, $25		# min_j = n - js
	cmple	$25, $0,  $1
	cmoveq	$1,  $0,  $25

	SXADDQ	$26, $20, $28		# aoffset = a + js
	mov	$18,  $8		# yoffset = y

	beq	$22, $CopySkip
	mulq	$26, $22, $2		# $0 = incx * js
	SXADDQ	$2,  $19, $2		# $0 = x + incx * js
	mov	$27, $5

	sra	$25, 3, $24
	ble	$24, $LoopSkip1
	.align 4

$Loop:
	LD	$f20, 0($2)
	SXADDQ	$22, $2, $2
	LD	$f21, 0($2)
	SXADDQ	$22, $2, $2

	LD	$f22, 0($2)
	SXADDQ	$22, $2, $2
	LD	$f23, 0($2)
	SXADDQ	$22, $2, $2

	LD	$f24, 0($2)
	SXADDQ	$22, $2, $2
	LD	$f25, 0($2)
	SXADDQ	$22, $2, $2

	LD	$f26, 0($2)
	SXADDQ	$22, $2, $2
	LD	$f27, 0($2)
	SXADDQ	$22, $2, $2

	ST	$f20, 0*SIZE($5)
	ST	$f21, 1*SIZE($5)
	ST	$f22, 2*SIZE($5)
	ST	$f23, 3*SIZE($5)
	ST	$f24, 4*SIZE($5)
	ST	$f25, 5*SIZE($5)
	ST	$f26, 6*SIZE($5)
	ST	$f27, 7*SIZE($5)
	lda	$24,  -1($24)
	lda	$5,   8*SIZE($5)
	bgt	$24, $Loop
	.align 4

$LoopSkip1:
	and	$25, 7, $24
	ble	$24, $CopySkip
	.align 4

$Loop2:
	LD	$f16, 0($2)
	SXADDQ	$22, $2, $2
	lda	$24,  -1($24)
	ST	$f16, 0($5)
	lda	$5,  SIZE($5)
	bgt	$24, $Loop2
	.align 4

$CopySkip:
	sra	$17,   2, $0		# i = (m >> 2)
	ble	$0,  $L8
	.align 4

$L24:
	mov	$28, $2			# aoffset1 = aoffset
	fclr	$f24
	SXADDQ	$21, $28, $6		# aoffset2 = aoffset  + lda
	fclr	$f13

	sra	$25,   3, $24		# j = (min_j >> 3)
	fclr	$f27
	SXADDQ	$21, $6,  $5		# aoffset3 = aoffset2 + lda
	fclr	$f25

	SXADDQ	$21, $5,  $7		# aoffset4 = aoffset3 + lda
	fclr	$f26
	lda	$0,    -1($0)
	fclr	$f11

	SXADDQ	$21, $7,  $28		# aoffset += 4 * lda
	fclr	$f15
	SXADDQ	$26, $19, $3		# xoffset = x + js
	fclr	$f23

	cmovne	$22, $27, $3
	mov	$8,  $4
	ldl	$31,    8*SIZE($8)
	ble	$24,  $L12
	.align 4

	LD	$f10,   0*SIZE($3)
	LD	$f12,   1*SIZE($3)
	LD	$f14,   2*SIZE($3)
	LD	$f22,   3*SIZE($3)

	LD	$f28,   0*SIZE($2)
	LD	$f29,   0*SIZE($6)
	LD	$f21,   0*SIZE($5)
	LD	$f30,   0*SIZE($7)

	LD	$f18,   1*SIZE($2)
	LD	$f20,   1*SIZE($6)
	LD	$f16,   1*SIZE($5)
	LD	$f17,   1*SIZE($7)

	LD	$f1,    2*SIZE($2)
	LD	$f0,    2*SIZE($6)
	LD	$f2,    2*SIZE($5)
	LD	$f7,    2*SIZE($7)

	LD	$f5,    3*SIZE($2)
	LD	$f3,    3*SIZE($6)
	LD	$f6,    3*SIZE($5)
	LD	$f4,    3*SIZE($7)

#ifdef EV6
	lds	$f31,    4*SIZE($4)
#else
	unop
#endif
	lda	$24,   -1($24)
	ble	$24,$L13
	.align 4

$L17:
	ADD	$f24, $f13, $f24
#ifdef EV6
	ldl	$31,   16*SIZE($2)
#else
	LD	$f31,  24*SIZE($2)
#endif
	MUL	$f10, $f28, $f13
	LD	$f28,   4*SIZE($2)

	ADD	$f27, $f15, $f27
#ifdef EV6
	ldl	$31,   16*SIZE($6)
#else
	unop
#endif
	MUL	$f10, $f29, $f15
	LD	$f29,   4*SIZE($6)

	ADD	$f25, $f11, $f25
/*	ldl	$31,   28*SIZE($5) */
	unop
	MUL	$f10, $f21, $f11
	LD	$f21,   4*SIZE($5)

	ADD	$f26, $f23, $f26
/*	ldl	$31,   16*SIZE($7) */
	unop
	MUL	$f10, $f30, $f23
	LD	$f10,   4*SIZE($3)

	ADD	$f24, $f13, $f24
	LD	$f30,   4*SIZE($7)
	MUL	$f12, $f18, $f13
	LD	$f18,   5*SIZE($2)

	ADD	$f27, $f15, $f27
/*	ldl	$31,   16*SIZE($3) */
	unop
	MUL	$f12, $f20, $f15
	LD	$f20,   5*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f12, $f16, $f11
	LD	$f16,   5*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f12, $f17, $f23
	LD	$f12,   5*SIZE($3)
	LD	$f17,   5*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f14, $f1,  $f13
	LD	$f1,    6*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f14, $f0,  $f15
	LD	$f0,    6*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f14, $f2,  $f11
	LD	$f2,    6*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f14, $f7,  $f23
	LD	$f14,   6*SIZE($3)
	LD	$f7,    6*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f22, $f5,  $f13
	LD	$f5,    7*SIZE($2)

	ADD	$f27, $f15, $f27
	lda	$2,     8*SIZE($2)
	MUL	$f22, $f3,  $f15
	LD	$f3,    7*SIZE($6)

	ADD	$f25, $f11, $f25
	lda	$6,     8*SIZE($6)
	MUL	$f22, $f6,  $f11
	LD	$f6,    7*SIZE($5)

	ADD	$f26, $f23, $f26
	LD	$f9,    7*SIZE($7)
	MUL	$f22, $f4,  $f23
	LD	$f22,   7*SIZE($3)

	ADD	$f24, $f13, $f24
	lda	$5,     8*SIZE($5)
	MUL	$f10, $f28, $f13
	LD	$f28,   0*SIZE($2)

	ADD	$f27, $f15, $f27
	lda	$3,     8*SIZE($3)
	MUL	$f10, $f29, $f15
	LD	$f29,   0*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f10, $f21, $f11
	LD	$f21,   0*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f10, $f30, $f23
	LD	$f10,   0*SIZE($3)
	LD	$f30,   8*SIZE($7)

	ADD	$f24, $f13, $f24
	lda	$7,     8*SIZE($7)
	MUL	$f12, $f18, $f13
	LD	$f18,   1*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f12, $f20, $f15
	LD	$f20,   1*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f12, $f16, $f11
	LD	$f16,   1*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f12, $f17, $f23
	LD	$f12,   1*SIZE($3)
	LD	$f17,   1*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f14, $f1,  $f13
	LD	$f1,    2*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f14, $f0,  $f15
	LD	$f0,    2*SIZE($6)

	ADD	$f25, $f11, $f25
	lda	$24,   -1($24)
	MUL	$f14, $f2,  $f11
	LD	$f2,    2*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f14, $f7,  $f23
	LD	$f14,   2*SIZE($3)
	LD	$f7,    2*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f22, $f5,  $f13
	LD	$f5,    3*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f22, $f3,  $f15
	LD	$f3,    3*SIZE($6)

	ADD	$f25, $f11, $f25
	LD	$f4,    3*SIZE($7)
	MUL	$f22, $f6,  $f11
	LD	$f6,    3*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f22, $f9,  $f23
	LD	$f22,   3*SIZE($3)
	bgt	$24,$L17
	.align 4

$L13:
	ADD	$f24, $f13, $f24
	unop
	MUL	$f10, $f28, $f13
	LD	$f28,   4*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f10, $f29, $f15
	LD	$f29,   4*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f10, $f21, $f11
	LD	$f21,   4*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f10, $f30, $f23
	LD	$f10,   4*SIZE($3)
	LD	$f30,   4*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f12, $f18, $f13
	LD	$f18,   5*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f12, $f20, $f15
	LD	$f20,   5*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f12, $f16, $f11
	LD	$f16,   5*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f12, $f17, $f23
	LD	$f12,   5*SIZE($3)
	LD	$f17,   5*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f14, $f1,  $f13
	LD	$f1,    6*SIZE($2)

	ADD	$f27, $f15, $f27
	unop
	MUL	$f14, $f0,  $f15
	LD	$f0,    6*SIZE($6)

	ADD	$f25, $f11, $f25
	unop
	MUL	$f14, $f2,  $f11
	LD	$f2,    6*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f14, $f7,  $f23
	LD	$f14,   6*SIZE($3)
	LD	$f7,    6*SIZE($7)

	ADD	$f24, $f13, $f24
	unop
	MUL	$f22, $f5,  $f13
	LD	$f5,    7*SIZE($2)

	ADD	$f27, $f15, $f27
	lda	$2,     8*SIZE($2)
	MUL	$f22, $f3,  $f15
	LD	$f3,    7*SIZE($6)

	ADD	$f25, $f11, $f25
	lda	$6,     8*SIZE($6)
	MUL	$f22, $f6,  $f11
	LD	$f6,    7*SIZE($5)

	ADD	$f26, $f23, $f26
	MUL	$f22, $f4,  $f23
	LD	$f22,   7*SIZE($3)
	LD	$f4,    7*SIZE($7)

	ADD	$f24, $f13, $f24
	lda	$5,     8*SIZE($5)
	MUL	$f10, $f28, $f13
	unop

	ADD	$f27, $f15, $f27
	lda	$3,     8*SIZE($3)
	MUL	$f10, $f29, $f15
	lda	$7,     8*SIZE($7)

	ADD	$f25, $f11, $f25
	MUL	$f10, $f21, $f11
	ADD	$f26, $f23, $f26
	MUL	$f10, $f30, $f23

	ADD	$f24, $f13, $f24
	MUL	$f12, $f18, $f13
	ADD	$f27, $f15, $f27
	MUL	$f12, $f20, $f15

	ADD	$f25, $f11, $f25
	MUL	$f12, $f16, $f11
	ADD	$f26, $f23, $f26
	MUL	$f12, $f17, $f23

	ADD	$f24, $f13, $f24
	MUL	$f14, $f1,  $f13
	ADD	$f27, $f15, $f27
	MUL	$f14, $f0,  $f15

	ADD	$f25, $f11, $f25
	MUL	$f14, $f2,  $f11
	ADD	$f26, $f23, $f26
	MUL	$f14, $f7,  $f23

	ADD	$f24, $f13, $f24
	MUL	$f22, $f5,  $f13
	ADD	$f27, $f15, $f27
	MUL	$f22, $f3,  $f15

	ADD	$f25, $f11, $f25
	MUL	$f22, $f6,  $f11
	ADD	$f26, $f23, $f26
	MUL	$f22, $f4,  $f23
	.align 4

$L12:
	and	$25,   7, $24
	unop
	unop
	ble	$24,  $L18
	.align 4

	LD	$f10,   0*SIZE($3)
	lda	$3,       SIZE($3)
	LD	$f28,   0*SIZE($2)
	lda	$2,       SIZE($2)

	LD	$f29,   0*SIZE($6)
	lda	$6,       SIZE($6)
	LD	$f21,   0*SIZE($5)
	lda	$5,       SIZE($5)

	LD	$f30,   0*SIZE($7)
	lda	$7,       SIZE($7)
	lda	$24,   -1($24)
	ble	$24, $L43
	.align 4

$L23:
	ADD	$f24, $f13, $f24
	lda	$24,   -1($24)
	MUL	$f10, $f28, $f13
	LD	$f28,   0*SIZE($2)

	ADD	$f27, $f15, $f27
	lda	$2,       SIZE($2)
	MUL	$f10, $f29, $f15
	LD	$f29,   0*SIZE($6)

	ADD	$f25, $f11, $f25
	lda	$6,       SIZE($6)
	MUL	$f10, $f21, $f11
	LD	$f21,   0*SIZE($5)

	ADD	$f26, $f23, $f26
	lda	$5,       SIZE($5)
	MUL	$f10, $f30, $f23
	LD	$f10,   0*SIZE($3)

	LD	$f30,   0*SIZE($7)
	lda	$3,       SIZE($3)
	lda	$7,       SIZE($7)
	bgt	$24,$L23
	.align 4

$L43:
	ADD	$f24, $f13, $f24
	MUL	$f10, $f28, $f13
	ADD	$f27, $f15, $f27
	MUL	$f10, $f29, $f15

	ADD	$f25, $f11, $f25
	MUL	$f10, $f21, $f11
	ADD	$f26, $f23, $f26
	MUL	$f10, $f30, $f23
	.align 5

$L18:
	ADD	$f24, $f13, $f24
	LD	$f8,    0*SIZE($8)
	unop
	SXADDQ	$23, $8,  $8

	ADD	$f27, $f15, $f27
	LD	$f3,    0*SIZE($8)
	unop
	SXADDQ	$23, $8,  $8

	ADD	$f25, $f11, $f25
	unop
	LD	$f6,    0*SIZE($8)
	SXADDQ	$23, $8,  $8

	ADD	$f26, $f23, $f26
	unop
	LD	$f4,    0*SIZE($8)
	SXADDQ	$23, $8,  $8

	MUL	$f19, $f24, $f10
	MUL	$f19, $f27, $f11
	MUL	$f19, $f25, $f12
	MUL	$f19, $f26, $f13

	ADD	$f8, $f10, $f10
	ADD	$f3, $f11, $f11
	ADD	$f6, $f12, $f12
	ADD	$f4, $f13, $f13

	ST	$f10,   0*SIZE($4)
	SXADDQ	$23, $4,  $4
	ST	$f11,   0*SIZE($4)
	SXADDQ	$23, $4,  $4

	ST	$f12,   0*SIZE($4)
	SXADDQ	$23, $4,  $4
	ST	$f13,   0*SIZE($4)
	bgt	$0,  $L24
	.align 4

$L8:
	and	$17,  3, $0
	fclr	$f23
	fclr	$f11
	ble	$0,  $L5
	.align 4

$L41:
	mov	$28, $2
	fclr	$f24
	sra	$25,  3, $24
	fclr	$f13

	SXADDQ	$26, $19, $3
	fclr	$f27
	SXADDQ	$21, $2,  $28
	fclr	$f25

	cmovne	$22, $27, $3
	fclr	$f26
	fclr	$f15
	ble	$24,$L29
	.align 4

	LD	$f10,   0*SIZE($3)
	LD	$f28,   0*SIZE($2)
	LD	$f12,   1*SIZE($3)
	LD	$f29,   1*SIZE($2)

	LD	$f14,   2*SIZE($3)
	LD	$f21,   2*SIZE($2)
	LD	$f22,   3*SIZE($3)
	LD	$f30,   3*SIZE($2)

	LD	$f1,    4*SIZE($3)
	LD	$f18,   4*SIZE($2)
	LD	$f0,    5*SIZE($3)
	LD	$f20,   5*SIZE($2)

	LD	$f2,    6*SIZE($3)
	LD	$f16,   6*SIZE($2)
	LD	$f7,    7*SIZE($3)
	LD	$f17,   7*SIZE($2)

	lda	$24,   -1($24)
	lda	$2,     8*SIZE($2)
	lda	$3,     8*SIZE($3)
	ble	$24, $L44
	.align 4

$L34:
	ADD	$f24, $f13, $f24
	MUL	$f10, $f28, $f13
	LD	$f10,   0*SIZE($3)
	LD	$f28,   0*SIZE($2)

	ADD	$f27, $f15, $f27
	MUL	$f12, $f29, $f15
	LD	$f12,   1*SIZE($3)
	LD	$f29,   1*SIZE($2)

	ADD	$f25, $f11, $f25
	MUL	$f14, $f21, $f11
	LD	$f14,   2*SIZE($3)
	LD	$f21,   2*SIZE($2)

	ADD	$f26, $f23, $f26
	MUL	$f22, $f30, $f23
	LD	$f22,   3*SIZE($3)
	LD	$f30,   3*SIZE($2)

	ADD	$f24, $f13, $f24
	MUL	$f1,  $f18, $f13
	LD	$f1,    4*SIZE($3)
	LD	$f18,   4*SIZE($2)

	ADD	$f27, $f15, $f27
	MUL	$f0,  $f20, $f15
	LD	$f0,    5*SIZE($3)
	LD	$f20,   5*SIZE($2)

	ADD	$f25, $f11, $f25
	MUL	$f2,  $f16, $f11
	LD	$f2,    6*SIZE($3)
	LD	$f16,   6*SIZE($2)

	ADD	$f26, $f23, $f26
	MUL	$f7,  $f17, $f23
	LD	$f7,    7*SIZE($3)
	lda	$24,   -1($24)

	LD	$f17,   7*SIZE($2)
	lda	$2,     8*SIZE($2)
	lda	$3,     8*SIZE($3)
	bgt	$24,$L34
	.align 4

$L44:
	ADD	$f24, $f13, $f24
	MUL	$f10, $f28, $f13
	ADD	$f27, $f15, $f27
	MUL	$f12, $f29, $f15

	ADD	$f25, $f11, $f25
	MUL	$f14, $f21, $f11
	ADD	$f26, $f23, $f26
	MUL	$f22, $f30, $f23

	ADD	$f24, $f13, $f24
	MUL	$f1,  $f18, $f13
	ADD	$f27, $f15, $f27
	MUL	$f0,  $f20, $f15

	ADD	$f25, $f11, $f25
	MUL	$f2,  $f16, $f11
	ADD	$f26, $f23, $f26
	MUL	$f7,  $f17, $f23
	.align 4

$L29:
	and	$25,   7, $24
	ADD	$f25, $f11, $f12
	LD	$f8,    0*SIZE($8)
	ble	$24, $L35
	.align 4

	LD	$f10,   0*SIZE($3)
	lda	$24,  -1($24)
	LD	$f28,   0*SIZE($2)
	lda	$2,       SIZE($2)

	lda	$3,       SIZE($3)
	unop
	unop
	ble	$24,  $L45
	.align 4

$L40:
	ADD	$f24, $f13, $f24
	MUL	$f10, $f28, $f13
	LD	$f10,   0*SIZE($3)
	LD	$f28,   0*SIZE($2)

	lda	$24,   -1($24)
	lda	$2,       SIZE($2)
	lda	$3,       SIZE($3)
	bgt	$24,$L40
	.align 4

$L45:
	ADD	$f24, $f13, $f24
	unop
	MUL	$f10, $f28, $f13
	unop
	.align 4

$L35:
	ADD	$f27, $f15, $f14
	ADD	$f26, $f23, $f11
	ADD	$f24, $f13, $f24

	ADD	$f12, $f11, $f25
	ADD	$f24, $f14, $f24
	ADD	$f24, $f25, $f24
	MUL	$f19, $f24, $f10
	ADD	$f8,  $f10, $f10
	lda	$0,    -1($0)
	ST	$f10,   0*SIZE($8)
	fclr	$f23
	SXADDQ	$23, $8,  $8
	fclr	$f11
	bgt	$0, $L41
	.align 4

$L5:
	lda	$26,   Q($26)
	nop
	cmplt	$26, $16, $1
	bne	$1,$L6
	.align 4

$End:
	ldt	$f2,    0($sp)
	ldt	$f3,    8($sp)
	ldt	$f4,   16($sp)
	ldt	$f5,   24($sp)
	ldt	$f6,   32($sp)
	ldt	$f7,   40($sp)
	ldt	$f8,   48($sp)
	ldt	$f9,   56($sp)
	ldq	$26,   64($sp)
	lda	$sp,   80($sp)
	ret
	.end CNAME
