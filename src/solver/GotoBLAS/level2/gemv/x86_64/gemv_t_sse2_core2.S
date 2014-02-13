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

#define P 8192

#define PREFETCH	prefetch
#define PREFETCHW	prefetchw
#define PREFETCHSIZE	80

#ifndef WINDOWS_ABI

#define STACKSIZE	128
	
#define OLD_INCX	  8 + STACKSIZE(%rsp)
#define OLD_Y		 16 + STACKSIZE(%rsp)
#define OLD_INCY	 24 + STACKSIZE(%rsp)
#define BUFFER		 32 + STACKSIZE(%rsp)
	
#define NLDA	         48(%rsp)
#define J	         56(%rsp)

#define M	  %rdi
#define N	  %rsi
#define A	  %rcx
#define LDA	  %r8
#define X	  %r9
#define INCX	  %rdx
#define Y	  %rbp
#define INCY	  %r10

#else

#define STACKSIZE	256
	
#define OLD_A		 40 + STACKSIZE(%rsp)
#define OLD_LDA		 48 + STACKSIZE(%rsp)
#define OLD_X		 56 + STACKSIZE(%rsp)
#define OLD_INCX	 64 + STACKSIZE(%rsp)
#define OLD_Y		 72 + STACKSIZE(%rsp)
#define OLD_INCY	 80 + STACKSIZE(%rsp)
#define BUFFER		 88 + STACKSIZE(%rsp)
#define NLDA	        224(%rsp)
#define J	        232(%rsp)

#define M	  %rcx
#define N	  %rdx
#define A	  %rdi
#define LDA	  %r8
#define X	  %r9
#define INCX	  %rsi
#define Y	  %rbp
#define INCY	  %r10

#endif

#define TEMP  %rax
#define I     %rax
#define MIN_M %rbx
#define IS    %r11
#define AO1   %r12
#define AO2   %r13
#define AO3   %rdi
#define AO4   %r11
#define BO    %r14
#define CO    %r15

#define ALPHA %xmm15
	
	PROLOGUE
	PROFCODE

	subq	$STACKSIZE, %rsp
	movq	%rbx,  0(%rsp)
	movq	%rbp,  8(%rsp)
	movq	%r12, 16(%rsp)
	movq	%r13, 24(%rsp)
	movq	%r14, 32(%rsp)
	movq	%r15, 40(%rsp)

#ifdef WINDOWS_ABI
	movq	%rdi,    48(%rsp)
	movq	%rsi,    56(%rsp)
	movups	%xmm6,   64(%rsp)
	movups	%xmm7,   80(%rsp)
	movups	%xmm8,   96(%rsp)
	movups	%xmm9,  112(%rsp)
	movups	%xmm10, 128(%rsp)
	movups	%xmm11, 144(%rsp)
	movups	%xmm12, 160(%rsp)
	movups	%xmm13, 176(%rsp)
	movups	%xmm14, 192(%rsp)
	movups	%xmm15, 208(%rsp)

	movq	OLD_A,        A
	movq	OLD_LDA,      LDA
	movq	OLD_X,        X
#endif

	movq	OLD_INCX,  INCX
	movq	OLD_Y,     Y
	movq	OLD_INCY,  INCY
	
	leaq	(,INCX, SIZE), INCX
	leaq	(,INCY, SIZE), INCY

#ifndef WINDOWS_ABI
	movapd	 %xmm0, ALPHA
#else
	movapd	 %xmm3, ALPHA
#endif

	testq	M, M
	jle	.L999
	testq	N, N
	jle	.L999

	mov     N,   TEMP
	imulq	LDA, TEMP
	movq	$P,   BO
	subq	TEMP, BO

	leaq	(, BO,  SIZE), BO
	leaq	(, LDA, SIZE), LDA

	xor	IS, IS
	movq	BO, NLDA

	testq	$SIZE, LDA
	jne	.L100

	subq	$-16 * SIZE, A

	testq	$SIZE, A
	jne	.L50
	ALIGN_3

.L10:
	movq	$P,   TEMP
	movq	M,    MIN_M
	subq	IS,   MIN_M
	cmpq	TEMP, MIN_M
	cmovg	TEMP, MIN_M

	movq	BUFFER, BO

	movq	MIN_M, I
	sarq	$3,    I
	jle	.L15
	ALIGN_3

