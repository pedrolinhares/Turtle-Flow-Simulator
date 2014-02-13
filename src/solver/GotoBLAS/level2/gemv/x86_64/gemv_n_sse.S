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
#define P 32
#else
#define P		40 + STACKSIZE(%rsp)
#endif

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
	
#define OLD_A		 40 + STACKSIZE(%rsp)
#define OLD_LDA		 48 + STACKSIZE(%rsp)
#define OLD_X		 56 + STACKSIZE(%rsp)
#define OLD_INCX	 64 + STACKSIZE(%rsp)
#define OLD_Y		 72 + STACKSIZE(%rsp)
#define OLD_INCY	 80 + STACKSIZE(%rsp)
#define BUFFER		 88 + STACKSIZE(%rsp)
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

#define ALPHA %xmm15
	
#if defined(PENTIUM4) || defined(CORE2) || defined(PENRYN) || defined(GENERIC)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	movsd	  4 * SIZE(AO), %xmm2; \
	movhpd	  6 * SIZE(AO), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	movsd	  8 * SIZE(AO), %xmm1; \
	movhpd	 10 * SIZE(AO), %xmm1; \
	movsd	 12 * SIZE(AO), %xmm2; \
	movhpd	 14 * SIZE(AO), %xmm2; \
	addq	LDA, AO; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0; \
	prefetchnta	32 * SIZE(AO);
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(AO), %xmm1; \
	prefetcht0	32 * SIZE(AO); \
	movhpd	  2 * SIZE(AO), %xmm1; \
	movsd	  4 * SIZE(AO), %xmm2; \
	movhpd	  6 * SIZE(AO), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	movsd	  8 * SIZE(AO), %xmm1; \
	movhpd	 10 * SIZE(AO), %xmm1; \
	movsd	 12 * SIZE(AO), %xmm2; \
	movhpd	 14 * SIZE(AO), %xmm2; \
	addq	LDA, AO; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0;
#endif

