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

#ifdef PARAMTEST
#define P	  60(%esp)
#endif

#if defined(PENTIUM3) || defined(PENTIUMM)
#ifndef PARAMTEST
#define P 32
#endif
#define movsd	movlps
#define PREFETCHSIZE 32
#endif

#ifdef PENTIUM4
#ifndef PARAMTEST
#define P 24
#endif
#define PREFETCHSIZE 48
#endif

#ifdef CORE2
#ifndef PARAMTEST
#define P 24
#endif
#define PREFETCHSIZE 48
#endif

#ifdef PENRYN
#ifndef PARAMTEST
#define P 24
#endif
#define PREFETCHSIZE 48
#endif

#if defined(OPTERON) || defined(BARCELONA)
#ifndef PARAMTEST
#define P 24
#endif
#define movsd	movlpd
#define PREFETCHSIZE 32
#endif

#ifndef P
#error  P is undefined!!
#endif

#ifndef PREFETCHSIZE
#define PREFETCHSIZE 32
#endif

#ifndef HAVE_SSE2
#define pxor	xorps
#define movlsd	movlps
#endif

#define STACK	16
	
#define OLD_M		 4 + STACK(%esi)
#define OLD_N		 8 + STACK(%esi)
#define OLD_ALPHA	16 + STACK(%esi)
#define OLD_A		20 + STACK(%esi)
#define OLD_LDA		24 + STACK(%esi)
#define OLD_X		28 + STACK(%esi)
#define OLD_INCX	32 + STACK(%esi)
#define OLD_Y		36 + STACK(%esi)
#define OLD_INCY	40 + STACK(%esi)
#define OLD_BUFFER	44 + STACK(%esi)
#define OLD_P		48 + STACK(%esi)

#define ALPHA	 0(%esp)
#define M	16(%esp)
#define N	20(%esp)
#define A	24(%esp)
#define X	32(%esp)
#define INCX	36(%esp)
#define Y	40(%esp)
#define INCY	44(%esp)
#define IS	48(%esp)
#define PLDA_M	52(%esp)
#define BUFFER  56(%esp)

#define OLD_STACK 64(%esp)

#if defined(PENTIUM3) || defined(PENTIUMM)
#define KERNELMACRO(address) \
	movlps	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	movlps	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	movlps	  8 * SIZE(%edx), %xmm1; \
	movhps	 10 * SIZE(%edx), %xmm1; \
	movlps	 12 * SIZE(%edx), %xmm2; \
	movhps	 14 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0;
#endif

