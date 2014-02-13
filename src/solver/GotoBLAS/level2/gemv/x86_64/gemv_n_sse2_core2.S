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
#define PREFETCHSIZE	32

#ifndef WINDOWS_ABI

#define STACKSIZE	64
	
#define OLD_M	  %rdi
#define OLD_N	  %rsi
#define OLD_LDA	  %r8
#define STACK_INCX	 8 + STACKSIZE(%rsp)
#define STACK_Y		16 + STACKSIZE(%rsp)
#define STACK_INCY	24 + STACKSIZE(%rsp)
#define STACK_BUFFER	32 + STACKSIZE(%rsp)
#define STACK_ALPHA	48	      (%rsp)

#else

#define STACKSIZE	256
	
#define OLD_M	  %rcx
#define OLD_N	  %rdx
#define OLD_A		 40 + STACKSIZE(%rsp)
#define OLD_LDA		 48 + STACKSIZE(%rsp)
#define OLD_X		 56 + STACKSIZE(%rsp)
#define STACK_INCX	 64 + STACKSIZE(%rsp)
#define STACK_Y		 72 + STACKSIZE(%rsp)
#define STACK_INCY	 80 + STACKSIZE(%rsp)
#define STACK_BUFFER	 88 + STACKSIZE(%rsp)
#define STACK_ALPHA	224	       (%rsp)

#endif

#define M	  %r12
#define N	  %r13
#define A	  %rcx
#define LDA	  %rbx
#define X	  %r9
#define INCX	  %rdx
#define Y	  %r14
#define INCY	  %r10

#define TEMP	%rax
#define I	%rax
#define J	%r11
#define A1	%rdi
#define A2	%rsi

#define Y1	%rbp
#define BUFFER	%r15
#define MM	%r8	


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

	movq	OLD_M,	      M
	movq	OLD_N,        N
	movq	OLD_A,        A
	movq	OLD_LDA,      LDA
	movq	OLD_X,        X
#else
	movq	OLD_M,	      M
	movq	OLD_N,        N
	movq	OLD_LDA,      LDA
#endif

	movq	STACK_INCX,   INCX
	movq	STACK_Y,      Y
	movq	STACK_INCY,   INCY
	movq	STACK_BUFFER, BUFFER

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

	movq	BUFFER, Y1

	movq	M, MM
	movq	BUFFER, %rax
	decq	MM
	addq	$1 * SIZE, BUFFER
	testq	$SIZE, A
	cmoveq	M, MM
	cmoveq	%rax, BUFFER

	pxor	%xmm4, %xmm4

	movq	M,  %rax
	addq	$8, %rax
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
	subq	$-16 * SIZE, A
	
	testq	$SIZE, LDA
	jne	.L40

	movq	N,  J
	sarq	$2, J
	jle	.L20
	ALIGN_3

.L11:
	leaq	16 * SIZE(BUFFER), Y1
	movq	A,  A1
	leaq	(A,  LDA, 1), A2
	leaq	(A,  LDA, 4), A

	movsd	(X), %xmm12
	addq	INCX, X
	movsd	(X), %xmm13
	addq	INCX, X
	movsd	(X), %xmm14
	addq	INCX, X
	movsd	(X), %xmm15
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm12
	mulsd	STACK_ALPHA, %xmm13
	mulsd	STACK_ALPHA, %xmm14
	mulsd	STACK_ALPHA, %xmm15

	unpcklpd %xmm12, %xmm12
	unpcklpd %xmm13, %xmm13
	unpcklpd %xmm14, %xmm14
	unpcklpd %xmm15, %xmm15
	ALIGN_3

	testq	$SIZE, A
	je	.L12

	movsd	 -16 * SIZE(Y1), %xmm0

	movsd	 -16 * SIZE(A1), %xmm4
	movsd	 -16 * SIZE(A2), %xmm5
	movsd	 -16 * SIZE(A1, LDA, 2), %xmm6
	movsd	 -16 * SIZE(A2, LDA, 2), %xmm7

	mulsd	 %xmm12, %xmm4
	mulsd	 %xmm13, %xmm5
	mulsd	 %xmm14, %xmm6
	mulsd	 %xmm15, %xmm7

	addsd	 %xmm4,  %xmm0
	addsd	 %xmm5,  %xmm0
	addsd	 %xmm6,  %xmm0
	addsd	 %xmm7,  %xmm0

	movsd	 %xmm0, -16 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L12:
	movq	MM,  I
	sarq	$4, I
	jle	.L15

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1
	movapd	 -12 * SIZE(Y1), %xmm2
	movapd	 -10 * SIZE(Y1), %xmm3
	movapd	  -8 * SIZE(Y1), %xmm4
	movapd	  -6 * SIZE(Y1), %xmm5
	movapd	  -4 * SIZE(Y1), %xmm6
	movapd	  -2 * SIZE(Y1), %xmm7

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	decq	 I
	jle	 .L14
	ALIGN_3

.L13:
	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A1), %xmm8
	movapd	 -6 * SIZE(A1), %xmm9
	movapd	 -4 * SIZE(A1), %xmm10
	movapd	 -2 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	 -16 * SIZE(A2), %xmm8
	movapd	 -14 * SIZE(A2), %xmm9
	movapd	 -12 * SIZE(A2), %xmm10
	movapd	 -10 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A2), %xmm8
	movapd	 -6 * SIZE(A2), %xmm9
	movapd	 -4 * SIZE(A2), %xmm10
	movapd	 -2 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm4
	addpd	 %xmm9, %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm14, %xmm10
	mulpd	 %xmm14, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A1, LDA, 2), %xmm8
	movapd	 -6 * SIZE(A1, LDA, 2), %xmm9
	movapd	 -4 * SIZE(A1, LDA, 2), %xmm10
	movapd	 -2 * SIZE(A1, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm14, %xmm10
	mulpd	 %xmm14, %xmm11

	addpd	 %xmm8, %xmm4
	addpd	 %xmm9, %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	-16 * SIZE(A2, LDA, 2), %xmm8
	movapd	-14 * SIZE(A2, LDA, 2), %xmm9
	movapd	-12 * SIZE(A2, LDA, 2), %xmm10
	movapd	-10 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm15, %xmm8
	mulpd	 %xmm15, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A2, LDA, 2), %xmm8
	movapd	 -6 * SIZE(A2, LDA, 2), %xmm9
	movapd	 -4 * SIZE(A2, LDA, 2), %xmm10
	movapd	 -2 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm15, %xmm8
	mulpd	 %xmm15, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	movapd	   0 * SIZE(Y1), %xmm0
	movapd	   2 * SIZE(Y1), %xmm1
	movapd	   4 * SIZE(Y1), %xmm2
	movapd	   6 * SIZE(Y1), %xmm3

	movapd	 %xmm4, -8 * SIZE(Y1)
	movapd	 %xmm5, -6 * SIZE(Y1)
	movapd	 %xmm6, -4 * SIZE(Y1)
	movapd	 %xmm7, -2 * SIZE(Y1)

	movapd	   8 * SIZE(Y1), %xmm4
	movapd	  10 * SIZE(Y1), %xmm5
	movapd	  12 * SIZE(Y1), %xmm6
	movapd	  14 * SIZE(Y1), %xmm7

	movapd	   0 * SIZE(A1), %xmm8
	movapd	   2 * SIZE(A1), %xmm9
	movapd	   4 * SIZE(A1), %xmm10
	movapd	   6 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1

	subq	 $1, I
	jg,pt	.L13
	ALIGN_3

.L14:
	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A1), %xmm8
	movapd	 -6 * SIZE(A1), %xmm9
	movapd	 -4 * SIZE(A1), %xmm10
	movapd	 -2 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	 -16 * SIZE(A2), %xmm8
	movapd	 -14 * SIZE(A2), %xmm9
	movapd	 -12 * SIZE(A2), %xmm10
	movapd	 -10 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A2), %xmm8
	movapd	 -6 * SIZE(A2), %xmm9
	movapd	 -4 * SIZE(A2), %xmm10
	movapd	 -2 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm4
	addpd	 %xmm9, %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm14, %xmm10
	mulpd	 %xmm14, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A1, LDA, 2), %xmm8
	movapd	 -6 * SIZE(A1, LDA, 2), %xmm9
	movapd	 -4 * SIZE(A1, LDA, 2), %xmm10
	movapd	 -2 * SIZE(A1, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm14, %xmm10
	mulpd	 %xmm14, %xmm11

	addpd	 %xmm8, %xmm4
	addpd	 %xmm9, %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	-16 * SIZE(A2, LDA, 2), %xmm8
	movapd	-14 * SIZE(A2, LDA, 2), %xmm9
	movapd	-12 * SIZE(A2, LDA, 2), %xmm10
	movapd	-10 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm15, %xmm8
	mulpd	 %xmm15, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A2, LDA, 2), %xmm8
	movapd	 -6 * SIZE(A2, LDA, 2), %xmm9
	movapd	 -4 * SIZE(A2, LDA, 2), %xmm10
	movapd	 -2 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm15, %xmm8
	mulpd	 %xmm15, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	movapd	 %xmm4, -8 * SIZE(Y1)
	movapd	 %xmm5, -6 * SIZE(Y1)
	movapd	 %xmm6, -4 * SIZE(Y1)
	movapd	 %xmm7, -2 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1
	ALIGN_3

