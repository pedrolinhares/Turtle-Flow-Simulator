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
#define Q	 400
#else
#define Q	 400
#endif
#endif

#ifdef EV5
#ifdef DOUBLE
#define Q	 112
#else
#define Q	 112
#endif
#endif

#ifdef EV4
#ifdef DOUBLE
#define Q	 112
#else
#define Q	 112
#endif
#endif

#if (!defined(CONJ) && !defined(XCONJ)) || (defined(CONJ) && defined(XCONJ))
#define ADDC	ADD
#define SUBC	SUB
#else
#define ADDC	SUB
#define SUBC	ADD
#endif

/* 
                        Register Map 
Integer:
 $0 : temp	 $1 : aoffset1	 $2 : i		 $3 : aoffset2
 $4 : incX	 $5 : xoffset	 $6 : incY	 $7 : ---
 $8 : aoffset	 $9 : ---	 $10: ---	 $11: ---
 $12: ---	 $13: ---	 $14: ---	 $15: ---
 $16: m		 $17: n		 $18: ---	 $19: x
 $20: lda	 $21: a		 $22: is	 $23: y
 $24: min_j 	 $25: STACK	 $26: ---	 $27: j
 $28: yoffset	 $29: ---	 $30: SP	 $31: Zero
*/

	.set noat
	.set noreorder
.text
	.align 5
	.globl CNAME
	.ent CNAME
CNAME:
	.frame $sp, 0,$26,0

#ifdef PROFILE
	ldgp	$gp, 0($27)
	lda	$28, _mcount
	jsr	$28, ($28), _mcount
#endif

	ldl	$20,  0($sp)		# lda
	clr	$22			# is = 0
	ldq	$19,  8($sp)		# X
	cmple	$16, 0, $2

	ldl	$6,  16($sp)		# incX
	cmple	$17, 0, $3
	ldq	$23, 24($sp)		# Y
	or	$2, $3, $2

	ldl	$4,  32($sp)		# incY
	addl	$20, $20, $20		# lda  *= 2
	ldq	$25, 40($sp)		# incY
	addl	$6,  $6,  $6		# incX *= 2
#ifndef PROFILE
	.prologue	0
#else
	.prologue	1
#endif

	addl	$4,  $4,  $4		# incY *= 2
	bne	$2, $End
	.align	4

$L5:
	lda	$5, Q
	subl	$16, $22, $24		# min_j = m - is
	mov	$23, $28		# yoffset = y
	mov	$19, $18		# $17 = X

	cmple	$24, $5,  $1		# $1 = (min_j > Q)
	cmpeq	$6, 2, $0		# $0  = (incx == 1?)
	sra	$17,   1, $27		# j = (n >> 1)
	lda	$2, 2*Q*SIZE($19)	# $2 = X + 2 * Q

	cmoveq	$1,  $5, $24		# if (min_j > Q) min_j = Q
	cmoveq	$0, $25, $18		# if (incx != 1) $17 = sp
	cmovne	$0, $2,  $19		# if (incx == 1) $19 = $2
	bne	$0, $CopySkip

	sra	$24, 2, $1
	mov	$19, $5
	mov	$25, $2
	ble	$1, $CopySkip1
	.align 4

$CopyLoop1:
	LD	$f21, 0*SIZE($19)
	unop
	LD	$f22, 1*SIZE($19)
	SXADDQ	$6,  $19,  $19

	LD	$f23, 0*SIZE($19)
	lda	$1,  -1($1)
	LD	$f24, 1*SIZE($19)
	SXADDQ	$6,  $19,  $19

	LD	$f25, 0*SIZE($19)
	unop
	LD	$f26, 1*SIZE($19)
	SXADDQ	$6,  $19,  $19

	LD	$f27, 0*SIZE($19)
	unop
	LD	$f28, 1*SIZE($19)
	SXADDQ	$6,  $19,  $19

	ST	$f21, 0*SIZE($2)
	ST	$f22, 1*SIZE($2)
	ST	$f23, 2*SIZE($2)
	ST	$f24, 3*SIZE($2)

	ST	$f25, 4*SIZE($2)
	ST	$f26, 5*SIZE($2)
	ST	$f27, 6*SIZE($2)
	ST	$f28, 7*SIZE($2)

	lda	$2,   8*SIZE($2)
	bgt	$1, $CopyLoop1
	.align 4

$CopySkip1:
	and	$24, 3, $1
	ble	$1, $CopySkip
	.align 4

