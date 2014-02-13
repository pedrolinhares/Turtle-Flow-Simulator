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

#define P 800

#if defined(OPTERON) || defined(BARCELONA)
#define PREFETCHSIZE 32
#endif

#ifdef PENTIUM4
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE 80
#endif

#ifdef CORE2
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE	(8 * 5)
#endif

#ifdef PENRYN
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE	(8 * 5)
#endif

#ifdef GENERIC
#define PREFETCH	prefetcht0
#define PREFETCHW	prefetcht0
#define PREFETCHSIZE	(8 * 5)
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

#ifdef OPTERON
#define movsd   movlps
#endif
#define movhpd	movhps

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
	pshufd	$0, %xmm0, ALPHA
#else
	pshufd	$0, %xmm3, ALPHA
#endif

	testq	M, M
	jle	.L999
	testq	N, N
	jle	.L999

	movq	N,    TEMP
	imulq	LDA,  TEMP
	movq	$P,   BO
	subq	TEMP, BO

	leaq	(, BO,  SIZE), BO
	leaq	(, LDA, SIZE), LDA

	movq	BO, NLDA
	xorq	IS, IS
	ALIGN_4

.L10:
	movq	$P,   TEMP
	movq	M,    MIN_M
	subq	IS,   MIN_M
	cmpq	TEMP, MIN_M
	cmovg	TEMP, MIN_M

	movq	BUFFER, BO

	cmpq	$SIZE, INCX
	jne	.L15

	movq	MIN_M, I
	sarq	$3, I
	jle	.L13
	ALIGN_4

.L12:
	movsd	0 * SIZE(X), %xmm0
	movsd	2 * SIZE(X), %xmm2
	movsd	4 * SIZE(X), %xmm4
	movsd	6 * SIZE(X), %xmm6
	addq	$8 * SIZE, X

	movsd	%xmm0, 0 * SIZE(BO)
	movsd	%xmm2, 2 * SIZE(BO)
	movsd	%xmm4, 4 * SIZE(BO)
	movsd	%xmm6, 6 * SIZE(BO)
	addq	$8 * SIZE, BO
	decq	I
	jg	.L12
	ALIGN_4

.L13:
	movq	MIN_M, I
	andq	$7, I
	jle	.L50
	ALIGN_4

.L14:
	movss	(X), %xmm0
	addq	$SIZE, X
	movss	%xmm0, 0 * SIZE(BO)
	addq	$SIZE, BO
	decq	I
	jg	.L14
	jmp	.L50
	ALIGN_4

.L15:
	movq	MIN_M, I
	sarq	$3, I
	jle	.L17
	ALIGN_4

.L16:
	movss	(X), %xmm0
	addq	INCX, X
	movss	(X), %xmm1
	addq	INCX, X

	movss	(X), %xmm2
	addq	INCX, X
	movss	(X), %xmm3
	addq	INCX, X

	movss	(X), %xmm4
	addq	INCX, X
	movss	(X), %xmm5
	addq	INCX, X

	movss	(X), %xmm6
	addq	INCX, X
	movss	(X), %xmm7
	addq	INCX, X

	movss	%xmm0, 0 * SIZE(BO)
	movss	%xmm1, 1 * SIZE(BO)
	movss	%xmm2, 2 * SIZE(BO)
	movss	%xmm3, 3 * SIZE(BO)
	movss	%xmm4, 4 * SIZE(BO)
	movss	%xmm5, 5 * SIZE(BO)
	movss	%xmm6, 6 * SIZE(BO)
	movss	%xmm7, 7 * SIZE(BO)

	addq	$8 * SIZE, BO
	decq	I
	jg	.L16
	ALIGN_4

.L17:
	movq	MIN_M, I
	andq	$7, I
	jle	.L50
	ALIGN_2

.L18:
	movss	(X), %xmm0
	addq	INCX, X
	movss	%xmm0, 0 * SIZE(BO)
	addq	$SIZE, BO
	decq	I
	jg	.L18
	ALIGN_4

/* Main Routine */

.L50:
	movq	Y, CO			# coffset = y
	movq	N,  J
	sarq	$2, J
	jle	.L100
	ALIGN_3

