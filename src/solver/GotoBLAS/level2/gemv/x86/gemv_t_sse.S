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

#define P 2000

#ifdef PENTIUM3
#define movsd	movlps
#define PREFETCHSIZE 32
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE 96
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define movsd	movlpd
#define PREFETCHSIZE 64
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

#define ALPHA	 0(%esp)
#define M	16(%esp)
#define N	20(%esp)
#define A	24(%esp)
#define INCX	36(%esp)
#define Y	40(%esp)
#define INCY	44(%esp)
#define IS	48(%esp)
#define PLDA_M	52(%esp)

#define NLDA	56(%esp)
#define MIN_M	64(%esp)
#define J	68(%esp)
#define LDA	72(%esp)
#define BUFFER  76(%esp)
#define OLD_STACK 80(%esp)

#ifndef HAVE_SSE2
#define pxor	xorps
#endif

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

	movl	OLD_M, %ebx
	movl	OLD_N, %edx
	movl	OLD_A, %eax
	movl	OLD_LDA, %ecx
	movl	OLD_X, %edi

	movl	%ebx, M
	movl	%edx, N
	movl	%eax, A

	movl	OLD_INCX, %eax
	leal	(,%eax,SIZE), %eax
	movl	%eax, INCX

	movl	OLD_Y, %eax
	movl	%eax, Y

	movl	OLD_INCY, %eax
	leal	(, %eax, SIZE), %eax
	movl	%eax, INCY

	movl	%esi, OLD_STACK

	movss	OLD_ALPHA,  %xmm3
	shufps	$0, %xmm3, %xmm3
	movaps	 %xmm3, ALPHA

	testl	%ebx, %ebx
	jle	.L999
	testl	%edx, %edx
	jle	.L999

	imull	%ecx, %edx
	movl	$P,   %eax
	subl	%edx, %eax

	leal	(, %eax, SIZE), %eax
	leal	(, %ecx, SIZE), %ecx
	movl	%eax, NLDA
	movl	%ecx, LDA
	movl	$0,  %esi
	ALIGN_2

.L10:
	movl	$P, %edx
	movl	M,    %ecx
	subl	%esi, %ecx
	cmpl	%edx, %ecx
	cmovg	%edx, %ecx
	movl	%ecx, MIN_M
	movl	%esi, IS

	movl	BUFFER, %esi

	movl	INCX, %ebx
	cmpl	$SIZE, %ebx
	jne	.L15

	sarl	$3, %ecx
	jle	.L13
	ALIGN_3

.L12:
	movlps	0 * SIZE(%edi), %xmm0
	movhps	2 * SIZE(%edi), %xmm0
	movlps	4 * SIZE(%edi), %xmm4
	movhps	6 * SIZE(%edi), %xmm4
	addl	$8 * SIZE, %edi

	movaps	%xmm0, 0 * SIZE(%esi)
	movaps	%xmm4, 4 * SIZE(%esi)
	addl	$8 * SIZE, %esi

	decl	%ecx
	jg	.L12
	ALIGN_3

.L13:
	movl	MIN_M, %ecx
	andl	$7, %ecx
	jle	.L50
	ALIGN_2

.L14:
	movss	(%edi), %xmm0
	addl	$SIZE, %edi
	movss	%xmm0, 0 * SIZE(%esi)
	addl	$SIZE, %esi
	decl	%ecx
	jg	.L14
	jmp	.L50
	ALIGN_3

.L15:
	sarl	$3, %ecx
	jle	.L17
	ALIGN_3

.L16:
	movss	(%edi), %xmm0
	addl	%ebx, %edi
	movss	(%edi), %xmm1
	addl	%ebx, %edi

	movss	(%edi), %xmm2
	addl	%ebx, %edi
	movss	(%edi), %xmm3
	addl	%ebx, %edi

	movss	(%edi), %xmm4
	addl	%ebx, %edi
	movss	(%edi), %xmm5
	addl	%ebx, %edi

	movss	(%edi), %xmm6
	addl	%ebx, %edi
	movss	(%edi), %xmm7
	addl	%ebx, %edi

	movss	%xmm0, 0 * SIZE(%esi)
	movss	%xmm1, 1 * SIZE(%esi)
	movss	%xmm2, 2 * SIZE(%esi)
	movss	%xmm3, 3 * SIZE(%esi)
	movss	%xmm4, 4 * SIZE(%esi)
	movss	%xmm5, 5 * SIZE(%esi)
	movss	%xmm6, 6 * SIZE(%esi)
	movss	%xmm7, 7 * SIZE(%esi)

	addl	$8 * SIZE, %esi
	decl	%ecx
	jg	.L16
	ALIGN_3

.L17:
	movl	MIN_M, %ecx
	andl	$7, %ecx
	jle	.L50
	ALIGN_2

.L18:
	movss	(%edi), %xmm0
	addl	%ebx, %edi
	movss	%xmm0, 0 * SIZE(%esi)
	addl	$SIZE, %esi
	decl	%ecx
	jg	.L18
	ALIGN_3

/* Main Routine */

.L50:
	movl	Y, %ebp			# coffset = y
	movaps	ALPHA, %xmm3

	movl	N, %esi
	sarl	$2, %esi
	movl	%esi, J
	jle	.L100
	ALIGN_3

.L51:
	movl	A, %ebx				# a_offset = a
	movl	LDA, %edx

	leal	(%ebx, %edx), %ecx		# a_offset2 = a + lda
	leal	(%ebx, %edx, 4), %eax

	movl	%eax, A

	movl	BUFFER, %esi

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movaps	0 * SIZE(%esi), %xmm0
	movaps	8 * SIZE(%esi), %xmm2

	movl	MIN_M, %eax
	sarl	$4,  %eax
	jle	.L53
	ALIGN_3

.L52:
	movsd	0 * SIZE(%ebx), %xmm1
	movhps	2 * SIZE(%ebx), %xmm1
	mulps	%xmm0, %xmm1