$CopyLoop2:
	LD	$f21, 0*SIZE($19)
	LD	$f22, 1*SIZE($19)
	SXADDQ	$6,  $19,  $19
	lda	$1,  -1($1)
	ST	$f21, 0*SIZE($2)
	ST	$f22, 1*SIZE($2)
	lda	$2,   2*SIZE($2)
	bgt	$1, $CopyLoop2
	.align 4


$CopySkip:
	fclr	$f14
	mov	$21, $8			# aoffset = a
	fclr	$f22
	ble	$27, $L7
	.align	4

$L8:
	mov	$8,  $1			# aoffset1 = aoffset
	fclr	$f15
	mov	$18, $5			# xoffset = X
	fclr	$f23

	sra	$24,  2, $2
	fclr	$f11
	SXADDQ	$20, $1 ,$3		# aoffset2 = aoffset + lda
	fclr	$f10

	fclr	$f12
	SXADDQ	$20, $3, $8		# aoffset += 2 * lda
	fclr	$f13
	ble	$2,$L11
	.align 4

	LD	$f28,  0*SIZE($1)
	LD	$f29,  1*SIZE($1)
	LD	$f0,   2*SIZE($1)
	LD	$f17,  3*SIZE($1)

	LD	$f24,  0*SIZE($5)
	LD	$f25,  1*SIZE($5)
	LD	$f26,  2*SIZE($5)
	LD	$f27,  3*SIZE($5)

	LD	$f30,  0*SIZE($3)
	LD	$f21,  1*SIZE($3)
	LD	$f16,  2*SIZE($3)
	LD	$f18,  3*SIZE($3)

	lda	$3,    4*SIZE($3)
	subl	$2,1,$2
	lda	$1,    4*SIZE($1)
	lda	$5,    4*SIZE($5)
	ble	$2,$L12
	.align	4

$L13:
	SUBC	$f14, $f11, $f14
	unop
	MUL	$f28, $f24, $f11
#ifdef EV6
	ldl	$31,  24*SIZE($3)
#else
	LD	$f31, 16*SIZE($3)
#endif

	ADDC	$f22, $f10, $f22
	subl	$2,1,$2
	MUL	$f28, $f25, $f10
	LD	$f28,   0*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f30, $f24, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f30, $f25, $f13
	LD	$f30,   0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f29, $f25, $f11
	unop

	ADD	$f22, $f10, $f22
	unop
	MUL	$f29, $f24, $f10
	LD	$f29,   1*SIZE($1)

	ADD	$f15, $f12, $f15
	unop
	MUL	$f21, $f25, $f12
	LD	$f25,   1*SIZE($5)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f21, $f24, $f13
	LD	$f21,   1*SIZE($3)

	SUBC	$f14, $f11, $f14
	LD	$f24,   0*SIZE($5)
	MUL	$f0, $f26, $f11
	unop

	ADDC	$f22, $f10, $f22
	unop
	MUL	$f0, $f27, $f10
	LD	$f0,   2*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f16, $f26, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f16, $f27, $f13
	LD	$f16,   2*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f17,$f27,$f11
	unop

	ADD	$f22, $f10, $f22
	unop
	MUL	$f17,$f26,$f10
	LD	$f17,   3*SIZE($1)

	ADD	$f15, $f12, $f15
	unop
	MUL	$f18,$f27,$f12
	LD	$f27,   3*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f18,$f26,$f13
	LD	$f1,    3*SIZE($3)
	LD	$f26,   2*SIZE($5)

	SUBC	$f14, $f11, $f14
	unop
	MUL	$f28, $f24, $f11
	unop

	ADDC	$f22, $f10, $f22
	unop
	MUL	$f28, $f25, $f10
	LD	$f28,  4*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f30, $f24, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f30, $f25, $f13
	LD	$f30,  4*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f29, $f25, $f11
	unop

	ADD	$f22, $f10, $f22
	unop
	MUL	$f29, $f24, $f10
	LD	$f29,  5*SIZE($1)

	ADD	$f15, $f12, $f15
	unop
	MUL	$f21, $f25, $f12
	LD	$f25,  5*SIZE($5)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f21, $f24, $f13
	LD	$f21,  5*SIZE($3)

	SUBC	$f14, $f11, $f14
	LD	$f24,  4*SIZE($5)
	MUL	$f0, $f26, $f11
	unop

	ADDC	$f22, $f10, $f22
	lda	$5,    8*SIZE($5)
	MUL	$f0, $f27, $f10
	LD	$f0,  6*SIZE($1)

	SUBC	$f15, $f12, $f15
	lda	$1,    8*SIZE($1)
	MUL	$f16, $f26, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f16, $f27, $f13
	LD	$f16,  6*SIZE($3)

	ADD	$f14, $f11, $f14
	LD	$f18,  7*SIZE($3)
	MUL	$f17, $f27, $f11
	unop

	ADD	$f22, $f10, $f22
	lda	$3,    8*SIZE($3)
	MUL	$f17, $f26, $f10
	LD	$f17, -1*SIZE($1)

	ADD	$f15, $f12, $f15
	unop
	MUL	$f1,  $f27, $f12
	LD	$f27, -1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f1,  $f26, $f13
	LD	$f26, -2*SIZE($5)
	bgt	$2,$L13
	.align 4

