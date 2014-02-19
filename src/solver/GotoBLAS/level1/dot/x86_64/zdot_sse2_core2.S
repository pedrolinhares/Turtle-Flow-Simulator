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

#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c)	movddup	a##b, c

#define PREFETCH       prefetcht0
#define PREFETCH_SIZE	(8 * 5)

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
	jle	.L49

	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	testq	$SIZE, X
	jne	.L30

	testq	$SIZE, Y
	jne	.L50

	cmpq	$2 * SIZE, INCX
	jne	.L20
	cmpq	$2 * SIZE, INCY
	jne	.L20

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L15
	ALIGN_3

.L11:
	movapd	 -16 * SIZE(Y), %xmm5
	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(X), %xmm4
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	movapd	 -14 * SIZE(Y), %xmm7
	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(X), %xmm4
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	mulpd	 %xmm4, %xmm6
	PREFETCH	(PREFETCH_SIZE +  0)(Y)
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	movapd	 -12 * SIZE(Y), %xmm5
	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(X), %xmm4
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	movapd	 -10 * SIZE(Y), %xmm7
	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(X), %xmm4
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	movapd	  -8 * SIZE(Y), %xmm5
	addpd	 %xmm6, %xmm2
	movapd	  -8 * SIZE(X), %xmm4
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	movapd	  -6 * SIZE(Y), %xmm7
	addpd	 %xmm6, %xmm0
	movapd	  -6 * SIZE(X), %xmm4
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	movapd	  -4 * SIZE(Y), %xmm5
	addpd	 %xmm6, %xmm2
	movapd	  -4 * SIZE(X), %xmm4
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	movapd	  -2 * SIZE(Y), %xmm7
	subq	$-16 * SIZE, Y
	addpd	 %xmm6, %xmm0
	movapd	  -2 * SIZE(X), %xmm4
	movapd	%xmm7, %xmm6
	subq	$-16 * SIZE, X
	SHUFPD_1 %xmm7, %xmm7
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	subq	$1, %rax
	jg,pt	.L11
	ALIGN_3

.L15:
	testq	$4, N
	jle	.L16

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 -16 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 -14 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 -12 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 -10 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	testq	$2, N
	jle	.L17

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 -16 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 -14 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L49

	movapd	 -16 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 -16 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
	jmp	 .L49
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
	ALIGN_3

.L23:
	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L23
	ALIGN_3

.L25:
	testq	$4, N
	jle	.L26

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L26:
	testq	$2, N
	jle	.L27

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L27:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L49

	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movapd	 (X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
	jmp	 .L49
	ALIGN_3

.L30:
	testq	$SIZE, Y
	jne	.L70

	/* Y is aligned */

	cmpq	$2 * SIZE, INCX
	jne	.L40
	cmpq	$2 * SIZE, INCY
	jne	.L40

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L35
	ALIGN_3

.L31:
	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(X), %xmm4
	movhpd	 -15 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	PREFETCH	(PREFETCH_SIZE +  0)(X)
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(X), %xmm4
	movhpd	 -13 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -12 * SIZE(X), %xmm4
	movhpd	 -11 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -10 * SIZE(X), %xmm4
	movhpd	  -9 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	  -8 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	  -8 * SIZE(X), %xmm4
	movhpd	  -7 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	  -6 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	  -6 * SIZE(X), %xmm4
	movhpd	  -5 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	  -4 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	  -4 * SIZE(X), %xmm4
	movhpd	  -3 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	  -2 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	  -2 * SIZE(X), %xmm4
	movhpd	  -1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	decq	%rax
	jg	.L31
	ALIGN_3

.L35:
	testq	$4, N
	jle	.L36

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(X), %xmm4
	movhpd	 -15 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(X), %xmm4
	movhpd	 -13 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -12 * SIZE(X), %xmm4
	movhpd	 -11 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -10 * SIZE(X), %xmm4
	movhpd	  -9 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L36:
	testq	$2, N
	jle	.L37

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(X), %xmm4
	movhpd	 -15 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(X), %xmm4
	movhpd	 -13 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L37:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L49

	movapd	 -16 * SIZE(Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -16 * SIZE(X), %xmm4
	movhpd	 -15 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
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
	ALIGN_3

.L43:
	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L43
	ALIGN_3

.L45:
	testq	$4, N
	jle	.L46

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L46:
	testq	$2, N
	jle	.L47

	addpd	 %xmm6, %xmm2
	movapd	 (Y), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L47:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L49

	movapd	 (Y), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
	ALIGN_3

.L49:
	addpd	%xmm0, %xmm2
	addpd	%xmm1, %xmm3

	movapd	 %xmm2, %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	 %xmm3, %xmm1
	unpckhpd %xmm3, %xmm3

#ifndef CONJ
	subsd	 %xmm2, %xmm0
	addsd	 %xmm3, %xmm1
#else
	addsd	 %xmm2, %xmm0
	subsd	 %xmm3, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movsd	%xmm0, 0 * SIZE(RESULT)
	movsd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3

.L50:
	/* X is aligned, Y is not aligned */

	cmpq	$2 * SIZE, INCX
	jne	.L60
	cmpq	$2 * SIZE, INCY
	jne	.L60

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L55
	ALIGN_3

.L51:
	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(Y), %xmm4
	movhpd	 -15 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(Y), %xmm4
	movhpd	 -13 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -12 * SIZE(Y), %xmm4
	movhpd	 -11 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -10 * SIZE(Y), %xmm4
	movhpd	  -9 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	  -8 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	  -8 * SIZE(Y), %xmm4
	movhpd	  -7 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	  -6 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	  -6 * SIZE(Y), %xmm4
	movhpd	  -5 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	  -4 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	  -4 * SIZE(Y), %xmm4
	movhpd	  -3 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	  -2 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	  -2 * SIZE(Y), %xmm4
	movhpd	  -1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	decq	%rax
	jg	.L51
	ALIGN_3

.L55:
	testq	$4, N
	jle	.L56

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(Y), %xmm4
	movhpd	 -15 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(Y), %xmm4
	movhpd	 -13 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addpd	 %xmm6, %xmm2
	movapd	 -12 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -12 * SIZE(Y), %xmm4
	movhpd	 -11 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -10 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -10 * SIZE(Y), %xmm4
	movhpd	  -9 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L56:
	testq	$2, N
	jle	.L57

	addpd	 %xmm6, %xmm2
	movapd	 -16 * SIZE(X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 -16 * SIZE(Y), %xmm4
	movhpd	 -15 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addpd	 %xmm6, %xmm0
	movapd	 -14 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -14 * SIZE(Y), %xmm4
	movhpd	 -13 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L57:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L69

	movapd	 -16 * SIZE(X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 -16 * SIZE(Y), %xmm4
	movhpd	 -15 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
	jmp	 .L69
	ALIGN_3

.L60:
#ifdef F_INTERFACE
	testq	INCX, INCX
	jge	.L61

	movq	N, %rax
	decq	%rax
	imulq	INCX, %rax
	subq	%rax, X
	ALIGN_3

.L61:
	testq	INCY, INCY
	jge	.L62

	movq	N, %rax
	decq	%rax
	imulq	INCY, %rax
	subq	%rax, Y
	ALIGN_3
.L62:
#endif

	movq	N,  %rax
	sarq	$3, %rax
	jle	.L65
	ALIGN_3

.L63:
	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L63
	ALIGN_3

.L65:
	testq	$4, N
	jle	.L66

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L66:
	testq	$2, N
	jle	.L67

	addpd	 %xmm6, %xmm2
	movapd	 (X), %xmm5
	movapd	%xmm5, %xmm6
	SHUFPD_1 %xmm5, %xmm5
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm7, %xmm3
	mulpd	 %xmm4, %xmm5

	addq	INCX, X
	addq	INCY, Y

	addpd	 %xmm6, %xmm0
	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm5, %xmm1
	mulpd	 %xmm4, %xmm7

	addq	INCX, X
	addq	INCY, Y
	ALIGN_3

.L67:
	addpd	 %xmm6, %xmm2
	addpd	 %xmm7, %xmm3

	testq	$1, N
	jle	.L69

	movapd	 (X), %xmm7
	movapd	%xmm7, %xmm6
	SHUFPD_1 %xmm7, %xmm7
	movsd	 (Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	mulpd	 %xmm4, %xmm6
	addpd	 %xmm6, %xmm0
	mulpd	 %xmm4, %xmm7
	addpd	 %xmm7, %xmm1
	ALIGN_3

.L69:
	addpd	%xmm0, %xmm2
	addpd	%xmm3, %xmm1

	movapd	 %xmm2, %xmm0
	unpckhpd %xmm2, %xmm2

	movapd	 %xmm1, %xmm3
	unpckhpd %xmm1, %xmm1

#ifndef CONJ
	subsd	 %xmm2, %xmm0
	addsd	 %xmm3, %xmm1
#else
	addsd	 %xmm2, %xmm0
	subsd	 %xmm3, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movsd	%xmm0, 0 * SIZE(RESULT)
	movsd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret
	ALIGN_3

.L70:
	cmpq	$2 * SIZE, INCX
	jne	.L80
	cmpq	$2 * SIZE, INCY
	jne	.L80

	movapd	-1 * SIZE(Y), %xmm8
	movq	N,  %rax
	sarq	$2, %rax
	jle	.L75
	ALIGN_3

.L73:
	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	movsd	 2 * SIZE(X), %xmm5
	movhpd	 3 * SIZE(X), %xmm5

	movapd	 1 * SIZE(Y), %xmm9
	movapd	 3 * SIZE(Y), %xmm10

	SHUFPD_3 %xmm8,  %xmm8
	movddup	 %xmm9,  %xmm12
	SHUFPD_3 %xmm9,  %xmm9
	movddup	 %xmm10, %xmm13

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm12
	mulpd	 %xmm5, %xmm9
	mulpd	 %xmm5, %xmm13

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm12, %xmm1
	addpd	 %xmm9,  %xmm2
	addpd	 %xmm13, %xmm3

	movsd	 4 * SIZE(X), %xmm6
	movhpd	 5 * SIZE(X), %xmm6
	movsd	 6 * SIZE(X), %xmm7
	movhpd	 7 * SIZE(X), %xmm7

	movapd	 5 * SIZE(Y), %xmm11
	movapd	 7 * SIZE(Y), %xmm8

	SHUFPD_3 %xmm10, %xmm10
	movddup	 %xmm11, %xmm14
	SHUFPD_3 %xmm11, %xmm11
	movddup	 %xmm8, %xmm15

	mulpd	 %xmm6, %xmm10
	mulpd	 %xmm6, %xmm14
	mulpd	 %xmm7, %xmm11
	mulpd	 %xmm7, %xmm15

	addpd	 %xmm10, %xmm0
	addpd	 %xmm14, %xmm1
	addpd	 %xmm11, %xmm2
	addpd	 %xmm15, %xmm3

	addq	 $8 * SIZE, X
	addq	 $8 * SIZE, Y

	decq	%rax
	jg	.L73
	ALIGN_3

.L75:
	testq	$2, N
	jle	.L77

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4
	movapd	 1 * SIZE(Y), %xmm9
	SHUFPD_3 %xmm8, %xmm8
	movddup	 %xmm9, %xmm13
	SHUFPD_3 %xmm9, %xmm9

	mulpd	 %xmm4, %xmm8
	mulpd	 %xmm4, %xmm13
	addpd	 %xmm8,   %xmm0
	addpd	 %xmm13,  %xmm1

	movsd	 2 * SIZE(X), %xmm5
	movhpd	 3 * SIZE(X), %xmm5
	movapd	 3 * SIZE(Y), %xmm8
	movddup	 %xmm8, %xmm14
	mulpd	 %xmm5, %xmm9
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm9,  %xmm2
	addpd	 %xmm14, %xmm3

	addq	 $4 * SIZE, X
	addq	 $4 * SIZE, Y
	ALIGN_3

.L77:
	testq	$1, N
	jle	.L999

	movsd	 0 * SIZE(X), %xmm4
	movhpd	 1 * SIZE(X), %xmm4

	movapd	 1 * SIZE(Y), %xmm9

	SHUFPD_3 %xmm8, %xmm8
	movddup	 %xmm9, %xmm13

	mulpd	 %xmm4,  %xmm8
	mulpd	 %xmm4,  %xmm13
	addpd	 %xmm8,  %xmm0
	addpd	 %xmm13, %xmm1
	jmp	 .L999
	ALIGN_3

.L80:
#ifdef F_INTERFACE
	testq	INCX, INCX		# if (incx < 0)
	jge	.L81

	movq	N, %rax		# n
	decq	%rax			# n - 1
	imulq	INCX, %rax		# (n - 1) * incx
	subq	%rax, X
	ALIGN_3

.L81:
	testq	INCY, INCY		# if (incy < 0)
	jge	.L82

	movq	N, %rax
	decq	%rax			# (n - 1)
	imulq	INCY, %rax		# (n - 1) * incy
	subq	%rax, Y
	ALIGN_3
.L82:
#endif

	movq	N,  %rax
	sarq	$2, %rax
	jle	.L85
	ALIGN_3

.L83:
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

	decq	%rax
	jg	.L83
	ALIGN_3

.L85:
	testq	$2, N
	jle	.L87

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

.L87:
	testq	$1, N
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
	ALIGN_3

.L999:
        addpd   %xmm0, %xmm2
        addpd   %xmm1, %xmm3

        movapd  %xmm2,  %xmm0
        unpckhpd %xmm2, %xmm2

        movapd  %xmm3, %xmm1
        unpckhpd %xmm3, %xmm3

#ifndef CONJ
        subsd    %xmm3, %xmm0
        addsd    %xmm2, %xmm1
#else
        addsd    %xmm3, %xmm0
        subsd    %xmm2, %xmm1
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	movsd	%xmm0, 0 * SIZE(RESULT)
	movsd	%xmm1, 1 * SIZE(RESULT)
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
