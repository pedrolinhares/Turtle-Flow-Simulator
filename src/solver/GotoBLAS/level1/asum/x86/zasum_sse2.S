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
	
#define STACK	12
#define ARGS     8

#define V	 0 + STACK(%esp)

#define STACK_M		 4 + STACK + ARGS(%esp)
#define STACK_X		 8 + STACK + ARGS(%esp)
#define STACK_INCX	12 + STACK + ARGS(%esp)

#define I	%eax
#define M	%ecx
#define X	%esi
#define INCX	%ebx

#define FLAG	%edi
	
	PROLOGUE

	subl	$ARGS, %esp
	pushl	%esi
	pushl	%edi
	pushl	%ebx

	PROFCODE

	movl	STACK_M, M
	movl	STACK_X, X
	movl	STACK_INCX, INCX

#ifdef F_INTERFACE
	movl	(M), M
	movl	(INCX), INCX
#endif

	pxor	%xmm0, %xmm0
	pxor	%xmm7, %xmm7
	testl	M, M
	jle	.L999
	testl	INCX, INCX
	jle	.L999

	pxor	%xmm1, %xmm1

	cmpeqpd	%xmm7, %xmm7
	psrlq	$1, %xmm7

	xor	FLAG, FLAG
	
	sall	$ZBASE_SHIFT, INCX
	cmpl	$2 * SIZE, INCX
	jne	.L40

	/* Analigned Check */
	testl	$7, X
	jne	.L30		# Unaligned Mode

	testl	$15, X
	je	.L05

	subl	$1, M
	movsd	0 * SIZE(X), %xmm0
	addl	$SIZE, X
	andpd	%xmm7, %xmm0
	mov	$1, FLAG
	ALIGN_3

.L05:
	movl	M,  I
	sarl	$4, I
	jle	.L19
	
	movapd	 0 * SIZE(X), %xmm2
	movapd	 8 * SIZE(X), %xmm3
	movapd	16 * SIZE(X), %xmm4
	movapd	24 * SIZE(X), %xmm5

	decl	I
	jle	.L12
	ALIGN_4

#ifdef PENTIUM3
#define PREFETCHSIZE	128
#endif

#ifdef CORE2
#define PREFETCHSIZE	168
#endif

#ifdef PENRYN
#define PREFETCHSIZE	168
#endif

#ifdef PENTIUM4
#define PREFETCHSIZE	168
#endif

#ifdef PENTIUMM
#define PREFETCHSIZE	168
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define PREFETCHSIZE	168
#endif
	ALIGN_3

.L10:
#if defined(OPTERON) || defined(BARCELONA)
       prefetcht0	(PREFETCHSIZE +  0) * SIZE(X)
#endif

	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	2 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

	movapd	4 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	6 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

#if defined(OPTERON) || defined(BARCELONA)
       prefetcht0	(PREFETCHSIZE +  8) * SIZE(X)
#endif

	movapd	32 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	10 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

	movapd	12 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	14 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

#ifdef PENTIUM4
       prefetcht0	(PREFETCHSIZE +  0) * SIZE(X)
#endif
#if defined(OPTERON) || defined(BARCELONA)
       prefetcht0	(PREFETCHSIZE + 16) * SIZE(X)
#endif

	movapd	40 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	18 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movapd	20 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	22 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

#if defined(OPTERON) || defined(BARCELONA)
       prefetcht0	(PREFETCHSIZE + 24) * SIZE(X)
#endif

	movapd	48 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm0

	movapd	26 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm1

	movapd	28 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm0

	movapd	30 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm1

	movapd	56 * SIZE(X), %xmm5

#ifdef PENTIUM4
	prefetcht0	(PREFETCHSIZE + 16) * SIZE(X)
#endif

	addl	$32 * SIZE, X
	subl	$1, I
	jg	.L10
	ALIGN_4

.L12:
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	2 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

	movapd	4 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	6 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	10 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

	movapd	12 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	14 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	18 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movapd	20 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	22 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm0

	movapd	26 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm1

	movapd	28 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm0

	movapd	30 * SIZE(X), %xmm5
	andpd	%xmm7, %xmm5
	addpd	%xmm5, %xmm1

	addl	$32 * SIZE, X
	ALIGN_4

.L19:
	testl	$15,  M
	je	.L29

	testl	$8, M
	je	.L20

	movapd	0 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	2 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

	movapd	4 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm0

	movapd	6 * SIZE(X), %xmm2
	andpd	%xmm7, %xmm2
	addpd	%xmm2, %xmm1

	movapd	8 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	10 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

	movapd	12 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm0

	movapd	14 * SIZE(X), %xmm3
	andpd	%xmm7, %xmm3
	addpd	%xmm3, %xmm1

	addl	$16 * SIZE, X
	ALIGN_2

.L20:
	testl	$4, M
	je	.L21

	movapd	0 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	2 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movapd	4 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	6 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1
	addl	$8 * SIZE, X
	ALIGN_3

.L21:
	testl	$2, M
	je	.L22

	movapd	0 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movapd	2 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1
	addl	$4 * SIZE, X
	ALIGN_3	

.L22:
	testl	$1, M
	je	.L29

	movapd	0 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1
	addl	$2 * SIZE, X
	ALIGN_3

.L29:
	testl	$1, FLAG
	je	.L998

	movsd	0 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addsd	%xmm4, %xmm0
	jmp	.L998
	ALIGN_3

/* Unaligned Mode */
.L30:
	movl	M,  I
	sarl	$3, I
	jle	.L35
	ALIGN_4
	
.L31:
	prefetcht0	PREFETCHSIZE * SIZE(X)

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	2 * SIZE(X), %xmm4
	movhpd	3 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movsd	4 * SIZE(X), %xmm4
	movhpd	5 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	6 * SIZE(X), %xmm4
	movhpd	7 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	prefetcht0	(PREFETCHSIZE + 8) * SIZE(X)

	movsd	8 * SIZE(X), %xmm4
	movhpd	9 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	10 * SIZE(X), %xmm4
	movhpd	11 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movsd	12 * SIZE(X), %xmm4
	movhpd	13 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	14 * SIZE(X), %xmm4
	movhpd	15 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	addl	$16 * SIZE, X
	decl	I
	jg	.L31
	ALIGN_4

.L35:
	andl	$7,  M
	jle	.L998
	ALIGN_4

.L36:
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0
	addl	$2 * SIZE, X
	decl	M
	jg	.L36
	jmp	.L998
	ALIGN_4

.L40:
	movl	M,  I
	sarl	$2, I
	jle	.L60
	ALIGN_4
	
.L50:
	prefetcht0	PREFETCHSIZE * SIZE(X)

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addl	INCX, X
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addl	INCX, X
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addl	INCX, X
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addl	INCX, X
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm1

	decl	I
	jg	.L50
	ALIGN_4

.L60:
	andl	$3,  M
	jle	.L998
	ALIGN_4


.L61:
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	andpd	%xmm7, %xmm4
	addpd	%xmm4, %xmm0
	addl	INCX, X
	decl	M
	jg	.L61
	ALIGN_4

.L998:
	addpd	%xmm1, %xmm0
	MOVAPD	%xmm0, %xmm1
	UNPCKHPD %xmm0, %xmm0
	ADDSD	 %xmm1, %xmm0
	ALIGN_4

.L999:
	movsd	%xmm0, V
	fldl	V
	popl	%ebx
	popl	%edi
	popl	%esi
	addl	$ARGS, %esp

	ret

	EPILOGUE
