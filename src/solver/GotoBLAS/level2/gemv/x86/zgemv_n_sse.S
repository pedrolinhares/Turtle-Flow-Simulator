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
#define P	  52 + STACK + ARGS(%esp)
#endif

#if defined(PENTIUM3) || defined(PENTIUMM)
#ifndef PARAMTEST
#define P 32
#endif
#define movsd	movlps
#define PREFETCHSIZE 48
#endif

#ifdef PENTIUM4
#ifndef PARAMTEST
#define P 32
#endif
#define PREFETCHSIZE 48
#endif

#ifdef CORE2
#ifndef PARAMTEST
#define P 32
#endif
#define PREFETCHSIZE 48
#endif

#ifdef PENRYN
#ifndef PARAMTEST
#define P 32
#endif
#define PREFETCHSIZE 48
#endif

#if defined(OPTERON) || defined(BARCELONA)
#ifndef PARAMTEST
#define P 24
#endif
#define movsd	movlps
#define PREFETCHSIZE 32
#endif
	
#ifndef P
#error  P is undefined!!
#endif

#ifndef HAVE_SSE2
#define movsd	movlps
#define unpckhpd movhlps
#define XORPS	xorps
#else
#define XORPS	pxor
#endif

#if defined(PENTIUM3) || defined(PENTIUMM)
#define KERNELMACRO(address) \
	movlps	  0 * SIZE(%ecx), %xmm0; \
	movhps	  2 * SIZE(%ecx), %xmm0; \
	mulps	%xmm0, %xmm1; \
	movlps	  4 * SIZE(%ecx), %xmm2; \
	movhps	  6 * SIZE(%ecx), %xmm2; \
	prefetcht0	PREFETCHSIZE * SIZE(%ecx); \
	addps	%xmm1, %xmm4; \
	movaps	  0 * SIZE + address * SIZE(%edx), %xmm3; \
	addl	%ebx, %ecx; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm0; \
	addps	%xmm0, %xmm5; \
	mulps	%xmm2, %xmm3; \
	movaps	  8 * SIZE + address * SIZE(%edx), %xmm1; \
	addps	%xmm3, %xmm6; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm2; \
	addps	%xmm2, %xmm7
#endif

#if defined(PENTIUM4) || defined(CORE2) || defined(PENRYN)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(%ecx), %xmm0; \
	movhps	  2 * SIZE(%ecx), %xmm0; \
	mulps	%xmm0, %xmm1; \
	movsd	  4 * SIZE(%ecx), %xmm2; \
	movhps	  6 * SIZE(%ecx), %xmm2; \
	prefetcht2	PREFETCHSIZE * SIZE(%ecx); \
	addps	%xmm1, %xmm4; \
	movaps	  0 * SIZE + address * SIZE(%edx), %xmm3; \
	addl	%ebx, %ecx; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm0; \
	addps	%xmm0, %xmm5; \
	mulps	%xmm2, %xmm3; \
	movaps	  8 * SIZE + address * SIZE(%edx), %xmm1; \
	addps	%xmm3, %xmm6; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm2; \
	addps	%xmm2, %xmm7
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define KERNELMACRO(address) \
	movlps	  0 * SIZE(%ecx), %xmm0; \
	movhps	  2 * SIZE(%ecx), %xmm0; \
	prefetcht0	PREFETCHSIZE * SIZE(%ecx); \
	mulps	%xmm0, %xmm1; \
	movlps	  4 * SIZE(%ecx), %xmm2; \
	movhps	  6 * SIZE(%ecx), %xmm2; \
	addps	%xmm1, %xmm4; \
	movaps	  0 * SIZE + address * SIZE(%edx), %xmm3; \
	addl	%ebx, %ecx; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm0; \
	addps	%xmm0, %xmm5; \
	mulps	%xmm2, %xmm3; \
	movaps	  8 * SIZE + address * SIZE(%edx), %xmm1; \
	addps	%xmm3, %xmm6; \
	mulps	  4 * SIZE + address * SIZE(%edx), %xmm2; \
	addps	%xmm2, %xmm7
#endif

	
#define STACK	16
#define ARGS	 8
	
#define PLDA_M	  0 + STACK(%esp)
#define IS	  4 + STACK(%esp)

#define M	 4 + STACK + ARGS(%esp)
#define N	 8 + STACK + ARGS(%esp)
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	20 + STACK + ARGS(%esp)
#define A	24 + STACK + ARGS(%esp)
#define LDA	28 + STACK + ARGS(%esp)
#define X	32 + STACK + ARGS(%esp)
#define INCX	36 + STACK + ARGS(%esp)
#define Y	40 + STACK + ARGS(%esp)
#define INCY	44 + STACK + ARGS(%esp)
#define BUFFER	48 + STACK + ARGS(%esp)

	PROLOGUE

	subl	$ARGS, %esp
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	EMMS

	movl	INCX, %eax
	sall	$3,   %eax		# INCX *= 2
	movl	%eax, INCX

	movl	INCY, %edx
	sall	$3,   %edx		# INCY *= 2
	movl	%edx, INCY

	movl	LDA,  %edi
	sall	$3,   %edi		# LDA *= 2
	movl	%edi, LDA

	movl	M, %ebp
	movl	N, %ebx

#ifndef PARAMTEST
	imull	$P,   %edi
#else
	imull	 P,   %edi
#endif
	movl	%ebp, %ecx
	sall	$3,   %ecx
	subl	%ecx, %edi
	movl	%edi, PLDA_M

	movl	BUFFER, %edi

	pcmpeqb	%mm7, %mm7
	pslld	$31, %mm7	

	movd	ALPHA_R,  %mm0
	movd	ALPHA_I,  %mm1

	movd	%mm0, 0 * SIZE(%edi)
	movd	%mm0, 1 * SIZE(%edi)
	movd	%mm0, 2 * SIZE(%edi)
	movd	%mm0, 3 * SIZE(%edi)
	movd	%mm1, 4 * SIZE(%edi)
	movd	%mm1, 6 * SIZE(%edi)
	pxor	%mm7, %mm1
	movd	%mm1, 5 * SIZE(%edi)
	movd	%mm1, 7 * SIZE(%edi)

	xorl	%edx,%edx		# is = 0

	testl	%ebp, %ebp
	jle	.L999
	testl	%ebx, %ebx
	jle	.L999
	ALIGN_3

.L10:
	movl	N,    %ebp
	subl	%edx, %ebp		# m - is
#ifndef PARAMTEST
	movl	$P,   %eax
#else
	movl	 P,   %eax
#endif
	cmpl	%eax, %ebp
	cmovg	%eax, %ebp

	movl	BUFFER, %ecx
	addl	$128, %ecx

	movl	%edx, IS

	movl	X,    %ebx
	movl	INCX, %edx

	movl	%ebp, %eax
	sarl	$2,   %eax
	jle	.L12
	ALIGN_3

.L11:
#ifndef CONJ
	movd	0 * SIZE(%ebx), %mm0
	movd	1 * SIZE(%ebx), %mm1
	addl	%edx,%ebx
	movd	0 * SIZE(%ebx), %mm2
	movd	1 * SIZE(%ebx), %mm3
	addl	%edx,%ebx

	movd	%mm0,  0 * SIZE(%ecx)
	movd	%mm0,  1 * SIZE(%ecx)
	movd	%mm0,  2 * SIZE(%ecx)
	movd	%mm0,  3 * SIZE(%ecx)

	movd	%mm1,  5 * SIZE(%ecx)
	movd	%mm1,  7 * SIZE(%ecx)
	pxor	%mm7, %mm1
	movd	%mm1,  4 * SIZE(%ecx)
	movd	%mm1,  6 * SIZE(%ecx)

	movd	%mm2,  8 * SIZE(%ecx)
	movd	%mm2,  9 * SIZE(%ecx)
	movd	%mm2, 10 * SIZE(%ecx)
	movd	%mm2, 11 * SIZE(%ecx)

	movd	%mm3, 13 * SIZE(%ecx)
	movd	%mm3, 15 * SIZE(%ecx)
	pxor	%mm7, %mm3
	movd	%mm3, 12 * SIZE(%ecx)
	movd	%mm3, 14 * SIZE(%ecx)

	movd	0 * SIZE(%ebx), %mm0
	movd	1 * SIZE(%ebx), %mm1
	addl	%edx,%ebx
	movd	0 * SIZE(%ebx), %mm2
	movd	1 * SIZE(%ebx), %mm3
	addl	%edx,%ebx

	movd	%mm0, 16 * SIZE(%ecx)
	movd	%mm0, 17 * SIZE(%ecx)
	movd	%mm0, 18 * SIZE(%ecx)
	movd	%mm0, 19 * SIZE(%ecx)

	movd	%mm1, 21 * SIZE(%ecx)
	movd	%mm1, 23 * SIZE(%ecx)
	pxor	%mm7, %mm1
	movd	%mm1, 20 * SIZE(%ecx)
	movd	%mm1, 22 * SIZE(%ecx)

	movd	%mm2, 24 * SIZE(%ecx)
	movd	%mm2, 25 * SIZE(%ecx)
	movd	%mm2, 26 * SIZE(%ecx)
	movd	%mm2, 27 * SIZE(%ecx)

	movd	%mm3, 29 * SIZE(%ecx)
	movd	%mm3, 31 * SIZE(%ecx)
	pxor	%mm7, %mm3
	movd	%mm3, 28 * SIZE(%ecx)
	movd	%mm3, 30 * SIZE(%ecx)
#else
	movd	0 * SIZE(%ebx), %mm0
	movd	1 * SIZE(%ebx), %mm1
	addl	%edx,%ebx
	movd	0 * SIZE(%ebx), %mm2
	movd	1 * SIZE(%ebx), %mm3
	addl	%edx,%ebx

	movd	%mm0,  0 * SIZE(%ecx)
	movd	%mm0,  2 * SIZE(%ecx)
	pxor	%mm7, %mm0
	movd	%mm0,  1 * SIZE(%ecx)
	movd	%mm0,  3 * SIZE(%ecx)

	movd	%mm1,  4 * SIZE(%ecx)
	movd	%mm1,  5 * SIZE(%ecx)
	movd	%mm1,  6 * SIZE(%ecx)
	movd	%mm1,  7 * SIZE(%ecx)

	movd	%mm2,  8 * SIZE(%ecx)
	movd	%mm2, 10 * SIZE(%ecx)
	pxor	%mm7, %mm2
	movd	%mm2,  9 * SIZE(%ecx)
	movd	%mm2, 11 * SIZE(%ecx)

	movd	%mm3, 12 * SIZE(%ecx)
	movd	%mm3, 13 * SIZE(%ecx)
	movd	%mm3, 14 * SIZE(%ecx)
	movd	%mm3, 15 * SIZE(%ecx)

	movd	0 * SIZE(%ebx), %mm0
	movd	1 * SIZE(%ebx), %mm1
	addl	%edx,%ebx
	movd	0 * SIZE(%ebx), %mm2
	movd	1 * SIZE(%ebx), %mm3
	addl	%edx,%ebx

	movd	%mm0, 16 * SIZE(%ecx)
	movd	%mm0, 18 * SIZE(%ecx)
	pxor	%mm7, %mm0
	movd	%mm0, 17 * SIZE(%ecx)
	movd	%mm0, 19 * SIZE(%ecx)

	movd	%mm1, 20 * SIZE(%ecx)
	movd	%mm1, 21 * SIZE(%ecx)
	movd	%mm1, 22 * SIZE(%ecx)
	movd	%mm1, 23 * SIZE(%ecx)

	movd	%mm2, 24 * SIZE(%ecx)
	movd	%mm2, 26 * SIZE(%ecx)
	pxor	%mm7, %mm2
	movd	%mm2, 25 * SIZE(%ecx)
	movd	%mm2, 27 * SIZE(%ecx)

	movd	%mm3, 28 * SIZE(%ecx)
	movd	%mm3, 29 * SIZE(%ecx)
	movd	%mm3, 30 * SIZE(%ecx)
	movd	%mm3, 31 * SIZE(%ecx)
#endif

	addl	$32 * SIZE, %ecx
	decl	%eax
	jg	.L11
	ALIGN_3

.L12:
	movl	%ebp, %eax
	andl	$3,   %eax
	jle	.L20
	ALIGN_3

.L13:
	movd	0 * SIZE(%ebx), %mm0
	movd	1 * SIZE(%ebx), %mm1
	addl	%edx, %ebx

#ifndef CONJ
	movd	%mm0, 0 * SIZE(%ecx)
	movd	%mm0, 1 * SIZE(%ecx)
	movd	%mm0, 2 * SIZE(%ecx)
	movd	%mm0, 3 * SIZE(%ecx)

	movd	%mm1, 5 * SIZE(%ecx)
	movd	%mm1, 7 * SIZE(%ecx)
	pxor	%mm7, %mm1
	movd	%mm1, 4 * SIZE(%ecx)
	movd	%mm1, 6 * SIZE(%ecx)
#else
	movd	%mm0, 0 * SIZE(%ecx)
	movd	%mm0, 2 * SIZE(%ecx)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(%ecx)

	movd	%mm0, 3 * SIZE(%ecx)
	movd	%mm1, 4 * SIZE(%ecx)
	movd	%mm1, 5 * SIZE(%ecx)
	movd	%mm1, 6 * SIZE(%ecx)
	movd	%mm1, 7 * SIZE(%ecx)
#endif

	addl	$8 * SIZE, %ecx
	decl	%eax
	jg	.L13
	ALIGN_3

.L20:
	movl	%ebx, X
	movl	Y,  %edi
	movl	M,  %esi
	sarl	$2, %esi
	jle	.L50
	ALIGN_3

.L21:
	XORPS	%xmm4, %xmm4
	XORPS	%xmm5, %xmm5
	XORPS	%xmm6, %xmm6
	XORPS	%xmm7, %xmm7

	movl	A, %ecx
	addl	$8 * SIZE, A
	movl	LDA, %ebx

	movl	BUFFER, %edx
	addl	$128, %edx

	movaps	  0 * SIZE(%edx), %xmm1

	movl	%ebp, %eax		# i = min_n
	sarl	$2,   %eax
	jle	.L23
	ALIGN_3

.L22:
	KERNELMACRO( 0)
	KERNELMACRO( 8)
	KERNELMACRO(16)
	KERNELMACRO(24)

	addl	$32 * SIZE, %edx
	decl	%eax
	jg	.L22
	ALIGN_3

.L23:
	movl	%ebp, %eax		# i = min_n
	andl	$3,  %eax
	jle	.L29
	ALIGN_3

.L24:
	KERNELMACRO( 0)
	addl	$8 * SIZE, %edx
	decl	%eax
	jg	.L24
	ALIGN_3

.L29:
	movl	BUFFER, %eax
	movl	INCY, %ebx

	movaps	0 * SIZE(%eax), %xmm0
	movaps	4 * SIZE(%eax), %xmm1

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

	mulps	%xmm0, %xmm4
	mulps	%xmm1, %xmm5
	mulps	%xmm0, %xmm6
	mulps	%xmm1, %xmm7

	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6

	movsd	 0 * SIZE(%edi), %xmm0
	movhps	 0 * SIZE(%edi, %ebx), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy

	movsd	 0 * SIZE(%edi), %xmm0
	movhps	 0 * SIZE(%edi, %ebx), %xmm0
	addps	%xmm0, %xmm6
	movsd	%xmm6, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy

	decl	%esi
	jg	.L21

.L50:
	movl	M,  %esi
	andl	$3, %esi
	cmpl	$3, %esi
	jne	.L60

	XORPS	%xmm4, %xmm4
	XORPS	%xmm5, %xmm5
	XORPS	%xmm6, %xmm6
	XORPS	%xmm7, %xmm7

	movl	A, %ecx
	addl	$6 * SIZE, A
	movl	LDA, %ebx

	movl	BUFFER, %edx
	addl	$128, %edx

	movaps	  0 * SIZE(%edx), %xmm1
	movaps	 16 * SIZE(%edx), %xmm3

	movl	%ebp, %eax		# i = min_n
	sarl	$2,   %eax
	jle	.L53
	ALIGN_3

.L52:
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	movsd	  4 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(%edx), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(%edx), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(%ecx), %xmm0
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(%edx), %xmm2
	addps	%xmm1, %xmm6
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm2, %xmm7

	movsd	  4 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	movaps	  8 * SIZE(%edx), %xmm1
	mulps	%xmm0, %xmm1
	mulps	 12 * SIZE(%edx), %xmm0
	addps	%xmm1, %xmm4
	movaps	  8 * SIZE(%edx), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(%ecx), %xmm0
	mulps	%xmm2, %xmm1
	mulps	 12 * SIZE(%edx), %xmm2
	addps	%xmm1, %xmm6
	movaps	 32 * SIZE(%edx), %xmm1
	addps	%xmm2, %xmm7

	movhps	  2 * SIZE(%ecx), %xmm0
	movsd	  4 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0, %xmm3
	mulps	 20 * SIZE(%edx), %xmm0
	addps	%xmm3, %xmm4
	movaps	 16 * SIZE(%edx), %xmm3
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(%ecx), %xmm0
	mulps	%xmm2, %xmm3
	mulps	 20 * SIZE(%edx), %xmm2
	addps	%xmm3, %xmm6
	movhps	  2 * SIZE(%ecx), %xmm0
	addps	%xmm2, %xmm7

	movsd	  4 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	movaps	 24 * SIZE(%edx), %xmm3
	mulps	%xmm0, %xmm3
	mulps	 28 * SIZE(%edx), %xmm0
	addps	%xmm3, %xmm4
	movaps	 24 * SIZE(%edx), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm3
	mulps	 28 * SIZE(%edx), %xmm2
	addps	%xmm3, %xmm6
	movaps	 48 * SIZE(%edx), %xmm3
	addps	%xmm2, %xmm7

	addl	$32 * SIZE, %edx
	decl	%eax
	jg	.L52
	ALIGN_3

.L53:
	movl	%ebp, %eax		# i = min_n
	andl	$3,  %eax
	jle	.L59
	ALIGN_3

.L54:
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	movsd	  4 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0, %xmm1
	mulps	  4 * SIZE(%edx), %xmm0
	addps	%xmm1, %xmm4
	movaps	  0 * SIZE(%edx), %xmm1
	addps	%xmm0, %xmm5
	mulps	%xmm2, %xmm1
	mulps	  4 * SIZE(%edx), %xmm2
	addps	%xmm1, %xmm6
	movaps	  8 * SIZE(%edx), %xmm1
	addps	%xmm2, %xmm7

	addl	$8 * SIZE, %edx
	decl	%eax
	jg	.L54
	ALIGN_3

.L59:
	movl	BUFFER, %eax
	movl	INCY, %ebx

	movaps	0 * SIZE(%eax), %xmm0
	movaps	4 * SIZE(%eax), %xmm1

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

	mulps	%xmm0, %xmm4
	mulps	%xmm1, %xmm5
	mulps	%xmm0, %xmm6
	mulps	%xmm1, %xmm7

	shufps	$0xb1, %xmm5, %xmm5
	shufps	$0xb1, %xmm7, %xmm7
	addps	%xmm5, %xmm4
	addps	%xmm7, %xmm6

	movsd	 0 * SIZE(%edi), %xmm0
	movhps	 0 * SIZE(%edi, %ebx), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	addl	%ebx, %edi		# coffset += incy

	movsd	 0 * SIZE(%edi), %xmm0
	addps	%xmm0, %xmm6
	movsd	%xmm6, 0 * SIZE(%edi)
	jmp	.L99
	ALIGN_3

.L60:
	cmpl	$2, %esi
	jne	.L70

	XORPS	%xmm4, %xmm4
	XORPS	%xmm5, %xmm5
	XORPS	%xmm6, %xmm6
	XORPS	%xmm7, %xmm7

	movl	BUFFER, %edx
	addl	$128, %edx

	movl	A, %ecx
	addl	$4 * SIZE, A
	movl	LDA, %ebx

	movaps	  0 * SIZE(%edx), %xmm1
	movaps	 16 * SIZE(%edx), %xmm3

	movl	%ebp, %eax
	sarl	$2,   %eax
	jle	.L63
	ALIGN_3

.L62:
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0
	addl	%ebx, %ecx
	movsd	  0 * SIZE(%ecx), %xmm2
	movhps	  2 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0,	%xmm1
	mulps	  4 * SIZE(%edx), %xmm0
	addps	%xmm1, %xmm4
	movaps	  8 * SIZE(%edx), %xmm1
	addps	%xmm0, %xmm5
	movsd	  0 * SIZE(%ecx), %xmm0
	mulps	%xmm2,	%xmm1
	mulps	 12 * SIZE(%edx), %xmm2
	addps	%xmm1, %xmm6
	movaps	 32 * SIZE(%edx), %xmm1
	addps	%xmm2, %xmm7

	movhps	  2 * SIZE(%ecx), %xmm0
	addl	%ebx, %ecx
	movsd	  0 * SIZE(%ecx), %xmm2
	movhps	  2 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0,	%xmm3
	mulps	 20 * SIZE(%edx), %xmm0
	addps	%xmm3, %xmm4
	movaps	 24 * SIZE(%edx), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2,	%xmm3
	mulps	 28 * SIZE(%edx), %xmm2
	addps	%xmm3, %xmm6
	movaps	 48 * SIZE(%edx), %xmm3
	addps	%xmm2, %xmm7

	addl	$32 * SIZE, %edx
	decl	%eax
	jg	.L62
	ALIGN_3

.L63:
	movl	%ebp, %eax
	andl	$3,   %eax
	jle	.L69
	ALIGN_3

