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

#ifdef CORE2
#define PREFETCHSIZE 48
#endif

#ifdef PENRYN
#define PREFETCHSIZE 48
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE 48
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define movsd	movlpd
#define PREFETCHSIZE 64
#endif

#define STACK	16
#define ARGS	 8
	
#define PLDA_M	  0 + STACK(%esp)
#define IS	  4 + STACK(%esp)

#define M	 4 + STACK + ARGS(%esp)
#define N	 8 + STACK + ARGS(%esp)
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	24 + STACK + ARGS(%esp)
#define A	32 + STACK + ARGS(%esp)
#define LDA	36 + STACK + ARGS(%esp)
#define X	40 + STACK + ARGS(%esp)
#define INCX	44 + STACK + ARGS(%esp)
#define Y	48 + STACK + ARGS(%esp)
#define INCY	52 + STACK + ARGS(%esp)
#define BUFFER	56 + STACK + ARGS(%esp)

	PROLOGUE

	subl	$ARGS, %esp
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	EMMS

	movl	BUFFER, %eax

	pcmpeqb	%mm7, %mm7
	psllq	$63, %mm7	

	movq	ALPHA_R,  %mm0
	movq	ALPHA_I,  %mm1

	movq	%mm0, 0 * SIZE(%eax)
	movq	%mm0, 1 * SIZE(%eax)
	movq	%mm1, 2 * SIZE(%eax)
	pxor	%mm7, %mm1
	movq	%mm1, 3 * SIZE(%eax)

	movl	INCX, %eax
	sall	$4, %eax
	movl	%eax, INCX

	movl	INCY, %edx
	sall	$4,   %edx
	movl	%edx, INCY

	movl	LDA,  %ecx
	sall	$4,   %ecx
	movl	%ecx,  LDA

	mov	M, %edx
	mov	N, %ebp
	
	imull	%ebp, %ecx
	subl	$2 * P * SIZE, %ecx
	movl	%ecx, PLDA_M

	xorl	%ebx,%ebx

	testl	%ebp, %ebp
	jle	.L999
	testl	%edx, %edx
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
	movq	0 * SIZE(%esi), %mm0
	movq	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi
	movq	0 * SIZE(%esi), %mm2
	movq	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movq	%mm0, 0 * SIZE(%edx)
	movq	%mm0, 1 * SIZE(%edx)
	movq	%mm1, 3 * SIZE(%edx)
	pxor	%mm7, %mm1
	movq	%mm1, 2 * SIZE(%edx)

	movq	%mm2, 4 * SIZE(%edx)
	movq	%mm2, 5 * SIZE(%edx)
	movq	%mm3, 7 * SIZE(%edx)
	pxor	%mm7, %mm3
	movq	%mm3, 6 * SIZE(%edx)

	movq	0 * SIZE(%esi), %mm0
	movq	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi

	movq	0 * SIZE(%esi), %mm2
	movq	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movq	%mm0,  8 * SIZE(%edx)
	movq	%mm0,  9 * SIZE(%edx)
	movq	%mm1, 11 * SIZE(%edx)
	pxor	%mm7, %mm1
	movq	%mm1, 10 * SIZE(%edx)

	movq	%mm2, 12 * SIZE(%edx)
	movq	%mm2, 13 * SIZE(%edx)
	movq	%mm3, 15 * SIZE(%edx)
	pxor	%mm7, %mm3
	movq	%mm3, 14 * SIZE(%edx)