.L12:
	movsd	(X), %xmm0
	addq	INCX, X
	movhpd	(X), %xmm0
	addq	INCX, X

	movsd	(X), %xmm2
	addq	INCX, X
	movhpd	(X), %xmm2
	addq	INCX, X

	movsd	(X), %xmm4
	addq	INCX, X
	movhpd	(X), %xmm4
	addq	INCX, X

	movsd	(X), %xmm6
	addq	INCX, X
	movhpd	(X), %xmm6
	addq	INCX, X

	movapd	%xmm0, 0 * SIZE(BO)
	movapd	%xmm2, 2 * SIZE(BO)
	movapd	%xmm4, 4 * SIZE(BO)
	movapd	%xmm6, 6 * SIZE(BO)

	addq	$8 * SIZE, BO
	decq	I
	jg	.L12
	ALIGN_3

.L15:
	movq	MIN_M, I
	andq	$7,    I
	jle	.L20
	ALIGN_2

.L16:
	movsd	(X), %xmm0
	addq	INCX, X

	movsd	%xmm0, 0 * SIZE(BO)
	addq	$SIZE, BO
	decq	I
	jg	.L16
	ALIGN_3

.L20:
	movq	Y, CO
	movq	N,  J
	sarq	$2, J
	jle	.L30
	ALIGN_3

.L21:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	PREFETCHW	3 * SIZE(CO)

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L24

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11

	decq	I
	jle	.L23
	ALIGN_3

.L22:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	  4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	  6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 -8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	  8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 -8 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 -6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd   -6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 -6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 -6 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 -4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 -4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 -4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd   -2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 -2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 -2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 -2 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 0 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 0 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 2 * SIZE(AO2, LDA, 2), %xmm11

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	subq	$1, I
	jg	.L22
	ALIGN_3

.L23:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	  4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 -8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 -8 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-6 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-2 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	 18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	ALIGN_2

