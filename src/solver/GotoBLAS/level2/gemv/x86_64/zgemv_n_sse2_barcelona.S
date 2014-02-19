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
#define PREFETCHSIZE	 (8 * 3 + 4)
	
#ifndef WINDOWS_ABI

#define STACKSIZE	128
	
#define OLD_INCX	 8 + STACKSIZE(%rsp)
#define OLD_Y		16 + STACKSIZE(%rsp)
#define OLD_INCY	24 + STACKSIZE(%rsp)
#define BUFFER		32 + STACKSIZE(%rsp)
#define ALPHA_R		48(%rsp)
#define ALPHA_I		64(%rsp)
#define COMP_MASK	80(%rsp)
	
#define M	  %rdi
#define N	  %rsi
#define A	  %rcx
#define LDA	  %r8
#define X	  %r9
#define INCX	  %rdx
#define Y	  %rbp
#define INCY	  %r10

#else

#define STACKSIZE	320
	
#define OLD_ALPHA_I	 40 + STACKSIZE(%rsp)
#define OLD_A		 48 + STACKSIZE(%rsp)
#define OLD_LDA		 56 + STACKSIZE(%rsp)
#define OLD_X		 64 + STACKSIZE(%rsp)
#define OLD_INCX	 72 + STACKSIZE(%rsp)
#define OLD_Y		 80 + STACKSIZE(%rsp)
#define OLD_INCY	 88 + STACKSIZE(%rsp)
#define BUFFER		 96 + STACKSIZE(%rsp)
#define ALPHA_R		224(%rsp)
#define ALPHA_I		240(%rsp)
#define COMP_MASK	256(%rsp)

#define M	  %rcx
#define N	  %rdx
#define A	  %r8
#define LDA	  %r9
#define X	  %rdi
#define INCX	  %rsi
#define Y	  %rbp
#define INCY	  %r10

#endif

#define I     %rax
#define J     %r11
#define A1    %r12
#define A2    %r13
#define Y1    %r14
#define YY    %r15

#ifndef CONJ
#define ADD	addpd
#else
#define ADD	subpd
#endif

#ifndef XCONJ
#define ADDX	addpd
#else
#define ADDX	subpd
#endif

#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c)	movddup	a##b, c

#define	ALPHA	%xmm15

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

	movaps	%xmm3,       %xmm0
	movsd	OLD_ALPHA_I, %xmm1
#endif

	movq	OLD_INCX,  INCX
	movq	OLD_Y,     Y
	movq	OLD_INCY,  INCY

	testq	N, N
	jle	.L999
	testq	M, M
	jle	.L999

	salq	$ZBASE_SHIFT, INCX
	salq	$ZBASE_SHIFT, INCY
	salq	$ZBASE_SHIFT, LDA

	unpcklpd %xmm1, %xmm0
	unpcklpd %xmm0, %xmm1
	pcmpeqb	%xmm2,  %xmm2
	xorpd	%xmm3,  %xmm3
	psllq	$63,    %xmm2
	unpcklpd %xmm3, %xmm2
	xorpd	 %xmm2, %xmm1

	movlpd	%xmm0,  0 + ALPHA_R
	movhpd	%xmm0,  8 + ALPHA_R
	movlpd	%xmm1,  0 + ALPHA_I
	movhpd	%xmm1,  8 + ALPHA_I
	movlpd	%xmm2,  0 + COMP_MASK
	movhpd	%xmm2,  8 + COMP_MASK

	pxor	%xmm4, %xmm4
	movq	Y, YY
	cmpq	$SIZE * 2, INCY
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
	movapd	%xmm4, 8 * SIZE(Y1)
	movapd	%xmm4,10 * SIZE(Y1)
	movapd	%xmm4,12 * SIZE(Y1)
	movapd	%xmm4,14 * SIZE(Y1)
	addq	$16 * SIZE, Y1
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

	MOVDDUP(0 * SIZE, X, %xmm0)
	MOVDDUP(1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP(0 * SIZE, X, %xmm2)
	MOVDDUP(1 * SIZE, X, %xmm3)
	addq	INCX, X
	MOVDDUP(0 * SIZE, X, %xmm4)
	MOVDDUP(1 * SIZE, X, %xmm5)
	addq	INCX, X
	MOVDDUP(0 * SIZE, X, %xmm6)
	MOVDDUP(1 * SIZE, X, %xmm7)
	addq	INCX, X

	movupd	  0 + ALPHA_R,   %xmm13
	movupd	  0 + ALPHA_I,   %xmm14
	movupd	  0 + COMP_MASK, %xmm15

	mulpd	  %xmm13, %xmm0
	mulpd	  %xmm14, %xmm1
	mulpd	  %xmm13, %xmm2
	mulpd	  %xmm14, %xmm3
	mulpd	  %xmm13, %xmm4
	mulpd	  %xmm14, %xmm5
	mulpd	  %xmm13, %xmm6
	mulpd	  %xmm14, %xmm7

	ADDX	  %xmm1,  %xmm0
	ADDX	  %xmm3,  %xmm2
	ADDX	  %xmm5,  %xmm4
	ADDX	  %xmm7,  %xmm6

	movapd	  %xmm0, %xmm1
	movapd	  %xmm2, %xmm3
	movapd	  %xmm4, %xmm5
	movapd	  %xmm6, %xmm7

	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3
	SHUFPD_1 %xmm5, %xmm5
	SHUFPD_1 %xmm7, %xmm7

	xorpd	  %xmm15, %xmm1
	xorpd	  %xmm15, %xmm3
	xorpd	  %xmm15, %xmm5
	xorpd	  %xmm15, %xmm7

	movq	M,  I
	sarq	$3, I
	jle	.L16

	MOVDDUP( 0 * SIZE, A1, %xmm12)
	MOVDDUP( 2 * SIZE, A1, %xmm13)
	MOVDDUP( 4 * SIZE, A1, %xmm14)
	MOVDDUP( 6 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm8
	movupd	 2 * SIZE(Y1), %xmm9
	movupd	 4 * SIZE(Y1), %xmm10
	movupd	 6 * SIZE(Y1), %xmm11

	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm13
	mulpd	 %xmm0, %xmm14
	mulpd	 %xmm0, %xmm15

	decq	 I
	jle	 .L15
	ALIGN_3

.L14:
	PREFETCH	(PREFETCHSIZE +  0) * SIZE(A1)

	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A1, %xmm13)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A1, %xmm15)
	mulpd	 %xmm1, %xmm15

	PREFETCHW	(PREFETCHSIZE +  0) * SIZE(Y1)

	ADD	 %xmm12, %xmm8
	MOVDDUP( 0 * SIZE, A2, %xmm12)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP( 2 * SIZE, A2, %xmm13)
	mulpd	 %xmm2, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP( 4 * SIZE, A2, %xmm14)
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP( 6 * SIZE, A2, %xmm15)
	mulpd	 %xmm2, %xmm15

	PREFETCH	(PREFETCHSIZE +  0) * SIZE(A2)

	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A2, %xmm12)
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A2, %xmm13)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A2, %xmm14)
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A2, %xmm15)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm4, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm4, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm4, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm4, %xmm15

	PREFETCH	(PREFETCHSIZE +  0) * SIZE(A1, LDA, 2)

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm5, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm5, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm5, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm6, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm6, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm6, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm6, %xmm15

	PREFETCH	(PREFETCHSIZE +  0) * SIZE(A2, LDA, 2)

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm7, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm7, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm7, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP( 8 * SIZE, A1, %xmm12)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP(10 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP(12 * SIZE, A1, %xmm14)
	mulpd	 %xmm0, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP(14 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm15

	movlpd	 %xmm8,  0 * SIZE(Y1)
	movhpd	 %xmm8,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm8
	movlpd	 %xmm9,  2 * SIZE(Y1)
	movhpd	 %xmm9,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm9

	movlpd	 %xmm10, 4 * SIZE(Y1)
	movhpd	 %xmm10, 5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm10
	movlpd	 %xmm11, 6 * SIZE(Y1)
	movhpd	 %xmm11, 7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm11

	PREFETCH	(PREFETCHSIZE +  8) * SIZE(A1)

	addpd	 %xmm12, %xmm8
	MOVDDUP( 9 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP(11 * SIZE, A1, %xmm13)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP(13 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm1, %xmm15

	PREFETCHW	(PREFETCHSIZE +  8) * SIZE(Y1)

	ADD	 %xmm12, %xmm8
	MOVDDUP( 8 * SIZE, A2, %xmm12)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP(10 * SIZE, A2, %xmm13)
	mulpd	 %xmm2, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP(12 * SIZE, A2, %xmm14)
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP(14 * SIZE, A2, %xmm15)
	mulpd	 %xmm2, %xmm15

	PREFETCH	(PREFETCHSIZE +  8) * SIZE(A2)

	addpd	 %xmm12, %xmm8
	MOVDDUP( 9 * SIZE, A2, %xmm12)
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP(11 * SIZE, A2, %xmm13)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP(13 * SIZE, A2, %xmm14)
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP(15 * SIZE, A2, %xmm15)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 8 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm4, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2(10 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm4, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2(12 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm4, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2(14 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm4, %xmm15

	PREFETCH	(PREFETCHSIZE +  8) * SIZE(A1, LDA, 2)

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 9 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm5, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2(11 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm5, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2(13 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2(15 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm5, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 8 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm6, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2(10 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm6, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2(12 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm6, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2(14 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm6, %xmm15

	PREFETCH	(PREFETCHSIZE +  8) * SIZE(A2, LDA, 2)

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 9 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm7, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2(11 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm7, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2(13 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2(15 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm7, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP(16 * SIZE, A1, %xmm12)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP(18 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP(20 * SIZE, A1, %xmm14)
	mulpd	 %xmm0, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP(22 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm15

	movlpd	 %xmm8,   8 * SIZE(Y1)
	movhpd	 %xmm8,   9 * SIZE(Y1)
	movupd	16 * SIZE(Y1), %xmm8
	movlpd	 %xmm9,  10 * SIZE(Y1)
	movhpd	 %xmm9,  11 * SIZE(Y1)
	movupd	18 * SIZE(Y1), %xmm9

	movlpd	 %xmm10, 12 * SIZE(Y1)
	movhpd	 %xmm10, 13 * SIZE(Y1)
	movupd	20 * SIZE(Y1), %xmm10
	movlpd	 %xmm11, 14 * SIZE(Y1)
	movhpd	 %xmm11, 15 * SIZE(Y1)
	movupd	22 * SIZE(Y1), %xmm11

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L14
	ALIGN_3

.L15:
	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A1, %xmm13)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A1, %xmm15)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP( 0 * SIZE, A2, %xmm12)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP( 2 * SIZE, A2, %xmm13)
	mulpd	 %xmm2, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP( 4 * SIZE, A2, %xmm14)
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP( 6 * SIZE, A2, %xmm15)
	mulpd	 %xmm2, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A2, %xmm12)
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A2, %xmm13)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A2, %xmm14)
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A2, %xmm15)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm4, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm4, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm4, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm4, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm5, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm5, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm5, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm6, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm6, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm6, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm6, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm7, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm7, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm7, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP( 8 * SIZE, A1, %xmm12)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP(10 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP(12 * SIZE, A1, %xmm14)
	mulpd	 %xmm0, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP(14 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm15

	movlpd	 %xmm8,  0 * SIZE(Y1)
	movhpd	 %xmm8,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm8
	movlpd	 %xmm9,  2 * SIZE(Y1)
	movhpd	 %xmm9,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm9

	movlpd	 %xmm10, 4 * SIZE(Y1)
	movhpd	 %xmm10, 5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm10
	movlpd	 %xmm11, 6 * SIZE(Y1)
	movhpd	 %xmm11, 7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm11

	addpd	 %xmm12, %xmm8
	MOVDDUP( 9 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP(11 * SIZE, A1, %xmm13)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP(13 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP( 8 * SIZE, A2, %xmm12)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP(10 * SIZE, A2, %xmm13)
	mulpd	 %xmm2, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP(12 * SIZE, A2, %xmm14)
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP(14 * SIZE, A2, %xmm15)
	mulpd	 %xmm2, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP( 9 * SIZE, A2, %xmm12)
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP(11 * SIZE, A2, %xmm13)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP(13 * SIZE, A2, %xmm14)
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP(15 * SIZE, A2, %xmm15)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 8 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm4, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2(10 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm4, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2(12 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm4, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2(14 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm4, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 9 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm5, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2(11 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm5, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2(13 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2(15 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm5, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 8 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm6, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2(10 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm6, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2(12 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm6, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2(14 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm6, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 9 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm7, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2(11 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm7, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2(13 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2(15 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm7, %xmm15

	ADD	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm9
	ADD	 %xmm14, %xmm10
	ADD	 %xmm15, %xmm11

	movlpd	 %xmm8,   8 * SIZE(Y1)
	movhpd	 %xmm8,   9 * SIZE(Y1)
	movlpd	 %xmm9,  10 * SIZE(Y1)
	movhpd	 %xmm9,  11 * SIZE(Y1)
	movlpd	 %xmm10, 12 * SIZE(Y1)
	movhpd	 %xmm10, 13 * SIZE(Y1)
	movlpd	 %xmm11, 14 * SIZE(Y1)
	movhpd	 %xmm11, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, A2
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L16:
	testq	$4, M
	je	.L17

	MOVDDUP( 0 * SIZE, A1, %xmm12)
	MOVDDUP( 2 * SIZE, A1, %xmm13)
	MOVDDUP( 4 * SIZE, A1, %xmm14)
	MOVDDUP( 6 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm8
	movupd	 2 * SIZE(Y1), %xmm9
	movupd	 4 * SIZE(Y1), %xmm10
	movupd	 6 * SIZE(Y1), %xmm11

	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm13
	mulpd	 %xmm0, %xmm14
	mulpd	 %xmm0, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A1, %xmm13)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A1, %xmm15)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP( 0 * SIZE, A2, %xmm12)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP( 2 * SIZE, A2, %xmm13)
	mulpd	 %xmm2, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP( 4 * SIZE, A2, %xmm14)
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP( 6 * SIZE, A2, %xmm15)
	mulpd	 %xmm2, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP( 1 * SIZE, A2, %xmm12)
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP( 3 * SIZE, A2, %xmm13)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP( 5 * SIZE, A2, %xmm14)
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP( 7 * SIZE, A2, %xmm15)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm4, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm4, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm4, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm4, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A1, LDA, 2), %xmm12)
	mulpd	 %xmm5, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A1, LDA, 2), %xmm13)
	mulpd	 %xmm5, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A1, LDA, 2), %xmm14)
	mulpd	 %xmm5, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A1, LDA, 2), %xmm15)
	mulpd	 %xmm5, %xmm15

	ADD	 %xmm12, %xmm8
	MOVDDUP2( 0 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm6, %xmm12
	ADD	 %xmm13, %xmm9
	MOVDDUP2( 2 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm6, %xmm13
	ADD	 %xmm14, %xmm10
	MOVDDUP2( 4 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm6, %xmm14
	ADD	 %xmm15, %xmm11
	MOVDDUP2( 6 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm6, %xmm15

	addpd	 %xmm12, %xmm8
	MOVDDUP2( 1 * SIZE, (A2, LDA, 2), %xmm12)
	mulpd	 %xmm7, %xmm12
	addpd	 %xmm13, %xmm9
	MOVDDUP2( 3 * SIZE, (A2, LDA, 2), %xmm13)
	mulpd	 %xmm7, %xmm13
	addpd	 %xmm14, %xmm10
	MOVDDUP2( 5 * SIZE, (A2, LDA, 2), %xmm14)
	mulpd	 %xmm7, %xmm14
	addpd	 %xmm15, %xmm11
	MOVDDUP2( 7 * SIZE, (A2, LDA, 2), %xmm15)
	mulpd	 %xmm7, %xmm15

	ADD	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm9
	ADD	 %xmm14, %xmm10
	ADD	 %xmm15, %xmm11

	movlpd	 %xmm8,   0 * SIZE(Y1)
	movhpd	 %xmm8,   1 * SIZE(Y1)
	movlpd	 %xmm9,   2 * SIZE(Y1)
	movhpd	 %xmm9,   3 * SIZE(Y1)
	movlpd	 %xmm10,  4 * SIZE(Y1)
	movhpd	 %xmm10,  5 * SIZE(Y1)
	movlpd	 %xmm11,  6 * SIZE(Y1)
	movhpd	 %xmm11,  7 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L17:
	testq	$2, M
	je	.L18

	movupd	 0 * SIZE(Y1), %xmm8
	movupd	 2 * SIZE(Y1), %xmm9

	MOVDDUP( 0 * SIZE, A1, %xmm12)
	MOVDDUP( 1 * SIZE, A1, %xmm13)
	MOVDDUP( 2 * SIZE, A1, %xmm14)
	MOVDDUP( 3 * SIZE, A1, %xmm15)

	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm1, %xmm13
	mulpd	 %xmm0, %xmm14
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm9
	ADD	 %xmm15, %xmm9

	MOVDDUP( 0 * SIZE, A2, %xmm12)
	MOVDDUP( 1 * SIZE, A2, %xmm13)
	MOVDDUP( 2 * SIZE, A2, %xmm14)
	MOVDDUP( 3 * SIZE, A2, %xmm15)

	mulpd	 %xmm2, %xmm12
	mulpd	 %xmm3, %xmm13
	mulpd	 %xmm2, %xmm14
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm9
	ADD	 %xmm15, %xmm9

	MOVDDUP2( 0 * SIZE, (A1, LDA, 2), %xmm12)
	MOVDDUP2( 1 * SIZE, (A1, LDA, 2), %xmm13)
	MOVDDUP2( 2 * SIZE, (A1, LDA, 2), %xmm14)
	MOVDDUP2( 3 * SIZE, (A1, LDA, 2), %xmm15)

	mulpd	 %xmm4, %xmm12
	mulpd	 %xmm5, %xmm13
	mulpd	 %xmm4, %xmm14
	mulpd	 %xmm5, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm9
	ADD	 %xmm15, %xmm9

	MOVDDUP2( 0 * SIZE, (A2, LDA, 2), %xmm12)
	MOVDDUP2( 1 * SIZE, (A2, LDA, 2), %xmm13)
	MOVDDUP2( 2 * SIZE, (A2, LDA, 2), %xmm14)
	MOVDDUP2( 3 * SIZE, (A2, LDA, 2), %xmm15)

	mulpd	 %xmm6, %xmm12
	mulpd	 %xmm7, %xmm13
	mulpd	 %xmm6, %xmm14
	mulpd	 %xmm7, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm9
	ADD	 %xmm15, %xmm9

	movlpd	 %xmm8,  0 * SIZE(Y1)
	movhpd	 %xmm8,  1 * SIZE(Y1)
	movlpd	 %xmm9,  2 * SIZE(Y1)
	movhpd	 %xmm9,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L18:
	testq	$1, M
	je	.L19

	movupd	 0 * SIZE(Y1), %xmm8

	MOVDDUP( 0 * SIZE, A1, %xmm12)
	MOVDDUP( 1 * SIZE, A1, %xmm13)
	MOVDDUP( 0 * SIZE, A2, %xmm14)
	MOVDDUP( 1 * SIZE, A2, %xmm15)

	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm1, %xmm13
	mulpd	 %xmm2, %xmm14
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm8
	ADD	 %xmm15, %xmm8

	MOVDDUP2( 0 * SIZE, (A1, LDA, 2), %xmm12)
	MOVDDUP2( 1 * SIZE, (A1, LDA, 2), %xmm13)
	MOVDDUP2( 0 * SIZE, (A2, LDA, 2), %xmm14)
	MOVDDUP2( 1 * SIZE, (A2, LDA, 2), %xmm15)

	mulpd	 %xmm4, %xmm12
	mulpd	 %xmm5, %xmm13
	mulpd	 %xmm6, %xmm14
	mulpd	 %xmm7, %xmm15

	addpd	 %xmm12, %xmm8
	ADD	 %xmm13, %xmm8
	addpd	 %xmm14, %xmm8
	ADD	 %xmm15, %xmm8

	movlpd	 %xmm8,  0 * SIZE(Y1)
	movhpd	 %xmm8,  1 * SIZE(Y1)
	ALIGN_3

.L19:
	decq	J
	jg	.L11
	ALIGN_3

.L20:
	testq	$2,  N
	je	.L30

	movq	YY, Y1
	movq	A,  A1
	leaq	(A, LDA, 2), A

	MOVDDUP(0 * SIZE, X, %xmm0)
	MOVDDUP(1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP(0 * SIZE, X, %xmm2)
	MOVDDUP(1 * SIZE, X, %xmm3)
	addq	INCX, X

	movupd	  0 + ALPHA_R,   %xmm13
	movupd	  0 + ALPHA_I,   %xmm14
	movupd	  0 + COMP_MASK, %xmm15

	mulpd	  %xmm13, %xmm0
	mulpd	  %xmm14, %xmm1
	mulpd	  %xmm13, %xmm2
	mulpd	  %xmm14, %xmm3
	ADDX	  %xmm1,  %xmm0
	ADDX	  %xmm3,  %xmm2
	movapd	  %xmm0, %xmm1
	movapd	  %xmm2, %xmm3
	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3
	xorpd	  %xmm15, %xmm1
	xorpd	  %xmm15, %xmm3

	movq	M,  I
	sarq	$3, I
	jle	.L26

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 4 * SIZE, A1, %xmm12)
	MOVDDUP( 6 * SIZE, A1, %xmm14)

	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 3 * SIZE, A1, %xmm11)
	MOVDDUP( 5 * SIZE, A1, %xmm13)
	MOVDDUP( 7 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5
	movupd	 4 * SIZE(Y1), %xmm6
	movupd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm14

	decq	 I
	jle	 .L25
	ALIGN_3

.L24:
	PREFETCH	PREFETCHSIZE * SIZE(A1)

	addpd	 %xmm8,  %xmm4
	MOVDDUP2( 0 * SIZE, (A1, LDA, 1), %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP2( 2 * SIZE, (A1, LDA, 1), %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP2( 4 * SIZE, (A1, LDA, 1), %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP2( 6 * SIZE, (A1, LDA, 1), %xmm14)
	mulpd	 %xmm1, %xmm15

	PREFETCHW	PREFETCHSIZE * SIZE(Y1)

	ADD	 %xmm9,  %xmm4
	MOVDDUP2( 1 * SIZE, (A1, LDA, 1), %xmm9)
	mulpd	 %xmm2, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP2( 3 * SIZE, (A1, LDA, 1), %xmm11)
	mulpd	 %xmm2, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP2( 5 * SIZE, (A1, LDA, 1), %xmm13)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP2( 7 * SIZE, (A1, LDA, 1), %xmm15)
	mulpd	 %xmm2, %xmm14

	PREFETCH	PREFETCHSIZE * SIZE(A1, LDA, 1)

	addpd	 %xmm8,  %xmm4
	MOVDDUP( 8 * SIZE, A1, %xmm8)
	mulpd	 %xmm3, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(10 * SIZE, A1, %xmm10)
	mulpd	 %xmm3, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(12 * SIZE, A1, %xmm12)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(14 * SIZE, A1, %xmm14)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP( 9 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(11 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10
	ADD	 %xmm13, %xmm6
	MOVDDUP(13 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm4
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm5

	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm6
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A1)

	addpd	 %xmm8,  %xmm4
	MOVDDUP2( 8 * SIZE, (A1, LDA, 1), %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP2(10 * SIZE, (A1, LDA, 1), %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP2(12 * SIZE, (A1, LDA, 1), %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP2(14 * SIZE, (A1, LDA, 1), %xmm14)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP2( 9 * SIZE, (A1, LDA, 1), %xmm9)
	mulpd	 %xmm2, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP2(11 * SIZE, (A1, LDA, 1), %xmm11)
	mulpd	 %xmm2, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP2(13 * SIZE, (A1, LDA, 1), %xmm13)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP2(15 * SIZE, (A1, LDA, 1), %xmm15)
	mulpd	 %xmm2, %xmm14

	addpd	 %xmm8,  %xmm4
	MOVDDUP(16 * SIZE, A1, %xmm8)
	mulpd	 %xmm3, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(18 * SIZE, A1, %xmm10)
	mulpd	 %xmm3, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(20 * SIZE, A1, %xmm12)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(22 * SIZE, A1, %xmm14)
	mulpd	 %xmm3, %xmm15

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A1, LDA, 1)

	ADD	 %xmm9,  %xmm4
	MOVDDUP(17 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(19 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP(21 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(23 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movupd	16 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movupd	18 * SIZE(Y1), %xmm5

	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movupd	20 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)
	movupd	22 * SIZE(Y1), %xmm7

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L24
	ALIGN_3

.L25:
	addpd	 %xmm8,  %xmm4
	MOVDDUP2( 0 * SIZE, (A1, LDA, 1), %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP2( 2 * SIZE, (A1, LDA, 1), %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP2( 4 * SIZE, (A1, LDA, 1), %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP2( 6 * SIZE, (A1, LDA, 1), %xmm14)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP2( 1 * SIZE, (A1, LDA, 1), %xmm9)
	mulpd	 %xmm2, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP2( 3 * SIZE, (A1, LDA, 1), %xmm11)
	mulpd	 %xmm2, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP2( 5 * SIZE, (A1, LDA, 1), %xmm13)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP2( 7 * SIZE, (A1, LDA, 1), %xmm15)
	mulpd	 %xmm2, %xmm14

	addpd	 %xmm8,  %xmm4
	MOVDDUP( 8 * SIZE, A1, %xmm8)
	mulpd	 %xmm3, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(10 * SIZE, A1, %xmm10)
	mulpd	 %xmm3, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(12 * SIZE, A1, %xmm12)
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(14 * SIZE, A1, %xmm14)
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP( 9 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(11 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10
	ADD	 %xmm13, %xmm6
	MOVDDUP(13 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm4
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm5

	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm6
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	MOVDDUP2( 8 * SIZE, (A1, LDA, 1), %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP2(10 * SIZE, (A1, LDA, 1), %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP2(12 * SIZE, (A1, LDA, 1), %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP2(14 * SIZE, (A1, LDA, 1), %xmm14)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP2( 9 * SIZE, (A1, LDA, 1), %xmm9)
	mulpd	 %xmm2, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP2(11 * SIZE, (A1, LDA, 1), %xmm11)
	mulpd	 %xmm2, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP2(13 * SIZE, (A1, LDA, 1), %xmm13)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP2(15 * SIZE, (A1, LDA, 1), %xmm15)
	mulpd	 %xmm2, %xmm14

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm3, %xmm9
	addpd	 %xmm10, %xmm5
	mulpd	 %xmm3, %xmm11

	addpd	 %xmm12, %xmm6
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm7
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm9,  %xmm4
	ADD	 %xmm11, %xmm5
	ADD	 %xmm13, %xmm6
	ADD	 %xmm15, %xmm7

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L26:
	testq	$4, M
	je	.L27

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 3 * SIZE, A1, %xmm11)
	MOVDDUP( 4 * SIZE, A1, %xmm12)
	MOVDDUP( 5 * SIZE, A1, %xmm13)
	MOVDDUP( 6 * SIZE, A1, %xmm14)
	MOVDDUP( 7 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5
	movupd	 4 * SIZE(Y1), %xmm6
	movupd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm14

	addpd	 %xmm8,  %xmm4
	MOVDDUP2( 0 * SIZE, (A1, LDA, 1), %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP2( 2 * SIZE, (A1, LDA, 1), %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP2( 4 * SIZE, (A1, LDA, 1), %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP2( 6 * SIZE, (A1, LDA, 1), %xmm14)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP2( 1 * SIZE, (A1, LDA, 1), %xmm9)
	mulpd	 %xmm2, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP2( 3 * SIZE, (A1, LDA, 1), %xmm11)
	mulpd	 %xmm2, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP2( 5 * SIZE, (A1, LDA, 1), %xmm13)
	mulpd	 %xmm2, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP2( 7 * SIZE, (A1, LDA, 1), %xmm15)
	mulpd	 %xmm2, %xmm14

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm3, %xmm9
	addpd	 %xmm10, %xmm5
	mulpd	 %xmm3, %xmm11

	addpd	 %xmm12, %xmm6
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm14, %xmm7
	mulpd	 %xmm3, %xmm15

	ADD	 %xmm9,  %xmm4
	ADD	 %xmm11, %xmm5
	ADD	 %xmm13, %xmm6
	ADD	 %xmm15, %xmm7

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

.L27:
	testq	$2, M
	je	.L28

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 3 * SIZE, A1, %xmm11)

	MOVDDUP2( 0 * SIZE, (A1, LDA, 1), %xmm12)
	MOVDDUP2( 1 * SIZE, (A1, LDA, 1), %xmm13)
	MOVDDUP2( 2 * SIZE, (A1, LDA, 1), %xmm14)
	MOVDDUP2( 3 * SIZE, (A1, LDA, 1), %xmm15)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm1, %xmm11

	mulpd	 %xmm2, %xmm12
	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm3, %xmm13
	addpd	 %xmm10, %xmm5
	mulpd	 %xmm2, %xmm14
	ADD	 %xmm9,  %xmm4
	mulpd	 %xmm3, %xmm15
	ADD	 %xmm11, %xmm5

	addpd	 %xmm12, %xmm4
	addpd	 %xmm14, %xmm5
	ADD	 %xmm13, %xmm4
	ADD	 %xmm15, %xmm5

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L28:
	testq	$1, M
	je	.L30

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP2( 0 * SIZE, (A1, LDA, 1), %xmm12)
	MOVDDUP2( 1 * SIZE, (A1, LDA, 1), %xmm13)

	movupd	 0 * SIZE(Y1), %xmm4

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm9
	mulpd	 %xmm2, %xmm12
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm8,  %xmm4
	ADD	 %xmm9,  %xmm4
	addpd	 %xmm12, %xmm4
	ADD	 %xmm13, %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	ALIGN_3

.L30:
	testq	$1, N
	je	.L995

	movq	YY, Y1
	movq	A,  A1

	MOVDDUP(0 * SIZE, X, %xmm0)
	MOVDDUP(1 * SIZE, X, %xmm1)
	addq	INCX, X

	movupd	  0 + ALPHA_R,   %xmm13
	movupd	  0 + ALPHA_I,   %xmm14
	movupd	  0 + COMP_MASK, %xmm15

	mulpd	  %xmm13, %xmm0
	mulpd	  %xmm14, %xmm1
	ADDX	  %xmm1,  %xmm0
	movapd	  %xmm0, %xmm1
	SHUFPD_1 %xmm1, %xmm1
	xorpd	  %xmm15, %xmm1

	movq	M,  I
	sarq	$3, I
	jle	.L36

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 4 * SIZE, A1, %xmm12)
	MOVDDUP( 6 * SIZE, A1, %xmm14)

	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 3 * SIZE, A1, %xmm11)
	MOVDDUP( 5 * SIZE, A1, %xmm13)
	MOVDDUP( 7 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5
	movupd	 4 * SIZE(Y1), %xmm6
	movupd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm14

	decq	 I
	jle	 .L35
	ALIGN_3

.L34:
	PREFETCH	PREFETCHSIZE * SIZE(A1)

	addpd	 %xmm8,  %xmm4
	MOVDDUP( 8 * SIZE, A1, %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(10 * SIZE, A1, %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(12 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(14 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm15

	PREFETCHW	PREFETCHSIZE * SIZE(Y1)

	ADD	 %xmm9,  %xmm4
	MOVDDUP( 9 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(11 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP(13 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm4
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm5
	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm6
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(A1)

	addpd	 %xmm8,  %xmm4
	MOVDDUP(16 * SIZE, A1, %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(18 * SIZE, A1, %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(20 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(22 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm15

	PREFETCHW	(PREFETCHSIZE + 8) * SIZE(Y1)

	ADD	 %xmm9,  %xmm4
	MOVDDUP(17 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(19 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10
	ADD	 %xmm13, %xmm6
	MOVDDUP(21 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(23 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movupd	16 * SIZE(Y1), %xmm4
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movupd	18 * SIZE(Y1), %xmm5
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movupd	20 * SIZE(Y1), %xmm6
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)
	movupd	22 * SIZE(Y1), %xmm7

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, Y1
	decq	 I
	jg	.L34
	ALIGN_3

.L35:
	addpd	 %xmm8,  %xmm4
	MOVDDUP( 8 * SIZE, A1, %xmm8)
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	MOVDDUP(10 * SIZE, A1, %xmm10)
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	MOVDDUP(12 * SIZE, A1, %xmm12)
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	MOVDDUP(14 * SIZE, A1, %xmm14)
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	MOVDDUP( 9 * SIZE, A1, %xmm9)
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	MOVDDUP(11 * SIZE, A1, %xmm11)
	mulpd	 %xmm0, %xmm10

	ADD	 %xmm13, %xmm6
	MOVDDUP(13 * SIZE, A1, %xmm13)
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	MOVDDUP(15 * SIZE, A1, %xmm15)
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movupd	 8 * SIZE(Y1), %xmm4
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)
	movupd	10 * SIZE(Y1), %xmm5

	movlpd	 %xmm6,  4 * SIZE(Y1)
	movhpd	 %xmm6,  5 * SIZE(Y1)
	movupd	12 * SIZE(Y1), %xmm6
	movlpd	 %xmm7,  6 * SIZE(Y1)
	movhpd	 %xmm7,  7 * SIZE(Y1)
	movupd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	mulpd	 %xmm0, %xmm8
	ADD	 %xmm11, %xmm5
	mulpd	 %xmm0, %xmm10
	ADD	 %xmm13, %xmm6
	mulpd	 %xmm0, %xmm12
	ADD	 %xmm15, %xmm7
	mulpd	 %xmm0, %xmm14

	movlpd	 %xmm4,  8 * SIZE(Y1)
	movhpd	 %xmm4,  9 * SIZE(Y1)
	movlpd	 %xmm5, 10 * SIZE(Y1)
	movhpd	 %xmm5, 11 * SIZE(Y1)
	movlpd	 %xmm6, 12 * SIZE(Y1)
	movhpd	 %xmm6, 13 * SIZE(Y1)
	movlpd	 %xmm7, 14 * SIZE(Y1)
	movhpd	 %xmm7, 15 * SIZE(Y1)

	subq	$-16 * SIZE, A1
	subq	$-16 * SIZE, Y1
	ALIGN_3

.L36:
	testq	$4, M
	je	.L37

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 3 * SIZE, A1, %xmm11)
	MOVDDUP( 4 * SIZE, A1, %xmm12)
	MOVDDUP( 5 * SIZE, A1, %xmm13)
	MOVDDUP( 6 * SIZE, A1, %xmm14)
	MOVDDUP( 7 * SIZE, A1, %xmm15)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5
	movupd	 4 * SIZE(Y1), %xmm6
	movupd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm12
	mulpd	 %xmm0, %xmm14

	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm1, %xmm9
	addpd	 %xmm10, %xmm5
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm12, %xmm6
	mulpd	 %xmm1, %xmm13
	addpd	 %xmm14, %xmm7
	mulpd	 %xmm1, %xmm15

	ADD	 %xmm9,  %xmm4
	ADD	 %xmm11, %xmm5
	ADD	 %xmm13, %xmm6
	ADD	 %xmm15, %xmm7

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

.L37:
	testq	$2, M
	je	.L38

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)
	MOVDDUP( 2 * SIZE, A1, %xmm10)
	MOVDDUP( 3 * SIZE, A1, %xmm11)

	movupd	 0 * SIZE(Y1), %xmm4
	movupd	 2 * SIZE(Y1), %xmm5

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm10, %xmm5
	ADD	 %xmm9,  %xmm4
	ADD	 %xmm11, %xmm5

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	movlpd	 %xmm5,  2 * SIZE(Y1)
	movhpd	 %xmm5,  3 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L38:
	testq	$1, M
	je	.L995

	MOVDDUP( 0 * SIZE, A1, %xmm8)
	MOVDDUP( 1 * SIZE, A1, %xmm9)

	movupd	 0 * SIZE(Y1), %xmm4

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm9

	addpd	 %xmm8,  %xmm4
	ADD	 %xmm9,  %xmm4

	movlpd	 %xmm4,  0 * SIZE(Y1)
	movhpd	 %xmm4,  1 * SIZE(Y1)
	jmp	 .L995
	ALIGN_3


.L995:
	cmpq	$SIZE * 2, INCY
	je	.L999

	movq	Y,  Y1
	movq	M,  %rax
	sarq	$2, %rax
	jle	.L997
	ALIGN_3

.L996:
	movupd	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	movupd	0 * SIZE(Y), %xmm5
	addq	INCY, Y
	movupd	0 * SIZE(Y), %xmm6
	addq	INCY, Y
	movupd	0 * SIZE(Y), %xmm7
	addq	INCY, Y

	movupd	0 * SIZE(YY), %xmm0
	movupd	2 * SIZE(YY), %xmm1
	movupd	4 * SIZE(YY), %xmm2
	movupd	6 * SIZE(YY), %xmm3

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1
	addpd	%xmm6, %xmm2
	addpd	%xmm7, %xmm3

	movlpd	%xmm0, 0 * SIZE(Y1)
	movhpd	%xmm0, 1 * SIZE(Y1)
	addq	INCY, Y1
	movlpd	%xmm1, 0 * SIZE(Y1)
	movhpd	%xmm1, 1 * SIZE(Y1)
	addq	INCY, Y1
	movlpd	%xmm2, 0 * SIZE(Y1)
	movhpd	%xmm2, 1 * SIZE(Y1)
	addq	INCY, Y1
	movlpd	%xmm3, 0 * SIZE(Y1)
	movhpd	%xmm3, 1 * SIZE(Y1)
	addq	INCY, Y1

	addq	$8 * SIZE, YY
	decq	%rax
	jg	.L996
	ALIGN_3

.L997:
	movq	M,  %rax
	andq	$3, %rax
	jle	.L999
	ALIGN_3

.L998:
	movupd	0 * SIZE(YY), %xmm0
	movupd	0 * SIZE(Y),  %xmm4

	addpd	%xmm4, %xmm0

	movlpd	%xmm0, 0 * SIZE(Y1)
	movhpd	%xmm0, 1 * SIZE(Y1)

	addq	$2 * SIZE, YY
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
	ALIGN_3

	EPILOGUE
