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
#define M	ARG1	/* rdi */
#define X	ARG4
#define INCX	ARG5
#define Y	ARG6
#define INCY	ARG2
#define FLAG	ARG3
#else
#define M	ARG1
#define X	ARG2
#define INCX	ARG3
#define Y	ARG4
#define INCY	%rbx
#define FLAG	%rdi
#endif

#define XX	%r10
#define YY	%r11

#ifdef BARCELONA
#define	PREFETCHW	prefetchw
#define	PREFETCHSIZE	(8 * 16)
#endif

	PROLOGUE
	PROFCODE

#ifndef WINDOWS_ABI
	movq	 8(%rsp), INCY
#else
	pushq	%rbx
	pushq	%rdi

	movq	64(%rsp), X
	movq	72(%rsp), INCX
	movq	80(%rsp), Y
	movq	88(%rsp), INCY
#endif

	SAVEREGISTERS

	salq	$ZBASE_SHIFT, INCX
	salq	$ZBASE_SHIFT, INCY
	xorq	FLAG, FLAG

	cmpq	$0, M
	jle	.L19

	cmpq	$2 * SIZE, INCX
	jne	.L40
	cmpq	$2 * SIZE, INCY
	jne	.L40

	testq	$SIZE, Y
	je	.L10

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm8

	movsd	%xmm8, 0 * SIZE(X)
	movsd	%xmm0, 0 * SIZE(Y)

	movq	$1, FLAG
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	jle	.L18
	ALIGN_4

.L10:
	testq	$SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L13

	movapd	 0 * SIZE(X), %xmm0
	movapd	 2 * SIZE(X), %xmm1
	movapd	 4 * SIZE(X), %xmm2
	movapd	 6 * SIZE(X), %xmm3

	movapd	 0 * SIZE(Y), %xmm8
	movapd	 2 * SIZE(Y), %xmm9
	movapd	 4 * SIZE(Y), %xmm10
	movapd	 6 * SIZE(Y), %xmm11

	movapd	 8 * SIZE(X), %xmm4
	movapd	10 * SIZE(X), %xmm5
	movapd	12 * SIZE(X), %xmm6
	movapd	14 * SIZE(X), %xmm7

	movapd	 8 * SIZE(Y), %xmm12
	movapd	10 * SIZE(Y), %xmm13
	movapd	12 * SIZE(Y), %xmm14
	movapd	14 * SIZE(Y), %xmm15

	decq	%rax
	jle .L12
	ALIGN_3

.L11:
#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 0)(X)
#endif

	movapd	%xmm8, 	 0 * SIZE(X)
	movapd	%xmm9, 	 2 * SIZE(X)
	movapd	%xmm10,	 4 * SIZE(X)
	movapd	%xmm11,	 6 * SIZE(X)

	movapd	16 * SIZE(Y), %xmm8
	movapd	18 * SIZE(Y), %xmm9
	movapd	20 * SIZE(Y), %xmm10
	movapd	22 * SIZE(Y), %xmm11

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 0)(Y)
#endif

	movapd	%xmm0, 	 0 * SIZE(Y)
	movapd	%xmm1, 	 2 * SIZE(Y)
	movapd	%xmm2, 	 4 * SIZE(Y)
	movapd	%xmm3, 	 6 * SIZE(Y)

	movapd	16 * SIZE(X), %xmm0
	movapd	18 * SIZE(X), %xmm1
	movapd	20 * SIZE(X), %xmm2
	movapd	22 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 8)(X)