.L24:
	movq	MIN_M, I
	andq	$8,  I
	je	.L25

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L25:
	movq	MIN_M, I
	andq	$4,  I
	je	.L26

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L26:
	movq	MIN_M, I
	andq	$2,  I
	je	.L27

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L27:
	movq	MIN_M, I
	andq	$1,  I
	je	.L29

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	-16 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm2

	movsd	-16 * SIZE(AO2, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm3

.L29:
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
	haddpd	%xmm2, %xmm2
	haddpd	%xmm3, %xmm3

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1
	mulsd	ALPHA, %xmm2
	mulsd	ALPHA, %xmm3

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	addsd	(TEMP), %xmm2
	addq	INCY, TEMP
	addsd	(TEMP), %xmm3

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	movsd	%xmm2, (CO)
	addq	INCY, CO
	movsd	%xmm3, (CO)
	addq	INCY, CO

	decq	J
	jg	.L21
	ALIGN_3

.L30:
	movq	N,  J
	andq	$2, J
	jle	.L40
	ALIGN_3

.L31:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L34

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	decq	I
	jle	.L33
	ALIGN_3

.L32:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 -6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	 -6 * SIZE(AO2), %xmm9

	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 -2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	 -2 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd    0 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	  0 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	  2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	  2 * SIZE(AO2), %xmm9

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L32
	ALIGN_3

.L33:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 -6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 -6 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 -2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 -2 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	16 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-16 * SIZE, BO
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2

.L34:
	movq	MIN_M, I
	andq	$8,  I
	je	.L35

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L35:
	movq	MIN_M, I
	andq	$4,  I
	je	.L36

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L36:
	movq	MIN_M, I
	andq	$2,  I
	je	.L37

	movapd	 -16 * SIZE(AO1), %xmm4
	movapd	 -16 * SIZE(AO2), %xmm5

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L37:
	movq	MIN_M, I
	andq	$1,  I
	je	.L39

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	-16 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

.L39:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	ALIGN_3

.L40:
	movq	N,  J
	andq	$1, J
	jle	.L49
	ALIGN_3

.L41:
	movq	A, AO1
	addq	LDA, A
	movq	BUFFER, BO

	movapd	  0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	  2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L44

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	decq	I
	jle	.L43
	ALIGN_3

.L42:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	 -6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 -4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	 -2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 0 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	 2 * SIZE(AO1), %xmm8

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L42
	ALIGN_3

.L43:
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	 -8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	 -6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 -4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	 -2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO

.L44:
	movq	MIN_M, I
	andq	$8,  I
	je	.L45

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, BO

.L45:
	movq	MIN_M, I
	andq	$4,  I
	je	.L46

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm1
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, BO

.L46:
	movq	MIN_M, I
	andq	$2,  I
	je	.L47

	movapd	-16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, BO

.L47:
	movq	MIN_M, I
	andq	$1,  I
	je	.L48

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

.L48:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

	addpd	%xmm1, %xmm0

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
#else
	movapd	%xmm0, %xmm9
	unpckhpd %xmm0, %xmm0
	addsd	 %xmm9,  %xmm0
#endif

	mulsd	ALPHA, %xmm0

	addsd	(CO), %xmm0
	movsd	%xmm0, (CO)
	ALIGN_3

.L49:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L10
	jmp	.L999
	ALIGN_3

.L50:
	movq	$P,   TEMP
	movq	M,    MIN_M
	subq	IS,   MIN_M
	cmpq	TEMP, MIN_M
	cmovg	TEMP, MIN_M

	movq	BUFFER, BO

	movsd	(X), %xmm0
	movsd	%xmm0, 0 * SIZE(BO)
	addq	INCX, X
	addq	$2 * SIZE, BO

	leaq	-1(MIN_M), I
	sarq	$3,    I
	jle	.L55
	ALIGN_3

.L52:
	movsd	(X), %xmm0
	addq	INCX, X
	movhpd	(X), %xmm0
	addq	INCX, X

	movsd	(X), %xmm2
	addq	INCX, X
	movhpd	(X), %xmm2
	addq	INCX, X

	movsd	(X), %xmm4
	addq	INCX, X
	movhpd	(X), %xmm4
	addq	INCX, X

	movsd	(X), %xmm6
	addq	INCX, X
	movhpd	(X), %xmm6
	addq	INCX, X

	movapd	%xmm0, 0 * SIZE(BO)
	movapd	%xmm2, 2 * SIZE(BO)
	movapd	%xmm4, 4 * SIZE(BO)
	movapd	%xmm6, 6 * SIZE(BO)

	addq	$8 * SIZE, BO
	decq	I
	jg	.L52
	ALIGN_3

.L55:
	leaq	-1(MIN_M), I
	andq	$7,    I
	jle	.L60
	ALIGN_2

.L56:
	movsd	(X), %xmm0
	addq	INCX, X

	movsd	%xmm0, 0 * SIZE(BO)
	addq	$SIZE, BO
	decq	I
	jg	.L56
	ALIGN_3

.L60:
	movq	Y, CO
	movq	N,  J
	sarq	$2, J
	jle	.L70
	ALIGN_3

.L61:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A
	movq	BUFFER, BO

	movapd	(BO), %xmm12

	movsd	-16 * SIZE(AO1), %xmm0
	mulsd	%xmm12, %xmm0
	movsd	-16 * SIZE(AO2), %xmm1
	mulsd	%xmm12, %xmm1
	movsd	-16 * SIZE(AO1, LDA, 2), %xmm2
	mulsd	%xmm12, %xmm2
	movsd	-16 * SIZE(AO2, LDA, 2), %xmm3
	mulsd	%xmm12, %xmm3

	movapd	 2 * SIZE(BO), %xmm12
	movapd	 4 * SIZE(BO), %xmm13
	addq	$SIZE, AO1
	addq	$SIZE, AO2
	addq	$2 * SIZE, BO

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	leaq	-1(MIN_M), I
	sarq	$4,  I
	jle	.L64

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11

	decq	I
	jle	.L63
	ALIGN_3

.L62:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)
#endif

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2)

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 -8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 -8 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)
#endif

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-6 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO1, LDA, 2)

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-4 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)
#endif

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-2 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2, LDA, 2)

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 0 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 0 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)
#endif

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 2 * SIZE(AO2, LDA, 2), %xmm11

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L62
	ALIGN_3