#define KERNELMACRO8UNROLL(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	movsd	  4 * SIZE(AO), %xmm2; \
	movhpd	  6 * SIZE(AO), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	movsd	  4 * SIZE(AO), %xmm2; \
	movhpd	  6 * SIZE(AO), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	addq	LDA, AO; \
	movaps	  8 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO8(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	movsd	  4 * SIZE(AO), %xmm2; \
	movhpd	  6 * SIZE(AO), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO4UNROLL(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm5; \
	addq	LDA, AO; \
	movaps	  8 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	addq	LDA, AO; \
	movaps	 12 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm7; \
	addq	LDA, AO; \
	movaps	 16 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO4(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	movhpd	  2 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO2UNROLL(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm5; \
	addq	LDA, AO; \
	movaps	  8 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	addq	LDA, AO; \
	movaps	 12 * SIZE + address * SIZE(BO), %xmm0; \
	movsd	  0 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm7; \
	addq	LDA, AO; \
	movaps	 16 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO2(address) \
	prefetcht2	32 * SIZE(AO); \
	movsd	  0 * SIZE(AO), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addq	LDA, AO; \
	movaps	  4 * SIZE + address * SIZE(BO), %xmm0;

#define KERNELMACRO1UNROLL(address) \
	prefetcht2	32 * SIZE(AO); \
	movss	  0 * SIZE(AO), %xmm1; \
	addq	LDA, AO; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm4; \
	movss	  4 * SIZE + address * SIZE(BO), %xmm0; \
	movss	  0 * SIZE(AO), %xmm1; \
	addq	LDA, AO; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm5; \
	movss	  8 * SIZE + address * SIZE(BO), %xmm0; \
	movss	  0 * SIZE(AO), %xmm1; \
	addq	LDA, AO; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm6; \
	movss	 12 * SIZE + address * SIZE(BO), %xmm0; \
	movss	  0 * SIZE(AO), %xmm1; \
	addq	LDA, AO; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm7; \
	movss	 16 * SIZE + address * SIZE(BO), %xmm0; \

#define KERNELMACRO1(address) \
	prefetcht2	32 * SIZE(AO); \
	movss	  0 * SIZE(AO), %xmm1; \
	addq	LDA, AO; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm4; \
	movss	  4 * SIZE + address * SIZE(BO), %xmm0;

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
	pshufd	 $0, %xmm0, ALPHA
#else
	pshufd	 $0, %xmm3, ALPHA
#endif

	leaq	(,INCX, SIZE), INCX
	leaq	(,INCY, SIZE), INCY

	movq	LDA,  %r14		# eax = lda
#ifndef PARAMTEST
	imulq	$P,   %r14
#else
	imulq	 P,   %r14
#endif
	subq	M,    %r14		# eax -= m
	salq	$2,   %r14
	movq	%r14, PLDA_M

	leaq	(,LDA, SIZE), LDA

	xorq	IS, IS		# is = 0

	testq	M,  M		# if n <= 0 goto END
	jle	.L999
	testq	N,  N		# if n <= 0 goto END
	jle	.L999
	ALIGN_4

.L01:
#ifndef PARAMTEST
	movq	$P,   TEMP
#else
	movq	 P,   TEMP
#endif
	movq	N,    MIN_N
	subq	IS,   MIN_N	# min_n = n - is
	cmpq	TEMP, MIN_N	# if (min_n > P)
	cmovg	TEMP, MIN_N	# min_n = P

	movq	BUFFER, AO
#ifndef PARAMTEST
	addq	$P, IS		# is += P
#else
	addq	 P, IS		# is += P
#endif

	cmpq	$SIZE, INCX
	jne	.L15

	movq	MIN_N, I	# min_n
	sarq	$3, I
	jle	.L12
	ALIGN_4

.L11:
	movss	 0 * SIZE(X), %xmm0
	movss	 1 * SIZE(X), %xmm1
	movss	 2 * SIZE(X), %xmm2
	movss	 3 * SIZE(X), %xmm3
	movss	 4 * SIZE(X), %xmm4
	movss	 5 * SIZE(X), %xmm5
	movss	 6 * SIZE(X), %xmm6
	movss	 7 * SIZE(X), %xmm7

	addq	$ 8 * SIZE, X
	addq	$32 * SIZE, AO

	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	shufps	$0, %xmm2, %xmm2
	shufps	$0, %xmm3, %xmm3
	shufps	$0, %xmm4, %xmm4
	shufps	$0, %xmm5, %xmm5
	shufps	$0, %xmm6, %xmm6
	shufps	$0, %xmm7, %xmm7

	movaps	%xmm0, -32 * SIZE(AO)
	movaps	%xmm1, -28 * SIZE(AO)
	movaps	%xmm2, -24 * SIZE(AO)
	movaps	%xmm3, -20 * SIZE(AO)
	movaps	%xmm4, -16 * SIZE(AO)
	movaps	%xmm5, -12 * SIZE(AO)
	movaps	%xmm6,  -8 * SIZE(AO)
	movaps	%xmm7,  -4 * SIZE(AO)
	decq	I
	jg	.L11
	ALIGN_4

.L12:
	movq	MIN_N, I	# min_n
	andq	$7, I
	jle	.L20
	ALIGN_4

.L13:
	movss	0 * SIZE(X), %xmm0
	shufps	$0, %xmm0, %xmm0
	movaps	%xmm0, 0 * SIZE(AO)
	addq	$4 * SIZE, AO
	addq	$1 * SIZE, X	# coffset ++
	decq	I
	jg	.L13
	jmp	.L20
	ALIGN_4

.L15:
	movq	MIN_N, I	# min_n
	sarq	$3, I
	jle	.L17
	ALIGN_4

.L16:
	movss	0 * SIZE(X), %xmm0
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm1
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm2
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm3
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm4
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm5
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm6
	addq	INCX, X	# coffset += incX
	movss	0 * SIZE(X), %xmm7
	addq	INCX, X	# coffset += incX

	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	shufps	$0, %xmm2, %xmm2
	shufps	$0, %xmm3, %xmm3
	shufps	$0, %xmm4, %xmm4
	shufps	$0, %xmm5, %xmm5
	shufps	$0, %xmm6, %xmm6
	shufps	$0, %xmm7, %xmm7

	movaps	%xmm0,  0 * SIZE(AO)
	movaps	%xmm1,  4 * SIZE(AO)
	movaps	%xmm2,  8 * SIZE(AO)
	movaps	%xmm3, 12 * SIZE(AO)
	movaps	%xmm4, 16 * SIZE(AO)
	movaps	%xmm5, 20 * SIZE(AO)
	movaps	%xmm6, 24 * SIZE(AO)
	movaps	%xmm7, 28 * SIZE(AO)

	addq	$32 * SIZE, AO
	decq	I
	jg	.L16
	ALIGN_4

.L17:
	movq	MIN_N, I	# min_n
	andq	$7, I
	jle	.L20
	ALIGN_4

.L18:
	movss	0 * SIZE(X), %xmm0
	addq	INCX, X	# coffset += incX
	shufps	$0, %xmm0, %xmm0
	movaps	%xmm0, 0 * SIZE(AO)
	addq	$4 * SIZE,AO
	decq	I
	jg	.L18
	ALIGN_4

/* Main Routine */

.L20:
	movq	Y, CO		# coffset = Y
	movq	M,  J
	sarq	$4, J
	jle	.L100
	ALIGN_4

.L21:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A, AO		# aoffset = a
	addq	$16 * SIZE, A	# a += 8

	movq	BUFFER, BO	# boffset = buffer
	movaps	  0 * SIZE(BO), %xmm0

	movq	MIN_N, I	# i = min_n
	sarq	$2, I
	jle	.L26
	ALIGN_4

.L24:
	KERNELMACRO( 0)
	KERNELMACRO( 4)
	KERNELMACRO( 8)
	KERNELMACRO(12)
	addq	$16 * SIZE, BO
	decq	I
	jg	.L24
	ALIGN_4

.L26:
	movq	MIN_N, I	# i = min_n
	andq	$3, I
	jle	.L28
	ALIGN_4

.L27:
	KERNELMACRO( 0)
	addq	$4 * SIZE, BO
	decq	I
	jg	.L27
	ALIGN_4

.L28:
	mulps	ALPHA, %xmm4
	mulps	ALPHA, %xmm5
	mulps	ALPHA, %xmm6
	mulps	ALPHA, %xmm7
	cmpq	$4, INCY
	jne	.L29

	movsd	  0 * SIZE(CO), %xmm0
	movhpd	  2 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4

	movsd	  4 * SIZE(CO), %xmm1
	movhpd	  6 * SIZE(CO), %xmm1
	addps	%xmm1, %xmm5

	movsd	  8 * SIZE(CO), %xmm2
	movhpd	 10 * SIZE(CO), %xmm2
	addps	%xmm2, %xmm6

	movsd	 12 * SIZE(CO), %xmm0
	movhpd	 14 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm7

	movsd	%xmm4,  0 * SIZE(CO)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(CO)

	movsd	%xmm5,  4 * SIZE(CO)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5,  6 * SIZE(CO)

	movsd	%xmm6,  8 * SIZE(CO)
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 10 * SIZE(CO)

	movsd	%xmm7, 12 * SIZE(CO)
	unpckhpd %xmm7, %xmm7
	movsd	%xmm7, 14 * SIZE(CO)

	addq	$16 * SIZE, CO
	decq	J
	jg	.L21

	movq	M,   J
	andq	$15, J
	jne	.L100
	jmp	.L99
	ALIGN_4

.L29:
	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(CO)
	addq	INCY, CO

	decq	J
	jg	.L21

	movq	M,  J
	andq	$15, J
	jne	.L100
	ALIGN_4

.L99:
	addq	PLDA_M, A
	cmpq	N, IS
	jl	.L01
	ALIGN_4

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
	movq	M,  J
	testq	$8, J
	jle	.L110
	ALIGN_4

.L101:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A, AO		# aoffset = a
	addq	$8 * SIZE, A	# a += 8

	movq	BUFFER, BO	# boffset = buffer
	movaps	  0 * SIZE(BO), %xmm0

	movq	MIN_N, I	# i = min_n
	sarq	$2, I
	jle	.L106
	ALIGN_4

.L104:
	KERNELMACRO8UNROLL( 0)
	KERNELMACRO8UNROLL( 8)
	addq	$16 * SIZE, BO
	decq	I
	jg	.L104
	ALIGN_4

.L106:
	movq	MIN_N, I	# i = min_n
	andq	$3, I
	jle	.L108
	ALIGN_4

.L107:
	KERNELMACRO8( 0)
	addq	$4 * SIZE, BO
	decq	I
	jg	.L107
	ALIGN_4

.L108:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	mulps	ALPHA, %xmm4
	mulps	ALPHA, %xmm5
	cmpq	$4, INCY
	jne	.L109

	movsd	  0 * SIZE(CO), %xmm0
	movhpd	  2 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4

	movsd	  4 * SIZE(CO), %xmm1
	movhpd	  6 * SIZE(CO), %xmm1
	addps	%xmm1, %xmm5

	movsd	%xmm4,  0 * SIZE(CO)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(CO)

	movsd	%xmm5,  4 * SIZE(CO)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5,  6 * SIZE(CO)
	addq	$8 * SIZE, CO
	jmp	.L110
	ALIGN_4

.L109:
	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(CO)
	addq	INCY, CO
	ALIGN_4

.L110:
	testq	$4, J
	jle	.L120
	ALIGN_4

.L111:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A, AO		# aoffset = a
	addq	$4 * SIZE, A	# a += 8

	movq	BUFFER, BO	# boffset = buffer
	movaps	  0 * SIZE(BO), %xmm0

	movq	MIN_N, I	# i = min_n
	sarq	$2, I
	jle	.L116
	ALIGN_4

.L114:
	KERNELMACRO4UNROLL( 0)
	addq	$16 * SIZE, BO
	decq	I
	jg	.L114
	ALIGN_4

.L116:
	movq	MIN_N, I	# i = min_n
	andq	$3, I
	jle	.L118
	ALIGN_4

.L117:
	KERNELMACRO4( 0)
	addq	$4 * SIZE, BO
	decq	I
	jg	.L117
	ALIGN_4

.L118:
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
	addps	%xmm6, %xmm4

	mulps	ALPHA, %xmm4
	cmpq	$4, INCY
	jne	.L119

	movsd	  0 * SIZE(CO), %xmm0
	movhpd	  2 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4

	movsd	%xmm4,  0 * SIZE(CO)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(CO)

	addq	$4 * SIZE, CO
	jmp	.L120
	ALIGN_4

.L119:
	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

.L120:
	testq	$2, J
	jle	.L130
	ALIGN_4

.L121:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A, AO		# aoffset = a
	addq	$2 * SIZE, A	# a += 8

	movq	BUFFER, BO	# boffset = buffer
	movaps	  0 * SIZE(BO), %xmm0

	movq	MIN_N, I	# i = min_n
	sarq	$2, I
	jle	.L126
	ALIGN_4

.L124:
	KERNELMACRO2UNROLL( 0)
	addq	$16 * SIZE, BO
	decq	I
	jg	.L124
	ALIGN_4

.L126:
	movq	MIN_N, I	# i = min_n
	andq	$3, I
	jle	.L128
	ALIGN_4

.L127:
	KERNELMACRO2( 0)
	addq	$4 * SIZE, BO
	decq	I
	jg	.L127
	ALIGN_4

.L128:
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
	addps	%xmm6, %xmm4

	mulps	ALPHA, %xmm4
	cmpq	$4, INCY
	jne	.L129

	movsd	  0 * SIZE(CO), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4,  0 * SIZE(CO)
	addq	$2 * SIZE, CO
	jmp	.L130
	ALIGN_4

.L129:
	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO

	movss	  0 * SIZE(CO), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	addq	INCY, CO
	ALIGN_4

.L130:
	testq	$1, J
	jle	.L99
	ALIGN_4

.L131:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movq	A, AO		# aoffset = a
	addq	$1 * SIZE, A	# a += 8

	movq	BUFFER, BO	# boffset = buffer
	movaps	  0 * SIZE(BO), %xmm0

	movq	MIN_N, I	# i = min_n
	sarq	$2, I
	jle	.L136
	ALIGN_4

.L134:
	KERNELMACRO1UNROLL( 0)
	addq	$16 * SIZE, BO
	decq	I
	jg	.L134
	ALIGN_4

.L136:
	movq	MIN_N, I	# i = min_n
	andq	$3, I
	jle	.L138
	ALIGN_4

.L137:
	KERNELMACRO1( 0)
	addq	$4 * SIZE, BO
	decq	I
	jg	.L137
	ALIGN_4

.L138:
	addss	%xmm5, %xmm4
	addss	%xmm7, %xmm6
	addss	%xmm6, %xmm4

	mulss	ALPHA, %xmm4
	movss	  0 * SIZE(CO), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(CO)
	jmp	.L99

	EPILOGUE
