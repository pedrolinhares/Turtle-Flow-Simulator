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

#define STACK	16
#define ARGS	 0
	
#define STACK_M		 4 + STACK + ARGS(%esp)
#define ALPHA		16 + STACK + ARGS(%esp)
#define STACK_X		24 + STACK + ARGS(%esp)
#define STACK_INCX	28 + STACK + ARGS(%esp)
#define STACK_Y		32 + STACK + ARGS(%esp)
#define STACK_INCY	36 + STACK + ARGS(%esp)

#define M	 %ebx
#define X	 %esi
#define Y	 %edi
#define INCX	 %ecx
#define INCY	 %edx
	
#ifdef PENTIUM4
#define PREFETCHSIZE	128
#endif

	PROLOGUE

	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%ebp

	PROFCODE

	movsd	ALPHA, %xmm7
	unpcklpd %xmm7, %xmm7

	movl	STACK_M,    M
	movl	STACK_X,    X
	movl	STACK_INCX, INCX
	movl	STACK_Y,    Y
	movl	STACK_INCY, INCY

	leal	(, INCX, SIZE), INCX
	leal	(, INCY, SIZE), INCY

	cmpl	$SIZE, INCX
	jne	.L100
	cmpl	$SIZE, INCY
	jne	.L100

	testl	$SIZE, Y
	je	.L00

	movsd	0 * SIZE(X), %xmm0
	mulsd	%xmm7, %xmm0
	addsd	0 * SIZE(Y), %xmm0
	movsd	%xmm0, 0 * SIZE(Y)
	addl	$1 * SIZE, X
	addl	$1 * SIZE, Y
	decl	M
	jle	.L999
	ALIGN_3

.L00:
	testl	$SIZE, X
	jne	.L20

	movl	M,  %eax
	sarl	$4,  %eax
	jle	.L15
	ALIGN_3

.L11:
	movapd	 0 * SIZE(X), %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 2 * SIZE(X), %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	movapd	 4 * SIZE(X), %xmm2
	mulpd	%xmm7, %xmm2
	addpd	 4 * SIZE(Y), %xmm2
	movapd	%xmm2,  4 * SIZE(Y)

	movapd	 6 * SIZE(X), %xmm3
	mulpd	%xmm7, %xmm3
	addpd	 6 * SIZE(Y), %xmm3
	movapd	%xmm3,  6 * SIZE(Y)

	movapd	 8 * SIZE(X), %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 8 * SIZE(Y), %xmm0
	movapd	%xmm0, 8 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
#endif

	movapd	10 * SIZE(X), %xmm1
	mulpd	%xmm7, %xmm1
	addpd	10 * SIZE(Y), %xmm1
	movapd	%xmm1, 10 * SIZE(Y)

	movapd	12 * SIZE(X), %xmm2
	mulpd	%xmm7, %xmm2
	addpd	12 * SIZE(Y), %xmm2
	movapd	%xmm2, 12 * SIZE(Y)

	movapd	14 * SIZE(X), %xmm3
	mulpd	%xmm7, %xmm3
	addpd	14 * SIZE(Y), %xmm3
	movapd	%xmm3, 14 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L11
	ALIGN_3

.L15:
	movl	M,  %eax
	testl	$8, %eax
	jle	.L16

	movapd	 0 * SIZE(X), %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 2 * SIZE(X), %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	movapd	 4 * SIZE(X), %xmm2
	mulpd	%xmm7, %xmm2
	addpd	 4 * SIZE(Y), %xmm2
	movapd	%xmm2,  4 * SIZE(Y)

	movapd	 6 * SIZE(X), %xmm3
	mulpd	%xmm7, %xmm3
	addpd	 6 * SIZE(Y), %xmm3
	movapd	%xmm3,  6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L16:
	testl	$4, %eax
	jle	.L17

	movapd	 0 * SIZE(X), %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 2 * SIZE(X), %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L17:
	testl	$2, %eax
	jle	.L18

	movapd	 0 * SIZE(X), %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	addl	$2 * SIZE, X
	addl	$2 * SIZE, Y
	ALIGN_3

.L18:
	testl	$1, %eax
	jle	.L99

	movsd	0 * SIZE(X), %xmm0
	mulsd	%xmm7, %xmm0
	addsd	0 * SIZE(Y), %xmm0
	movsd	%xmm0, 	0 * SIZE(Y)
	jmp	.L99
	ALIGN_3

.L20:
	movapd	-1 * SIZE(X), %xmm0

	movl	M, %eax
	sarl	$4,   %eax
	jle	.L25
	ALIGN_4

