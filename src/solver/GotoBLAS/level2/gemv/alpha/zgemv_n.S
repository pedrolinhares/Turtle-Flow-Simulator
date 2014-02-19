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
#define Q	 64
#else
#define Q	 64
#endif
#endif

#ifdef EV5
#ifdef DOUBLE
#define Q	 32
#else
#define Q	 32
#endif
#endif

#ifdef EV4
#ifdef DOUBLE
#define Q	 24
#else
#define Q	 24
#endif
#endif

#if (!defined(CONJ) && !defined(XCONJ)) || (defined(CONJ) && defined(XCONJ))
#define ADDC	ADD
#define SUBC	SUB
#else
#define ADDC	SUB
#define SUBC	ADD
#endif

	.set noat
	.set noreorder
.text
	.align 5
	.globl CNAME
	.ent CNAME
CNAME:
	.frame $sp, 0, $26, 0

#ifdef PROFILE
	ldgp	$gp, 0($27)
	lda	$28, _mcount
	jsr	$28, ($28), _mcount
	.prologue	1
#else
	.prologue	0
#endif

	ldl	$20,  0($sp)		# lda
	clr	$22			# jslda = 0	
	ldq	$19,  8($sp)		# X
	clr	$23			# js

	ldl	$28, 16($sp)		# incx
	cmple	$16, 0, $2
	ldq	$8,  24($sp)		# Y
	cmple	$17, 0, $3

	ldl	$5,  32($sp)		# incy
	addq	$20, $20, $20		# lda  *= 2
	ldq	$18, 40($sp)		# buffer
	or	$2, $3, $2

	addl	$28, $28, $28		# incx *= 2
	unop
	addl	$5,  $5,  $5		# incy *= 2
	bne	$2, $End
	.align 4

$L5:
	mov	$8,  $24		# y_offset = y
	mulq	$20, Q, $6		# ldaQ = lda*Q
	subl	$17, $23, $25		# min_j = n - js
	SXADDQ	$22, $21, $27		# a_orig = a + jslda

	cmple	$25,   Q, $1		# if (min_j>Q)
	fclr	$f12
	addl	$6,  $22, $22		# jslda += ldaQ
	fclr	$f13

	cmoveq	$1,    Q, $25		#       min_j = Q
	cmpeq	$28, 2, $0
	sra	$16,   1, $7		# i = (m>>1)
	bne	$0,  $CopySkip
	.align 4

	mull	$23, $28, $0
	mov	$18, $1
	unop
	sra	$25, 2, $6

	unop
	SXADDQ	$0,  $19, $3		# x_offset = x + js * incx
	unop
	ble	$6, $CopySkip1
	.align 4
	
$CopyLoop1:
	LD	$f21,  0*SIZE($3)
	unop
	LD	$f22,  1*SIZE($3)
	SXADDQ	$28, $3,  $3

	LD	$f23,  0*SIZE($3)
	unop
	LD	$f24,  1*SIZE($3)
	SXADDQ	$28, $3,  $3

	LD	$f25,  0*SIZE($3)
	unop
	LD	$f26,  1*SIZE($3)
	SXADDQ	$28, $3,  $3

	LD	$f27,  0*SIZE($3)
	lda	$6, -1($6)
	LD	$f28,  1*SIZE($3)
	SXADDQ	$28, $3,  $3

	ST	$f21,  0*SIZE($1)
	ST	$f22,  1*SIZE($1)
	ST	$f23,  2*SIZE($1)
	ST	$f24,  3*SIZE($1)

	ST	$f25,  4*SIZE($1)
	ST	$f26,  5*SIZE($1)
	ST	$f27,  6*SIZE($1)
	ST	$f28,  7*SIZE($1)

	lda	$1,    8*SIZE($1)
	bgt	$6, $CopyLoop1
	.align 4

$CopySkip1:
	and	$25, 3, $6
	ble	$6, $CopySkip
	.align 4

$CopyLoop2:
	LD	$f21,  0*SIZE($3)
	lda	$6, -1($6)
	LD	$f22,  1*SIZE($3)
	SXADDQ	$28, $3,  $3

	ST	$f21,  0*SIZE($1)
	ST	$f22,  1*SIZE($1)
	lda	$1,    2*SIZE($1)
	bgt	$6, $CopyLoop2
	.align 4

