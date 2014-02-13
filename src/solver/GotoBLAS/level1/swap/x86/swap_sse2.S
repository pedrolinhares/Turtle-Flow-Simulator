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
#define ARGS     0
	
#define STACK_M	 	 4 + STACK + ARGS(%esp)
#define STACK_X		24 + STACK + ARGS(%esp)
#define STACK_INCX	28 + STACK + ARGS(%esp)
#define STACK_Y		32 + STACK + ARGS(%esp)
#define STACK_INCY	36 + STACK + ARGS(%esp)

#define M	%edx
#define X	%esi
#define Y	%edi
#define INCX	%ebx
#define INCY	%ecx
	
	
	PROLOGUE
	PROFCODE

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	movl	STACK_M,    M
	movl	STACK_X,    X
	movl	STACK_Y,    Y
	movl	STACK_INCX, INCX
	movl	STACK_INCY, INCY

	leal	(, INCX, SIZE), INCX
	leal	(, INCY, SIZE), INCY

	cmpl	$SIZE, INCX
	jne	.L40
	cmpl	$SIZE, INCY
	jne	.L40

	testl	$SIZE, Y
	je	.L10

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4

	movsd	%xmm4, 0 * SIZE(X)
	movsd	%xmm0, 0 * SIZE(Y)

	addl	$1 * SIZE, X
	addl	$1 * SIZE, Y
	decl	M
	jle	.L19
	ALIGN_4

.L10:
	testl	$SIZE, X
	jne	.L20

	movl	M,  %eax
	sarl	$3, %eax
	jle	.L14

	movapd	 0 * SIZE(X), %xmm0
	movapd	 2 * SIZE(X), %xmm1
	movapd	 4 * SIZE(X), %xmm2
	movapd	 6 * SIZE(X), %xmm3

	movapd	 0 * SIZE(Y), %xmm4
	movapd	 2 * SIZE(Y), %xmm5
	movapd	 4 * SIZE(Y), %xmm6
	movapd	 6 * SIZE(Y), %xmm7

	decl	%eax
	jle .L12
	ALIGN_3

.L11:
	prefetcht0	40 * SIZE(Y)

	movapd	%xmm4, 	 0 * SIZE(X)
	movapd	%xmm5, 	 2 * SIZE(X)
	movapd	%xmm6,	 4 * SIZE(X)
	movapd	%xmm7,	 6 * SIZE(X)

	movapd	  8 * SIZE(Y), %xmm4
	movapd	 10 * SIZE(Y), %xmm5
	movapd	 12 * SIZE(Y), %xmm6
	movapd	 14 * SIZE(Y), %xmm7

	movapd	%xmm0, 	 0 * SIZE(Y)
	movapd	%xmm1, 	 2 * SIZE(Y)
	movapd	%xmm2, 	 4 * SIZE(Y)
	movapd	%xmm3, 	 6 * SIZE(Y)

	movapd	  8 * SIZE(X), %xmm0
	movapd	 10 * SIZE(X), %xmm1
	movapd	 12 * SIZE(X), %xmm2
	movapd	 14 * SIZE(X), %xmm3

	addl	$8 * SIZE, Y
	addl	$8 * SIZE, X
	decl	%eax
	jg	.L11
	ALIGN_3

.L12:
	movapd	%xmm4, 	 0 * SIZE(X)
	movapd	%xmm5, 	 2 * SIZE(X)
	movapd	%xmm6,	 4 * SIZE(X)
	movapd	%xmm7,	 6 * SIZE(X)

	movapd	%xmm0, 	 0 * SIZE(Y)
	movapd	%xmm1, 	 2 * SIZE(Y)
	movapd	%xmm2, 	 4 * SIZE(Y)
	movapd	%xmm3, 	 6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L14:
	movl	M,  %eax
	andl	$4, %eax
	jle	.L15
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	2 * SIZE(X), %xmm1
	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5

	movapd	%xmm4, 	0 * SIZE(X)
	movapd	%xmm5, 	2 * SIZE(X)
	movapd	%xmm0, 	0 * SIZE(Y)
	movapd	%xmm1, 	2 * SIZE(Y)

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L15:
	movl	M,  %eax
	andl	$2, %eax
	jle	.L16
	ALIGN_3

	movapd	0 * SIZE(X), %xmm0
	movapd	0 * SIZE(Y), %xmm4

	movapd	%xmm4, 	0 * SIZE(X)
	movapd	%xmm0, 	0 * SIZE(Y)

	addl	$2 * SIZE, X
	addl	$2 * SIZE, Y
	ALIGN_3

.L16:
	movl	M,  %eax
	andl	$1, %eax
	jle	.L19
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4

	movsd	%xmm4, 	0 * SIZE(X)
	movsd	%xmm0, 	0 * SIZE(Y)
	ALIGN_3

.L19:
	xorl	%eax,%eax
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	ALIGN_3

.L20:
	movapd	-1 * SIZE(X), %xmm0

	movl	M,  %eax
	sarl	$3, %eax
	jle	.L24

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2
	movapd	5 * SIZE(X), %xmm3

	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5
	movapd	4 * SIZE(Y), %xmm6
	movapd	6 * SIZE(Y), %xmm7

	movlpd	%xmm4, 0 * SIZE(X)

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	SHUFPD_1 %xmm5, %xmm4
	SHUFPD_1 %xmm6, %xmm5

	decl	%eax
	jle .L22
	ALIGN_4