$L12:
	SUBC	$f14, $f11, $f14
	unop
	MUL	$f28, $f24, $f11
	unop

	ADDC	$f22, $f10, $f22
	unop
	MUL	$f28, $f25, $f10
	LD	$f28,   0*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f30, $f24, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f30, $f25, $f13
	LD	$f30,   0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f29, $f25, $f11
	unop

	ADD	$f22, $f10, $f22
	unop
	MUL	$f29, $f24, $f10
	LD	$f29,   1*SIZE($1)

	ADD	$f15, $f12, $f15
	unop
	MUL	$f21, $f25, $f12
	LD	$f25,   1*SIZE($5)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f21, $f24, $f13
	LD	$f21,   1*SIZE($3)

	SUBC	$f14, $f11, $f14
	LD	$f24,   0*SIZE($5)
	MUL	$f0, $f26, $f11
	unop

	ADDC	$f22, $f10, $f22
	unop
	MUL	$f0, $f27, $f10
	LD	$f0,   2*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f16, $f26, $f12
	unop

	ADDC	$f23, $f13, $f23
	lda	$5,     4*SIZE($5)
	MUL	$f16, $f27, $f13
	LD	$f16,   2*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f17, $f27, $f11
	unop

	ADD	$f22, $f10, $f22
	lda	$3,     4*SIZE($3)
	MUL	$f17, $f26, $f10
	LD	$f17,   3*SIZE($1)

	ADD	$f15, $f12, $f15
	lda	$1,     4*SIZE($1)
	MUL	$f18, $f27, $f12
	LD	$f27,  -1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f18, $f26, $f13
	LD	$f18,  -1*SIZE($3)
	LD	$f26,  -2*SIZE($5)

	SUBC	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADDC	$f22, $f10, $f22
	MUL	$f28, $f25, $f10

	SUBC	$f15, $f12, $f15
	MUL	$f30, $f24, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f30, $f25, $f13

	ADD	$f14, $f11, $f14
	MUL	$f29, $f25, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f24, $f10

	ADD	$f15, $f12, $f15
	MUL	$f21, $f25, $f12
	ADD	$f23, $f13, $f23
	MUL	$f21, $f24, $f13

	SUBC	$f14, $f11, $f14
	MUL	$f0, $f26, $f11
	ADDC	$f22, $f10, $f22
	MUL	$f0, $f27, $f10

	SUBC	$f15, $f12, $f15
	MUL	$f16, $f26, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f16, $f27, $f13

	ADD	$f14, $f11, $f14
	MUL	$f17, $f27, $f11
	ADD	$f22, $f10, $f22
	MUL	$f17, $f26, $f10

	ADD	$f15, $f12, $f15
	MUL	$f18, $f27, $f12
	ADD	$f23, $f13, $f23
	MUL	$f18, $f26, $f13
	.align 4

$L11:
	and	$24,3,$2
	ble	$2,$L18

	LD	$f28,  0*SIZE($1)
	LD	$f29,  1*SIZE($1)

	LD	$f30,  0*SIZE($3)
	LD	$f21,  1*SIZE($3)
	LD	$f24,  0*SIZE($5)
	LD	$f25,  1*SIZE($5)

	subl	$2,1,$2
	lda	$1,    2*SIZE($1)
	lda	$3,    2*SIZE($3)
	lda	$5,    2*SIZE($5)
	ble	$2,$L19
	.align	4

