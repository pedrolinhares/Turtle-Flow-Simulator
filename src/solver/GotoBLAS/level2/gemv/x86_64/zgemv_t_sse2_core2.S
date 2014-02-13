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

#ifdef CORE2
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE	32
#endif

#ifdef PENRYN
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE	32
#endif

#ifdef PRESCOTT
#define PREFETCH	prefetchnta
#define PREFETCHW	prefetcht2
#define PREFETCHSIZE	32
#endif

#define P 8192

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

#ifdef CONJ
#define ADD	subpd
#else
#define ADD	addpd
#endif

#define	ALPHA	%xmm14
#define	BETA	%xmm15

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

	pcmpeqb	%xmm12, %xmm12
	xorpd	BETA, BETA
	psllq	$63,    %xmm12
	unpckhpd %xmm12, BETA

	salq	$ZBASE_SHIFT,   INCX
	salq	$ZBASE_SHIFT,   INCY

	mov     N,   TEMP
	imulq	LDA, TEMP
	movq	$P,   BO
	subq	TEMP, BO

	addq	$16 * SIZE, A

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


	movq	MIN_N, I
	sarq	$3,    I
	jle	.L12
	ALIGN_3

.L11:
	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm1
	movhpd	1 * SIZE(X), %xmm1
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm3
	movhpd	1 * SIZE(X), %xmm3
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm5
	movhpd	1 * SIZE(X), %xmm5
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	addq	INCX,X
	movsd	0 * SIZE(X), %xmm7
	movhpd	1 * SIZE(X), %xmm7
	addq	INCX,X

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
	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	addq	INCX,X

	movapd	%xmm0,  0 * SIZE(BO)

	addq	$2 * SIZE, BO
	decq	I
	jg	.L13
	ALIGN_3

.L20:
	movq	Y,   CO

	testq	$SIZE, A
	jne	.L100

	movq	N,   J
	sarq	$2,  J
	jle	.L30
	ALIGN_3
	
.L21:
	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	movapd	-14 * SIZE(BO),  %xmm13

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L24
	ALIGN_3

.L22:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movapd	-16 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	movapd	-16 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	-16 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	-16 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	-12 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	-14 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	-14 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2)

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	-14 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	-10 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	-12 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	-12 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1, LDA, 2)

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	-12 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	-12 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	 -8 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	-10 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	-10 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2, LDA, 2)

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	-10 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	 -6 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	 -8 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	 -8 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	 -8 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	 -8 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	 -4 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	 -6 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	 -6 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	 -6 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	 -6 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	 -2 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	 -4 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	 -4 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	 -4 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	 -4 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	  0 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	movapd	 -2 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7
	movapd	 -2 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	movapd	 -2 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3
	movapd	 -2 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	  2 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L22
	ALIGN_3

.L24:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L25

	movapd	-16 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-16 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-16 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-14 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-14 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-10 * SIZE(BO),  %xmm13

	movapd	-12 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-12 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	 -8 * SIZE(BO),  %xmm12

	movapd	-10 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-10 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-10 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-10 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO
	ALIGN_3

.L25:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L26

	movapd	-16 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-16 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-16 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-14 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-14 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-14 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO
	ALIGN_2

.L26:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L27

	movapd	-16 * SIZE(AO1), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-16 * SIZE(AO1, LDA, 2), %xmm9
	movapd	%xmm9, %xmm8
	SHUFPD_1 %xmm9, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movapd	-16 * SIZE(AO2, LDA, 2), %xmm11
	movapd	%xmm11, %xmm10
	SHUFPD_1 %xmm11, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7
	ALIGN_3

.L27:
#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
	pxor	BETA, %xmm2
	pxor	BETA, %xmm4
	pxor	BETA, %xmm6
#else
	pxor	BETA, %xmm1
	pxor	BETA, %xmm3
	pxor	BETA, %xmm5
	pxor	BETA, %xmm7
#endif

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2
	haddpd	%xmm5, %xmm4
	haddpd	%xmm7, %xmm6

	pshufd	  $0x4e, %xmm0, %xmm1
	pshufd	  $0x4e, %xmm2, %xmm3
	pshufd	  $0x4e, %xmm4, %xmm5
	pshufd	  $0x4e, %xmm6, %xmm7

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1
	mulpd	  ALPHA, %xmm2
	mulpd	  ALPHA, %xmm3
	mulpd	  ALPHA, %xmm4
	mulpd	  ALPHA, %xmm5
	mulpd	  ALPHA, %xmm6
	mulpd	  ALPHA, %xmm7

	xorpd	  BETA, %xmm0
	xorpd	  BETA, %xmm2
	xorpd	  BETA, %xmm4
	xorpd	  BETA, %xmm6

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2
	haddpd	%xmm5, %xmm4
	haddpd	%xmm7, %xmm6

	movq	    CO, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm4
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm6

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm4, 0 * SIZE(CO)
	movhpd	 %xmm4, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm6, 0 * SIZE(CO)
	movhpd	 %xmm6, 1 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L21
	ALIGN_3

.L30:
	movq	N,   I
	andq	$2,  I
	jle	.L40

	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	pxor	%xmm0, %xmm0
	movapd	-14 * SIZE(BO),  %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	PREFETCHW 16 * SIZE(CO)

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L34
	ALIGN_3

.L32:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-14 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2)

	movapd	-10 * SIZE(BO),  %xmm13

	movapd	-12 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -8 * SIZE(BO),  %xmm12

	movapd	-10 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-10 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	movapd	 -6 * SIZE(BO),  %xmm13

	movapd	 -8 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -8 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -4 * SIZE(BO),  %xmm12

	movapd	 -6 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -6 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	movapd	 -2 * SIZE(BO),  %xmm13

	movapd	 -4 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -4 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	  0 * SIZE(BO),  %xmm12

	movapd	 -2 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -2 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	  2 * SIZE(BO),  %xmm13

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L32
	ALIGN_3

.L34:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L35

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-14 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movapd	-12 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -8 * SIZE(BO),  %xmm12

	movapd	-10 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-10 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO
	ALIGN_3

.L35:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L36

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-14 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO
	ALIGN_2

.L36:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L37

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-16 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	ALIGN_3

.L37:
#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
	pxor	BETA, %xmm2
#else
	pxor	BETA, %xmm1
	pxor	BETA, %xmm3
#endif

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2

	pshufd	  $0x4e, %xmm0, %xmm1
	pshufd	  $0x4e, %xmm2, %xmm3

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1
	mulpd	  ALPHA, %xmm2
	mulpd	  ALPHA, %xmm3

	xorpd	  BETA, %xmm0
	xorpd	  BETA, %xmm2

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2

	movq	    CO, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO
	ALIGN_3

.L40:
	movq	N,   I
	andq	$1,  I
	jle	.L99
	
	movq	A,  AO1
	addq	LDA, A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	pxor	%xmm0, %xmm0
	movapd	-14 * SIZE(BO),  %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L44
	ALIGN_3

.L42:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movapd	-12 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -8 * SIZE(BO),  %xmm12

	movapd	-10 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	movapd	 -6 * SIZE(BO),  %xmm13

	movapd	 -8 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -4 * SIZE(BO),  %xmm12

	movapd	 -6 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	 -2 * SIZE(BO),  %xmm13

	movapd	 -4 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	  0 * SIZE(BO),  %xmm12

	movapd	 -2 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	  2 * SIZE(BO),  %xmm13

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L42
	ALIGN_3

.L44:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L45

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movapd	-12 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -8 * SIZE(BO),  %xmm12

	movapd	-10 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, BO
	ALIGN_3

.L45:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L46

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movapd	-14 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, BO
	ALIGN_2

.L46:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L47

	movapd	-16 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	ALIGN_3

.L47:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
#else
	pxor	BETA, %xmm1
#endif

	haddpd	%xmm1, %xmm0

	pshufd	  $0x4e, %xmm0, %xmm1

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1

	xorpd	  BETA, %xmm0

	haddpd	%xmm1, %xmm0

	movsd	 0 * SIZE(CO), %xmm8
	movhpd	 1 * SIZE(CO), %xmm8

	addpd	%xmm8, %xmm0

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	ALIGN_3

.L99:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
	jl	.L10

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

.L100:
	movq	N,   J
	sarq	$2,  J
	jle	.L130
	ALIGN_3
	
.L121:
	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 4), A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	movapd	-14 * SIZE(BO),  %xmm13

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L124
	ALIGN_3

.L122:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-15 * SIZE(AO1, LDA, 2), %xmm8
	movsd	-16 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-15 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	-12 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2)

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	-14 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-13 * SIZE(AO1, LDA, 2), %xmm8
	movsd	-14 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-13 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	-10 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1, LDA, 2)

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	movsd	-12 * SIZE(AO2), %xmm10
	movhpd	-11 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	-12 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-11 * SIZE(AO1, LDA, 2), %xmm8
	movsd	-12 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-11 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	 -8 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2, LDA, 2)

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	movsd	-10 * SIZE(AO2), %xmm10
	movhpd	 -9 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	-10 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -9 * SIZE(AO1, LDA, 2), %xmm8
	movsd	-10 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -9 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	 -6 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	movsd	 -8 * SIZE(AO1), %xmm8
	movhpd	 -7 * SIZE(AO1), %xmm8
	movsd	 -8 * SIZE(AO2), %xmm10
	movhpd	 -7 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	 -8 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -7 * SIZE(AO1, LDA, 2), %xmm8
	movsd	 -8 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -7 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	 -4 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	movsd	 -6 * SIZE(AO1), %xmm8
	movhpd	 -5 * SIZE(AO1), %xmm8
	movsd	 -6 * SIZE(AO2), %xmm10
	movhpd	 -5 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	 -6 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -5 * SIZE(AO1, LDA, 2), %xmm8
	movsd	 -6 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -5 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	 -2 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1, LDA, 2)

	movsd	 -4 * SIZE(AO1), %xmm8
	movhpd	 -3 * SIZE(AO1), %xmm8
	movsd	 -4 * SIZE(AO2), %xmm10
	movhpd	 -3 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	 -4 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -3 * SIZE(AO1, LDA, 2), %xmm8
	movsd	 -4 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -3 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm12, %xmm8
	mulpd	%xmm12, %xmm9
	mulpd	%xmm12, %xmm10
	mulpd	%xmm12, %xmm11

	movapd	  0 * SIZE(BO),  %xmm12

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2, LDA, 2)

	movsd	 -2 * SIZE(AO1), %xmm8
	movhpd	 -1 * SIZE(AO1), %xmm8
	movsd	 -2 * SIZE(AO2), %xmm10
	movhpd	 -1 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	addpd	%xmm8,  %xmm0
	ADD	%xmm9,  %xmm1
	addpd	%xmm10, %xmm2
	ADD	%xmm11, %xmm3

	movsd	 -2 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -1 * SIZE(AO1, LDA, 2), %xmm8
	movsd	 -2 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -1 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm8, %xmm9
	pshufd	  $0x4e, %xmm10, %xmm11

	mulpd	%xmm13, %xmm8
	mulpd	%xmm13, %xmm9
	mulpd	%xmm13, %xmm10
	mulpd	%xmm13, %xmm11

	movapd	  2 * SIZE(BO),  %xmm13

	addpd	%xmm8,  %xmm4
	ADD	%xmm9,  %xmm5
	addpd	%xmm10, %xmm6
	ADD	%xmm11, %xmm7

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L122
	ALIGN_3

.L124:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L125

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-15 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-16 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-15 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-14 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-13 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-14 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-13 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-10 * SIZE(BO),  %xmm13

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-12 * SIZE(AO2), %xmm10
	movhpd	-11 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-12 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-11 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-12 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-11 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	 -8 * SIZE(BO),  %xmm12

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-10 * SIZE(AO2), %xmm10
	movhpd	 -9 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-10 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	 -9 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-10 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	 -9 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO
	ALIGN_3

.L125:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L126

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-15 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-16 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-15 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-14 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-13 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-14 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-13 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm13, %xmm11
	ADD	%xmm11, %xmm7

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO
	ALIGN_2

.L126:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L127

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movsd	-16 * SIZE(AO1, LDA, 2), %xmm8
	movhpd	-15 * SIZE(AO1, LDA, 2), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm4
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm5

	movsd	-16 * SIZE(AO2, LDA, 2), %xmm10
	movhpd	-15 * SIZE(AO2, LDA, 2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10, %xmm6
	mulpd	%xmm12, %xmm11
	ADD	%xmm11, %xmm7
	ALIGN_3

.L127:
#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
	pxor	BETA, %xmm2
	pxor	BETA, %xmm4
	pxor	BETA, %xmm6
#else
	pxor	BETA, %xmm1
	pxor	BETA, %xmm3
	pxor	BETA, %xmm5
	pxor	BETA, %xmm7
#endif

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2
	haddpd	%xmm5, %xmm4
	haddpd	%xmm7, %xmm6

	pshufd	  $0x4e, %xmm0, %xmm1
	pshufd	  $0x4e, %xmm2, %xmm3
	pshufd	  $0x4e, %xmm4, %xmm5
	pshufd	  $0x4e, %xmm6, %xmm7

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1
	mulpd	  ALPHA, %xmm2
	mulpd	  ALPHA, %xmm3
	mulpd	  ALPHA, %xmm4
	mulpd	  ALPHA, %xmm5
	mulpd	  ALPHA, %xmm6
	mulpd	  ALPHA, %xmm7

	xorpd	  BETA, %xmm0
	xorpd	  BETA, %xmm2
	xorpd	  BETA, %xmm4
	xorpd	  BETA, %xmm6

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2
	haddpd	%xmm5, %xmm4
	haddpd	%xmm7, %xmm6

	movq	    CO, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm4
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm6

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm4, 0 * SIZE(CO)
	movhpd	 %xmm4, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm6, 0 * SIZE(CO)
	movhpd	 %xmm6, 1 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L121
	ALIGN_3

.L130:
	movq	N,   I
	andq	$2,  I
	jle	.L140

	movq	A,  AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	pxor	%xmm0, %xmm0
	movapd	-14 * SIZE(BO),  %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	PREFETCHW 16 * SIZE(CO)

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L134
	ALIGN_3

.L132:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO2)

	movapd	-10 * SIZE(BO),  %xmm13

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-12 * SIZE(AO2), %xmm10
	movhpd	-11 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -8 * SIZE(BO),  %xmm12

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-10 * SIZE(AO2), %xmm10
	movhpd	 -9 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	movapd	 -6 * SIZE(BO),  %xmm13

	movsd	 -8 * SIZE(AO1), %xmm8
	movhpd	 -7 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	 -8 * SIZE(AO2), %xmm10
	movhpd	 -7 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -4 * SIZE(BO),  %xmm12

	movsd	 -6 * SIZE(AO1), %xmm8
	movhpd	 -5 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	 -6 * SIZE(AO2), %xmm10
	movhpd	 -5 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO2)

	movapd	 -2 * SIZE(BO),  %xmm13

	movsd	 -4 * SIZE(AO1), %xmm8
	movhpd	 -3 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	 -4 * SIZE(AO2), %xmm10
	movhpd	 -3 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	  0 * SIZE(BO),  %xmm12

	movsd	 -2 * SIZE(AO1), %xmm8
	movhpd	 -1 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	 -2 * SIZE(AO2), %xmm10
	movhpd	 -1 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	  2 * SIZE(BO),  %xmm13

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, AO2
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L132
	ALIGN_3

.L134:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L135

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-12 * SIZE(AO2), %xmm10
	movhpd	-11 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -8 * SIZE(BO),  %xmm12

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-10 * SIZE(AO2), %xmm10
	movhpd	 -9 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, AO2
	subq	$-8 * SIZE, BO
	ALIGN_3

.L135:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L136

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-14 * SIZE(AO2), %xmm10
	movhpd	-13 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm13, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm13, %xmm11
	ADD	%xmm11,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, AO2
	subq	$-4 * SIZE, BO
	ALIGN_2

.L136:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L137

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movsd	-16 * SIZE(AO2), %xmm10
	movhpd	-15 * SIZE(AO2), %xmm10
	pshufd	  $0x4e, %xmm10, %xmm11
	mulpd	%xmm12, %xmm10
	addpd	%xmm10,  %xmm2
	mulpd	%xmm12, %xmm11
	ADD	%xmm11,  %xmm3
	ALIGN_3

.L137:
#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
	pxor	BETA, %xmm2
#else
	pxor	BETA, %xmm1
	pxor	BETA, %xmm3
#endif

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2

	pshufd	  $0x4e, %xmm0, %xmm1
	pshufd	  $0x4e, %xmm2, %xmm3

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1
	mulpd	  ALPHA, %xmm2
	mulpd	  ALPHA, %xmm3

	xorpd	  BETA, %xmm0
	xorpd	  BETA, %xmm2

	haddpd	%xmm1, %xmm0
	haddpd	%xmm3, %xmm2

	movq	    CO, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm0
	addq	INCY, TEMP

	movsd	 0 * SIZE(TEMP), %xmm8
	movhpd	 1 * SIZE(TEMP), %xmm8
	addpd	%xmm8, %xmm2

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	addq	INCY, CO

	movsd	 %xmm2, 0 * SIZE(CO)
	movhpd	 %xmm2, 1 * SIZE(CO)
	addq	INCY, CO
	ALIGN_3

.L140:
	movq	N,   I
	andq	$1,  I
	jle	.L199
	
	movq	A,  AO1
	addq	LDA, A

	movq	BUFFER, BO

	addq	$16 * SIZE, BO

	movapd	-16 * SIZE(BO),  %xmm12
	pxor	%xmm0, %xmm0
	movapd	-14 * SIZE(BO),  %xmm13
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	movq	MIN_N, I
	sarq	$3,   I
	jle	.L144
	ALIGN_3

.L142:
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(AO1)

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -8 * SIZE(BO),  %xmm12

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	PREFETCH	(PREFETCHSIZE + 8) * SIZE(AO1)

	movapd	 -6 * SIZE(BO),  %xmm13

	movsd	 -8 * SIZE(AO1), %xmm8
	movhpd	 -7 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -4 * SIZE(BO),  %xmm12

	movsd	 -6 * SIZE(AO1), %xmm8
	movhpd	 -5 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	 -2 * SIZE(BO),  %xmm13

	movsd	 -4 * SIZE(AO1), %xmm8
	movhpd	 -3 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	  0 * SIZE(BO),  %xmm12

	movsd	 -2 * SIZE(AO1), %xmm8
	movhpd	 -1 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	  2 * SIZE(BO),  %xmm13

	subq	$-16 * SIZE, AO1
	subq	$-16 * SIZE, BO
	decq	I
	jg	.L142
	ALIGN_3

.L144:
	movq	MIN_N, I
	andq	$4,   I
	jle	.L145

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	movsd	-12 * SIZE(AO1), %xmm8
	movhpd	-11 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	 -8 * SIZE(BO),  %xmm12

	movsd	-10 * SIZE(AO1), %xmm8
	movhpd	 -9 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	 -6 * SIZE(BO),  %xmm13

	subq	$-8 * SIZE, AO1
	subq	$-8 * SIZE, BO
	ALIGN_3

.L145:
	movq	MIN_N, I
	andq	$2,   I
	jle	.L146

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1

	movapd	-12 * SIZE(BO),  %xmm12

	movsd	-14 * SIZE(AO1), %xmm8
	movhpd	-13 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm13, %xmm8
	addpd	%xmm8,  %xmm2
	mulpd	%xmm13, %xmm9
	ADD	%xmm9,  %xmm3

	movapd	-10 * SIZE(BO),  %xmm13

	subq	$-4 * SIZE, AO1
	subq	$-4 * SIZE, BO
	ALIGN_2

.L146:
	movq	MIN_N, I
	andq	$1,   I
	jle	.L147

	movsd	-16 * SIZE(AO1), %xmm8
	movhpd	-15 * SIZE(AO1), %xmm8
	pshufd	  $0x4e, %xmm8, %xmm9
	mulpd	%xmm12, %xmm8
	addpd	%xmm8,  %xmm0
	mulpd	%xmm12, %xmm9
	ADD	%xmm9,  %xmm1
	ALIGN_3

.L147:
	addpd	%xmm2, %xmm0
	addpd	%xmm3, %xmm1

#if (!defined(CONJ) && !defined(XCONJ)) || \
    ( defined(CONJ) &&  defined(XCONJ))
	pxor	BETA, %xmm0
#else
	pxor	BETA, %xmm1
#endif

	haddpd	%xmm1, %xmm0

	pshufd	  $0x4e, %xmm0, %xmm1

	mulpd	  ALPHA, %xmm0
	mulpd	  ALPHA, %xmm1

	xorpd	  BETA, %xmm0

	haddpd	%xmm1, %xmm0

	movsd	 0 * SIZE(CO), %xmm8
	movhpd	 1 * SIZE(CO), %xmm8

	addpd	%xmm8, %xmm0

	movsd	 %xmm0, 0 * SIZE(CO)
	movhpd	 %xmm0, 1 * SIZE(CO)
	ALIGN_3

.L199:
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
