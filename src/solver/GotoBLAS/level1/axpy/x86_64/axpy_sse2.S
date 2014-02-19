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

#ifndef WINDOWS_ABI
#define M	ARG1
#define X	ARG4
#define INCX	ARG5
#define Y	ARG6
#define INCY	ARG2
#else
#define M	ARG1
#define X	ARG2
#define INCX	ARG3
#define Y	ARG4
#define INCY	%r10
#endif

#define	YY	%r11
#define ALPHA	%xmm15

#if defined(CORE2) || defined(PENRYN)
#define PREFETCH	prefetcht0
#define PREFETCHSIZE (8 * 24)
#endif

	PROLOGUE
	PROFCODE

#ifndef WINDOWS_ABI
#ifndef XDOUBLE
	movq	 8(%rsp), INCY
#else
	movq	24(%rsp), INCY
#endif
	movaps	%xmm0,  ALPHA
#else
	movaps	%xmm3,  ALPHA

	movq	40(%rsp), X
	movq	48(%rsp), INCX
	movq	56(%rsp), Y
	movq	64(%rsp), INCY
#endif

	SAVEREGISTERS

	unpcklpd ALPHA, ALPHA

	leaq	(, INCX, SIZE), INCX
	leaq	(, INCY, SIZE), INCY

	cmpq	$SIZE, INCX
	jne	.L40
	cmpq	$SIZE, INCY
	jne	.L40

	testq	$SIZE, Y
	je	.L10

	movsd	0 * SIZE(X), %xmm0
	mulsd	ALPHA, %xmm0
	addsd	0 * SIZE(Y), %xmm0
	movsd	%xmm0, 0 * SIZE(Y)
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	jle	.L19
	ALIGN_4

.L10:
	testq	$SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L13

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1
	movapd	4 * SIZE(X), %xmm2
	movapd	6 * SIZE(X), %xmm3

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5
	movapd	4 * SIZE(Y), %xmm6
	movapd	6 * SIZE(Y), %xmm7

	movapd	 8 * SIZE(X), %xmm8
	mulpd	ALPHA, %xmm0
	movapd	10 * SIZE(X), %xmm9
	mulpd	ALPHA, %xmm1
	movapd	12 * SIZE(X), %xmm10
	mulpd	ALPHA, %xmm2
	movapd	14 * SIZE(X), %xmm11
	mulpd	ALPHA, %xmm3

	decq	%rax
	jle .L12
	ALIGN_3

.L11:
#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  0)(X)
#endif

	addpd	%xmm4, %xmm0
	mulpd	ALPHA, %xmm8
	addpd	%xmm5, %xmm1
	mulpd	ALPHA, %xmm9
	addpd	%xmm6, %xmm2
	mulpd	ALPHA, %xmm10
	addpd	%xmm7, %xmm3
	mulpd	ALPHA, %xmm11

	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5
	movapd	12 * SIZE(Y), %xmm6
	movapd	14 * SIZE(Y), %xmm7
	
#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  0)(Y)
#endif

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	movapd	16 * SIZE(X), %xmm0
	movapd	18 * SIZE(X), %xmm1
	movapd	20 * SIZE(X), %xmm2
	movapd	22 * SIZE(X), %xmm3

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  8)(X)
#endif
	addpd	%xmm4, %xmm8
	mulpd	ALPHA, %xmm0
	addpd	%xmm5, %xmm9
	mulpd	ALPHA, %xmm1
	addpd	%xmm6, %xmm10
	mulpd	ALPHA, %xmm2
	addpd	%xmm7, %xmm11
	mulpd	ALPHA, %xmm3

	movapd	16 * SIZE(Y), %xmm4
	movapd	18 * SIZE(Y), %xmm5
	movapd	20 * SIZE(Y), %xmm6
	movapd	22 * SIZE(Y), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  8)(Y)
