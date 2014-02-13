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

#define STACK	12
#define ARGS	 0
	
#define M	 4 + STACK + ARGS(%esp)
#define X	 8 + STACK + ARGS(%esp)
#define INCX	12 + STACK + ARGS(%esp)
#define Y	16 + STACK + ARGS(%esp)
#define INCY	20 + STACK + ARGS(%esp)
	
#ifdef PENTIUM4
#define PREFETCHSIZE 88
#endif

#ifdef OPTERON
#define PREFETCHSIZE 88
#define movsd	     movlpd
#endif

	PROLOGUE

	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	movl	M,    %ebx
	movl	X,    %ecx
	movl	INCX, %esi
	movl	Y,    %edx
	movl	INCY, %edi

	testl	%ebx, %ebx	# if m == 0 goto End
	jle	.L999

	leal	(, %esi, SIZE), %esi
	leal	(, %edi, SIZE), %edi
	
	addl	%esi, %esi
	addl	%edi, %edi
	
	cmpl	$2 * SIZE, %esi	# if incx != 1
	jne	.L100
	cmpl	$2 * SIZE, %edi	# if incy != 1
	jne	.L100

	movl	%ebx, %eax	# i = m
	sarl	$2,   %eax
	jle	.L20
	ALIGN_2

.L11:
#ifdef PENTIUM4
	prefetcht1	(PREFETCHSIZE +  0) * SIZE(%edx)
#endif

#ifdef OPTERON
	prefetcht0	(PREFETCHSIZE +  0) * SIZE(%ecx)
	prefetchw	(PREFETCHSIZE +  0) * SIZE(%edx)
#endif

	movsd	 0 * SIZE(%ecx), %xmm0
	movsd	 1 * SIZE(%ecx), %xmm1
	movsd	 2 * SIZE(%ecx), %xmm2
	movsd	 3 * SIZE(%ecx), %xmm3
	movsd	 4 * SIZE(%ecx), %xmm4
	movsd	 5 * SIZE(%ecx), %xmm5
	movsd	 6 * SIZE(%ecx), %xmm6
	movsd	 7 * SIZE(%ecx), %xmm7

	movsd	%xmm0,  0 * SIZE(%edx)
	movsd	%xmm1,  1 * SIZE(%edx)
	movsd	%xmm2,  2 * SIZE(%edx)
	movsd	%xmm3,  3 * SIZE(%edx)
	movsd	%xmm4,  4 * SIZE(%edx)
	movsd	%xmm5,  5 * SIZE(%edx)
	movsd	%xmm6,  6 * SIZE(%edx)
	movsd	%xmm7,  7 * SIZE(%edx)

	addl	$8 * SIZE, %ecx
	addl	$8 * SIZE, %edx
	decl	%eax
	jg	.L11
	ALIGN_2

.L20:
	movl	%ebx, %eax	# i = m
	andl	$3,   %eax
	jle	.L99
	ALIGN_2

.L21:
	movsd	 0 * SIZE(%ecx), %xmm0
	movsd	 1 * SIZE(%ecx), %xmm1
	addl	$2 * SIZE, %ecx

	movsd	%xmm0, 0 * SIZE(%edx)
	movsd	%xmm1, 1 * SIZE(%edx)
	addl	$2 * SIZE, %edx
	decl	%eax
	jg	.L21

.L99:
	xorl	%eax,%eax
	popl	%ebx
	popl	%esi
	popl	%edi
	ret
	ALIGN_3

.L100:
	movl	%ebx, %eax
	sarl	$2,   %eax
	jle	.L120
	ALIGN_2

.L111:
	movsd	0 * SIZE(%ecx), %xmm0
	movsd	1 * SIZE(%ecx), %xmm1
	addl	%esi, %ecx

	movsd	0 * SIZE(%ecx), %xmm2
	movsd	1 * SIZE(%ecx), %xmm3
	addl	%esi, %ecx

	movsd	0 * SIZE(%ecx), %xmm4
	movsd	1 * SIZE(%ecx), %xmm5
	addl	%esi, %ecx

	movsd	0 * SIZE(%ecx), %xmm6
	movsd	1 * SIZE(%ecx), %xmm7
	addl	%esi, %ecx

	movsd	%xmm0, 0 * SIZE(%edx)
	movsd	%xmm1, 1 * SIZE(%edx)
	addl	%edi, %edx

	movsd	%xmm2, 0 * SIZE(%edx)
	movsd	%xmm3, 1 * SIZE(%edx)
	addl	%edi, %edx

	movsd	%xmm4, 0 * SIZE(%edx)
	movsd	%xmm5, 1 * SIZE(%edx)
	addl	%edi, %edx

	movsd	%xmm6, 0 * SIZE(%edx)
	movsd	%xmm7, 1 * SIZE(%edx)
	addl	%edi, %edx

	decl	%eax
	jg	.L111

.L120:
	movl	%ebx, %eax
	andl	$3,   %eax
	jle	.L999
	ALIGN_2

.L121:
	movsd	0 * SIZE(%ecx), %xmm0
	movsd	1 * SIZE(%ecx), %xmm1
	addl	%esi, %ecx
	movsd	%xmm0, 0 * SIZE(%edx)
	movsd	%xmm1, 1 * SIZE(%edx)
	addl	%edi, %edx

	decl	%eax
	jg	.L121

.L999:
	xorl	%eax,%eax
	popl	%ebx
	popl	%esi
	popl	%edi
	ret

	EPILOGUE
