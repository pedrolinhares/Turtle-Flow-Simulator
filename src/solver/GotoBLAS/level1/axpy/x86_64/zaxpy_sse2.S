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

#ifdef PENTIUM4
#define movlpd	movsd
#endif

#ifdef OPTERON
#define PREFETCH	prefetch
#define PREFETCHW	prefetchw
#define PREFETCHSIZE	64
#endif

#if defined(HAVE_SSE3) && !defined(CORE_OPTERON)
#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c)	movddup	a##b, c
#else
#define MOVDDUP(a, b, c)	movlpd	a(b), c;movhpd	a(b), c
#define MOVDDUP2(a, b, c)	movlpd	a##b, c;movhpd	a##b, c
#endif

	PROLOGUE
	PROFCODE

#ifndef WINDOWS_ABI
#ifndef XDOUBLE
	movq	 8(%rsp), INCY
#else
	movq	40(%rsp), INCY
#endif
#else
	movaps	%xmm3, %xmm0
	movsd	40(%rsp), %xmm1	

	movq	48(%rsp), X
	movq	56(%rsp), INCX
	movq	64(%rsp), Y
	movq	72(%rsp), INCY
#endif

	SAVEREGISTERS
	
#ifndef CONJ
	movapd	%xmm0, %xmm14		#  a   0

	pxor	%xmm15, %xmm15		#  0   0
	subsd	%xmm1,  %xmm15		# -b   0

	unpcklpd %xmm14, %xmm15		# -b   a
	unpcklpd %xmm1,  %xmm14		#  a   b
#else
	movapd	%xmm0, %xmm14		#  a   0
	movapd	%xmm1, %xmm15		#  b   0

	pxor	%xmm13, %xmm13		#  0   0
	subsd	%xmm0,  %xmm13		# -a   0

	unpcklpd %xmm13, %xmm15		#  b   -a
	unpcklpd %xmm1,  %xmm14		#  a   b
#endif

	salq	$ZBASE_SHIFT, INCX
	salq	$ZBASE_SHIFT, INCY

	testq	$SIZE, Y
	jne	.L30

	cmpq	$2 * SIZE, INCX
	jne	.L20
	cmpq	$2 * SIZE, INCY
	jne	.L20

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L15

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)
	MOVDDUP( 4 * SIZE, X, %xmm4)
	MOVDDUP( 5 * SIZE, X, %xmm5)
	MOVDDUP( 6 * SIZE, X, %xmm6)
	MOVDDUP( 7 * SIZE, X, %xmm7)

	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	decq	%rax
	jle	.L12
	ALIGN_3

.L11:
#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 0) * SIZE(Y)
#endif
	addpd	%xmm0, %xmm8
	MOVDDUP( 8 * SIZE, X, %xmm0)
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	MOVDDUP(10 * SIZE, X, %xmm2)
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	MOVDDUP(12 * SIZE, X, %xmm4)
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	MOVDDUP(14 * SIZE, X, %xmm6)
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	MOVDDUP( 9 * SIZE, X, %xmm1)
	mulpd	%xmm14, %xmm0
	addpd	%xmm3, %xmm9
	MOVDDUP(11 * SIZE, X, %xmm3)
	mulpd	%xmm14, %xmm2
	addpd	%xmm5, %xmm10
	MOVDDUP(13 * SIZE, X, %xmm5)
	mulpd	%xmm14, %xmm4
	addpd	%xmm7, %xmm11
	MOVDDUP(15 * SIZE, X, %xmm7)
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	movapd	 8 * SIZE(Y), %xmm8
	movapd	10 * SIZE(Y), %xmm9
	movapd	12 * SIZE(Y), %xmm10
	movapd	14 * SIZE(Y), %xmm11

#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 8) * SIZE(Y)
#endif
	addpd	%xmm0, %xmm8
	MOVDDUP(16 * SIZE, X, %xmm0)
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	MOVDDUP(18 * SIZE, X, %xmm2)
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	MOVDDUP(20 * SIZE, X, %xmm4)
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	MOVDDUP(22 * SIZE, X, %xmm6)
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	MOVDDUP(17 * SIZE, X, %xmm1)
	mulpd	%xmm14, %xmm0
	addpd	%xmm3, %xmm9
	MOVDDUP(19 * SIZE, X, %xmm3)
	mulpd	%xmm14, %xmm2
	addpd	%xmm5, %xmm10
	MOVDDUP(21 * SIZE, X, %xmm5)
	mulpd	%xmm14, %xmm4
	addpd	%xmm7, %xmm11
	MOVDDUP(23 * SIZE, X, %xmm7)
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10,	12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	movapd	16 * SIZE(Y), %xmm8
	movapd	18 * SIZE(Y), %xmm9
	movapd	20 * SIZE(Y), %xmm10
	movapd	22 * SIZE(Y), %xmm11

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	addpd	%xmm0, %xmm8
	MOVDDUP( 8 * SIZE, X, %xmm0)
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	MOVDDUP(10 * SIZE, X, %xmm2)
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	MOVDDUP(12 * SIZE, X, %xmm4)
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	MOVDDUP(14 * SIZE, X, %xmm6)
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	MOVDDUP( 9 * SIZE, X, %xmm1)
	mulpd	%xmm14, %xmm0
	addpd	%xmm3, %xmm9
	MOVDDUP(11 * SIZE, X, %xmm3)
	mulpd	%xmm14, %xmm2
	addpd	%xmm5, %xmm10
	MOVDDUP(13 * SIZE, X, %xmm5)
	mulpd	%xmm14, %xmm4
	addpd	%xmm7, %xmm11
	MOVDDUP(15 * SIZE, X, %xmm7)
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	movapd	 8 * SIZE(Y), %xmm8
	movapd	10 * SIZE(Y), %xmm9
	movapd	12 * SIZE(Y), %xmm10
	movapd	14 * SIZE(Y), %xmm11

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	mulpd	%xmm14, %xmm0
	addpd	%xmm3, %xmm9
	mulpd	%xmm14, %xmm2
	addpd	%xmm5, %xmm10
	mulpd	%xmm14, %xmm4
	addpd	%xmm7, %xmm11
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10,	12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L15:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L16

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)
	MOVDDUP( 4 * SIZE, X, %xmm4)
	MOVDDUP( 5 * SIZE, X, %xmm5)
	MOVDDUP( 6 * SIZE, X, %xmm6)
	MOVDDUP( 7 * SIZE, X, %xmm7)

	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L17

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)

	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)

	movapd	 0 * SIZE(Y), %xmm8

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movapd	%xmm8,   0 * SIZE(Y)
	jmp	.L999
	ALIGN_3

.L20:
	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L25

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y
	movapd	 (Y), %xmm10
	addq	 INCY, Y
	movapd	 (Y), %xmm11
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	decq	%rax
	jle	.L22
	ALIGN_3

.L21:
	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   (YY)
	addq	 INCY, YY
	movapd	%xmm9,   (YY)
	addq	 INCY, YY
	movapd	%xmm10,  (YY)
	addq	 INCY, YY
	movapd	%xmm11,  (YY)
	addq	 INCY, YY

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y
	movapd	 (Y), %xmm10
	addq	 INCY, Y
	movapd	 (Y), %xmm11
	addq	 INCY, Y

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   (YY)
	addq	 INCY, YY
	movapd	%xmm9,   (YY)
	addq	 INCY, YY
	movapd	%xmm10,  (YY)
	addq	 INCY, YY
	movapd	%xmm11,  (YY)
	addq	 INCY, YY

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y
	movapd	 (Y), %xmm10
	addq	 INCY, Y
	movapd	 (Y), %xmm11
	addq	 INCY, Y

	decq	%rax
	jg	.L21
	ALIGN_3

.L22:
	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movapd	%xmm8,   (YY)
	addq	 INCY, YY
	movapd	%xmm9,   (YY)
	addq	 INCY, YY
	movapd	%xmm10,  (YY)
	addq	 INCY, YY
	movapd	%xmm11,  (YY)
	addq	 INCY, YY

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y
	movapd	 (Y), %xmm10
	addq	 INCY, Y
	movapd	 (Y), %xmm11
	addq	 INCY, Y

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   (YY)
	addq	 INCY, YY
	movapd	%xmm9,   (YY)
	addq	 INCY, YY
	movapd	%xmm10,  (YY)
	addq	 INCY, YY
	movapd	%xmm11,  (YY)
	addq	 INCY, YY
	ALIGN_3

.L25:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L26

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	INCX, X

	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	INCX, X

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y
	movapd	 (Y), %xmm10
	addq	 INCY, Y
	movapd	 (Y), %xmm11
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,  (YY)
	addq	 INCY, YY
	movapd	%xmm9,  (YY)
	addq	 INCY, YY
	movapd	%xmm10, (YY)
	addq	 INCY, YY
	movapd	%xmm11, (YY)
	addq	 INCY, YY
	ALIGN_3

.L26:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L27

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	INCX, X

	movapd	 (Y), %xmm8
	addq	 INCY, Y
	movapd	 (Y), %xmm9
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9

	movapd	%xmm8,   (YY)
	addq	 INCY, YY
	movapd	%xmm9,   (YY)
	addq	 INCY, YY
	ALIGN_3

.L27:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)

	movapd	 (Y), %xmm8
	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movapd	%xmm8,   (YY)
	jmp	.L999
	ALIGN_3


