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

#define N	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#else
#define INCY	%r10
#endif

#define PREFETCH	prefetch
#ifdef BARCELONA
#define PREFETCHSIZE	(8 * 20)
#else
#define PREFETCHSIZE	(8 * 16)
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
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

	leaq	(, INCX, SIZE), INCX	
	leaq	(, INCY, SIZE), INCY	

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	cmpq	$0, N
	jle	.L999

	cmpq	$SIZE, INCX
	jne	.L50
	cmpq	$SIZE, INCY
	jne	.L50

	testq	$SIZE, Y
	je	.L10

	movsd	  0 * SIZE(X), %xmm0
	mulsd	  0 * SIZE(Y), %xmm0
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	N
	jle	.L999
	ALIGN_2

.L10:
	testq	$SIZE, X
	jne	.L20

	movq	N,    %rax
	andq	$-16, %rax
	jle	.L14

	leaq	(X, %rax, 8), X
	leaq	(Y, %rax, 8), Y
	negq	%rax

	movapd	  0 * SIZE(X, %rax, 8), %xmm4
	movapd	  2 * SIZE(Y, %rax, 8), %xmm5
	movapd	  4 * SIZE(X, %rax, 8), %xmm6
	movapd	  6 * SIZE(Y, %rax, 8), %xmm7

	movapd	  8 * SIZE(X, %rax, 8), %xmm8
	movapd	 10 * SIZE(Y, %rax, 8), %xmm9
	movapd	 12 * SIZE(X, %rax, 8), %xmm10
	movapd	 14 * SIZE(Y, %rax, 8), %xmm11

	mulpd	  0 * SIZE(Y, %rax, 8), %xmm4
	mulpd	  2 * SIZE(X, %rax, 8), %xmm5
	mulpd	  4 * SIZE(Y, %rax, 8), %xmm6
	mulpd	  6 * SIZE(X, %rax, 8), %xmm7

	subq	$-16, %rax
	jge	.L12
	ALIGN_3

.L11:
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm8
	addpd	%xmm4,  %xmm0
	movapd	  0 * SIZE(X, %rax, 8), %xmm4

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(Y, %rax, 8)

	mulpd	 -6 * SIZE(X, %rax, 8), %xmm9
	addpd	%xmm5,  %xmm1
	movapd	  2 * SIZE(Y, %rax, 8), %xmm5

	mulpd	 -4 * SIZE(Y, %rax, 8), %xmm10
	addpd	%xmm6,  %xmm2
	movapd	  4 * SIZE(X, %rax, 8), %xmm6

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X, %rax, 8)

	mulpd	 -2 * SIZE(X, %rax, 8), %xmm11
	addpd	%xmm7,  %xmm3
	movapd	  6 * SIZE(Y, %rax, 8), %xmm7

	mulpd	  0 * SIZE(Y, %rax, 8), %xmm4
	addpd	%xmm8,  %xmm0
	movapd	  8 * SIZE(X, %rax, 8), %xmm8

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(X, %rax, 8)

	mulpd	  2 * SIZE(X, %rax, 8), %xmm5
	addpd	%xmm9,  %xmm1
	movapd	 10 * SIZE(Y, %rax, 8), %xmm9

	mulpd	  4 * SIZE(Y, %rax, 8), %xmm6
	addpd	%xmm10, %xmm2
	movapd	 12 * SIZE(X, %rax, 8), %xmm10

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(Y, %rax, 8)

	mulpd	  6 * SIZE(X, %rax, 8), %xmm7
	addpd	%xmm11, %xmm3
	movapd	 14 * SIZE(Y, %rax, 8), %xmm11

	subq	$-16, %rax
	jl,pt	.L11
	ALIGN_3

.L12:
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm8
	addpd	%xmm4,  %xmm0
	mulpd	 -6 * SIZE(X, %rax, 8), %xmm9
	addpd	%xmm5,  %xmm1
	mulpd	 -4 * SIZE(Y, %rax, 8), %xmm10
	addpd	%xmm6,  %xmm2
	mulpd	 -2 * SIZE(X, %rax, 8), %xmm11
	addpd	%xmm7,  %xmm3

	addpd	%xmm8,  %xmm0
	addpd	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	addpd	%xmm11, %xmm3
	ALIGN_3

.L14:
	testq	$15, N
	jle	.L999

	testq	$8, N
	jle	.L15

	movapd	  0 * SIZE(X), %xmm4
	movapd	  2 * SIZE(X), %xmm5
	movapd	  4 * SIZE(X), %xmm6
	movapd	  6 * SIZE(X), %xmm7

	mulpd	  0 * SIZE(Y), %xmm4
	mulpd	  2 * SIZE(Y), %xmm5
	mulpd	  4 * SIZE(Y), %xmm6
	mulpd	  6 * SIZE(Y), %xmm7

	addpd	%xmm4,  %xmm0
	addpd	%xmm5,  %xmm1
	addpd	%xmm6,  %xmm2
	addpd	%xmm7,  %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L15:
	testq	$4, N
	jle	.L16

	movapd	  0 * SIZE(X), %xmm4
	movapd	  2 * SIZE(X), %xmm5

	mulpd	  0 * SIZE(Y), %xmm4
	mulpd	  2 * SIZE(Y), %xmm5

	addpd	%xmm4,  %xmm0
	addpd	%xmm5,  %xmm1

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L16:
	testq	$2, N
	jle	.L17

	movapd	  0 * SIZE(X), %xmm4
	mulpd	  0 * SIZE(Y), %xmm4
	addpd	%xmm4,  %xmm2

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L17:
	testq	$1, N
	jle	.L999

	movsd	  0 * SIZE(X), %xmm4
	mulsd	  0 * SIZE(Y), %xmm4

	addsd	%xmm4,  %xmm3
	jmp	.L999
	ALIGN_3


.L20:
	movq	N,    %rax
	andq	$-16, %rax
	jle	.L24

	leaq	(X, %rax, 8), X
	leaq	(Y, %rax, 8), Y
	negq	%rax

	movlpd	  0 * SIZE(X, %rax, 8), %xmm4
	movhpd	  1 * SIZE(X, %rax, 8), %xmm4
	movlpd	  2 * SIZE(X, %rax, 8), %xmm5
	movhpd	  3 * SIZE(X, %rax, 8), %xmm5
	movlpd	  4 * SIZE(X, %rax, 8), %xmm6
	movhpd	  5 * SIZE(X, %rax, 8), %xmm6
	movlpd	  6 * SIZE(X, %rax, 8), %xmm7
	movhpd	  7 * SIZE(X, %rax, 8), %xmm7

	movlpd	  8 * SIZE(X, %rax, 8), %xmm8
	movhpd	  9 * SIZE(X, %rax, 8), %xmm8
	movlpd	 10 * SIZE(X, %rax, 8), %xmm9
	movhpd	 11 * SIZE(X, %rax, 8), %xmm9
	movlpd	 12 * SIZE(X, %rax, 8), %xmm10
	movhpd	 13 * SIZE(X, %rax, 8), %xmm10
	movlpd	 14 * SIZE(X, %rax, 8), %xmm11

	mulpd	  0 * SIZE(Y, %rax, 8), %xmm4
	mulpd	  2 * SIZE(Y, %rax, 8), %xmm5
	mulpd	  4 * SIZE(Y, %rax, 8), %xmm6
	mulpd	  6 * SIZE(Y, %rax, 8), %xmm7

	subq	$-16, %rax
	jge	.L22
	ALIGN_3

.L21:
	mulpd	 -8 * SIZE(Y, %rax, 8), %xmm8
	addpd	%xmm4,  %xmm0
	movhpd	 -1 * SIZE(X, %rax, 8), %xmm11
	movlpd	  0 * SIZE(X, %rax, 8), %xmm4

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X, %rax, 8)

	mulpd	 -6 * SIZE(Y, %rax, 8), %xmm9
	addpd	%xmm5,  %xmm1
	movhpd	  1 * SIZE(X, %rax, 8), %xmm4
	movlpd	  2 * SIZE(X, %rax, 8), %xmm5

	mulpd	 -4 * SIZE(Y, %rax, 8), %xmm10
	addpd	%xmm6,  %xmm2
	movlpd	  4 * SIZE(X, %rax, 8), %xmm6
	movhpd	  3 * SIZE(X, %rax, 8), %xmm5

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(Y, %rax, 8)

	mulpd	 -2 * SIZE(Y, %rax, 8), %xmm11
	addpd	%xmm7,  %xmm3
	movlpd	  6 * SIZE(X, %rax, 8), %xmm7
	movhpd	  5 * SIZE(X, %rax, 8), %xmm6

	mulpd	  0 * SIZE(Y, %rax, 8), %xmm4
	addpd	%xmm8,  %xmm0
	movhpd	  7 * SIZE(X, %rax, 8), %xmm7
	movlpd	  8 * SIZE(X, %rax, 8), %xmm8

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(X, %rax, 8)

	mulpd	  2 * SIZE(Y, %rax, 8), %xmm5
	addpd	%xmm9,  %xmm1
	movhpd	  9 * SIZE(X, %rax, 8), %xmm8
	movlpd	 10 * SIZE(X, %rax, 8), %xmm9

	mulpd	  4 * SIZE(Y, %rax, 8), %xmm6
	addpd	%xmm10, %xmm2
	movhpd	 11 * SIZE(X, %rax, 8), %xmm9
	movlpd	 12 * SIZE(X, %rax, 8), %xmm10

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(Y, %rax, 8)

	mulpd	  6 * SIZE(Y, %rax, 8), %xmm7
	addpd	%xmm11, %xmm3
	movhpd	 13 * SIZE(X, %rax, 8), %xmm10
	movlpd	 14 * SIZE(X, %rax, 8), %xmm11

	subq	$-16, %rax
	jl,pt	.L21
	ALIGN_3

