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
	
#define M	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */

#define I	%rax
#define FLAG	%r10
	
#define PREFETCH	prefetcht0
#define PREFETCHSIZE	(8 * 2)

	PROLOGUE
	PROFCODE

#ifdef F_INTERFACE
#ifndef USE64BITINT
	movslq	(M), M
	movslq	(INCX), INCX
#else
	movq	(M), M
	movq	(INCX), INCX
#endif
#endif

	SAVEREGISTERS
	
	pxor	%xmm0, %xmm0
	testq	M, M
	jle	.L999
	testq	INCX, INCX
	jle	.L999

	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	pcmpeqb	%xmm15, %xmm15
	psrlq	$1, %xmm15

	xor	FLAG, FLAG
	
	pxor	%xmm4,  %xmm4
	pxor	%xmm5,  %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	salq	$ZBASE_SHIFT, INCX
	cmpq	$2 * SIZE, INCX
	jne	.L40

	testq	$15, X
	je	.L05

	subq	$1, M
	movsd	0 * SIZE(X), %xmm0
	addq	$SIZE, X
	andpd	%xmm15, %xmm0
	mov	$1, FLAG
	ALIGN_3

.L05:
	subq	$-14 * SIZE, X

	movq	M,  I
	sarq	$3, I
	jle	.L20
	ALIGN_4
	
.L10:
	addpd	%xmm4, %xmm0
	movapd	-14 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addpd	%xmm5, %xmm1
	movapd	-12 * SIZE(X), %xmm5
	andpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm2
	movapd	-10 * SIZE(X), %xmm6
	andpd	%xmm15, %xmm6
	addpd	%xmm7, %xmm3
	movapd	 -8 * SIZE(X), %xmm7
	andpd	%xmm15, %xmm7

	addpd	%xmm4, %xmm0
	movapd	 -6 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addpd	%xmm5, %xmm1
	movapd	 -4 * SIZE(X), %xmm5
	andpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm2
	movapd	 -2 * SIZE(X), %xmm6
	andpd	%xmm15, %xmm6
	subq	$-16 * SIZE, X
	addpd	%xmm7, %xmm3
	movapd	 -16 * SIZE(X), %xmm7
	andpd	%xmm15, %xmm7

	decq	I
	jg	.L10

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1
	addpd	%xmm6, %xmm2
	addpd	%xmm7, %xmm3
	ALIGN_3

.L20:
	testq	$7,  M
	je	.L29

	testq	$4, M
	je	.L21

	movapd	-14 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addpd	%xmm4, %xmm0

	movapd	-12 * SIZE(X), %xmm5
	andpd	%xmm15, %xmm5
	addpd	%xmm5, %xmm1

	movapd	-10 * SIZE(X), %xmm6
	andpd	%xmm15, %xmm6
	addpd	%xmm6, %xmm2

	movapd	 -8 * SIZE(X), %xmm7
	andpd	%xmm15, %xmm7
	addpd	%xmm7, %xmm3
	addq	$8 * SIZE, X
	ALIGN_3

.L21:
	testq	$2, M
	je	.L22

	movapd	-14 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addpd	%xmm4, %xmm0

	movapd	-12 * SIZE(X), %xmm5
	andpd	%xmm15, %xmm5
	addpd	%xmm5, %xmm1
	addq	$4 * SIZE, X
	ALIGN_3	

.L22:
	testq	$1, M
	je	.L29

	movapd	-14 * SIZE(X), %xmm6
	andpd	%xmm15, %xmm6
	addpd	%xmm6, %xmm3
	addq	$2 * SIZE, X
	ALIGN_3

.L29:
	testq	$1, FLAG
	je	.L998

	movsd	-14 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addsd	%xmm4, %xmm0
	jmp	.L998
	ALIGN_3

.L40:
	movq	M,  I
	sarq	$2, I
	jle	.L60
	ALIGN_3
	
.L50:
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	addq	INCX, X
	andpd	%xmm15, %xmm4
	addpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm5
	movhpd	1 * SIZE(X), %xmm5
	addq	INCX, X
	andpd	%xmm15, %xmm5
	addpd	%xmm5, %xmm1

	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	addq	INCX, X
	andpd	%xmm15, %xmm6
	addpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm7
	movhpd	1 * SIZE(X), %xmm7
	addq	INCX, X
	andpd	%xmm15, %xmm7
	addpd	%xmm7, %xmm3

	decq	I
	jg	.L50
	ALIGN_3

.L60:
	andq	$3,  M
	jle	.L998
	ALIGN_3

.L61:
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	andpd	%xmm15, %xmm4
	addpd	%xmm4, %xmm0
	addq	INCX, X
	decq	M
	jg	.L61
	ALIGN_3

.L998:
	addpd	%xmm1, %xmm0
	addpd	%xmm3, %xmm2
	addpd	%xmm2, %xmm0

#ifndef HAVE_SSE3
	MOVAPD	%xmm0, %xmm1
	UNPCKHPD %xmm0, %xmm0
	ADDSD	 %xmm1, %xmm0
#else
	haddpd	%xmm0, %xmm0
#endif
	ALIGN_3

.L999:
	RESTOREREGISTERS
	
	ret

	EPILOGUE