.L21:
	movapd	 1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 3 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	movapd	 5 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 4 * SIZE(Y), %xmm0
	movapd	%xmm0,  4 * SIZE(Y)

	movapd	 7 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 6 * SIZE(Y), %xmm1
	movapd	%xmm1,  6 * SIZE(Y)

	movapd	 9 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 8 * SIZE(Y), %xmm0
	movapd	%xmm0,  8 * SIZE(Y)

	movapd	11 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	10 * SIZE(Y), %xmm1
	movapd	%xmm1, 10 * SIZE(Y)

	movapd	13 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	12 * SIZE(Y), %xmm0
	movapd	%xmm0, 12 * SIZE(Y)

	movapd	15 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	14 * SIZE(Y), %xmm1
	movapd	%xmm1, 14 * SIZE(Y)

#ifdef PENTIUM4
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(X)
	prefetcht0     (PREFETCHSIZE + 0) * SIZE(Y)
#endif

	addl	$16 * SIZE, X
	addl	$16 * SIZE, Y
	decl	%eax
	jg	.L21
	ALIGN_3

.L25:
	movl	M,  %eax
	testl	$8, %eax
	jle	.L26

	movapd	 1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 3 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	movapd	 5 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 4 * SIZE(Y), %xmm0
	movapd	%xmm0,  4 * SIZE(Y)

	movapd	 7 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 6 * SIZE(Y), %xmm1
	movapd	%xmm1,  6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L26:
	testl	$4, %eax
	jle	.L27

	movapd	 1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)

	movapd	 3 * SIZE(X), %xmm0
	SHUFPD_1 %xmm0, %xmm1
	mulpd	%xmm7, %xmm1
	addpd	 2 * SIZE(Y), %xmm1
	movapd	%xmm1,  2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L27:
	testl	$2, %eax
	jle	.L28

	movapd	 1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	mulpd	%xmm7, %xmm0
	addpd	 0 * SIZE(Y), %xmm0
	movapd	%xmm0,  0 * SIZE(Y)
	movapd	%xmm1, %xmm0

	addl	$2 * SIZE, X
	addl	$2 * SIZE, Y
	ALIGN_3

.L28:
	testl	$1, %eax
	jle	.L99

	unpckhpd %xmm0, %xmm0
	mulsd	%xmm7, %xmm0
	addsd	0 * SIZE(Y), %xmm0
	movsd	%xmm0, 	0 * SIZE(Y)
	ALIGN_3

.L99:
	xorl	%eax,%eax
	popl	%ebp
	popl	%ebx
	popl	%esi
	popl	%edi
	ret
	ALIGN_3

.L100:
	movl	M, %eax
	movl	Y, %ebp
	sarl	$3,   %eax
	jle	.L114
	ALIGN_3

.L110:
	movsd	0 * SIZE(X), %xmm0
	addl	INCX, X
	movhpd	0 * SIZE(X), %xmm0
	addl	INCX, X
	mulpd	%xmm7, %xmm0

	movsd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	movhpd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	addpd	%xmm6, %xmm0

	movsd	0 * SIZE(X), %xmm1
	addl	INCX, X
	movhpd	0 * SIZE(X), %xmm1
	addl	INCX, X
	mulpd	%xmm7, %xmm1

	movsd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	movhpd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	addpd	%xmm6, %xmm1

	movsd	0 * SIZE(X), %xmm2
	addl	INCX, X
	movhpd	0 * SIZE(X), %xmm2
	addl	INCX, X
	mulpd	%xmm7, %xmm2

	movsd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	movhpd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	addpd	%xmm6, %xmm2

	movsd	0 * SIZE(X), %xmm3
	addl	INCX, X
	movhpd	0 * SIZE(X), %xmm3
	addl	INCX, X
	mulpd	%xmm7, %xmm3

	movsd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	movhpd	0 * SIZE(%ebp), %xmm6
	addl	INCY, %ebp
	addpd	%xmm6, %xmm3

	movsd	%xmm0, 0 * SIZE(Y)
	addl	INCY, Y
	movhpd	%xmm0, 0 * SIZE(Y)
	addl	INCY, Y
	movsd	%xmm1, 0 * SIZE(Y)
	addl	INCY, Y
	movhpd	%xmm1, 0 * SIZE(Y)
	addl	INCY, Y
	movsd	%xmm2, 0 * SIZE(Y)
	addl	INCY, Y
	movhpd	%xmm2, 0 * SIZE(Y)
	addl	INCY, Y
	movsd	%xmm3, 0 * SIZE(Y)
	addl	INCY, Y
	movhpd	%xmm3, 0 * SIZE(Y)
	addl	INCY, Y

	decl	%eax
	jg	.L110
	ALIGN_3

.L114:
	movl	M, %eax
	andl	$7,   %eax
	jle	.L999
	ALIGN_3

.L115:
	movsd	(X), %xmm0
	addl	INCX, X
	mulsd	%xmm7, %xmm0
	addsd	(Y), %xmm0
	movsd	%xmm0, (Y)
	addl	INCY, Y
	decl	%eax
	jg	.L115
	ALIGN_3

.L999:
	xorl	%eax,%eax
	popl	%ebp
	popl	%ebx
	popl	%esi
	popl	%edi
	ret

	EPILOGUE