$CopySkip:
	ble	$7,  $L7
	.align 4

$L8:
	addl	$23, $23, $6
	fclr	$f14
	cmpeq	$28, 2, $0
	fclr	$f15

	SXADDQ	$6,  $19, $3		# x_offset = x + js
	fclr	$f22
	mov	$27, $1
	fclr	$f23

	cmoveq	$0,  $18, $3
	fclr	$f10
	sra	$25,  2,  $6		# j = (min_j>>2)
	fclr	$f11

	unop
	lda	$27,  4*SIZE($27)	# a_orig += 4
	unop
	ble	$6,$L11


	LD	$f29,  0*SIZE($1)
	LD	$f25,  0*SIZE($3)
	LD	$f28,  1*SIZE($1)
	LD	$f24,  1*SIZE($3)

	LD	$f21,  2*SIZE($1)
	LD	$f26,  2*SIZE($3)
	LD	$f30,  3*SIZE($1)
	LD	$f27,  3*SIZE($3)

	SXADDQ	$20, $1,  $1
	lda	$3,    4*SIZE($3)
	subl	$6,   1,  $6		# j --
	unop

	LD	$f16,  0*SIZE($1)
	LD	$f0,   1*SIZE($1)
	LD	$f18,  2*SIZE($1)
	LD	$f17,  3*SIZE($1)

	unop
	SXADDQ	$20, $1,  $1
	unop
	ble	$6,$L12
	.align	4

$MainLoop:
	SUBC	$f14, $f11, $f14		# -ac
#ifdef EV6
	ldl	$31,  12*SIZE($1)
#else
	LD	$f31, 16*SIZE($1)
#endif
	MUL	$f25, $f29, $f11
#ifdef EV6
	ldl	$31,  12*SIZE($3)
#else
	unop
#endif

	ADDC	$f15, $f10, $f15
	MUL	$f25, $f28, $f10
	SUBC	$f22, $f12, $f22
	MUL	$f25, $f21, $f12

	ADDC	$f23, $f13, $f23
	subl	$6,  1,  $6
	MUL	$f25, $f30, $f13
	LD	$f25,  0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f24, $f28, $f11
	LD	$f28,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	unop
	MUL	$f24, $f29, $f10
	LD	$f29,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f24, $f30, $f12
	LD	$f30,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f24, $f21, $f13
	LD	$f21,  2*SIZE($1)

	SUBC	$f14, $f11, $f14
	SXADDQ	$20, $1,  $1
	MUL	$f26, $f16, $f11
	LD	$f24,  1*SIZE($3)

	ADDC	$f15, $f10, $f15
	MUL	$f26, $f0, $f10
	SUBC	$f22, $f12, $f22
	MUL	$f26, $f18, $f12

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f26, $f17, $f13
	LD	$f26,  2*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f27, $f0, $f11
	LD	$f0,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	unop
	MUL	$f27, $f16, $f10
	LD	$f16,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f27, $f17, $f12
	LD	$f17,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f27, $f18, $f13
	LD	$f27,  3*SIZE($3)

	SUBC	$f14, $f11, $f14
	LD	$f1,   2*SIZE($1)
	MUL	$f25, $f29, $f11
	lda	$3,    4*SIZE($3)

	ADDC	$f15, $f10, $f15
	SXADDQ	$20, $1,  $1
	MUL	$f25, $f28, $f10
	unop

	SUBC	$f22, $f12, $f22
	unop
	MUL	$f25, $f21, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f25, $f30, $f13
	LD	$f25,  0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f24, $f28, $f11
	LD	$f28,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	unop
	MUL	$f24, $f29, $f10
	LD	$f29,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f24, $f30, $f12
	LD	$f30,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f24, $f21, $f13
	LD	$f21,  2*SIZE($1)

	SUBC	$f14, $f11, $f14
	LD	$f24,  1*SIZE($3)
	MUL	$f26, $f16, $f11
	SXADDQ	$20, $1,  $1

	ADDC	$f15, $f10, $f15
	MUL	$f26, $f0, $f10
	SUBC	$f22, $f12, $f22
	MUL	$f26, $f1,  $f12

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f26, $f17, $f13
	LD	$f26,  2*SIZE($3)

	ADD	$f14, $f11, $f14
	lda	$3,    4*SIZE($3)
	MUL	$f27, $f0, $f11
	LD	$f0,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	LD	$f18,  2*SIZE($1)
	MUL	$f27, $f16, $f10
	LD	$f16,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	MUL	$f27, $f17, $f12
	LD	$f17,  3*SIZE($1)
	SXADDQ	$20, $1,  $1

	ADD	$f23, $f13, $f23
	MUL	$f27, $f1,  $f13
	LD	$f27, -1*SIZE($3)
	bgt	$6, $MainLoop
	.align 4

$L12:
	SUBC	$f14, $f11, $f14
	unop
	MUL	$f25, $f29, $f11
	unop

	ADDC	$f15, $f10, $f15
	unop
	MUL	$f25, $f28, $f10
	unop

	SUBC	$f22, $f12, $f22
	unop
	MUL	$f25, $f21, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f25, $f30, $f13
	LD	$f25,  0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f24, $f28, $f11
	LD	$f28,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	unop
	MUL	$f24, $f29, $f10
	LD	$f29,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f24, $f30, $f12
	LD	$f30,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f24, $f21, $f13
	LD	$f21,  2*SIZE($1)

	SUBC	$f14, $f11, $f14
	LD	$f24,  1*SIZE($3)
	MUL	$f26, $f16, $f11
	SXADDQ	$20, $1,  $1	

	ADDC	$f15, $f10, $f15
	MUL	$f26, $f0, $f10
	SUBC	$f22, $f12, $f22
	MUL	$f26, $f18, $f12

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f26, $f17, $f13
	LD	$f26,  2*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f27, $f0, $f11
	LD	$f0,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	unop
	MUL	$f27, $f16, $f10
	LD	$f16,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f27, $f17, $f12
	LD	$f17,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	unop
	MUL	$f27, $f18, $f13
	LD	$f27,  3*SIZE($3)

	SUBC	$f14, $f11, $f14
	LD	$f18,  2*SIZE($1)
	MUL	$f25, $f29, $f11
	lda	$3,    4*SIZE($3)

	ADDC	$f15, $f10, $f15
	SXADDQ	$20, $1,  $1
	MUL	$f25, $f28, $f10
	unop

	SUBC	$f22, $f12, $f22
	MUL	$f25, $f21, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f25, $f30, $f13

	ADD	$f14, $f11, $f14
	MUL	$f24, $f28, $f11
	ADD	$f15, $f10, $f15
	MUL	$f24, $f29, $f10

	ADD	$f22, $f12, $f22
	MUL	$f24, $f30, $f12
	ADD	$f23, $f13, $f23
	MUL	$f24, $f21, $f13

	SUBC	$f14, $f11, $f14
	MUL	$f26, $f16, $f11
	ADDC	$f15, $f10, $f15
	MUL	$f26, $f0, $f10

	SUBC	$f22, $f12, $f22
	MUL	$f26, $f18, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f26, $f17, $f13

	ADD	$f14, $f11, $f14
	MUL	$f27, $f0, $f11
	ADD	$f15, $f10, $f15
	MUL	$f27, $f16, $f10

	ADD	$f22, $f12, $f22
	MUL	$f27, $f17, $f12
	ADD	$f23, $f13, $f23
	MUL	$f27, $f18, $f13
	.align 4

$L11:
	and	$25,   3, $6
	ble	$6,$L18

	LD	$f29,  0*SIZE($1)
	LD	$f25,  0*SIZE($3)

	LD	$f28,  1*SIZE($1)
	LD	$f21,  2*SIZE($1)
	LD	$f30,  3*SIZE($1)
	LD	$f24,  1*SIZE($3)

	subl	$6,   1, $6
	SXADDQ	$20, $1, $1
	addq	$3, 2*SIZE, $3
	ble	$6, $L19
	.align	4

$L20:
	SUBC	$f14, $f11, $f14
	MUL	$f25, $f29, $f11
	ADDC	$f15, $f10, $f15
	MUL	$f25, $f28, $f10

	SUBC	$f22, $f12, $f22
	subl	$6,  1, $6
	MUL	$f25, $f21, $f12
	unop

	ADDC	$f23, $f13, $f23
	unop
	MUL	$f25, $f30, $f13
	LD	$f25,  0*SIZE($3)

	ADD	$f14, $f11, $f14
	unop
	MUL	$f24, $f28, $f11
	LD	$f28,  1*SIZE($1)

	ADD	$f15, $f10, $f15
	addq	$3, 2*SIZE, $3
	MUL	$f24, $f29, $f10
	LD	$f29,  0*SIZE($1)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f24, $f30, $f12
	LD	$f30,  3*SIZE($1)

	ADD	$f23, $f13, $f23
	MUL	$f24, $f21, $f13
	LD	$f21,  2*SIZE($1)
	LD	$f24, -1*SIZE($3)

	SXADDQ	$20, $1, $1
	unop
	bgt	$6, $L20
	.align 4

$L19:
	SUBC	$f14, $f11, $f14
	MUL	$f25, $f29, $f11
	ADDC	$f15, $f10, $f15
	MUL	$f25, $f28, $f10

	SUBC	$f22, $f12, $f22
	MUL	$f25, $f21, $f12
	ADDC	$f23, $f13, $f23
	MUL	$f25, $f30, $f13

	ADD	$f14, $f11, $f14
	MUL	$f24, $f28, $f11
	ADD	$f15, $f10, $f15
	MUL	$f24, $f29, $f10

	ADD	$f22, $f12, $f22
	MUL	$f24, $f30, $f12
	ADD	$f23, $f13, $f23
	MUL	$f24, $f21, $f13
	.align 4

$L18:
	SUBC	$f14, $f11, $f14
	SXADDQ	$5, $24,  $6		# dummy
	fnop
	LD	$f29,  0*SIZE($24)

	ADDC	$f15, $f10, $f15
	unop
	LD	$f28,  1*SIZE($24)
	unop

	SUBC	$f22, $f12, $f22
	LD	$f21,  0*SIZE($6)
	ADDC	$f23, $f13, $f23
	LD	$f30,  1*SIZE($6)

	MUL	$f19, $f14, $f11
	MUL	$f20, $f15, $f10
	MUL	$f20, $f14, $f12
	MUL	$f19, $f15, $f13

	MUL	$f19, $f22, $f25
	MUL	$f20, $f23, $f24
	MUL	$f20, $f22, $f26
	MUL	$f19, $f23, $f27

#ifndef XCONJ
	SUBC	$f11, $f10, $f16
	ADDC	$f13, $f12, $f0
	SUBC	$f25, $f24, $f18
	ADDC	$f27, $f26, $f17
#else
	ADDC	$f11, $f10, $f16
	SUBC	$f13, $f12, $f0
	ADDC	$f25, $f24, $f18
	SUBC	$f27, $f26, $f17
#endif

	ADD	$f29, $f16, $f29
	lda	$7,  -1($7)
#ifndef XCONJ
	ADDC	$f28, $f0, $f28
#else
	SUBC	$f28, $f0, $f28
#endif

	ADD	$f21, $f18, $f21

#ifndef XCONJ
	ADDC	$f30, $f17, $f30
#else
	SUBC	$f30, $f17, $f30
#endif

	ST	$f29,  0*SIZE($24)
	fclr	$f12
	ST	$f28,  1*SIZE($24)
	SXADDQ	$5, $24, $24

	ST	$f21,  0*SIZE($24)
	fclr	$f13
	ST	$f30,  1*SIZE($24)
	SXADDQ	$5, $24, $24

	bgt	$7,$L8
	.align 4

$L7:
	fclr	$f11
	addl	$23, $23, $6
	fclr	$f10
	blbc	$16,  $L4

	cmpeq	$28, 2, $0
	fclr	$f14
	SXADDQ	$6, $19, $3		# x_offset = x + js
	fclr	$f15

	cmoveq	$0,  $18, $3
	fclr	$f22
	sra	$25,  1, $6
	fclr	$f23

	mov	$27, $1
	fclr	$f12
	fclr	$f13
	ble	$6,$L28

	LD	$f29,  0*SIZE($1)
	LD	$f25,  0*SIZE($3)
	LD	$f28,  1*SIZE($1)
	LD	$f24,  1*SIZE($3)

	LD	$f26,  2*SIZE($3)
	LD	$f27,  3*SIZE($3)
	SXADDQ	$20, $1,  $1
	lda	$3,    4*SIZE($3)

	LD	$f21,  0*SIZE($1)
	LD	$f30,  1*SIZE($1)
	SXADDQ	$20, $1,  $1
	subl	$6, 1, $6
	ble	$6,$L29
	.align	4