.L64:
	movsd	  0 * SIZE(%ecx), %xmm0
	movhps	  2 * SIZE(%ecx), %xmm0

	mulps	%xmm0,	%xmm1
	addps	%xmm1, %xmm4
	movaps	  4 * SIZE(%edx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5
	movaps	  8 * SIZE(%edx), %xmm1

	addl	%ebx, %ecx
	addl	$8 * SIZE, %edx
	decl	%eax
	jg	.L64
	ALIGN_3

.L69:
	movl	BUFFER, %eax
	movl	INCY,   %ebx

	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	shufps	$0xb1, %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
#else
	addps	%xmm5, %xmm4
#endif
	movaps	%xmm4, %xmm5

	movaps	0 * SIZE(%eax), %xmm0
	movaps	4 * SIZE(%eax), %xmm1

	mulps	%xmm0, %xmm4
	mulps	%xmm1, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(%edi), %xmm0
	movhps	 0 * SIZE(%edi, %ebx), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi, %ebx)
	jmp	.L99
	ALIGN_3

.L70:
	cmpl	$1, %esi
	jne	.L99

	XORPS	%xmm4, %xmm4
	XORPS	%xmm5, %xmm5
	XORPS	%xmm6, %xmm6
	XORPS	%xmm7, %xmm7

	movl	BUFFER, %edx
	addl	$128, %edx

	movl	A, %ecx
	addl	$2 * SIZE, A
	movl	LDA, %ebx

	movaps	  0 * SIZE(%edx), %xmm1
	movaps	 16 * SIZE(%edx), %xmm3

	movl	%ebp, %eax
	sarl	$2,   %eax
	jle	.L73
	ALIGN_3

.L72:
	movsd	   0 * SIZE(%ecx), %xmm0
	addl	%ebx, %ecx
	movsd	   0 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0,	%xmm1
	mulps	   4 * SIZE(%edx), %xmm0
	addps	%xmm1, %xmm4
	movsd	   8 * SIZE(%edx), %xmm1
	addps	%xmm0, %xmm5
	movsd	   0 * SIZE(%ecx), %xmm0
	mulps	%xmm2,	%xmm1
	mulps	  12 * SIZE(%edx), %xmm2
	addps	%xmm1, %xmm6
	movsd	  32 * SIZE(%edx), %xmm1
	addps	%xmm2, %xmm7

	addl	%ebx, %ecx
	movsd	   0 * SIZE(%ecx), %xmm2
	addl	%ebx, %ecx

	mulps	%xmm0,	%xmm3
	mulps	  20 * SIZE(%edx), %xmm0
	addps	%xmm3, %xmm4
	movsd	  24 * SIZE(%edx), %xmm3
	addps	%xmm0, %xmm5
	mulps	%xmm2,	%xmm3
	mulps	  28 * SIZE(%edx), %xmm2
	addps	%xmm3, %xmm6
	movsd	  48 * SIZE(%edx), %xmm3
	addps	%xmm2, %xmm7

	addl	$32 * SIZE, %edx
	decl	%eax
	jg	.L72
	ALIGN_3

.L73:
	movl	%ebp, %eax
	andl	$3,   %eax
	jle	.L79
	ALIGN_3

.L74:
	movsd	 0 * SIZE(%ecx), %xmm0
	mulps	%xmm0,	%xmm1
	addps	%xmm1, %xmm4
	movsd	 4 * SIZE(%edx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5
	movsd	 8 * SIZE(%edx), %xmm1

	addl	%ebx, %ecx
	addl	$8 * SIZE, %edx
	decl	%eax
	jg	.L74
	ALIGN_3

.L79:
	addps	%xmm6, %xmm4
	addps	%xmm7, %xmm5

	movl	BUFFER, %eax
	shufps	$0xb1, %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subps	%xmm5, %xmm4
#else
	addps	%xmm5, %xmm4
#endif
	movaps	%xmm4, %xmm5

	movaps	0 * SIZE(%eax), %xmm0
	movaps	4 * SIZE(%eax), %xmm1

	mulps	%xmm0, %xmm4
	mulps	%xmm1, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(%edi), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%edi)
	ALIGN_3

.L99:
	movl	PLDA_M, %eax
	addl	%eax, A

	movl	IS,  %edx
#ifndef PARAMTEST
	addl	$P,  %edx
#else
	addl	 P,  %edx
#endif
	cmpl	N,   %edx
	jl	.L10
	ALIGN_3

.L999:
	EMMS

	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	addl	$ARGS, %esp
	ret

	EPILOGUE