.L21:
	prefetcht0	40 * SIZE(Y)

	movapd	%xmm4, 1 * SIZE(X)
	movapd	%xmm5, 3 * SIZE(X)
	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)

	movapd	7 * SIZE(X), %xmm0

	SHUFPD_1 %xmm7, %xmm6
	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm0, %xmm3

	movapd	%xmm6, 5 * SIZE(X)
	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	movapd	 9 * SIZE(X), %xmm1
	movapd	11 * SIZE(X), %xmm2
	movapd	13 * SIZE(X), %xmm3

	movapd	 8 * SIZE(Y), %xmm4
	movapd	10 * SIZE(Y), %xmm5
	movapd	12 * SIZE(Y), %xmm6

	SHUFPD_1 %xmm4, %xmm7
	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movapd	%xmm7, 7 * SIZE(X)
	SHUFPD_1 %xmm5, %xmm4
	SHUFPD_1 %xmm6, %xmm5
	movapd	14 * SIZE(Y), %xmm7

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y

	decl	%eax
	jg	.L21
	ALIGN_3

.L22:
	movapd	%xmm4, 1 * SIZE(X)
	movapd	%xmm5, 3 * SIZE(X)
	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)

	movapd	7 * SIZE(X), %xmm0

	SHUFPD_1 %xmm3, %xmm2
	SHUFPD_1 %xmm0, %xmm3
	SHUFPD_1 %xmm7, %xmm6

	movapd	%xmm6, 5 * SIZE(X)
	movhpd	%xmm7, 7 * SIZE(X)

	movapd	%xmm2, 4 * SIZE(Y)
	movapd	%xmm3, 6 * SIZE(Y)

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L24:
	movl	M,  %eax
	andl	$4, %eax
	jle	.L25
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	movapd	3 * SIZE(X), %xmm2
	movapd	0 * SIZE(Y), %xmm4
	movapd	2 * SIZE(Y), %xmm5

	SHUFPD_1 %xmm1, %xmm0
	SHUFPD_1 %xmm2, %xmm1

	movlpd	%xmm4, 0 * SIZE(X)
	SHUFPD_1 %xmm5, %xmm4
	movapd	%xmm4, 1 * SIZE(X)
	movhpd	%xmm5, 3 * SIZE(X)

	movapd	%xmm0, 0 * SIZE(Y)
	movapd	%xmm1, 2 * SIZE(Y)
	movapd	%xmm2, %xmm0

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L25:
	movl	M,  %eax
	andl	$2, %eax
	jle	.L26
	ALIGN_3

	movapd	1 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0

	movapd	0 * SIZE(Y), %xmm4

	movlpd	%xmm4, 0 * SIZE(X)
	movhpd	%xmm4, 1 * SIZE(X)
	movapd	%xmm0, 0 * SIZE(Y)

	addl	$2 * SIZE, X
	addl	$2 * SIZE, Y
	ALIGN_3

.L26:
	movl	M,  %eax
	andl	$1, %eax
	jle	.L29
	ALIGN_3

	movsd	0 * SIZE(X), %xmm0
	movsd	0 * SIZE(Y), %xmm4

	movsd	%xmm4, 	0 * SIZE(X)
	movsd	%xmm0, 	0 * SIZE(Y)
	ALIGN_3

.L29:
	xorl	%eax,%eax
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	ALIGN_3


.L40:
	movl	M,  %eax
	sarl	$2, %eax
	jle	.L45
	ALIGN_3

.L41:
	movsd	(X), %xmm0
	addl	INCX, X
	movsd	(Y), %xmm4
	addl	INCY, Y
	movsd	(X), %xmm1
	addl	INCX, X
	movsd	(Y), %xmm5
	addl	INCY, Y
	movsd	(X), %xmm2
	addl	INCX, X
	movsd	(Y), %xmm6
	addl	INCY, Y
	movsd	(X), %xmm3
	movsd	(Y), %xmm7

	movsd	%xmm7, (X)
	subl	INCX, X
	movsd	%xmm3, (Y)
	subl	INCY, Y
	movsd	%xmm6, (X)
	subl	INCX, X
	movsd	%xmm2, (Y)
	subl	INCY, Y
	movsd	%xmm5, (X)
	subl	INCX, X
	movsd	%xmm1, (Y)
	subl	INCY, Y
	movsd	%xmm4, (X)
	leal	(X, INCX, 4), X
	movsd	%xmm0, (Y)
	leal	(Y, INCY, 4), Y

	decl	%eax
	jg	.L41
	ALIGN_3

.L45:
	movl	M,  %eax
	andl	$3, %eax
	jle	.L47
	ALIGN_3

.L46:
	movsd	(X), %xmm0
	movsd	(Y), %xmm4

	movsd	%xmm4, (X)
	movsd	%xmm0, (Y)

	addl	INCX, X
	addl	INCY, Y
	decl	%eax
	jg	.L46
	ALIGN_3

.L47:
	xorl	%eax, %eax
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret

	EPILOGUE
