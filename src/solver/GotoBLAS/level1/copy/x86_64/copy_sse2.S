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
#define PREFETCH_SIZE	(12 * 16)
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
#endif

	SAVEREGISTERS

	leaq	(, INCX, SIZE), INCX
	leaq	(, INCY, SIZE), INCY

	cmpq	$SIZE, INCX
	jne	.L40
	cmpq	$SIZE, INCY
	jne	.L40

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	
	testq	$SIZE, Y
	je	.L10

	movsd	-16 * SIZE(X), %xmm0
	movsd	%xmm0, -16 * SIZE(Y)

	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	jle	.L19
	ALIGN_4

.L10:
	testq	$SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L13

	movapd	 -16 * SIZE(X), %xmm0
	movapd	 -14 * SIZE(X), %xmm1
	movapd	 -12 * SIZE(X), %xmm2
	movapd	 -10 * SIZE(X), %xmm3

	movapd	  -8 * SIZE(X), %xmm4
	movapd	  -6 * SIZE(X), %xmm5
	movapd	  -4 * SIZE(X), %xmm6
	movapd	  -2 * SIZE(X), %xmm7
	decq	%rax
	jle .L12
	ALIGN_3

.L11:
#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0)(X)
#endif

	movapd	%xmm0, -16 * SIZE(Y)
	movapd	 0 * SIZE(X), %xmm0
	movapd	%xmm1, -14 * SIZE(Y)
 	movapd	 2 * SIZE(X), %xmm1

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 0)(Y)
#endif

	movapd	%xmm2, -12 * SIZE(Y)
	movapd	 4 * SIZE(X), %xmm2
	movapd	%xmm3, -10 * SIZE(Y)
	movapd	 6 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 8)(X)
#endif

	movapd	%xmm4,  -8 * SIZE(Y)
	movapd	 8 * SIZE(X), %xmm4
	movapd	%xmm5,  -6 * SIZE(Y)
 	movapd	10 * SIZE(X), %xmm5

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 8)(Y)
#endif

	movapd	%xmm6,  -4 * SIZE(Y)
	movapd	12 * SIZE(X), %xmm6
	movapd	%xmm7,  -2 * SIZE(Y)
	subq	$-16 * SIZE, Y
	movapd	14 * SIZE(X), %xmm7
	subq	$-16 * SIZE, X

	subq	$1, %rax
	jg,pt	.L11
	ALIGN_3

.L12:
	movapd	%xmm0, -16 * SIZE(Y)
	movapd	%xmm1, -14 * SIZE(Y)
	movapd	%xmm2, -12 * SIZE(Y)
	movapd	%xmm3, -10 * SIZE(Y)

	movapd	%xmm4,  -8 * SIZE(Y)
	movapd	%xmm5,  -6 * SIZE(Y)
	movapd	%xmm6,  -4 * SIZE(Y)
	movapd	%xmm7,  -2 * SIZE(Y)

	subq	$-16 * SIZE, Y
	subq	$-16 * SIZE, X
	ALIGN_3

.L13:
	testq	$8, M
	jle	.L14
	ALIGN_3

	movapd	-16 * SIZE(X), %xmm0
	movapd	-14 * SIZE(X), %xmm1
	movapd	-12 * SIZE(X), %xmm2
	movapd	-10 * SIZE(X), %xmm3

	movapd	%xmm0, -16 * SIZE(Y)
	movapd	%xmm1, -14 * SIZE(Y)
	movapd	%xmm2, -12 * SIZE(Y)
	movapd	%xmm3, -10 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L14:
	testq	$4, M
	jle	.L15
	ALIGN_3

	movapd	-16 * SIZE(X), %xmm0
	movapd	-14 * SIZE(X), %xmm1
	movapd	%xmm0, -16 * SIZE(Y)
	movapd	%xmm1, -14 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L15:
	testq	$2, M
	jle	.L16
	ALIGN_3

	movapd	-16 * SIZE(X), %xmm0
	movapd	%xmm0, -16 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L16:
	testq	$1, M
	jle	.L19
	ALIGN_3

	movsd	-16 * SIZE(X), %xmm0
	movsd	%xmm0, 	-16 * SIZE(Y)
	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	movapd	-17 * SIZE(X), %xmm0

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L23

	movapd	 -15 * SIZE(X), %xmm1
	movapd	 -13 * SIZE(X), %xmm2
	movapd	 -11 * SIZE(X), %xmm3
	movapd	  -9 * SIZE(X), %xmm4
	movapd	  -7 * SIZE(X), %xmm5
	movapd	  -5 * SIZE(X), %xmm6
	movapd	  -3 * SIZE(X), %xmm7

	decq	%rax
	jle .L22
	ALIGN_4

.L21:
#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0)(X)
#endif

	SHUFPD_1 %xmm1, %xmm0
	movapd	%xmm0, -16 * SIZE(Y)
	movapd	 -1 * SIZE(X), %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movapd	%xmm1, -14 * SIZE(Y)
	movapd	  1 * SIZE(X), %xmm1

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 0)(Y)
#endif

	SHUFPD_1 %xmm3, %xmm2
	movapd	%xmm2, -12 * SIZE(Y)
	movapd	  3 * SIZE(X), %xmm2
	SHUFPD_1 %xmm4, %xmm3
	movapd	%xmm3, -10 * SIZE(Y)
	movapd	  5 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 8)(X)
#endif

	SHUFPD_1 %xmm5, %xmm4
	movapd	%xmm4,  -8 * SIZE(Y)
	movapd	  7 * SIZE(X), %xmm4
	SHUFPD_1 %xmm6, %xmm5
	movapd	%xmm5,  -6 * SIZE(Y)
	movapd	  9 * SIZE(X), %xmm5

#ifdef BARCELONA
	PREFETCHW	(PREFETCH_SIZE + 8)(Y)
#endif

	SHUFPD_1 %xmm7, %xmm6
	movapd	%xmm6,  -4 * SIZE(Y)
	movapd	 11 * SIZE(X), %xmm6
	SHUFPD_1 %xmm0, %xmm7
	movapd	%xmm7,  -2 * SIZE(Y)
	subq	$-16 * SIZE, Y
	movapd	 13 * SIZE(X), %xmm7
	subq	$-16 * SIZE, X

	subq	$1, %rax
	jg,pt	.L21
	ALIGN_3

.L22:
	SHUFPD_1 %xmm1, %xmm0
	movapd	%xmm0, -16 * SIZE(Y)
	movapd	 -1 * SIZE(X), %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movapd	%xmm1, -14 * SIZE(Y)
	SHUFPD_1 %xmm3, %xmm2
	movapd	%xmm2, -12 * SIZE(Y)
	SHUFPD_1 %xmm4, %xmm3
	movapd	%xmm3, -10 * SIZE(Y)

	SHUFPD_1 %xmm5, %xmm4
	movapd	%xmm4,  -8 * SIZE(Y)
	SHUFPD_1 %xmm6, %xmm5
	movapd	%xmm5,  -6 * SIZE(Y)
	SHUFPD_1 %xmm7, %xmm6
	movapd	%xmm6,  -4 * SIZE(Y)
	subq	$-16 * SIZE, X
	SHUFPD_1 %xmm0, %xmm7
	movapd	%xmm7,  -2 * SIZE(Y)
	subq	$-16 * SIZE, Y
	ALIGN_3

.L23:
	testq	$8, M
	jle	.L24
	ALIGN_3

	movapd	-15 * SIZE(X), %xmm1
	movapd	-13 * SIZE(X), %xmm2
	movapd	-11 * SIZE(X), %xmm3
	movapd	 -9 * SIZE(X), %xmm8

	SHUFPD_1 %xmm1, %xmm0
	movapd	%xmm0, -16 * SIZE(Y)
	movapd	%xmm8, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movapd	%xmm1, -14 * SIZE(Y)
	SHUFPD_1 %xmm3, %xmm2
	movapd	%xmm2, -12 * SIZE(Y)
	addq	$8 * SIZE, X
	SHUFPD_1 %xmm8, %xmm3
	movapd	%xmm3, -10 * SIZE(Y)
	addq	$8 * SIZE, Y
	ALIGN_3

.L24:
	testq	$4, M
	jle	.L25
	ALIGN_3

	movapd	-15 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	movapd	-13 * SIZE(X), %xmm2
	SHUFPD_1 %xmm2, %xmm1

	movapd	%xmm0, -16 * SIZE(Y)
	movapd	%xmm1, -14 * SIZE(Y)
	movapd	%xmm2, %xmm0

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L25:
	testq	$2, M
	jle	.L26
	ALIGN_3

	movapd	-15 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	movapd	%xmm0, -16 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L26:
	testq	$1, M
	jle	.L29
	ALIGN_3

	movsd	-16 * SIZE(X), %xmm0
	movsd	%xmm0, 	-16 * SIZE(Y)
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3


.L40:
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
