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

#ifdef HAVE_SSE3
#define MOVDDUP(a, b, c)	movddup	a(b), c
#define MOVDDUP2(a, b, c)	movddup	a##b, c
#else
#define MOVDDUP(a, b, c)	movsd	a(b), c;movhpd	a(b), c
#define MOVDDUP2(a, b, c)	movsd	a##b, c;movhpd	a##b, c
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
	jne	.L50

	cmpq	$2 * SIZE, INCX
	jne	.L30
	cmpq	$2 * SIZE, INCY
	jne	.L30

#ifndef CONJ
	movddup	 %xmm0,  %xmm14
	pxor	 %xmm15, %xmm15
	subsd	 %xmm1,  %xmm15
	unpcklpd %xmm1,  %xmm15
#else
	movddup	 %xmm1,  %xmm15
	movapd	 %xmm0,  %xmm14
	pxor	 %xmm13, %xmm13
	subsd	 %xmm0,  %xmm13
	unpcklpd %xmm13, %xmm14
#endif

	testq	$SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L15

	movapd	 0 * SIZE(X), %xmm0
	movapd	 2 * SIZE(X), %xmm2
	movapd	 4 * SIZE(X), %xmm6
	movapd	 6 * SIZE(X), %xmm7
	decq	%rax
	jle	.L12
	ALIGN_3

.L11:
	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3
	movapd	%xmm14, %xmm8
	movapd	%xmm14, %xmm9

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	shufps	 $0x4e, %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	shufps	 $0x4e, %xmm7, %xmm7
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	SHUFPD_1 %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	SHUFPD_1 %xmm7, %xmm7
#endif
	
	movapd	 0 * SIZE(Y), %xmm4
	addpd	%xmm1, %xmm4
	mulpd	%xmm15, %xmm0
	movapd	 2 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm5
	mulpd	%xmm15, %xmm2
	movapd	 4 * SIZE(Y), %xmm10
	addpd	%xmm8, %xmm10
	mulpd	%xmm15, %xmm6
	movapd	 6 * SIZE(Y), %xmm11
	addpd	%xmm9, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm0, %xmm4
	movapd	 8 * SIZE(X), %xmm0
	addpd	%xmm2, %xmm5
	movapd	10 * SIZE(X), %xmm2
	addpd	%xmm6, %xmm10
	movapd	12 * SIZE(X), %xmm6
	addpd	%xmm7, %xmm11
	movapd	14 * SIZE(X), %xmm7

	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3
	movapd	%xmm14, %xmm8
	movapd	%xmm14, %xmm9

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	shufps	 $0x4e, %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	shufps	 $0x4e, %xmm7, %xmm7
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	SHUFPD_1 %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	SHUFPD_1 %xmm7, %xmm7
#endif

	movapd	 8 * SIZE(Y), %xmm4
	addpd	%xmm1, %xmm4
	mulpd	%xmm15, %xmm0
	movapd	10 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm5
	mulpd	%xmm15, %xmm2
	movapd	12 * SIZE(Y), %xmm10
	addpd	%xmm8, %xmm10
	mulpd	%xmm15, %xmm6
	movapd	14 * SIZE(Y), %xmm11
	addpd	%xmm9, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm0, %xmm4
	movapd	16 * SIZE(X), %xmm0
	addpd	%xmm2, %xmm5
	movapd	18 * SIZE(X), %xmm2
	addpd	%xmm6, %xmm10
	movapd	20 * SIZE(X), %xmm6
	addpd	%xmm7, %xmm11
	movapd	22 * SIZE(X), %xmm7

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	subq	$-16 * SIZE, Y
	subq	$-16 * SIZE, X
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3
	movapd	%xmm14, %xmm8
	movapd	%xmm14, %xmm9

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	shufps	 $0x4e, %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	shufps	 $0x4e, %xmm7, %xmm7
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	SHUFPD_1 %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	SHUFPD_1 %xmm7, %xmm7
#endif

	movapd	 0 * SIZE(Y), %xmm4
	addpd	%xmm1, %xmm4
	mulpd	%xmm15, %xmm0
	movapd	 2 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm5
	mulpd	%xmm15, %xmm2
	movapd	 4 * SIZE(Y), %xmm10
	addpd	%xmm8, %xmm10
	mulpd	%xmm15, %xmm6
	movapd	 6 * SIZE(Y), %xmm11
	addpd	%xmm9, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm0, %xmm4
	movapd	 8 * SIZE(X), %xmm0
	addpd	%xmm2, %xmm5
	movapd	10 * SIZE(X), %xmm2
	addpd	%xmm6, %xmm10
	movapd	12 * SIZE(X), %xmm6
	addpd	%xmm7, %xmm11
	movapd	14 * SIZE(X), %xmm7

	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3
	movapd	%xmm14, %xmm8
	movapd	%xmm14, %xmm9

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	shufps	 $0x4e, %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	shufps	 $0x4e, %xmm7, %xmm7
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	SHUFPD_1 %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	SHUFPD_1 %xmm7, %xmm7
#endif

	movapd	 8 * SIZE(Y), %xmm4
	addpd	%xmm1, %xmm4
	mulpd	%xmm15, %xmm0
	movapd	10 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm5
	mulpd	%xmm15, %xmm2
	movapd	12 * SIZE(Y), %xmm10
	addpd	%xmm8, %xmm10
	mulpd	%xmm15, %xmm6
	movapd	14 * SIZE(Y), %xmm11
	addpd	%xmm9, %xmm11
	mulpd	%xmm15, %xmm7

	addpd	%xmm0, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm6, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	ALIGN_3

.L15:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L16

	movapd	 0 * SIZE(X), %xmm0
	movapd	 2 * SIZE(X), %xmm2
	movapd	 4 * SIZE(X), %xmm6
	movapd	 6 * SIZE(X), %xmm7

	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3
	movapd	%xmm14, %xmm8
	movapd	%xmm14, %xmm9

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	shufps	 $0x4e, %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	shufps	 $0x4e, %xmm7, %xmm7
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
	mulpd	%xmm6,  %xmm8
	SHUFPD_1 %xmm6, %xmm6
	mulpd	%xmm7,  %xmm9
	SHUFPD_1 %xmm7, %xmm7
#endif

	mulpd	%xmm15, %xmm0
	mulpd	%xmm15, %xmm2
	mulpd	%xmm15, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm4
	addpd	%xmm3, %xmm5
	addpd	%xmm8, %xmm10
	addpd	%xmm9, %xmm11

	addpd	%xmm0, %xmm4
	addpd	%xmm2, %xmm5
	addpd	%xmm6, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L17

	movapd	 0 * SIZE(X), %xmm0
	movapd	 2 * SIZE(X), %xmm2
	movapd	%xmm14, %xmm1
	movapd	%xmm14, %xmm3

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	shufps	 $0x4e, %xmm2, %xmm2
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
	mulpd	%xmm2,  %xmm3
	SHUFPD_1 %xmm2, %xmm2
#endif

	mulpd	%xmm15, %xmm0
	mulpd	%xmm15, %xmm2

	addpd	%xmm1, %xmm4
	addpd	%xmm3, %xmm5
	addpd	%xmm0, %xmm4
	addpd	%xmm2, %xmm5

	movapd	%xmm4,   0 * SIZE(Y)
	movapd	%xmm5,   2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	movapd	 0 * SIZE(X), %xmm0
	movapd	%xmm14, %xmm1
	movapd	 0 * SIZE(Y), %xmm4

#ifdef PENRYN
	mulpd	%xmm0,  %xmm1
	shufps	 $0x4e, %xmm0, %xmm0
#else
	mulpd	%xmm0,  %xmm1
	SHUFPD_1 %xmm0, %xmm0
#endif
	mulpd	%xmm15, %xmm0
	addpd	%xmm0, %xmm4
	addpd	%xmm1, %xmm4

	movapd	%xmm4,   0 * SIZE(Y)

	jmp	.L999
	ALIGN_3

.L20:
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L25

	movsd	 0 * SIZE(X), %xmm0
	movhpd	 1 * SIZE(X), %xmm0
	movsd	 2 * SIZE(X), %xmm2
	movhpd	 3 * SIZE(X), %xmm2
	movsd	 4 * SIZE(X), %xmm4
	movhpd	 5 * SIZE(X), %xmm4
	movsd	 6 * SIZE(X), %xmm6
	movhpd	 7 * SIZE(X), %xmm6

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

	subq	 $1, %rax
	jle	 .L22
	ALIGN_3

