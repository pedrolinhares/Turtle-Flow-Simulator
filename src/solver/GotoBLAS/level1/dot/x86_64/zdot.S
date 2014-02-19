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

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
#define RESULT	ARG1	/* rdi */
#define N	ARG2	/* rsi */
#define X	ARG3	/* rdx */
#define INCX	ARG4	/* rcx */
#define Y	ARG5	/* r8  */
#define INCY	ARG6	/* r9  */
#else
#define N	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#define INCY	ARG5	/* r8  */
#endif

	PROLOGUE
	PROFCODE
	
#ifdef F_INTERFACE
#ifndef USE64BITINT
	movslq	(N), N			# N
	movslq	(INCX),INCX		# INCX
	movslq	(INCY),INCY		# INCY
#else
	movq	(N), N			# N
	movq	(INCX),INCX		# INCX
	movq	(INCY),INCY		# INCY
#endif
#endif

	testq	N, N
	jle	.L88

	salq	$ZBASE_SHIFT, INCX
	salq	$ZBASE_SHIFT, INCY

	fldz
	fldz
	fldz
	fldz

	cmpq	$2 * SIZE, INCX
	jne	.L14
	cmpq	$2 * SIZE, INCY
	jne	.L14

	movq	N,  %rax
	sarq	$1, %rax
	jle	.L15
	ALIGN_3

.L16:
	FLD	 0 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 1 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)
	FLD	 2 * SIZE(X)

	FLD	 2 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 3 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 3 * SIZE(X)

	FLD	 2 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 3 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	decq	%rax
	jg	.L16
	ALIGN_3

.L15:
	movq	N, %rax
	andq	$1,   %rax
	jle	.L27
	ALIGN_3

.L22:
	FLD	 0 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 1 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)
	jmp	.L27
	ALIGN_3

.L14:
#ifdef F_INTERFACE
	testq	INCX, INCX		# if (incx < 0)
	jge	.L28

	movq	N, %rax
	decq	%rax
	imulq	INCX, %rax
	subq	%rax, X
	ALIGN_3

.L28:
	testq	INCY, INCY		# if (incy < 0)
	jge	.L29

	movq	N, %rax
	decq	%rax
	imulq	INCY, %rax
	subq	%rax, Y
	ALIGN_3

.L29:
#endif

	movq	N, %rax
	sarq	$1,   %rax
	jle	.L30
	ALIGN_3


.L31:
	FLD	 0 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 1 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)
	addq	INCX, X

	FLD	 0 * SIZE(X)
	addq	INCY, Y

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 1 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)
	addq	INCX, X
	addq	INCY, Y

	decq	%rax
	jg	.L31
	ALIGN_3

.L30:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L27
	ALIGN_3

.L37:
	FLD	 0 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(2)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(2)
	FLD	 1 * SIZE(X)

	FLD	 0 * SIZE(Y)
	fmul	%st(1)
	faddp	%st, %st(4)

	FLD	 1 * SIZE(Y)
	fmulp	 %st, %st(1)
	faddp	%st, %st(4)
	ALIGN_3

.L27:
#if (defined(F_INTERFACE) && defined(F_INTERFACE_F2C))
	movq	RESULT, %rax
#endif

#ifndef CONJ
	fsubp	%st, %st(3)
	faddp	%st, %st(1)
#else
	faddp	%st, %st(3)
	fsubp	%st, %st(1)
#endif

#if   (defined(F_INTERFACE) && defined(F_INTERFACE_F2C))
	FST	1 * SIZE(%rax)
	FST	0 * SIZE(%rax)
#elif defined(F_INTERFACE) && defined(F_INTERFACE_GFORT) && !defined(DOUBLE)
	subq	$2 * SIZE, %rsp
	FST	1 * SIZE(%rsp)
	FST	0 * SIZE(%rsp)
	movq	0 * SIZE(%rsp), %rax
	movq	1 * SIZE(%rsp), %rdx
	addq	$2 * SIZE, %rsp
#else
	fxch	%st(1)
#endif
	ret
	ALIGN_3

.L88:
#if (defined(F_INTERFACE) && defined(F_INTERFACE_F2C))
	movq	RESULT, %rax
#endif

	fldz
	fldz

#if  (defined(F_INTERFACE) && defined(F_INTERFACE_F2C))
	FST	1 * SIZE(%rax)
	FST	0 * SIZE(%rax)
#elif defined(F_INTERFACE) && defined(F_INTERFACE_GFORT) && !defined(DOUBLE)
	xor	%rax, %rax
	xor	%edx, %edx
#endif

	ret
	EPILOGUE
