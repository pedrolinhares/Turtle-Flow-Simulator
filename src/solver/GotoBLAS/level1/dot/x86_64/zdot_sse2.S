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

#ifdef PENTIUM4
#define PREFETCHSIZE 88
#endif

#ifdef OPTERON
#define PREFETCHSIZE 80
#define movsd	     movlpd
#endif

#ifdef GENERIC
#define PREFETCHSIZE 80
#endif

#if defined(HAVE_SSE3) && !defined(CORE_OPTERON)
#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c)	movddup	a##b, c
#else
#define MOVDDUP(a, b, c)	movlpd	a(b), c;movhpd	a(b), c
#define MOVDDUP2(a, b, c)	movlpd	a##b, c;movhpd	a##b, c
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
	jle	.L999

	testq	$SIZE, X
	jne	.L30

	cmpq	$2 * SIZE, INCX
	jne	.L20
	cmpq	$2 * SIZE, INCY
	jne	.L20

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L15

	movapd	 0 * SIZE(X), %xmm4
	movapd	 2 * SIZE(X), %xmm5
	movapd	 4 * SIZE(X), %xmm6
	movapd	 6 * SIZE(X), %xmm7

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	MOVDDUP( 2 * SIZE, Y, %xmm10)
	MOVDDUP( 3 * SIZE, Y, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 4 * SIZE, Y, %xmm12)
	MOVDDUP( 5 * SIZE, Y, %xmm13)
	MOVDDUP( 6 * SIZE, Y, %xmm14)
	MOVDDUP( 7 * SIZE, Y, %xmm15)

	decq	%rax
	jle	.L12
	ALIGN_3

.L11:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 8 * SIZE(X), %xmm4
	movapd	10 * SIZE(X), %xmm5
	movapd	12 * SIZE(X), %xmm6
	movapd	14 * SIZE(X), %xmm7

	MOVDDUP( 8 * SIZE, Y, %xmm8)
	MOVDDUP( 9 * SIZE, Y, %xmm9)
	MOVDDUP(10 * SIZE, Y, %xmm10)
	MOVDDUP(11 * SIZE, Y, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(12 * SIZE, Y, %xmm12)
	MOVDDUP(13 * SIZE, Y, %xmm13)
	MOVDDUP(14 * SIZE, Y, %xmm14)
	MOVDDUP(15 * SIZE, Y, %xmm15)

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	16 * SIZE(X), %xmm4
	movapd	18 * SIZE(X), %xmm5
	movapd	20 * SIZE(X), %xmm6
	movapd	22 * SIZE(X), %xmm7

	MOVDDUP(16 * SIZE, Y, %xmm8)
	MOVDDUP(17 * SIZE, Y, %xmm9)
	MOVDDUP(18 * SIZE, Y, %xmm10)
	MOVDDUP(19 * SIZE, Y, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(20 * SIZE, Y, %xmm12)
	MOVDDUP(21 * SIZE, Y, %xmm13)
	MOVDDUP(22 * SIZE, Y, %xmm14)
	MOVDDUP(23 * SIZE, Y, %xmm15)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y

	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 8 * SIZE(X), %xmm4
	movapd	10 * SIZE(X), %xmm5
	movapd	12 * SIZE(X), %xmm6
	movapd	14 * SIZE(X), %xmm7

	MOVDDUP( 8 * SIZE, Y, %xmm8)
	MOVDDUP( 9 * SIZE, Y, %xmm9)
	MOVDDUP(10 * SIZE, Y, %xmm10)
	MOVDDUP(11 * SIZE, Y, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(12 * SIZE, Y, %xmm12)
	MOVDDUP(13 * SIZE, Y, %xmm13)
	MOVDDUP(14 * SIZE, Y, %xmm14)
	MOVDDUP(15 * SIZE, Y, %xmm15)

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

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L15:
	testq	$7, N
	je	.L999

	movq	N,  %rax
	andq	$4, %rax
	jle	.L16

	movapd	 0 * SIZE(X), %xmm4
	movapd	 2 * SIZE(X), %xmm5
	movapd	 4 * SIZE(X), %xmm6
	movapd	 6 * SIZE(X), %xmm7

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	MOVDDUP( 2 * SIZE, Y, %xmm10)
	MOVDDUP( 3 * SIZE, Y, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 4 * SIZE, Y, %xmm12)
	MOVDDUP( 5 * SIZE, Y, %xmm13)
	MOVDDUP( 6 * SIZE, Y, %xmm14)
	MOVDDUP( 7 * SIZE, Y, %xmm15)

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

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L17

	movapd	 0 * SIZE(X), %xmm4
	movapd	 2 * SIZE(X), %xmm5

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)
	MOVDDUP( 2 * SIZE, Y, %xmm10)
	MOVDDUP( 3 * SIZE, Y, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L999

	movapd	 0 * SIZE(X), %xmm4

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	jmp	 .L999
	ALIGN_3

.L20:
#ifdef F_INTERFACE
	testq	INCX, INCX		# if (incx < 0)
	jge	.L21

	movq	N, %rax		# n
	decq	%rax			# n - 1
	imulq	INCX, %rax		# (n - 1) * incx
	subq	%rax, X
	ALIGN_3

.L21:
	testq	INCY, INCY		# if (incy < 0)
	jge	.L22

	movq	N, %rax
	decq	%rax			# (n - 1)
	imulq	INCY, %rax		# (n - 1) * incy
	subq	%rax, Y
	ALIGN_3
.L22:
#endif

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L25

	movapd	 (X), %xmm4
	addq	 INCX, X
	movapd	 (X), %xmm5
	addq	 INCX, X
	movapd	 (X), %xmm6
	addq	 INCX, X
	movapd	 (X), %xmm7
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
	jle	.L24
	ALIGN_3

.L23:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 (X), %xmm4
	addq	 INCX, X
	movapd	 (X), %xmm5
	addq	 INCX, X
	movapd	 (X), %xmm6
	addq	 INCX, X
	movapd	 (X), %xmm7
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

	movapd	(X), %xmm4
	addq	 INCX, X
	movapd	(X), %xmm5
	addq	 INCX, X
	movapd	(X), %xmm6
	addq	 INCX, X
	movapd	(X), %xmm7
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
	jg	.L23
	ALIGN_3

.L24:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 (X), %xmm4
	addq	 INCX, X
	movapd	 (X), %xmm5
	addq	 INCX, X
	movapd	 (X), %xmm6
	addq	 INCX, X
	movapd	 (X), %xmm7
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

.L25:
	testq	$7, N
	je	.L999

	movq	N,  %rax
	andq	$4, %rax
	jle	.L26

	movapd	 (X), %xmm4
	addq	 INCX, X
	movapd	 (X), %xmm5
	addq	 INCX, X
	movapd	 (X), %xmm6
	addq	 INCX, X
	movapd	 (X), %xmm7
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

.L26:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L27

	movapd	 (X), %xmm4
	addq	 INCX, X
	movapd	 (X), %xmm5
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

.L27:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L999

	movapd	 (X), %xmm4
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	jmp	 .L999
	ALIGN_3

.L30:
	testq	$SIZE, Y
	jne	.L50

	cmpq	$2 * SIZE, INCX
	jne	.L40
	cmpq	$2 * SIZE, INCY
	jne	.L40

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L35

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5
	movapd	 4 * SIZE(Y), %xmm6
	movapd	 6 * SIZE(Y), %xmm7

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	MOVDDUP( 2 * SIZE, X, %xmm10)
	MOVDDUP( 3 * SIZE, X, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 4 * SIZE, X, %xmm12)
	MOVDDUP( 5 * SIZE, X, %xmm13)
	MOVDDUP( 6 * SIZE, X, %xmm14)
	MOVDDUP( 7 * SIZE, X, %xmm15)

	decq	%rax
	jle	.L32
	ALIGN_3

.L31:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5
	movapd	12 * SIZE(Y), %xmm6
	movapd	14 * SIZE(Y), %xmm7

	MOVDDUP( 8 * SIZE, X, %xmm8)
	MOVDDUP( 9 * SIZE, X, %xmm9)
	MOVDDUP(10 * SIZE, X, %xmm10)
	MOVDDUP(11 * SIZE, X, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(12 * SIZE, X, %xmm12)
	MOVDDUP(13 * SIZE, X, %xmm13)
	MOVDDUP(14 * SIZE, X, %xmm14)
	MOVDDUP(15 * SIZE, X, %xmm15)

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	16 * SIZE(Y), %xmm4
	movapd	18 * SIZE(Y), %xmm5
	movapd	20 * SIZE(Y), %xmm6
	movapd	22 * SIZE(Y), %xmm7

	MOVDDUP(16 * SIZE, X, %xmm8)
	MOVDDUP(17 * SIZE, X, %xmm9)
	MOVDDUP(18 * SIZE, X, %xmm10)
	MOVDDUP(19 * SIZE, X, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(20 * SIZE, X, %xmm12)
	MOVDDUP(21 * SIZE, X, %xmm13)
	MOVDDUP(22 * SIZE, X, %xmm14)
	MOVDDUP(23 * SIZE, X, %xmm15)

	addq	$16 * SIZE, Y
	addq	$16 * SIZE, X

	decq	%rax
	jg	.L31
	ALIGN_3

.L32:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5
	movapd	12 * SIZE(Y), %xmm6
	movapd	14 * SIZE(Y), %xmm7

	MOVDDUP( 8 * SIZE, X, %xmm8)
	MOVDDUP( 9 * SIZE, X, %xmm9)
	MOVDDUP(10 * SIZE, X, %xmm10)
	MOVDDUP(11 * SIZE, X, %xmm11)

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP(12 * SIZE, X, %xmm12)
	MOVDDUP(13 * SIZE, X, %xmm13)
	MOVDDUP(14 * SIZE, X, %xmm14)
	MOVDDUP(15 * SIZE, X, %xmm15)

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

	addq	$16 * SIZE, Y
	addq	$16 * SIZE, X
	ALIGN_3

.L35:
	testq	$7, N
	je	.L49

	movq	N,  %rax
	andq	$4, %rax
	jle	.L36

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5
	movapd	 4 * SIZE(Y), %xmm6
	movapd	 6 * SIZE(Y), %xmm7

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	MOVDDUP( 2 * SIZE, X, %xmm10)
	MOVDDUP( 3 * SIZE, X, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 4 * SIZE, X, %xmm12)
	MOVDDUP( 5 * SIZE, X, %xmm13)
	MOVDDUP( 6 * SIZE, X, %xmm14)
	MOVDDUP( 7 * SIZE, X, %xmm15)

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

	addq	$8 * SIZE, Y
	addq	$8 * SIZE, X
	ALIGN_3

.L36:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L37

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	MOVDDUP( 2 * SIZE, X, %xmm10)
	MOVDDUP( 3 * SIZE, X, %xmm11)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	addq	$4 * SIZE, Y
	addq	$4 * SIZE, X
	ALIGN_3

.L37:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L49

	movapd	 0 * SIZE(Y), %xmm4

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	jmp	 .L49
	ALIGN_3

.L40:
#ifdef F_INTERFACE
	testq	INCX, INCX
	jge	.L41

	movq	N, %rax
	decq	%rax
	imulq	INCX, %rax
	subq	%rax, X
	ALIGN_3

.L41:
	testq	INCY, INCY
	jge	.L42

	movq	N, %rax
	decq	%rax
	imulq	INCY, %rax
	subq	%rax, Y
	ALIGN_3
.L42:
#endif

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L45

	movapd	 (Y), %xmm4
	addq	 INCY, Y
	movapd	 (Y), %xmm5
	addq	 INCY, Y
	movapd	 (Y), %xmm6
	addq	 INCY, Y
	movapd	 (Y), %xmm7
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm12)
	MOVDDUP( 1 * SIZE, X, %xmm13)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm14)
	MOVDDUP( 1 * SIZE, X, %xmm15)
	addq	 INCX, X

	decq	%rax
	jle	.L44
	ALIGN_3

.L43:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 (Y), %xmm4
	addq	 INCY, Y
	movapd	 (Y), %xmm5
	addq	 INCY, Y
	movapd	 (Y), %xmm6
	addq	 INCY, Y
	movapd	 (Y), %xmm7
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm12)
	MOVDDUP( 1 * SIZE, X, %xmm13)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm14)
	MOVDDUP( 1 * SIZE, X, %xmm15)
	addq	 INCX, X

	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	(Y), %xmm4
	addq	 INCY, Y
	movapd	(Y), %xmm5
	addq	 INCY, Y
	movapd	(Y), %xmm6
	addq	 INCY, Y
	movapd	(Y), %xmm7
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm12)
	MOVDDUP( 1 * SIZE, X, %xmm13)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm14)
	MOVDDUP( 1 * SIZE, X, %xmm15)
	addq	 INCX, X

	decq	%rax
	jg	.L43
	ALIGN_3

.L44:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movapd	 (Y), %xmm4
	addq	 INCY, Y
	movapd	 (Y), %xmm5
	addq	 INCY, Y
	movapd	 (Y), %xmm6
	addq	 INCY, Y
	movapd	 (Y), %xmm7
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	addpd	 %xmm12, %xmm0
	mulpd	 %xmm4, %xmm8
	addpd	 %xmm13, %xmm1
	mulpd	 %xmm4, %xmm9

	addpd	 %xmm14, %xmm2
	mulpd	 %xmm5, %xmm10
	addpd	 %xmm15, %xmm3
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm12)
	MOVDDUP( 1 * SIZE, X, %xmm13)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm14)
	MOVDDUP( 1 * SIZE, X, %xmm15)
	addq	 INCX, X

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

.L45:
	testq	$7, N
	je	.L49

	movq	N,  %rax
	andq	$4, %rax
	jle	.L46

	movapd	 (Y), %xmm4
	addq	 INCY, Y
	movapd	 (Y), %xmm5
	addq	 INCY, Y
	movapd	 (Y), %xmm6
	addq	 INCY, Y
	movapd	 (Y), %xmm7
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm12)
	MOVDDUP( 1 * SIZE, X, %xmm13)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm14)
	MOVDDUP( 1 * SIZE, X, %xmm15)
	addq	 INCX, X

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

.L46:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L47

	movapd	 (Y), %xmm4
	addq	 INCY, Y
	movapd	 (Y), %xmm5
	addq	 INCY, Y

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm10)
	MOVDDUP( 1 * SIZE, X, %xmm11)
	addq	 INCX, X

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	mulpd	 %xmm5, %xmm10
	mulpd	 %xmm5, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3
	ALIGN_3

.L47:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L49

	movapd	 (Y), %xmm4

	MOVDDUP( 0 * SIZE, X, %xmm8)
	MOVDDUP( 1 * SIZE, X, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	ALIGN_3

.L49:
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
	movsd	%xmm0, 0 * SIZE(RESULT)
	movsd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3

.L50:
#ifdef F_INTERFACE
	testq	INCX, INCX		# if (incx < 0)
	jge	.L61

	movq	N, %rax		# n
	decq	%rax			# n - 1
	imulq	INCX, %rax		# (n - 1) * incx
	subq	%rax, X
	ALIGN_3

.L61:
	testq	INCY, INCY		# if (incy < 0)
	jge	.L62

	movq	N, %rax
	decq	%rax			# (n - 1)
	imulq	INCY, %rax		# (n - 1) * incy
	subq	%rax, Y
	ALIGN_3
.L62:
#endif

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L65

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm7
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
	jle	.L64
	ALIGN_3

.L63:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm7
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

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm7
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
	jg	.L63
	ALIGN_3

.L64:
	addpd	 %xmm8, %xmm0
	mulpd	 %xmm6, %xmm12
	addpd	 %xmm9, %xmm1
	mulpd	 %xmm6, %xmm13

	addpd	 %xmm10, %xmm2
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm11, %xmm3
	mulpd	 %xmm7, %xmm15

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm7
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

.L65:
	testq	$7, N
	je	.L999

	movq	N,  %rax
	andq	$4, %rax
	jle	.L66

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
	movhpd	 1 * SIZE(X), %xmm5
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm6
	movhpd	 1 * SIZE(X), %xmm6
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm7
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

.L66:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L67

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm5
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

.L67:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L999

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	addq	 INCX, X

	MOVDDUP( 0 * SIZE, Y, %xmm8)
	MOVDDUP( 1 * SIZE, Y, %xmm9)

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm9
	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	jmp	 .L999
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
	movsd	%xmm0, 0 * SIZE(RESULT)
	movsd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