#else
	movq	0 * SIZE(%esi), %mm0
	movq	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi
	movq	0 * SIZE(%esi), %mm2
	movq	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movq	%mm0, 0 * SIZE(%edx)
	pxor	%mm7, %mm0
	movq	%mm0, 1 * SIZE(%edx)
	movq	%mm1, 2 * SIZE(%edx)
	movq	%mm1, 3 * SIZE(%edx)

	movq	%mm2, 4 * SIZE(%edx)
	pxor	%mm7, %mm2
	movq	%mm2, 5 * SIZE(%edx)
	movq	%mm3, 6 * SIZE(%edx)
	movq	%mm3, 7 * SIZE(%edx)

	movq	0 * SIZE(%esi), %mm0
	movq	1 * SIZE(%esi), %mm1
	addl	%ebx,%esi

	movq	0 * SIZE(%esi), %mm2
	movq	1 * SIZE(%esi), %mm3
	addl	%ebx,%esi

	movq	%mm0,  8 * SIZE(%edx)
	pxor	%mm7, %mm0
	movq	%mm0,  9 * SIZE(%edx)
	movq	%mm1, 10 * SIZE(%edx)
	movq	%mm1, 11 * SIZE(%edx)

	movq	%mm2, 12 * SIZE(%edx)
	pxor	%mm7, %mm2
	movq	%mm2, 13 * SIZE(%edx)
	movq	%mm3, 14 * SIZE(%edx)
	movq	%mm3, 15 * SIZE(%edx)
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
	movq	0 * SIZE(%esi), %mm0
	movq	1 * SIZE(%esi), %mm1
	addl	%ebx, %esi

#ifndef CONJ
	movq	%mm0, 0 * SIZE(%edx)
	movq	%mm0, 1 * SIZE(%edx)
	movq	%mm1, 3 * SIZE(%edx)
	pxor	%mm7, %mm1
	movq	%mm1, 2 * SIZE(%edx)
#else
	movq	%mm0, 0 * SIZE(%edx)
	pxor	%mm7, %mm0
	movq	%mm0, 1 * SIZE(%edx)
	movq	%mm1, 2 * SIZE(%edx)
	movq	%mm1, 3 * SIZE(%edx)
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
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A,   %edx
	movl	LDA, %eax
	leal	(%edx, %eax), %ebx
	addl	%eax, %eax
	addl	%eax, A

	movl	BUFFER, %eax
	addl	$128, %eax

	movapd	 0 * SIZE(%eax), %xmm1
	movapd	 8 * SIZE(%eax), %xmm3

	movl	%ebp, %ecx
	sarl	$2,   %ecx
	jle	.L23
	ALIGN_3

.L22:
	movsd	 0 * SIZE(%edx), %xmm0
	movhpd	 1 * SIZE(%edx), %xmm0
	mulpd	%xmm0, %xmm1
	prefetchnta	PREFETCHSIZE * SIZE(%edx)
	addpd	%xmm1, %xmm4
	mulpd	 2 * SIZE(%eax), %xmm0
	addpd	%xmm0, %xmm5

	movapd	 0 * SIZE(%eax), %xmm1
	movsd	 0 * SIZE(%ebx), %xmm2
	movhpd	 1 * SIZE(%ebx), %xmm2
	mulpd	%xmm2, %xmm1
	addpd	%xmm1, %xmm6
	mulpd	 2 * SIZE(%eax), %xmm2
	addpd	%xmm2, %xmm7

	movapd	 4 * SIZE(%eax), %xmm1
	movsd	 2 * SIZE(%edx), %xmm0
	movhpd	 3 * SIZE(%edx), %xmm0
	mulpd	%xmm0, %xmm1
	addpd	%xmm1, %xmm4
	mulpd	 6 * SIZE(%eax), %xmm0
	addpd	%xmm0, %xmm5

	movapd	 4 * SIZE(%eax), %xmm1
	movsd	 2 * SIZE(%ebx), %xmm2
	movhpd	 3 * SIZE(%ebx), %xmm2
	mulpd	%xmm2, %xmm1
	addpd	%xmm1, %xmm6
	mulpd	 6 * SIZE(%eax), %xmm2
	addpd	%xmm2, %xmm7

	movapd	16 * SIZE(%eax), %xmm1

	movsd	 4 * SIZE(%edx), %xmm0
	movhpd	 5 * SIZE(%edx), %xmm0
	mulpd	%xmm0, %xmm3
	prefetchnta	PREFETCHSIZE * SIZE(%ebx)
	addpd	%xmm3, %xmm4
	mulpd	10 * SIZE(%eax), %xmm0
	addpd	%xmm0, %xmm5

	movapd	 8 * SIZE(%eax), %xmm3
	movsd	 4 * SIZE(%ebx), %xmm2
	movhpd	 5 * SIZE(%ebx), %xmm2
	mulpd	%xmm2, %xmm3
	addpd	%xmm3, %xmm6
	mulpd	10 * SIZE(%eax), %xmm2
	addpd	%xmm2, %xmm7

	movapd	12 * SIZE(%eax), %xmm3
	movsd	 6 * SIZE(%edx), %xmm0
	movhpd	 7 * SIZE(%edx), %xmm0
	addl	$ 8 * SIZE, %edx
	mulpd	%xmm0, %xmm3
	addpd	%xmm3, %xmm4
	mulpd	14 * SIZE(%eax), %xmm0
	addpd	%xmm0, %xmm5

	movapd	12 * SIZE(%eax), %xmm3
	movsd	 6 * SIZE(%ebx), %xmm2
	movhpd	 7 * SIZE(%ebx), %xmm2
	addl	$ 8 * SIZE, %ebx
	mulpd	%xmm2, %xmm3
	addpd	%xmm3, %xmm6
	mulpd	14 * SIZE(%eax), %xmm2
	addpd	%xmm2, %xmm7

	movapd	24 * SIZE(%eax), %xmm3

	addl	$16 * SIZE, %eax
	decl	%ecx
	jg	.L22
	ALIGN_3

.L23:
	movl	%ebp, %ecx
	andl	$3,   %ecx
	jle	.L29
	ALIGN_3

.L24:
	movsd	 0 * SIZE(%edx), %xmm0
	movhpd	 1 * SIZE(%edx), %xmm0
	addl	$2 * SIZE, %edx
	movsd	 0 * SIZE(%ebx), %xmm2
	movhpd	 1 * SIZE(%ebx), %xmm2
	addl	$2 * SIZE, %ebx

	mulpd	%xmm0, %xmm1
	mulpd	 2 * SIZE(%eax), %xmm0
	addpd	%xmm1, %xmm4
	movapd	 0 * SIZE(%eax), %xmm1
	addpd	%xmm0, %xmm5

	mulpd	%xmm2, %xmm1
	mulpd	 2 * SIZE(%eax), %xmm2
	addpd	%xmm1, %xmm6
	movapd	 4 * SIZE(%eax), %xmm1
	addpd	%xmm2, %xmm7
	addl	$4 * SIZE, %eax
	decl	%ecx
	jg	.L24
	ALIGN_3


.L29:
	SHUFPD_1 %xmm5, %xmm5
	SHUFPD_1 %xmm7, %xmm7

	movl	BUFFER, %ecx
	movl	INCY, %ebx
	movapd	0 * SIZE(%ecx), %xmm0
	movapd	2 * SIZE(%ecx), %xmm1

#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subpd	%xmm5, %xmm4
	subpd	%xmm7, %xmm6
#else
	addpd	%xmm5, %xmm4
	addpd	%xmm7, %xmm6
#endif
	movapd	%xmm4, %xmm5
	movapd	%xmm6, %xmm7

	mulpd	%xmm0, %xmm4
	mulpd	%xmm1, %xmm5
	mulpd	%xmm0, %xmm6
	mulpd	%xmm1, %xmm7

	SHUFPD_1 %xmm5, %xmm5
	SHUFPD_1 %xmm7, %xmm7

	addpd	%xmm5, %xmm4
	addpd	%xmm7, %xmm6

	movsd	 0 * SIZE(%esi), %xmm0
	movhpd	 1 * SIZE(%esi), %xmm0
	addpd	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%esi)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%esi)
	addl	%ebx, %esi

	movsd	 0 * SIZE(%esi), %xmm1
	movhpd	 1 * SIZE(%esi), %xmm1
	addpd	%xmm1, %xmm6
	movsd	%xmm6, 0 * SIZE(%esi)
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 1 * SIZE(%esi)
	addl	%ebx, %esi

	decl	%edi
	jg	.L21
	ALIGN_3