.L15:
	testq	$8, MM
	je	.L16

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1
	movapd	 -12 * SIZE(Y1), %xmm2
	movapd	 -10 * SIZE(Y1), %xmm3

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -16 * SIZE(A2), %xmm8
	movapd	 -14 * SIZE(A2), %xmm9
	movapd	 -12 * SIZE(A2), %xmm10
	movapd	 -10 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm14, %xmm10
	mulpd	 %xmm14, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	-16 * SIZE(A2, LDA, 2), %xmm8
	movapd	-14 * SIZE(A2, LDA, 2), %xmm9
	movapd	-12 * SIZE(A2, LDA, 2), %xmm10
	movapd	-10 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm15, %xmm8
	mulpd	 %xmm15, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L16:
	testq	$4, MM
	je	.L17

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -16 * SIZE(A2), %xmm10
	movapd	 -14 * SIZE(A2), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm0
	addpd	 %xmm11, %xmm1

	movapd	 -16 * SIZE(A1, LDA, 2), %xmm8
	movapd	 -14 * SIZE(A1, LDA, 2), %xmm9
	movapd	 -16 * SIZE(A2, LDA, 2), %xmm10
	movapd	 -14 * SIZE(A2, LDA, 2), %xmm11

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm14, %xmm9
	mulpd	 %xmm15, %xmm10
	mulpd	 %xmm15, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm0
	addpd	 %xmm11, %xmm1

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L17:
	testq	$2, MM
	je	.L18

	movapd	 -16 * SIZE(Y1), %xmm0

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -16 * SIZE(A2), %xmm10

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm13, %xmm10

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm10, %xmm0

	movapd	 -16 * SIZE(A1, LDA, 2), %xmm8
	movapd	 -16 * SIZE(A2, LDA, 2), %xmm10

	mulpd	 %xmm14, %xmm8
	mulpd	 %xmm15, %xmm10

	addpd	 %xmm8, %xmm0
	addpd	 %xmm10, %xmm0

	movapd	 %xmm0, -16 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L18:
	testq	$1, MM
	je	.L19

	movsd	 -16 * SIZE(Y1), %xmm0

	movsd	 -16 * SIZE(A1), %xmm8
	movsd	 -16 * SIZE(A2), %xmm9
	movsd	 -16 * SIZE(A1, LDA, 2), %xmm10
	movsd	 -16 * SIZE(A2, LDA, 2), %xmm11

	mulsd	 %xmm12, %xmm8
	mulsd	 %xmm13, %xmm9
	mulsd	 %xmm14, %xmm10
	mulsd	 %xmm15, %xmm11

	addsd	 %xmm8,  %xmm0
	addsd	 %xmm9,  %xmm0
	addsd	 %xmm10, %xmm0
	addsd	 %xmm11, %xmm0

	movsd	 %xmm0, -16 * SIZE(Y1)

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

	leaq	16 * SIZE(BUFFER), Y1
	movq	A,  A1
	leaq	(A, LDA, 1), A2
	leaq	(A, LDA, 2), A

	movsd	(X), %xmm12
	addq	INCX, X
	movsd	(X), %xmm13
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm12
	mulsd	STACK_ALPHA, %xmm13

	unpcklpd %xmm12, %xmm12
	unpcklpd %xmm13, %xmm13

	testq	$SIZE, A
	je	.L22

	movsd	 -16 * SIZE(Y1), %xmm0
	movsd	 -16 * SIZE(A1), %xmm8
	movsd	 -16 * SIZE(A2), %xmm9

	mulsd	 %xmm12, %xmm8
	mulsd	 %xmm13, %xmm9
	addsd	 %xmm8,  %xmm0
	addsd	 %xmm9,  %xmm0

	movsd	 %xmm0, -16 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L22:
	movq	MM,  I
	sarq	$4, I
	jle	.L25
	ALIGN_3

.L23:
	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1
	movapd	 -12 * SIZE(Y1), %xmm2
	movapd	 -10 * SIZE(Y1), %xmm3

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -16 * SIZE(A2), %xmm8
	movapd	 -14 * SIZE(A2), %xmm9
	movapd	 -12 * SIZE(A2), %xmm10
	movapd	 -10 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	movapd	-8 * SIZE(Y1), %xmm0
	movapd	-6 * SIZE(Y1), %xmm1
	movapd	-4 * SIZE(Y1), %xmm2
	movapd	-2 * SIZE(Y1), %xmm3

	movapd	 -8 * SIZE(A1), %xmm8
	movapd	 -6 * SIZE(A1), %xmm9
	movapd	 -4 * SIZE(A1), %xmm10
	movapd	 -2 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -8 * SIZE(A2), %xmm8
	movapd	 -6 * SIZE(A2), %xmm9
	movapd	 -4 * SIZE(A2), %xmm10
	movapd	 -2 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -8 * SIZE(Y1)
	movapd	 %xmm1, -6 * SIZE(Y1)
	movapd	 %xmm2, -4 * SIZE(Y1)
	movapd	 %xmm3, -2 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1

	subq	 $1, I
	jg	.L23
	ALIGN_3

.L25:
	testq	$8, MM
	je	.L26

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1
	movapd	 -12 * SIZE(Y1), %xmm2
	movapd	 -10 * SIZE(Y1), %xmm3

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 -16 * SIZE(A2), %xmm8
	movapd	 -14 * SIZE(A2), %xmm9
	movapd	 -12 * SIZE(A2), %xmm10
	movapd	 -10 * SIZE(A2), %xmm11

	mulpd	 %xmm13, %xmm8
	mulpd	 %xmm13, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8, %xmm0
	addpd	 %xmm9, %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L26:
	testq	$4, MM
	je	.L27

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -16 * SIZE(A2), %xmm10
	movapd	 -14 * SIZE(A2), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm13, %xmm10
	mulpd	 %xmm13, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm0
	addpd	 %xmm11, %xmm1

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L27:
	testq	$2, MM
	je	.L28

	movapd	 -16 * SIZE(Y1), %xmm0

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -16 * SIZE(A2), %xmm10

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm13, %xmm10

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm10, %xmm0

	movapd	 %xmm0, -16 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L28:
	testq	$1, MM
	je	.L30

	movsd	-16 * SIZE(Y1), %xmm0

	movsd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm9

	mulsd	 %xmm12, %xmm8
	mulsd	 %xmm13, %xmm9

	addsd	 %xmm8,  %xmm0
	addsd	 %xmm9,  %xmm0

	movsd	 %xmm0, -16 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L30:
	testq	$1, N
	je	.L990

	leaq	16 * SIZE(BUFFER), Y1
	movq	A,  A1

	movsd	(X), %xmm12
	mulsd	STACK_ALPHA, %xmm12
	unpcklpd %xmm12, %xmm12

	testq	$SIZE, A
	je	.L32

	movsd	 -16 * SIZE(Y1), %xmm0
	movsd	 -16 * SIZE(A1), %xmm8
	mulsd	 %xmm12, %xmm8
	addsd	 %xmm8,  %xmm0
	movsd	 %xmm0, -16 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L32:
	movq	MM,  I
	sarq	$4, I
	jle	.L35
	ALIGN_3

