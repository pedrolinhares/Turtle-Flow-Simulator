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

#define P 400

#ifdef OPTERON
#define PREFETCHSIZE 32
#endif
#ifdef PENTIUM4
#define PREFETCHSIZE 128
#endif

#ifdef GENERIC
#define PREFETCHSIZE 128
#endif

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

#undef MOVSD

#ifdef OPTERON
#define MOVSD   movlps
#else
#define MOVSD	movsd
#endif

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

	mov     N,   TEMP
	imulq	LDA, TEMP
	movq	$P,   BO
	subq	TEMP, BO

	salq	$ZBASE_SHIFT, BO
	salq	$ZBASE_SHIFT, LDA

	movq	BO, NLDA

	pxor	%xmm13,  %xmm13
	cmpeqps	%xmm13,  %xmm13
	pslld	$31,     %xmm13	# Generate mask
	pxor	%xmm12,  %xmm12
	unpcklps %xmm13, %xmm12

	shufps  $0, %xmm0, %xmm0
	shufps  $0, %xmm1, %xmm1
	pxor	%xmm12, %xmm1
	movaps	%xmm0, %xmm14
	movaps	%xmm1, %xmm15

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

	pcmpeqb	%mm7, %mm7
	pslld	$31, %mm7	

	movq	BUFFER, BO

	movq	MIN_N, I
	sarq	$2,    I
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

	movd	%mm0, 0 * SIZE(BO)
	movd	%mm0, 1 * SIZE(BO)
	movd	%mm2, 2 * SIZE(BO)
	movd	%mm2, 3 * SIZE(BO)

	movd	%mm1, 5 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1, 4 * SIZE(BO)
	movd	%mm3, 7 * SIZE(BO)
	pxor	%mm7, %mm3
	movd	%mm3, 6 * SIZE(BO)

	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X

	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0,  8 * SIZE(BO)
	movd	%mm0,  9 * SIZE(BO)
	movd	%mm2, 10 * SIZE(BO)
	movd	%mm2, 11 * SIZE(BO)

	movd	%mm1, 13 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1, 12 * SIZE(BO)
	movd	%mm3, 15 * SIZE(BO)
	pxor	%mm7, %mm3
	movd	%mm3, 14 * SIZE(BO)
#else
	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X
	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0, 0 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(BO)
	movd	%mm2, 2 * SIZE(BO)
	pxor	%mm7, %mm2
	movd	%mm2, 3 * SIZE(BO)

	movd	%mm1, 4 * SIZE(BO)
	movd	%mm1, 5 * SIZE(BO)
	movd	%mm3, 6 * SIZE(BO)
	movd	%mm3, 7 * SIZE(BO)

	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX,X

	movd	0 * SIZE(X), %mm2
	movd	1 * SIZE(X), %mm3
	addq	INCX,X

	movd	%mm0,  8 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0,  9 * SIZE(BO)
	movd	%mm2, 10 * SIZE(BO)
	pxor	%mm7, %mm2
	movd	%mm2, 11 * SIZE(BO)

	movd	%mm1, 12 * SIZE(BO)
	movd	%mm1, 13 * SIZE(BO)
	movd	%mm3, 14 * SIZE(BO)
	movd	%mm3, 15 * SIZE(BO)
#endif
	addq	$16 * SIZE, BO
	decq	I
	jg	.L11
	ALIGN_3

.L12:
	movq	MIN_N, I
	andq	$3,    I
	jle	.L20
	ALIGN_3

.L13:
	movd	0 * SIZE(X), %mm0
	movd	1 * SIZE(X), %mm1
	addq	INCX, X

#ifndef CONJ
	movd	%mm0, 0 * SIZE(BO)
	movd	%mm0, 1 * SIZE(BO)
	movd	%mm1, 3 * SIZE(BO)
	pxor	%mm7, %mm1
	movd	%mm1, 2 * SIZE(BO)
#else
	movd	%mm0, 0 * SIZE(BO)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(BO)
	movd	%mm1, 2 * SIZE(BO)
	movd	%mm1, 3 * SIZE(BO)
#endif

	addq	$4 * SIZE, BO
	decq	I
	jg	.L13
	ALIGN_3

.L20:
	movq	Y,   CO
	movq	N,   J
	sarq	$1,  J
	jle	.L50
	ALIGN_3
	
.L21:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A,   AO1
	leaq	(A, LDA, 1), AO2
	leaq	(A, LDA, 2), A

	movq	BUFFER, BO

	movaps	 0 * SIZE(BO), %xmm1
	movaps	 8 * SIZE(BO), %xmm3

	movq	MIN_N, I
	sarq	$2,   I
	jle	.L23
	ALIGN_3

.L22:
#ifdef OPTERON
	prefetcht0 PREFETCHSIZE * SIZE(AO1)
	prefetcht0 PREFETCHSIZE * SIZE(AO2)
#endif

#ifdef PENTIUM4
	prefetchnta PREFETCHSIZE * SIZE(AO1)
	prefetchnta PREFETCHSIZE * SIZE(AO2)
#endif

	MOVSD	 0 * SIZE(AO1), %xmm0
	movhps	 2 * SIZE(AO1), %xmm0
	MOVSD	 0 * SIZE(AO2), %xmm2
	movhps	 2 * SIZE(AO2), %xmm2

	mulps	%xmm0, %xmm1
	mulps	 4 * SIZE(BO), %xmm0
	addps	%xmm1, %xmm4
	movaps	 0 * SIZE(BO), %xmm1
	addps	%xmm0, %xmm5
	MOVSD	 4 * SIZE(AO1), %xmm0

	mulps	%xmm2, %xmm1
	mulps	 4 * SIZE(BO), %xmm2
	addps	%xmm1, %xmm6
	movaps	16 * SIZE(BO), %xmm1
	addps	%xmm2, %xmm7

 	movhps	 6 * SIZE(AO1), %xmm0
	addq	$8 * SIZE, AO1
	MOVSD	 4 * SIZE(AO2), %xmm2
	movhps	 6 * SIZE(AO2), %xmm2
	addq	$8 * SIZE, AO2

	mulps	%xmm0, %xmm3
	mulps	12 * SIZE(BO), %xmm0
	addps	%xmm3, %xmm4
	movaps	 8 * SIZE(BO), %xmm3

	addps	%xmm0, %xmm5

	mulps	%xmm2, %xmm3
	mulps	12 * SIZE(BO), %xmm2
	addps	%xmm3, %xmm6
	movaps	24 * SIZE(BO), %xmm3

	addps	%xmm2, %xmm7
	addq	$16 * SIZE, BO
	decq	I
	jg	.L22
	ALIGN_3

.L23:
	movq	MIN_N, I
	andq	$3,   I
	jle	.L29
	ALIGN_3

.L24:
	movsd	 0 * SIZE(AO1), %xmm0
	addq	$2 * SIZE, AO1
	movsd	 0 * SIZE(AO2), %xmm2
	addq	$2 * SIZE, AO2

	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 2 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	 0 * SIZE(BO), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movsd	 2 * SIZE(BO), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm7

	movsd	 4 * SIZE(BO), %xmm1
	addq	$4 * SIZE, BO

	decq	I
	jg	.L24
	ALIGN_3

.L29:
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4
	
	movaps	%xmm5, %xmm0
	shufps	$0xe, %xmm5, %xmm5
	addps	 %xmm0, %xmm5

	movaps	%xmm6, %xmm0
	shufps	$0xe, %xmm6, %xmm6
	addps	 %xmm0, %xmm6

	movaps	%xmm7, %xmm0
	shufps	$0xe, %xmm7, %xmm7
	addps	 %xmm0, %xmm7

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
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO

	movsd	 0 * SIZE(CO), %xmm1
	addps	%xmm1, %xmm6
	movsd	%xmm6, 0 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L21
	ALIGN_3

.L50:
	movq	N,  J
	andq	$1, J
	je	.L99

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A,   AO1
	addq	LDA, A

	movq	BUFFER, BO

	movq	MIN_N,I
	sarq	$2,  I
	jle	.L52
	ALIGN_3

.L51:
	MOVSD	 0 * SIZE(AO1), %xmm0
	movhps	 2 * SIZE(AO1), %xmm0

	movaps	 0 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movaps	 4 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	MOVSD	 4 * SIZE(AO1), %xmm0
 	movhps	 6 * SIZE(AO1), %xmm0

	movaps	 8 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movaps	12 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm7

	addq	$8 * SIZE, AO1
	addq	$16 * SIZE, BO

	decq	I
	jg	.L51
	ALIGN_3

.L52:
	movq	MIN_N,I
	andq	$3,  I
	jle	.L59
	ALIGN_3

.L53:
	MOVSD	 0 * SIZE(AO1), %xmm0
	movhps	 2 * SIZE(AO1), %xmm0

	movsd	 0 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 2 * SIZE(BO), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	addq	$2 * SIZE, AO1
	addq	$4 * SIZE, BO

	decq	I
	jg	.L53
	ALIGN_3

.L59:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5
	
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4
	
	movaps	%xmm5, %xmm0
	shufps	$0xe, %xmm5, %xmm5
	addps	 %xmm0, %xmm5

	shufps	$0xb1, %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
#else
	addps	%xmm5, %xmm4
#endif
	movaps	%xmm4, %xmm5

	mulps	%xmm14,	%xmm4
	mulps	%xmm15, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(CO)
	ALIGN_3

.L99:
	addq	NLDA, A

	addq	$P, IS
	cmpq	M,  IS
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
