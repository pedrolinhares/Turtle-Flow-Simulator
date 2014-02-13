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
#define PREFETCH_SIZE (16 * 8)
#define movsd	     movlps
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

	addq	INCX, INCX
	addq	INCY, INCY

	leaq	(, INCX, SIZE), INCX	
	leaq	(, INCY, SIZE), INCY	

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
	sarq	$4, %rax
	jle	.L15

	movddup	 0 * SIZE(X), %xmm4
	movddup	 2 * SIZE(X), %xmm6
	movddup	 4 * SIZE(X), %xmm8
	movddup	 6 * SIZE(X), %xmm10

	movsd	 0 * SIZE(Y), %xmm5
	movsd	 2 * SIZE(Y), %xmm7
	movsd	 4 * SIZE(Y), %xmm9
	movsd	 6 * SIZE(Y), %xmm11

	movsd	 8 * SIZE(Y), %xmm12
	movsd	10 * SIZE(Y), %xmm13
	movsd	12 * SIZE(Y), %xmm14
	movsd	14 * SIZE(Y), %xmm15

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

	mulps	 %xmm4, %xmm5
	mulps	 %xmm6, %xmm7
	mulps	 %xmm8, %xmm9
	mulps	 %xmm10, %xmm11

	movddup	 8 * SIZE(X), %xmm4
	movddup	10 * SIZE(X), %xmm6
	movddup	12 * SIZE(X), %xmm8
	movddup	14 * SIZE(X), %xmm10

	decq	%rax
	jle	.L12
	ALIGN_3

.L11:
	unpcklps	%xmm12, %xmm12
	unpcklps	%xmm13, %xmm13
	unpcklps	%xmm14, %xmm14
	unpcklps	%xmm15, %xmm15

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0) * SIZE(X)
#endif

	addps	 %xmm5,  %xmm0
	movsd	16 * SIZE(Y), %xmm5
	mulps	 %xmm4, %xmm12
	movddup	16 * SIZE(X), %xmm4
	addps	 %xmm7,  %xmm1
	movsd	18 * SIZE(Y), %xmm7
	mulps	 %xmm6, %xmm13
	movddup	18 * SIZE(X), %xmm6

	addps	 %xmm9,  %xmm2
	movsd	20 * SIZE(Y), %xmm9
	mulps	 %xmm8, %xmm14
	movddup	20 * SIZE(X), %xmm8
	addps	 %xmm11, %xmm3
	movsd	22 * SIZE(Y), %xmm11
	mulps	 %xmm10, %xmm15
	movddup	22 * SIZE(X), %xmm10

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 0) * SIZE(Y)
#endif

	addps	 %xmm12, %xmm0
	movsd	24 * SIZE(Y), %xmm12
	mulps	 %xmm4, %xmm5
	movddup	24 * SIZE(X), %xmm4
	addps	 %xmm13, %xmm1
	movsd	26 * SIZE(Y), %xmm13
	mulps	 %xmm6, %xmm7
	movddup	26 * SIZE(X), %xmm6

	addps	 %xmm14, %xmm2
	movsd	28 * SIZE(Y), %xmm14
	mulps	 %xmm8, %xmm9
	movddup	28 * SIZE(X), %xmm8
	addps	 %xmm15, %xmm3
	movsd	30 * SIZE(Y), %xmm15
	mulps	 %xmm10, %xmm11
	movddup	30 * SIZE(X), %xmm10

	unpcklps	%xmm12, %xmm12
	unpcklps	%xmm13, %xmm13
	unpcklps	%xmm14, %xmm14
	unpcklps	%xmm15, %xmm15

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 16) * SIZE(X)
#endif

	addps	 %xmm5, %xmm0
	movsd	32 * SIZE(Y), %xmm5
	mulps	 %xmm4, %xmm12
	movddup	32 * SIZE(X), %xmm4
	addps	 %xmm7, %xmm1
	movsd	34 * SIZE(Y), %xmm7
	mulps	 %xmm6, %xmm13
	movddup	34 * SIZE(X), %xmm6

	addps	 %xmm9, %xmm2
	movsd	36 * SIZE(Y), %xmm9
	mulps	 %xmm8, %xmm14
	movddup	36 * SIZE(X), %xmm8
	addps	 %xmm11, %xmm3
	movsd	38 * SIZE(Y), %xmm11
	mulps	 %xmm10, %xmm15
	movddup	38 * SIZE(X), %xmm10

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