.L30:
	cmpq	$2 * SIZE, INCX
	jne	.L40
	cmpq	$2 * SIZE, INCY
	jne	.L40

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L35

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)
	MOVDDUP( 4 * SIZE, X, %xmm4)
	MOVDDUP( 5 * SIZE, X, %xmm5)
	MOVDDUP( 6 * SIZE, X, %xmm6)
	MOVDDUP( 7 * SIZE, X, %xmm7)

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	movlpd	 2 * SIZE(Y), %xmm9
	movhpd	 3 * SIZE(Y), %xmm9
	movlpd	 4 * SIZE(Y), %xmm10
	movhpd	 5 * SIZE(Y), %xmm10
	movlpd	 6 * SIZE(Y), %xmm11
	movhpd	 7 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	decq	%rax
	jle	.L32
	ALIGN_3

.L31:
	addpd	%xmm0, %xmm8
#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 0) * SIZE(Y)
#endif
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 8 * SIZE, X, %xmm0)
	MOVDDUP( 9 * SIZE, X, %xmm1)
	MOVDDUP(10 * SIZE, X, %xmm2)
	MOVDDUP(11 * SIZE, X, %xmm3)
	MOVDDUP(12 * SIZE, X, %xmm4)
	MOVDDUP(13 * SIZE, X, %xmm5)
	MOVDDUP(14 * SIZE, X, %xmm6)
	MOVDDUP(15 * SIZE, X, %xmm7)

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   0 * SIZE(Y)
	movhpd	%xmm8,   1 * SIZE(Y)
	movlpd	%xmm9,   2 * SIZE(Y)
	movhpd	%xmm9,   3 * SIZE(Y)
	movlpd	%xmm10,  4 * SIZE(Y)
	movhpd	%xmm10,  5 * SIZE(Y)
	movlpd	%xmm11,  6 * SIZE(Y)
	movhpd	%xmm11,  7 * SIZE(Y)

	movlpd	 8 * SIZE(Y), %xmm8
	movhpd	 9 * SIZE(Y), %xmm8
	movlpd	10 * SIZE(Y), %xmm9
	movhpd	11 * SIZE(Y), %xmm9
	movlpd	12 * SIZE(Y), %xmm10
	movhpd	13 * SIZE(Y), %xmm10
	movlpd	14 * SIZE(Y), %xmm11
	movhpd	15 * SIZE(Y), %xmm11

	addpd	%xmm0, %xmm8
#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 8) * SIZE(Y)
#endif
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP(16 * SIZE, X, %xmm0)
	MOVDDUP(17 * SIZE, X, %xmm1)
	MOVDDUP(18 * SIZE, X, %xmm2)
	MOVDDUP(19 * SIZE, X, %xmm3)
	MOVDDUP(20 * SIZE, X, %xmm4)
	MOVDDUP(21 * SIZE, X, %xmm5)
	MOVDDUP(22 * SIZE, X, %xmm6)
	MOVDDUP(23 * SIZE, X, %xmm7)

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   8 * SIZE(Y)
	movhpd	%xmm8,   9 * SIZE(Y)
	movlpd	%xmm9,  10 * SIZE(Y)
	movhpd	%xmm9,  11 * SIZE(Y)
	movlpd	%xmm10, 12 * SIZE(Y)
	movhpd	%xmm10, 13 * SIZE(Y)
	movlpd	%xmm11, 14 * SIZE(Y)
	movhpd	%xmm11, 15 * SIZE(Y)

	movlpd	16 * SIZE(Y), %xmm8
	movhpd	17 * SIZE(Y), %xmm8
	movlpd	18 * SIZE(Y), %xmm9
	movhpd	19 * SIZE(Y), %xmm9
	movlpd	20 * SIZE(Y), %xmm10
	movhpd	21 * SIZE(Y), %xmm10
	movlpd	22 * SIZE(Y), %xmm11
	movhpd	23 * SIZE(Y), %xmm11

	addq	 $16 * SIZE, X
	addq	 $16 * SIZE, Y

	decq	%rax
	jg	.L31
	ALIGN_3

