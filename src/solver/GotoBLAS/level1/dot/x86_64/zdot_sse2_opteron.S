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

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
#define RESULT	ARG1	/* rdi */
#define N	ARG2	/* rsi */
#define X	ARG3	/* rdx */
#define INCX	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define Y	ARG5	/* r8  */
#define INCY	ARG6	/* r9  */
#else
#define Y	%r10
#define INCY	%r11
#endif
#else
#define N	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#else
#define INCY	%r10
#endif
#endif

#ifdef BARCELONA
#define PREFETCH_SIZE_X (8 * 9 + 2)
#define PREFETCH_SIZE_Y (8 * 9 - 2)
#else
#define PREFETCH_SIZE_X (8 * 9 + 2)
#define PREFETCH_SIZE_Y (8 * 9 - 2)
#endif

#ifdef BARCELONA
#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c, d, e)	movddup	a(b, c, d), e
#else
#define MOVDDUP(a, b, c)	movlpd	a(b), c;movhpd	a(b), c
#define MOVDDUP2(a, b, c, d, e)	movlpd	a(b, c, d), e;movhpd	a(b, c, d), e
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
		movq	40(%rsp), Y
		movq	48(%rsp), INCY

#else
		movq	40(%rsp), INCY
#endif
#endif

	SAVEREGISTERS

#ifdef F_INTERFACE
#ifndef USE64BITINT
	movslq	(N), N			# N
	movslq	(INCX),INCX		# INCX
	movslq	(INCY),INCY		# INCY
#else
	movq	(N), N			# N
	movq	(INCX),INCX		# INCX
	movq	(INCY),INCY		# INCY
#endif
#endif

	salq	$ZBASE_SHIFT, INCX
	salq	$ZBASE_SHIFT, INCY

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	cmpq	$0, N
	jle	.L18

	cmpq	$2 * SIZE, INCX
	jne	.L50
	cmpq	$2 * SIZE, INCY
	jne	.L50

	testq	$SIZE, X
	jne	.L20

	movq	N,   %rax
	andq	$-8, %rax
	jle	.L15

	addq	%rax, %rax

	leaq	(X, %rax, 8), X
	leaq	(Y, %rax, 8), Y
	negq	%rax

	MOVDDUP2(0 * SIZE, Y, %rax, 8, %xmm4)
	mulpd	0 * SIZE(X, %rax, 8), %xmm4
	MOVDDUP2(1 * SIZE, Y, %rax, 8, %xmm5)
	mulpd	0 * SIZE(X, %rax, 8), %xmm5

	MOVDDUP2(2 * SIZE, Y, %rax, 8, %xmm6)
	mulpd	2 * SIZE(X, %rax, 8), %xmm6
	MOVDDUP2(3 * SIZE, Y, %rax, 8, %xmm7)
	mulpd	2 * SIZE(X, %rax, 8), %xmm7

	MOVDDUP2(4 * SIZE, Y, %rax, 8, %xmm8)
	mulpd	4 * SIZE(X, %rax, 8), %xmm8
	MOVDDUP2(5 * SIZE, Y, %rax, 8, %xmm9)
 	mulpd	4 * SIZE(X, %rax, 8), %xmm9

	MOVDDUP2(6 * SIZE, Y, %rax, 8, %xmm10)
 	mulpd	6 * SIZE(X, %rax, 8), %xmm10
	MOVDDUP2(7 * SIZE, Y, %rax, 8, %xmm11)
	mulpd	6 * SIZE(X, %rax, 8), %xmm11

	subq	$-16, %rax
	jge	.L12
	ALIGN_3