.L63:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 -8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 -8 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-6 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-2 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-2 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-2 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L64:
	leaq	-1(MIN_M), I
	andq	$8,  I
	je	.L65

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L65:
	leaq	-1(MIN_M), I
	andq	$4,  I
	je	.L66

	movapd	 -16 * SIZE(AO1), %xmm4
	movapd	 -16 * SIZE(AO2), %xmm5
	movapd	 -16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 -16 * SIZE(AO2, LDA, 2), %xmm7
	movapd	 -14 * SIZE(AO1), %xmm8
	movapd	 -14 * SIZE(AO2), %xmm9
	movapd	 -14 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 -14 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L66:
	leaq	-1(MIN_M), I
	andq	$2,  I
	je	.L67

	movapd	 -16 * SIZE(AO1), %xmm4
	movapd	 -16 * SIZE(AO2), %xmm5
	movapd	 -16 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 -16 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L67:
	leaq	-1(MIN_M), I
	andq	$1,  I
	je	.L69

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	-16 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm2

	movsd	-16 * SIZE(AO2, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm3

.L69:
#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
	haddpd	%xmm2, %xmm2
	haddpd	%xmm3, %xmm3
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10
	movapd	%xmm2, %xmm11
	movapd	%xmm3, %xmm12

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1
	unpckhpd %xmm2, %xmm2
	unpckhpd %xmm3, %xmm3

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
	addsd	 %xmm11, %xmm2
	addsd	 %xmm12, %xmm3
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1
	mulsd	ALPHA, %xmm2
	mulsd	ALPHA, %xmm3

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	addsd	(TEMP), %xmm2
	addq	INCY, TEMP
	addsd	(TEMP), %xmm3

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	movsd	%xmm2, (CO)
	addq	INCY, CO
	movsd	%xmm3, (CO)
	addq	INCY, CO

	decq	J
	jg	.L61
	ALIGN_3

.L70:
	movq	N,  J
	andq	$2, J
	jle	.L80
	ALIGN_3

.L71:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A
	movq	BUFFER, BO

	movsd	0 * SIZE(BO), %xmm12
	movsd	-16 * SIZE(AO1), %xmm0
	mulsd	%xmm12, %xmm0
	movsd	-16 * SIZE(AO2), %xmm1
	mulsd	%xmm12, %xmm1


	movapd	2 * SIZE(BO), %xmm12
	movapd	4 * SIZE(BO), %xmm13
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	addq	$1 * SIZE, AO1
	addq	$1 * SIZE, AO2
	addq	$2 * SIZE, BO

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	leaq	-1(MIN_M), I
	sarq	$4,  I
	jle	.L74

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	decq	I
	jle	.L73
	ALIGN_3

.L72:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 -6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	 -6 * SIZE(AO2), %xmm9

	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	-2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	-2 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 0 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 0 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movapd	 2 * SIZE(AO2), %xmm9

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L72
	ALIGN_3

.L73:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 -8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-6 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-2 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-2 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	16 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L74:
	leaq	-1(MIN_M), I
	andq	$8,  I
	je	.L75

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	-10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	-10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L75:
	leaq	-1(MIN_M), I
	andq	$4,  I
	je	.L76

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5
	movapd	-14 * SIZE(AO1), %xmm8
	movapd	-14 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(BO), %xmm12

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L76:
	leaq	-1(MIN_M), I
	andq	$2,  I
	je	.L77

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-16 * SIZE(AO2), %xmm5

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L77:
	leaq	-1(MIN_M), I
	andq	$1,  I
	je	.L79

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	-16 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

.L79:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	ALIGN_3

.L80:
	movq	N,  J
	andq	$1, J
	jle	.L89
	ALIGN_3

.L81:
	movq	A, AO1
	addq	LDA, A
	movq	BUFFER, BO

	movsd	(BO), %xmm12
	movsd	-16 * SIZE (AO1), %xmm0
	mulsd	%xmm12, %xmm0
	pxor	%xmm1, %xmm1
	movapd	 2 * SIZE(BO), %xmm12
	pxor	%xmm2, %xmm2
	movapd	 4 * SIZE(BO), %xmm13
	pxor	%xmm3, %xmm3

	addq	$1 * SIZE, AO1
	addq	$1 * SIZE, AO2
	addq	$2 * SIZE, BO

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	leaq	-1(MIN_M), I
	sarq	$4,  I
	jle	.L84

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	decq	I
	jle	.L83
	ALIGN_3

.L82:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 -8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	-6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	-2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 0 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	 2 * SIZE(AO1), %xmm8

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L82
	ALIGN_3

.L83:
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	 -8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	-6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	-2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO

.L84:
	leaq	-1(MIN_M), I
	andq	$8,  I
	je	.L85

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	-12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	-10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, BO

.L85:
	leaq	-1(MIN_M), I
	andq	$4,  I
	je	.L86

	movapd	-16 * SIZE(AO1), %xmm4
	movapd	-14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm1
	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, BO

.L86:
	leaq	-1(MIN_M), I
	andq	$2,  I
	je	.L87

	movapd	-16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, BO

.L87:
	leaq	-1(MIN_M), I
	andq	$1,  I
	je	.L88

	movsd	-16 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

.L88:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1
	addpd	%xmm1, %xmm0

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
#else
	movapd	%xmm0, %xmm9
	unpckhpd %xmm0, %xmm0
	addsd	 %xmm9,  %xmm0
#endif

	mulsd	ALPHA, %xmm0

	addsd	(CO), %xmm0
	movsd	%xmm0, (CO)
	ALIGN_3

.L89:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L50
	jmp	.L999
	ALIGN_3

.L100:
	movq	$P,   TEMP
	movq	M,    MIN_M
	subq	IS,   MIN_M
	cmpq	TEMP, MIN_M
	cmovg	TEMP, MIN_M

	movq	BUFFER, BO

	movq	MIN_M, I
	sarq	$3,    I
	jle	.L115
	ALIGN_3

.L112:
	movsd	(X), %xmm0
	addq	INCX, X
	movhpd	(X), %xmm0
	addq	INCX, X

	movsd	(X), %xmm2
	addq	INCX, X
	movhpd	(X), %xmm2
	addq	INCX, X

	movsd	(X), %xmm4
	addq	INCX, X
	movhpd	(X), %xmm4
	addq	INCX, X

	movsd	(X), %xmm6
	addq	INCX, X
	movhpd	(X), %xmm6
	addq	INCX, X

	movapd	%xmm0, 0 * SIZE(BO)
	movapd	%xmm2, 2 * SIZE(BO)
	movapd	%xmm4, 4 * SIZE(BO)
	movapd	%xmm6, 6 * SIZE(BO)

	addq	$8 * SIZE, BO
	decq	I
	jg	.L112
	ALIGN_3

.L115:
	movq	MIN_M, I
	andq	$7,    I
	jle	.L120
	ALIGN_2

.L116:
	movsd	(X), %xmm0
	addq	INCX, X

	movsd	%xmm0, 0 * SIZE(BO)
	addq	$SIZE, BO
	decq	I
	jg	.L116
	ALIGN_3


.L120:
	movq	Y, CO

	testq	$SIZE, A
	jne	.L160

	movq	N,  J
	sarq	$2, J
	jle	.L130
	ALIGN_3

.L121:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movapd	 -1 * SIZE(AO2), %xmm5
	movapd	 -1 * SIZE(AO2, LDA, 2), %xmm7

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L124

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 2 * SIZE(AO1), %xmm8
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 1 * SIZE(AO2, LDA, 2), %xmm11

	decq	I
	jle	.L123
	ALIGN_3

.L122:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 3 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)
#endif

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 5 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 5 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2)

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 7 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)
#endif

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 9 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 9 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO1, LDA, 2)

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	11 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	11 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)
#endif

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	13 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	14 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	13 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2, LDA, 2)

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	15 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	16 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	15 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)
#endif

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	18 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	17 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	18 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	17 * SIZE(AO2, LDA, 2), %xmm11

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L122
	ALIGN_3