.L22:
	movhpd	 -1 * SIZE(X, %rax, 8), %xmm11

	mulpd	 -8 * SIZE(Y), %xmm8
	mulpd	 -6 * SIZE(Y), %xmm9
	mulpd	 -4 * SIZE(Y), %xmm10
	mulpd	 -2 * SIZE(Y), %xmm11

	addpd	%xmm4,  %xmm0
	addpd	%xmm5,  %xmm1
	addpd	%xmm6,  %xmm2
	addpd	%xmm7,  %xmm3

	addpd	%xmm8,  %xmm0
	addpd	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	addpd	%xmm11, %xmm3
	ALIGN_3

.L24:
	testq	$15, N
	jle	.L999

	testq	$8, N
	jle	.L25

	movlpd	  0 * SIZE(X), %xmm4
	movhpd	  1 * SIZE(X), %xmm4
	movlpd	  2 * SIZE(X), %xmm5
	movhpd	  3 * SIZE(X), %xmm5
	movlpd	  4 * SIZE(X), %xmm6
	movhpd	  5 * SIZE(X), %xmm6
	movlpd	  6 * SIZE(X), %xmm7
	movhpd	  7 * SIZE(X), %xmm7

	mulpd	  0 * SIZE(Y), %xmm4
	mulpd	  2 * SIZE(Y), %xmm5
	mulpd	  4 * SIZE(Y), %xmm6
	mulpd	  6 * SIZE(Y), %xmm7

	addpd	%xmm4,  %xmm0
	addpd	%xmm5,  %xmm1
	addpd	%xmm6,  %xmm2
	addpd	%xmm7,  %xmm3

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	testq	$4, N
	jle	.L26

	movlpd	  0 * SIZE(X), %xmm4
	movhpd	  1 * SIZE(X), %xmm4
	movlpd	  2 * SIZE(X), %xmm5
	movhpd	  3 * SIZE(X), %xmm5

	mulpd	  0 * SIZE(Y), %xmm4
	mulpd	  2 * SIZE(Y), %xmm5

	addpd	%xmm4,  %xmm0
	addpd	%xmm5,  %xmm1

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	testq	$2, N
	jle	.L27

	movlpd	  0 * SIZE(X), %xmm4
	movhpd	  1 * SIZE(X), %xmm4
	mulpd	  0 * SIZE(Y), %xmm4
	addpd	%xmm4,  %xmm2

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L27:
	testq	$1, N
	jle	.L999

	movsd	  0 * SIZE(X), %xmm4
	mulsd	  0 * SIZE(Y), %xmm4

	addsd	%xmm4,  %xmm3
	jmp	.L999
	ALIGN_3

.L50:
#ifdef F_INTERFACE
	testq	INCX, INCX
	jge	.L51

	movq	N, %rax
	decq	%rax
	imulq	INCX, %rax
	subq	%rax, X
	ALIGN_3

.L51:
	testq	INCY, INCY
	jge	.L52

	movq	N, %rax
	decq	%rax
	imulq	INCY, %rax
	subq	%rax, Y
	ALIGN_3
.L52:
#endif
	movq	N,  %rax
	sarq	$2, %rax
	jle	.L55
	ALIGN_3

.L53:
	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	mulsd	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	mulsd	0 * SIZE(Y), %xmm5
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	mulsd	0 * SIZE(Y), %xmm6
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X
	mulsd	0 * SIZE(Y), %xmm7
	addq	INCY, Y

	addsd	%xmm4, %xmm0
	addsd	%xmm5, %xmm1
	addsd	%xmm6, %xmm2
	addsd	%xmm7, %xmm3

	decq	%rax
	jg	.L53
	ALIGN_3

.L55:
	movq	N, %rax
	andq	$3,   %rax
	jle	.L999
	ALIGN_3

.L56:
	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	mulsd	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	addsd	%xmm4, %xmm0
	decq	%rax
	jg	.L56
	ALIGN_3

.L999:
	addpd	%xmm1, %xmm0
	addpd	%xmm3, %xmm2
	addpd	%xmm2, %xmm0

#ifndef HAVE_SSE3
	movapd	%xmm0, %xmm1
	unpckhpd	%xmm0, %xmm0
	addsd	%xmm1, %xmm0
#else
	haddpd	%xmm0, %xmm0
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
