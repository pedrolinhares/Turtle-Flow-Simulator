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

#define PREFETCHSIZE 144

#ifdef OPTERON
#define movsd	movlps
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

	shufps	$0, ALPHA, ALPHA

	leaq	(, INCX, SIZE), INCX
	leaq	(, INCY, SIZE), INCY
	testq	M, M
	jle	.L19
	
	cmpq	$SIZE, INCX
	jne	.L50
	cmpq	$SIZE, INCY
	jne	.L50

	cmpq	$3, M
	jle	.L16

	testq	$SIZE, Y
	je	.L00

	movss	0 * SIZE(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	0 * SIZE(Y), %xmm0
	movss	%xmm0, 0 * SIZE(Y)
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	jle	.L19
	ALIGN_3

.L00:
	testq	$SIZE * 2, Y
	je	.L10

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4
	mulps	ALPHA, %xmm0
	addps	%xmm4, %xmm0
	movsd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	subq	$2, M
	jle	.L19
	ALIGN_3

.L10:
	testq	$SIZE * 3, X
	jne	.L20

	movq	M,  %rax
	sarq	$5, %rax
	jle	.L13

	movaps	 0 * SIZE(X), %xmm0
	movaps	 4 * SIZE(X), %xmm1
	movaps	 8 * SIZE(X), %xmm2
	movaps	12 * SIZE(X), %xmm3

	movaps	16 * SIZE(X), %xmm8
	movaps	20 * SIZE(X), %xmm9
	movaps	24 * SIZE(X), %xmm10
	movaps	28 * SIZE(X), %xmm11

	movaps	 0 * SIZE(Y), %xmm4
	movaps	 4 * SIZE(Y), %xmm5
	movaps	 8 * SIZE(Y), %xmm6
	movaps	12 * SIZE(Y), %xmm7
	decq	%rax
	jle .L12
	ALIGN_4

.L11:
	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	mulps	ALPHA, %xmm8
	mulps	ALPHA, %xmm9
	mulps	ALPHA, %xmm10
	mulps	ALPHA, %xmm11

	addps	%xmm4, %xmm0
	movaps	16 * SIZE(Y), %xmm4
	addps	%xmm5, %xmm1
	movaps	20 * SIZE(Y), %xmm5
	addps	%xmm6, %xmm2
	movaps	24 * SIZE(Y), %xmm6
	addps	%xmm7, %xmm3
	movaps	28 * SIZE(Y), %xmm7

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	movaps	32 * SIZE(X), %xmm0
	movaps	36 * SIZE(X), %xmm1
	movaps	40 * SIZE(X), %xmm2
	movaps	44 * SIZE(X), %xmm3

	addps	%xmm4, %xmm8
	addps	%xmm5, %xmm9
	addps	%xmm6, %xmm10
	addps	%xmm7, %xmm11

	movaps	32 * SIZE(Y), %xmm4
	movaps	36 * SIZE(Y), %xmm5
	movaps	40 * SIZE(Y), %xmm6
	movaps	44 * SIZE(Y), %xmm7

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	movaps	48 * SIZE(X), %xmm8
	movaps	52 * SIZE(X), %xmm9
	movaps	56 * SIZE(X), %xmm10
	movaps	60 * SIZE(X), %xmm11

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	mulps	ALPHA, %xmm8
	mulps	ALPHA, %xmm9
	mulps	ALPHA, %xmm10
	mulps	ALPHA, %xmm11

	addps	%xmm4, %xmm0
	movaps	16 * SIZE(Y), %xmm4
	addps	%xmm5, %xmm1
	movaps	20 * SIZE(Y), %xmm5
	addps	%xmm6, %xmm2
	movaps	24 * SIZE(Y), %xmm6
	addps	%xmm7, %xmm3
	movaps	28 * SIZE(Y), %xmm7

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addps	%xmm4, %xmm8
	addps	%xmm5, %xmm9
	addps	%xmm6, %xmm10
	addps	%xmm7, %xmm11

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L13:
	movq	M,  %rax
	andq	$16, %rax
	jle	.L14
	ALIGN_3

	movaps	 0 * SIZE(X), %xmm0
	movaps	 4 * SIZE(X), %xmm1
	movaps	 8 * SIZE(X), %xmm2
	movaps	12 * SIZE(X), %xmm3

	movaps	 0 * SIZE(Y), %xmm4
	movaps	 4 * SIZE(Y), %xmm5
	movaps	 8 * SIZE(Y), %xmm6
	movaps	12 * SIZE(Y), %xmm7

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1
	addps	%xmm6, %xmm2
	addps	%xmm7, %xmm3

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L14:
	movq	M,  %rax
	andq	$8, %rax
	jle	.L15
	ALIGN_3

	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(X), %xmm1

	movaps	0 * SIZE(Y), %xmm4
	movaps	4 * SIZE(Y), %xmm5

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1

	movaps	%xmm0, 0 * SIZE(Y)
	movaps	%xmm1, 4 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L15:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L16
	ALIGN_3

	movaps	0 * SIZE(X), %xmm0
	movaps	0 * SIZE(Y), %xmm4

	mulps	ALPHA, %xmm0
	addps	%xmm4, %xmm0

	movaps	%xmm0, 0 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L16:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L17
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4

	mulps	ALPHA, %xmm0
	addps	%xmm4, %xmm0

	movsd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L17:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L19
	ALIGN_3

	movss	0 * SIZE(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	0 * SIZE(Y), %xmm0

	movss	%xmm0, 	0 * SIZE(Y)
	addq	$SIZE, Y
	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	movq	M,  %rax
	sarq	$5, %rax
	jle	.L23

#ifdef HAVE_SSE3
	lddqu	 0 * SIZE(X), %xmm0
	lddqu	 4 * SIZE(X), %xmm1
	lddqu	 8 * SIZE(X), %xmm2
	lddqu	12 * SIZE(X), %xmm3

	lddqu	16 * SIZE(X), %xmm8
	lddqu	20 * SIZE(X), %xmm9
	lddqu	24 * SIZE(X), %xmm10
	lddqu	28 * SIZE(X), %xmm11
#else
	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movsd	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1
	movsd	 8 * SIZE(X), %xmm2
	movhps	10 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm3
	movhps	14 * SIZE(X), %xmm3

	movsd	16 * SIZE(X), %xmm8
	movhps	18 * SIZE(X), %xmm8
	movsd	20 * SIZE(X), %xmm9
	movhps	22 * SIZE(X), %xmm9
	movsd	24 * SIZE(X), %xmm10
	movhps	26 * SIZE(X), %xmm10
	movsd	28 * SIZE(X), %xmm11
	movhps	30 * SIZE(X), %xmm11
#endif

	movaps	 0 * SIZE(Y), %xmm4
	movaps	 4 * SIZE(Y), %xmm5
	movaps	 8 * SIZE(Y), %xmm6
	movaps	12 * SIZE(Y), %xmm7
	decq	%rax
	jle .L22
	ALIGN_4

.L21:
	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	mulps	ALPHA, %xmm8
	mulps	ALPHA, %xmm9
	mulps	ALPHA, %xmm10
	mulps	ALPHA, %xmm11

	addps	%xmm4, %xmm0
	movaps	16 * SIZE(Y), %xmm4
	addps	%xmm5, %xmm1
	movaps	20 * SIZE(Y), %xmm5
	addps	%xmm6, %xmm2
	movaps	24 * SIZE(Y), %xmm6
	addps	%xmm7, %xmm3
	movaps	28 * SIZE(Y), %xmm7

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

#ifdef HAVE_SSE3
	lddqu	32 * SIZE(X), %xmm0
	lddqu	36 * SIZE(X), %xmm1
	lddqu	40 * SIZE(X), %xmm2
	lddqu	44 * SIZE(X), %xmm3
#else
	movsd	32 * SIZE(X), %xmm0
	movhps	34 * SIZE(X), %xmm0
	movsd	36 * SIZE(X), %xmm1
	movhps	38 * SIZE(X), %xmm1
	movsd	40 * SIZE(X), %xmm2
	movhps	42 * SIZE(X), %xmm2
	movsd	44 * SIZE(X), %xmm3
	movhps	46 * SIZE(X), %xmm3
#endif

	addps	%xmm4, %xmm8
	addps	%xmm5, %xmm9
	addps	%xmm6, %xmm10
	addps	%xmm7, %xmm11

	movaps	32 * SIZE(Y), %xmm4
	movaps	36 * SIZE(Y), %xmm5
	movaps	40 * SIZE(Y), %xmm6
	movaps	44 * SIZE(Y), %xmm7

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

#ifdef HAVE_SSE3
	lddqu	48 * SIZE(X), %xmm8
	lddqu	52 * SIZE(X), %xmm9
	lddqu	56 * SIZE(X), %xmm10
	lddqu	60 * SIZE(X), %xmm11
#else
	movsd	48 * SIZE(X), %xmm8
	movhps	50 * SIZE(X), %xmm8
	movsd	52 * SIZE(X), %xmm9
	movhps	54 * SIZE(X), %xmm9
	movsd	56 * SIZE(X), %xmm10
	movhps	58 * SIZE(X), %xmm10
	movsd	60 * SIZE(X), %xmm11
	movhps	62 * SIZE(X), %xmm11
#endif

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	decq	%rax
	jg	.L21
	ALIGN_3

.L22:
	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	mulps	ALPHA, %xmm8
	mulps	ALPHA, %xmm9
	mulps	ALPHA, %xmm10
	mulps	ALPHA, %xmm11

	addps	%xmm4, %xmm0
	movaps	16 * SIZE(Y), %xmm4
	addps	%xmm5, %xmm1
	movaps	20 * SIZE(Y), %xmm5
	addps	%xmm6, %xmm2
	movaps	24 * SIZE(Y), %xmm6
	addps	%xmm7, %xmm3
	movaps	28 * SIZE(Y), %xmm7

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addps	%xmm4, %xmm8
	addps	%xmm5, %xmm9
	addps	%xmm6, %xmm10
	addps	%xmm7, %xmm11

	movaps	%xmm8,  16 * SIZE(Y)
	movaps	%xmm9,  20 * SIZE(Y)
	movaps	%xmm10, 24 * SIZE(Y)
	movaps	%xmm11, 28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L23:
	movq	M,  %rax
	andq	$16, %rax
	jle	.L24
	ALIGN_3

#ifdef HAVE_SSE3
	lddqu	 0 * SIZE(X), %xmm0
	lddqu	 4 * SIZE(X), %xmm1
	lddqu	 8 * SIZE(X), %xmm2
	lddqu	12 * SIZE(X), %xmm3
#else
	movsd	 0 * SIZE(X), %xmm0
	movhps	 2 * SIZE(X), %xmm0
	movsd	 4 * SIZE(X), %xmm1
	movhps	 6 * SIZE(X), %xmm1
	movsd	 8 * SIZE(X), %xmm2
	movhps	10 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm3
	movhps	14 * SIZE(X), %xmm3
#endif

	movaps	 0 * SIZE(Y), %xmm4
	movaps	 4 * SIZE(Y), %xmm5
	movaps	 8 * SIZE(Y), %xmm6
	movaps	12 * SIZE(Y), %xmm7

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1
	mulps	ALPHA, %xmm2
	mulps	ALPHA, %xmm3

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1
	addps	%xmm6, %xmm2
	addps	%xmm7, %xmm3

	movaps	%xmm0,  0 * SIZE(Y)
	movaps	%xmm1,  4 * SIZE(Y)
	movaps	%xmm2,  8 * SIZE(Y)
	movaps	%xmm3, 12 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L24:
	movq	M,  %rax
	andq	$8, %rax
	jle	.L25
	ALIGN_3

#ifdef HAVE_SSE3
	lddqu	0 * SIZE(X), %xmm0
	lddqu	4 * SIZE(X), %xmm1
#else
	movsd	0 * SIZE(X), %xmm0
	movhps	2 * SIZE(X), %xmm0
	movsd	4 * SIZE(X), %xmm1
	movhps	6 * SIZE(X), %xmm1
#endif

	movaps	0 * SIZE(Y), %xmm4
	movaps	4 * SIZE(Y), %xmm5

	mulps	ALPHA, %xmm0
	mulps	ALPHA, %xmm1

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1

	movaps	%xmm0, 0 * SIZE(Y)
	movaps	%xmm1, 4 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L26
	ALIGN_3

#ifdef HAVE_SSE3
	lddqu	0 * SIZE(X), %xmm0
#else
	movsd	0 * SIZE(X), %xmm0
	movhps	2 * SIZE(X), %xmm0
#endif
	movaps	0 * SIZE(Y), %xmm4

	mulps	ALPHA, %xmm0
	addps	%xmm4, %xmm0

	movaps	%xmm0, 0 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L27
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4

	mulps	ALPHA, %xmm0
	addps	%xmm4, %xmm0

	movsd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L27:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L29
	ALIGN_3

	movss	0 * SIZE(X), %xmm0
	mulss	ALPHA, %xmm0
	addss	0 * SIZE(Y), %xmm0

	movss	%xmm0, 	0 * SIZE(Y)
	addq	$SIZE, Y
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L50:
	movq	M, %rax
	movq	Y, YY
	sarq	$3,   %rax
	jle	.L55
	ALIGN_3

.L51:
	movss	(X), %xmm0
	addq	INCX, X
	mulss	ALPHA, %xmm0
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm0

	movss	(X), %xmm1
	addq	INCX, X
	mulss	ALPHA, %xmm1
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm1

	movss	(X), %xmm2
	addq	INCX, X
	mulss	ALPHA, %xmm2
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm2

	movss	(X), %xmm3
	addq	INCX, X
	mulss	ALPHA, %xmm3
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm3

	movss	%xmm0, (Y)
	addq	INCY, Y
	movss	%xmm1, (Y)
	addq	INCY, Y
	movss	%xmm2, (Y)
	addq	INCY, Y
	movss	%xmm3, (Y)
	addq	INCY, Y

	movss	(X), %xmm0
	addq	INCX, X
	mulss	ALPHA, %xmm0
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm0

	movss	(X), %xmm1
	addq	INCX, X
	mulss	ALPHA, %xmm1
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm1

	movss	(X), %xmm2
	addq	INCX, X
	mulss	ALPHA, %xmm2
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm2

	movss	(X), %xmm3
	addq	INCX, X
	mulss	ALPHA, %xmm3
	movss	(YY), %xmm6
	addq	INCY, YY
	addss	%xmm6, %xmm3

	movss	%xmm0, (Y)
	addq	INCY, Y
	movss	%xmm1, (Y)
	addq	INCY, Y
	movss	%xmm2, (Y)
	addq	INCY, Y
	movss	%xmm3, (Y)
	addq	INCY, Y

	decq	%rax
	jg	.L51
	ALIGN_3

.L55:
	movq	M, %rax
	andq	$7,   %rax
	jle	.L59
	ALIGN_3

.L56:
	movss	(X), %xmm0
	addq	INCX, X
	mulss	ALPHA, %xmm0
	movss	(Y), %xmm6
	addss	%xmm6, %xmm0
	movss	%xmm0, (Y)
	addq	INCY, Y
	decq	%rax
	jg	.L56
	ALIGN_3

.L59:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret

	EPILOGUE