.L51:
	movq	A, AO1				# a_offset = a
	leaq	(AO1, LDA   ), AO2		# a_offset2 = a + lda
	leaq	(AO1, LDA, 4), A

	movq	BUFFER, BO

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movaps	0 * SIZE(BO), %xmm0
	movaps	4 * SIZE(BO), %xmm2

	movq	MIN_M, I
	sarq	$3,  I
	jle	.L53
	ALIGN_4

.L52:
	movsd	0 * SIZE(AO1), %xmm1
	prefetcht0 PREFETCHSIZE * SIZE(AO1)
	movhpd	2 * SIZE(AO1), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	0 * SIZE(AO2), %xmm1
	movhpd	2 * SIZE(AO2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	0 * SIZE(AO1, LDA, 2), %xmm1
	prefetcht0 PREFETCHSIZE * SIZE(AO2)
	movhpd	2 * SIZE(AO1, LDA, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movsd	0 * SIZE(AO2, LDA, 2), %xmm1
	movhpd	2 * SIZE(AO2, LDA, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm7

	movaps	8 * SIZE(BO), %xmm0

	movsd	4 * SIZE(AO1), %xmm1
	prefetcht0 PREFETCHSIZE * SIZE(AO1, LDA, 2)
	movhpd	6 * SIZE(AO1), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movsd	4 * SIZE(AO2), %xmm1
	movhpd	6 * SIZE(AO2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	prefetcht0 PREFETCHSIZE * SIZE(AO2, LDA, 2)

	movsd	4 * SIZE(AO1, LDA, 2), %xmm1
	movhpd	6 * SIZE(AO1, LDA, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movsd	4 * SIZE(AO2, LDA, 2), %xmm1
	movhpd	6 * SIZE(AO2, LDA, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm7

	movaps	12 * SIZE(BO), %xmm2

	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, AO2
	addq	$8 * SIZE, BO

	decq	I
	jg	.L52
	ALIGN_4

.L53:
	movq	MIN_M, I
	andq	$7,  I
	je	.L55
	ALIGN_4

.L54:
	movss	0 * SIZE(AO1), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(AO2), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	0 * SIZE(AO1, LDA, 2), %xmm1
	addq	$SIZE, AO1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm6

	movss	0 * SIZE(AO2, LDA, 2), %xmm1
	addq	$SIZE, AO2
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm7

	movss	 1 * SIZE(BO), %xmm0
	addq	$SIZE, BO

	decq	I
	jg	.L54
	ALIGN_4

.L55:
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

	movaps	%xmm4, %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	 %xmm0, %xmm4
	
	movaps	%xmm5, %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	 %xmm0, %xmm5

	movaps	%xmm6, %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	 %xmm0, %xmm6

	movaps	%xmm7, %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	 %xmm0, %xmm7

	mulss	ALPHA, %xmm4
	mulss	ALPHA, %xmm5
	mulss	ALPHA, %xmm6
	mulss	ALPHA, %xmm7

	movq	CO, TEMP
	cmpq	$SIZE, INCY
	jne	.L56

	movss	0 * SIZE(CO), %xmm1
	movss	1 * SIZE(CO), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	2 * SIZE(CO), %xmm1
	movss	3 * SIZE(CO), %xmm2

	addss	%xmm1, %xmm6
	addss	%xmm2, %xmm7

	movss	%xmm4, 0 * SIZE(CO)
	movss	%xmm5, 1 * SIZE(CO)
	movss	%xmm6, 2 * SIZE(CO)
	movss	%xmm7, 3 * SIZE(CO)
	addq	$4 * SIZE, CO

	decq	J
	jg	.L51

 	movq	N,  J
	andq	$3, J
	jne	.L100

	jmp	.L99
	ALIGN_4

.L56:
	movss	0 * SIZE(TEMP), %xmm1
	addq	INCY, TEMP
	movss	0 * SIZE(TEMP), %xmm2
	addq	INCY, TEMP

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	0 * SIZE(TEMP), %xmm1
	addq	INCY, TEMP
	movss	0 * SIZE(TEMP), %xmm2

	addss	%xmm1, %xmm6
	addss	%xmm2, %xmm7

	movss	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm5, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm6, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm7, 0 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L51

 	movq	N,  J
	andq	$3, J
	jne	.L100

	ALIGN_4

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
	ALIGN_4

.L100:
	movq	N,  J
	andq	$3, J
	cmpq	$3, J
	jne	.L110
	ALIGN_3

.L101:
	movq	A, AO1				# a_offset = a
	leaq	(AO1, LDA   ), AO2		# a_offset2 = a + lda
	leaq	(AO2, LDA, 2), A

	movq	BUFFER, BO

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6

	movaps	0 * SIZE(BO), %xmm0
	movaps	4 * SIZE(BO), %xmm2

	movq	MIN_M, I
	sarq	$3,  I
	jle	.L103
	ALIGN_4

.L102:
	prefetchnta	56 * SIZE(AO1)
	prefetchnta	56 * SIZE(AO2)
	prefetchnta	56 * SIZE(AO1, LDA, 2)

	movsd	 0 * SIZE(AO1), %xmm1
	movhpd	 2 * SIZE(AO1), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 0 * SIZE(AO2), %xmm1
	movhpd	 2 * SIZE(AO2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	 0 * SIZE(AO1, LDA, 2), %xmm1
	movhpd	 2 * SIZE(AO1, LDA, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movaps	 8 * SIZE(BO), %xmm0

	movsd	 4 * SIZE(AO1), %xmm1
	movhpd	 6 * SIZE(AO1), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movsd	 4 * SIZE(AO2), %xmm1
	movhpd	 6 * SIZE(AO2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movsd	 4 * SIZE(AO1, LDA, 2), %xmm1
	movhpd	 6 * SIZE(AO1, LDA, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movaps	12 * SIZE(BO), %xmm2

	addq	$8 * SIZE, AO2
	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, BO

	decq	I
	jg	.L102
	ALIGN_4

.L103:
	movq	MIN_M, I
	andq	$7,  I
	je	.L105
	ALIGN_4

.L104:
	movss	0 * SIZE(AO1), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(AO2), %xmm1
	addq	$SIZE, AO2
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	0 * SIZE(AO1, LDA, 2), %xmm1
	addq	$SIZE, AO1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm6

	movss	 1 * SIZE(BO), %xmm0
	addq	$SIZE, BO

	decq	I
	jg	.L104
	ALIGN_4

.L105:
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4
	
	movaps	%xmm5, %xmm0
	shufps	$0xe, %xmm5, %xmm5
	addps	 %xmm0, %xmm5

	movaps	%xmm6, %xmm0
	shufps	$0xe, %xmm6, %xmm6
	addps	 %xmm0, %xmm6

	movaps	%xmm4, %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	 %xmm0, %xmm4

	movaps	%xmm5, %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	 %xmm0, %xmm5

	movaps	%xmm6, %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	 %xmm0, %xmm6

	mulss	ALPHA, %xmm4
	mulss	ALPHA, %xmm5
	mulss	ALPHA, %xmm6

	movq	CO, TEMP
	cmpq	$SIZE, INCY
	jne	.L106

	movss	0 * SIZE(CO), %xmm1
	movss	1 * SIZE(CO), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	2 * SIZE(CO), %xmm1

	addss	%xmm1, %xmm6

	movss	%xmm4, 0 * SIZE(CO)
	movss	%xmm5, 1 * SIZE(CO)
	movss	%xmm6, 2 * SIZE(CO)
	jmp	.L99
	ALIGN_4

.L106:
	movss	0 * SIZE(TEMP), %xmm1
	addq	INCY, TEMP
	movss	0 * SIZE(TEMP), %xmm2
	addq	INCY, TEMP

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	0 * SIZE(TEMP), %xmm1
	addss	%xmm1, %xmm6

	movss	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm5, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm6, 0 * SIZE(CO)
	jmp	.L99
	ALIGN_4

.L110:
	cmpq	$2, J
	jne	.L120
	ALIGN_3

.L111:
	movq	A, AO1				# a_offset = a
	leaq	(AO1, LDA   ), AO2		# a_offset2 = a + lda
	leaq	(AO1, LDA, 2), A

	movq	BUFFER, BO

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5

	movaps	0 * SIZE(BO), %xmm0
	movaps	4 * SIZE(BO), %xmm2

	movq	MIN_M, I
	sarq	$3,  I
	jle	.L113
	ALIGN_4

.L112:
	prefetchnta	56 * SIZE(AO1)
	prefetchnta	56 * SIZE(AO2)

	movsd	 0 * SIZE(AO1), %xmm1
	movhpd	 2 * SIZE(AO1), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 0 * SIZE(AO2), %xmm1
	movhpd	 2 * SIZE(AO2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movaps	 8 * SIZE(BO), %xmm0

	movsd	 4 * SIZE(AO1), %xmm1
	movhpd	 6 * SIZE(AO1), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movsd	 4 * SIZE(AO2), %xmm1
	movhpd	 6 * SIZE(AO2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movaps	12 * SIZE(BO), %xmm2
	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, AO2
	addq	$8 * SIZE, BO

	decq	I
	jg	.L112
	ALIGN_4

.L113:
	movq	MIN_M, I
	andq	$7,  I
	je	.L115
	ALIGN_4

.L114:
	movss	0 * SIZE(AO1), %xmm1
	addq	$SIZE, AO1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(AO2), %xmm1
	addq	$SIZE, AO2
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	 1 * SIZE(BO), %xmm0
	addq	$SIZE, BO

	decq	I
	jg	.L114
	ALIGN_4

.L115:
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4

	movaps	%xmm5, %xmm0
	shufps	$0xe, %xmm5, %xmm5
	addps	 %xmm0, %xmm5

	movaps	%xmm4, %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	 %xmm0, %xmm4

	movaps	%xmm5, %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	 %xmm0, %xmm5

	mulss	ALPHA, %xmm4
	mulss	ALPHA, %xmm5

	movq	CO, TEMP
	cmpq	$SIZE, INCY
	jne	.L116

	movss	0 * SIZE(CO), %xmm1
	movss	1 * SIZE(CO), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	%xmm4, 0 * SIZE(CO)
	movss	%xmm5, 1 * SIZE(CO)
	jmp	.L99
	ALIGN_4

.L116:
	movss	0 * SIZE(TEMP), %xmm1
	addq	INCY, TEMP
	movss	0 * SIZE(TEMP), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	%xmm4, 0 * SIZE(CO)
	addq	INCY, CO
	movss	%xmm5, 0 * SIZE(CO)
	jmp	.L99
	ALIGN_4

.L120:
	movq	A, AO1				# a_offset = a
	leaq	(AO1, LDA   ), AO2		# a_offset2 = a + lda
	leaq	(AO1, LDA, 1), A

	movq	BUFFER, BO

	pxor	%xmm4, %xmm4

	movaps	0 * SIZE(BO), %xmm0
	movaps	4 * SIZE(BO), %xmm2

	movq	MIN_M, I
	sarq	$3,  I
	jle	.L123
	ALIGN_4

.L122:
	prefetchnta	56 * SIZE(AO1)

	movsd	 0 * SIZE(AO1), %xmm1
	movhpd	 2 * SIZE(AO1), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movaps	 8 * SIZE(BO), %xmm0

	movsd	 4 * SIZE(AO1), %xmm1
	movhpd	 6 * SIZE(AO1), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movaps	12 * SIZE(BO), %xmm2

	addq	$8 * SIZE, AO1
	addq	$8 * SIZE, BO

	decq	I
	jg	.L122
	ALIGN_4

.L123:
	movq	MIN_M, I
	andq	$7,  I
	je	.L125
	ALIGN_4

.L124:
	movss	0 * SIZE(AO1), %xmm1
	addq	$SIZE, AO1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	 1 * SIZE(BO), %xmm0
	addq	$SIZE, BO

	decq	I
	jg	.L124
	ALIGN_4

.L125:
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4
	
	movaps	%xmm4, %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	 %xmm0, %xmm4

	mulss	ALPHA, %xmm4

	movss	0 * SIZE(CO), %xmm1
	addss	%xmm1, %xmm4
	movss	%xmm4, 0 * SIZE(CO)
	jmp	.L99

	EPILOGUE