.L33:
	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -14 * SIZE(Y1), %xmm1
	movapd	 -12 * SIZE(Y1), %xmm2
	movapd	 -10 * SIZE(Y1), %xmm3

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	movapd	-8 * SIZE(Y1), %xmm0
	movapd	-6 * SIZE(Y1), %xmm1
	movapd	-4 * SIZE(Y1), %xmm2
	movapd	-2 * SIZE(Y1), %xmm3

	movapd	 -8 * SIZE(A1), %xmm8
	movapd	 -6 * SIZE(A1), %xmm9
	movapd	 -4 * SIZE(A1), %xmm10
	movapd	 -2 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -8 * SIZE(Y1)
	movapd	 %xmm1, -6 * SIZE(Y1)
	movapd	 %xmm2, -4 * SIZE(Y1)
	movapd	 %xmm3, -2 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, Y1
	decq	 I
	jg	.L33
	ALIGN_3

.L35:
	testq	$8, MM
	je	.L36

	movapd	-16 * SIZE(Y1), %xmm0
	movapd	-14 * SIZE(Y1), %xmm1
	movapd	-12 * SIZE(Y1), %xmm2
	movapd	-10 * SIZE(Y1), %xmm3

	movapd	 -16 * SIZE(A1), %xmm8
	movapd	 -14 * SIZE(A1), %xmm9
	movapd	 -12 * SIZE(A1), %xmm10
	movapd	 -10 * SIZE(A1), %xmm11

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	mulpd	 %xmm12, %xmm10
	mulpd	 %xmm12, %xmm11

	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1
	addpd	 %xmm10, %xmm2
	addpd	 %xmm11, %xmm3

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)
	movapd	 %xmm2, -12 * SIZE(Y1)
	movapd	 %xmm3, -10 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L36:
	testq	$4, MM
	je	.L37

	movapd	-16 * SIZE(Y1), %xmm0
	movapd	-14 * SIZE(Y1), %xmm1

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9

	mulpd	 %xmm12, %xmm8
	mulpd	 %xmm12, %xmm9
	addpd	 %xmm8,  %xmm0
	addpd	 %xmm9,  %xmm1

	movapd	 %xmm0, -16 * SIZE(Y1)
	movapd	 %xmm1, -14 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L37:
	testq	$2, MM
	je	.L38

	movapd	 -16 * SIZE(Y1), %xmm0
	movapd	 -16 * SIZE(A1), %xmm8
	mulpd	 %xmm12, %xmm8
	addpd	 %xmm8,  %xmm0
	movapd	 %xmm0, -16 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L38:
	testq	$1, MM
	je	.L990

	movsd	 -16 * SIZE(Y1), %xmm0
	movsd	 -16 * SIZE(A1), %xmm8
	mulsd	 %xmm12, %xmm8
	addsd	 %xmm8,  %xmm0
	movsd	 %xmm0, -16 * SIZE(Y1)
	jmp	 .L990
	ALIGN_3

.L40:
	movq	N,  J
	sarq	$2, J
	jle	.L50
	ALIGN_3

.L41:
	movq	BUFFER, Y1
	movq	A,  A1
	leaq	(A, LDA, 1), A2
	leaq	(A, LDA, 4), A

	movsd	(X), %xmm0
	addq	INCX, X
	movsd	(X), %xmm1
	addq	INCX, X
	movsd	(X), %xmm2
	addq	INCX, X
	movsd	(X), %xmm3
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm0
	mulsd	STACK_ALPHA, %xmm1
	mulsd	STACK_ALPHA, %xmm2
	mulsd	STACK_ALPHA, %xmm3

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1
	unpcklpd %xmm2, %xmm2
	unpcklpd %xmm3, %xmm3
	ALIGN_3

	testq	$SIZE, A
	je	.L42

	movsd	 0 * SIZE(Y1), %xmm12
	movsd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm9
	movsd	-16 * SIZE(A1, LDA, 2), %xmm10
	movsd	-16 * SIZE(A2, LDA, 2), %xmm11

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9
	mulsd	 %xmm2, %xmm10
	mulsd	 %xmm3, %xmm11

	addsd	 %xmm8,  %xmm12
	addsd	 %xmm9,  %xmm12
	addsd	 %xmm10, %xmm12
	addsd	 %xmm11, %xmm12

	movsd	 %xmm12, 0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L42:
	movq	MM,  I
	sarq	$4, I
	jle	.L45

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	movsd	-16 * SIZE(A2), %xmm12
	movhpd	-15 * SIZE(A2), %xmm12
	movsd	-14 * SIZE(A2), %xmm13
	movhpd	-13 * SIZE(A2), %xmm13
	movsd	-12 * SIZE(A2), %xmm14
	movhpd	-11 * SIZE(A2), %xmm14
	movsd	-10 * SIZE(A2), %xmm15
	movhpd	 -9 * SIZE(A2), %xmm15

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	decq	 I
	jle	 .L44
	ALIGN_3

