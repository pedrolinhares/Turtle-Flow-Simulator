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
#define P 4096

#ifndef WINDOWS_ABI

#define STACKSIZE	64

#define OLD_INCX	 8 + STACKSIZE(%rsp)
#define OLD_Y		16 + STACKSIZE(%rsp)
#define OLD_INCY	24 + STACKSIZE(%rsp)
#define BUFFER		32 + STACKSIZE(%rsp)
#define NLDA	        48            (%rsp)
#define J	        56            (%rsp)

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
	
#define OLD_ALPHA_I	 40 + STACKSIZE(%rsp)
#define OLD_A		 48 + STACKSIZE(%rsp)
#define OLD_LDA		 56 + STACKSIZE(%rsp)
#define OLD_X		 64 + STACKSIZE(%rsp)
#define OLD_INCX	 72 + STACKSIZE(%rsp)
#define OLD_Y		 80 + STACKSIZE(%rsp)
#define OLD_INCY	 88 + STACKSIZE(%rsp)
#define BUFFER		 96 + STACKSIZE(%rsp)
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
#define MIN_N %rbx
#define IS    %r11
#define AO1   %r12
#define AO2   %r13
#define BO    %r14
#define CO    %r15

#ifndef CONJ
#define ADD	addpd
#else
#define ADD	subpd
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

	movapd	%xmm0,  ALPHA
	unpcklpd %xmm1, ALPHA

	salq	$ZBASE_SHIFT,   INCX
	salq	$ZBASE_SHIFT,   INCY

	mov     N,   TEMP
	imulq	LDA, TEMP
	movq	$P,   BO
	subq	TEMP, BO

	salq	$ZBASE_SHIFT, BO
	salq	$ZBASE_SHIFT, LDA
	movq	BO, NLDA
	xorq	IS, IS

	testq	N, N
	jle	.L999
	testq	M, M
	jle	.L999
	ALIGN_3

.L10:
	movq	M,    MIN_N
	movq	$P,   TEMP
	subq	IS,   MIN_N
	cmpq	TEMP, MIN_N
	cmovg	TEMP, MIN_N

	movq	BUFFER, BO

#ifdef XCONJ
	pcmpeqb	%xmm12, %xmm12
	xorpd	%xmm13, %xmm13
	psllq	$63,    %xmm12
	unpckhpd %xmm12, %xmm13
#endif

	movq	MIN_N, I
	sarq	$3,    I
	jle	.L12
	ALIGN_3

.L11:
	movlpd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm1
	movhpd	1 * SIZE(X), %xmm1
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm3
	movhpd	1 * SIZE(X), %xmm3
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm5
	movhpd	1 * SIZE(X), %xmm5
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	addq	INCX,X
	movlpd	0 * SIZE(X), %xmm7
	movhpd	1 * SIZE(X), %xmm7
	addq	INCX,X

#ifdef XCONJ
	xorpd	%xmm13, %xmm0
	xorpd	%xmm13, %xmm1
	xorpd	%xmm13, %xmm2
	xorpd	%xmm13, %xmm3
	xorpd	%xmm13, %xmm4
	xorpd	%xmm13, %xmm5
	xorpd	%xmm13, %xmm6
	xorpd	%xmm13, %xmm7
#endif

	movapd	%xmm0,  0 * SIZE(BO)
	movapd	%xmm1,  2 * SIZE(BO)
	movapd	%xmm2,  4 * SIZE(BO)
	movapd	%xmm3,  6 * SIZE(BO)
	movapd	%xmm4,  8 * SIZE(BO)
	movapd	%xmm5, 10 * SIZE(BO)
	movapd	%xmm6, 12 * SIZE(BO)
	movapd	%xmm7, 14 * SIZE(BO)

	addq	$16 * SIZE, BO
	decq	I
	jg	.L11
	ALIGN_3

.L12:
	movq	MIN_N, I
	andq	$7,   I
	jle	.L20
	ALIGN_3

.L13:
	movlpd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	addq	INCX,X
#ifdef XCONJ
	xorpd	%xmm13, %xmm0
#endif
	movapd	%xmm0,  0 * SIZE(BO)

	addq	$2 * SIZE, BO
	decq	I
	jg	.L13
	ALIGN_3

.L20:
	movq	Y,   CO

	movq	N,   J
	sarq	$2,  J
	jle	.L30
	ALIGN_3
	
.L21:
	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A

	movq	BUFFER, BO

	movapd	 0 * SIZE(BO),  %xmm12
	pxor	%xmm0, %xmm0
	movapd	 2 * SIZE(BO),  %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	PREFETCHW  7 * SIZE(CO)

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L24

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)
	decq	 I
	jle	 .L23
	ALIGN_3

.L22:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(0 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(1 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(0 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(1 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(2 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(3 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(2 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(3 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	PREFETCH	PREFETCHSIZE * SIZE(AO2)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(4 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(5 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(4 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(5 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(6 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(7 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(6 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(7 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(9 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(8 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(9 * SIZE, AO2, %xmm11)

	PREFETCH	PREFETCHSIZE * SIZE(AO1, LDA, 2)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(8 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(9 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(8 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(9 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(11 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(10 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(11 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(10 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(11 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(10 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(11 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(13 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(12 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(13 * SIZE, AO2, %xmm11)

	PREFETCH	PREFETCHSIZE * SIZE(AO2, LDA, 2)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(12 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(13 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(12 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(13 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(15 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(14 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(15 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(14 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(15 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(14 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(15 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(16 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(17 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(16 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(17 * SIZE, AO2, %xmm11)

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L22
	ALIGN_3

.L23:
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(0 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(1 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(0 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(1 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(2 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(3 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(2 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(3 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(4 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(5 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(4 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(5 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(6 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(7 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(6 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(7 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(9 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(8 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(9 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(8 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(9 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(8 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(9 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(11 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(10 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(11 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(10 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(11 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(10 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(11 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(13 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(12 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(13 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(12 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(13 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(12 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(13 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(15 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(14 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(15 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(14 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(15 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(14 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(15 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7

	addq	$16 * SIZE, AO1
	addq	$16 * SIZE, AO2
	addq	$16 * SIZE, BO
	ALIGN_3

.L24:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L25

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(0 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(1 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(0 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(1 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(2 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(3 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(2 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(3 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(4 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(5 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(4 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(5 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(6 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(7 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(6 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(7 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11, %xmm7

	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, AO2
	addq	$8 * SIZE, BO
	ALIGN_3

.L25:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L26

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(0 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(1 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(0 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(1 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11, %xmm7
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(2 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(3 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(2 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(3 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	addq	$4 * SIZE, AO1
	addq	$4 * SIZE, AO2
	addq	$4 * SIZE, BO
	ALIGN_2

.L26:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L27

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP2(0 * SIZE, (AO1, LDA, 2), %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP2(1 * SIZE, (AO1, LDA, 2), %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP2(0 * SIZE, (AO2, LDA, 2), %xmm10)
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	MOVDDUP2(1 * SIZE, (AO2, LDA, 2), %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7
	ALIGN_3

.L27:
	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3
	SHUFPD_1 %xmm5, %xmm5
	SHUFPD_1 %xmm7, %xmm7

	addsubpd    %xmm1, %xmm0
	addsubpd    %xmm3, %xmm2
	addsubpd    %xmm5, %xmm4
	addsubpd    %xmm7, %xmm6

	movapd	    %xmm0, %xmm1
	movapd	    %xmm2, %xmm3
	movapd	    %xmm4, %xmm5
	movapd	    %xmm6, %xmm7

	unpcklpd    %xmm0, %xmm0
	unpckhpd    %xmm1, %xmm1
	unpcklpd    %xmm2, %xmm2
	unpckhpd    %xmm3, %xmm3

	unpcklpd    %xmm4, %xmm4
	unpckhpd    %xmm5, %xmm5
	unpcklpd    %xmm6, %xmm6
	unpckhpd    %xmm7, %xmm7

	mulpd	    ALPHA, %xmm0
	mulpd	    ALPHA, %xmm1
	mulpd	    ALPHA, %xmm2
	mulpd	    ALPHA, %xmm3

	mulpd	    ALPHA, %xmm4
	mulpd	    ALPHA, %xmm5
	mulpd	    ALPHA, %xmm6
	mulpd	    ALPHA, %xmm7

	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3
	SHUFPD_1 %xmm5, %xmm5
	SHUFPD_1 %xmm7, %xmm7

	addsubpd    %xmm1, %xmm0
	addsubpd    %xmm3, %xmm2
	addsubpd    %xmm5, %xmm4
	addsubpd    %xmm7, %xmm6

	movq	    CO, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2
	addq	INCY, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm4
	addq	INCY, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm6

	movlpd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movlpd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO

	movlpd	 %xmm4, 0 * SIZE(CO)
	movhpd	 %xmm4, 1 * SIZE(CO)
	addq	INCY, CO

	movlpd	 %xmm6, 0 * SIZE(CO)
	movhpd	 %xmm6, 1 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L21
	ALIGN_3

.L30:
	movq	N,   I
	andq	$2,  I
	jle	.L40
	ALIGN_3
	
.L31:
	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A

	movq	BUFFER, BO

	movapd	 0 * SIZE(BO),  %xmm12
	movapd	 2 * SIZE(BO),  %xmm13

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L34

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	decq	 I
	jle	 .L33
	ALIGN_3

.L32:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(9 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(8 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(9 * SIZE, AO2, %xmm11)

	PREFETCH	PREFETCHSIZE * SIZE(AO2)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(11 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(10 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(11 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(13 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(12 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(13 * SIZE, AO2, %xmm11)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(15 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(14 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(15 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(16 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(17 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(16 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(17 * SIZE, AO2, %xmm11)

	addq	$16 * SIZE, AO1
	addq	$16 * SIZE, AO2
	addq	$16 * SIZE, BO
	decq	I
	jg	.L32
	ALIGN_3

.L33:
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(9 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(8 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(9 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(11 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(10 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(11 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(13 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(12 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(13 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(15 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(14 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(15 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3

	addq	$16 * SIZE, AO1
	addq	$16 * SIZE, AO2
	addq	$16 * SIZE, BO
	ALIGN_3

.L34:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L35

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(5 * SIZE, AO1, %xmm9)
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(4 * SIZE, AO2, %xmm10)
	mulpd	%xmm13, %xmm11
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3
	MOVDDUP(5 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(6 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(7 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm11,  %xmm3

	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, AO2
	addq	$8 * SIZE, BO
	ALIGN_3

.L35:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L36

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	MOVDDUP(2 * SIZE, AO2, %xmm10)
	mulpd	%xmm12, %xmm11
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm11,  %xmm3
	MOVDDUP(3 * SIZE, AO2, %xmm11)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	addq	$4 * SIZE, AO1
	addq	$4 * SIZE, AO2
	addq	$4 * SIZE, BO
	ALIGN_2

.L36:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L37

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	MOVDDUP(0 * SIZE, AO2, %xmm10)
	MOVDDUP(1 * SIZE, AO2, %xmm11)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	ALIGN_3

.L37:
	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3

	addsubpd    %xmm1, %xmm0
	addsubpd    %xmm3, %xmm2

	movapd	    %xmm0, %xmm1
	movapd	    %xmm2, %xmm3

	unpcklpd    %xmm0, %xmm0
	unpckhpd    %xmm1, %xmm1
	unpcklpd    %xmm2, %xmm2
	unpckhpd    %xmm3, %xmm3

	mulpd	    ALPHA, %xmm0
	mulpd	    ALPHA, %xmm1
	mulpd	    ALPHA, %xmm2
	mulpd	    ALPHA, %xmm3

	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3

	addsubpd    %xmm1, %xmm0
	addsubpd    %xmm3, %xmm2

	movq	    CO, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movupd	 0 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2

	movlpd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movlpd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO
	ALIGN_3

.L40:
	movq	N,   I
	andq	$1,  I
	jle	.L99
	ALIGN_3
	
.L41:
	movq	A,  AO1
	addq	LDA, A

	movq	BUFFER, BO

	movapd	 0 * SIZE(BO),  %xmm12
	movapd	 2 * SIZE(BO),  %xmm13

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L44

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)
	decq	 I
	jle	 .L43
	ALIGN_3

.L42:
	PREFETCH	PREFETCHSIZE * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(5 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(9 * SIZE, AO1, %xmm9)

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(11 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(13 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(15 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(16 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(17 * SIZE, AO1, %xmm9)

	addq	$16 * SIZE, AO1
	addq	$16 * SIZE, BO
	decq	I
	jg	.L42
	ALIGN_3

.L43:
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(5 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(8 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(9 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(10 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	12 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(11 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(12 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	14 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1
	MOVDDUP(13 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(14 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	16 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(15 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	movapd	18 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm1

	addq	$16 * SIZE, AO1
	addq	$16 * SIZE, BO
	ALIGN_3

.L44:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L45

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	MOVDDUP(4 * SIZE, AO1, %xmm8)
	mulpd	%xmm13, %xmm9
	movapd	 6 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm3
	MOVDDUP(5 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(6 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 8 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(7 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	movapd	10 * SIZE(BO),  %xmm13
	ADD	%xmm9,  %xmm3

	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, BO
	ALIGN_3

.L45:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L46

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	MOVDDUP(2 * SIZE, AO1, %xmm8)
	mulpd	%xmm12, %xmm9
	movapd	 4 * SIZE(BO),  %xmm12
	ADD	%xmm9,  %xmm1
	MOVDDUP(3 * SIZE, AO1, %xmm9)

	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	addq	$4 * SIZE, AO1
	addq	$4 * SIZE, BO
	ALIGN_2

.L46:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L47

	MOVDDUP(0 * SIZE, AO1, %xmm8)
	MOVDDUP(1 * SIZE, AO1, %xmm9)

	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	ALIGN_3

.L47:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

	SHUFPD_1 %xmm1, %xmm1

	addsubpd    %xmm1, %xmm0

	movapd	    %xmm0, %xmm1

	unpcklpd    %xmm0, %xmm0
	unpckhpd    %xmm1, %xmm1

	mulpd	    ALPHA, %xmm0
	mulpd	    ALPHA, %xmm1

	SHUFPD_1 %xmm1, %xmm1

	addsubpd    %xmm1, %xmm0

	movupd	 0 * SIZE(CO), %xmm8
	addpd	%xmm8, %xmm0

	movlpd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	ALIGN_3

.L99:
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

	EPILOGUE
