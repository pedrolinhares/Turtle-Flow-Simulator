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
#define PREFETCHSIZE	(16 * 2)

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
	
	pxor	%xmm0,  %xmm0

	testq	M, M
	jle	.L999
	testq	INCX, INCX
	jle	.L999

	pxor	%xmm8,  %xmm8
	pxor	%xmm9,  %xmm9
	pxor	%xmm10, %xmm10
	pxor	%xmm11, %xmm11
	xor	FLAG, FLAG

	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	pcmpeqb	%xmm15, %xmm15
	psrld	$1, %xmm15
	
	salq	$ZBASE_SHIFT, INCX

	cmpq	$2 * SIZE, INCX
	jne	.L100		# incx != 1

	 subq	$-28 * SIZE, X

/* Aligned check */
	testq	$4, X
	je	.L05

	movss	-28 * SIZE(X), %xmm8
	andps	%xmm15, %xmm8
	addq	$SIZE, X
	mov	$1, FLAG
	decq	M
	jle	.L19
	ALIGN_3

.L05:
	testq	$8, X
	je	.L10

	movsd	-28 * SIZE(X), %xmm9
	andps	%xmm15, %xmm9
	addq	$2 * SIZE, X
	decq	M
	jle	.L19
	ALIGN_3

/* aligned mode */
.L10:
	movq	M,  I
	sarq	$4, I
	jle	.L14
	ALIGN_3
	
.L11:
	addps	%xmm4, %xmm8
	movaps	-28 * SIZE(X), %xmm4
	andps	%xmm15, %xmm4
	addps	%xmm5, %xmm9
	movaps	-24 * SIZE(X), %xmm5
	andps	%xmm15, %xmm5
	addps	%xmm6, %xmm10
	movaps	-20 * SIZE(X), %xmm6
	andps	%xmm15, %xmm6
	addps	%xmm7, %xmm11
	movaps	-16 * SIZE(X), %xmm7
	andps	%xmm15, %xmm7

	addps	%xmm4, %xmm8
	movaps	-12 * SIZE(X), %xmm4
	andps	%xmm15, %xmm4
	addps	%xmm5, %xmm9
	movaps	 -8 * SIZE(X), %xmm5
	andps	%xmm15, %xmm5
	addps	%xmm6, %xmm10
	movaps	 -4 * SIZE(X), %xmm6
	andps	%xmm15, %xmm6
	subq	$-32 * SIZE, X
	addps	%xmm7, %xmm11
	movaps	-32 * SIZE(X), %xmm7
	andps	%xmm15, %xmm7

	subq	$1, I
	jg	.L11

	addps	%xmm4, %xmm8
	addps	%xmm5, %xmm9
	addps	%xmm6, %xmm10
	addps	%xmm7, %xmm11
	ALIGN_3

.L14:
	testq	$15,  M
	je	.L19
	testq	$8, M
	je	.L16

	movaps	-28 * SIZE(X), %xmm4
	andps	%xmm15, %xmm4
	addps	%xmm4, %xmm8

	movaps	-24 * SIZE(X), %xmm5
	andps	%xmm15, %xmm5
	addps	%xmm5, %xmm9

	movaps	-20 * SIZE(X), %xmm6
	andps	%xmm15, %xmm6
	addps	%xmm6, %xmm10

	movaps	-16 * SIZE(X), %xmm7
	andps	%xmm15, %xmm7
	addps	%xmm7, %xmm11

	addq	$16 * SIZE, X
	ALIGN_4

.L16:
	testq	$4, M
	je	.L17

	movaps	-28 * SIZE(X), %xmm4
	andps	%xmm15, %xmm4
	addps	%xmm4, %xmm8

	movaps	-24 * SIZE(X), %xmm5
	andps	%xmm15, %xmm5
	addps	%xmm5, %xmm9
	addq	$8 * SIZE, X
	ALIGN_3

.L17:
	testq	$2, M
	je	.L18

	movaps	-28 * SIZE(X), %xmm6
	andps	%xmm15, %xmm6
	addps	%xmm6, %xmm10
	addq	$4 * SIZE, X
	ALIGN_3

.L18:
	testq	$1, M
	je	.L19

	movsd	-28 * SIZE(X), %xmm7
	andps	%xmm15, %xmm7
	addps	%xmm7, %xmm11
	addq	$2 * SIZE, X
	ALIGN_4

.L19:
	testq	$1, FLAG
	je	.L998

	movss	-28 * SIZE(X), %xmm4
	andps	%xmm15, %xmm4
	addss	%xmm4, %xmm10
	jmp	.L998
	ALIGN_4


/* incx != 1 */

.L100:
	movq	M,  I
	sarq	$2, I
	jle	.L105
	ALIGN_4
	
.L101:
	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	andps	%xmm15, %xmm4
	addps	%xmm4, %xmm8

	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	andps	%xmm15, %xmm5
	addps	%xmm5, %xmm9

	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	andps	%xmm15, %xmm6
	addps	%xmm6, %xmm10

	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X
	andps	%xmm15, %xmm7
	addps	%xmm7, %xmm11

	decq	I
	jg	.L101
	ALIGN_4

.L105:
	andq	$3,  M
	jle	.L998
	ALIGN_4

.L106:
	movsd	(X), %xmm4
	andps	%xmm15, %xmm4
	addps	%xmm4, %xmm8
	addq	INCX, X
	decq	M
	jg	.L106
	ALIGN_4

.L998:
	addps	%xmm9,  %xmm8
	addps	%xmm11, %xmm10
	addps	%xmm10, %xmm8
	movaps	%xmm8,  %xmm0


#ifndef HAVE_SSE3
	movhlps	%xmm0, %xmm1
	addps	%xmm1, %xmm0
	
	movaps	%xmm0, %xmm1
	shufps  $1, %xmm0, %xmm0
	addss	 %xmm1, %xmm0
#else
	haddps	%xmm0, %xmm0
	haddps	%xmm0, %xmm0
#endif	
	ALIGN_4

.L999:
#if !defined(DOUBLE) && defined(F_INTERFACE) && \
     defined(F_INTERFACE_F2C) && defined (NEED_F2CCONV)
	cvtss2sd     %xmm0, %xmm0
#endif

	RESTOREREGISTERS
	
	ret

	EPILOGUE
