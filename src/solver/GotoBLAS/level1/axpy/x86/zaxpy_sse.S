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
#ifdef DOUBLE
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	24 + STACK + ARGS(%esp)
#define STACK_X	32 + STACK + ARGS(%esp)
#define STACK_INCX	36 + STACK + ARGS(%esp)
#define STACK_Y	40 + STACK + ARGS(%esp)
#define STACK_INCY	44 + STACK + ARGS(%esp)
#else
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	20 + STACK + ARGS(%esp)
#define STACK_X	24 + STACK + ARGS(%esp)
#define STACK_INCX	28 + STACK + ARGS(%esp)
#define STACK_Y	32 + STACK + ARGS(%esp)
#define STACK_INCY	36 + STACK + ARGS(%esp)
#endif

#ifndef HAVE_SSE2
#define pxor	xorps
#define movsd	movlps
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE	128
#endif

#ifdef OPTERON
#define PREFETCHSIZE	176
#define movsd		movlps
#endif

	PROLOGUE

	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%ebp

#define M	%ebx
#define X	%esi
#define INCX	%ecx
#define Y	%edi
#define INCY	%edx
#define YY	%ebp

	PROFCODE

#ifndef CONJ
	movss	ALPHA_R, %xmm6
	movss	ALPHA_I, %xmm5

	shufps	$0x00, %xmm6, %xmm6
	shufps	$0x00, %xmm5, %xmm5

	pxor	%xmm7, %xmm7
	subps	%xmm5, %xmm7

	unpcklps %xmm5, %xmm7
#else
	movss	ALPHA_R, %xmm6
	movss	ALPHA_I, %xmm7

	shufps	$0x00, %xmm6, %xmm6
	shufps	$0x00, %xmm7, %xmm7

	pxor	%xmm5, %xmm5
	subps	%xmm6, %xmm5

	unpcklps %xmm5, %xmm6
#endif

	movl	STACK_M,    M
	movl	STACK_X,    X
	movl	STACK_INCX, INCX
	movl	STACK_Y,    Y
	movl	STACK_INCY, INCY

	leal	(, INCX, SIZE), INCX
	leal	(, INCY, SIZE), INCY

	addl	INCX, INCX
	addl	INCY, INCY

	cmpl	$2 * SIZE, INCX
	jne	.L20
	cmpl	$2 * SIZE, INCY
	jne	.L20

	movl	M,  %eax
	sarl	$3, %eax
	jle	.L15
	ALIGN_3

.L12:
#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	movsd	 0 * SIZE(X), %xmm1
	movhps	 2 * SIZE(X), %xmm1
	movsd	 0 * SIZE(Y), %xmm2
	movhps	 2 * SIZE(Y), %xmm2
	movsd	 4 * SIZE(X), %xmm4
	movhps	 6 * SIZE(X), %xmm4
	movsd	 4 * SIZE(Y), %xmm5
	movhps	 6 * SIZE(Y), %xmm5

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  0 * SIZE(Y)
	movhps	%xmm2,  2 * SIZE(Y)
	movsd	%xmm5,  4 * SIZE(Y)
	movhps	%xmm5,  6 * SIZE(Y)

	movsd	 8 * SIZE(X), %xmm1
	movhps	10 * SIZE(X), %xmm1
	movsd	 8 * SIZE(Y), %xmm2
	movhps	10 * SIZE(Y), %xmm2
	movsd	12 * SIZE(X), %xmm4
	movhps	14 * SIZE(X), %xmm4
	movsd	12 * SIZE(Y), %xmm5
	movhps	14 * SIZE(Y), %xmm5

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  8 * SIZE(Y)
	movhps	%xmm2, 10 * SIZE(Y)
	movsd	%xmm5, 12 * SIZE(Y)
	movhps	%xmm5, 14 * SIZE(Y)

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y

	decl	%eax
	jg	.L12
	ALIGN_3

.L15:
	testl	$4, M
	jle	.L16

	movsd	 0 * SIZE(X), %xmm1
	movhps	 2 * SIZE(X), %xmm1
	movsd	 0 * SIZE(Y), %xmm2
	movhps	 2 * SIZE(Y), %xmm2
	movsd	 4 * SIZE(X), %xmm4
	movhps	 6 * SIZE(X), %xmm4
	movsd	 4 * SIZE(Y), %xmm5
	movhps	 6 * SIZE(Y), %xmm5

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  0 * SIZE(Y)
	movhps	%xmm2,  2 * SIZE(Y)
	movsd	%xmm5,  4 * SIZE(Y)
	movhps	%xmm5,  6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L16:
	testl	$2, M
	jle	.L17

	movsd	 0 * SIZE(X), %xmm1
	movhps	 2 * SIZE(X), %xmm1
	movsd	 0 * SIZE(Y), %xmm2
	movhps	 2 * SIZE(Y), %xmm2

	movaps	 %xmm1, %xmm0
	shufps	 $0xb1, %xmm1, %xmm1

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	addps	%xmm1, %xmm0
	addps	%xmm0, %xmm2

	movsd	%xmm2,  0 * SIZE(Y)
	movhps	%xmm2,  2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L17:
	testl	$1, M
	jle	.L99

	movsd	 0 * SIZE(X), %xmm1
	movsd	 0 * SIZE(Y), %xmm2

	movaps	 %xmm1, %xmm0
	shufps	 $0xb1, %xmm1, %xmm1

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	addps	%xmm1, %xmm0
	addps	%xmm0, %xmm2

	movsd	%xmm2,  0 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L20:
	movl	Y, YY

	movl	M,  %eax
	sarl	$3, %eax
	jle	.L25
	ALIGN_3

.L22:
	movsd	 (X), %xmm1
	addl	 INCX, X
	movhps	 (X), %xmm1
	addl	 INCX, X
	movsd	 (Y), %xmm2
	addl	 INCY, Y
	movhps	 (Y), %xmm2
	addl	 INCY, Y
	movsd	 (X), %xmm4
	addl	 INCX, X
	movhps	 (X), %xmm4
	addl	 INCX, X
	movsd	 (Y), %xmm5
	addl	 INCY, Y
	movhps	 (Y), %xmm5
	addl	 INCY, Y

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  (YY)
	addl	 INCY, YY
	movhps	%xmm2,  (YY)
	addl	 INCY, YY
	movsd	%xmm5,  (YY)
	addl	 INCY, YY
	movhps	%xmm5,  (YY)
	addl	 INCY, YY

	movsd	 (X), %xmm1
	addl	 INCX, X
	movhps	 (X), %xmm1
	addl	 INCX, X
	movsd	 (Y), %xmm2
	addl	 INCY, Y
	movhps	 (Y), %xmm2
	addl	 INCY, Y
	movsd	 (X), %xmm4
	addl	 INCX, X
	movhps	 (X), %xmm4
	addl	 INCX, X
	movsd	 (Y), %xmm5
	addl	 INCY, Y
	movhps	 (Y), %xmm5
	addl	 INCY, Y

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  (YY)
	addl	 INCY, YY
	movhps	%xmm2,  (YY)
	addl	 INCY, YY
	movsd	%xmm5,  (YY)
	addl	 INCY, YY
	movhps	%xmm5,  (YY)
	addl	 INCY, YY

	decl	%eax
	jg	.L22
	ALIGN_3

.L25:
	testl	$4, M
	jle	.L26

	movsd	 (X), %xmm1
	addl	 INCX, X
	movhps	 (X), %xmm1
	addl	 INCX, X
	movsd	 (Y), %xmm2
	addl	 INCY, Y
	movhps	 (Y), %xmm2
	addl	 INCY, Y
	movsd	 (X), %xmm4
	addl	 INCX, X
	movhps	 (X), %xmm4
	addl	 INCX, X
	movsd	 (Y), %xmm5
	addl	 INCY, Y
	movhps	 (Y), %xmm5
	addl	 INCY, Y

	movaps	 %xmm1, %xmm0
	movaps	 %xmm4, %xmm3
	shufps	 $0xb1, %xmm1, %xmm1
	shufps	 $0xb1, %xmm4, %xmm4

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	mulps	%xmm6, %xmm3
	mulps	%xmm7, %xmm4

	addps	%xmm1, %xmm0
	addps	%xmm4, %xmm3
	addps	%xmm0, %xmm2
	addps	%xmm3, %xmm5

	movsd	%xmm2,  (YY)
	addl	 INCY, YY
	movhps	%xmm2,  (YY)
	addl	 INCY, YY
	movsd	%xmm5,  (YY)
	addl	 INCY, YY
	movhps	%xmm5,  (YY)
	addl	 INCY, YY
	ALIGN_3

.L26:
	testl	$2, M
	jle	.L27

	movsd	 (X), %xmm1
	addl	 INCX, X
	movhps	 (X), %xmm1
	addl	 INCX, X
	movsd	 (Y), %xmm2
	addl	 INCY, Y
	movhps	 (Y), %xmm2
	addl	 INCY, Y

	movaps	 %xmm1, %xmm0
	shufps	 $0xb1, %xmm1, %xmm1

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	addps	%xmm1, %xmm0
	addps	%xmm0, %xmm2

	movsd	%xmm2,  (YY)
	addl	 INCY, YY
	movhps	%xmm2,  (YY)
	addl	 INCY, YY
	ALIGN_3

.L27:
	testl	$1, M
	jle	.L99

	movsd	 (X), %xmm1
	movsd	 (Y), %xmm2

	movaps	 %xmm1, %xmm0
	shufps	 $0xb1, %xmm1, %xmm1

	mulps	%xmm6, %xmm0
	mulps	%xmm7, %xmm1
	addps	%xmm1, %xmm0
	addps	%xmm0, %xmm2

	movsd	%xmm2,  0 * SIZE(YY)
	ALIGN_3

.L99:
	xorl	%eax,%eax

	popl	%ebp
	popl	%ebx
	popl	%esi
	popl	%edi
	ret

	EPILOGUE