#endif

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	movapd	24 * SIZE(X), %xmm8
	movapd	26 * SIZE(X), %xmm9
	movapd	28 * SIZE(X), %xmm10
	movapd	30 * SIZE(X), %xmm11

	addq	$16 * SIZE, Y
	addq	$16 * SIZE, X
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	addpd	%xmm4, %xmm0
	mulpd	ALPHA, %xmm8
	addpd	%xmm5, %xmm1
	mulpd	ALPHA, %xmm9
	addpd	%xmm6, %xmm2
	mulpd	ALPHA, %xmm10
	addpd	%xmm7, %xmm3
	mulpd	ALPHA, %xmm11

	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5
	movapd	12 * SIZE(Y), %xmm6
	movapd	14 * SIZE(Y), %xmm7

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	movapd	16 * SIZE(X), %xmm0
	movapd	18 * SIZE(X), %xmm1
	movapd	20 * SIZE(X), %xmm2
	movapd	22 * SIZE(X), %xmm3

	addpd	%xmm4, %xmm8
	mulpd	ALPHA, %xmm0
	addpd	%xmm5, %xmm9
	mulpd	ALPHA, %xmm1
	addpd	%xmm6, %xmm10
	mulpd	ALPHA, %xmm2
	addpd	%xmm7, %xmm11
	mulpd	ALPHA, %xmm3

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L13:
	movq	M,  %rax
	andq	$8, %rax
	jle	.L14
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1
	movapd	4 * SIZE(X), %xmm2
	movapd	6 * SIZE(X), %xmm3

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5
	movapd	4 * SIZE(Y), %xmm6
	movapd	6 * SIZE(Y), %xmm7

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1
	mulpd	ALPHA, %xmm2
	mulpd	ALPHA, %xmm3

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1
	addpd	%xmm6, %xmm2
	addpd	%xmm7, %xmm3

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L14:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L15
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L15:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L16
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	0 * SIZE(Y), %xmm4

	mulpd	ALPHA, %xmm0
	addpd	%xmm4, %xmm0

	movapd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L16:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L19
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	mulsd	ALPHA, %xmm0
	addsd	0 * SIZE(Y), %xmm0

	movsd	%xmm0, 	0 * SIZE(Y)
	addq	$SIZE, Y
	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	movapd	-1 * SIZE(X), %xmm0
	movq	M,  %rax
	sarq	$4, %rax
	jle	.L23

	movapd	 1 * SIZE(X), %xmm1
	movapd	 3 * SIZE(X), %xmm2
	movapd	 5 * SIZE(X), %xmm3
	movapd	 7 * SIZE(X), %xmm8

	movapd	 9 * SIZE(X), %xmm9
	movapd	11 * SIZE(X), %xmm10
	movapd	13 * SIZE(X), %xmm11
	movapd	15 * SIZE(X), %xmm12

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5
	movapd	4 * SIZE(Y), %xmm6
	movapd	6 * SIZE(Y), %xmm7
	decq	%rax
	jle .L22
	ALIGN_4

.L21:
#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  0)(X)
#endif
	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm8, %xmm3

	SHUFPD_1 %xmm9,  %xmm8
	SHUFPD_1 %xmm10, %xmm9
	SHUFPD_1 %xmm11, %xmm10
	SHUFPD_1 %xmm12, %xmm11

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1
	mulpd	ALPHA, %xmm2
	mulpd	ALPHA, %xmm3

	mulpd	ALPHA, %xmm8
	mulpd	ALPHA, %xmm9
	mulpd	ALPHA, %xmm10
	mulpd	ALPHA, %xmm11

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  0)(Y)
#endif
	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(Y), %xmm4
	addpd	%xmm5, %xmm1
	movapd	10 * SIZE(Y), %xmm5
	addpd	%xmm6, %xmm2
	movapd	12 * SIZE(Y), %xmm6
	addpd	%xmm7, %xmm3
	movapd	14 * SIZE(Y), %xmm7

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	movapd	%xmm12, %xmm0
	movapd	17 * SIZE(X), %xmm1
	movapd	19 * SIZE(X), %xmm2
	movapd	21 * SIZE(X), %xmm3
	movapd	31 * SIZE(X), %xmm12

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  8)(X)
#endif
	addpd	%xmm4, %xmm8
	addpd	%xmm5, %xmm9
	addpd	%xmm6, %xmm10
	addpd	%xmm7, %xmm11

	movapd	16 * SIZE(Y), %xmm4
	movapd	18 * SIZE(Y), %xmm5
	movapd	20 * SIZE(Y), %xmm6
	movapd	22 * SIZE(Y), %xmm7

#if defined(CORE2) || defined(PENRYN)
	PREFETCH	(PREFETCHSIZE +  8)(Y)
#endif

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	movapd	23 * SIZE(X), %xmm8
	movapd	25 * SIZE(X), %xmm9
	movapd	27 * SIZE(X), %xmm10
	movapd	29 * SIZE(X), %xmm11

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	decq	%rax
	jg	.L21
	ALIGN_3

.L22:
	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm8, %xmm3

	SHUFPD_1 %xmm9,  %xmm8
	SHUFPD_1 %xmm10, %xmm9
	SHUFPD_1 %xmm11, %xmm10
	SHUFPD_1 %xmm12, %xmm11

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1
	mulpd	ALPHA, %xmm2
	mulpd	ALPHA, %xmm3

	mulpd	ALPHA, %xmm8
	mulpd	ALPHA, %xmm9
	mulpd	ALPHA, %xmm10
	mulpd	ALPHA, %xmm11

	addpd	%xmm4, %xmm0
	movapd	 8 * SIZE(Y), %xmm4
	addpd	%xmm5, %xmm1
	movapd	10 * SIZE(Y), %xmm5
	addpd	%xmm6, %xmm2
	movapd	12 * SIZE(Y), %xmm6
	addpd	%xmm7, %xmm3
	movapd	14 * SIZE(Y), %xmm7

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	addpd	%xmm4, %xmm8
	addpd	%xmm5, %xmm9
	addpd	%xmm6, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,  8 * SIZE(Y)
	movapd	%xmm9, 10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	movapd	%xmm12, %xmm0
	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L23:
	movq	M,  %rax
	andq	$8, %rax
	jle	.L24
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2
	movapd	5 * SIZE(X), %xmm3
	movapd	7 * SIZE(X), %xmm8

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5
	movapd	4 * SIZE(Y), %xmm6
	movapd	6 * SIZE(Y), %xmm7

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm8, %xmm3

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1
	mulpd	ALPHA, %xmm2
	mulpd	ALPHA, %xmm3

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1
	addpd	%xmm6, %xmm2
	addpd	%xmm7, %xmm3

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	movapd	%xmm8, %xmm0

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L24:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L25
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1

	mulpd	ALPHA, %xmm0
	mulpd	ALPHA, %xmm1

	addpd	%xmm4, %xmm0
	addpd	%xmm5, %xmm1

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, %xmm0

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L25:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L26
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	0 * SIZE(Y), %xmm4

	SHUFPD_1 %xmm1, %xmm0
	mulpd	ALPHA, %xmm0
	addpd	%xmm4, %xmm0

	movapd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L26:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L29
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	mulsd	ALPHA, %xmm0
	addsd	0 * SIZE(Y), %xmm0

	movsd	%xmm0, 	0 * SIZE(Y)
	addq	$SIZE, Y
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3


.L40:
	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L45
	ALIGN_3

.L41:
	movsd	0 * SIZE(X), %xmm0
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm0
	addq	INCX, X
	mulpd	ALPHA, %xmm0

	movsd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	movhpd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	addpd	%xmm6, %xmm0

	movsd	0 * SIZE(X), %xmm1
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm1
	addq	INCX, X
	mulpd	ALPHA, %xmm1

	movsd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	movhpd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	addpd	%xmm6, %xmm1

	movsd	0 * SIZE(X), %xmm2
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm2
	addq	INCX, X
	mulpd	ALPHA, %xmm2

	movsd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	movhpd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	addpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm3
	addq	INCX, X
	movhpd	0 * SIZE(X), %xmm3
	addq	INCX, X
	mulpd	ALPHA, %xmm3

	movsd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	movhpd	0 * SIZE(YY), %xmm6
	addq	INCY, YY
	addpd	%xmm6, %xmm3

	movsd	%xmm0, 0 * SIZE(Y)
	addq	INCY, Y
	movhpd	%xmm0, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm1, 0 * SIZE(Y)
	addq	INCY, Y
	movhpd	%xmm1, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm2, 0 * SIZE(Y)
	addq	INCY, Y
	movhpd	%xmm2, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm3, 0 * SIZE(Y)
	addq	INCY, Y
	movhpd	%xmm3, 0 * SIZE(Y)
	addq	INCY, Y

	decq	%rax
	jg	.L41
	ALIGN_3

.L45:
	movq	M,  %rax
	andq	$7, %rax
	jle	.L47
	ALIGN_3

.L46:
	movsd	(X), %xmm0
	addq	INCX, X
	mulsd	%xmm15, %xmm0
	addsd	(Y), %xmm0
	movsd	%xmm0, (Y)
	addq	INCY, Y
	decq	%rax
	jg	.L46
	ALIGN_3

.L47:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE
