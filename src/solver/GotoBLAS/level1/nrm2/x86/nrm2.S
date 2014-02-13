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
	
#define STACK	 8
#define ARGS	 0
	
#define M	 4 + STACK + ARGS(%esp)
#define X	 8 + STACK + ARGS(%esp)
#define INCX	12 + STACK + ARGS(%esp)

	PROLOGUE

	pushl	%esi
	pushl	%ebx

	PROFCODE

#ifdef F_INTERFACE_GFORT
	EMMS
#endif

	movl	M,    %ebx
	movl	INCX, %esi
	movl	X,    %ecx

#ifdef F_INTERFACE
	movl	(%ebx), %ebx
	movl	(%esi), %esi
#endif

	fldz
	testl	%ebx, %ebx
	jle	.L999
	testl	%esi, %esi
	jle	.L999

	sall	$BASE_SHIFT, %esi

	fldz
	fldz
	fldz
	cmpl	$SIZE, %esi
	jne	.L40

	movl	%ebx, %edx
	sarl	$3,   %edx
	jle	.L20
	ALIGN_4
	
.L10:
#if defined(HAVE_SSE) || defined(HAVE_SSE2)
        prefetchnta   80 * SIZE(%ecx)
#endif

	FLD	0 * SIZE(%ecx)
	fmul	%st, %st
	FLD	1 * SIZE(%ecx)
	fmul	%st, %st
	FLD	2 * SIZE(%ecx)
	fmul	%st, %st
	FLD	3 * SIZE(%ecx)
	fmul	%st, %st

	faddp	%st, %st(7)
	faddp	%st, %st(5)
	faddp	%st, %st(3)
	faddp	%st, %st(1)

	FLD	4 * SIZE(%ecx)
	fmul	%st, %st
	FLD	5 * SIZE(%ecx)
	fmul	%st, %st
	FLD	6 * SIZE(%ecx)
	fmul	%st, %st
	FLD	7 * SIZE(%ecx)
	fmul	%st, %st

	addl	$8 * SIZE, %ecx

	faddp	%st, %st(7)
	faddp	%st, %st(5)
	faddp	%st, %st(3)
	faddp	%st, %st(1)

	decl	%edx
	jg	.L10
	ALIGN_4

.L20:
	andl	$7,  %ebx
	jle	.L998
	ALIGN_4


.L21:
	FLD	(%ecx)
	fmul	%st, %st
	faddp	%st,%st(1)
	addl	$1 * SIZE, %ecx
	decl	%ebx
	jg	.L21
	jmp	.L998
	ALIGN_4

.L40:
	movl	%ebx, %edx
	sarl	$3,   %edx
	jle	.L60
	ALIGN_4
	
.L50:
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st

	faddp	%st, %st(7)
	faddp	%st, %st(5)
	faddp	%st, %st(3)
	faddp	%st, %st(1)

	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st

	faddp	%st, %st(7)
	faddp	%st, %st(5)
	faddp	%st, %st(3)
	faddp	%st, %st(1)

	decl	%edx
	jg	.L50
	ALIGN_4

.L60:
	andl	$7,  %ebx
	jle	.L998
	ALIGN_4


.L61:
	FLD	(%ecx)
	addl	%esi, %ecx
	fmul	%st, %st
	faddp	%st,%st(1)
	decl	%ebx
	jg	.L61
	ALIGN_4

.L998:
	faddp	%st,%st(2)
	faddp	%st,%st(1)
	faddp	%st,%st(1)
	ALIGN_4

.L999:
	fsqrt
	popl	%ebx
	popl	%esi
	ret

	EPILOGUE
