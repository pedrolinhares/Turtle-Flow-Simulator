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

#define PREFETCH	prefetch
#define PREFETCHW	prefetchw
#define PREFETCHSIZE	(8 * 3 + 4)

#define P 16384

#ifndef WINDOWS_ABI

#define STACKSIZE	 64
	
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
#define A	  %r8
#define LDA	  %r9
#define X	  %rdi
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

	movq	OLD_A,     A
	movq	OLD_LDA,   LDA
	movq	OLD_X,     X
#endif

	movq	OLD_INCX,  INCX
	movq	OLD_Y,     Y
	movq	OLD_INCY,  INCY
	
	leaq	(,INCX, SIZE), INCX
	leaq	(,INCY, SIZE), INCY

#ifndef WINDOWS_ABI
	movaps	 %xmm0, ALPHA
#else
	movaps	 %xmm3, ALPHA
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
	movlpd	(X), %xmm0
	addq	INCX, X
	movhpd	(X), %xmm0
	addq	INCX, X

	movlpd	(X), %xmm2
	addq	INCX, X
	movhpd	(X), %xmm2
	addq	INCX, X

	movlpd	(X), %xmm4
	addq	INCX, X
	movhpd	(X), %xmm4
	addq	INCX, X

	movlpd	(X), %xmm6
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
	movlpd	(X), %xmm0
	addq	INCX, X

	movlpd	%xmm0, 0 * SIZE(BO)
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

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5
	movupd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movupd	 0 * SIZE(AO2, LDA, 2), %xmm7

	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9
	movupd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movupd	 2 * SIZE(AO2, LDA, 2), %xmm11
	decq	I
	jle	.L23
	ALIGN_3

.L22:
	mulpd	%xmm12, %xmm4
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	 4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	 4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	 4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	addpd	%xmm8, %xmm0
	movupd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	 6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	 6 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	PREFETCH	PREFETCHSIZE * SIZE(AO1, LDA, 2)
	addpd	%xmm4, %xmm0
	movupd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	 8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	 8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	 8 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	PREFETCH	PREFETCHSIZE * SIZE(AO2, LDA, 2)
	addpd	%xmm8, %xmm0
	movupd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)
	addpd	%xmm8, %xmm0
	movupd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	14 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	14 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	14 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)
	addpd	%xmm4, %xmm0
	movupd	16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	16 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	16 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	16 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)
	addpd	%xmm8, %xmm0
	movupd	18 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	18 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	18 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	18 * SIZE(AO2, LDA, 2), %xmm11

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L22
	ALIGN_3

.L23:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	 4 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	 4 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	 4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	 6 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	 6 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	 8 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	 8 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	 8 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	10 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	10 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	10 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	movupd	12 * SIZE(AO2), %xmm5
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	movupd	12 * SIZE(AO1, LDA, 2), %xmm6
	mulpd	%xmm12, %xmm7
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3
	movupd	12 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	14 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	movupd	14 * SIZE(AO1, LDA, 2), %xmm10
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm11, %xmm3
	movupd	14 * SIZE(AO2, LDA, 2), %xmm11

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

