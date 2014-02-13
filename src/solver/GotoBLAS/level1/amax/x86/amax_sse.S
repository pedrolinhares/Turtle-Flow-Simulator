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
#define STACK_X		 8 + STACK + ARGS(%esp)
#define STACK_INCX	12 + STACK + ARGS(%esp)

#define RET	%eax
#define	M	%ebx
#define X	%ecx
#define INCX	%edx
#define I	%esi
#define MM	%ebp
#define XX	%edi
#define TEMP	%ebx
	
#ifdef MIN
#define maxps	minps
#define maxss	minss
#endif

#ifndef HAVE_SSE2
#define pxor	xorps
#define movsd	movlps
#endif

	PROLOGUE

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	movl	STACK_M, M
	movl	STACK_X, X
	movl	STACK_INCX, INCX

#ifdef F_INTERFACE
	movl	(M), M
	movl	(INCX), INCX
#endif

	pxor	%xmm0, %xmm0
#ifdef ABS
	pxor	%xmm7, %xmm7
#endif
	xor	RET, RET		/* Return Value(Int)   */
	testl	M, M
	jle	.L999
	leal	(, INCX, SIZE), INCX
	testl	INCX, INCX
	jle	.L999

	movl	M, MM
	movl	X, XX

#ifdef ABS
#ifndef HAVE_SSE2
	subl	$8, %esp
	movl	$0x7fffffff, (%esp)
	movss	(%esp), %xmm7
	shufps	$0, %xmm7, %xmm7
	addl	$8, %esp
#else
	cmpeqps	%xmm7, %xmm7
	psrld	$1, %xmm7		/* Generate ABS */
#endif
#endif

	movss	(XX), %xmm0
	addl	INCX, XX
	decl	MM
	shufps	$0, %xmm0, %xmm0
#ifdef ABS
	andps	%xmm7, %xmm0
#endif
	movaps	%xmm0, %xmm1
	movaps	%xmm0, %xmm2
	movaps	%xmm0, %xmm3		/* Generating "seed value" */
	cmpl	$SIZE, INCX
	jne	.L80			/* Incx != 1 goto L80 */

/* Analigned Check */
	testl	$3, XX			/* 00000011 */
	jne	.L30			/* Purely Unaligned Mode */

	cmpl	$8, MM
	jle	.L30			/* if M <= 8 goto Unaligned mode */

	testl	$4, XX			/* bit test 000100 */
	je	.L05

	movss	0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	  %xmm4, %xmm0
	decl	MM
	addl	$SIZE, XX
	ALIGN_3

.L05:
	testl	$8, XX
	je	.L06

	movsd	0 * SIZE(XX), %xmm4
	unpcklps  %xmm4, %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	  %xmm4, %xmm1
	subl	$2, MM
	addl	$2 * SIZE, XX
	ALIGN_3

.L06:
	movl	MM,  I
	sarl	$4, I
	jle	.L15
	ALIGN_4
	
#define PREFETCHSIZE 256

.L11:
	prefetcht0	PREFETCHSIZE * SIZE(XX)

	movaps	 0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movaps	 4 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm1

	movaps	 8 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm2

	movaps	12 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm3

	addl	$16 * SIZE, XX
	decl	I
	jg	.L11
	ALIGN_4

.L15:
	andl	$15,  MM
	jle	.L20

	testl	$8, MM
	je	.L16

	movaps	0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movaps	4 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm1
	addl	$8 * SIZE, XX
	ALIGN_3

.L16:
	testl	$4, MM
	je	.L17

	movaps	0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm2
	addl	$4 * SIZE, XX
	ALIGN_3	

.L17:
	testl	$2, MM
	je	.L18

	movsd	0 * SIZE(XX), %xmm4
	unpcklps %xmm4, %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm3
	addl	$2 * SIZE, XX
	
.L18:
	testl	$1, MM
	je	.L20

	movss	0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0
	ALIGN_3

.L20:
	maxps	%xmm1, %xmm0
	maxps	%xmm3, %xmm2
	maxps	%xmm2, %xmm0
	movaps	%xmm0, %xmm1
	movhlps %xmm0, %xmm0
	maxps	%xmm1, %xmm0
	movaps	%xmm0, %xmm1
	shufps	$1, %xmm0, %xmm0
	maxss	%xmm1, %xmm0
	shufps	$0, %xmm0, %xmm0
	jmp	.L999
	ALIGN_4

/* Unaligned Mode */
.L30:
	movl	MM,  I
	sarl	$4, I
	jle	.L35
	ALIGN_4
	
.L31:
	prefetcht0	PREFETCHSIZE * SIZE(XX)

	movsd	 0 * SIZE(XX), %xmm4
	movhps	 2 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movsd	 4 * SIZE(XX), %xmm4
	movhps	 6 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm1

	movsd	 8 * SIZE(XX), %xmm4
	movhps	10 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm2

	movsd	12 * SIZE(XX), %xmm4
	movhps	14 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm3

	addl	$16 * SIZE, XX
	decl	I
	jg	.L31
	ALIGN_4

.L35:
	andl	$15,  MM
	jle	.L40

	testl	$8, MM
	je	.L36

	movsd	0 * SIZE(XX), %xmm4
	movhps	2 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm0

	movsd	4 * SIZE(XX), %xmm4
	movhps	6 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm1

	addl	$8 * SIZE, XX
	ALIGN_3

.L36:
	testl	$4, MM
	je	.L37

	movsd	0 * SIZE(XX), %xmm4
	movhps	2 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm2
	addl	$4 * SIZE, XX
	ALIGN_3	

.L37:
	testl	$2, MM
	je	.L38

	movsd	0 * SIZE(XX), %xmm4
	unpcklps %xmm4, %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxps	%xmm4, %xmm3
	addl	$2 * SIZE, XX
	
.L38:
	testl	$1, MM
	je	.L40

	movss	0 * SIZE(XX), %xmm4
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0
	jmp	.L40
	ALIGN_4

.L40:
	maxps	%xmm1, %xmm0
	maxps	%xmm3, %xmm2
	maxps	%xmm2, %xmm0
	movaps	%xmm0, %xmm1
	movhlps %xmm0, %xmm0
	maxps	%xmm1, %xmm0
	movaps	%xmm0, %xmm1
	shufps	$1, %xmm0, %xmm0
	maxss	%xmm1, %xmm0
	jmp	.L999
	ALIGN_4

.L80:
	movl	MM,  I
	sarl	$3, I
	jle	.L85
	ALIGN_4
	
.L81:
	prefetcht0	PREFETCHSIZE * SIZE(XX)

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm1

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm2

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm3

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm1

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm2

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm3

	decl	I
	jg	.L81
	ALIGN_4

.L85:
	andl	$7,  MM
	jle	.L90

	testl	$4, MM
	je	.L86

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm1

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm2

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm3
	ALIGN_3	

.L86:
	testl	$2, MM
	je	.L87

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm0

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm1
	ALIGN_3
	
.L87:
	testl	$1, MM
	je	.L90

	movss	0 * SIZE(XX), %xmm4
	addl	INCX, XX
#ifdef ABS
	andps	%xmm7, %xmm4
#endif
	maxss	%xmm4, %xmm2
	ALIGN_4

.L90:
	maxss	%xmm1, %xmm0
	maxss	%xmm3, %xmm2
	maxss	%xmm2, %xmm0
	ALIGN_4

.L999:
	subl	$8, %esp
	movss	%xmm0, (%esp)
	flds	(%esp)
	addl	$8, %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret

	EPILOGUE