.L50:
	movl	N,  %edi
	testl	$1, %edi
	je	.L99

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A,   %edx
	movl	LDA, %eax
	leal	(%edx, %eax), %ecx
	movl	%ecx, A

	movl	BUFFER, %eax
	addl	$128, %eax

	movapd	 0 * SIZE(%eax), %xmm1
	movapd	 8 * SIZE(%eax), %xmm3

	movl	%ebp,%ecx
	sarl	$2,  %ecx
	jle	.L52
	ALIGN_3

.L51:
	movsd	 0 * SIZE(%edx), %xmm0
	movhpd	 1 * SIZE(%edx), %xmm0
	movsd	 2 * SIZE(%edx), %xmm2
	movhpd	 3 * SIZE(%edx), %xmm2

	mulpd	%xmm0, %xmm1
	mulpd	 2 * SIZE(%eax), %xmm0
	addpd	%xmm1, %xmm4
	movapd	 4 * SIZE(%eax), %xmm1
	addpd	%xmm0, %xmm5
	movsd	 4 * SIZE(%edx), %xmm0
	mulpd	%xmm2, %xmm1
	mulpd	 6 * SIZE(%eax), %xmm2
	addpd	%xmm1, %xmm6
	movapd	16 * SIZE(%eax), %xmm1
	addpd	%xmm2, %xmm7

	movhpd	 5 * SIZE(%edx), %xmm0
	movsd	 6 * SIZE(%edx), %xmm2
	movhpd	 7 * SIZE(%edx), %xmm2
	addl	$ 8 * SIZE,%edx

	mulpd	%xmm0, %xmm3
	mulpd	10 * SIZE(%eax), %xmm0
	addpd	%xmm3, %xmm4
	movapd	12 * SIZE(%eax), %xmm3
	addpd	%xmm0, %xmm5

	mulpd	%xmm2, %xmm3
	mulpd	14 * SIZE(%eax), %xmm2
	addpd	%xmm3, %xmm6
	movapd	24 * SIZE(%eax), %xmm3
	addpd	%xmm2, %xmm7

	addl	$16 * SIZE,%eax
	decl	%ecx
	jg	.L51
	ALIGN_3

.L52:
	movl	%ebp,%ecx
	andl	$3,  %ecx
	jle	.L59
	ALIGN_3

.L53:
	movsd	 0 * SIZE(%edx), %xmm0
	movhpd	 1 * SIZE(%edx), %xmm0
	addl	$2 * SIZE,%edx

	movapd	 0 * SIZE(%eax), %xmm1
	mulpd	%xmm0, %xmm1
	addpd	%xmm1, %xmm4
	mulpd	 2 * SIZE(%eax), %xmm0
	addpd	%xmm0, %xmm5
	addl	$4 * SIZE,%eax
	decl	%ecx
	jg	.L53
	ALIGN_3

.L59:
	addpd	%xmm6, %xmm4
	addpd	%xmm7, %xmm5
	
	SHUFPD_1 %xmm5, %xmm5
#if (!defined(XCONJ) && !defined(CONJ)) || (defined(XCONJ) && defined(CONJ))
	subpd	%xmm5, %xmm4
#else
	addpd	%xmm5, %xmm4
#endif
	movapd	%xmm4, %xmm5

	movl	BUFFER, %ecx
	movapd	0 * SIZE(%ecx), %xmm0
	movapd	2 * SIZE(%ecx), %xmm1

	mulpd	%xmm0,	%xmm4
	mulpd	%xmm1, %xmm5
	SHUFPD_1 %xmm5, %xmm5
	addpd	%xmm5, %xmm4

	movsd	 0 * SIZE(%esi), %xmm0
	movhpd	 1 * SIZE(%esi), %xmm0
	addpd	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%esi)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%esi)
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
