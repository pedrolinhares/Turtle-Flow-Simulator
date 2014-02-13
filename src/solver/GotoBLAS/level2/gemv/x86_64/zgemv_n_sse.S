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

#ifndef PARAMTEST
#define P 24
#else
#define P		40 + STACKSIZE(%rsp)
#endif
	
#define PREFETCHSIZE	32

#ifndef WINDOWS_ABI

#define STACKSIZE	64
	
#define OLD_INCX	 8 + STACKSIZE(%rsp)
#define OLD_Y		16 + STACKSIZE(%rsp)
#define OLD_INCY	24 + STACKSIZE(%rsp)
#define BUFFER		32 + STACKSIZE(%rsp)
#define PLDA_M	        48            (%rsp)
	
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
#define PLDA_M	        224            (%rsp)

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
#define J     %r12
#define AO    %r13
#define BO    %r14
#define CO    %r15

#ifdef OPTERON
#define movsd   movlps
#endif
#define movhpd	movhps

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

	EMMS

	movq	OLD_INCX,  INCX
	movq	OLD_Y,     Y
	movq	OLD_INCY,  INCY

	salq	$ZBASE_SHIFT,   INCX
	salq	$ZBASE_SHIFT,   INCY

	movq	LDA,  %r14		# eax = lda
#ifndef PARAMTEST
	imulq	$P,   %r14
#else
	imulq	 P,   %r14
#endif
	subq	M,    %r14		# eax -= m
	salq	$ZBASE_SHIFT, %r14
	movq	%r14, PLDA_M

	salq	$ZBASE_SHIFT,   LDA

	pxor	%xmm13,  %xmm13
	cmpeqps	%xmm13,  %xmm13
	pslld	$31,     %xmm13	# Generate mask
	xorps	%xmm12,  %xmm12
	unpcklps %xmm13, %xmm12

	shufps  $0, %xmm0, %xmm0
	shufps  $0, %xmm1, %xmm1
	xorps	%xmm12, %xmm1
	movaps	%xmm0, %xmm14
	movaps	%xmm1, %xmm15

	xor	IS, IS

	testq	M, M
	jle	.L999
	testq	N, N
	jle	.L999
	ALIGN_3

.L10:
	movq	N,    MIN_N
	subq	IS,   MIN_N		# m - is
#ifndef PARAMTEST
	movq	$P,   TEMP
#else
	movq	 P,   TEMP
#endif
	cmpq	TEMP, MIN_N
	cmovg	TEMP, MIN_N

	pcmpeqb	%mm7, %mm7
	pslld	$31, %mm7	

	movq	BUFFER, BO

	movq	MIN_N, I
	sarq	$2,   I
	jle	.L12
	ALIGN_3

.L11:
#ifndef CONJ
	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X
	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0,  0 * SIZE(BO)
	movd	%mm0,  1 * SIZE(BO)
	movd	%mm0,  2 * SIZE(BO)
	movd	%mm0,  3 * SIZE(BO)

	movd	%mm1,  5 * SIZE(BO)
	movd	%mm1,  7 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1,  4 * SIZE(BO)
	movd	%mm1,  6 * SIZE(BO)

	movd	%mm2,  8 * SIZE(BO)
	movd	%mm2,  9 * SIZE(BO)
	movd	%mm2, 10 * SIZE(BO)
	movd	%mm2, 11 * SIZE(BO)

	movd	%mm3, 13 * SIZE(BO)
	movd	%mm3, 15 * SIZE(BO)
	pxor	%mm7, %mm3
	movd	%mm3, 12 * SIZE(BO)
	movd	%mm3, 14 * SIZE(BO)

	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X
	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0, 16 * SIZE(BO)
	movd	%mm0, 17 * SIZE(BO)
	movd	%mm0, 18 * SIZE(BO)
	movd	%mm0, 19 * SIZE(BO)

	movd	%mm1, 21 * SIZE(BO)
	movd	%mm1, 23 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1, 20 * SIZE(BO)
	movd	%mm1, 22 * SIZE(BO)

	movd	%mm2, 24 * SIZE(BO)
	movd	%mm2, 25 * SIZE(BO)
	movd	%mm2, 26 * SIZE(BO)
	movd	%mm2, 27 * SIZE(BO)

	movd	%mm3, 29 * SIZE(BO)
	movd	%mm3, 31 * SIZE(BO)
	pxor	%mm7, %mm3
	movd	%mm3, 28 * SIZE(BO)
	movd	%mm3, 30 * SIZE(BO)
#else
	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X
	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0,  0 * SIZE(BO)
	movd	%mm0,  2 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0,  1 * SIZE(BO)
	movd	%mm0,  3 * SIZE(BO)

	movd	%mm1,  4 * SIZE(BO)
	movd	%mm1,  5 * SIZE(BO)
	movd	%mm1,  6 * SIZE(BO)
	movd	%mm1,  7 * SIZE(BO)

	movd	%mm2,  8 * SIZE(BO)
	movd	%mm2, 10 * SIZE(BO)
	pxor	%mm7, %mm2
	movd	%mm2,  9 * SIZE(BO)
	movd	%mm2, 11 * SIZE(BO)

	movd	%mm3, 12 * SIZE(BO)
	movd	%mm3, 13 * SIZE(BO)
	movd	%mm3, 14 * SIZE(BO)
	movd	%mm3, 15 * SIZE(BO)

	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X
	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0, 16 * SIZE(BO)
	movd	%mm0, 18 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0, 17 * SIZE(BO)
	movd	%mm0, 19 * SIZE(BO)

	movd	%mm1, 20 * SIZE(BO)
	movd	%mm1, 21 * SIZE(BO)
	movd	%mm1, 22 * SIZE(BO)
	movd	%mm1, 23 * SIZE(BO)

	movd	%mm2, 24 * SIZE(BO)
	movd	%mm2, 26 * SIZE(BO)
	pxor	%mm7, %mm2
	movd	%mm2, 25 * SIZE(BO)
	movd	%mm2, 27 * SIZE(BO)

	movd	%mm3, 28 * SIZE(BO)
	movd	%mm3, 29 * SIZE(BO)
	movd	%mm3, 30 * SIZE(BO)
	movd	%mm3, 31 * SIZE(BO)
#endif

	addq	$32 * SIZE, BO
	decq	I
	jg	.L11
	ALIGN_3

.L12:
	movq	MIN_N, I
	andq	$3,   I
	jle	.L20
	ALIGN_3

.L13:
	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX, X

#ifndef CONJ
	movd	%mm0, 0 * SIZE(BO)
	movd	%mm0, 1 * SIZE(BO)
	movd	%mm0, 2 * SIZE(BO)
	movd	%mm0, 3 * SIZE(BO)

	movd	%mm1, 5 * SIZE(BO)
	movd	%mm1, 7 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1, 4 * SIZE(BO)
	movd	%mm1, 6 * SIZE(BO)
#else
	movd	%mm0, 0 * SIZE(BO)
	movd	%mm0, 2 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(BO)

	movd	%mm0, 3 * SIZE(BO)
	movd	%mm1, 4 * SIZE(BO)
	movd	%mm1, 5 * SIZE(BO)
	movd	%mm1, 6 * SIZE(BO)
	movd	%mm1, 7 * SIZE(BO)
#endif

	addq	$8 * SIZE, BO
	decq	I
	jg	.L13
	ALIGN_3

.L20:
	movq	Y,  CO
	movq	M,  J
	sarq	$2, J
	jle	.L50
	ALIGN_3

.L21:
	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movq	A, AO
	addq	$8 * SIZE, A

	movq	BUFFER, BO

	movaps	  0 * SIZE(BO), %xmm1
	movaps	 16 * SIZE(BO), %xmm3

	movq	MIN_N, I		# i = min_n
	sarq	$2,   I
	jle	.L23
	ALIGN_3

.L22:
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	movhps	  6 * SIZE(AO), %xmm2
	addq	LDA, AO

	prefetcht0 PREFETCHSIZE * SIZE(AO)
	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movhps	  2 * SIZE(AO), %xmm0
	addps	%xmm2, %xmm7

	movsd	  4 * SIZE(AO), %xmm2
	movhps	  6 * SIZE(AO), %xmm2
	addq	LDA, AO

	prefetcht0 PREFETCHSIZE * SIZE(AO)
	movaps	  8 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	mulps	 12 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  8 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm1
	mulps	 12 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	 32 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	movhps	  6 * SIZE(AO), %xmm2
	addq	LDA, AO

	prefetcht0 PREFETCHSIZE * SIZE(AO)
	mulps	%xmm0, %xmm3
	mulps	 20 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 16 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm3
	mulps	 20 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movhps	  2 * SIZE(AO), %xmm0
	addps	%xmm2, %xmm7

	movsd	  4 * SIZE(AO), %xmm2
	movhps	  6 * SIZE(AO), %xmm2
	addq	LDA, AO

	prefetcht0 PREFETCHSIZE * SIZE(AO)
	movaps	 24 * SIZE(BO), %xmm3
	mulps	%xmm0, %xmm3
	mulps	 28 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 24 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm3
	mulps	 28 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movaps	 48 * SIZE(BO), %xmm3
	addps	%xmm2, %xmm7

	addq	$32 * SIZE, BO
	decq	I
	jg	.L22
	ALIGN_3

.L23:
	movq	MIN_N, I		# i = min_n
	andq	$3,  I
	jle	.L29
	ALIGN_3

.L24:
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	movhps	  6 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	  8 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	addq	$8 * SIZE, BO
	decq	I
	jg	.L24
	ALIGN_3

.L29:
	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6
#else
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
#endif
	movaps	%xmm4, %xmm5
	movaps	%xmm6, %xmm7

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	mulps	%xmm14, %xmm6
	mulps	%xmm15, %xmm7

	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6

	movsd	 0 * SIZE(CO), %xmm0
	movhps	 0 * SIZE(CO, INCY), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy

	movsd	 0 * SIZE(CO), %xmm0
	movhps	 0 * SIZE(CO, INCY), %xmm0
	addps	%xmm0, %xmm6
	movsd	%xmm6, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy

	decq	J
	jg	.L21

.L50:
	movq	M,  J
	andq	$3, J
	cmpq	$3, J
	jne	.L60

	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movq	A, AO
	addq	$6 * SIZE, A

	movq	BUFFER, BO

	movaps	  0 * SIZE(BO), %xmm1
	movaps	 16 * SIZE(BO), %xmm3

	movq	MIN_N, I		# i = min_n
	sarq	$2,   I
	jle	.L53
	ALIGN_3

.L52:
	prefetcht0 PREFETCHSIZE * SIZE(AO)
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movhps	  2 * SIZE(AO), %xmm0
	addps	%xmm2, %xmm7

	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	  4 * SIZE(AO), %xmm2
	addq	LDA, AO

	movaps	  8 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	mulps	 12 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  8 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm1
	mulps	 12 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	 32 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	prefetchnta PREFETCHSIZE * SIZE(AO)
	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0, %xmm3
	mulps	 20 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 16 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2, %xmm3
	mulps	 20 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movhps	  2 * SIZE(AO), %xmm0
	addps	%xmm2, %xmm7

	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	  4 * SIZE(AO), %xmm2
	addq	LDA, AO

	movaps	 24 * SIZE(BO), %xmm3
	mulps	%xmm0, %xmm3
	mulps	 28 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 24 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm3
	mulps	 28 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movaps	 48 * SIZE(BO), %xmm3
	addps	%xmm2, %xmm7

	addq	$32 * SIZE, BO
	decq	I
	jg	.L52
	ALIGN_3

.L53:
	movq	MIN_N, I		# i = min_n
	andq	$3,  I
	jle	.L59
	ALIGN_3

.L54:
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0
	movsd	  4 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	  8 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	addq	$8 * SIZE, BO
	decq	I
	jg	.L54
	ALIGN_3

.L59:
	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6
#else
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
#endif
	movaps	%xmm4, %xmm5
	movaps	%xmm6, %xmm7

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	mulps	%xmm14, %xmm6
	mulps	%xmm15, %xmm7

	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6

	movsd	 0 * SIZE(CO), %xmm0
	movhps	 0 * SIZE(CO, INCY), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO		# coffset += incy

	movsd	 0 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm6
	movsd	%xmm6, 0 * SIZE(CO)
	jmp	.L99
	ALIGN_3

.L60:
	cmpq	$2, J
	jne	.L70

	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movq	BUFFER, BO

	movq	A, AO
	addq	$4 * SIZE, A

	movaps	  0 * SIZE(BO), %xmm1
	movaps	 16 * SIZE(BO), %xmm3

	movq	MIN_N, I
	sarq	$2,   I
	jle	.L63
	ALIGN_3

.L62:
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0
	addq	LDA, AO
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	  0 * SIZE(AO), %xmm2
	movhps	  2 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0,	%xmm1
	mulps	  4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	  8 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(AO), %xmm0
	mulps	%xmm2,	%xmm1
	mulps	 12 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	 32 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	prefetchnta PREFETCHSIZE * SIZE(AO)
	movhps	  2 * SIZE(AO), %xmm0
	addq	LDA, AO
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	  0 * SIZE(AO), %xmm2
	movhps	  2 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0,	%xmm3
	mulps	 20 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 24 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2,	%xmm3
	mulps	 28 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movaps	 48 * SIZE(BO), %xmm3
	addps	%xmm2, %xmm7

	addq	$32 * SIZE, BO
	decq	I
	jg	.L62
	ALIGN_3

.L63:
	movq	MIN_N, I
	andq	$3,   I
	jle	.L69
	ALIGN_3

.L64:
	movsd	  0 * SIZE(AO), %xmm0
	movhps	  2 * SIZE(AO), %xmm0

	mulps	%xmm0,	%xmm1
	addps	%xmm1, %xmm4
	movaps	  4 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5
	movaps	  8 * SIZE(BO), %xmm1

	addq	LDA, AO
	addq	$8 * SIZE, BO
	decq	I
	jg	.L64
	ALIGN_3

.L69:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	shufps	$0xb1, %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
#else
	addps	%xmm5, %xmm4
#endif
	movaps	%xmm4, %xmm5

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(CO), %xmm0
	movhps	 0 * SIZE(CO, INCY), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(CO, INCY)
	jmp	.L99
	ALIGN_3

.L70:
	cmpq	$1, J
	jne	.L99

	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movq	BUFFER, BO

	movq	A, AO
	addq	$2 * SIZE, A

	movaps	  0 * SIZE(BO), %xmm1
	movaps	 16 * SIZE(BO), %xmm3

	movq	MIN_N, I
	sarq	$2,   I
	jle	.L73
	ALIGN_3

.L72:
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	   0 * SIZE(AO), %xmm0
	addq	LDA, AO
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	   0 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0,	%xmm1
	mulps	   4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movsd	   8 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	movsd	   0 * SIZE(AO), %xmm0
	mulps	%xmm2,	%xmm1
	mulps	  12 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movsd	  32 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

	prefetchnta PREFETCHSIZE * SIZE(AO)
	addq	LDA, AO
	prefetchnta PREFETCHSIZE * SIZE(AO)
	movsd	   0 * SIZE(AO), %xmm2
	addq	LDA, AO

	mulps	%xmm0,	%xmm3
	mulps	  20 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movsd	  24 * SIZE(BO), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2,	%xmm3
	mulps	  28 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movsd	  48 * SIZE(BO), %xmm3
	addps	%xmm2, %xmm7

	addq	$32 * SIZE, BO
	decq	I
	jg	.L72
	ALIGN_3

.L73:
	movq	MIN_N, I
	andq	$3,   I
	jle	.L79
	ALIGN_3

.L74:
	movsd	 0 * SIZE(AO), %xmm0
	mulps	%xmm0,	%xmm1
	addps	%xmm1, %xmm4
	movsd	 4 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5
	movsd	 8 * SIZE(BO), %xmm1

	addq	LDA, AO
	addq	$8 * SIZE, BO
	decq	I
	jg	.L74
	ALIGN_3

.L79:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	shufps	$0xb1, %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
#else
	addps	%xmm5, %xmm4
#endif
	movaps	%xmm4, %xmm5

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	ALIGN_3

.L99:
	addq	PLDA_M, A

#ifndef PARAMTEST
	addq	$P, IS		# is += P
#else
	addq	 P, IS		# is += P
#endif
	cmpq	N,   IS
	jl	.L10
	ALIGN_3

.L999:
	EMMS

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
