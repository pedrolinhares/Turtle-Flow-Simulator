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

#ifndef WINDOWS_ABI
#define M	ARG1
#define X	ARG4
#define INCX	ARG5
#define Y	ARG6
#define INCY	ARG2
#else
#define M	ARG1
#define X	ARG2
#define INCX	ARG3
#define Y	ARG4
#define INCY	%r10
#endif

#define	YY	%r11
#define ALPHA	%xmm15

#define PREFETCH	prefetch
#define PREFETCHW	prefetchw
#define PREFETCHSIZE	(16 * 8 + 4)

	PROLOGUE
	PROFCODE

#ifndef WINDOWS_ABI
#ifndef XDOUBLE
	movq	 8(%rsp), INCY
#else
	movq	24(%rsp), INCY
#endif
	movaps	%xmm0,  ALPHA
#else
	movaps	%xmm3,  ALPHA

	movq	40(%rsp), X
	movq	48(%rsp), INCX
	movq	56(%rsp), Y
	movq	64(%rsp), INCY
#endif

	SAVEREGISTERS
	
	shufps	$0, ALPHA, ALPHA

	leaq	(, INCX, SIZE), INCX
	leaq	(, INCY, SIZE), INCY

	cmpq	$SIZE, INCX
	jne	.L40
	cmpq	$SIZE, INCY
	jne	.L40

	cmpq	$3, M
	jle	.L16

	testq	$SIZE, Y
	je	.L05

	movss	(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	ALIGN_3

.L05:
	testq	$2 * SIZE, Y
	je	.L10

	movsd	(X), %xmm0
	mulps	ALPHA, %xmm0
	movsd	(Y), %xmm1
	addps	%xmm1, %xmm0
	movlps	%xmm0, (Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	subq	$2, M
	jle	.L19
	ALIGN_3

.L10:
	testq	$3 * SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$5, %rax
	jle	.L13

	movaps	 0 * SIZE(X), %xmm0
	movaps	 4 * SIZE(X), %xmm1
	movaps	 8 * SIZE(X), %xmm2
	movaps	12 * SIZE(X), %xmm3
	movaps	16 * SIZE(X), %xmm8
	movaps	20 * SIZE(X), %xmm9
	movaps	24 * SIZE(X), %xmm10
	movaps	28 * SIZE(X), %xmm11

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	decq	%rax
	jle .L12
	ALIGN_3

.L11:
	addps	 0 * SIZE(Y), %xmm0
	mulps	ALPHA, %xmm8

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)

	addps	 4 * SIZE(Y), %xmm1
	mulps	ALPHA, %xmm9
	addps	 8 * SIZE(Y), %xmm2
	mulps	ALPHA, %xmm10
	addps	12 * SIZE(Y), %xmm3
	mulps	ALPHA, %xmm11

	PREFETCHW	(PREFETCHSIZE + 0) * SIZE(Y)

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	movaps	32 * SIZE(X), %xmm0
	movaps	36 * SIZE(X), %xmm1
	movaps	40 * SIZE(X), %xmm2
	movaps	44 * SIZE(X), %xmm3

	addps	16 * SIZE(Y), %xmm8
	mulps	ALPHA, %xmm0

	PREFETCH	(PREFETCHSIZE + 16) * SIZE(X)

	addps	20 * SIZE(Y), %xmm9
	mulps	ALPHA, %xmm1
	addps	24 * SIZE(Y), %xmm10
	mulps	ALPHA, %xmm2
	addps	28 * SIZE(Y), %xmm11
	mulps	ALPHA, %xmm3

	PREFETCHW	(PREFETCHSIZE + 16) * SIZE(Y)

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	movaps	48 * SIZE(X), %xmm8
	movaps	52 * SIZE(X), %xmm9
	movaps	56 * SIZE(X), %xmm10
	movaps	60 * SIZE(X), %xmm11

	subq	$-32 * SIZE, Y
	subq	$-32 * SIZE, X
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	addps	 0 * SIZE(Y), %xmm0
	mulps	ALPHA, %xmm8
	addps	 4 * SIZE(Y), %xmm1
	mulps	ALPHA, %xmm9
	addps	 8 * SIZE(Y), %xmm2
	mulps	ALPHA, %xmm10
	addps	12 * SIZE(Y), %xmm3
	mulps	ALPHA, %xmm11

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addps	16 * SIZE(Y), %xmm8
	addps	20 * SIZE(Y), %xmm9
	addps	24 * SIZE(Y), %xmm10
	addps	28 * SIZE(Y), %xmm11

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L13:
	testq	$31, M
	jle	.L19

	testq	$16, M
	jle	.L14

	movaps	 0 * SIZE(X), %xmm0
	movaps	 4 * SIZE(X), %xmm1
	movaps	 8 * SIZE(X), %xmm2
	movaps	12 * SIZE(X), %xmm3

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	addps	 0 * SIZE(Y), %xmm0
	addps	 4 * SIZE(Y), %xmm1
	addps	 8 * SIZE(Y), %xmm2
	addps	12 * SIZE(Y), %xmm3

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L14:
	testq	$8, M
	jle	.L15

	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(X), %xmm1

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1

	addps	0 * SIZE(Y), %xmm0
	addps	4 * SIZE(Y), %xmm1

	movaps	%xmm0, 0 * SIZE(Y)
	movaps	%xmm1, 4 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L15:
	testq	$4, M
	jle	.L16

	movaps	0 * SIZE(X), %xmm0

	mulps	ALPHA, %xmm0

	addps	0 * SIZE(Y), %xmm0

	movaps	%xmm0, 0 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L16:
	testq	$2, M
	jle	.L17

	movsd	(X), %xmm0
	mulps	ALPHA, %xmm0
	movsd	(Y), %xmm1
	addps	%xmm1, %xmm0
	movlps	%xmm0, (Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L17:
	testq	$1, M
	jle	.L19

	movss	0 * SIZE(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	0 * SIZE(Y), %xmm0

	movss	%xmm0, 	0 * SIZE(Y)
	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	movq	M,  %rax
	sarq	$5, %rax
	jle	.L23

	movlps	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movlps	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1
	movlps	 8 * SIZE(X), %xmm2
	movhps	10 * SIZE(X), %xmm2
	movlps	12 * SIZE(X), %xmm3
	movhps	14 * SIZE(X), %xmm3
	movlps	16 * SIZE(X), %xmm8
	movhps	18 * SIZE(X), %xmm8
	movlps	20 * SIZE(X), %xmm9
	movhps	22 * SIZE(X), %xmm9
	movlps	24 * SIZE(X), %xmm10
	movhps	26 * SIZE(X), %xmm10
	movlps	28 * SIZE(X), %xmm11
	movhps	30 * SIZE(X), %xmm11

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	decq	%rax
	jle .L22
	ALIGN_3

.L21:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)

	addps	 0 * SIZE(Y), %xmm0
	mulps	ALPHA, %xmm8
	addps	 4 * SIZE(Y), %xmm1
	mulps	ALPHA, %xmm9
	addps	 8 * SIZE(Y), %xmm2
	mulps	ALPHA, %xmm10
	addps	12 * SIZE(Y), %xmm3
	mulps	ALPHA, %xmm11

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	PREFETCHW	(PREFETCHSIZE + 0) * SIZE(Y)

	movlps	32 * SIZE(X), %xmm0
	movhps	34 * SIZE(X), %xmm0
	movlps	36 * SIZE(X), %xmm1
	movhps	38 * SIZE(X), %xmm1
	movlps	40 * SIZE(X), %xmm2
	movhps	42 * SIZE(X), %xmm2
	movlps	44 * SIZE(X), %xmm3
	movhps	46 * SIZE(X), %xmm3

	PREFETCH	(PREFETCHSIZE + 16) * SIZE(X)

	addps	16 * SIZE(Y), %xmm8
	mulps	ALPHA, %xmm0
	addps	20 * SIZE(Y), %xmm9
	mulps	ALPHA, %xmm1
	addps	24 * SIZE(Y), %xmm10
	mulps	ALPHA, %xmm2
	addps	28 * SIZE(Y), %xmm11
	mulps	ALPHA, %xmm3

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	PREFETCHW	(PREFETCHSIZE + 16) * SIZE(Y)

	movlps	48 * SIZE(X), %xmm8
	movhps	50 * SIZE(X), %xmm8
	movlps	52 * SIZE(X), %xmm9
	movhps	54 * SIZE(X), %xmm9
	movlps	56 * SIZE(X), %xmm10
	movhps	58 * SIZE(X), %xmm10
	movlps	60 * SIZE(X), %xmm11
	movhps	62 * SIZE(X), %xmm11

	addq	$32 * SIZE, Y
	addq	$32 * SIZE, X
	decq	%rax
	jg	.L21
	ALIGN_3

.L22:
	addps	 0 * SIZE(Y), %xmm0
	mulps	ALPHA, %xmm8
	addps	 4 * SIZE(Y), %xmm1
	mulps	ALPHA, %xmm9
	addps	 8 * SIZE(Y), %xmm2
	mulps	ALPHA, %xmm10
	addps	12 * SIZE(Y), %xmm3
	mulps	ALPHA, %xmm11

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addps	16 * SIZE(Y), %xmm8
	addps	20 * SIZE(Y), %xmm9
	addps	24 * SIZE(Y), %xmm10
	addps	28 * SIZE(Y), %xmm11

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L23:
	testq	$31, M
	jle	.L29

	testq	$16, M
	jle	.L24

	movlps	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movlps	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1
	movlps	 8 * SIZE(X), %xmm2
	movhps	10 * SIZE(X), %xmm2
	movlps	12 * SIZE(X), %xmm3
	movhps	14 * SIZE(X), %xmm3

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	addps	 0 * SIZE(Y), %xmm0
	addps	 4 * SIZE(Y), %xmm1
	addps	 8 * SIZE(Y), %xmm2
	addps	12 * SIZE(Y), %xmm3

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L24:
	testq	$8, M
	jle	.L25

	movlps	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movlps	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1

	addps	 0 * SIZE(Y), %xmm0
	addps	 4 * SIZE(Y), %xmm1

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	testq	$4, M
	jle	.L26

	movlps	0 * SIZE(X), %xmm0
	movhps	2 * SIZE(X), %xmm0

	mulps	ALPHA, %xmm0

	addps	0 * SIZE(Y), %xmm0

	movaps	%xmm0, 0 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	testq	$2, M
	jle	.L27

	movsd	(X), %xmm0
	mulps	ALPHA, %xmm0
	movsd	(Y), %xmm1
	addps	%xmm1, %xmm0
	movlps	%xmm0, (Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L27:
	testq	$1, M
	jle	.L29

	movss	0 * SIZE(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	0 * SIZE(Y), %xmm0

	movss	%xmm0, 	0 * SIZE(Y)
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L40:
	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L45
	ALIGN_3

.L41:
	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addq	INCX, X
	addss	(Y), %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y

	decq	%rax
	jg	.L41
	ALIGN_3

.L45:
	movq	M,  %rax
	andq	$7, %rax
	jle	.L47
	ALIGN_3

.L46:
	movss	(X), %xmm0
	mulss	%xmm15, %xmm0
	addss	(Y), %xmm0
	movss	%xmm0, (Y)

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L46
	ALIGN_3

.L47:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret

	EPILOGUE