.L123:
	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 3 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 5 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 5 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 7 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 9 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 9 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	11 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	11 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	movapd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	13 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	14 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	13 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm11, %xmm7
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	15 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	15 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm7,  %xmm11
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L124:
	movq	MIN_M, I
	andq	$8,  I
	je	.L125

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 2 * SIZE(AO1), %xmm8
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 1 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 4 * SIZE(AO1, LDA, 2), %xmm6
	SHUFPD_1 %xmm11, %xmm7
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 3 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movapd	 6 * SIZE(AO1), %xmm8
	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 5 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 6 * SIZE(AO1, LDA, 2), %xmm10
	SHUFPD_1 %xmm7,  %xmm11
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 5 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	SHUFPD_1 %xmm11, %xmm7
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 7 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	SHUFPD_1 %xmm7,  %xmm11
	mulpd	%xmm13, %xmm11
	addpd	%xmm11, %xmm3
	movapd	10 * SIZE(BO), %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L125:
	movq	MIN_M, I
	andq	$4,  I
	je	.L126

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 2 * SIZE(AO1), %xmm8
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 1 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	SHUFPD_1 %xmm11, %xmm7
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 3 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	SHUFPD_1 %xmm5,  %xmm9
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	SHUFPD_1 %xmm7, %xmm11
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L126:
	movq	MIN_M, I
	andq	$2,  I
	je	.L127

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movapd	 1 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	SHUFPD_1 %xmm9,  %xmm5
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	SHUFPD_1 %xmm11, %xmm7
	mulpd	%xmm12, %xmm7
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	movapd	%xmm9, %xmm5
	movapd	%xmm7, %xmm11

	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L127:
	movq	MIN_M, I
	andq	$1,  I
	je	.L129

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	0 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

	movsd	0 * SIZE(AO1, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm2

	movsd	0 * SIZE(AO2, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm3

.L129:
#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
	haddpd	%xmm2, %xmm2
	haddpd	%xmm3, %xmm3
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10
	movapd	%xmm2, %xmm11
	movapd	%xmm3, %xmm12

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1
	unpckhpd %xmm2, %xmm2
	unpckhpd %xmm3, %xmm3

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
	addsd	 %xmm11, %xmm2
	addsd	 %xmm12, %xmm3
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1
	mulsd	ALPHA, %xmm2
	mulsd	ALPHA, %xmm3

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	addsd	(TEMP), %xmm2
	addq	INCY, TEMP
	addsd	(TEMP), %xmm3

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	movsd	%xmm2, (CO)
	addq	INCY, CO
	movsd	%xmm3, (CO)
	addq	INCY, CO

	decq	J
	jg	.L121
	ALIGN_3

.L130:
	movq	N,  J
	andq	$2, J
	jle	.L140
	ALIGN_3

.L131:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movapd	-1 * SIZE(AO2), %xmm5

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L134

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 2 * SIZE(AO1), %xmm8
	movapd	 1 * SIZE(AO2), %xmm9

	decq	I
	jle	.L133
	ALIGN_3

.L132:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 5 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	10 * SIZE(AO1), %xmm8
	movapd	 9 * SIZE(AO2), %xmm9

	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	11 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	13 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	15 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	18 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	17 * SIZE(AO2), %xmm9

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L132
	ALIGN_3

.L133:
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 5 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	10 * SIZE(AO1), %xmm8
	movapd	 9 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	11 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	13 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	15 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L134:
	movq	MIN_M, I
	andq	$8,  I
	je	.L135

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	movapd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	movapd	 5 * SIZE(AO2), %xmm9
	SHUFPD_1 %xmm9, %xmm5
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 7 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L135:
	movq	MIN_M, I
	andq	$4,  I
	je	.L136

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 1 * SIZE(AO2), %xmm9
	movapd	 2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 3 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm5, %xmm9
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L136:
	movq	MIN_M, I
	andq	$2,  I
	je	.L137

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 1 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm9, %xmm5
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1

	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L137:
	movq	MIN_M, I
	andq	$1,  I
	je	.L139

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	0 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

.L139:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	ALIGN_3

.L140:
	movq	N,  J
	andq	$1, J
	jle	.L149
	ALIGN_3

.L141:
	movq	A, AO1
	addq	LDA, A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L144

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 2 * SIZE(AO1), %xmm8

	decq	I
	jle	.L143
	ALIGN_3

.L142:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	16 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movapd	18 * SIZE(AO1), %xmm8

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L142
	ALIGN_3

.L143:
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	 8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	subq	$-16 * SIZE, AO1

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-16 * SIZE, BO

.L144:
	movq	MIN_M, I
	andq	$8,  I
	je	.L145

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	subq	$-8 * SIZE, AO1

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-8 * SIZE, BO

.L145:
	movq	MIN_M, I
	andq	$4,  I
	je	.L146

	movapd	 0 * SIZE(AO1), %xmm4
	movapd	 2 * SIZE(AO1), %xmm8
	subq	$-4 * SIZE, AO1

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	mulpd	%xmm13, %xmm8
	subq	$-4 * SIZE, BO
	addpd	%xmm8, %xmm1

.L146:
	movq	MIN_M, I
	andq	$2,  I
	je	.L147

	movapd	 0 * SIZE(AO1), %xmm4
	subq	$-2 * SIZE, AO1
	mulpd	%xmm12, %xmm4
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	subq	$-2 * SIZE, BO

.L147:
	movq	MIN_M, I
	andq	$1,  I
	je	.L148

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

.L148:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

	addpd	%xmm1, %xmm0

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
#else
	movapd	%xmm0, %xmm9
	unpckhpd %xmm0, %xmm0
	addsd	 %xmm9,  %xmm0
#endif

	mulsd	ALPHA, %xmm0

	addsd	(CO), %xmm0
	movsd	%xmm0, (CO)
	ALIGN_3

.L149:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L100
	jmp	.L999
	ALIGN_3

.L160:
	movq	N,  J
	sarq	$2, J
	jle	.L170
	ALIGN_3

.L161:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movapd	-1 * SIZE(AO1), %xmm4
	movapd	-1 * SIZE(AO1, LDA, 2), %xmm6


	movq	MIN_M, I
	sarq	$4,  I
	jle	.L164

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9
	movapd	 1 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 2 * SIZE(AO2, LDA, 2), %xmm11

	decq	I
	jle	.L163
	ALIGN_3

.L162:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 3 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 4 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)
#endif

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 5 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 6 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2)

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 7 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 8 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)
#endif

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	 9 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 9 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	10 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO1, LDA, 2)

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	11 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	12 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)
#endif

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	13 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	14 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	13 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	14 * SIZE(AO2, LDA, 2), %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(AO2, LDA, 2)

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	15 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	16 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	15 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	16 * SIZE(AO2, LDA, 2), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)
#endif

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	17 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	18 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	17 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	18 * SIZE(AO2, LDA, 2), %xmm11

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L162
	ALIGN_3

.L163:
	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 3 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 4 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 5 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 6 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 7 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 8 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	 9 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 9 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	10 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	11 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	12 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	movapd	13 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	14 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	13 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	14 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	15 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	15 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	SHUFPD_1 %xmm4,  %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6,  %xmm10
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L164:
	movq	MIN_M, I
	andq	$8,  I
	je	.L165

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9
	movapd	 1 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 2 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 3 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 4 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6, %xmm10
	addpd	%xmm8, %xmm0
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movapd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movapd	 5 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movapd	 6 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movapd	 7 * SIZE(AO1, LDA, 2), %xmm6

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6, %xmm10
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L165:
	movq	MIN_M, I
	andq	$4,  I
	je	.L166

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9
	movapd	 1 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 2 * SIZE(AO2, LDA, 2), %xmm11

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	SHUFPD_1 %xmm10, %xmm6
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movapd	 3 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	SHUFPD_1 %xmm6, %xmm10
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L166:
	movq	MIN_M, I
	andq	$2,  I
	je	.L167

	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 1 * SIZE(AO1, LDA, 2), %xmm10
	movapd	 0 * SIZE(AO2, LDA, 2), %xmm7

	SHUFPD_1 %xmm8,  %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	SHUFPD_1 %xmm10, %xmm6
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L167:
	movq	MIN_M, I
	andq	$1,  I
	je	.L169

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	0 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

	movsd	0 * SIZE(AO1, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm2

	movsd	0 * SIZE(AO2, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm3

.L169:
#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
	haddpd	%xmm2, %xmm2
	haddpd	%xmm3, %xmm3
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10
	movapd	%xmm2, %xmm11
	movapd	%xmm3, %xmm12

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1
	unpckhpd %xmm2, %xmm2
	unpckhpd %xmm3, %xmm3

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
	addsd	 %xmm11, %xmm2
	addsd	 %xmm12, %xmm3
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1
	mulsd	ALPHA, %xmm2
	mulsd	ALPHA, %xmm3

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	addsd	(TEMP), %xmm2
	addq	INCY, TEMP
	addsd	(TEMP), %xmm3

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	movsd	%xmm2, (CO)
	addq	INCY, CO
	movsd	%xmm3, (CO)
	addq	INCY, CO

	decq	J
	jg	.L161
	ALIGN_3

.L170:
	movq	N,  J
	andq	$2, J
	jle	.L180
	ALIGN_3

.L171:
	movq	A, AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movapd	-1 * SIZE(AO1), %xmm4

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L174

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9

	decq	I
	jle	.L173
	ALIGN_3

.L172:
	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 6 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 9 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	10 * SIZE(AO2), %xmm9

	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	12 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	13 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	14 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	15 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	16 * SIZE(BO), %xmm12
	movapd	16 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	17 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	18 * SIZE(AO2), %xmm9

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

	decq	I
	jg	.L172
	ALIGN_3

.L173:
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 6 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 9 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	10 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	12 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	13 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	14 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	15 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	16 * SIZE(BO), %xmm12

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO

.L174:
	movq	MIN_M, I
	andq	$8,  I
	je	.L175

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movapd	 4 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movapd	 5 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movapd	 6 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 7 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movapd	 8 * SIZE(BO), %xmm12

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO

.L175:
	movq	MIN_M, I
	andq	$4,  I
	je	.L176

	movapd	 0 * SIZE(AO2), %xmm5
	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 2 * SIZE(AO2), %xmm9

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO

.L176:
	movq	MIN_M, I
	andq	$2,  I
	je	.L177

	movapd	 1 * SIZE(AO1), %xmm8
	movapd	 0 * SIZE(AO2), %xmm5

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1

	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, AO2
	subq	$-2 * SIZE, BO

.L177:
	movq	MIN_M, I
	andq	$1,  I
	je	.L179

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movsd	0 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

.L179:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
	haddpd	%xmm1, %xmm1
#else
	movapd	%xmm0, %xmm9
	movapd	%xmm1, %xmm10

	unpckhpd %xmm0, %xmm0
	unpckhpd %xmm1, %xmm1

	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm1
#endif

	mulsd	ALPHA, %xmm0
	mulsd	ALPHA, %xmm1

	movq	CO, TEMP

	addsd	(TEMP), %xmm0
	addq	INCY, TEMP
	addsd	(TEMP), %xmm1
	addq	INCY, TEMP

	movsd	%xmm0, (CO)
	addq	INCY, CO
	movsd	%xmm1, (CO)
	addq	INCY, CO
	ALIGN_3

.L180:
	movq	N,  J
	andq	$1, J
	jle	.L189
	ALIGN_3

.L181:
	movq	A, AO1
	addq	LDA, A
	movq	BUFFER, BO

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCHW	4 * SIZE(CO)
#endif

	movapd	-1 * SIZE(AO1), %xmm4

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L184

	movapd	 1 * SIZE(AO1), %xmm8

	decq	I
	jle	.L183
	ALIGN_3

.L182:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	 5 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	 7 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	 9 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	13 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	15 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	17 * SIZE(AO1), %xmm8

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L182
	ALIGN_3

.L183:
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	 3 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	 5 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	 7 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movapd	 9 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movapd	11 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movapd	13 * SIZE(AO1), %xmm8

	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movapd	15 * SIZE(AO1), %xmm4

	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO

.L184:
	movq	MIN_M, I
	andq	$8,  I
	je	.L185

	movapd	 1 * SIZE(AO1), %xmm8
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0

	movapd	 3 * SIZE(AO1), %xmm4
	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1

	movapd	 5 * SIZE(AO1), %xmm8
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2

	movapd	 7 * SIZE(AO1), %xmm4
	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, BO

.L185:
	movq	MIN_M, I
	andq	$4,  I
	je	.L186

	movapd	 1 * SIZE(AO1), %xmm8
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0

	movapd	 3 * SIZE(AO1), %xmm4
	SHUFPD_1 %xmm4, %xmm8
	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm1

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, BO

.L186:
	movq	MIN_M, I
	andq	$2,  I
	je	.L187

	movapd	 1 * SIZE(AO1), %xmm8
	SHUFPD_1 %xmm8, %xmm4
	mulpd	%xmm12, %xmm4
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	subq	$-2 * SIZE, AO1
	subq	$-2 * SIZE, BO

.L187:
	movq	MIN_M, I
	andq	$1,  I
	je	.L188

	movsd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

.L188:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

	addpd	%xmm1, %xmm0

#ifdef HAVE_SSE3
	haddpd	%xmm0, %xmm0
#else
	movapd	%xmm0, %xmm9
	unpckhpd %xmm0, %xmm0
	addsd	 %xmm9,  %xmm0
#endif

	mulsd	ALPHA, %xmm0

	addsd	(CO), %xmm0
	movsd	%xmm0, (CO)
	ALIGN_3

.L189:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L100
	jmp	.L999
	ALIGN_3


.L999:
	movq	  0(%rsp), %rbx
	movq	  8(%rsp), %rbp
	movq	 16(%rsp), %r12
	movq	 24(%rsp), %r13
	movq	 32(%rsp), %r14
	movq	 40(%rsp), %r15
	addq	$STACKSIZE, %rsp

#ifdef WINDOWS_ABI
	movq	 48(%rsp), %rdi
	movq	 56(%rsp), %rsi
	movups	 64(%rsp), %xmm6
	movups	 80(%rsp), %xmm7
	movups	 96(%rsp), %xmm8
	movups	112(%rsp), %xmm9
	movups	128(%rsp), %xmm10
	movups	144(%rsp), %xmm11
	movups	160(%rsp), %xmm12
	movups	176(%rsp), %xmm13
	movups	192(%rsp), %xmm14
	movups	208(%rsp), %xmm15
#endif

	ret
	ALIGN_3

	EPILOGUE