#endif

	movapd	%xmm12,	 8 * SIZE(X)
	movapd	%xmm13,	10 * SIZE(X)
	movapd	%xmm14,	12 * SIZE(X)
	movapd	%xmm15,	14 * SIZE(X)

	movapd	24 * SIZE(Y), %xmm12
	movapd	26 * SIZE(Y), %xmm13
	movapd	28 * SIZE(Y), %xmm14
	movapd	30 * SIZE(Y), %xmm15

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 8)(Y)
#endif

	movapd	%xmm4, 	 8 * SIZE(Y)
	movapd	%xmm5, 	10 * SIZE(Y)
	movapd	%xmm6, 	12 * SIZE(Y)
	movapd	%xmm7, 	14 * SIZE(Y)

	movapd	24 * SIZE(X), %xmm4
	movapd	26 * SIZE(X), %xmm5
	movapd	28 * SIZE(X), %xmm6
	movapd	30 * SIZE(X), %xmm7

	addq	$16 * SIZE, Y
	addq	$16 * SIZE, X
	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	movapd	%xmm8, 	 0 * SIZE(X)
	movapd	%xmm9, 	 2 * SIZE(X)
	movapd	%xmm10,	 4 * SIZE(X)
	movapd	%xmm11,	 6 * SIZE(X)

	movapd	%xmm0, 	 0 * SIZE(Y)
	movapd	%xmm1, 	 2 * SIZE(Y)
	movapd	%xmm2, 	 4 * SIZE(Y)
	movapd	%xmm3, 	 6 * SIZE(Y)

	movapd	%xmm12,	 8 * SIZE(X)
	movapd	%xmm13,	10 * SIZE(X)
	movapd	%xmm14,	12 * SIZE(X)
	movapd	%xmm15,	14 * SIZE(X)

	movapd	%xmm4, 	 8 * SIZE(Y)
	movapd	%xmm5, 	10 * SIZE(Y)
	movapd	%xmm6, 	12 * SIZE(Y)
	movapd	%xmm7, 	14 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L13:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L14
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1
	movapd	4 * SIZE(X), %xmm2
	movapd	6 * SIZE(X), %xmm3
	movapd	0 * SIZE(Y), %xmm8
	movapd	2 * SIZE(Y), %xmm9
	movapd	4 * SIZE(Y), %xmm10
	movapd	6 * SIZE(Y), %xmm11

	movapd	%xmm8, 	0 * SIZE(X)
	movapd	%xmm9, 	2 * SIZE(X)
	movapd	%xmm10,	4 * SIZE(X)
	movapd	%xmm11,	6 * SIZE(X)
	movapd	%xmm0, 	0 * SIZE(Y)
	movapd	%xmm1, 	2 * SIZE(Y)
	movapd	%xmm2, 	4 * SIZE(Y)
	movapd	%xmm3, 	6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L14:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L15
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1
	movapd	0 * SIZE(Y), %xmm8
	movapd	2 * SIZE(Y), %xmm9

	movapd	%xmm8, 	0 * SIZE(X)
	movapd	%xmm9, 	2 * SIZE(X)
	movapd	%xmm0, 	0 * SIZE(Y)
	movapd	%xmm1, 	2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L15:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L18
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	0 * SIZE(Y), %xmm8

	movapd	%xmm8, 	0 * SIZE(X)
	movapd	%xmm0, 	0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L18:
	testq	FLAG, FLAG
	je	.L19
	
	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm8

	movsd	%xmm8, 0 * SIZE(X)
	movsd	%xmm0, 0 * SIZE(Y)


.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

#ifdef WINDOWS_ABI
	popq	%rdi
	popq	%rbx
#endif

	ret
	ALIGN_3

.L20:
	movapd	-1 * SIZE(X), %xmm0

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L23

	movapd	  1 * SIZE(X), %xmm1
	movapd	  3 * SIZE(X), %xmm2
	movapd	  5 * SIZE(X), %xmm3
	movapd	  7 * SIZE(X), %xmm4
	movapd	  9 * SIZE(X), %xmm5
	movapd	 11 * SIZE(X), %xmm6
	movapd	 13 * SIZE(X), %xmm7

	movapd	  0 * SIZE(Y), %xmm8
	movapd	  2 * SIZE(Y), %xmm9
	movapd	  4 * SIZE(Y), %xmm10
	movapd	  6 * SIZE(Y), %xmm11
	movapd	  8 * SIZE(Y), %xmm12
	movapd	 10 * SIZE(Y), %xmm13
	movapd	 12 * SIZE(Y), %xmm14
	movapd	 14 * SIZE(Y), %xmm15

	movlpd	%xmm8,   0 * SIZE(X)

	decq	%rax
	jle .L22
	ALIGN_4