$L20:
	SUBC	$f14, $f11, $f14
	unop
	MUL	$f28, $f24, $f11
	unop

	ADDC	$f22, $f10, $f22
	subl	$2,1,$2
	MUL	$f28, $f25, $f10
	LD	$f28,  0*SIZE($1)

	SUBC	$f15, $f12, $f15
	unop
	MUL	$f30, $f24, $f12
	unop

	ADDC	$f23, $f13, $f23
	lda	$1,    2*SIZE($1)
	MUL	$f30, $f25, $f13
	LD	$f30,  0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f29, $f25, $f11
	unop

	ADD	$f22, $f10, $f22
	lda	$5,    2*SIZE($5)
	MUL	$f29, $f24, $f10
	LD	$f29, -1*SIZE($1)

	ADD	$f15, $f12, $f15
	lda	$3,    2*SIZE($3)
	MUL	$f21, $f25, $f12
	LD	$f25, -1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f21, $f24, $f13
	LD	$f24, -2*SIZE($5)
	LD	$f21, -1*SIZE($3)
	bgt	$2,$L20
	.align 4

$L19:
	SUBC	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADDC	$f22, $f10, $f22
	MUL	$f28, $f25, $f10

	SUBC	$f15, $f12, $f15
	MUL	$f30, $f24, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f30, $f25, $f13

	ADD	$f14, $f11, $f14
	MUL	$f29, $f25, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f24, $f10

	ADD	$f15, $f12, $f15
	MUL	$f21, $f25, $f12
	ADD	$f23, $f13, $f23
	MUL	$f21, $f24, $f13
	.align 4

$L18:
	SUBC	$f14, $f11, $f14
	LD	$f24,  0*SIZE($28)
	unop
	SXADDQ	$4,  $28, $0

	ADDC	$f22, $f10, $f22
	unop
	LD	$f25,  1*SIZE($28)
	unop

	SUBC	$f15, $f12, $f15
	LD	$f26,  0*SIZE($0)
	ADDC	$f23, $f13, $f23
	LD	$f27,  1*SIZE($0)

	MUL	$f19, $f14, $f28
	MUL	$f20, $f22, $f29
	MUL	$f20, $f14, $f21
	MUL	$f19, $f22, $f30

	MUL	$f19, $f15, $f0
	MUL	$f20, $f23, $f17
	MUL	$f20, $f15, $f18
	MUL	$f19, $f23, $f16

#ifndef XCONJ
	SUB	$f28, $f29, $f11
	ADD	$f21, $f30, $f10
	SUB	$f0,  $f17, $f12
	ADD	$f18, $f16, $f13
#else
	ADD	$f28, $f29, $f11
	SUB	$f21, $f30, $f10
	ADD	$f0,  $f17, $f12
	SUB	$f18, $f16, $f13
#endif

	ADD	$f24, $f11, $f24
	ADD	$f25, $f10, $f25
	ADD	$f26, $f12, $f26
	ADD	$f27, $f13, $f27

	ST	$f24,  0*SIZE($28)
	subl	$27,1,$27
	ST	$f25,  1*SIZE($28)
	SXADDQ	$4,  $28, $28

	ST	$f26,  0*SIZE($28)
	fclr	$f14
	ST	$f27,  1*SIZE($28)
	SXADDQ	$4,  $28, $28
	fclr	$f22

	bgt	$27, $L8
	.align 4

$L7:
	fclr	$f23
	mov	$8,  $1
	fclr	$f15
	blbc	$17, $L27

	sra	$24,  2, $2
	fclr	$f11
	mov	$18, $5
	fclr	$f10

	fclr	$f12
	unop
	fclr	$f13
	ble	$2,$L28

	LD	$f28,  0*SIZE($1)
	LD	$f29,  1*SIZE($1)
	LD	$f30,  2*SIZE($1)
	LD	$f21,  3*SIZE($1)

	LD	$f24,  0*SIZE($5)
	LD	$f25,  1*SIZE($5)
	LD	$f26,  2*SIZE($5)
	LD	$f27,  3*SIZE($5)

	subl	$2,1,$2
	lda	$1,    4*SIZE($1)
	lda	$5,    4*SIZE($5)
	ble	$2,$L29
	.align	4

$L30:
	ADD	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f25, $f10

	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12
	LD	$f28,   0*SIZE($1)
	LD	$f25,   1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	LD	$f29,   1*SIZE($1)
	LD	$f24,   0*SIZE($5)

	ADD	$f14, $f11, $f14
	MUL	$f30, $f26, $f11
	ADD	$f22, $f10, $f22
	MUL	$f21, $f27, $f10

	ADD	$f15, $f12, $f15
	MUL	$f30, $f27, $f12
	LD	$f30,   2*SIZE($1)
	LD	$f27,   3*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f21, $f26, $f13
	LD	$f21,   3*SIZE($1)
	LD	$f26,   2*SIZE($5)

	ADD	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f25, $f10

	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12
	LD	$f28,  4*SIZE($1)
	LD	$f25,  5*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	LD	$f29,  5*SIZE($1)
	LD	$f24,  4*SIZE($5)

	ADD	$f14, $f11, $f14
	lda	$5,    8*SIZE($5)
	MUL	$f30, $f26, $f11
	unop

	ADD	$f22, $f10, $f22
	lda	$1,    8*SIZE($1)
	MUL	$f21, $f27, $f10
	subl	$2,1,$2

	ADD	$f15, $f12, $f15
	MUL	$f30, $f27, $f12
	LD	$f30, -2*SIZE($1)
	LD	$f27, -1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f21, $f26, $f13
	LD	$f21, -1*SIZE($1)
	LD	$f26, -2*SIZE($5)
	bgt	$2,$L30
	.align 4
	