.L24:
	movq	MIN_M, I
	andq	$8,  I
	je	.L25

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5
	movupd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movupd	 0 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9
	movupd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movupd	 2 * SIZE(AO2, LDA, 2), %xmm11

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	mulpd	%xmm13, %xmm9
	addpd	%xmm9, %xmm1
	movupd	 6 * SIZE(AO2), %xmm9
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm2
	mulpd	%xmm13, %xmm11
	addpd	%xmm11, %xmm3
	movapd	 6 * SIZE(BO), %xmm13

	movupd	 4 * SIZE(AO1), %xmm4
	movupd	 4 * SIZE(AO2), %xmm5
	movupd	 4 * SIZE(AO1, LDA, 2), %xmm6
	movupd	 4 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	movupd	 6 * SIZE(AO1), %xmm8
	movupd	 6 * SIZE(AO1, LDA, 2), %xmm10
	movupd	 6 * SIZE(AO2, LDA, 2), %xmm11

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

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5
	movupd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movupd	 0 * SIZE(AO2, LDA, 2), %xmm7

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	addpd	%xmm5, %xmm1
	mulpd	%xmm12, %xmm6
	addpd	%xmm6, %xmm2
	mulpd	%xmm12, %xmm7
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm7, %xmm3

	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9
	movupd	 2 * SIZE(AO1, LDA, 2), %xmm10
	movupd	 2 * SIZE(AO2, LDA, 2), %xmm11

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

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5

	movupd	 0 * SIZE(AO1, LDA, 2), %xmm6
	movupd	 0 * SIZE(AO2, LDA, 2), %xmm7

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

	movlpd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movlpd	0 * SIZE(AO2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm1

	movlpd	0 * SIZE(AO1, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm2

	movlpd	0 * SIZE(AO2, LDA, 2), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm3

.L29:
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

	movlpd	%xmm0, (CO)
	addq	INCY, CO
	movlpd	%xmm1, (CO)
	addq	INCY, CO
	movlpd	%xmm2, (CO)
	addq	INCY, CO
	movlpd	%xmm3, (CO)
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

	PREFETCHW	3 * SIZE(CO)

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L34

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5
	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9

	decq	I
	jle	.L33
	ALIGN_3

.L32:
	mulpd	%xmm12, %xmm4
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	 4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movupd	 6 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	PREFETCH	PREFETCHSIZE * SIZE(AO2)
	addpd	%xmm4, %xmm0
	movupd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	 8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movupd	10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movupd	14 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)
	addpd	%xmm4, %xmm0
	movupd	16 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	16 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm0
	movupd	18 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm1
	movupd	18 * SIZE(AO2), %xmm9

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L32
	ALIGN_3

.L33:
	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	 4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movupd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movupd	 6 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	 8 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	 8 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movupd	10 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movupd	10 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	12 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movupd	14 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movupd	14 * SIZE(AO2), %xmm9

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

.L34:
	movq	MIN_M, I
	andq	$8,  I
	je	.L35

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5
	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1
	movupd	 4 * SIZE(AO2), %xmm5

	mulpd	%xmm13, %xmm8
	addpd	%xmm8, %xmm2
	movupd	 6 * SIZE(AO1), %xmm8
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm9, %xmm3
	movupd	 6 * SIZE(AO2), %xmm9

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

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5

	mulpd	%xmm12, %xmm4
	addpd	%xmm4, %xmm0
	mulpd	%xmm12, %xmm5
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm5, %xmm1

	movupd	 2 * SIZE(AO1), %xmm8
	movupd	 2 * SIZE(AO2), %xmm9

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

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 0 * SIZE(AO2), %xmm5

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

	movlpd	0 * SIZE(AO1), %xmm8
	mulsd	%xmm12, %xmm8
	addsd	%xmm8, %xmm0

	movlpd	0 * SIZE(AO2), %xmm8
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

	movlpd	%xmm0, (CO)
	addq	INCY, CO
	movlpd	%xmm1, (CO)
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

	movapd	 0 * SIZE(BO), %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO), %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	PREFETCHW	3 * SIZE(CO)

	movq	MIN_M, I
	sarq	$4,  I
	jle	.L44

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 2 * SIZE(AO1), %xmm8

	decq	I
	jle	.L43
	ALIGN_3

.L42:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movupd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	 8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movupd	10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movupd	14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	16 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm0
	movupd	18 * SIZE(AO1), %xmm8

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L42
	ALIGN_3

.L43:
	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movupd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	movupd	 8 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	movupd	10 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	12 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	12 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	14 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movupd	14 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	16 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	subq	$-16 * SIZE, AO1

	mulpd	%xmm13, %xmm8
	movapd	18 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-16 * SIZE, BO

.L44:
	movq	MIN_M, I
	andq	$8,  I
	je	.L45

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 2 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	movupd	 4 * SIZE(AO1), %xmm4

	mulpd	%xmm13, %xmm8
	movapd	 6 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm1
	movupd	 6 * SIZE(AO1), %xmm8

	mulpd	%xmm12, %xmm4
	movapd	 8 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm2
	subq	$-8 * SIZE, AO1

	mulpd	%xmm13, %xmm8
	movapd	10 * SIZE(BO), %xmm13
	addpd	%xmm8, %xmm3
	subq	$-8 * SIZE, BO

.L45:
	movq	MIN_M, I
	andq	$4,  I
	je	.L46

	movupd	 0 * SIZE(AO1), %xmm4
	movupd	 2 * SIZE(AO1), %xmm8
	subq	$-4 * SIZE, AO1

	mulpd	%xmm12, %xmm4
	movapd	 4 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	mulpd	%xmm13, %xmm8
	subq	$-4 * SIZE, BO
	addpd	%xmm8, %xmm1

.L46:
	movq	MIN_M, I
	andq	$2,  I
	je	.L47

	movupd	 0 * SIZE(AO1), %xmm4
	subq	$-2 * SIZE, AO1
	mulpd	%xmm12, %xmm4
	movapd	 2 * SIZE(BO), %xmm12
	addpd	%xmm4, %xmm0
	subq	$-2 * SIZE, BO

.L47:
	movq	MIN_M, I
	andq	$1,  I
	je	.L48

	movlpd	0 * SIZE(AO1), %xmm8
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
	movlpd	%xmm0, (CO)
	ALIGN_3

.L49:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L10
	ALIGN_3

.L999:
	movq	  0(%rsp), %rbx
	movq	  8(%rsp), %rbp
	movq	 16(%rsp), %r12
	movq	 24(%rsp), %r13
	movq	 32(%rsp), %r14
	movq	 40(%rsp), %r15

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

	addq	$STACKSIZE, %rsp
	ret
	ALIGN_3

	EPILOGUE
