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
#define maxpd	minpd
#define maxsd	minsd
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
	psrlq	$1, %xmm15
#endif

	movsd	(X), %xmm0
	addq	INCX, X
	decq	M
#ifdef ABS
	andpd	 %xmm15, %xmm0
#endif
	unpcklpd %xmm0, %xmm0
	movapd	 %xmm0, %xmm1
	movapd	 %xmm0, %xmm2
	movapd	 %xmm0, %xmm3
	cmpq	$SIZE, INCX
	jne	.L40

/* Analigned Check */
	cmpq	$7, M
	jle	.L30

	testq	$7, X
	jne	.L30		# Purely Unaligned Mode

	testq	$15, X		# Checking for 128bit align
	je	.L05

	movsd	0 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	unpcklpd  %xmm4, %xmm4
	maxpd	  %xmm4, %xmm3
	decq	M
	addq	$SIZE, X
	ALIGN_3

.L05:
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
	prefetchnta	PREFETCHSIZE * SIZE(X)
#endif

	movapd	0 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movapd	2 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movapd	4 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movapd	6 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

#if defined(OPTERON) || defined(BARCELONA)
	prefetch	(PREFETCHSIZE + 8) * SIZE(X)
#endif

	movapd	8 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movapd	10 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movapd	12 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movapd	14 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

	addq	$16 * SIZE, X
	decq	I
	jg	.L11
	ALIGN_4

.L15:
	andq	$15,  M
	jle	.L998

	testq	$8, M
	je	.L16

	movapd	0 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movapd	2 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movapd	4 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movapd	6 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3
	addq	$8 * SIZE, X
	ALIGN_3

.L16:
	testq	$4, M
	je	.L17

	movapd	0 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movapd	2 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1
	addq	$4 * SIZE, X
	ALIGN_3	

.L17:
	testq	$2, M
	je	.L18

	movapd	0 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2
	addq	$2 * SIZE, X
	
.L18:
	testq	$1, M
	je	.L998

	movsd	0 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	unpcklpd  %xmm7, %xmm7
	maxpd	%xmm7, %xmm3
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

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
#ifdef PENTIUM4
	prefetcht0	PREFETCHSIZE * SIZE(X)
#endif

#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	2 * SIZE(X), %xmm5
	movhpd	3 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	4 * SIZE(X), %xmm6
	movhpd	5 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	6 * SIZE(X), %xmm7
	movhpd	7 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

#if defined(OPTERON) || defined(BARCELONA)
	prefetch	(PREFETCHSIZE + 8) * SIZE(X)
#endif

	movsd	8 * SIZE(X), %xmm4
	movhpd	9 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	10 * SIZE(X), %xmm5
	movhpd	11 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	12 * SIZE(X), %xmm6
	movhpd	13 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	14 * SIZE(X), %xmm7
	movhpd	15 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

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
	movhpd	1 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	2 * SIZE(X), %xmm5
	movhpd	3 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	4 * SIZE(X), %xmm6
	movhpd	5 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	6 * SIZE(X), %xmm7
	movhpd	7 * SIZE(X), %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

	addq	$8 * SIZE, X
	ALIGN_3

.L36:
	testq	$4, M
	je	.L37

	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	2 * SIZE(X), %xmm5
	movhpd	3 * SIZE(X), %xmm5
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1
	addq	$4 * SIZE, X
	ALIGN_3	

.L37:
	testq	$2, M
	je	.L38

	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2
	addq	$2 * SIZE, X
	
.L38:
	testq	$1, M
	je	.L998

	movsd	0 * SIZE(X), %xmm7
	unpcklpd  %xmm7, %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3
	jmp	.L998
	ALIGN_4


.L40:
	movq	M,  I
	sarq	$4, I
	jle	.L45
	ALIGN_4
	
.L41:
#if defined(OPTERON) || defined(BARCELONA)
	prefetch	PREFETCHSIZE * SIZE(X)
#endif
#ifdef PENTIUM4
	prefetcht0	PREFETCHSIZE * SIZE(X)
#endif

	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

#if defined(OPTERON) || defined(BARCELONA)
	prefetch	PREFETCHSIZE * SIZE(X)
#endif

	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3

	decq	I
	jg	.L41
	ALIGN_4

.L45:
	andq	$15,  M
	jle	.L998

	testq	$8, M
	je	.L46

	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1

	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm7
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3
	ALIGN_3

.L46:
	testq	$4, M
	je	.L47

	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm4
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm4
#endif
	maxpd	%xmm4, %xmm0

	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm5
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm5
#endif
	maxpd	%xmm5, %xmm1
	ALIGN_3	

.L47:
	testq	$2, M
	je	.L48

	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm6
	addq	INCX, X
#ifdef ABS
	andpd	 %xmm15, %xmm6
#endif
	maxpd	%xmm6, %xmm2
	ALIGN_3
	
.L48:
	testq	$1, M
	je	.L998

	movsd	0 * SIZE(X), %xmm7
	unpcklpd  %xmm7, %xmm7
#ifdef ABS
	andpd	 %xmm15, %xmm7
#endif
	maxpd	%xmm7, %xmm3
	ALIGN_4

.L998:
	maxpd	%xmm1, %xmm0
	maxpd	%xmm3, %xmm2
	maxpd	%xmm2, %xmm0
	movapd	%xmm0, %xmm1
	unpckhpd %xmm0, %xmm0
	maxsd	%xmm1, %xmm0
	ALIGN_4

.L999:
	RESTOREREGISTERS

	ret

	EPILOGUE