.L21:
#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 0)(X)
#endif

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm4, %xmm3

	movapd	%xmm0,   0 * SIZE(Y)
	movapd	%xmm1,   2 * SIZE(Y)
	movapd	%xmm2,   4 * SIZE(Y)
	movapd	%xmm3,   6 * SIZE(Y)

	movapd	 15 * SIZE(X), %xmm0
	movapd	 17 * SIZE(X), %xmm1
	movapd	 19 * SIZE(X), %xmm2
	movapd	 21 * SIZE(X), %xmm3

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 0)(Y)
#endif

	SHUFPD_1 %xmm5, %xmm4
	SHUFPD_1 %xmm6, %xmm5
	SHUFPD_1 %xmm7, %xmm6
	SHUFPD_1 %xmm0, %xmm7

	SHUFPD_1 %xmm9,   %xmm8
	SHUFPD_1 %xmm10,  %xmm9
	SHUFPD_1 %xmm11,  %xmm10
	SHUFPD_1 %xmm12,  %xmm11

	movapd	%xmm8,   1 * SIZE(X)
	movapd	%xmm9,   3 * SIZE(X)
	movapd	%xmm10,  5 * SIZE(X)
	movapd	%xmm11,  7 * SIZE(X)

	movapd	 16 * SIZE(Y), %xmm8
	movapd	 18 * SIZE(Y), %xmm9
	movapd	 20 * SIZE(Y), %xmm10
	movapd	 22 * SIZE(Y), %xmm11

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 8)(X)
#endif

	SHUFPD_1 %xmm13,  %xmm12
	SHUFPD_1 %xmm14,  %xmm13
	SHUFPD_1 %xmm15,  %xmm14
	SHUFPD_1 %xmm8,   %xmm15

	movapd	%xmm12,  9 * SIZE(X)
	movapd	%xmm13, 11 * SIZE(X)
	movapd	%xmm14, 13 * SIZE(X)
	movapd	%xmm15, 15 * SIZE(X)

#ifdef BARCELONA
	PREFETCHW	(PREFETCHSIZE + 8)(Y)
#endif

	movapd	 24 * SIZE(Y), %xmm12
	movapd	 26 * SIZE(Y), %xmm13
	movapd	 28 * SIZE(Y), %xmm14
	movapd	 30 * SIZE(Y), %xmm15

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)
	movapd	%xmm6,  12 * SIZE(Y)
	movapd	%xmm7,  14 * SIZE(Y)

	movapd	 23 * SIZE(X), %xmm4
	movapd	 25 * SIZE(X), %xmm5
	movapd	 27 * SIZE(X), %xmm6
	movapd	 29 * SIZE(X), %xmm7

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y

	decq	%rax
	jg	.L21
	ALIGN_3

.L22:
	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm4, %xmm3

	movapd	%xmm0,   0 * SIZE(Y)
	movapd	%xmm1,   2 * SIZE(Y)
	movapd	%xmm2,   4 * SIZE(Y)
	movapd	%xmm3,   6 * SIZE(Y)

	movapd	 15 * SIZE(X), %xmm0

	SHUFPD_1 %xmm5, %xmm4
	SHUFPD_1 %xmm6, %xmm5
	SHUFPD_1 %xmm7, %xmm6
	SHUFPD_1 %xmm0, %xmm7

	SHUFPD_1 %xmm9,   %xmm8
	SHUFPD_1 %xmm10,  %xmm9
	SHUFPD_1 %xmm11,  %xmm10
	SHUFPD_1 %xmm12,  %xmm11
	SHUFPD_1 %xmm13,  %xmm12
	SHUFPD_1 %xmm14,  %xmm13
	SHUFPD_1 %xmm15,  %xmm14

	movapd	%xmm4,   8 * SIZE(Y)
	movapd	%xmm5,  10 * SIZE(Y)
	movapd	%xmm6,  12 * SIZE(Y)
	movapd	%xmm7,  14 * SIZE(Y)

	movapd	%xmm8,   1 * SIZE(X)
	movapd	%xmm9,   3 * SIZE(X)
	movapd	%xmm10,  5 * SIZE(X)
	movapd	%xmm11,  7 * SIZE(X)
	movapd	%xmm12,  9 * SIZE(X)
	movapd	%xmm13, 11 * SIZE(X)
	movapd	%xmm14, 13 * SIZE(X)
	movhpd	%xmm15, 15 * SIZE(X)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L23:
	movq	M,  %rax
	andq	$4, %rax
	jle	.L24
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2
	movapd	5 * SIZE(X), %xmm3
	movapd	7 * SIZE(X), %xmm4

	movapd	0 * SIZE(Y), %xmm8
	movapd	2 * SIZE(Y), %xmm9
	movapd	4 * SIZE(Y), %xmm10
	movapd	6 * SIZE(Y), %xmm11

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm4, %xmm3

	movlpd	%xmm8,  0 * SIZE(X)
	SHUFPD_1 %xmm9,  %xmm8
	SHUFPD_1 %xmm10, %xmm9
	SHUFPD_1 %xmm11, %xmm10
	movapd	%xmm8,  1 * SIZE(X)
	movapd	%xmm9,  3 * SIZE(X)
	movapd	%xmm10, 5 * SIZE(X)
	movhpd	%xmm11, 7 * SIZE(X)

	movapd	%xmm0,  0 * SIZE(Y)
	movapd	%xmm1,  2 * SIZE(Y)
	movapd	%xmm2,  4 * SIZE(Y)
	movapd	%xmm3,  6 * SIZE(Y)
	movapd	%xmm4, %xmm0

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L24:
	movq	M,  %rax
	andq	$2, %rax
	jle	.L25
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2
	movapd	0 * SIZE(Y), %xmm8
	movapd	2 * SIZE(Y), %xmm9

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1

	movlpd	%xmm8, 0 * SIZE(X)
	SHUFPD_1 %xmm9, %xmm8
	movapd	%xmm8, 1 * SIZE(X)
	movhpd	%xmm9, 3 * SIZE(X)

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, %xmm0

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L25:
	movq	M,  %rax
	andq	$1, %rax
	jle	.L28
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0

	movapd	0 * SIZE(Y), %xmm8

	movlpd	%xmm8, 0 * SIZE(X)
	movhpd	%xmm8, 1 * SIZE(X)
	movapd	%xmm0, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L28:
	testq	FLAG, FLAG
	je	.L29

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm8

	movsd	%xmm8, 0 * SIZE(X)
	movsd	%xmm0, 0 * SIZE(Y)
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

#ifdef WINDOWS_ABI
	popq	%rdi
	popq	%rbx
#endif

	ret
	ALIGN_3


.L40:
	movq	X, XX
	movq	Y, YY

	testq	$SIZE, X
	jne	.L60
	testq	$SIZE, Y
	jne	.L60

	movq	M,  %rax
	sarq	$2, %rax
	jle	.L45
	ALIGN_3

.L41:
	movapd	0 * SIZE(X), %xmm0
	addq	INCX, X
	movapd	0 * SIZE(Y), %xmm8
	addq	INCY, Y
	movapd	0 * SIZE(X), %xmm1
	addq	INCX, X
	movapd	0 * SIZE(Y), %xmm9
	addq	INCY, Y
	movapd	0 * SIZE(X), %xmm2
	addq	INCX, X
	movapd	0 * SIZE(Y), %xmm10
	addq	INCY, Y
	movapd	0 * SIZE(X), %xmm3
	addq	INCX, X
	movapd	0 * SIZE(Y), %xmm11
	addq	INCY, Y

	movapd	%xmm8, 0 * SIZE(XX)
	addq	INCX, XX
	movapd	%xmm0, 0 * SIZE(YY)
	addq	INCY, YY
	movapd	%xmm9, 0 * SIZE(XX)
	addq	INCX, XX
	movapd	%xmm1, 0 * SIZE(YY)
	addq	INCY, YY
	movapd	%xmm10, 0 * SIZE(XX)
	addq	INCX, XX
	movapd	%xmm2, 0 * SIZE(YY)
	addq	INCY, YY
	movapd	%xmm11, 0 * SIZE(XX)
	addq	INCX, XX
	movapd	%xmm3, 0 * SIZE(YY)
	addq	INCY, YY

	decq	%rax
	jg	.L41
	ALIGN_3