.L43:
	addpd	 %xmm8,  %xmm4
	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-16 * SIZE(A2, LDA, 2), %xmm12
	movhpd	-15 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-14 * SIZE(A2, LDA, 2), %xmm13
	movhpd	-13 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-12 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-11 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-10 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 -9 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	movapd	 -8 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	 -6 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	 -4 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	 -2 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	 -8 * SIZE(A2), %xmm12
	movhpd	 -7 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	 -6 * SIZE(A2), %xmm13
	movhpd	 -5 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	 -4 * SIZE(A2), %xmm14
	movhpd	 -3 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	 -2 * SIZE(A2), %xmm15
	movhpd	 -1 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	movapd	 -8 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	 -6 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	 -4 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	 -2 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	 -8 * SIZE(A2, LDA, 2), %xmm12
	movhpd	 -7 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	 -6 * SIZE(A2, LDA, 2), %xmm13
	movhpd	 -5 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	 -4 * SIZE(A2, LDA, 2), %xmm14
	movhpd	 -3 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	 -2 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 -1 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	movapd	  0 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	  2 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	  4 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	  6 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	  0 * SIZE(A2), %xmm12
	movhpd	  1 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	  2 * SIZE(A2), %xmm13
	movhpd	  3 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	  4 * SIZE(A2), %xmm14
	movhpd	  5 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	  6 * SIZE(A2), %xmm15
	movhpd	  7 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	16 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	18 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	20 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 14 * SIZE(Y1)
	movapd	22 * SIZE(Y1), %xmm7

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1
	decq	 I
	jg	.L43
	ALIGN_3

.L44:
	addpd	 %xmm8,  %xmm4
	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-16 * SIZE(A2, LDA, 2), %xmm12
	movhpd	-15 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-14 * SIZE(A2, LDA, 2), %xmm13
	movhpd	-13 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-12 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-11 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-10 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 -9 * SIZE(A2, LDA, 2), %xmm15
	mulpd	 %xmm2, %xmm11

	addpd	 %xmm8,  %xmm4
	movapd	 -8 * SIZE(A1), %xmm8
	mulpd	 %xmm3, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	 -6 * SIZE(A1), %xmm9
	mulpd	 %xmm3, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	 -4 * SIZE(A1), %xmm10
	mulpd	 %xmm3, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	 -2 * SIZE(A1), %xmm11
	mulpd	 %xmm3, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	 -8 * SIZE(A2), %xmm12
	movhpd	 -7 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	 -6 * SIZE(A2), %xmm13
	movhpd	 -5 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-4 * SIZE(A2), %xmm14
	movhpd	-3 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-2 * SIZE(A2), %xmm15
	movhpd	-1 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	movapd	-8 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-6 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-4 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-2 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-8 * SIZE(A2, LDA, 2), %xmm12
	movhpd	-7 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-6 * SIZE(A2, LDA, 2), %xmm13
	movhpd	-5 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-4 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-3 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-2 * SIZE(A2, LDA, 2), %xmm15
	movhpd	-1 * SIZE(A2, LDA, 2), %xmm15
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

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	 %xmm7, 14 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1
	ALIGN_3

.L45:
	testq	$8, MM
	je	.L46

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	movsd	-16 * SIZE(A2), %xmm12
	movhpd	-15 * SIZE(A2), %xmm12
	movsd	-14 * SIZE(A2), %xmm13
	movhpd	-13 * SIZE(A2), %xmm13
	movsd	-12 * SIZE(A2), %xmm14
	movhpd	-11 * SIZE(A2), %xmm14
	movsd	-10 * SIZE(A2), %xmm15
	movhpd	 -9 * SIZE(A2), %xmm15

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	addpd	 %xmm8,  %xmm4
	movapd	-16 * SIZE(A1, LDA, 2), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-14 * SIZE(A1, LDA, 2), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-12 * SIZE(A1, LDA, 2), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-10 * SIZE(A1, LDA, 2), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-16 * SIZE(A2, LDA, 2), %xmm12
	movhpd	-15 * SIZE(A2, LDA, 2), %xmm12
	mulpd	 %xmm2, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-14 * SIZE(A2, LDA, 2), %xmm13
	movhpd	-13 * SIZE(A2, LDA, 2), %xmm13
	mulpd	 %xmm2, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-12 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-11 * SIZE(A2, LDA, 2), %xmm14
	mulpd	 %xmm2, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-10 * SIZE(A2, LDA, 2), %xmm15
	movhpd	 -9 * SIZE(A2, LDA, 2), %xmm15
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

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	 %xmm7, 6 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L46:
	testq	$4, MM
	je	.L47

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movsd	-16 * SIZE(A2), %xmm10
	movhpd	-15 * SIZE(A2), %xmm10
	movsd	-14 * SIZE(A2), %xmm11
	movhpd	-13 * SIZE(A2), %xmm11
	movapd	-16 * SIZE(A1, LDA, 2), %xmm12
	movapd	-14 * SIZE(A1, LDA, 2), %xmm13
	movsd	-16 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-15 * SIZE(A2, LDA, 2), %xmm14
	movsd	-14 * SIZE(A2, LDA, 2), %xmm15
	movhpd	-13 * SIZE(A2, LDA, 2), %xmm15

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

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L47:
	testq	$2, MM
	je	.L48

	movapd	 0 * SIZE(Y1), %xmm4

	movapd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm10
	movhpd	-15 * SIZE(A2), %xmm10
	movapd	-16 * SIZE(A1, LDA, 2), %xmm12
	movsd	-16 * SIZE(A2, LDA, 2), %xmm14
	movhpd	-15 * SIZE(A2, LDA, 2), %xmm14

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm10
	mulpd	 %xmm2, %xmm12
	mulpd	 %xmm3, %xmm14

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm10, %xmm4
	addpd	 %xmm12, %xmm4
	addpd	 %xmm14, %xmm4

	movapd	 %xmm4, 0 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L48:
	testq	$1, MM
	je	.L49

	movsd	 0 * SIZE(Y1), %xmm4

	movsd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm9
	movsd	-16 * SIZE(A1, LDA, 2), %xmm10
	movsd	-16 * SIZE(A2, LDA, 2), %xmm11

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9
	mulsd	 %xmm2, %xmm10
	mulsd	 %xmm3, %xmm11

	addsd	 %xmm8,  %xmm4
	addsd	 %xmm9,  %xmm4
	addsd	 %xmm10, %xmm4
	addsd	 %xmm11, %xmm4

	movsd	 %xmm4, 0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L49:
	decq	J
	jg	.L41
	ALIGN_3

.L50:
	testq	$2, N
	je	.L60

	movq	BUFFER, Y1
	movq	A,  A1
	leaq	(A, LDA, 1), A2
	leaq	(A, LDA, 2), A

	movsd	(X), %xmm0
	addq	INCX, X
	movsd	(X), %xmm1
	addq	INCX, X

	mulsd	STACK_ALPHA, %xmm0
	mulsd	STACK_ALPHA, %xmm1

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1

	testq	$SIZE, A
	je	.L52

	movsd	 (Y1), %xmm4
	movsd	 -16 * SIZE(A1), %xmm8
	movsd	 -16 * SIZE(A2), %xmm9

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9
	addsd	 %xmm8,  %xmm4
	addsd	 %xmm9,  %xmm4

	movsd	 %xmm4, 0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L52:
	movq	MM,  I
	sarq	$4, I
	jle	.L55

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	movsd	-16 * SIZE(A2), %xmm12
	movhpd	-15 * SIZE(A2), %xmm12
	movsd	-14 * SIZE(A2), %xmm13
	movhpd	-13 * SIZE(A2), %xmm13
	movsd	-12 * SIZE(A2), %xmm14
	movhpd	-11 * SIZE(A2), %xmm14
	movsd	-10 * SIZE(A2), %xmm15
	movhpd	 -9 * SIZE(A2), %xmm15

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	decq	 I
	jle	 .L54
	ALIGN_3

.L53:
	addpd	 %xmm8,  %xmm4
	movapd	-8 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-6 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-4 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-2 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-8 * SIZE(A2), %xmm12
	movhpd	-7 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-6 * SIZE(A2), %xmm13
	movhpd	-5 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-4 * SIZE(A2), %xmm14
	movhpd	-3 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-2 * SIZE(A2), %xmm15
	movhpd	-1 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm8,  %xmm4
	movapd	  0 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	  2 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	  4 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	  6 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	  0 * SIZE(A2), %xmm12
	movhpd	  1 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	  2 * SIZE(A2), %xmm13
	movhpd	  3 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	  4 * SIZE(A2), %xmm14
	movhpd	  5 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	  6 * SIZE(A2), %xmm15
	movhpd	  7 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	16 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	18 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	20 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 14 * SIZE(Y1)
	movapd	22 * SIZE(Y1), %xmm7

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	subq	 $-16 * SIZE, Y1
	decq	 I
	jg	.L53
	ALIGN_3

.L54:
	addpd	 %xmm8,  %xmm4
	movapd	-8 * SIZE(A1), %xmm8
	mulpd	 %xmm1, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	-6 * SIZE(A1), %xmm9
	mulpd	 %xmm1, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	-4 * SIZE(A1), %xmm10
	mulpd	 %xmm1, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	-2 * SIZE(A1), %xmm11
	mulpd	 %xmm1, %xmm15

	addpd	 %xmm12, %xmm4
	movsd	-8 * SIZE(A2), %xmm12
	movhpd	-7 * SIZE(A2), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movsd	-6 * SIZE(A2), %xmm13
	movhpd	-5 * SIZE(A2), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movsd	-4 * SIZE(A2), %xmm14
	movhpd	-3 * SIZE(A2), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movsd	-2 * SIZE(A2), %xmm15
	movhpd	-1 * SIZE(A2), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

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

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	 %xmm7, 14 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, A2
	addq	 $16 * SIZE, Y1
	ALIGN_3

.L55:
	testq	$8, MM
	je	.L56

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	movsd	-16 * SIZE(A2), %xmm12
	movhpd	-15 * SIZE(A2), %xmm12
	movsd	-14 * SIZE(A2), %xmm13
	movhpd	-13 * SIZE(A2), %xmm13
	movsd	-12 * SIZE(A2), %xmm14
	movhpd	-11 * SIZE(A2), %xmm14
	movsd	-10 * SIZE(A2), %xmm15
	movhpd	 -9 * SIZE(A2), %xmm15

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

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	 %xmm7, 6 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, A2
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L56:
	testq	$4, MM
	je	.L57

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movsd	-16 * SIZE(A2), %xmm10
	movhpd	-15 * SIZE(A2), %xmm10
	movsd	-14 * SIZE(A2), %xmm11
	movhpd	-13 * SIZE(A2), %xmm11

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm1, %xmm10
	mulpd	 %xmm1, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm4
	addpd	 %xmm11, %xmm5

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, A2
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L57:
	testq	$2, MM
	je	.L58

	movapd	 0 * SIZE(Y1), %xmm4

	movapd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm10
	movhpd	-15 * SIZE(A2), %xmm10

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm1, %xmm10

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm10, %xmm4

	movapd	 %xmm4, 0 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, A2
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L58:
	testq	$1, MM
	je	.L30

	movsd	 0 * SIZE(Y1), %xmm4

	movsd	-16 * SIZE(A1), %xmm8
	movsd	-16 * SIZE(A2), %xmm9

	mulsd	 %xmm0, %xmm8
	mulsd	 %xmm1, %xmm9

	addsd	 %xmm8,  %xmm4
	addsd	 %xmm9,  %xmm4

	movsd	 %xmm4, 0 * SIZE(Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L60:
	testq	$1, N
	je	.L990

	movq	BUFFER, Y1
	movq	A,  A1

	movsd	(X), %xmm0
	mulsd	STACK_ALPHA, %xmm0
	unpcklpd %xmm0, %xmm0

	testq	$SIZE, A
	je	.L62

	movsd	 (Y1), %xmm4
	movsd	 -16 * SIZE(A1), %xmm8
	mulsd	 %xmm0, %xmm8
	addsd	 %xmm8,  %xmm4
	movsd	 %xmm4, (Y1)

	addq	 $1 * SIZE, A1
	addq	 $1 * SIZE, A2
	addq	 $1 * SIZE, Y1
	ALIGN_3

.L62:
	movq	MM,  I
	sarq	$4, I
	jle	.L65

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	movapd	 -8 * SIZE(A1), %xmm12
	mulpd	 %xmm0, %xmm8
	movapd	 -6 * SIZE(A1), %xmm13
	mulpd	 %xmm0, %xmm9
	movapd	 -4 * SIZE(A1), %xmm14
	mulpd	 %xmm0, %xmm10
	movapd	 -2 * SIZE(A1), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	decq	 I
	jle	 .L64
	ALIGN_3

.L63:
	addpd	 %xmm8,  %xmm4
	movapd	 0 * SIZE(A1), %xmm8
	mulpd	 %xmm0, %xmm12
	addpd	 %xmm9,  %xmm5
	movapd	 2 * SIZE(A1), %xmm9
	mulpd	 %xmm0, %xmm13

	addpd	 %xmm10, %xmm6
	movapd	 4 * SIZE(A1), %xmm10
	mulpd	 %xmm0, %xmm14
	addpd	 %xmm11, %xmm7
	movapd	 6 * SIZE(A1), %xmm11
	mulpd	 %xmm0, %xmm15

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm12, %xmm4
	movapd	 8 * SIZE(A1), %xmm12
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm13, %xmm5
	movapd	10 * SIZE(A1), %xmm13
	mulpd	 %xmm0, %xmm9

	addpd	 %xmm14, %xmm6
	movapd	12 * SIZE(A1), %xmm14
	mulpd	 %xmm0, %xmm10
	addpd	 %xmm15, %xmm7
	movapd	14 * SIZE(A1), %xmm15
	mulpd	 %xmm0, %xmm11

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	16 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	18 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	20 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 14 * SIZE(Y1)
	movapd	22 * SIZE(Y1), %xmm7

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, Y1
	decq	 I
	jg	.L63
	ALIGN_3

.L64:
	addpd	 %xmm8,  %xmm4
	mulpd	 %xmm0, %xmm12
	addpd	 %xmm9,  %xmm5
	mulpd	 %xmm0, %xmm13

	addpd	 %xmm10, %xmm6
	mulpd	 %xmm0, %xmm14
	addpd	 %xmm11, %xmm7
	mulpd	 %xmm0, %xmm15

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 8 * SIZE(Y1), %xmm4
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	10 * SIZE(Y1), %xmm5
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	12 * SIZE(Y1), %xmm6
	movapd	 %xmm7, 6 * SIZE(Y1)
	movapd	14 * SIZE(Y1), %xmm7

	addpd	 %xmm12, %xmm4
	addpd	 %xmm13, %xmm5
	addpd	 %xmm14, %xmm6
	addpd	 %xmm15, %xmm7

	movapd	 %xmm4,  8 * SIZE(Y1)
	movapd	 %xmm5, 10 * SIZE(Y1)
	movapd	 %xmm6, 12 * SIZE(Y1)
	movapd	 %xmm7, 14 * SIZE(Y1)

	subq	 $-16 * SIZE, A1
	subq	 $-16 * SIZE, Y1
	ALIGN_3

.L65:
	testq	$8, MM
	je	.L66

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5
	movapd	 4 * SIZE(Y1), %xmm6
	movapd	 6 * SIZE(Y1), %xmm7

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9
	movapd	-12 * SIZE(A1), %xmm10
	movapd	-10 * SIZE(A1), %xmm11

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	mulpd	 %xmm0, %xmm10
	mulpd	 %xmm0, %xmm11

	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5
	addpd	 %xmm10, %xmm6
	addpd	 %xmm11, %xmm7

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)
	movapd	 %xmm6, 4 * SIZE(Y1)
	movapd	 %xmm7, 6 * SIZE(Y1)

	addq	 $8 * SIZE, A1
	addq	 $8 * SIZE, Y1
	ALIGN_3

.L66:
	testq	$4, MM
	je	.L67

	movapd	 0 * SIZE(Y1), %xmm4
	movapd	 2 * SIZE(Y1), %xmm5

	movapd	-16 * SIZE(A1), %xmm8
	movapd	-14 * SIZE(A1), %xmm9

	mulpd	 %xmm0, %xmm8
	mulpd	 %xmm0, %xmm9
	addpd	 %xmm8,  %xmm4
	addpd	 %xmm9,  %xmm5

	movapd	 %xmm4, 0 * SIZE(Y1)
	movapd	 %xmm5, 2 * SIZE(Y1)

	addq	 $4 * SIZE, A1
	addq	 $4 * SIZE, Y1
	ALIGN_3

.L67:
	testq	$2, MM
	je	.L68

	movapd	  0 * SIZE(Y1), %xmm4
	movapd	-16 * SIZE(A1), %xmm8
	mulpd	 %xmm0, %xmm8
	addpd	 %xmm8,  %xmm4
	movapd	 %xmm4, 0 * SIZE(Y1)

	addq	 $2 * SIZE, A1
	addq	 $2 * SIZE, Y1
	ALIGN_3

.L68:
	testq	$1, MM
	je	.L990

	movsd	 0 * SIZE(Y1), %xmm4
	movsd	-16 * SIZE(A1), %xmm8
	mulsd	 %xmm0, %xmm8
	addsd	 %xmm8,  %xmm4
	movsd	 %xmm4, 0 * SIZE(Y1)
	ALIGN_3

.L990:
	movq	Y,  Y1
	testq	$SIZE, A
	je	.L991

	movsd	(Y), %xmm4
	addsd	(BUFFER), %xmm4
	movsd	%xmm4, (Y1)
	addq	INCY, Y
	addq	INCY, Y1
	addq	$1 * SIZE, BUFFER
	ALIGN_3

.L991:
	movq	MM,  %rax
	sarq	$3, %rax
	jle	.L994
	ALIGN_3

.L992:
	movsd	(Y), %xmm4
	addq	INCY, Y
	movhpd	(Y), %xmm4
	addq	INCY, Y
	movsd	(Y), %xmm5
	addq	INCY, Y
	movhpd	(Y), %xmm5
	addq	INCY, Y
	movsd	(Y), %xmm6
	addq	INCY, Y
	movhpd	(Y), %xmm6
	addq	INCY, Y
	movsd	(Y), %xmm7
	addq	INCY, Y
	movhpd	(Y), %xmm7
	addq	INCY, Y

	movapd	(BUFFER), %xmm0
	movapd	2 * SIZE(BUFFER), %xmm1
	movapd	4 * SIZE(BUFFER), %xmm2
	movapd	6 * SIZE(BUFFER), %xmm3

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1
	addpd	%xmm6, %xmm2
	addpd	%xmm7, %xmm3

	movsd	%xmm0, (Y1)
	addq	INCY, Y1
	movhpd	%xmm0, (Y1)
	addq	INCY, Y1
	movsd	%xmm1, (Y1)
	addq	INCY, Y1
	movhpd	%xmm1, (Y1)
	addq	INCY, Y1
	movsd	%xmm2, (Y1)
	addq	INCY, Y1
	movhpd	%xmm2, (Y1)
	addq	INCY, Y1
	movsd	%xmm3, (Y1)
	addq	INCY, Y1
	movhpd	%xmm3, (Y1)
	addq	INCY, Y1

	addq	$8 * SIZE, BUFFER
	decq	%rax
	jg	.L992
	ALIGN_3

.L994:
	testq	$7, MM
	jle	.L999

	testq	$4, MM
	jle	.L995

	movsd	(Y), %xmm4
	addq	INCY, Y
	movhpd	(Y), %xmm4
	addq	INCY, Y
	movsd	(Y), %xmm5
	addq	INCY, Y
	movhpd	(Y), %xmm5
	addq	INCY, Y

	movapd	(BUFFER), %xmm0
	movapd	2 * SIZE(BUFFER), %xmm1

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1

	movsd	%xmm0, (Y1)
	addq	INCY, Y1
	movhpd	%xmm0, (Y1)
	addq	INCY, Y1
	movsd	%xmm1, (Y1)
	addq	INCY, Y1
	movhpd	%xmm1, (Y1)
	addq	INCY, Y1
	addq	$4 * SIZE, BUFFER
	ALIGN_3

.L995:
	testq	$2, MM
	jle	.L996

	movsd	(Y), %xmm4
	addq	INCY, Y
	movhpd	(Y), %xmm4
	addq	INCY, Y

	movapd	(BUFFER), %xmm0
	addpd	%xmm4, %xmm0

	movsd	%xmm0, (Y1)
	addq	INCY, Y1
	movhpd	%xmm0, (Y1)
	addq	INCY, Y1
	addq	$2 * SIZE, BUFFER
	ALIGN_3

.L996:
	testq	$1, MM
	jle	.L999

	movsd	(Y), %xmm4
	addq	INCY, Y

	movsd	(BUFFER), %xmm0
	addsd	%xmm4, %xmm0

	movsd	%xmm0, (Y1)
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
