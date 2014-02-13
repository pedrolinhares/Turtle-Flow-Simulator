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

#define PREFETCHSIZE	(16 * 8)

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
	movss	40(%rsp), %xmm1	

	movq	48(%rsp), X
	movq	56(%rsp), INCX
	movq	64(%rsp), Y
	movq	72(%rsp), INCY
#endif

	SAVEREGISTERS
	
	leaq	(, INCX, SIZE * 2), INCX
	leaq	(, INCY, SIZE * 2), INCY

#ifndef CONJ
	pshufd	$0, %xmm0, %xmm14
	pshufd	$0, %xmm1, %xmm1

	pxor	 %xmm15, %xmm15
	subps	 %xmm1,  %xmm15

	unpcklps %xmm1,  %xmm15
#else
	pshufd	$0, %xmm0, %xmm14
	pshufd	$0, %xmm1, %xmm15

	pxor	 %xmm13, %xmm13
	subps	 %xmm14, %xmm13

	unpcklps %xmm13,  %xmm14
#endif

	cmpq	$2 * SIZE, INCX
	jne	.L20
	cmpq	$2 * SIZE, INCY
	jne	.L20

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L15
	ALIGN_3

.L12:
	prefetch	PREFETCHSIZE * SIZE(X)

	movlps	 0 * SIZE(X),  %xmm0
	movhps	 2 * SIZE(X),  %xmm0
	movlps	 4 * SIZE(X),  %xmm2
	movhps	 6 * SIZE(X),  %xmm2
	movlps	 8 * SIZE(X),  %xmm4
	movhps	10 * SIZE(X),  %xmm4
	movlps	12 * SIZE(X),  %xmm6
	movhps	14 * SIZE(X),  %xmm6

	pshufd	 $0xb1, %xmm0, %xmm1
	pshufd	 $0xb1, %xmm2, %xmm3
	pshufd	 $0xb1, %xmm4, %xmm5
	pshufd	 $0xb1, %xmm6, %xmm7

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1
	mulps	%xmm14, %xmm2
	mulps	%xmm15, %xmm3

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	mulps	%xmm14, %xmm6
	mulps	%xmm15, %xmm7

	prefetchw	PREFETCHSIZE * SIZE(Y)

	movlps	 0 * SIZE(Y), %xmm8
	movhps	 2 * SIZE(Y), %xmm8
	movlps	 4 * SIZE(Y), %xmm9
	movhps	 6 * SIZE(Y), %xmm9
	movlps	 8 * SIZE(Y), %xmm10
	movhps	10 * SIZE(Y), %xmm10
	movlps	12 * SIZE(Y), %xmm11
	movhps	14 * SIZE(Y), %xmm11

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8
	addps	%xmm2, %xmm9
	addps	%xmm3, %xmm9

	addps	%xmm4, %xmm10
	addps	%xmm5, %xmm10
	addps	%xmm6, %xmm11
	addps	%xmm7, %xmm11

	movlps	%xmm8,   0 * SIZE(Y)
	movhps	%xmm8,   2 * SIZE(Y)
	movlps	%xmm9,   4 * SIZE(Y)
	movhps	%xmm9,   6 * SIZE(Y)
	movlps	%xmm10,  8 * SIZE(Y)
	movhps	%xmm10, 10 * SIZE(Y)
	movlps	%xmm11, 12 * SIZE(Y)
	movhps	%xmm11, 14 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	decq	%rax
	jg	.L12
	ALIGN_3

.L15:
	testq	$4, M
	jle	.L16

	movlps	 0 * SIZE(X),  %xmm0
	movhps	 2 * SIZE(X),  %xmm0
	movlps	 4 * SIZE(X),  %xmm2
	movhps	 6 * SIZE(X),  %xmm2

	pshufd	 $0xb1, %xmm0, %xmm1
	pshufd	 $0xb1, %xmm2, %xmm3

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1
	mulps	%xmm14, %xmm2
	mulps	%xmm15, %xmm3

	movlps	 0 * SIZE(Y), %xmm8
	movhps	 2 * SIZE(Y), %xmm8
	movlps	 4 * SIZE(Y), %xmm9
	movhps	 6 * SIZE(Y), %xmm9

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8
	addps	%xmm2, %xmm9
	addps	%xmm3, %xmm9

	movlps	%xmm8,   0 * SIZE(Y)
	movhps	%xmm8,   2 * SIZE(Y)
	movlps	%xmm9,   4 * SIZE(Y)
	movhps	%xmm9,   6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_2

.L16:
	testq	$2, M
	jle	.L17

	movlps	 0 * SIZE(X),  %xmm0
	movhps	 2 * SIZE(X),  %xmm0

	pshufd	 $0xb1, %xmm0, %xmm1

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1

	movlps	 0 * SIZE(Y), %xmm8
	movhps	 2 * SIZE(Y), %xmm8

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8

	movlps	%xmm8,   0 * SIZE(Y)
	movhps	%xmm8,   2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_2

.L17:
	testq	$1, M
	jle	.L999

	movlps	 0 * SIZE(X),  %xmm0
	pshufd	 $0xb1, %xmm0, %xmm1

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1

	movlps	 0 * SIZE(Y), %xmm8

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8

	movlps	%xmm8,   0 * SIZE(Y)
	jmp	.L999
	ALIGN_3

.L20:
	movq	Y, YY

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L25
	ALIGN_3

.L22:
	movlps	(X),  %xmm0
	addq	INCX, X
	movhps	(X),  %xmm0
	addq	INCX, X
	movlps	(X),  %xmm2
	addq	INCX, X
	movhps	(X),  %xmm2
	addq	INCX, X
	movlps	(X),  %xmm4
	addq	INCX, X
	movhps	(X),  %xmm4
	addq	INCX, X
	movlps	(X),  %xmm6
	addq	INCX, X
	movhps	(X),  %xmm6
	addq	INCX, X

	pshufd	 $0xb1, %xmm0, %xmm1
	pshufd	 $0xb1, %xmm2, %xmm3
	pshufd	 $0xb1, %xmm4, %xmm5
	pshufd	 $0xb1, %xmm6, %xmm7

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1
	mulps	%xmm14, %xmm2
	mulps	%xmm15, %xmm3

	mulps	%xmm14, %xmm4
	mulps	%xmm15, %xmm5
	mulps	%xmm14, %xmm6
	mulps	%xmm15, %xmm7

	movlps	(Y), %xmm8
	addq	INCY, Y
	movhps	(Y), %xmm8
	addq	INCY, Y
	movlps	(Y), %xmm9
	addq	INCY, Y
	movhps	(Y), %xmm9
	addq	INCY, Y
	movlps	(Y), %xmm10
	addq	INCY, Y
	movhps	(Y), %xmm10
	addq	INCY, Y
	movlps	(Y), %xmm11
	addq	INCY, Y
	movhps	(Y), %xmm11
	addq	INCY, Y

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8
	addps	%xmm2, %xmm9
	addps	%xmm3, %xmm9

	addps	%xmm4, %xmm10
	addps	%xmm5, %xmm10
	addps	%xmm6, %xmm11
	addps	%xmm7, %xmm11

	movlps	%xmm8,  (YY)
	addq	INCY, YY
	movhps	%xmm8,  (YY)
	addq	INCY, YY
	movlps	%xmm9,  (YY)
	addq	INCY, YY
	movhps	%xmm9,  (YY)
	addq	INCY, YY
	movlps	%xmm10, (YY)
	addq	INCY, YY
	movhps	%xmm10, (YY)
	addq	INCY, YY
	movlps	%xmm11, (YY)
	addq	INCY, YY
	movhps	%xmm11, (YY)
	addq	INCY, YY

	decq	%rax
	jg	.L22
	ALIGN_3

.L25:
	testq	$4, M
	jle	.L26

	movlps	(X),  %xmm0
	addq	INCX, X
	movhps	(X),  %xmm0
	addq	INCX, X
	movlps	(X),  %xmm2
	addq	INCX, X
	movhps	(X),  %xmm2
	addq	INCX, X

	pshufd	 $0xb1, %xmm0, %xmm1
	pshufd	 $0xb1, %xmm2, %xmm3

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1
	mulps	%xmm14, %xmm2
	mulps	%xmm15, %xmm3

	movlps	(Y), %xmm8
	addq	INCY, Y
	movhps	(Y), %xmm8
	addq	INCY, Y
	movlps	(Y), %xmm9
	addq	INCY, Y
	movhps	(Y), %xmm9
	addq	INCY, Y

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8
	addps	%xmm2, %xmm9
	addps	%xmm3, %xmm9

	movlps	%xmm8,  (YY)
	addq	INCY, YY
	movhps	%xmm8,  (YY)
	addq	INCY, YY
	movlps	%xmm9,  (YY)
	addq	INCY, YY
	movhps	%xmm9,  (YY)
	addq	INCY, YY
	ALIGN_2

.L26:
	testq	$2, M
	jle	.L27

	movlps	(X),  %xmm0
	addq	INCX, X
	movhps	(X),  %xmm0
	addq	INCX, X

	pshufd	 $0xb1, %xmm0, %xmm1

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1

	movlps	(Y), %xmm8
	addq	INCY, Y
	movhps	(Y), %xmm8
	addq	INCY, Y

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8

	movlps	%xmm8,  (YY)
	addq	INCY, YY
	movhps	%xmm8,  (YY)
	addq	INCY, YY
	ALIGN_2

.L27:
	testq	$1, M
	jle	.L999

	movlps	 (X),  %xmm0
	pshufd	 $0xb1, %xmm0, %xmm1

	mulps	%xmm14, %xmm0
	mulps	%xmm15, %xmm1

	movlps	 (Y), %xmm8

	addps	%xmm0, %xmm8
	addps	%xmm1, %xmm8

	movlps	%xmm8,   (Y)
	jmp	.L999
	ALIGN_3

.L999:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE

