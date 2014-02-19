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

#define M	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#define FLAG	ARG6
#else
#define INCY	%r10
#define FLAG	%r11
#endif

#ifdef BARCELONA
#define PREFETCH	prefetch
#define PREFETCHW	prefetchw
#define PREFETCH_SIZE	(16 * 16)
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
#endif

	SAVEREGISTERS

	leaq	(, INCX, SIZE * 2), INCX
	leaq	(, INCY, SIZE * 2), INCY

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y

	cmpq	$2 * SIZE, INCX
	jne	.L40
	cmpq	$2 * SIZE, INCY
	jne	.L40

	testq	$2 * SIZE, Y
	je	.L10

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, -32 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	decq	M
	jle	.L19
	ALIGN_4

.L10:
	testq	$1 * SIZE, Y
	jne	.L40

	testq	$3 * SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L13

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1
	movaps	-24 * SIZE(X), %xmm2
	movaps	-20 * SIZE(X), %xmm3

	movaps	-16 * SIZE(X), %xmm4
	movaps	-12 * SIZE(X), %xmm5
	movaps	 -8 * SIZE(X), %xmm6
	movaps	 -4 * SIZE(X), %xmm7
	decq	%rax
	jle .L12
	ALIGN_3

.L11:
#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0)(X)
#endif

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	 0 * SIZE(X), %xmm0
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	 4 * SIZE(X), %xmm1

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 0)(Y)
#endif

	movaps	%xmm2, -24 * SIZE(Y)
	movaps	 8 * SIZE(X), %xmm2
	movaps	%xmm3, -20 * SIZE(Y)
	movaps	12 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 16)(X)
#endif

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	16 * SIZE(X), %xmm4
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	20 * SIZE(X), %xmm5

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 16)(Y)
#endif

	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	24 * SIZE(X), %xmm6
	movaps	%xmm7,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	movaps	28 * SIZE(X), %xmm7
	subq	$-32 * SIZE, X

	subq	$1, %rax
	jg,pt	.L11
	ALIGN_3

.L12:
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	%xmm7,  -4 * SIZE(Y)

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L13:
	testq	$8, M
	jle	.L14
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1
	movaps	-24 * SIZE(X), %xmm2
	movaps	-20 * SIZE(X), %xmm3

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L14:
	testq	$4, M
	jle	.L15
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L15:
	testq	$2, M
	jle	.L16
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	%xmm0, -32 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L16:
	testq	$1, M
	jle	.L19
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, 	-32 * SIZE(Y)

	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	movq	M,  %rax
	sarq	$4, %rax
	jle	.L23

	movsd	-32 * SIZE(X), %xmm0
	movhps	-30 * SIZE(X), %xmm0
	movsd	-28 * SIZE(X), %xmm1
	movhps	-26 * SIZE(X), %xmm1
	movsd	-24 * SIZE(X), %xmm2
	movhps	-22 * SIZE(X), %xmm2
	movsd	-20 * SIZE(X), %xmm3
	movhps	-18 * SIZE(X), %xmm3

	movsd	-16 * SIZE(X), %xmm4
	movhps	-14 * SIZE(X), %xmm4
	movsd	-12 * SIZE(X), %xmm5
	movhps	-10 * SIZE(X), %xmm5
	movsd	 -8 * SIZE(X), %xmm6
	movhps	 -6 * SIZE(X), %xmm6
	movsd	 -4 * SIZE(X), %xmm7
	movhps	 -2 * SIZE(X), %xmm7

	decq	%rax
	jle .L22
	ALIGN_3

.L21:
#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0)(X)
#endif

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 0)(Y)
#endif

	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movsd	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1
	movsd	 8 * SIZE(X), %xmm2
	movhps	10 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm3
	movhps	14 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 16)(X)
#endif

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	%xmm7,  -4 * SIZE(Y)

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 16)(Y)
#endif

	movsd	16 * SIZE(X), %xmm4
	movhps	18 * SIZE(X), %xmm4
	movsd	20 * SIZE(X), %xmm5
	movhps	22 * SIZE(X), %xmm5
	movsd	24 * SIZE(X), %xmm6
	movhps	26 * SIZE(X), %xmm6
	movsd	28 * SIZE(X), %xmm7
	movhps	30 * SIZE(X), %xmm7

	subq	$-32 * SIZE, Y
	subq	$-32 * SIZE, X
	subq	$1, %rax
	jg,pt	.L21
	ALIGN_3

.L22:
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	%xmm7,  -4 * SIZE(Y)

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L23:
	testq	$8, M
	jle	.L24
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movhps	-30 * SIZE(X), %xmm0
	movsd	-28 * SIZE(X), %xmm1
	movhps	-26 * SIZE(X), %xmm1
	movsd	-24 * SIZE(X), %xmm2
	movhps	-22 * SIZE(X), %xmm2
	movsd	-20 * SIZE(X), %xmm3
	movhps	-18 * SIZE(X), %xmm3

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L24:
	testq	$4, M
	jle	.L25
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movhps	-30 * SIZE(X), %xmm0
	movsd	-28 * SIZE(X), %xmm1
	movhps	-26 * SIZE(X), %xmm1

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	testq	$2, M
	jle	.L26
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movhps	-30 * SIZE(X), %xmm0

	movaps	%xmm0, -32 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	testq	$1, M
	jle	.L29
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, 	-32 * SIZE(Y)
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L40:
	addq	$-32 * SIZE, X
	addq	$-32 * SIZE, Y

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L45
	ALIGN_3

.L41:
	movsd	0 * SIZE(X), %xmm0
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm3
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X

	movsd	%xmm0, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm1, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm2, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm3, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm4, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm5, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm6, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm7, 0 * SIZE(Y)
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
	movsd	(X), %xmm0
	addq	INCX, X
	movsd	%xmm0, (Y)
	addq	INCY, Y
	decq	%rax
	jg	.L46
	ALIGN_3

.L47:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE
