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

#define PREFETCHSIZE 224

#ifdef BARCELONA
#define MOVDDUP(a, b, c)	movddup	a(b), c
#else
#define MOVDDUP(a, b, c)	movlps	a(b), c;unpcklps c, c
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

	cmpq	$2 * SIZE, INCX
	jne	.L50
	cmpq	$2 * SIZE, INCY
	jne	.L50

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L25
	ALIGN_3

.L21:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 2 * SIZE(X), %xmm4
	movlpd	 4 * SIZE(X), %xmm6
	movhpd	 6 * SIZE(X), %xmm6
	movlpd	 8 * SIZE(X), %xmm8
	movhpd	10 * SIZE(X), %xmm8
	movlpd	12 * SIZE(X), %xmm10
	movhpd	14 * SIZE(X), %xmm10

	pshufd	 $0xb1, %xmm4,  %xmm5
	pshufd	 $0xb1, %xmm6,  %xmm7
	pshufd	 $0xb1, %xmm8,  %xmm9
	pshufd	 $0xb1, %xmm10, %xmm11

	movlpd	 0 * SIZE(Y), %xmm12
	movhpd	 2 * SIZE(Y), %xmm12
	movlpd	 4 * SIZE(Y), %xmm13
	movhpd	 6 * SIZE(Y), %xmm13
	movlpd	 8 * SIZE(Y), %xmm14
	movhpd	10 * SIZE(Y), %xmm14
	movlpd	12 * SIZE(Y), %xmm15
	movhpd	14 * SIZE(Y), %xmm15

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(Y)

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5
	mulps	 %xmm13, %xmm6
	mulps	 %xmm13, %xmm7

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	addps	 %xmm6, %xmm2
	addps	 %xmm7, %xmm3

	mulps	 %xmm14, %xmm8
	mulps	 %xmm14, %xmm9
	mulps	 %xmm15, %xmm10
	mulps	 %xmm15, %xmm11

	addps	 %xmm8,  %xmm0
	addps	 %xmm9,  %xmm1
	addps	 %xmm10, %xmm2
	addps	 %xmm11, %xmm3

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y

	decq	%rax
	jg	.L21
	ALIGN_3

.L25:
	testq	$4, N
	jle	.L27

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 2 * SIZE(X), %xmm4
	movlpd	 4 * SIZE(X), %xmm6
	movhpd	 6 * SIZE(X), %xmm6
	movlpd	 0 * SIZE(Y), %xmm12
	movhpd	 2 * SIZE(Y), %xmm12
	movlpd	 4 * SIZE(Y), %xmm13
	movhpd	 6 * SIZE(Y), %xmm13

	pshufd	 $0xb1, %xmm4, %xmm5
	pshufd	 $0xb1, %xmm6, %xmm7

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5
	mulps	 %xmm13, %xmm6
	mulps	 %xmm13, %xmm7

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	addps	 %xmm6, %xmm2
	addps	 %xmm7, %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L27:
	testq	$2, N
	jle	.L28

	movlpd	 0 * SIZE(X), %xmm4
	movhpd	 2 * SIZE(X), %xmm4
	movlpd	 0 * SIZE(Y), %xmm12
	movhpd	 2 * SIZE(Y), %xmm12

	pshufd	 $0xb1, %xmm4, %xmm5

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1

	addq	 $4 * SIZE, X
	addq	 $4 * SIZE, Y
	ALIGN_3

.L28:
	testq	$1, N
	jle	.L999

	movsd	 (X), %xmm4
	movsd	 (Y), %xmm12

	pshufd	 $0xb1, %xmm4, %xmm5

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	jmp	 .L999
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
	ALIGN_3

.L53:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)

	movlpd	(X), %xmm4
	addq	 INCX, X
	movhpd	(X), %xmm4
	addq	 INCX, X
	movlpd	(X), %xmm6
	addq	 INCX, X
	movhpd	(X), %xmm6
	addq	 INCX, X
	movlpd	(X), %xmm8
	addq	 INCX, X
	movhpd	(X), %xmm8
	addq	 INCX, X
	movlpd	(X), %xmm10
	addq	 INCX, X
	movhpd	(X), %xmm10
	addq	 INCX, X

	pshufd	 $0xb1, %xmm4,  %xmm5
	pshufd	 $0xb1, %xmm6,  %xmm7
	pshufd	 $0xb1, %xmm8,  %xmm9
	pshufd	 $0xb1, %xmm10, %xmm11

	movlpd	(Y), %xmm12
	addq	 INCY, Y
	movhpd	(Y), %xmm12
	addq	 INCY, Y
	movlpd	(Y), %xmm13
	addq	 INCY, Y
	movhpd	(Y), %xmm13
	addq	 INCY, Y
	movlpd	(Y), %xmm14
	addq	 INCY, Y
	movhpd	(Y), %xmm14
	addq	 INCY, Y
	movlpd	(Y), %xmm15
	addq	 INCY, Y
	movhpd	(Y), %xmm15
	addq	 INCY, Y

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(Y)

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5
	mulps	 %xmm13, %xmm6
	mulps	 %xmm13, %xmm7

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	addps	 %xmm6, %xmm2
	addps	 %xmm7, %xmm3

	mulps	 %xmm14, %xmm8
	mulps	 %xmm14, %xmm9
	mulps	 %xmm15, %xmm10
	mulps	 %xmm15, %xmm11

	addps	 %xmm8,  %xmm0
	addps	 %xmm9,  %xmm1
	addps	 %xmm10, %xmm2
	addps	 %xmm11, %xmm3

	decq	%rax
	jg	.L53
	ALIGN_3

.L55:
	testq	$4, N
	jle	.L57

	movlpd	 (X), %xmm4
	addq	 INCX, X
	movhpd	 (X), %xmm4
	addq	 INCX, X
	movlpd	 (X), %xmm6
	addq	 INCX, X
	movhpd	 (X), %xmm6
	addq	 INCX, X
	movlpd	 (Y), %xmm12
	addq	 INCY, Y
	movhpd	 (Y), %xmm12
	addq	 INCY, Y
	movlpd	 (Y), %xmm13
	addq	 INCY, Y
	movhpd	 (Y), %xmm13
	addq	 INCY, Y

	pshufd	 $0xb1, %xmm4, %xmm5
	pshufd	 $0xb1, %xmm6, %xmm7

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5
	mulps	 %xmm13, %xmm6
	mulps	 %xmm13, %xmm7

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	addps	 %xmm6, %xmm2
	addps	 %xmm7, %xmm3
	ALIGN_3

.L57:
	testq	$2, N
	jle	.L58

	movlpd	 (X), %xmm4
	addq	 INCX, X
	movhpd	 (X), %xmm4
	addq	 INCX, X
	movlpd	 (Y), %xmm12
	addq	 INCY, Y
	movhpd	 (Y), %xmm12
	addq	 INCY, Y

	pshufd	 $0xb1, %xmm4, %xmm5

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	ALIGN_3

.L58:
	testq	$1, N
	jle	.L999

	movsd	 (X), %xmm4
	movsd	 (Y), %xmm12

	pshufd	 $0xb1, %xmm4, %xmm5

	mulps	 %xmm12, %xmm4
	mulps	 %xmm12, %xmm5

	addps	 %xmm4, %xmm0
	addps	 %xmm5, %xmm1
	ALIGN_3

.L999:
	addps	%xmm2, %xmm0
	addps	%xmm3, %xmm1
	
	movhlps	%xmm0, %xmm2
	movhlps	%xmm1, %xmm3

#ifndef CONJ
	addps	%xmm2, %xmm0
	addps	%xmm3, %xmm1

	pshufd	$1, %xmm0, %xmm2
	pshufd	$1, %xmm1, %xmm3

	subps	 %xmm2, %xmm0
	addps	 %xmm3, %xmm1
#else
	addps	%xmm2, %xmm0
	addps	%xmm1, %xmm3

	pshufd	$1, %xmm0, %xmm2
	pshufd	$1, %xmm3, %xmm1

	addps	 %xmm2, %xmm0
	subps	 %xmm3, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movss	%xmm0, 0 * SIZE(RESULT)
	movss	%xmm1, 1 * SIZE(RESULT)
#elif defined(PACKED_RETURN) || defined(F_SUN)
	unpcklps       %xmm1, %xmm0	
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