$L29:
	ADD	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f25, $f10

	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12
	LD	$f28,  0*SIZE($1)
	LD	$f25,  1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	LD	$f29,  1*SIZE($1)
	LD	$f24,  0*SIZE($5)

	ADD	$f14, $f11, $f14
	MUL	$f30, $f26, $f11
	ADD	$f22, $f10, $f22
	MUL	$f21, $f27, $f10

	ADD	$f15, $f12, $f15
	MUL	$f30, $f27, $f12
	LD	$f30,  2*SIZE($1)
	LD	$f27,  3*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f21, $f26, $f13
	LD	$f21,  3*SIZE($1)
	LD	$f26,  2*SIZE($5)

	ADD	$f14, $f11, $f14
	lda	$1,    4*SIZE($1)
	MUL	$f28, $f24, $f11
	lda	$5,    4*SIZE($5)

	ADD	$f22, $f10, $f22
	MUL	$f29, $f25, $f10
	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12

	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	ADD	$f14, $f11, $f14
	MUL	$f30, $f26, $f11

	ADD	$f22, $f10, $f22
	MUL	$f21, $f27, $f10
	ADD	$f15, $f12, $f15
	MUL	$f30, $f27, $f12

	ADD	$f23, $f13, $f23
	unop
	MUL	$f21, $f26, $f13
	unop
	.align 4

$L28:
	and	$24,3,$2
	ble	$2,$L35

	LD	$f28,  0*SIZE($1)
	LD	$f29,  1*SIZE($1)

	LD	$f24,  0*SIZE($5)
	LD	$f25,  1*SIZE($5)

	subl	$2,1,$2
	lda	$1,    2*SIZE($1)
	lda	$5,    2*SIZE($5)
	ble	$2,$L36
	.align	4

$L37:
	ADD	$f14, $f11, $f14
	lda	$5,    2*SIZE($5)
	MUL	$f28, $f24, $f11
	lda	$1,    2*SIZE($1)

	ADD	$f22, $f10, $f22
	unop
	MUL	$f29, $f25, $f10
	subl	$2,1,$2

	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12
	LD	$f28, -2*SIZE($1)
	LD	$f25, -1*SIZE($5)

	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	LD	$f29, -1*SIZE($1)
	LD	$f24, -2*SIZE($5)
	bgt	$2,$L37
	.align 4

$L36:
	ADD	$f14, $f11, $f14
	MUL	$f28, $f24, $f11
	ADD	$f22, $f10, $f22
	MUL	$f29, $f25, $f10

	ADD	$f15, $f12, $f15
	MUL	$f28, $f25, $f12
	ADD	$f23, $f13, $f23
	MUL	$f29, $f24, $f13
	.align 4

$L35:
	ADD	$f14, $f11, $f14
	LD	$f28,  0*SIZE($28)
	ADD	$f22, $f10, $f22
	LD	$f29,  1*SIZE($28)

	ADD	$f15, $f12, $f15
	ADD	$f23, $f13, $f23

	SUBC	$f14, $f22, $f14
	ADDC	$f15, $f23, $f15

	MUL	$f19, $f14, $f11
	MUL	$f20, $f15, $f10
	MUL	$f19, $f15, $f12
	MUL	$f20, $f14, $f13

#ifndef XCONJ
	SUB	$f11, $f10, $f11
	ADD	$f13, $f12, $f12
#else
	ADD	$f11, $f10, $f11
	SUB	$f13, $f12, $f12
#endif

	ADD	$f28, $f11, $f28
	ADD	$f29, $f12, $f29

	ST	$f28,  0*SIZE($28)
	nop
	ST	$f29,  1*SIZE($28)
	nop
	.align 4

$L27:
	lda	$22, Q($22)
	lda	$21, Q*SIZE*2($21)
	cmplt	$22, $16, $1
	bne	$1,$L5
	.align 4

$End:
	clr	$0
	ret
	.end CNAME