.L45:
	movq	M,  %rax
	andq	$3, %rax
	jle	.L47
	ALIGN_3

.L46:
	movapd	(X), %xmm0
	movapd	(Y), %xmm8

	movapd	%xmm8, (X)
	movapd	%xmm0, (Y)

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L46
	ALIGN_3

.L47:
	xorq	%rax, %rax

	RESTOREREGISTERS

#ifdef WINDOWS_ABI
	popq	%rdi
	popq	%rbx
#endif

	ret
	ALIGN_3

.L60:
	movq	M,  %rax
	sarq	$2, %rax
	jle	.L65
	ALIGN_3

.L61:
	movsd	0 * SIZE(X), %xmm0
	movsd	1 * SIZE(X), %xmm1
	addq	INCX, X
	movsd	0 * SIZE(Y), %xmm8
	movsd	1 * SIZE(Y), %xmm9
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm2
	movsd	1 * SIZE(X), %xmm3
	addq	INCX, X
	movsd	0 * SIZE(Y), %xmm10
	movsd	1 * SIZE(Y), %xmm11
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm4
	movsd	1 * SIZE(X), %xmm5
	addq	INCX, X
	movsd	0 * SIZE(Y), %xmm12
	movsd	1 * SIZE(Y), %xmm13
	addq	INCY, Y
	movsd	0 * SIZE(X), %xmm6
	movsd	1 * SIZE(X), %xmm7
	addq	INCX, X
	movsd	0 * SIZE(Y), %xmm14
	movsd	1 * SIZE(Y), %xmm15
	addq	INCY, Y

	movsd	%xmm8, 0 * SIZE(XX)
	movsd	%xmm9, 1 * SIZE(XX)
	addq	INCX, XX
	movsd	%xmm0, 0 * SIZE(YY)
	movsd	%xmm1, 1 * SIZE(YY)
	addq	INCY, YY
	movsd	%xmm10, 0 * SIZE(XX)
	movsd	%xmm11, 1 * SIZE(XX)
	addq	INCX, XX
	movsd	%xmm2, 0 * SIZE(YY)
	movsd	%xmm3, 1 * SIZE(YY)
	addq	INCY, YY
	movsd	%xmm12, 0 * SIZE(XX)
	movsd	%xmm13, 1 * SIZE(XX)
	addq	INCX, XX
	movsd	%xmm4, 0 * SIZE(YY)
	movsd	%xmm5, 1 * SIZE(YY)
	addq	INCY, YY
	movsd	%xmm14, 0 * SIZE(XX)
	movsd	%xmm15, 1 * SIZE(XX)
	addq	INCX, XX
	movsd	%xmm6, 0 * SIZE(YY)
	movsd	%xmm7, 1 * SIZE(YY)
	addq	INCY, YY

	decq	%rax
	jg	.L61
	ALIGN_3

.L65:
	movq	M,  %rax
	andq	$3, %rax
	jle	.L67
	ALIGN_3

.L66:
	movsd	0 * SIZE(X), %xmm0
	movsd	1 * SIZE(X), %xmm1
	movsd	0 * SIZE(Y), %xmm8
	movsd	1 * SIZE(Y), %xmm9

	movsd	%xmm8, 0 * SIZE(X)
	movsd	%xmm9, 1 * SIZE(X)
	movsd	%xmm0, 0 * SIZE(Y)
	movsd	%xmm1, 1 * SIZE(Y)

	addq	INCX, X
	addq	INCY, Y
	decq	%rax
	jg	.L66
	ALIGN_3

.L67:
	xorq	%rax, %rax

	RESTOREREGISTERS

#ifdef WINDOWS_ABI
	popq	%rdi
	popq	%rbx
#endif

	ret

	EPILOGUE