.L11:
	PREFETCH	(PREFETCH_SIZE_X + 0) * SIZE(X, %rax, 8)

	addpd	 %xmm4, %xmm0
	MOVDDUP2(-8 * SIZE, Y, %rax, 8, %xmm4)
	mulpd	 -8 * SIZE(X, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2(-7 * SIZE, Y, %rax, 8, %xmm5)
	mulpd	 -8 * SIZE(X, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2(-6 * SIZE, Y, %rax, 8, %xmm6)
	mulpd	-6 * SIZE(X, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2(-5 * SIZE, Y, %rax, 8, %xmm7)
	mulpd	-6 * SIZE(X, %rax, 8), %xmm7

   	PREFETCH	(PREFETCH_SIZE_Y + 0) * SIZE(Y, %rax, 8)

	addpd	 %xmm8,  %xmm0
	MOVDDUP2(-4 * SIZE, Y, %rax, 8, %xmm8)
 	mulpd	-4 * SIZE(X, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2(-3 * SIZE, Y, %rax, 8, %xmm9)
	mulpd	-4 * SIZE(X, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2(-2 * SIZE, Y, %rax, 8, %xmm10)
	mulpd	-2 * SIZE(X, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
	MOVDDUP2(-1 * SIZE, Y, %rax, 8, %xmm11)
	mulpd	-2 * SIZE(X, %rax, 8), %xmm11

	PREFETCH	(PREFETCH_SIZE_X + 8) * SIZE(X, %rax, 8)

	addpd	 %xmm4, %xmm0
	MOVDDUP2( 0 * SIZE, Y, %rax, 8, %xmm4)
 	mulpd	 0 * SIZE(X, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2( 1 * SIZE, Y, %rax, 8, %xmm5)
 	mulpd	 0 * SIZE(X, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2( 2 * SIZE, Y, %rax, 8, %xmm6)
	mulpd	 2 * SIZE(X, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2( 3 * SIZE, Y, %rax, 8, %xmm7)
	mulpd	 2 * SIZE(X, %rax, 8), %xmm7

	PREFETCH	(PREFETCH_SIZE_Y + 8) * SIZE(Y, %rax, 8)

	addpd	 %xmm8,  %xmm0
	MOVDDUP2( 4 * SIZE, Y, %rax, 8, %xmm8)
	mulpd	 4 * SIZE(X, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2( 5 * SIZE, Y, %rax, 8, %xmm9)
	mulpd	 4 * SIZE(X, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2( 6 * SIZE, Y, %rax, 8, %xmm10)
	mulpd	 6 * SIZE(X, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
 	MOVDDUP2( 7 * SIZE, Y, %rax, 8, %xmm11)
	mulpd	 6 * SIZE(X, %rax, 8), %xmm11

	subq	$-16, %rax
	jl,pt	.L11
	ALIGN_3

.L12:
	addpd	 %xmm4, %xmm0
 	MOVDDUP2( -8 * SIZE, Y, %rax, 8, %xmm4)
	mulpd	 -8 * SIZE(X, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2(-7 * SIZE, Y, %rax, 8, %xmm5)
	mulpd	-8 * SIZE(X, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2(-6 * SIZE, Y, %rax, 8, %xmm6)
	mulpd	-6 * SIZE(X, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2(-5 * SIZE, Y, %rax, 8, %xmm7)
	mulpd	-6 * SIZE(X, %rax, 8), %xmm7

	addpd	 %xmm8,  %xmm0
	MOVDDUP2(-4 * SIZE, Y, %rax, 8, %xmm8)
	mulpd	-4 * SIZE(X, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2(-3 * SIZE, Y, %rax, 8, %xmm9)
	mulpd	-4 * SIZE(X, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2(-2 * SIZE, Y, %rax, 8, %xmm10)
	mulpd	-2 * SIZE(X, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
	MOVDDUP2(-1 * SIZE, Y, %rax, 8, %xmm11)
	mulpd	-2 * SIZE(X, %rax, 8), %xmm11

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3
	ALIGN_3

.L15:
	testq	$7, N
	je	.L18

	movq	N,  %rax
	andq	$4, %rax
	jle	.L16

	MOVDDUP(0 * SIZE, Y, %xmm4)
	MOVDDUP(1 * SIZE, Y, %xmm5)
	MOVDDUP(2 * SIZE, Y, %xmm6)
	MOVDDUP(3 * SIZE, Y, %xmm7)

	mulpd	0 * SIZE(X), %xmm4
	mulpd	0 * SIZE(X), %xmm5
	mulpd	2 * SIZE(X), %xmm6
	mulpd	2 * SIZE(X), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	MOVDDUP(4 * SIZE, Y, %xmm8)
	MOVDDUP(5 * SIZE, Y, %xmm9)
	MOVDDUP(6 * SIZE, Y, %xmm10)
	MOVDDUP(7 * SIZE, Y, %xmm11)

	mulpd	4 * SIZE(X), %xmm8
	mulpd	4 * SIZE(X), %xmm9
	mulpd	6 * SIZE(X), %xmm10
	mulpd	6 * SIZE(X), %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L17

	MOVDDUP(0 * SIZE, Y, %xmm4)
	MOVDDUP(1 * SIZE, Y, %xmm5)
	MOVDDUP(2 * SIZE, Y, %xmm6)
	MOVDDUP(3 * SIZE, Y, %xmm7)

	mulpd	0 * SIZE(X), %xmm4
	mulpd	0 * SIZE(X), %xmm5
	mulpd	2 * SIZE(X), %xmm6
	mulpd	2 * SIZE(X), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L18

	MOVDDUP(0 * SIZE, Y, %xmm4)
	MOVDDUP(1 * SIZE, Y, %xmm5)

	mulpd	0 * SIZE(X), %xmm4
	mulpd	0 * SIZE(X), %xmm5

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	ALIGN_3

.L18:
	addpd	%xmm0, %xmm2
	addpd	%xmm1, %xmm3

	movapd	%xmm2,  %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	%xmm3, %xmm1
	unpckhpd %xmm3, %xmm3

#ifndef CONJ
	subsd	 %xmm3, %xmm0
	addsd	 %xmm2, %xmm1
#else
	addsd	 %xmm3, %xmm0
	subsd	 %xmm2, %xmm1
#endif

.L19:
#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movlpd	%xmm0, 0 * SIZE(RESULT)
	movlpd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	testq	$SIZE, Y
	jne	.L30

	movq	N,   %rax
	andq	$-8, %rax
	jle	.L25

	addq	%rax, %rax

	leaq	(X, %rax, 8), X
	leaq	(Y, %rax, 8), Y
	negq	%rax

	MOVDDUP2(0 * SIZE, X, %rax, 8, %xmm4)
	mulpd	0 * SIZE(Y, %rax, 8), %xmm4
	MOVDDUP2(1 * SIZE, X, %rax, 8, %xmm5)
	mulpd	0 * SIZE(Y, %rax, 8), %xmm5

	MOVDDUP2(2 * SIZE, X, %rax, 8, %xmm6)
	mulpd	2 * SIZE(Y, %rax, 8), %xmm6
	MOVDDUP2(3 * SIZE, X, %rax, 8, %xmm7)
	mulpd	2 * SIZE(Y, %rax, 8), %xmm7

	MOVDDUP2(4 * SIZE, X, %rax, 8, %xmm8)
	mulpd	4 * SIZE(Y, %rax, 8), %xmm8
	MOVDDUP2(5 * SIZE, X, %rax, 8, %xmm9)
 	mulpd	4 * SIZE(Y, %rax, 8), %xmm9

	MOVDDUP2(6 * SIZE, X, %rax, 8, %xmm10)
 	mulpd	6 * SIZE(Y, %rax, 8), %xmm10
	MOVDDUP2(7 * SIZE, X, %rax, 8, %xmm11)
	mulpd	6 * SIZE(Y, %rax, 8), %xmm11

	subq	$-16, %rax
	jge	.L22
	ALIGN_3

.L21:
   	PREFETCH	(PREFETCH_SIZE_X + 0) * SIZE(X, %rax, 8)

	addpd	 %xmm4, %xmm0
	MOVDDUP2(-8 * SIZE, X, %rax, 8, %xmm4)
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2(-7 * SIZE, X, %rax, 8, %xmm5)
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2(-6 * SIZE, X, %rax, 8, %xmm6)
	mulpd	-6 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2(-5 * SIZE, X, %rax, 8, %xmm7)
	mulpd	-6 * SIZE(Y, %rax, 8), %xmm7

	PREFETCH	(PREFETCH_SIZE_Y + 0) * SIZE(Y, %rax, 8)

	addpd	 %xmm8,  %xmm0
	MOVDDUP2(-4 * SIZE, X, %rax, 8, %xmm8)
 	mulpd	-4 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2(-3 * SIZE, X, %rax, 8, %xmm9)
	mulpd	-4 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2(-2 * SIZE, X, %rax, 8, %xmm10)
	mulpd	-2 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
	MOVDDUP2(-1 * SIZE, X, %rax, 8, %xmm11)
	mulpd	-2 * SIZE(Y, %rax, 8), %xmm11

	PREFETCH	(PREFETCH_SIZE_X + 8) * SIZE(X, %rax, 8)

	addpd	 %xmm4, %xmm0
	MOVDDUP2( 0 * SIZE, X, %rax, 8, %xmm4)
 	mulpd	 0 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2( 1 * SIZE, X, %rax, 8, %xmm5)
 	mulpd	 0 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2( 2 * SIZE, X, %rax, 8, %xmm6)
	mulpd	 2 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2( 3 * SIZE, X, %rax, 8, %xmm7)
	mulpd	 2 * SIZE(Y, %rax, 8), %xmm7

	PREFETCH	(PREFETCH_SIZE_Y + 8) * SIZE(Y, %rax, 8)

	addpd	 %xmm8,  %xmm0
	MOVDDUP2( 4 * SIZE, X, %rax, 8, %xmm8)
	mulpd	 4 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2( 5 * SIZE, X, %rax, 8, %xmm9)
	mulpd	 4 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2( 6 * SIZE, X, %rax, 8, %xmm10)
	mulpd	 6 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
 	MOVDDUP2( 7 * SIZE, X, %rax, 8, %xmm11)
	mulpd	 6 * SIZE(Y, %rax, 8), %xmm11

	subq	$-16, %rax
	jl,pt	.L21
	ALIGN_3

.L22:
	addpd	 %xmm4, %xmm0
 	MOVDDUP2( -8 * SIZE, X, %rax, 8, %xmm4)
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm5, %xmm1
	MOVDDUP2(-7 * SIZE, X, %rax, 8, %xmm5)
	mulpd	-8 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm6, %xmm2
	MOVDDUP2(-6 * SIZE, X, %rax, 8, %xmm6)
	mulpd	-6 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm7, %xmm3
	MOVDDUP2(-5 * SIZE, X, %rax, 8, %xmm7)
	mulpd	-6 * SIZE(Y, %rax, 8), %xmm7

	addpd	 %xmm8,  %xmm0
	MOVDDUP2(-4 * SIZE, X, %rax, 8, %xmm8)
	mulpd	-4 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm9,  %xmm1
	MOVDDUP2(-3 * SIZE, X, %rax, 8, %xmm9)
	mulpd	-4 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm10, %xmm2
	MOVDDUP2(-2 * SIZE, X, %rax, 8, %xmm10)
	mulpd	-2 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm11, %xmm3
	MOVDDUP2(-1 * SIZE, X, %rax, 8, %xmm11)
	mulpd	-2 * SIZE(Y, %rax, 8), %xmm11

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3
	ALIGN_3

.L25:
	testq	$7, N
	je	.L28

	movq	N,  %rax
	andq	$4, %rax
	jle	.L26

	MOVDDUP(0 * SIZE, X, %xmm4)
	MOVDDUP(1 * SIZE, X, %xmm5)
	MOVDDUP(2 * SIZE, X, %xmm6)
	MOVDDUP(3 * SIZE, X, %xmm7)

	mulpd	0 * SIZE(Y), %xmm4
	mulpd	0 * SIZE(Y), %xmm5
	mulpd	2 * SIZE(Y), %xmm6
	mulpd	2 * SIZE(Y), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	MOVDDUP(4 * SIZE, X, %xmm8)
	MOVDDUP(5 * SIZE, X, %xmm9)
	MOVDDUP(6 * SIZE, X, %xmm10)
	MOVDDUP(7 * SIZE, X, %xmm11)

	mulpd	4 * SIZE(Y), %xmm8
	mulpd	4 * SIZE(Y), %xmm9
	mulpd	6 * SIZE(Y), %xmm10
	mulpd	6 * SIZE(Y), %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	addq	$8 * SIZE, Y
	addq	$8 * SIZE, X
	ALIGN_3

.L26:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L27

	MOVDDUP(0 * SIZE, X, %xmm4)
	MOVDDUP(1 * SIZE, X, %xmm5)
	MOVDDUP(2 * SIZE, X, %xmm6)
	MOVDDUP(3 * SIZE, X, %xmm7)

	mulpd	0 * SIZE(Y), %xmm4
	mulpd	0 * SIZE(Y), %xmm5
	mulpd	2 * SIZE(Y), %xmm6
	mulpd	2 * SIZE(Y), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	addq	$4 * SIZE, Y
	addq	$4 * SIZE, X
	ALIGN_3

.L27:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L28

	MOVDDUP(0 * SIZE, X, %xmm4)
	MOVDDUP(1 * SIZE, X, %xmm5)

	mulpd	0 * SIZE(Y), %xmm4
	mulpd	0 * SIZE(Y), %xmm5

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	ALIGN_3

.L28:
	addpd	%xmm0, %xmm2
	addpd	%xmm1, %xmm3

	movapd	%xmm2,  %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	%xmm3, %xmm1
	unpckhpd %xmm3, %xmm3

#ifndef CONJ
	subsd	 %xmm3, %xmm0
	addsd	 %xmm2, %xmm1
#else
	addsd	 %xmm3, %xmm0
	subsd	 %xmm1, %xmm2
	movapd	 %xmm2, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movlpd	%xmm0, 0 * SIZE(RESULT)
	movlpd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3

.L30:
	movhpd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm1

	movhpd	0 * SIZE(Y), %xmm5

	mulpd	%xmm5, %xmm0
	mulpd	%xmm5, %xmm1

	decq	N
	jle	.L39

	movq	N,  %rax
	andq	$-8, %rax
	jle	.L35

	addq	%rax, %rax

	leaq	(X, %rax, 8), X
	leaq	(Y, %rax, 8), Y
	negq	%rax

	movapd	 1 * SIZE(X, %rax, 8), %xmm4
	movapd	 3 * SIZE(X, %rax, 8), %xmm6
	movapd	 5 * SIZE(X, %rax, 8), %xmm8
	movapd	 7 * SIZE(X, %rax, 8), %xmm10

	movlpd	 0 * SIZE(X, %rax, 8), %xmm5
	movhpd	 3 * SIZE(X, %rax, 8), %xmm5
	movlpd	 2 * SIZE(X, %rax, 8), %xmm7
	movhpd	 5 * SIZE(X, %rax, 8), %xmm7
	movlpd	 4 * SIZE(X, %rax, 8), %xmm9
	movhpd	 7 * SIZE(X, %rax, 8), %xmm9
	movlpd	 6 * SIZE(X, %rax, 8), %xmm11
	movhpd	 9 * SIZE(X, %rax, 8), %xmm11

	mulpd	 1 * SIZE(Y, %rax, 8), %xmm4
	mulpd	 1 * SIZE(Y, %rax, 8), %xmm5
	mulpd	 3 * SIZE(Y, %rax, 8), %xmm6
	mulpd	 3 * SIZE(Y, %rax, 8), %xmm7

	subq	$-16, %rax
	jge	.L32
	ALIGN_3

.L31:
	PREFETCH	(PREFETCH_SIZE_X + 0) * SIZE(X, %rax, 8)

	mulpd	-11 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm4, %xmm0
	movapd	 -7 * SIZE(X, %rax, 8), %xmm4

	mulpd	-11 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm5, %xmm1
	movlpd	 -8 * SIZE(X, %rax, 8), %xmm5
	movhpd	 -5 * SIZE(X, %rax, 8), %xmm5

	mulpd	 -9 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm6, %xmm2
	movapd	 -5 * SIZE(X, %rax, 8), %xmm6

	mulpd	 -9 * SIZE(Y, %rax, 8), %xmm11
	addpd	 %xmm7, %xmm3
	movlpd	 -6 * SIZE(X, %rax, 8), %xmm7
	movhpd	 -3 * SIZE(X, %rax, 8), %xmm7

	PREFETCH	(PREFETCH_SIZE_Y + 0) * SIZE(Y, %rax, 8)

	mulpd	 -7 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm8, %xmm0
	movapd	 -3 * SIZE(X, %rax, 8), %xmm8

	mulpd	 -7 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm9, %xmm1
	movlpd	 -4 * SIZE(X, %rax, 8), %xmm9
	movhpd	 -1 * SIZE(X, %rax, 8), %xmm9

	mulpd	 -5 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm10, %xmm2
	movapd	 -1 * SIZE(X, %rax, 8), %xmm10

	mulpd	 -5 * SIZE(Y, %rax, 8), %xmm7
	addpd	 %xmm11, %xmm3
	movlpd	 -2 * SIZE(X, %rax, 8), %xmm11
	movhpd	  1 * SIZE(X, %rax, 8), %xmm11

	PREFETCH	(PREFETCH_SIZE_X + 8) * SIZE(X, %rax, 8)

	mulpd	 -3 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm4, %xmm0
	movapd	  1 * SIZE(X, %rax, 8), %xmm4

	mulpd	 -3 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm5, %xmm1
	movlpd	  0 * SIZE(X, %rax, 8), %xmm5
	movhpd	  3 * SIZE(X, %rax, 8), %xmm5

	mulpd	 -1 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm6, %xmm2
	movapd	  3 * SIZE(X, %rax, 8), %xmm6

	mulpd	 -1 * SIZE(Y, %rax, 8), %xmm11
	addpd	 %xmm7, %xmm3
	movlpd	  2 * SIZE(X, %rax, 8), %xmm7
	movhpd	  5 * SIZE(X, %rax, 8), %xmm7

	PREFETCH	(PREFETCH_SIZE_Y + 8) * SIZE(Y, %rax, 8)

	mulpd	  1 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm8, %xmm0
	movapd	  5 * SIZE(X, %rax, 8), %xmm8

	mulpd	  1 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm9, %xmm1
	movlpd	  4 * SIZE(X, %rax, 8), %xmm9
	movhpd	  7 * SIZE(X, %rax, 8), %xmm9

	mulpd	  3 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm10, %xmm2
	movapd	 7 * SIZE(X, %rax, 8), %xmm10

	mulpd	  3 * SIZE(Y, %rax, 8), %xmm7
	addpd	 %xmm11, %xmm3
	movlpd	  6 * SIZE(X, %rax, 8), %xmm11
	movhpd	  9 * SIZE(X, %rax, 8), %xmm11

	subq	$-16, %rax
	jl,pt	.L31
	ALIGN_3

.L32:
	mulpd	-11 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm4, %xmm0
	movapd	 -7 * SIZE(X, %rax, 8), %xmm4

	mulpd	-11 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm5, %xmm1
	movlpd	 -8 * SIZE(X, %rax, 8), %xmm5
	movhpd	 -5 * SIZE(X, %rax, 8), %xmm5

	mulpd	 -9 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm6, %xmm2
	movapd	 -5 * SIZE(X, %rax, 8), %xmm6

	mulpd	 -9 * SIZE(Y, %rax, 8), %xmm11
	addpd	 %xmm7, %xmm3
	movlpd	 -6 * SIZE(X, %rax, 8), %xmm7
	movhpd	 -3 * SIZE(X, %rax, 8), %xmm7

	mulpd	 -7 * SIZE(Y, %rax, 8), %xmm4
	addpd	 %xmm8, %xmm0
	movapd	 -3 * SIZE(X, %rax, 8), %xmm8

	mulpd	 -7 * SIZE(Y, %rax, 8), %xmm5
	addpd	 %xmm9, %xmm1
	movlpd	 -4 * SIZE(X, %rax, 8), %xmm9
	movhpd	 -1 * SIZE(X, %rax, 8), %xmm9

	mulpd	 -5 * SIZE(Y, %rax, 8), %xmm6
	addpd	 %xmm10, %xmm2
	movapd	 -1 * SIZE(X, %rax, 8), %xmm10

	mulpd	 -5 * SIZE(Y, %rax, 8), %xmm7
	addpd	 %xmm11, %xmm3
	movlpd	 -2 * SIZE(X, %rax, 8), %xmm11
	movhpd	  1 * SIZE(X, %rax, 8), %xmm11

	mulpd	 -3 * SIZE(Y, %rax, 8), %xmm8
	addpd	 %xmm4, %xmm0
	mulpd	 -3 * SIZE(Y, %rax, 8), %xmm9
	addpd	 %xmm5, %xmm1

	mulpd	 -1 * SIZE(Y, %rax, 8), %xmm10
	addpd	 %xmm6, %xmm2
	mulpd	 -1 * SIZE(Y, %rax, 8), %xmm11
	addpd	 %xmm7, %xmm3

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3
	ALIGN_3

.L35:
	testq	$7, N
	je	.L39

	movq	N,  %rax
	andq	$4, %rax
	jle	.L36

	movapd	 1 * SIZE(X), %xmm4
	movapd	 3 * SIZE(X), %xmm6

	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 3 * SIZE(X), %xmm5
	movlpd	 2 * SIZE(X), %xmm7
	movhpd	 5 * SIZE(X), %xmm7

	mulpd	 1 * SIZE(Y), %xmm4
	mulpd	 1 * SIZE(Y), %xmm5
	mulpd	 3 * SIZE(Y), %xmm6
	mulpd	 3 * SIZE(Y), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	movapd	 5 * SIZE(X), %xmm8
	movapd	 7 * SIZE(X), %xmm10

	movlpd	 4 * SIZE(X), %xmm9
	movhpd	 7 * SIZE(X), %xmm9
	movlpd	 6 * SIZE(X), %xmm11
	movhpd	 9 * SIZE(X), %xmm11

	mulpd	 5 * SIZE(Y), %xmm8
	mulpd	 5 * SIZE(Y), %xmm9
	mulpd	 7 * SIZE(Y), %xmm10
	mulpd	 7 * SIZE(Y), %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L36:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L37

	movapd	 1 * SIZE(X), %xmm4
	movapd	 3 * SIZE(X), %xmm6

	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 3 * SIZE(X), %xmm5
	movlpd	 2 * SIZE(X), %xmm7
	movhpd	 5 * SIZE(X), %xmm7

	mulpd	 1 * SIZE(Y), %xmm4
	mulpd	 1 * SIZE(Y), %xmm5
	mulpd	 3 * SIZE(Y), %xmm6
	mulpd	 3 * SIZE(Y), %xmm7

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	addq	 $4 * SIZE, X
	addq	 $4 * SIZE, Y
	ALIGN_3

.L37:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L39

	movapd	 1 * SIZE(X), %xmm4

	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 3 * SIZE(X), %xmm5

	mulpd	 1 * SIZE(Y), %xmm4
	mulpd	 1 * SIZE(Y), %xmm5

	addpd	 %xmm4, %xmm0
	addpd	 %xmm5, %xmm1

	addq	 $2 * SIZE, X
	addq	 $2 * SIZE, Y
	ALIGN_3
	
.L39:
	movsd	1 * SIZE(X), %xmm4
	movsd	0 * SIZE(X), %xmm5

	movsd	1 * SIZE(Y), %xmm6

	mulsd	%xmm6, %xmm4
	mulsd	%xmm6, %xmm5

	addsd	%xmm4, %xmm0
	addsd	%xmm5, %xmm1

	addpd	%xmm0, %xmm2
	addpd	%xmm1, %xmm3

	movapd	%xmm2,  %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	%xmm3, %xmm1
	unpckhpd %xmm3, %xmm3

#ifndef CONJ
	subsd	 %xmm0, %xmm2
	addsd	 %xmm3, %xmm1

	movapd	 %xmm2, %xmm0
#else
	addsd	 %xmm2, %xmm0
	subsd	 %xmm3, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movlpd	%xmm0, 0 * SIZE(RESULT)
	movlpd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3


.L50:
#ifdef F_INTERFACE
	testq	INCX, INCX		# if (incx < 0)
	jge	.L51

	movq	N, %rax		# n
	decq	%rax			# n - 1
	imulq	INCX, %rax		# (n - 1) * incx
	subq	%rax, X
	ALIGN_3

.L51:
	testq	INCY, INCY		# if (incy < 0)
	jge	.L52

	movq	N, %rax
	decq	%rax			# (n - 1)
	imulq	INCY, %rax		# (n - 1) * incy
	subq	%rax, Y
	ALIGN_3
.L52:
#endif

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L55

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm7
	movhpd	 1 * SIZE(X), %xmm7
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, Y, %xmm12)
	MOVDDUP( 1 * SIZE, Y, %xmm13)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm14)
	MOVDDUP( 1 * SIZE, Y, %xmm15)
	addq	 INCY, Y

	decq	%rax
	jle	.L54
	ALIGN_3

.L53:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm7
	movhpd	 1 * SIZE(X), %xmm7
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, Y, %xmm12)
	MOVDDUP( 1 * SIZE, Y, %xmm13)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm14)
	MOVDDUP( 1 * SIZE, Y, %xmm15)
	addq	 INCY, Y

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm7
	movhpd	 1 * SIZE(X), %xmm7
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, Y, %xmm12)
	MOVDDUP( 1 * SIZE, Y, %xmm13)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm14)
	MOVDDUP( 1 * SIZE, Y, %xmm15)
	addq	 INCY, Y

	decq	%rax
	jg	.L53
	ALIGN_3

.L54:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm7
	movhpd	 1 * SIZE(X), %xmm7
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, Y, %xmm12)
	MOVDDUP( 1 * SIZE, Y, %xmm13)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm14)
	MOVDDUP( 1 * SIZE, Y, %xmm15)
	addq	 INCY, Y

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11
	ALIGN_3

.L55:
	testq	$7, N
	je	.L999

	movq	N,  %rax
	andq	$4, %rax
	jle	.L56

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm7
	movhpd	 1 * SIZE(X), %xmm7
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, Y, %xmm12)
	MOVDDUP( 1 * SIZE, Y, %xmm13)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm14)
	MOVDDUP( 1 * SIZE, Y, %xmm15)
	addq	 INCY, Y

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	addpd	 %xmm12, %xmm0
	addpd	 %xmm13, %xmm1
	addpd	 %xmm14, %xmm2
	addpd	 %xmm15, %xmm3
	ALIGN_3

.L56:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L57

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movlpd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	addq	 INCY, Y
	MOVDDUP( 0 * SIZE, Y, %xmm10)
	MOVDDUP( 1 * SIZE, Y, %xmm11)
	addq	 INCY, Y

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3
	ALIGN_3

.L57:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L999

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	ALIGN_3

.L999:
	addpd	%xmm0, %xmm2
	addpd	%xmm1, %xmm3

	movapd	%xmm2,  %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	%xmm3, %xmm1
	unpckhpd %xmm3, %xmm3

#ifndef CONJ
	subsd	 %xmm3, %xmm0
	addsd	 %xmm2, %xmm1
#else
	addsd	 %xmm3, %xmm0
	subsd	 %xmm2, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movlpd	%xmm0, 0 * SIZE(RESULT)
	movlpd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
