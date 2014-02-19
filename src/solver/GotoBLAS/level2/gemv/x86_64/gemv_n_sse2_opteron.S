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
#define PREFETCHSIZE	16

#ifndef WINDOWS_ABI

#define STACKSIZE	64
	
#define OLD_INCX	 8 + STACKSIZE(%rsp)
#define OLD_Y		16 + STACKSIZE(%rsp)
#define OLD_INCY	24 + STACKSIZE(%rsp)
#define BUFFER		32 + STACKSIZE(%rsp)
#define STACK_ALPHA	48	      (%rsp)

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

#define STACK_ALPHA	224	       (%rsp)

#define M	  %rcx
#define N	  %rdx
#define A	  %r8
#define LDA	  %r9
#define X	  %rdi
#define INCX	  %rsi
#define Y	  %rbp
#define INCY	  %r10

#endif

#define TEMP	%rax
#define I	%rax
#define J	%r11
#define A1	%r12
#define A2	%r13
#define Y1	%r14
#define YY	%r15

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

#ifndef WINDOWS_ABI
	movsd	 %xmm0, STACK_ALPHA
#else
	movsd	 %xmm3, STACK_ALPHA
#endif

	leaq	(,INCX, SIZE), INCX
	leaq	(,INCY, SIZE), INCY
	leaq	(,LDA,  SIZE), LDA

	testq	N, N		# if n <= 0 goto END
	jle	.L999
	testq	M, M		# if n <= 0 goto END
	jle	.L999

	pxor	%xmm4, %xmm4
	movq	Y, YY
	cmpq	$SIZE, INCY
	je	.L10

	movq	BUFFER, YY
	movq	BUFFER, Y1
	movq	M,  %rax
	addq	$7, %rax
	sarq	$3, %rax
	ALIGN_3

.L01:
	movapd	%xmm4, 0 * SIZE(Y1)
	movapd	%xmm4, 2 * SIZE(Y1)
	movapd	%xmm4, 4 * SIZE(Y1)
	movapd	%xmm4, 6 * SIZE(Y1)
	addq	$8 * SIZE, Y1
	decq	%rax
	jg	.L01
	ALIGN_3
	
.L10:
	movq	N,  J
	sarq	$2, J
	jle	.L20
	ALIGN_3

.L11:
	movq	YY, Y1
	movq	A,  A1
	leaq	(A, LDA, 1), A2
	leaq	(A, LDA, 4), A

	movlpd	(X), %xmm0
	addq	INCX, X
	movlpd	(X), %xmm1
	addq	INCX, X
	movlpd	(X), %xmm2
	addq	INCX, X
	movlpd	(X), %xmm3
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm0
	mulsd	STACK_ALPHA, %xmm1
	mulsd	STACK_ALPHA, %xmm2
	mulsd	STACK_ALPHA, %xmm3

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1
	unpcklpd %xmm2, %xmm2
	unpcklpd %xmm3, %xmm3

	movq	M,  I
	sarq	$4, I
	jle	.L14

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 0 * SIZE(A2), %xmm12
	movhpd	 1 * SIZE(A2), %xmm12
	movlpd	 2 * SIZE(A2), %xmm13
	movhpd	 3 * SIZE(A2), %xmm13
	movlpd	 4 * SIZE(A2), %xmm14
	movhpd	 5 * SIZE(A2), %xmm14
	movlpd	 6 * SIZE(A2), %xmm15
	movhpd	 7 * SIZE(A2), %xmm15

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	decq	 I
	jle	 .L13
	ALIGN_3