#ifdef BARCELONA
	PREFETCH	(PREFETCH_SIZE + 16) * SIZE(Y)
#endif

	addps	 %xmm12, %xmm0
	movsd	40 * SIZE(Y), %xmm12
	mulps	 %xmm4, %xmm5
	movddup	40 * SIZE(X), %xmm4
	addps	 %xmm13, %xmm1
	movsd	42 * SIZE(Y), %xmm13
	mulps	 %xmm6, %xmm7
	movddup	42 * SIZE(X), %xmm6

	addps	 %xmm14, %xmm2
	movsd	44 * SIZE(Y), %xmm14
	mulps	 %xmm8, %xmm9
	movddup	44 * SIZE(X), %xmm8
	addps	 %xmm15, %xmm3
	movsd	46 * SIZE(Y), %xmm15
	mulps	 %xmm10, %xmm11
	movddup	46 * SIZE(X), %xmm10

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y

	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	unpcklps	%xmm12, %xmm12
	unpcklps	%xmm13, %xmm13
	unpcklps	%xmm14, %xmm14
	unpcklps	%xmm15, %xmm15

	addps	 %xmm5,  %xmm0
	movsd	16 * SIZE(Y), %xmm5
	mulps	 %xmm4, %xmm12
	movddup	16 * SIZE(X), %xmm4
	addps	 %xmm7,  %xmm1
	movsd	18 * SIZE(Y), %xmm7
	mulps	 %xmm6, %xmm13
	movddup	18 * SIZE(X), %xmm6

	addps	 %xmm9,  %xmm2
	movsd	20 * SIZE(Y), %xmm9
	mulps	 %xmm8, %xmm14
	movddup	20 * SIZE(X), %xmm8
	addps	 %xmm11, %xmm3
	movsd	22 * SIZE(Y), %xmm11
	mulps	 %xmm10, %xmm15
	movddup	22 * SIZE(X), %xmm10

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

	addps	 %xmm12, %xmm0
	movsd	24 * SIZE(Y), %xmm12
	mulps	 %xmm4, %xmm5
	movddup	24 * SIZE(X), %xmm4
	addps	 %xmm13, %xmm1
	movsd	26 * SIZE(Y), %xmm13
	mulps	 %xmm6, %xmm7
	movddup	26 * SIZE(X), %xmm6

	addps	 %xmm14, %xmm2
	movsd	28 * SIZE(Y), %xmm14
	mulps	 %xmm8, %xmm9
	movddup	28 * SIZE(X), %xmm8
	addps	 %xmm15, %xmm3
	movsd	30 * SIZE(Y), %xmm15
	mulps	 %xmm10, %xmm11
	movddup	30 * SIZE(X), %xmm10

	unpcklps	%xmm12, %xmm12
	unpcklps	%xmm13, %xmm13
	unpcklps	%xmm14, %xmm14
	unpcklps	%xmm15, %xmm15

	addps	 %xmm5, %xmm0
	mulps	 %xmm4, %xmm12
	addps	 %xmm7, %xmm1
	mulps	 %xmm6, %xmm13

	addps	 %xmm9, %xmm2
	mulps	 %xmm8, %xmm14
	addps	 %xmm11, %xmm3
	mulps	 %xmm10, %xmm15

	addps	 %xmm12, %xmm0
	addps	 %xmm13, %xmm1
	addps	 %xmm14, %xmm2
	addps	 %xmm15, %xmm3

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L15:
	testq	$15, N
	jle	.L999

	testq	$8, N
	jle	.L16

	movddup	 0 * SIZE(X), %xmm4
	movddup	 2 * SIZE(X), %xmm6
	movddup	 4 * SIZE(X), %xmm8
	movddup	 6 * SIZE(X), %xmm10

	movsd	 0 * SIZE(Y), %xmm5
	movsd	 2 * SIZE(Y), %xmm7
	movsd	 4 * SIZE(Y), %xmm9
	movsd	 6 * SIZE(Y), %xmm11

	movsd	 8 * SIZE(Y), %xmm12
	movsd	10 * SIZE(Y), %xmm13
	movsd	12 * SIZE(Y), %xmm14
	movsd	14 * SIZE(Y), %xmm15

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

	mulps	 %xmm4, %xmm5
	movddup	 8 * SIZE(X), %xmm4
	mulps	 %xmm6, %xmm7
	movddup	10 * SIZE(X), %xmm6
	mulps	 %xmm8, %xmm9
	movddup	12 * SIZE(X), %xmm8
	mulps	 %xmm10, %xmm11
	movddup	14 * SIZE(X), %xmm10

	unpcklps	%xmm12, %xmm12
	unpcklps	%xmm13, %xmm13
	unpcklps	%xmm14, %xmm14
	unpcklps	%xmm15, %xmm15

	addps	 %xmm5,  %xmm0
	mulps	 %xmm4, %xmm12
	addps	 %xmm7,  %xmm1
	mulps	 %xmm6, %xmm13

	addps	 %xmm9,  %xmm2
	mulps	 %xmm8, %xmm14
	addps	 %xmm11, %xmm3
	mulps	 %xmm10, %xmm15

	addps	 %xmm12, %xmm0
	addps	 %xmm13, %xmm1
	addps	 %xmm14, %xmm2
	addps	 %xmm15, %xmm3

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L16:
	testq	$4, N
	jle	.L17

	movddup	 0 * SIZE(X), %xmm4
	movddup	 2 * SIZE(X), %xmm6
	movddup	 4 * SIZE(X), %xmm8
	movddup	 6 * SIZE(X), %xmm10

	movsd	 0 * SIZE(Y), %xmm5
	movsd	 2 * SIZE(Y), %xmm7
	movsd	 4 * SIZE(Y), %xmm9
	movsd	 6 * SIZE(Y), %xmm11

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7
	unpcklps	%xmm9, %xmm9
	unpcklps	%xmm11, %xmm11

	mulps	 %xmm4, %xmm5
	mulps	 %xmm6, %xmm7
	mulps	 %xmm8, %xmm9
	mulps	 %xmm10, %xmm11

	addps	 %xmm5,  %xmm0
	addps	 %xmm7,  %xmm1
	addps	 %xmm9,  %xmm2
	addps	 %xmm11, %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L17:
	testq	$2, N
	jle	.L18

	movddup	 0 * SIZE(X), %xmm4
	movddup	 2 * SIZE(X), %xmm6
	movsd	 0 * SIZE(Y), %xmm5
	movsd	 2 * SIZE(Y), %xmm7

	unpcklps	%xmm5, %xmm5
	unpcklps	%xmm7, %xmm7

	mulps	 %xmm4, %xmm5
	mulps	 %xmm6, %xmm7
	addps	 %xmm5,  %xmm0
	addps	 %xmm7,  %xmm1

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L18:
	testq	$1, N
	jle	.L999

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5

	unpcklps	%xmm5, %xmm5

	mulps	 %xmm4, %xmm5
	addps	 %xmm5,  %xmm0
	jmp	.L999
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
	jge	.L60

	movq	N, %rax
	decq	%rax			# (n - 1)
	imulq	INCY, %rax		# (n - 1) * incy
	subq	%rax, Y
	ALIGN_3
.L60:
#endif
	movq	N,  %rax
	sarq	$3, %rax
	jle	.L65
	ALIGN_3

.L62:
	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm0
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm1
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm2
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm3
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm0
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm1
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm2
	addq	INCX, X
	addq	INCY, Y

	movddup	 0 * SIZE(X), %xmm4
	movsd	 0 * SIZE(Y), %xmm5
	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm3
	addq	INCX, X
	addq	INCY, Y

	decq	%rax
	jg	.L62
	ALIGN_3

.L65:
	movq	N, %rax
	andq	$7,   %rax
	jle	.L999
	ALIGN_3

.L66:
	movddup	 0 * SIZE(X), %xmm4	/* a b a b */
	movsd	 0 * SIZE(Y), %xmm5	/* c d x x */

	unpcklps	%xmm5, %xmm5
	mulps	 %xmm4, %xmm5
	addps	 %xmm5, %xmm0

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L66
	ALIGN_3

.L999:
	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	addps	%xmm2, %xmm0

	movhlps	%xmm0, %xmm1	/* a b c d */

	pshufd	$ 1, %xmm0, %xmm2
	pshufd	$11, %xmm0, %xmm3

#ifndef CONJ
	subss	 %xmm3, %xmm0
	addss	 %xmm2, %xmm1
#else
	addss	 %xmm3, %xmm0
	subss	 %xmm2, %xmm1
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