.L32:
	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 8 * SIZE, X, %xmm0)
	MOVDDUP( 9 * SIZE, X, %xmm1)
	MOVDDUP(10 * SIZE, X, %xmm2)
	MOVDDUP(11 * SIZE, X, %xmm3)
	MOVDDUP(12 * SIZE, X, %xmm4)
	MOVDDUP(13 * SIZE, X, %xmm5)
	MOVDDUP(14 * SIZE, X, %xmm6)
	MOVDDUP(15 * SIZE, X, %xmm7)

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   0 * SIZE(Y)
	movhpd	%xmm8,   1 * SIZE(Y)
	movlpd	%xmm9,   2 * SIZE(Y)
	movhpd	%xmm9,   3 * SIZE(Y)
	movlpd	%xmm10,  4 * SIZE(Y)
	movhpd	%xmm10,  5 * SIZE(Y)
	movlpd	%xmm11,  6 * SIZE(Y)
	movhpd	%xmm11,  7 * SIZE(Y)

	movlpd	 8 * SIZE(Y), %xmm8
	movhpd	 9 * SIZE(Y), %xmm8
	movlpd	10 * SIZE(Y), %xmm9
	movhpd	11 * SIZE(Y), %xmm9
	movlpd	12 * SIZE(Y), %xmm10
	movhpd	13 * SIZE(Y), %xmm10
	movlpd	14 * SIZE(Y), %xmm11
	movhpd	15 * SIZE(Y), %xmm11

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movlpd	%xmm8,   8 * SIZE(Y)
	movhpd	%xmm8,   9 * SIZE(Y)
	movlpd	%xmm9,  10 * SIZE(Y)
	movhpd	%xmm9,  11 * SIZE(Y)
	movlpd	%xmm10, 12 * SIZE(Y)
	movhpd	%xmm10, 13 * SIZE(Y)
	movlpd	%xmm11, 14 * SIZE(Y)
	movhpd	%xmm11, 15 * SIZE(Y)

	addq	 $16 * SIZE, X
	addq	 $16 * SIZE, Y
	ALIGN_3

.L35:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L36

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)
	MOVDDUP( 4 * SIZE, X, %xmm4)
	MOVDDUP( 5 * SIZE, X, %xmm5)
	MOVDDUP( 6 * SIZE, X, %xmm6)
	MOVDDUP( 7 * SIZE, X, %xmm7)

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	movlpd	 2 * SIZE(Y), %xmm9
	movhpd	 3 * SIZE(Y), %xmm9
	movlpd	 4 * SIZE(Y), %xmm10
	movhpd	 5 * SIZE(Y), %xmm10
	movlpd	 6 * SIZE(Y), %xmm11
	movhpd	 7 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movlpd	%xmm8,   0 * SIZE(Y)
	movhpd	%xmm8,   1 * SIZE(Y)
	movlpd	%xmm9,   2 * SIZE(Y)
	movhpd	%xmm9,   3 * SIZE(Y)
	movlpd	%xmm10,  4 * SIZE(Y)
	movhpd	%xmm10,  5 * SIZE(Y)
	movlpd	%xmm11,  6 * SIZE(Y)
	movhpd	%xmm11,  7 * SIZE(Y)

	addq	 $8 * SIZE, X
	addq	 $8 * SIZE, Y
	ALIGN_3

.L36:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L37

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	MOVDDUP( 2 * SIZE, X, %xmm2)
	MOVDDUP( 3 * SIZE, X, %xmm3)

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	movlpd	 2 * SIZE(Y), %xmm9
	movhpd	 3 * SIZE(Y), %xmm9

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9

	movlpd	%xmm8,   0 * SIZE(Y)
	movhpd	%xmm8,   1 * SIZE(Y)
	movlpd	%xmm9,   2 * SIZE(Y)
	movhpd	%xmm9,   3 * SIZE(Y)

	addq	 $4 * SIZE, X
	addq	 $4 * SIZE, Y
	ALIGN_3

.L37:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movlpd	%xmm8,   0 * SIZE(Y)
	movhpd	%xmm8,   1 * SIZE(Y)
	jmp	.L999
	ALIGN_3

.L40:
	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L45

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	decq	%rax
	jle	.L42
	ALIGN_3

.L41:
	addpd	%xmm0, %xmm8
#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 0) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 0) * SIZE(Y)
#endif
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	addpd	%xmm0, %xmm8
#ifdef OPTERON
	PREFETCH	(PREFETCHSIZE + 8) * SIZE(X)
	PREFETCHW	(PREFETCHSIZE + 8) * SIZE(Y)
#endif
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	decq	%rax
	jg	.L41
	ALIGN_3

.L42:
	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	 INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	 INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L45:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L46

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	INCX, X

	MOVDDUP( 0 * SIZE, X, %xmm4)
	MOVDDUP( 1 * SIZE, X, %xmm5)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm6)
	MOVDDUP( 1 * SIZE, X, %xmm7)
	addq	INCX, X

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	mulpd	%xmm15, %xmm1
	addpd	%xmm2, %xmm9
	mulpd	%xmm15, %xmm3
	addpd	%xmm4, %xmm10
	mulpd	%xmm15, %xmm5
	addpd	%xmm6, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movlpd	%xmm8,  0 * SIZE(YY)
	movhpd	%xmm8,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,  0 * SIZE(YY)
	movhpd	%xmm9,  1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm10, 0 * SIZE(YY)
	movhpd	%xmm10, 1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm11, 0 * SIZE(YY)
	movhpd	%xmm11, 1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L46:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L47

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	INCX, X

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movlpd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movlpd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L47:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)

	movlpd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movlpd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	ALIGN_3

.L999:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE
