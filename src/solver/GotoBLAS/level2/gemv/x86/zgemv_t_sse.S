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

#ifdef PENTIUM3
#define PREFETCHSIZE 96
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE 96
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define movsd	movlps
#define PREFETCHSIZE 128
#endif

#ifndef HAVE_SSE2
#define movsd	movlps
#define unpckhpd movhlps
#define XORPS	xorps
#else
#define XORPS	pxor
#endif

#define STACK	16
#define ARGS	16
	
#define PLDA_M	  0 + STACK(%esp)
#define IS	  4 + STACK(%esp)
#define I         8 + STACK(%esp)

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
	sall	$3, %eax
	movl	%eax, INCX

	movl	INCY, %edx
	sall	$3,   %edx
	movl	%edx, INCY

	movl	LDA,  %ecx
	sall	$3,   %ecx
	movl	%ecx,  LDA

	movl	M,    %edx
	movl	N,    %ebp

	imull	%ebp, %ecx
	subl	$2 * P * SIZE, %ecx
	movl	%ecx, PLDA_M
	
	movl	BUFFER, %eax

	pcmpeqb	%mm7, %mm7
	pslld	$31, %mm7	

	movd	ALPHA_R,  %mm0
	movd	ALPHA_I,  %mm1

	movd	%mm0, 0 * SIZE(%eax)
	movd	%mm0, 1 * SIZE(%eax)
	movd	%mm0, 2 * SIZE(%eax)
	movd	%mm0, 3 * SIZE(%eax)
	movd	%mm1, 4 * SIZE(%eax)
	movd	%mm1, 6 * SIZE(%eax)
	pxor	%mm7, %mm1
	movd	%mm1, 5 * SIZE(%eax)
	movd	%mm1, 7 * SIZE(%eax)

	xorl	%ebx, %ebx

	testl	%edx, %edx
	jle	.L999
	testl	%ebp, %ebp
	jle	.L999
	ALIGN_3

.L10:
	movl	M,    %ebp
	movl	$P,   %eax
	subl	%ebx, %ebp
	cmpl	%eax, %ebp
	cmovg	%eax, %ebp

	movl	BUFFER, %edx
	addl	$128, %edx

	movl	%ebx, IS

	movl	INCX, %ebx
	movl	X, %esi

	movl	%ebp, %ecx
	sarl	$2,   %ecx
	jle	.L12
	ALIGN_3

.L11:
#ifndef CONJ
	movd	0 * SIZE(%esi), %mm0
	movd	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi
	movd	0 * SIZE(%esi), %mm2
	movd	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movd	%mm0, 0 * SIZE(%edx)
	movd	%mm0, 1 * SIZE(%edx)
	movd	%mm2, 2 * SIZE(%edx)
	movd	%mm2, 3 * SIZE(%edx)

	movd	%mm1, 5 * SIZE(%edx)
	pxor	%mm7, %mm1
	movd	%mm1, 4 * SIZE(%edx)
	movd	%mm3, 7 * SIZE(%edx)
	pxor	%mm7, %mm3
	movd	%mm3, 6 * SIZE(%edx)

	movd	0 * SIZE(%esi), %mm0
	movd	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi

	movd	0 * SIZE(%esi), %mm2
	movd	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movd	%mm0,  8 * SIZE(%edx)
	movd	%mm0,  9 * SIZE(%edx)
	movd	%mm2, 10 * SIZE(%edx)
	movd	%mm2, 11 * SIZE(%edx)

	movd	%mm1, 13 * SIZE(%edx)
	pxor	%mm7, %mm1
	movd	%mm1, 12 * SIZE(%edx)
	movd	%mm3, 15 * SIZE(%edx)
	pxor	%mm7, %mm3
	movd	%mm3, 14 * SIZE(%edx)
#else
	movd	0 * SIZE(%esi), %mm0
	movd	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi
	movd	0 * SIZE(%esi), %mm2
	movd	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movd	%mm0, 0 * SIZE(%edx)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(%edx)
	movd	%mm2, 2 * SIZE(%edx)
	pxor	%mm7, %mm2
	movd	%mm2, 3 * SIZE(%edx)

	movd	%mm1, 4 * SIZE(%edx)
	movd	%mm1, 5 * SIZE(%edx)
	movd	%mm3, 6 * SIZE(%edx)
	movd	%mm3, 7 * SIZE(%edx)

	movd	0 * SIZE(%esi), %mm0
	movd	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi

	movd	0 * SIZE(%esi), %mm2
	movd	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movd	%mm0,  8 * SIZE(%edx)
	pxor	%mm7, %mm0
	movd	%mm0,  9 * SIZE(%edx)
	movd	%mm2, 10 * SIZE(%edx)
	pxor	%mm7, %mm2
	movd	%mm2, 11 * SIZE(%edx)

	movd	%mm1, 12 * SIZE(%edx)
	movd	%mm1, 13 * SIZE(%edx)
	movd	%mm3, 14 * SIZE(%edx)
	movd	%mm3, 15 * SIZE(%edx)
#endif
	addl	$16 * SIZE, %edx
	decl	%ecx
	jg	.L11
	ALIGN_3

.L12:
	movl	%ebp, %ecx
	andl	$3,   %ecx
	jle	.L20
	ALIGN_3

.L13:
	movd	0 * SIZE(%esi), %mm0
	movd	1 * SIZE(%esi), %mm1
	addl	%ebx, %esi

#ifndef CONJ
	movd	%mm0, 0 * SIZE(%edx)
	movd	%mm0, 1 * SIZE(%edx)
	movd	%mm1, 3 * SIZE(%edx)
	pxor	%mm7, %mm1
	movd	%mm1, 2 * SIZE(%edx)
#else
	movd	%mm0, 0 * SIZE(%edx)
	pxor	%mm7, %mm0
	movd	%mm0, 1 * SIZE(%edx)
	movd	%mm1, 2 * SIZE(%edx)
	movd	%mm1, 3 * SIZE(%edx)
#endif

	addl	$4 * SIZE, %edx
	decl	%ecx
	jg	.L13
	ALIGN_3

.L20:
	movl	%esi, X
	movl	Y,   %esi
	movl	N,   %edi
	sarl	$1,  %edi
	jle	.L50
	ALIGN_3
	
.L21:
	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movl	A,   %edx
	movl	LDA, %eax
	leal	(%edx, %eax, 1), %ebx
	leal	(%edx, %eax, 2), %ecx
	movl	%ecx, A

	movl	BUFFER, %eax
	addl	$128, %eax

	movaps	 0 * SIZE(%eax), %xmm1
	movaps	16 * SIZE(%eax), %xmm3

	movl	%ebp, %ecx
	sarl	$3,   %ecx
	jle	.L23
	ALIGN_3

.L22:
#if defined(OPTERON) || defined(BARCELONA)
	prefetcht0	PREFETCHSIZE * SIZE(%edx)
#endif

	movsd	 0 * SIZE(%edx), %xmm0
	movhps	 2 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm1
#ifdef PENTIUM3
	prefetcht0	PREFETCHSIZE * SIZE(%edx)
#endif
#ifdef PENTIUM4
	prefetchnta	PREFETCHSIZE * SIZE(%edx)
#endif
	addps	%xmm1, %xmm4
	mulps	 4 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	 0 * SIZE(%eax), %xmm1
	movsd	 0 * SIZE(%ebx), %xmm2
	movhps	 2 * SIZE(%ebx), %xmm2
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6
	mulps	 4 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	 8 * SIZE(%eax), %xmm1
	movsd	 4 * SIZE(%edx), %xmm0
	movhps	 6 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4
	mulps	12 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	 8 * SIZE(%eax), %xmm1
	movsd	 4 * SIZE(%ebx), %xmm2
	movhps	 6 * SIZE(%ebx), %xmm2
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6
	mulps	12 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	32 * SIZE(%eax), %xmm1

	movsd	 8 * SIZE(%edx), %xmm0
	movhps	10 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm3
#ifdef PENTIUM3
	prefetcht0	PREFETCHSIZE * SIZE(%ebx)
#endif
#ifdef PENTIUM4
	prefetchnta	PREFETCHSIZE * SIZE(%ebx)
#endif
#if defined(OPTERON) || defined(BARCELONA)
	prefetcht0	PREFETCHSIZE * SIZE(%ebx)
#endif
	addps	%xmm3, %xmm4
	mulps	20 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	16 * SIZE(%eax), %xmm3
	movsd	 8 * SIZE(%ebx), %xmm2
	movhps	10 * SIZE(%ebx), %xmm2
	mulps	%xmm2, %xmm3
	addps	%xmm3, %xmm6
	mulps	20 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	24 * SIZE(%eax), %xmm3
	movsd	12 * SIZE(%edx), %xmm0
	movhps	14 * SIZE(%edx), %xmm0
	addl	$16 * SIZE, %edx
	mulps	%xmm0, %xmm3
	addps	%xmm3, %xmm4
	mulps	28 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	24 * SIZE(%eax), %xmm3
	movsd	12 * SIZE(%ebx), %xmm2
	movhps	14 * SIZE(%ebx), %xmm2
	addl	$16 * SIZE, %ebx
	mulps	%xmm2, %xmm3
	addps	%xmm3, %xmm6
	mulps	28 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	48 * SIZE(%eax), %xmm3
	addl	$32 * SIZE, %eax

	decl	%ecx
	jg	.L22
	ALIGN_3