.L21:
	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm4, %xmm10
	addpd	%xmm6, %xmm11

	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3
	mulpd	%xmm15, %xmm5
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	movsd	 8 * SIZE(X), %xmm0
	movhpd	 9 * SIZE(X), %xmm0
	movsd	10 * SIZE(X), %xmm2
	movhpd	11 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm4
	movhpd	13 * SIZE(X), %xmm4
	movsd	14 * SIZE(X), %xmm6
	movhpd	15 * SIZE(X), %xmm6

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

	movapd	 8 * SIZE(Y), %xmm8
	movapd	10 * SIZE(Y), %xmm9
	movapd	12 * SIZE(Y), %xmm10
	movapd	14 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm4, %xmm10
	addpd	%xmm6, %xmm11

	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3
	mulpd	%xmm15, %xmm5
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	movsd	16 * SIZE(X), %xmm0
	movhpd	17 * SIZE(X), %xmm0
	movsd	18 * SIZE(X), %xmm2
	movhpd	19 * SIZE(X), %xmm2
	movsd	20 * SIZE(X), %xmm4
	movhpd	21 * SIZE(X), %xmm4
	movsd	22 * SIZE(X), %xmm6
	movhpd	23 * SIZE(X), %xmm6

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	subq	$1, %rax
	jg	.L21
	ALIGN_3

.L22:
	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm4, %xmm10
	addpd	%xmm6, %xmm11

	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3
	mulpd	%xmm15, %xmm5
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   0 * SIZE(Y)
	movapd	%xmm9,   2 * SIZE(Y)
	movapd	%xmm10,  4 * SIZE(Y)
	movapd	%xmm11,  6 * SIZE(Y)

	movsd	 8 * SIZE(X), %xmm0
	movhpd	 9 * SIZE(X), %xmm0
	movsd	10 * SIZE(X), %xmm2
	movhpd	11 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm4
	movhpd	13 * SIZE(X), %xmm4
	movsd	14 * SIZE(X), %xmm6
	movhpd	15 * SIZE(X), %xmm6

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

	movapd	 8 * SIZE(Y), %xmm8
	movapd	10 * SIZE(Y), %xmm9
	movapd	12 * SIZE(Y), %xmm10
	movapd	14 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm4, %xmm10
	addpd	%xmm6, %xmm11

	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3
	mulpd	%xmm15, %xmm5
	mulpd	%xmm15, %xmm7

	addpd	%xmm1, %xmm8
	addpd	%xmm3, %xmm9
	addpd	%xmm5, %xmm10
	addpd	%xmm7, %xmm11

	movapd	%xmm8,   8 * SIZE(Y)
	movapd	%xmm9,  10 * SIZE(Y)
	movapd	%xmm10, 12 * SIZE(Y)
	movapd	%xmm11, 14 * SIZE(Y)

	subq	$-16 * SIZE, X
	subq	$-16 * SIZE, Y
	ALIGN_3

.L25:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L26

	movsd	 0 * SIZE(X), %xmm0
	movhpd	 1 * SIZE(X), %xmm0
	movsd	 2 * SIZE(X), %xmm2
	movhpd	 3 * SIZE(X), %xmm2
	movsd	 4 * SIZE(X), %xmm4
	movhpd	 5 * SIZE(X), %xmm4
	movsd	 6 * SIZE(X), %xmm6
	movhpd	 7 * SIZE(X), %xmm6

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	addpd	%xmm0, %xmm8
	addpd	%xmm2, %xmm9
	addpd	%xmm4, %xmm10
	addpd	%xmm6, %xmm11

	mulpd	%xmm15, %xmm1
	mulpd	%xmm15, %xmm3
	mulpd	%xmm15, %xmm5
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

.L26:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L27

	movsd	 0 * SIZE(X), %xmm0
	movhpd	 1 * SIZE(X), %xmm0
	movsd	 2 * SIZE(X), %xmm2
	movhpd	 3 * SIZE(X), %xmm2

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3

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

.L27:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	movsd	 0 * SIZE(X), %xmm0
	movhpd	 1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	
	movapd	 0 * SIZE(Y), %xmm8

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movapd	%xmm8,   0 * SIZE(Y)
	jmp	.L999
	ALIGN_3

.L30:
	testq	$SIZE, X
	jne	.L40

#ifndef CONJ
	movddup	 %xmm0,  %xmm14
	pxor	 %xmm15, %xmm15
	subsd	 %xmm1,  %xmm15
	unpcklpd %xmm1,  %xmm15
#else
	movddup	 %xmm1,  %xmm15
	movapd	 %xmm0,  %xmm14
	pxor	 %xmm13, %xmm13
	subsd	 %xmm0,  %xmm13
	unpcklpd %xmm13, %xmm14
#endif

	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L35

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X
	movapd	 (X), %xmm4
	addq	INCX, X
	movapd	 (X), %xmm6
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

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
	jle	.L32
	ALIGN_3

.L31:
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

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X
	movapd	 (X), %xmm4
	addq	INCX, X
	movapd	 (X), %xmm6
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

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

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X
	movapd	 (X), %xmm4
	addq	INCX, X
	movapd	 (X), %xmm6
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

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

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X
	movapd	 (X), %xmm4
	addq	INCX, X
	movapd	 (X), %xmm6
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

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

.L35:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L36

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X
	movapd	 (X), %xmm4
	addq	INCX, X
	movapd	 (X), %xmm6
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3
	pshufd	 $0x4e, %xmm4, %xmm5
	pshufd	 $0x4e, %xmm6, %xmm7

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

.L36:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L37

	movapd	 (X), %xmm0
	addq	INCX, X
	movapd	 (X), %xmm2
	addq	INCX, X

	pshufd	 $0x4e, %xmm0, %xmm1
	pshufd	 $0x4e, %xmm2, %xmm3

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

.L37:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 (Y), %xmm8

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8
	movapd	%xmm8,   (YY)
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
	jle	.L42
	ALIGN_3

.L41:
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

.L47:
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

.L50:
	movq	Y, YY
	movq	M,  %rax
	sarq	$3, %rax
	jle	.L55

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

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	mulpd	%xmm14, %xmm0
	mulpd	%xmm14, %xmm2
	mulpd	%xmm14, %xmm4
	mulpd	%xmm14, %xmm6

	decq	%rax
	jle	.L52
	ALIGN_3

.L51:
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

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm11
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

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm11
	movhpd	 1 * SIZE(Y), %xmm11
	addq	 INCY, Y

	decq	%rax
	jg	.L51
	ALIGN_3

.L52:
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

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm11
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

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm10,  0 * SIZE(YY)
	movhpd	%xmm10,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm11,  0 * SIZE(YY)
	movhpd	%xmm11,  1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L55:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L56

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

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
	movhpd	 1 * SIZE(Y), %xmm9
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm10
	movhpd	 1 * SIZE(Y), %xmm10
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm11
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

	movsd	%xmm8,  0 * SIZE(YY)
	movhpd	%xmm8,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,  0 * SIZE(YY)
	movhpd	%xmm9,  1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm10, 0 * SIZE(YY)
	movhpd	%xmm10, 1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm11, 0 * SIZE(YY)
	movhpd	%xmm11, 1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L56:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L57

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)
	addq	INCX, X
	MOVDDUP( 0 * SIZE, X, %xmm2)
	MOVDDUP( 1 * SIZE, X, %xmm3)
	addq	INCX, X

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	addq	 INCY, Y
	movsd	 0 * SIZE(Y), %xmm9
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

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	addq	 INCY, YY
	movsd	%xmm9,   0 * SIZE(YY)
	movhpd	%xmm9,   1 * SIZE(YY)
	addq	 INCY, YY
	ALIGN_3

.L57:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L999

	MOVDDUP( 0 * SIZE, X, %xmm0)
	MOVDDUP( 1 * SIZE, X, %xmm1)

	movsd	 0 * SIZE(Y), %xmm8
	movhpd	 1 * SIZE(Y), %xmm8
	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm0, %xmm8
	addpd	%xmm1, %xmm8

	movsd	%xmm8,   0 * SIZE(YY)
	movhpd	%xmm8,   1 * SIZE(YY)
	ALIGN_3

.L999:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE
