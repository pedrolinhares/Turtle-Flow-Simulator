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
	
#ifdef MIN
#define maxps	minps
#define maxss	minss
#endif
	
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

	leaq	(, INCX, SIZE), INCX
	testq	INCX, INCX
	jle	.L999

#ifdef ABS
	pcmpeqb	%xmm15, %xmm15
	psrld	$1, %xmm15
#endif

	movss	(X), %xmm0
	shufps	$0, %xmm0, %xmm0
#ifdef ABS
	andps	%xmm15, %xmm0
#endif
	movaps	%xmm0, %xmm1
	movaps	%xmm0, %xmm2
	movaps	%xmm0, %xmm3
	addq	INCX, X
	decq	M
	jle	.L999

	cmpq	$SIZE, INCX
	jne	.L40

	cmpq	$7, M
	jle	.L45

	testq	$4, X
	je	.L05

	movss	0 * SIZE(X), %xmm1
	shufps	$0, %xmm1, %xmm1
#ifdef ABS
	andps	%xmm15, %xmm1
#endif
	decq	M
	addq	$SIZE, X
	ALIGN_3

.L05:
	testq	$8, X
	je	.L06

	movsd	0 * SIZE(X), %xmm2
	unpcklps  %xmm2, %xmm2
#ifdef ABS
	andps	%xmm15, %xmm2
#endif
	subq	$2, M
	addq	$2 * SIZE, X
	ALIGN_3

.L06:
	movq	M,  I
	sarq	$4, I
	jle	.L15
	ALIGN_4
	
#define PREFETCHSIZE 256

.L11:
#if defined(OPTERON) || defined(BARCELONA)
	prefetch	PREFETCHSIZE * SIZE(X)
#endif

#ifdef PENTIUM4
	prefetcht2	PREFETCHSIZE * SIZE(X)
#endif

	movaps	 0 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movaps	 4 * SIZE(X), %xmm5
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxps	%xmm5, %xmm1

	movaps	 8 * SIZE(X), %xmm6
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxps	%xmm6, %xmm2

	movaps	12 * SIZE(X), %xmm7
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxps	%xmm7, %xmm3

	addq	$16 * SIZE, X
	decq	I
	jg	.L11
	ALIGN_4

.L15:
	andq	$15,  M
	jle	.L998

	testq	$8, M
	je	.L16

	movaps	0 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movaps	4 * SIZE(X), %xmm5
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxps	%xmm5, %xmm1
	addq	$8 * SIZE, X
	ALIGN_3

.L16:
	testq	$4, M
	je	.L17

	movaps	0 * SIZE(X), %xmm6
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxps	%xmm6, %xmm2
	addq	$4 * SIZE, X
	ALIGN_3	

.L17:
	testq	$2, M
	je	.L18

	movsd	0 * SIZE(X), %xmm7
	unpcklps %xmm7, %xmm7
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxps	%xmm7, %xmm3
	addq	$2 * SIZE, X
	
.L18:
	testq	$1, M
	je	.L998

	movss	0 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0
	jmp	.L998
	ALIGN_3

/* Unaligned Mode */
.L30:
	movq	M,  I
	sarq	$4, I
	jle	.L35
	ALIGN_4
	
.L31:
#if defined(OPTERON) || defined(BARCELONA)
	prefetch	PREFETCHSIZE * SIZE(X)
#endif
#ifdef PENTIUM4
	prefetchnta	PREFETCHSIZE * SIZE(X)
#endif

	movsd	 0 * SIZE(X), %xmm4
	movhps	 2 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movsd	 4 * SIZE(X), %xmm5
	movhps	 6 * SIZE(X), %xmm5
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxps	%xmm5, %xmm1

	movsd	 8 * SIZE(X), %xmm6
	movhps	10 * SIZE(X), %xmm6
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxps	%xmm6, %xmm2

	movsd	12 * SIZE(X), %xmm7
	movhps	14 * SIZE(X), %xmm7
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxps	%xmm7, %xmm3

	addq	$16 * SIZE, X
	decq	I
	jg	.L31
	ALIGN_4

.L35:
	andq	$15,  M
	jle	.L998

	testq	$8, M
	je	.L36

	movsd	0 * SIZE(X), %xmm4
	movhps	2 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movsd	4 * SIZE(X), %xmm5
	movhps	6 * SIZE(X), %xmm5
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxps	%xmm5, %xmm1

	addq	$8 * SIZE, X
	ALIGN_3

.L36:
	testq	$4, M
	je	.L37

	movsd	0 * SIZE(X), %xmm6
	movhps	2 * SIZE(X), %xmm6
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxps	%xmm6, %xmm2
	addq	$4 * SIZE, X
	ALIGN_3	

.L37:
	testq	$2, M
	je	.L38

	movsd	0 * SIZE(X), %xmm7
	unpcklps %xmm7, %xmm7
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxps	%xmm7, %xmm3
	addq	$2 * SIZE, X
	
.L38:
	testq	$1, M
	je	.L998

	movss	0 * SIZE(X), %xmm4
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0
	jmp	.L998
	ALIGN_4


.L40:
	movq	M,  I
	sarq	$3, I
	jle	.L45
	ALIGN_4
	
.L41:
#if defined(OPTERON) || defined(BARCELONA)
	prefetch	PREFETCHSIZE * SIZE(X)
#endif
#ifdef PENTIUM4
	prefetchnta	PREFETCHSIZE * SIZE(X)
#endif

	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxss	%xmm5, %xmm1

	movss	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxss	%xmm6, %xmm2

	movss	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxss	%xmm7, %xmm3

	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxss	%xmm5, %xmm1

	movss	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxss	%xmm6, %xmm2

	movss	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxss	%xmm7, %xmm3

	decq	I
	jg	.L41
	ALIGN_4

.L45:
	andq	$7,  M
	jle	.L998

	testq	$4, M
	je	.L46

	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxss	%xmm5, %xmm1

	movss	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxss	%xmm6, %xmm2

	movss	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm7
#endif
	maxss	%xmm7, %xmm3
	ALIGN_3	

.L46:
	testq	$2, M
	je	.L47

	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm5
#endif
	maxss	%xmm5, %xmm1
	ALIGN_3
	
.L47:
	testq	$1, M
	je	.L998

	movss	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andps	%xmm15, %xmm6
#endif
	maxss	%xmm6, %xmm2
	ALIGN_4

.L998:
	maxps	%xmm1, %xmm0
	maxps	%xmm3, %xmm2
	maxps	%xmm2, %xmm0
	movaps	%xmm0, %xmm1
	movhlps %xmm0, %xmm0
	maxps	%xmm1, %xmm0
	movaps	%xmm0, %xmm1
	shufps	$1, %xmm0, %xmm0
	maxss	%xmm1, %xmm0
	ALIGN_4

.L999:
#if !defined(DOUBLE) && defined(F_INTERFACE) && \
     defined(F_INTERFACE_F2C) && defined (NEED_F2CCONV)
	cvtss2sd     %xmm0, %xmm0
#endif
	RESTOREREGISTERS

	ret

	EPILOGUE