#if defined(PENTIUM4) || defined(CORE2) || defined(PENRYN)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	movsd	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	movsd	  8 * SIZE(%edx), %xmm1; \
	movhps	 10 * SIZE(%edx), %xmm1; \
	movsd	 12 * SIZE(%edx), %xmm2; \
	movhps	 14 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	prefetchnta	PREFETCHSIZE * SIZE(%edx); \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0; \
	addps	%xmm2, %xmm7; 
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define KERNELMACRO(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	movsd	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	movsd	  8 * SIZE(%edx), %xmm1; \
	movhps	 10 * SIZE(%edx), %xmm1; \
	movsd	 12 * SIZE(%edx), %xmm2; \
	movhps	 14 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0;
#endif

#define KERNELMACRO8UNROLL(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	movsd	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	movsd	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm7; \
	addl	%ebp, %edx; \
	movaps	  8 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO8(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	movsd	  4 * SIZE(%edx), %xmm2; \
	movhps	  6 * SIZE(%edx), %xmm2; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	mulps	%xmm0, %xmm2; \
	addps	%xmm2, %xmm5; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO4UNROLL(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm5; \
	addl	%ebp, %edx; \
	movaps	  8 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	addl	%ebp, %edx; \
	movaps	 12 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm7; \
	addl	%ebp, %edx; \
	movaps	 16 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO4(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhps	  2 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO2UNROLL(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm5; \
	addl	%ebp, %edx; \
	movaps	  8 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm6; \
	addl	%ebp, %edx; \
	movaps	 12 * SIZE + address * SIZE(%ebx), %xmm0; \
	movsd	  0 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm7; \
	addl	%ebp, %edx; \
	movaps	 16 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO2(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	mulps	%xmm0, %xmm1; \
	addps	%xmm1, %xmm4; \
	addl	%ebp, %edx; \
	movaps	  4 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO1UNROLL(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movss	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm4; \
	movss	  4 * SIZE + address * SIZE(%ebx), %xmm0; \
	movss	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm5; \
	movss	  8 * SIZE + address * SIZE(%ebx), %xmm0; \
	movss	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm6; \
	movss	 12 * SIZE + address * SIZE(%ebx), %xmm0; \
	movss	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm7; \
	movss	 16 * SIZE + address * SIZE(%ebx), %xmm0; \

#define KERNELMACRO1(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movss	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulss	%xmm0, %xmm1; \
	addss	%xmm1, %xmm4; \
	movss	  4 * SIZE + address * SIZE(%ebx), %xmm0;

	PROLOGUE

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	movl	%esp, %esi	# save old stack

	subl	$128, %esp
	andl	$-128, %esp	# align stack

	movl	OLD_BUFFER,   %eax
	movl	%eax, BUFFER

#ifdef PARAMTEST
	movl	OLD_P, %eax
	movl	%eax, P
#endif

	movl	OLD_M,   %ebx
	movl	OLD_N,   %edi
	movss	OLD_ALPHA,  %xmm3
	movl	OLD_A,   %edx

	shufps	$0, %xmm3, %xmm3
	movaps	 %xmm3, ALPHA

	movl	%ebx, M
	movl	%edi, N
	movl	%edx, A

	movl	OLD_LDA,  %ebp
	movl	OLD_X,   %eax
	movl	%eax, X

	movl	OLD_INCX,   %eax
	movl	%eax, INCX
	movl	OLD_Y,   %eax
	movl	%eax, Y
	movl	OLD_INCY,   %eax
	leal	(,%eax, SIZE), %eax
	movl	%eax, INCY

	movl	%esi, OLD_STACK

	movl	%ebp, %eax		# eax = lda
#ifndef PARAMTEST
	imull	$P,   %eax
#else
	imull	 P,   %eax
#endif
	subl	%ebx, %eax		# eax -= m
	sall	$2,   %eax
	movl	%eax, PLDA_M
	sall	$2,  %ebp

	xorl	%ecx, %ecx		# is = 0

	testl	%ebx, %ebx		# if n <= 0 goto END
	jle	.L999
	testl	%edi, %edi		# if n <= 0 goto END
	jle	.L999

.L01:
#ifndef PARAMTEST
	movl	$P,   %ebx
#else
	movl	 P,   %ebx
#endif
	subl	%ecx, %edi	# min_n = n - is
	cmpl	%ebx, %edi	# if (min_n > P)
	cmovg	%ebx, %edi	# min_n = P

	movl	BUFFER, %edx

#ifndef PARAMTEST
	addl	$P, %ecx	# is += P
#else
	addl	 P, %ecx	# is += P
#endif
	movl	%ecx,IS

	movl	X, %ebx

	movl	INCX, %ecx
	cmpl	$1, %ecx
	jne	.L15

	movl	%edi, %eax	# min_n
	sarl	$3, %eax
	jle	.L12

.L11:
	movss	 0 * SIZE(%ebx), %xmm0
	movss	 1 * SIZE(%ebx), %xmm1
	movss	 2 * SIZE(%ebx), %xmm2
	movss	 3 * SIZE(%ebx), %xmm3
	movss	 4 * SIZE(%ebx), %xmm4
	movss	 5 * SIZE(%ebx), %xmm5
	movss	 6 * SIZE(%ebx), %xmm6
	movss	 7 * SIZE(%ebx), %xmm7

	addl	$ 8 * SIZE, %ebx
	addl	$32 * SIZE, %edx

	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	shufps	$0, %xmm2, %xmm2
	shufps	$0, %xmm3, %xmm3
	shufps	$0, %xmm4, %xmm4
	shufps	$0, %xmm5, %xmm5
	shufps	$0, %xmm6, %xmm6
	shufps	$0, %xmm7, %xmm7

	movaps	%xmm0, -32 * SIZE(%edx)
	movaps	%xmm1, -28 * SIZE(%edx)
	movaps	%xmm2, -24 * SIZE(%edx)
	movaps	%xmm3, -20 * SIZE(%edx)
	movaps	%xmm4, -16 * SIZE(%edx)
	movaps	%xmm5, -12 * SIZE(%edx)
	movaps	%xmm6,  -8 * SIZE(%edx)
	movaps	%xmm7,  -4 * SIZE(%edx)
	decl	%eax
	jg	.L11

.L12:
	movl	%edi, %eax	# min_n
	andl	$7, %eax
	jle	.L20

.L13:
	movss	0 * SIZE(%ebx), %xmm0
	shufps	$0, %xmm0, %xmm0
	movaps	%xmm0, 0 * SIZE(%edx)
	addl	$4 * SIZE, %edx
	addl	$1 * SIZE, %ebx	# coffset ++
	decl	%eax
	jg	.L13
	jmp	.L20

.L15:
	sall	$2, %ecx
	movl	%edi, %eax	# min_n
	sarl	$3, %eax
	jle	.L17

.L16:
	movss	0 * SIZE(%ebx), %xmm0
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm1
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm2
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm3
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm4
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm5
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm6
	addl	%ecx, %ebx	# coffset += incX
	movss	0 * SIZE(%ebx), %xmm7
	addl	%ecx, %ebx	# coffset += incX

	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	shufps	$0, %xmm2, %xmm2
	shufps	$0, %xmm3, %xmm3
	shufps	$0, %xmm4, %xmm4
	shufps	$0, %xmm5, %xmm5
	shufps	$0, %xmm6, %xmm6
	shufps	$0, %xmm7, %xmm7

	movaps	%xmm0,  0 * SIZE(%edx)
	movaps	%xmm1,  4 * SIZE(%edx)
	movaps	%xmm2,  8 * SIZE(%edx)
	movaps	%xmm3, 12 * SIZE(%edx)
	movaps	%xmm4, 16 * SIZE(%edx)
	movaps	%xmm5, 20 * SIZE(%edx)
	movaps	%xmm6, 24 * SIZE(%edx)
	movaps	%xmm7, 28 * SIZE(%edx)

	addl	$32 * SIZE, %edx
	decl	%eax
	jg	.L16

.L17:
	movl	%edi, %eax	# min_n
	andl	$7, %eax
	jle	.L20

.L18:
	movss	0 * SIZE(%ebx), %xmm0
	addl	%ecx, %ebx	# coffset += incX
	shufps	$0, %xmm0, %xmm0
	movaps	%xmm0, 0 * SIZE(%edx)
	addl	$4 * SIZE,%edx
	decl	%eax
	jg	.L18

/* Main Routine */

.L20:
	movl	%ebx, X

	movl	Y, %ecx		# coffset = Y
	movaps	ALPHA, %xmm3

	movl	M,  %esi
	sarl	$4, %esi
	jle	.L100

.L21:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$16 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movaps	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L26

.L24:
	KERNELMACRO( 0)
	KERNELMACRO( 4)
	KERNELMACRO( 8)
	KERNELMACRO(12)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L24

.L26:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L28

.L27:
	KERNELMACRO( 0)
	addl	$4 * SIZE, %ebx
	decl	%eax
	jg	.L27

.L28:
	mulps	%xmm3, %xmm4
	movl	INCY, %eax
	mulps	%xmm3, %xmm5
	movl	%ecx, %edx
	mulps	%xmm3, %xmm6
	mulps	%xmm3, %xmm7
	cmpl	$4, %eax
	jne	.L29

#ifdef HAVE_SSE2
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4

	movsd	  4 * SIZE(%ecx), %xmm1
	movhps	  6 * SIZE(%ecx), %xmm1
	addps	%xmm1, %xmm5

	movsd	  8 * SIZE(%ecx), %xmm2
	movhps	 10 * SIZE(%ecx), %xmm2
	addps	%xmm2, %xmm6

	movsd	 12 * SIZE(%ecx), %xmm0
	movhps	 14 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm7

	movsd	%xmm4,  0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(%ecx)

	movsd	%xmm5,  4 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5,  6 * SIZE(%ecx)

	movsd	%xmm6,  8 * SIZE(%ecx)
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 10 * SIZE(%ecx)

	movsd	%xmm7, 12 * SIZE(%ecx)
	unpckhpd %xmm7, %xmm7
	movsd	%xmm7, 14 * SIZE(%ecx)
#else	
	movlps	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4

	movlps	  4 * SIZE(%ecx), %xmm1
	movhps	  6 * SIZE(%ecx), %xmm1
	addps	%xmm1, %xmm5

	movlps	  8 * SIZE(%ecx), %xmm2
	movhps	 10 * SIZE(%ecx), %xmm2
	addps	%xmm2, %xmm6

	movlps	 12 * SIZE(%ecx), %xmm0
	movhps	 14 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm7

	movlps	%xmm4,  0 * SIZE(%ecx)
	movhps	%xmm4,  2 * SIZE(%ecx)
	movlps	%xmm5,  4 * SIZE(%ecx)
	movhps	%xmm5,  6 * SIZE(%ecx)
	movlps	%xmm6,  8 * SIZE(%ecx)
	movhps	%xmm6, 10 * SIZE(%ecx)
	movlps	%xmm7, 12 * SIZE(%ecx)
	movhps	%xmm7, 14 * SIZE(%ecx)
#endif

	addl	$16 * SIZE, %ecx
	decl	%esi
	jg	.L21

	movl	M,   %esi
	andl	$15, %esi
	jne	.L100
	jmp	.L99

.L29:
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm6, %xmm6
	addss	%xmm0, %xmm6
	movss	%xmm6,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm7, %xmm7
	addss	%xmm0, %xmm7
	movss	%xmm7,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	decl	%esi
	jg	.L21

	movl	M,  %esi
	andl	$15, %esi
	jne	.L100

.L99:
	movl	PLDA_M, %ebx
	addl	%ebx, A

	movl	N, %edi
	movl	IS, %ecx
	cmpl	%edi, %ecx
	jl	.L01

.L999:
	movl	OLD_STACK, %esp
	popl	%ebx
	popl	%esi
	popl	%edi	
	popl	%ebp
	ret

.L100:
	movl	M,  %esi
	testl	$8, %esi
	jle	.L110

.L101:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$8 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movaps	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L106

.L104:
	KERNELMACRO8UNROLL( 0)
	KERNELMACRO8UNROLL( 8)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L104

.L106:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L108

.L107:
	KERNELMACRO8( 0)
	addl	$4 * SIZE, %ebx
	decl	%eax
	jg	.L107

.L108:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	mulps	%xmm3, %xmm4
	movl	INCY, %eax
	mulps	%xmm3, %xmm5
	movl	%ecx, %edx
	cmpl	$4, %eax
	jne	.L109

#ifdef HAVE_SSE2
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4

	movsd	  4 * SIZE(%ecx), %xmm1
	movhps	  6 * SIZE(%ecx), %xmm1
	addps	%xmm1, %xmm5

	movsd	%xmm4,  0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(%ecx)

	movsd	%xmm5,  4 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5,  6 * SIZE(%ecx)
#else
	movlps	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4

	movlps	  4 * SIZE(%ecx), %xmm1
	movhps	  6 * SIZE(%ecx), %xmm1
	addps	%xmm1, %xmm5

	movlps	%xmm4,  0 * SIZE(%ecx)
	movhps	%xmm4,  2 * SIZE(%ecx)
	movlps	%xmm5,  4 * SIZE(%ecx)
	movhps	%xmm5,  6 * SIZE(%ecx)
#endif

	addl	$8 * SIZE, %ecx
	jmp	.L110

.L109:
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm5, %xmm5
	addss	%xmm0, %xmm5
	movss	%xmm5,  0 * SIZE(%ecx)
	addl	%eax, %ecx

.L110:
	testl	$4, %esi
	jle	.L120

.L111:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$4 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movaps	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L116

.L114:
	KERNELMACRO4UNROLL( 0)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L114

.L116:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L118

.L117:
	KERNELMACRO4( 0)
	addl	$4 * SIZE, %ebx
	decl	%eax
	jg	.L117

.L118:
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
	addps	%xmm6, %xmm4

	mulps	%xmm3, %xmm4
	movl	INCY, %eax
	movl	%ecx, %edx
	cmpl	$4, %eax
	jne	.L119


#ifdef HAVE_SSE2
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4

	movsd	%xmm4,  0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4,  2 * SIZE(%ecx)
#else
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)

	movss	  1 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  1 * SIZE(%ecx)

	movss	  2 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  2 * SIZE(%ecx)

	movss	  3 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  3 * SIZE(%ecx)
#endif

	addl	$4 * SIZE, %ecx
	jmp	.L120

.L119:
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

.L120:
	testl	$2, %esi
	jle	.L130

.L121:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$2 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movaps	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L126

.L124:
	KERNELMACRO2UNROLL( 0)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L124

.L126:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L128

.L127:
	KERNELMACRO2( 0)
	addl	$4 * SIZE, %ebx
	decl	%eax
	jg	.L127

.L128:
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6
	addps	%xmm6, %xmm4

	mulps	%xmm3, %xmm4
	movl	INCY, %eax
	movl	%ecx, %edx
	cmpl	$4, %eax
	jne	.L129

#ifdef HAVE_SSE2
	movsd	  0 * SIZE(%ecx), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4,  0 * SIZE(%ecx)
#else
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)

	movss	  1 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  1 * SIZE(%ecx)
#endif

	addl	$2 * SIZE, %ecx
	jmp	.L130

.L129:
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

	movss	  0 * SIZE(%ecx), %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	addl	%eax, %ecx

.L130:
	testl	$1, %esi
	jle	.L99

.L131:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$1 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movaps	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L136

.L134:
	KERNELMACRO1UNROLL( 0)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L134

.L136:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L138

.L137:
	KERNELMACRO1( 0)
	addl	$4 * SIZE, %ebx
	decl	%eax
	jg	.L137

.L138:
	addss	%xmm5, %xmm4
	addss	%xmm7, %xmm6
	addss	%xmm6, %xmm4

	mulss	%xmm3, %xmm4
	movss	  0 * SIZE(%ecx), %xmm0
	addss	%xmm0, %xmm4
	movss	%xmm4,  0 * SIZE(%ecx)
	jmp	.L99

	EPILOGUE

