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

#define STACK	16
#define ARGS	 0
	
#define STACK_M	 4 + STACK + ARGS(%esp)
#define ALPHA	16 + STACK + ARGS(%esp)
#define STACK_X	20 + STACK + ARGS(%esp)
#define STACK_INCX	24 + STACK + ARGS(%esp)
#define STACK_Y	28 + STACK + ARGS(%esp)
#define STACK_INCY	32 + STACK + ARGS(%esp)

#define M	 %ebx
#define X	 %esi
#define Y	 %edi
#define INCX	 %ecx
#define INCY	 %edx
#define YY	 %ebp


#if !defined(HAVE_SSE2) || defined(OPTERON)
#define movsd movlps
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE 88
#endif

#ifdef OPTERON
#define PREFETCHSIZE 88
#endif

	PROLOGUE

	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%ebp

	PROFCODE

	movss	ALPHA, %xmm7
	shufps	$0, %xmm7, %xmm7

	movl	STACK_M,    M
	movl	STACK_X,    X
	movl	STACK_INCX, INCX
	movl	STACK_Y,    Y
	movl	STACK_INCY, INCY

	leal	(, INCX, SIZE), INCX
	leal	(, INCY, SIZE), INCY

	testl	M, M
	jle	.L99
	
	cmpl	$SIZE, INCX
	jne	.L20
	cmpl	$SIZE, INCY
	jne	.L20

	testl	$SIZE, Y
	je	.L00

	movss	0 * SIZE(X), %xmm0
	mulss	%xmm7, %xmm0
	addss	0 * SIZE(Y), %xmm0
	movss	%xmm0, 0 * SIZE(Y)
	addl	$1 * SIZE, X
	addl	$1 * SIZE, Y
	decl	M
	jle	.L99
	ALIGN_3

.L00:
	cmpl	$1, M
	jle	.L19

	testl	$SIZE * 2, Y
	je	.L10

	movss	0 * SIZE(X), %xmm0
	movss	1 * SIZE(X), %xmm1
	mulss	%xmm7, %xmm0
	mulss	%xmm7, %xmm1
	addss	0 * SIZE(Y), %xmm0
	addss	1 * SIZE(Y), %xmm1
	movss	%xmm0, 0 * SIZE(Y)
	movss	%xmm1, 1 * SIZE(Y)
	addl	$2 * SIZE, X
	addl	$2 * SIZE, Y
	subl	$2, M
	jle	.L99
	ALIGN_3

.L10:
	movl	M,  %eax
	sarl	$5, %eax
	jle	.L15
	ALIGN_4

.L12:
#ifdef OPTERON
	prefetcht0	(PREFETCHSIZE +  0) * SIZE(X)
	prefetchw	(PREFETCHSIZE +  0) * SIZE(Y)
#endif

	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 0 * SIZE(Y), %xmm0
	movaps	%xmm0,  0 * SIZE(Y)

	movsd	 4 * SIZE(X), %xmm0
	movhps	 6 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 4 * SIZE(Y), %xmm0
	movaps	%xmm0,  4 * SIZE(Y)

	movsd	 8 * SIZE(X), %xmm0
	movhps	10 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 8 * SIZE(Y), %xmm0
	movaps	%xmm0,  8 * SIZE(Y)

	movsd	12 * SIZE(X), %xmm0
	movhps	14 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	12 * SIZE(Y), %xmm0
	movaps	%xmm0, 12 * SIZE(Y)

#ifdef OPTERON
	prefetcht0	(PREFETCHSIZE + 16) * SIZE(X)
	prefetchw	(PREFETCHSIZE + 16) * SIZE(Y)
#endif

#ifdef PENTIUM4
	prefetcht0	(PREFETCHSIZE +  0) * SIZE(X)
#endif

	movsd	16 * SIZE(X), %xmm1
	movhps	18 * SIZE(X), %xmm1
	mulps	%xmm7, %xmm1
	addps	16 * SIZE(Y), %xmm1
	movaps	%xmm1, 16 * SIZE(Y)

	movsd	20 * SIZE(X), %xmm1
	movhps	22 * SIZE(X), %xmm1
	mulps	%xmm7, %xmm1
	addps	20 * SIZE(Y), %xmm1
	movaps	%xmm1, 20 * SIZE(Y)

	movsd	24 * SIZE(X), %xmm1
	movhps	26 * SIZE(X), %xmm1
	mulps	%xmm7, %xmm1
	addps	24 * SIZE(Y), %xmm1
	movaps	%xmm1, 24 * SIZE(Y)

	movsd	28 * SIZE(X), %xmm1
	movhps	30 * SIZE(X), %xmm1
	mulps	%xmm7, %xmm1
	addps	28 * SIZE(Y), %xmm1
	movaps	%xmm1, 28 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0	(PREFETCHSIZE +  0) * SIZE(Y)
#endif

	addl	$32 * SIZE, Y
	addl	$32 * SIZE, X
	decl	%eax
	jg	.L12
	ALIGN_3

.L15:
	testl	$16, M
	jle	.L16

	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 0 * SIZE(Y), %xmm0
	movaps	%xmm0,  0 * SIZE(Y)

	movsd	 4 * SIZE(X), %xmm0
	movhps	 6 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 4 * SIZE(Y), %xmm0
	movaps	%xmm0,  4 * SIZE(Y)

	movsd	 8 * SIZE(X), %xmm0
	movhps	10 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 8 * SIZE(Y), %xmm0
	movaps	%xmm0,  8 * SIZE(Y)

	movsd	12 * SIZE(X), %xmm0
	movhps	14 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	12 * SIZE(Y), %xmm0
	movaps	%xmm0, 12 * SIZE(Y)

	addl	$16 * SIZE, Y
	addl	$16 * SIZE, X
	ALIGN_3

.L16:
	testl	$8, M
	jle	.L17

	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 0 * SIZE(Y), %xmm0
	movaps	%xmm0,  0 * SIZE(Y)

	movsd	 4 * SIZE(X), %xmm0
	movhps	 6 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 4 * SIZE(Y), %xmm0
	movaps	%xmm0,  4 * SIZE(Y)

	addl	$8 * SIZE, Y
	addl	$8 * SIZE, X
	ALIGN_3

.L17:
	testl	$4, M
	jle	.L18

	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	addps	 0 * SIZE(Y), %xmm0
	movaps	%xmm0,  0 * SIZE(Y)

	addl	$4 * SIZE, Y
	addl	$4 * SIZE, X
	ALIGN_3

.L18:
	testl	$2, M
	jle	.L19

	movsd	 0 * SIZE(X), %xmm0
	mulps	%xmm7, %xmm0
	movsd	 0 * SIZE(Y), %xmm1
	addps	%xmm1, %xmm0
	movlps	%xmm0,  0 * SIZE(Y)

	addl	$2 * SIZE, Y
	addl	$2 * SIZE, X
	ALIGN_3

.L19:
	testl	$1, M
	jle	.L99

	movss	 0 * SIZE(X), %xmm0
	mulss	%xmm7, %xmm0
	addss	 0 * SIZE(Y), %xmm0
	movss	%xmm0,  0 * SIZE(Y)
	jmp	.L99
	ALIGN_3


.L20:
	movl	Y, YY

	movl	M, %eax
	sarl	$3,   %eax
	jle	.L25
	ALIGN_3

.L22:
	movss	(X), %xmm0
	addl	INCX, X
	mulss	%xmm7, %xmm0
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm0

	movss	(X), %xmm1
	addl	INCX, X
	mulss	%xmm7, %xmm1
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm1

	movss	(X), %xmm2
	addl	INCX, X
	mulss	%xmm7, %xmm2
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm2

	movss	(X), %xmm3
	addl	INCX, X
	mulss	%xmm7, %xmm3
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm3

	movss	%xmm0, (Y)
	addl	INCY, Y
	movss	%xmm1, (Y)
	addl	INCY, Y
	movss	%xmm2, (Y)
	addl	INCY, Y
	movss	%xmm3, (Y)
	addl	INCY, Y

	movss	(X), %xmm0
	addl	INCX, X
	mulss	%xmm7, %xmm0
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm0

	movss	(X), %xmm1
	addl	INCX, X
	mulss	%xmm7, %xmm1
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm1

	movss	(X), %xmm2
	addl	INCX, X
	mulss	%xmm7, %xmm2
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm2

	movss	(X), %xmm3
	addl	INCX, X
	mulss	%xmm7, %xmm3
	movss	(YY), %xmm6
	addl	INCY, YY
	addss	%xmm6, %xmm3

	movss	%xmm0, (Y)
	addl	INCY, Y
	movss	%xmm1, (Y)
	addl	INCY, Y
	movss	%xmm2, (Y)
	addl	INCY, Y
	movss	%xmm3, (Y)
	addl	INCY, Y

	decl	%eax
	jg	.L22
	ALIGN_3

.L25:
	movl	M, %eax
	andl	$7,   %eax
	jle	.L99
	ALIGN_3

.L26:
	movss	(X), %xmm0
	addl	INCX, X
	mulss	%xmm7, %xmm0
	movss	(Y), %xmm6
	addss	%xmm6, %xmm0
	movss	%xmm0, (Y)
	addl	INCY, Y
	decl	%eax
	jg	.L26
	ALIGN_3

.L99:
	xorl	%eax,%eax
	popl	%ebp
	popl	%ebx
	popl	%esi
	popl	%edi
	ret

	EPILOGUE