#ifdef PENTIUM4
#	prefetchnta	PREFETCHSIZE * SIZE(%ebx)
#endif
	addps	%xmm1, %xmm4

	movsd	0 * SIZE(%ecx), %xmm1
	movhps	2 * SIZE(%ecx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	0 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	2 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movsd	0 * SIZE(%ecx, %edx, 2), %xmm1
	movhps	2 * SIZE(%ecx, %edx, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm7

	movaps	4 * SIZE(%esi), %xmm0

	movsd	4 * SIZE(%ebx), %xmm1
	movhps	6 * SIZE(%ebx), %xmm1
	mulps	%xmm0, %xmm1
#ifdef PENTIUM4
#	prefetchnta	PREFETCHSIZE * SIZE(%ecx)
#endif
	addps	%xmm1, %xmm4

	movsd	4 * SIZE(%ecx), %xmm1
	movhps	6 * SIZE(%ecx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	4 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	6 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movsd	4 * SIZE(%ecx, %edx, 2), %xmm1
	movhps	6 * SIZE(%ecx, %edx, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm7

	movaps	16 * SIZE(%esi), %xmm0

	movsd	 8 * SIZE(%ebx), %xmm1
	movhps	10 * SIZE(%ebx), %xmm1
	mulps	%xmm2, %xmm1
#ifdef PENTIUM4
#	prefetchnta	PREFETCHSIZE * SIZE(%ebx, %edx, 2)
#endif
	addps	%xmm1, %xmm4

	movsd	 8 * SIZE(%ecx), %xmm1
	movhps	10 * SIZE(%ecx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movsd	 8 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	10 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movsd	 8 * SIZE(%ecx, %edx, 2), %xmm1
	movhps	10 * SIZE(%ecx, %edx, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm7

	movaps	12 * SIZE(%esi), %xmm2

	movsd	12 * SIZE(%ebx), %xmm1
	movhps	14 * SIZE(%ebx), %xmm1
	mulps	%xmm2, %xmm1
#ifdef PENTIUM4
#	prefetchnta	PREFETCHSIZE * SIZE(%ecx, %edx, 2)
#endif
	addps	%xmm1, %xmm4

	movsd	12 * SIZE(%ecx), %xmm1
	movhps	14 * SIZE(%ecx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movsd	12 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	14 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movsd	12 * SIZE(%ecx, %edx, 2), %xmm1
	movhps	14 * SIZE(%ecx, %edx, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm7

	movaps	24 * SIZE(%esi), %xmm2

	addl	$16 * SIZE, %ebx
	addl	$16 * SIZE, %ecx
	addl	$16 * SIZE, %esi

	decl	%eax
	jg	.L52
	ALIGN_3

.L53:
	movl	MIN_M, %eax
	andl	$15,  %eax
	je	.L55
	ALIGN_3

.L54:
	movss	0 * SIZE(%ebx), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(%ecx), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	0 * SIZE(%ebx, %edx, 2), %xmm1
	addl	$SIZE, %ebx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm6

	movss	0 * SIZE(%ecx, %edx, 2), %xmm1
	addl	$SIZE, %ecx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm7

	movss	 1 * SIZE(%esi), %xmm0
	addl	$SIZE, %esi

	decl	%eax
	jg	.L54
	ALIGN_3

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

	mulss	%xmm3, %xmm4
	mulss	%xmm3, %xmm5
	mulss	%xmm3, %xmm6
	mulss	%xmm3, %xmm7

	movl	INCY, %eax
	movl	%ebp, %edx
	cmpl	$SIZE, %eax
	jne	.L56

	movss	0 * SIZE(%ebp), %xmm1
	movss	1 * SIZE(%ebp), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	2 * SIZE(%ebp), %xmm1
	movss	3 * SIZE(%ebp), %xmm2

	addss	%xmm1, %xmm6
	addss	%xmm2, %xmm7

	movss	%xmm4, 0 * SIZE(%ebp)
	movss	%xmm5, 1 * SIZE(%ebp)
	movss	%xmm6, 2 * SIZE(%ebp)
	movss	%xmm7, 3 * SIZE(%ebp)
	addl	$4 * SIZE, %ebp

	decl	J
	jg	.L51

 	movl	N, %esi
	andl	$3, %esi
	jne	.L100

	jmp	.L99
	ALIGN_3

.L56:
	movss	0 * SIZE(%edx), %xmm1
	addl	%eax, %edx
	movss	0 * SIZE(%edx), %xmm2
	addl	%eax, %edx

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	0 * SIZE(%edx), %xmm1
	addl	%eax, %edx
	movss	0 * SIZE(%edx), %xmm2

	addss	%xmm1, %xmm6
	addss	%xmm2, %xmm7

	movss	%xmm4, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm5, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm6, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm7, 0 * SIZE(%ebp)
	addl	%eax, %ebp

	decl	J
	jg	.L51

 	movl	N, %esi
	andl	$3, %esi
	jne	.L100

	ALIGN_3

.L99:
	movl	A, %ebx
	addl	NLDA, %ebx
	movl	%ebx, A

	movl	IS, %esi
	addl	$P, %esi
	cmpl	M,  %esi
	jl	.L10
	ALIGN_3

.L999:
	movl	OLD_STACK, %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	ALIGN_3

.L100:
	movl	N, %esi
	andl	$3, %esi
	cmpl	$3, %esi
	jne	.L110
	ALIGN_3

.L101:
	movl	A, %ebx				# a_offset = a
	movl	LDA, %edx

	leal	(%ebx, %edx), %ecx		# a_offset2 = a + lda
	leal	(%ebx, %edx, 2), %eax
	addl	%edx, %eax

	movl	%eax, A

	movl	BUFFER, %esi

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6

	movaps	0 * SIZE(%esi), %xmm0
	movaps	4 * SIZE(%esi), %xmm2

	movl	MIN_M, %eax
	sarl	$3,  %eax
	jle	.L103
	ALIGN_3

.L102:
	movsd	 0 * SIZE(%ebx), %xmm1
	movhps	 2 * SIZE(%ebx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 0 * SIZE(%ecx), %xmm1
	movhps	 2 * SIZE(%ecx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movsd	 0 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	 2 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm6

	movaps	 8 * SIZE(%esi), %xmm0

	movsd	 4 * SIZE(%ebx), %xmm1
	movhps	 6 * SIZE(%ebx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movsd	 4 * SIZE(%ecx), %xmm1
	movhps	 6 * SIZE(%ecx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movsd	 4 * SIZE(%ebx, %edx, 2), %xmm1
	movhps	 6 * SIZE(%ebx, %edx, 2), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm6

	movaps	12 * SIZE(%esi), %xmm2

	addl	$8 * SIZE, %ecx
	addl	$8 * SIZE, %ebx
	addl	$8 * SIZE, %esi

	decl	%eax
	jg	.L102
	ALIGN_3

.L103:
	movl	MIN_M, %eax
	andl	$7,  %eax
	je	.L105
	ALIGN_3

.L104:
	movss	0 * SIZE(%ebx), %xmm1
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(%ecx), %xmm1
	addl	$SIZE, %ecx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	0 * SIZE(%ebx, %edx, 2), %xmm1
	addl	$SIZE, %ebx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm6

	movss	 1 * SIZE(%esi), %xmm0
	addl	$SIZE, %esi

	decl	%eax
	jg	.L104
	ALIGN_3

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

	mulss	%xmm3, %xmm4
	mulss	%xmm3, %xmm5
	mulss	%xmm3, %xmm6

	movl	INCY, %eax
	movl	%ebp, %edx
	cmpl	$SIZE, %eax
	jne	.L106

	movss	0 * SIZE(%ebp), %xmm1
	movss	1 * SIZE(%ebp), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	2 * SIZE(%ebp), %xmm1

	addss	%xmm1, %xmm6

	movss	%xmm4, 0 * SIZE(%ebp)
	movss	%xmm5, 1 * SIZE(%ebp)
	movss	%xmm6, 2 * SIZE(%ebp)
	jmp	.L99
	ALIGN_3

.L106:
	movss	0 * SIZE(%edx), %xmm1
	addl	%eax, %edx
	movss	0 * SIZE(%edx), %xmm2
	addl	%eax, %edx

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	0 * SIZE(%edx), %xmm1
	addss	%xmm1, %xmm6

	movss	%xmm4, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm5, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm6, 0 * SIZE(%ebp)
	jmp	.L99
	ALIGN_3

.L110:
	cmpl	$2, %esi
	jne	.L120
	ALIGN_3

.L111:
	movl	A, %ebx				# a_offset = a
	movl	LDA, %edx

	leal	(%ebx, %edx), %ecx		# a_offset2 = a + lda
	leal	(%ebx, %edx, 2), %eax

	movl	%eax, A

	movl	BUFFER, %esi

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5

	movaps	0 * SIZE(%esi), %xmm0
	movaps	4 * SIZE(%esi), %xmm2

	movl	MIN_M, %eax
	sarl	$3,  %eax
	jle	.L113
	ALIGN_3

.L112:
	movsd	 0 * SIZE(%ebx), %xmm1
	movhps	 2 * SIZE(%ebx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movsd	 0 * SIZE(%ecx), %xmm1
	movhps	 2 * SIZE(%ecx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm5

	movaps	 8 * SIZE(%esi), %xmm0

	movsd	 4 * SIZE(%ebx), %xmm1
	movhps	 6 * SIZE(%ebx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movsd	 4 * SIZE(%ecx), %xmm1
	movhps	 6 * SIZE(%ecx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm5

	movaps	12 * SIZE(%esi), %xmm2
	addl	$8 * SIZE, %ebx
	addl	$8 * SIZE, %ecx
	addl	$8 * SIZE, %esi

	decl	%eax
	jg	.L112
	ALIGN_3

.L113:
	movl	MIN_M, %eax
	andl	$7,  %eax
	je	.L115
	ALIGN_3

.L114:
	movss	0 * SIZE(%ebx), %xmm1
	addl	$SIZE, %ebx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	0 * SIZE(%ecx), %xmm1
	addl	$SIZE, %ecx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm5

	movss	 1 * SIZE(%esi), %xmm0
	addl	$SIZE, %esi

	decl	%eax
	jg	.L114
	ALIGN_3

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

	mulss	%xmm3, %xmm4
	mulss	%xmm3, %xmm5

	movl	INCY, %eax
	movl	%ebp, %edx
	cmpl	$SIZE, %eax
	jne	.L116

	movss	0 * SIZE(%ebp), %xmm1
	movss	1 * SIZE(%ebp), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	%xmm4, 0 * SIZE(%ebp)
	movss	%xmm5, 1 * SIZE(%ebp)
	jmp	.L99
	ALIGN_3

.L116:
	movss	0 * SIZE(%edx), %xmm1
	addl	%eax, %edx
	movss	0 * SIZE(%edx), %xmm2

	addss	%xmm1, %xmm4
	addss	%xmm2, %xmm5

	movss	%xmm4, 0 * SIZE(%ebp)
	addl	%eax, %ebp
	movss	%xmm5, 0 * SIZE(%ebp)
	jmp	.L99
	ALIGN_3

.L120:
	movl	A, %ebx				# a_offset = a
	movl	LDA, %edx

	leal	(%ebx, %edx), %ecx		# a_offset2 = a + lda
	leal	(%ebx, %edx, 1), %eax

	movl	%eax, A

	movl	BUFFER, %esi

	pxor	%xmm4, %xmm4

	movaps	0 * SIZE(%esi), %xmm0
	movaps	4 * SIZE(%esi), %xmm2

	movl	MIN_M, %eax
	sarl	$3,  %eax
	jle	.L123
	ALIGN_3

.L122:
	movsd	 0 * SIZE(%ebx), %xmm1
	movhps	 2 * SIZE(%ebx), %xmm1
	mulps	%xmm0, %xmm1
	addps	%xmm1, %xmm4

	movaps	 8 * SIZE(%esi), %xmm0

	movsd	 4 * SIZE(%ebx), %xmm1
	movhps	 6 * SIZE(%ebx), %xmm1
	mulps	%xmm2, %xmm1
	addps	%xmm1, %xmm4

	movaps	12 * SIZE(%esi), %xmm2

	addl	$8 * SIZE, %ebx
	addl	$8 * SIZE, %esi

	decl	%eax
	jg	.L122
	ALIGN_3

.L123:
	movl	MIN_M, %eax
	andl	$7,  %eax
	je	.L125
	ALIGN_3

.L124:
	movss	0 * SIZE(%ebx), %xmm1
	addl	$SIZE, %ebx
	mulss	%xmm0, %xmm1
	addss	%xmm1, %xmm4

	movss	 1 * SIZE(%esi), %xmm0
	addl	$SIZE, %esi

	decl	%eax
	jg	.L124
	ALIGN_3

.L125:
	movaps	%xmm4, %xmm0
	shufps	$0xe, %xmm4, %xmm4
	addps	 %xmm0, %xmm4
	
	movaps	%xmm4, %xmm0
	shufps	$0x39, %xmm4, %xmm4
	addss	 %xmm0, %xmm4

	mulss	%xmm3, %xmm4

	movss	0 * SIZE(%ebp), %xmm1
	addss	%xmm1, %xmm4
	movss	%xmm4, 0 * SIZE(%ebp)
	jmp	.L99

	EPILOGUE