.L12:
	PREFETCH	PREFETCHSIZE * SIZE(A1)
	addpd	 %xmm8,  %xmm4
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm8
	movhpd	 1 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	 2 * SIZE(A1, LDA, 2), %xmm9
	movhpd	 3 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	PREFETCHW	PREFETCHSIZE * SIZE(Y1)
	addpd	 %xmm10, %xmm6
	movlpd	 4 * SIZE(A1, LDA, 2), %xmm10
	movhpd	 5 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	 6 * SIZE(A1, LDA, 2), %xmm11
	movhpd	 7 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	PREFETCH	PREFETCHSIZE * SIZE(A2)
	addpd	 %xmm12, %xmm4
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 1 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	 2 * SIZE(A2, LDA, 2), %xmm13
	movhpd	 3 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	 4 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 5 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	 6 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 7 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	PREFETCH	PREFETCHSIZE * SIZE(A1, LDA, 2)
	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1), %xmm8
	movhpd	 9 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1), %xmm9
	movhpd	11 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1), %xmm10
	movhpd	13 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1), %xmm11
	movhpd	15 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	PREFETCH	PREFETCHSIZE * SIZE(A2, LDA, 2)
	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2), %xmm12
	movhpd	 9 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2), %xmm13
	movhpd	11 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2), %xmm14
	movhpd	13 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2), %xmm15
	movhpd	15 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A1)
	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1, LDA, 2), %xmm8
	movhpd	 9 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1, LDA, 2), %xmm9
	movhpd	11 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	PREFETCHW	(PREFETCHSIZE + 8) * SIZE(Y1)
	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1, LDA, 2), %xmm10
	movhpd	13 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1, LDA, 2), %xmm11
	movhpd	15 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A2)
	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 9 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2, LDA, 2), %xmm13
	movhpd	11 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2, LDA, 2), %xmm14
	movhpd	13 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2, LDA, 2), %xmm15
	movhpd	15 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A1, LDA, 2)
	addpd	 %xmm8,  %xmm4
	movlpd	16 * SIZE(A1), %xmm8
	movhpd	17 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	18 * SIZE(A1), %xmm9
	movhpd	19 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	20 * SIZE(A1), %xmm10
	movhpd	21 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	22 * SIZE(A1), %xmm11
	movhpd	23 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A2, LDA, 2)
	addpd	 %xmm12, %xmm4
	movlpd	16 * SIZE(A2), %xmm12
	movhpd	17 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	18 * SIZE(A2), %xmm13
	movhpd	19 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	20 * SIZE(A2), %xmm14
	movhpd	21 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	22 * SIZE(A2), %xmm15
	movhpd	23 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movlpd	16 * SIZE(Y1), %xmm4
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movhpd	17 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movlpd	18 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movhpd	19 * SIZE(Y1), %xmm5
	movlpd	 %xmm6, 12 * SIZE(Y1)

	movlpd	20 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movhpd	21 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movlpd	22 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 15 * SIZE(Y1)
	movhpd	23 * SIZE(Y1), %xmm7

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L12
	ALIGN_3

.L13:
	addpd	 %xmm8,  %xmm4
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm8
	movhpd	 1 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	 2 * SIZE(A1, LDA, 2), %xmm9
	movhpd	 3 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	 4 * SIZE(A1, LDA, 2), %xmm10
	movhpd	 5 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	 6 * SIZE(A1, LDA, 2), %xmm11
	movhpd	 7 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 1 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	 2 * SIZE(A2, LDA, 2), %xmm13
	movhpd	 3 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	 4 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 5 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	 6 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 7 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1), %xmm8
	movhpd	 9 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1), %xmm9
	movhpd	11 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1), %xmm10
	movhpd	13 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1), %xmm11
	movhpd	15 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2), %xmm12
	movhpd	 9 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2), %xmm13
	movhpd	11 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2), %xmm14
	movhpd	13 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2), %xmm15
	movhpd	15 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1, LDA, 2), %xmm8
	movhpd	 9 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1, LDA, 2), %xmm9
	movhpd	11 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1, LDA, 2), %xmm10
	movhpd	13 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1, LDA, 2), %xmm11
	movhpd	15 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 9 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2, LDA, 2), %xmm13
	movhpd	11 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2, LDA, 2), %xmm14
	movhpd	13 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2, LDA, 2), %xmm15
	movhpd	15 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm6
	addpd	 %xmm15, %xmm7

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L14:
	testq	$8, M
	je	.L15

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 0 * SIZE(A2), %xmm12
	movhpd	 1 * SIZE(A2), %xmm12
	movlpd	 2 * SIZE(A2), %xmm13
	movhpd	 3 * SIZE(A2), %xmm13
	movlpd	 4 * SIZE(A2), %xmm14
	movhpd	 5 * SIZE(A2), %xmm14
	movlpd	 6 * SIZE(A2), %xmm15
	movhpd	 7 * SIZE(A2), %xmm15

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	addpd	 %xmm8,  %xmm4
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm8
	movhpd	 1 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	 2 * SIZE(A1, LDA, 2), %xmm9
	movhpd	 3 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	 4 * SIZE(A1, LDA, 2), %xmm10
	movhpd	 5 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	 6 * SIZE(A1, LDA, 2), %xmm11
	movhpd	 7 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 1 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	 2 * SIZE(A2, LDA, 2), %xmm13
	movhpd	 3 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	 4 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 5 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	 6 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 7 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L15:
	testq	$4, M
	je	.L16

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 0 * SIZE(A2), %xmm10
	movhpd	 1 * SIZE(A2), %xmm10
	movlpd	 2 * SIZE(A2), %xmm11
	movhpd	 3 * SIZE(A2), %xmm11
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm12
	movhpd	 1 * SIZE(A1, LDA, 2), %xmm12
	movlpd	 2 * SIZE(A1, LDA, 2), %xmm13
	movhpd	 3 * SIZE(A1, LDA, 2), %xmm13
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 1 * SIZE(A2, LDA, 2), %xmm14
	movlpd	 2 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 3 * SIZE(A2, LDA, 2), %xmm15

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm1, %xmm10
	mulpd	 %xmm1, %xmm11
	mulpd	 %xmm2, %xmm12
	mulpd	 %xmm2, %xmm13
	mulpd	 %xmm3, %xmm14
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm4
	addpd	 %xmm11, %xmm5
	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm4
	addpd	 %xmm15, %xmm5

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L16:
	testq	$2, M
	je	.L17

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 0 * SIZE(A2), %xmm10
	movhpd	 1 * SIZE(A2), %xmm10
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm12
	movhpd	 1 * SIZE(A1, LDA, 2), %xmm12
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 1 * SIZE(A2, LDA, 2), %xmm14

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm10
	mulpd	 %xmm2, %xmm12
	mulpd	 %xmm3, %xmm14

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm10, %xmm4
	addpd	 %xmm12, %xmm4
	addpd	 %xmm14, %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L17:
	testq	$1, M
	je	.L19

	movlpd	 0 * SIZE(Y1), %xmm4

	movlpd	 0 * SIZE(A1), %xmm8
	movlpd	 0 * SIZE(A2), %xmm9
	movlpd	 0 * SIZE(A1, LDA, 2), %xmm10
	movlpd	 0 * SIZE(A2, LDA, 2), %xmm11

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9
	mulsd	 %xmm2, %xmm10
	mulsd	 %xmm3, %xmm11

	addsd	 %xmm8,  %xmm4
	addsd	 %xmm9,  %xmm4
	addsd	 %xmm10, %xmm4
	addsd	 %xmm11, %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L19:
	decq	J
	jg	.L11
	ALIGN_3

.L20:
	testq	$2, N
	je	.L30

	movq	YY, Y1
	movq	A,  A1
	leaq	(A, LDA, 1), A2
	leaq	(A, LDA, 2), A

	movlpd	(X), %xmm0
	addq	INCX, X
	movlpd	(X), %xmm1
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm0
	mulsd	STACK_ALPHA, %xmm1

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1

	movq	M,  I
	sarq	$4, I
	jle	.L25

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 0 * SIZE(A2), %xmm12
	movhpd	 1 * SIZE(A2), %xmm12
	movlpd	 2 * SIZE(A2), %xmm13
	movhpd	 3 * SIZE(A2), %xmm13
	movlpd	 4 * SIZE(A2), %xmm14
	movhpd	 5 * SIZE(A2), %xmm14
	movlpd	 6 * SIZE(A2), %xmm15
	movhpd	 7 * SIZE(A2), %xmm15

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	decq	 I
	jle	 .L22
	ALIGN_3

.L21:
	PREFETCH	PREFETCHSIZE * SIZE(A1)
	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1), %xmm8
	movhpd	 9 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1), %xmm9
	movhpd	11 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1), %xmm10
	movhpd	13 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1), %xmm11
	movhpd	15 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	PREFETCH	PREFETCHSIZE * SIZE(Y1)
	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2), %xmm12
	movhpd	 9 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2), %xmm13
	movhpd	11 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2), %xmm14
	movhpd	13 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2), %xmm15
	movhpd	15 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	PREFETCH	PREFETCHSIZE * SIZE(A2)
	addpd	 %xmm8,  %xmm4
	movlpd	16 * SIZE(A1), %xmm8
	movhpd	17 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	18 * SIZE(A1), %xmm9
	movhpd	19 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	20 * SIZE(A1), %xmm10
	movhpd	21 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	22 * SIZE(A1), %xmm11
	movhpd	23 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 16 * SIZE(A2), %xmm12
	movhpd	 17 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	 18 * SIZE(A2), %xmm13
	movhpd	 19 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	 20 * SIZE(A2), %xmm14
	movhpd	 21 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	 22 * SIZE(A2), %xmm15
	movhpd	 23 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movlpd	16 * SIZE(Y1), %xmm4
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movhpd	17 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movlpd	18 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movhpd	19 * SIZE(Y1), %xmm5
	movlpd	 %xmm6, 12 * SIZE(Y1)

	movlpd	20 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movhpd	21 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movlpd	22 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 15 * SIZE(Y1)
	movhpd	23 * SIZE(Y1), %xmm7

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L21
	ALIGN_3

.L22:
	addpd	 %xmm8,  %xmm4
	movlpd	 8 * SIZE(A1), %xmm8
	movhpd	 9 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	10 * SIZE(A1), %xmm9
	movhpd	11 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	12 * SIZE(A1), %xmm10
	movhpd	13 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	14 * SIZE(A1), %xmm11
	movhpd	15 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movlpd	 8 * SIZE(A2), %xmm12
	movhpd	 9 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	10 * SIZE(A2), %xmm13
	movhpd	11 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	12 * SIZE(A2), %xmm14
	movhpd	13 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	14 * SIZE(A2), %xmm15
	movhpd	15 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm6
	addpd	 %xmm15, %xmm7

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L25:
	testq	$8, M
	je	.L26

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 0 * SIZE(A2), %xmm12
	movhpd	 1 * SIZE(A2), %xmm12
	movlpd	 2 * SIZE(A2), %xmm13
	movhpd	 3 * SIZE(A2), %xmm13
	movlpd	 4 * SIZE(A2), %xmm14
	movhpd	 5 * SIZE(A2), %xmm14
	movlpd	 6 * SIZE(A2), %xmm15
	movhpd	 7 * SIZE(A2), %xmm15

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm6
	addpd	 %xmm15, %xmm7

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L26:
	testq	$4, M
	je	.L27

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9

	movlpd	 0 * SIZE(A2), %xmm10
	movhpd	 1 * SIZE(A2), %xmm10
	movlpd	 2 * SIZE(A2), %xmm11
	movhpd	 3 * SIZE(A2), %xmm11

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm1, %xmm10
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm4
	addpd	 %xmm11, %xmm5

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L27:
	testq	$2, M
	je	.L28

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 0 * SIZE(A2), %xmm10
	movhpd	 1 * SIZE(A2), %xmm10

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm10

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm10, %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L28:
	testq	$1, M
	je	.L30

	movlpd	 0 * SIZE(A1), %xmm8
	movlpd	 0 * SIZE(A2), %xmm9
	movlpd	 0 * SIZE(Y1), %xmm4

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9

	addsd	 %xmm8,  %xmm4
	addsd	 %xmm9,  %xmm4

	movlpd	 %xmm4, 0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L30:
	testq	$1, N
	je	.L995

	movq	YY, Y1
	movq	A,  A1

	movlpd	(X), %xmm0
	mulsd	STACK_ALPHA, %xmm0
	unpcklpd %xmm0, %xmm0

	movq	M,  I
	sarq	$4, I
	jle	.L35

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 8 * SIZE(A1), %xmm12
	movhpd	 9 * SIZE(A1), %xmm12
	movlpd	10 * SIZE(A1), %xmm13
	movhpd	11 * SIZE(A1), %xmm13
	movlpd	12 * SIZE(A1), %xmm14
	movhpd	13 * SIZE(A1), %xmm14
	movlpd	14 * SIZE(A1), %xmm15
	movhpd	15 * SIZE(A1), %xmm15

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	decq	 I
	jle	 .L32
	ALIGN_3

.L31:
	PREFETCH	PREFETCHSIZE * SIZE(A1)
	addpd	 %xmm8,  %xmm4
	movlpd	16 * SIZE(A1), %xmm8
	movhpd	17 * SIZE(A1), %xmm8
	mulpd	 %xmm0, %xmm12
	addpd	 %xmm9,  %xmm5
	movlpd	18 * SIZE(A1), %xmm9
	movhpd	19 * SIZE(A1), %xmm9
	mulpd	 %xmm0, %xmm13

	addpd	 %xmm10, %xmm6
	movlpd	20 * SIZE(A1), %xmm10
	movhpd	21 * SIZE(A1), %xmm10
	mulpd	 %xmm0, %xmm14
	addpd	 %xmm11, %xmm7
	movlpd	22 * SIZE(A1), %xmm11
	movhpd	23 * SIZE(A1), %xmm11
	mulpd	 %xmm0, %xmm15

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	PREFETCH	PREFETCHSIZE * SIZE(Y1)
	addpd	 %xmm12, %xmm4
	movlpd	24 * SIZE(A1), %xmm12
	movhpd	25 * SIZE(A1), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movlpd	26 * SIZE(A1), %xmm13
	movhpd	27 * SIZE(A1), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movlpd	28 * SIZE(A1), %xmm14
	movhpd	29 * SIZE(A1), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movlpd	30 * SIZE(A1), %xmm15
	movhpd	31 * SIZE(A1), %xmm15
	mulpd	 %xmm0, %xmm11

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movlpd	16 * SIZE(Y1), %xmm4
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movhpd	17 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movlpd	18 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movhpd	19 * SIZE(Y1), %xmm5
	movlpd	 %xmm6, 12 * SIZE(Y1)

	movlpd	20 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movhpd	21 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movlpd	22 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 15 * SIZE(Y1)
	movhpd	23 * SIZE(Y1), %xmm7

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L31
	ALIGN_3

.L32:
	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm0, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm0, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm0, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm0, %xmm15

	movlpd	 %xmm4, 0 * SIZE(Y1)
	movlpd	 8 * SIZE(Y1), %xmm4
	movhpd	 %xmm4, 1 * SIZE(Y1)
	movhpd	 9 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 2 * SIZE(Y1)
	movlpd	10 * SIZE(Y1), %xmm5
	movhpd	 %xmm5, 3 * SIZE(Y1)
	movhpd	11 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 4 * SIZE(Y1)
	movlpd	12 * SIZE(Y1), %xmm6
	movhpd	 %xmm6, 5 * SIZE(Y1)
 	movhpd	13 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 6 * SIZE(Y1)
	movlpd	14 * SIZE(Y1), %xmm7
	movhpd	 %xmm7, 7 * SIZE(Y1)
	movhpd	15 * SIZE(Y1), %xmm7

	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm6
	addpd	 %xmm15, %xmm7

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L35:
	testq	$8, M
	je	.L36

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9
	movlpd	 4 * SIZE(A1), %xmm10
	movhpd	 5 * SIZE(A1), %xmm10
	movlpd	 6 * SIZE(A1), %xmm11
	movhpd	 7 * SIZE(A1), %xmm11

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5
	movlpd	 4 * SIZE(Y1), %xmm6
	movhpd	 5 * SIZE(Y1), %xmm6
	movlpd	 6 * SIZE(Y1), %xmm7
	movhpd	 7 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L36:
	testq	$4, M
	je	.L37

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8
	movlpd	 2 * SIZE(A1), %xmm9
	movhpd	 3 * SIZE(A1), %xmm9

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4
	movlpd	 2 * SIZE(Y1), %xmm5
	movhpd	 3 * SIZE(Y1), %xmm5

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L37:
	testq	$2, M
	je	.L38

	movlpd	 0 * SIZE(A1), %xmm8
	movhpd	 1 * SIZE(A1), %xmm8

	movlpd	 0 * SIZE(Y1), %xmm4
	movhpd	 1 * SIZE(Y1), %xmm4

	mulpd	 %xmm0, %xmm8
	addpd	 %xmm8,  %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L38:
	testq	$1, M
	je	.L995

	movlpd	 0 * SIZE(A1), %xmm8
	movlpd	 0 * SIZE(Y1), %xmm4
	mulsd	 %xmm0, %xmm8
	addsd	 %xmm8,  %xmm4
	movlpd	 %xmm4, 0 * SIZE(Y1)
	ALIGN_3

.L995:
	cmpq	$SIZE, INCY
	je	.L999

	movq	Y,  Y1
	movq	M,  %rax
	sarq	$2, %rax
	jle	.L997
	ALIGN_3

.L996:
	movlpd	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	movhpd	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	movlpd	0 * SIZE(Y), %xmm5
	addq	INCY, Y
	movhpd	0 * SIZE(Y), %xmm5
	addq	INCY, Y

	movapd	0 * SIZE(YY), %xmm0
	movapd	2 * SIZE(YY), %xmm1

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1

	movlpd	%xmm0, 0 * SIZE(Y1)
	addq	INCY, Y1
	movhpd	%xmm0, 0 * SIZE(Y1)
	addq	INCY, Y1
	movlpd	%xmm1, 0 * SIZE(Y1)
	addq	INCY, Y1
	movhpd	%xmm1, 0 * SIZE(Y1)
	addq	INCY, Y1

	addq	$4 * SIZE, YY
	decq	%rax
	jg	.L996
	ALIGN_3

.L997:
	movq	M,  %rax
	andq	$3, %rax
	jle	.L999
	ALIGN_3

.L998:
	movlpd	0 * SIZE(YY), %xmm0
	addsd	0 * SIZE(Y), %xmm0
	movlpd	%xmm0, 0 * SIZE(Y1)

	addq	$SIZE, YY
	addq	INCY, Y
	addq	INCY, Y1
	decq	%rax
	jg	.L998
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
	EPILOGUE
