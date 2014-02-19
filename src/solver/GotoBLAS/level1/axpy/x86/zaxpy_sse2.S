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
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	24 + STACK + ARGS(%esp)
#define STACK_X	32 + STACK + ARGS(%esp)
#define STACK_INCX	36 + STACK + ARGS(%esp)
#define STACK_Y	40 + STACK + ARGS(%esp)
#define STACK_INCY	44 + STACK + ARGS(%esp)

#ifdef PENTIUM4
#define PREFETCHSIZE	220
#endif

#ifdef OPTERON
#define PREFETCHSIZE	 88
#define movsd	movlpd
#endif

#define M	%ebx
#define X	%esi
#define	INCX	%ecx
#define Y	%edi
#define INCY	%edx
#define YY	%ebp


	PROLOGUE

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	movl	STACK_M,    M
	movl	STACK_X,    X
	movl	STACK_INCX, INCX
	movl	STACK_Y,    Y
	movl	STACK_INCY, INCY

#ifndef CONJ
	movsd	ALPHA_R, %xmm6
	movsd	ALPHA_I, %xmm5

	pxor	%xmm7, %xmm7
	subsd	%xmm5, %xmm7

	unpcklpd %xmm6, %xmm6
	unpcklpd %xmm5, %xmm7
#else
	movsd	ALPHA_R, %xmm6
	movsd	ALPHA_I, %xmm7

	pxor	%xmm5, %xmm5
	subsd	%xmm6, %xmm5

	unpcklpd %xmm5, %xmm6
	unpcklpd %xmm7, %xmm7
#endif

	leal	(, INCX, SIZE), INCX
	leal	(, INCY, SIZE), INCY

	addl	INCX, INCX
	addl	INCY, INCY

	cmpl	$2 * SIZE, INCX
	jne	.L50
	cmpl	$2 * SIZE, INCY
	jne	.L50

	testl	$SIZE, Y
	jne	.L30

	testl	$SIZE, X
	jne	.L20

	movl	M, %eax
	sarl	$3,   %eax
	jle	.L15
	ALIGN_3

.L12:
#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	movapd	 4 * SIZE(X),  %xmm0
	movapd	 6 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 4 * SIZE(Y), %xmm4
	movapd	 6 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   4 * SIZE(Y)
	movapd	%xmm5,   6 * SIZE(Y)

#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 8) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 8) * SIZE(Y)
#endif

	movapd	 8 * SIZE(X),  %xmm0
	movapd	10 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)

	movapd	12 * SIZE(X),  %xmm0
	movapd	14 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	12 * SIZE(Y), %xmm4
	movapd	14 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,  12 * SIZE(Y)
	movapd	%xmm5,  14 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L12
	ALIGN_3

.L15:
	testl	$4, M
	jle	.L16

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	movapd	 4 * SIZE(X),  %xmm0
	movapd	 6 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 4 * SIZE(Y), %xmm4
	movapd	 6 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   4 * SIZE(Y)
	movapd	%xmm5,   6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L16:
	testl	$2, M
	jle	.L17

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L17:
	testl	$1, M
	jle	.L99

	movapd	 0 * SIZE(X),  %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 0 * SIZE(Y), %xmm4

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movapd	%xmm4,   0 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L20:
	movl	M, %eax
	sarl	$3,   %eax
	jle	.L25
	ALIGN_3

.L22:
#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	movsd	 4 * SIZE(X),  %xmm0
	movhpd	 5 * SIZE(X),  %xmm0
	movsd	 6 * SIZE(X),  %xmm2
	movhpd	 7 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 4 * SIZE(Y), %xmm4
	movapd	 6 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   4 * SIZE(Y)
	movapd	%xmm5,   6 * SIZE(Y)

#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 8) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 8) * SIZE(Y)
#endif

	movsd	 8 * SIZE(X),  %xmm0
	movhpd	 9 * SIZE(X),  %xmm0
	movsd	10 * SIZE(X),  %xmm2
	movhpd	11 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)

	movsd	12 * SIZE(X),  %xmm0
	movhpd	13 * SIZE(X),  %xmm0
	movsd	14 * SIZE(X),  %xmm2
	movhpd	15 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	12 * SIZE(Y), %xmm4
	movapd	14 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,  12 * SIZE(Y)
	movapd	%xmm5,  14 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L22
	ALIGN_3

.L25:
	testl	$4, M
	jle	.L26

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	movsd	 4 * SIZE(X),  %xmm0
	movhpd	 5 * SIZE(X),  %xmm0
	movsd	 6 * SIZE(X),  %xmm2
	movhpd	 7 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 4 * SIZE(Y), %xmm4
	movapd	 6 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   4 * SIZE(Y)
	movapd	%xmm5,   6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L26:
	testl	$2, M
	jle	.L27

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L27:
	testl	$1, M
	jle	.L99

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 0 * SIZE(Y), %xmm4

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movapd	%xmm4,   0 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L30:
	testl	$SIZE, X
	jne	.L40

	movl	M, %eax
	sarl	$3,   %eax
	jle	.L35
	ALIGN_3

.L32:
#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	movapd	 4 * SIZE(X),  %xmm0
	movapd	 6 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 4 * SIZE(Y), %xmm4
	movhpd	 5 * SIZE(Y), %xmm4
	movsd	 6 * SIZE(Y), %xmm5
	movhpd	 7 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   4 * SIZE(Y)
	movhpd	%xmm4,   5 * SIZE(Y)
	movsd	%xmm5,   6 * SIZE(Y)
	movhpd	%xmm5,   7 * SIZE(Y)

#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 8) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 8) * SIZE(Y)
#endif

	movapd	 8 * SIZE(X),  %xmm0
	movapd	10 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 8 * SIZE(Y), %xmm4
	movhpd	 9 * SIZE(Y), %xmm4
	movsd	10 * SIZE(Y), %xmm5
	movhpd	11 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   8 * SIZE(Y)
	movhpd	%xmm4,   9 * SIZE(Y)
	movsd	%xmm5,  10 * SIZE(Y)
	movhpd	%xmm5,  11 * SIZE(Y)

	movapd	12 * SIZE(X),  %xmm0
	movapd	14 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	12 * SIZE(Y), %xmm4
	movhpd	13 * SIZE(Y), %xmm4
	movsd	14 * SIZE(Y), %xmm5
	movhpd	15 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,  12 * SIZE(Y)
	movhpd	%xmm4,  13 * SIZE(Y)
	movsd	%xmm5,  14 * SIZE(Y)
	movhpd	%xmm5,  15 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L32
	ALIGN_3

.L35:
	testl	$4, M
	jle	.L36

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	movapd	 4 * SIZE(X),  %xmm0
	movapd	 6 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 4 * SIZE(Y), %xmm4
	movhpd	 5 * SIZE(Y), %xmm4
	movsd	 6 * SIZE(Y), %xmm5
	movhpd	 7 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   4 * SIZE(Y)
	movhpd	%xmm4,   5 * SIZE(Y)
	movsd	%xmm5,   6 * SIZE(Y)
	movhpd	%xmm5,   7 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L36:
	testl	$2, M
	jle	.L37

	movapd	 0 * SIZE(X),  %xmm0
	movapd	 2 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L37:
	testl	$1, M
	jle	.L99

	movapd	 0 * SIZE(X),  %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L40:
	movl	M, %eax
	sarl	$3,   %eax
	jle	.L45
	ALIGN_3

.L42:
#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	movsd	 4 * SIZE(X),  %xmm0
	movhpd	 5 * SIZE(X),  %xmm0
	movsd	 6 * SIZE(X),  %xmm2
	movhpd	 7 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 4 * SIZE(Y), %xmm4
	movhpd	 5 * SIZE(Y), %xmm4
	movsd	 6 * SIZE(Y), %xmm5
	movhpd	 7 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   4 * SIZE(Y)
	movhpd	%xmm4,   5 * SIZE(Y)
	movsd	%xmm5,   6 * SIZE(Y)
	movhpd	%xmm5,   7 * SIZE(Y)

#ifdef OPTERON
	prefetcht0     (PREFETCHSIZE + 8) * SIZE(X)
	prefetchw      (PREFETCHSIZE + 8) * SIZE(Y)
#endif

	movsd	 8 * SIZE(X),  %xmm0
	movhpd	 9 * SIZE(X),  %xmm0
	movsd	10 * SIZE(X),  %xmm2
	movhpd	11 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 8 * SIZE(Y), %xmm4
	movhpd	 9 * SIZE(Y), %xmm4
	movsd	10 * SIZE(Y), %xmm5
	movhpd	11 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   8 * SIZE(Y)
	movhpd	%xmm4,   9 * SIZE(Y)
	movsd	%xmm5,  10 * SIZE(Y)
	movhpd	%xmm5,  11 * SIZE(Y)

	movsd	12 * SIZE(X),  %xmm0
	movhpd	13 * SIZE(X),  %xmm0
	movsd	14 * SIZE(X),  %xmm2
	movhpd	15 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	12 * SIZE(Y), %xmm4
	movhpd	13 * SIZE(Y), %xmm4
	movsd	14 * SIZE(Y), %xmm5
	movhpd	15 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,  12 * SIZE(Y)
	movhpd	%xmm4,  13 * SIZE(Y)
	movsd	%xmm5,  14 * SIZE(Y)
	movhpd	%xmm5,  15 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L42
	ALIGN_3

.L45:
	testl	$4, M
	jle	.L46

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	movsd	 4 * SIZE(X),  %xmm0
	movhpd	 5 * SIZE(X),  %xmm0
	movsd	 6 * SIZE(X),  %xmm2
	movhpd	 7 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 4 * SIZE(Y), %xmm4
	movhpd	 5 * SIZE(Y), %xmm4
	movsd	 6 * SIZE(Y), %xmm5
	movhpd	 7 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   4 * SIZE(Y)
	movhpd	%xmm4,   5 * SIZE(Y)
	movsd	%xmm5,   6 * SIZE(Y)
	movhpd	%xmm5,   7 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L46:
	testl	$2, M
	jle	.L47

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	movsd	 2 * SIZE(X),  %xmm2
	movhpd	 3 * SIZE(X),  %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	movsd	 2 * SIZE(Y), %xmm5
	movhpd	 3 * SIZE(Y), %xmm5

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	movsd	%xmm5,   2 * SIZE(Y)
	movhpd	%xmm5,   3 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L47:
	testl	$1, M
	jle	.L99

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movsd	%xmm4,   0 * SIZE(Y)
	movhpd	%xmm4,   1 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L50:
	movl	Y, YY

	movl	M,  %eax
	sarl	$2, %eax
	jle	.L55
	ALIGN_3

.L52:
	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	addl	 INCX, X
	movsd	 0 * SIZE(X),  %xmm2
	movhpd	 1 * SIZE(X),  %xmm2
	addl	 INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	addl	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm5
	movhpd	 1 * SIZE(Y), %xmm5
	addl	 INCY, Y

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(YY)
	movhpd	%xmm4,   1 * SIZE(YY)
	addl	 INCY, YY
	movsd	%xmm5,   0 * SIZE(YY)
	movhpd	%xmm5,   1 * SIZE(YY)
	addl	 INCY, YY

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	addl	 INCX, X
	movsd	 0 * SIZE(X),  %xmm2
	movhpd	 1 * SIZE(X),  %xmm2
	addl	 INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	addl	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm5
	movhpd	 1 * SIZE(Y), %xmm5
	addl	 INCY, Y

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(YY)
	movhpd	%xmm4,   1 * SIZE(YY)
	addl	 INCY, YY
	movsd	%xmm5,   0 * SIZE(YY)
	movhpd	%xmm5,   1 * SIZE(YY)
	addl	 INCY, YY

	decl	%eax
	jg	.L52
	ALIGN_3

.L55:
	testl	$2, M
	jle	.L57

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	addl	 INCX, X
	movsd	 0 * SIZE(X),  %xmm2
	movhpd	 1 * SIZE(X),  %xmm2
	addl	 INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4
	addl	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm5
	movhpd	 1 * SIZE(Y), %xmm5
	addl	 INCY, Y

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	mulpd	%xmm6, %xmm2
	mulpd	%xmm7, %xmm3
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm3, %xmm5

	movsd	%xmm4,   0 * SIZE(YY)
	movhpd	%xmm4,   1 * SIZE(YY)
	addl	 INCY, YY
	movsd	%xmm5,   0 * SIZE(YY)
	movhpd	%xmm5,   1 * SIZE(YY)
	addl	 INCY, YY
	ALIGN_3

.L57:
	testl	$1, M
	jle	.L99

	movsd	 0 * SIZE(X),  %xmm0
	movhpd	 1 * SIZE(X),  %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	 0 * SIZE(Y), %xmm4
	movhpd	 1 * SIZE(Y), %xmm4

	mulpd	%xmm6, %xmm0
	mulpd	%xmm7, %xmm1
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movsd	%xmm4,   0 * SIZE(YY)
	movhpd	%xmm4,   1 * SIZE(YY)
	jmp	.L99
	ALIGN_3



.L99:
	xorl	%eax,%eax
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp

	ret

	EPILOGUE