$L30:
	ADD	$f14, $f11, $f14
	unop
	MUL	$f25, $f29, $f11
	unop

	ADD	$f15, $f10, $f15
	subl	$6, 1, $6
	MUL	$f25, $f28, $f10
	LD	$f25,  0*SIZE($3)

	ADD	$f22, $f12, $f22
	unop
	MUL	$f24, $f28, $f12
	LD	$f28,  1*SIZE($1)

	ADD	$f23, $f13, $f23
	MUL	$f24, $f29, $f13
	LD	$f29,  0*SIZE($1)
	LD	$f24,  1*SIZE($3)

	ADD	$f14, $f11, $f14
	SXADDQ	$20, $1,  $1
	MUL	$f26, $f21, $f11
	unop

	ADD	$f15, $f10, $f15
	unop
	MUL	$f26, $f30, $f10
	LD	$f26,  2*SIZE($3)


	ADD	$f22, $f12, $f22
	lda	$3,    4*SIZE($3)
	MUL	$f27, $f30, $f12
	LD	$f30,  1*SIZE($1)

	ADD	$f23, $f13, $f23
	MUL	$f27, $f21, $f13
	LD	$f27, -1*SIZE($3)
	LD	$f21,  0*SIZE($1)

	unop
	SXADDQ	$20, $1,  $1
	unop
	bgt	$6,$L30
	.align 4

$L29:
	ADD	$f14, $f11, $f14
	MUL	$f25, $f29, $f11
	ADD	$f15, $f10, $f15
	MUL	$f25, $f28, $f10

	ADD	$f22, $f12, $f22
	MUL	$f24, $f28, $f12
	ADD	$f23, $f13, $f23
	MUL	$f24, $f29, $f13

	ADD	$f14, $f11, $f14
	MUL	$f26, $f21, $f11
	ADD	$f15, $f10, $f15
	MUL	$f26, $f30, $f10

	ADD	$f22, $f12, $f22
	MUL	$f27, $f30, $f12
	ADD	$f23, $f13, $f23
	MUL	$f27, $f21, $f13
	.align 4

$L28:
	fnop
	nop
	fnop
	blbc	$25,  $L35

	LD	$f29,  0*SIZE($1)
	LD	$f25,  0*SIZE($3)
	LD	$f28,  1*SIZE($1)
	LD	$f24,  1*SIZE($3)

	ADD	$f14, $f11, $f14
	MUL	$f25, $f29, $f11
	ADD	$f15, $f10, $f15
	MUL	$f25, $f28, $f10

	ADD	$f22, $f12, $f22
	MUL	$f24, $f28, $f12
	ADD	$f23, $f13, $f23
	MUL	$f24, $f29, $f13
	.align 4

$L35:
	ADD	$f14, $f11, $f14
	LD	$f29,  0*SIZE($24)
	ADD	$f15, $f10, $f15
	LD	$f28,  1*SIZE($24)

	ADD	$f22, $f12, $f22
	ADD	$f23, $f13, $f23

	SUBC	$f14, $f22, $f14		# ac - bd
	ADDC	$f23, $f15, $f15		# ad + bc

	MUL	$f19, $f14, $f11		# a * c
	MUL	$f20, $f15, $f10		# b * d
	MUL	$f20, $f14, $f12		# b * c
	MUL	$f19, $f15, $f13		# a * d

#ifndef XCONJ
	SUB	$f11, $f10, $f11		# ac - bd
	ADD	$f12, $f13, $f12		# ad + bc
#else
	ADD	$f11, $f10, $f11		# ac - bd
	SUB	$f12, $f13, $f12		# ad + bc
#endif

	ADD	$f29, $f11, $f29
	ADD	$f28, $f12, $f28

	ST	$f29,  0*SIZE($24)
	unop
	ST	$f28,  1*SIZE($24)
	unop
	.align 4

$L4:
	lda	$23,   Q($23)
	cmplt	$23, $17, $1
	bne	$1,  $L5
	.align 4

$End:
	clr	$0
	ret
	.end	CNAME