.L23:
	testl	$4,   %ebp
	je	.L25

	movsd	 0 * SIZE(%edx), %xmm0
	movhps	 2 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4
	mulps	 4 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	 0 * SIZE(%eax), %xmm1
	movsd	 0 * SIZE(%ebx), %xmm2
	movhps	 2 * SIZE(%ebx), %xmm2
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6
	mulps	 4 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	 8 * SIZE(%eax), %xmm1
	movsd	 4 * SIZE(%edx), %xmm0
	movhps	 6 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4
	mulps	12 * SIZE(%eax), %xmm0
	addps	%xmm0, %xmm5

	movaps	 8 * SIZE(%eax), %xmm1
	movsd	 4 * SIZE(%ebx), %xmm2
	movhps	 6 * SIZE(%ebx), %xmm2
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6
	mulps	12 * SIZE(%eax), %xmm2
	addps	%xmm2, %xmm7

	movaps	16 * SIZE(%eax), %xmm0
	addl	$8  * SIZE, %edx
	addl	$8  * SIZE, %ebx
	addl	$16 * SIZE, %eax
	ALIGN_3

.L25:
#if !defined(HAVE_SSE2) || defined(movsd)
	xorps	%xmm0, %xmm0
	xorps	%xmm0, %xmm0
	xorps	%xmm2, %xmm2
#endif
	movl	%ebp, %ecx
	andl	$3,   %ecx
	jle	.L29
	ALIGN_3

.L28:
	movsd	 0 * SIZE(%eax), %xmm1
	movsd	 0 * SIZE(%edx), %xmm0
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 2 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	 0 * SIZE(%ebx), %xmm2
	movsd	 0 * SIZE(%eax), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movsd	 2 * SIZE(%eax), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm7

	addl	$2 * SIZE, %edx
	addl	$2 * SIZE, %ebx
	addl	$4 * SIZE, %eax

	decl	%ecx
	jg	.L28
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

	movl	BUFFER, %ecx
	movl	INCY, %ebx
	movaps	0 * SIZE(%ecx), %xmm0
	movaps	4 * SIZE(%ecx), %xmm1

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

	movsd	 0 * SIZE(%esi), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%esi)
	addl	%ebx, %esi

	movsd	 0 * SIZE(%esi), %xmm1
	addps	%xmm1, %xmm6
	movsd	%xmm6, 0 * SIZE(%esi)
	addl	%ebx, %esi

	decl	%edi
	jg	.L21
	ALIGN_3

.L50:
	movl	N,  %edi
	andl	$1, %edi
	je	.L99

	xorps	%xmm4, %xmm4
	xorps	%xmm5, %xmm5
	xorps	%xmm6, %xmm6
	xorps	%xmm7, %xmm7

	movl	A,   %edx
	movl	LDA, %eax
	leal	(%edx, %eax), %ecx
	movl	%ecx, A

	movl	BUFFER, %eax
	addl	$128, %eax

	movl	%ebp,%ecx
	sarl	$2,  %ecx
	jle	.L52
	ALIGN_3

.L51:
	movsd	 0 * SIZE(%edx), %xmm0
	movhps	 2 * SIZE(%edx), %xmm0

	movaps	 0 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movaps	 4 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	 4 * SIZE(%edx), %xmm0
 	movhps	 6 * SIZE(%edx), %xmm0

	movaps	 8 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movaps	12 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm7

	addl	$8 * SIZE, %edx
	addl	$16 * SIZE, %eax

	decl	%ecx
	jg	.L51
	ALIGN_3

.L52:
	movl	%ebp,%ecx
#if !defined(HAVE_SSE2) || defined(movsd)
	xorps	%xmm0, %xmm0
#endif
	andl	$3,  %ecx
	jle	.L59
	ALIGN_3

.L53:
	movsd	 0 * SIZE(%edx), %xmm0
	addl	$2 * SIZE, %edx

	movsd	 0 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 2 * SIZE(%eax), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	addl	$4 * SIZE, %eax
	decl	%ecx
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

	movl	BUFFER, %ecx
	movaps	0 * SIZE(%ecx), %xmm0
	movaps	4 * SIZE(%ecx), %xmm1

	mulps	%xmm0,	%xmm4
	mulps	%xmm1, %xmm5
	shufps	$0xb1, %xmm5, %xmm5
	addps	%xmm5, %xmm4

	movsd	 0 * SIZE(%esi), %xmm0
	addps	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%esi)
	ALIGN_3

.L99:
	movl	PLDA_M, %esi
	subl	%esi, A

	movl	IS, %ebx
	addl	$P, %ebx
	cmpl	M,  %ebx
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
