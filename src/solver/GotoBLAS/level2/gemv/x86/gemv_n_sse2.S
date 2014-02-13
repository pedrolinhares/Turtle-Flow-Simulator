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

#ifdef PARAMTEST
#define P	  60(%esp)
#endif

#ifdef PENTIUM4
#ifndef PARAMTEST
#define P 24
#endif
#define PREFETCHSIZE 24
#endif

#ifdef CORE2
#define P 24
#define PREFETCHSIZE 24
#endif

#ifdef PENRYN
#define P 24
#define PREFETCHSIZE 24
#endif

#if defined(OPTERON) || defined(BARCELONA)
#ifndef PARAMTEST
#define P 32
#endif
#define movsd	movlpd
#define PREFETCHSIZE 16
#endif

#ifndef P
#define P 32
#endif

#ifndef PREFETCHSIZE
#define PREFETCHSIZE 32
#endif

#define STACK	16
	
#define OLD_M		 4 + STACK(%esi)
#define OLD_N		 8 + STACK(%esi)
#define OLD_ALPHA	16 + STACK(%esi)
#define OLD_A		24 + STACK(%esi)
#define OLD_LDA		28 + STACK(%esi)
#define OLD_X		32 + STACK(%esi)
#define OLD_INCX	36 + STACK(%esi)
#define OLD_Y		40 + STACK(%esi)
#define OLD_INCY	44 + STACK(%esi)
#define OLD_BUFFER	48 + STACK(%esi)
#define OLD_P		52 + STACK(%esi)
	
#define ALPHA	 0(%esp)
#define M	16(%esp)
#define N	20(%esp)
#define A	24(%esp)
#define X	32(%esp)
#define INCX	36(%esp)
#define Y	40(%esp)
#define INCY	44(%esp)
#define IS	48(%esp)
#define PLDA_M	52(%esp)
#define BUFFER  56(%esp)

#define OLD_STACK 64(%esp)

#if defined(OPTERON) || defined(BARCELONA)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(%edx), %xmm1; \
	prefetcht1	PREFETCHSIZE * SIZE(%edx); \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movsd	  4 * SIZE(%edx), %xmm1; \
	movhpd	  5 * SIZE(%edx), %xmm1; \
	movsd	  6 * SIZE(%edx), %xmm2; \
	movhpd	  7 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm6; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm7; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0
#endif

#if defined(PENTIUM4) || defined(CORE2) || defined(PENRYN)
#define KERNELMACRO(address) \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movsd	  4 * SIZE(%edx), %xmm1; \
	movhpd	  5 * SIZE(%edx), %xmm1; \
	movsd	  6 * SIZE(%edx), %xmm2; \
	movhpd	  7 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm6; \
	mulpd	%xmm0, %xmm2; \
	prefetchnta	PREFETCHSIZE * SIZE(%edx); \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0; \
	addpd	%xmm2, %xmm7	;  \

#endif

#define KERNELMACRO7(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movsd	  4 * SIZE(%edx), %xmm1; \
	movhpd	  5 * SIZE(%edx), %xmm1; \
	movsd	  6 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm6; \
	mulsd	%xmm0, %xmm2; \
	addsd	%xmm2, %xmm7; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO6(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movsd	  4 * SIZE(%edx), %xmm1; \
	movhpd	  5 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm6; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO5(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movsd	  4 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulsd	%xmm0, %xmm1; \
	addsd	%xmm1, %xmm6; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO4(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	movhpd	  3 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulpd	%xmm0, %xmm2; \
	addpd	%xmm2, %xmm5; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO3(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	movsd	  2 * SIZE(%edx), %xmm2; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	mulsd	%xmm0, %xmm2; \
	addsd	%xmm2, %xmm5; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO2(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	movhpd	  1 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulpd	%xmm0, %xmm1; \
	addpd	%xmm1, %xmm4; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

#define KERNELMACRO1(address) \
	prefetcht2	PREFETCHSIZE * SIZE(%edx); \
	movsd	  0 * SIZE(%edx), %xmm1; \
	addl	%ebp, %edx; \
	mulsd	%xmm0, %xmm1; \
	addsd	%xmm1, %xmm4; \
	movapd	  2 * SIZE + address * SIZE(%ebx), %xmm0;

	PROLOGUE

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

	movl	%esp, %esi	# save old stack

	subl	$128, %esp
	andl	$-128, %esp	# align stack

	movl	OLD_M,   %ebx
	movl	OLD_N,   %edi
	movsd	OLD_ALPHA,  %xmm3
	movl	OLD_A,   %edx

	movl	OLD_BUFFER,   %eax
	movl	%eax, BUFFER

#ifdef PARAMTEST
	movl	OLD_P, %eax
	movl	%eax, P
#endif

	unpcklpd %xmm3, %xmm3
	movapd	 %xmm3, ALPHA

	movl	%ebx, M
	movl	%edi, N
	movl	%edx, A

	movl	OLD_LDA,  %ebp
	movl	OLD_X,   %eax
	movl	%eax, X

	movl	OLD_INCX,   %eax
	movl	%eax, INCX
	movl	OLD_Y,   %eax
	movl	%eax, Y
	movl	OLD_INCY,   %eax
	leal	(,%eax, SIZE), %eax
	movl	%eax, INCY

	movl	%esi, OLD_STACK

	movl	%ebp, %eax		# eax = lda
#ifndef PARAMTEST
	imull	$P,   %eax
#else
	imull	 P,   %eax
#endif
	subl	%ebx, %eax		# eax -= m
	sall	$3,   %eax
	movl	%eax, PLDA_M
	sall	$3,  %ebp

	xorl	%ecx, %ecx		# is = 0

	testl	%edi, %edi		# if n <= 0 goto END
	jle	.L999
	testl	%ebx, %ebx		# if n <= 0 goto END
	jle	.L999

.L01:
#ifndef PARAMTEST
	movl	$P,   %ebx
#else
	movl	 P,   %ebx
#endif
	subl	%ecx, %edi	# min_n = n - is
	cmpl	%ebx, %edi	# if (min_n > P)
	cmovg	%ebx, %edi	# min_n = P

	movl	BUFFER, %edx

#ifndef PARAMTEST
	addl	$P, %ecx	# is += P
#else
	addl	 P, %ecx	# is += P
#endif
	movl	%ecx,IS

	movl	X, %ebx

	movl	INCX, %ecx
	cmpl	$1, %ecx
	jne	.L15

	movl	%edi, %eax	# min_n
	sarl	$3, %eax
	jle	.L12

.L11:
	movsd	 0 * SIZE(%ebx), %xmm0
	movsd	 1 * SIZE(%ebx), %xmm1
	movsd	 2 * SIZE(%ebx), %xmm2
	movsd	 3 * SIZE(%ebx), %xmm3
	movsd	 4 * SIZE(%ebx), %xmm4
	movsd	 5 * SIZE(%ebx), %xmm5
	movsd	 6 * SIZE(%ebx), %xmm6
	movsd	 7 * SIZE(%ebx), %xmm7

	addl	$ 8 * SIZE, %ebx
	addl	$16 * SIZE, %edx

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1
	unpcklpd %xmm2, %xmm2
	unpcklpd %xmm3, %xmm3
	unpcklpd %xmm4, %xmm4
	unpcklpd %xmm5, %xmm5
	unpcklpd %xmm6, %xmm6
	unpcklpd %xmm7, %xmm7

	movapd	%xmm0, -16 * SIZE(%edx)
	movapd	%xmm1, -14 * SIZE(%edx)
	movapd	%xmm2, -12 * SIZE(%edx)
	movapd	%xmm3, -10 * SIZE(%edx)
	movapd	%xmm4,  -8 * SIZE(%edx)
	movapd	%xmm5,  -6 * SIZE(%edx)
	movapd	%xmm6,  -4 * SIZE(%edx)
	movapd	%xmm7,  -2 * SIZE(%edx)

	decl	%eax
	jg	.L11

.L12:
	movl	%edi, %eax	# min_n
	andl	$7, %eax
	jle	.L20

.L13:
	movsd	0 * SIZE(%ebx), %xmm0
	unpcklpd %xmm0, %xmm0
	movapd	%xmm0, 0 * SIZE(%edx)
	addl	$2 * SIZE,%edx
	addl	$1 * SIZE, %ebx	# coffset ++
	decl	%eax
	jg	.L13
	jmp	.L20

.L15:
	sall	$3,%ecx
	movl	%edi, %eax	# min_n
	sarl	$3, %eax
	jle	.L17

.L16:
	movsd	0 * SIZE(%ebx), %xmm0
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm1
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm2
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm3
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm4
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm5
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm6
	addl	%ecx, %ebx	# coffset += incX
	movsd	0 * SIZE(%ebx), %xmm7
	addl	%ecx, %ebx	# coffset += incX

	unpcklpd %xmm0, %xmm0
	unpcklpd %xmm1, %xmm1
	unpcklpd %xmm2, %xmm2
	unpcklpd %xmm3, %xmm3
	unpcklpd %xmm4, %xmm4
	unpcklpd %xmm5, %xmm5
	unpcklpd %xmm6, %xmm6
	unpcklpd %xmm7, %xmm7

	movapd	%xmm0,  0 * SIZE(%edx)
	movapd	%xmm1,  2 * SIZE(%edx)
	movapd	%xmm2,  4 * SIZE(%edx)
	movapd	%xmm3,  6 * SIZE(%edx)
	movapd	%xmm4,  8 * SIZE(%edx)
	movapd	%xmm5, 10 * SIZE(%edx)
	movapd	%xmm6, 12 * SIZE(%edx)
	movapd	%xmm7, 14 * SIZE(%edx)

	addl	$16 * SIZE, %edx
	decl	%eax
	jg	.L16

.L17:
	movl	%edi, %eax	# min_n
	andl	$7, %eax
	jle	.L20

.L18:
	movsd	0 * SIZE(%ebx), %xmm0
	addl	%ecx, %ebx	# coffset += incX
	unpcklpd %xmm0, %xmm0
	movapd	%xmm0, 0 * SIZE(%edx)
	addl	$2 * SIZE,%edx
	decl	%eax
	jg	.L18

/* Main Routine */

.L20:
	movl	%ebx, X

	movl	Y, %ecx		# coffset = Y
	movapd	ALPHA, %xmm3

	movl	M,  %esi
	sarl	$3, %esi
	jle	.L100

.L21:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$8 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

#if 0
	prefetcht2  8 * SIZE(%ecx)
#endif

	movl	%edi, %eax	# i = min_n
	sarl	$2, %eax
	jle	.L26

.L24:
	KERNELMACRO( 0)
	KERNELMACRO( 2)
	KERNELMACRO( 4)
	KERNELMACRO( 6)
	addl	$8 * SIZE, %ebx
	decl	%eax
	jg	.L24

.L26:
	movl	%edi, %eax	# i = min_n
	andl	$3, %eax
	jle	.L28

.L27:
	KERNELMACRO( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L27

.L28:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulpd	%xmm3, %xmm5
	movl	%ecx, %edx
	mulpd	%xmm3, %xmm6
	addl	%eax, %edx
	mulpd	%xmm3, %xmm7
	cmpl	$SIZE, %eax
	jne	.L29

	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm1
	movhpd	  3 * SIZE(%ecx), %xmm1
	addpd	%xmm1, %xmm5

	movsd	  4 * SIZE(%ecx), %xmm2
	movhpd	  5 * SIZE(%ecx), %xmm2
	addpd	%xmm2, %xmm6

	movsd	  6 * SIZE(%ecx), %xmm0
	movhpd	  7 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm7

	movsd	%xmm4, 0 * SIZE(%ecx)
	movhpd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	movhpd	%xmm5, 3 * SIZE(%ecx)

	movsd	%xmm6, 4 * SIZE(%ecx)
	movhpd	%xmm6, 5 * SIZE(%ecx)

	movsd	%xmm7, 6 * SIZE(%ecx)
	movhpd	%xmm7, 7 * SIZE(%ecx)

	addl	$8 * SIZE, %ecx
	decl	%esi
	jg	.L21

	movl	M,  %esi
	andl	$7, %esi
	jne	.L100
	jmp	.L99

.L29:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	addpd	%xmm1, %xmm5

	movsd	  0 * SIZE(%edx), %xmm2
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm2
	addl	  %eax, %edx
	addpd	%xmm2, %xmm6

	movsd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm0
	addpd	%xmm0, %xmm7

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm6, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm7, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm7, %xmm7
	movsd	%xmm7, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	decl	%esi
	jg	.L21

	movl	M,  %esi
	andl	$7, %esi
	jne	.L100

.L99:
	movl	PLDA_M, %ebx
	addl	%ebx, A

	movl	N, %edi
	movl	IS, %ecx
	cmpl	%edi, %ecx
	jl	.L01

.L999:
	movl	OLD_STACK, %esp
	popl	%ebx
	popl	%esi
	popl	%edi	
	popl	%ebp
	ret

.L100:
	movl	M,  %esi
	andl	$7, %esi
	cmpl	$7, %esi
	jne	.L110

.L101:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6
	pxor	%xmm7, %xmm7

	movl	A, %edx		# aoffset = a
	addl	$7 * SIZE, A	# a += 8

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L106

.L104:
	KERNELMACRO7( 0)
	KERNELMACRO7( 2)
	KERNELMACRO7( 4)
	KERNELMACRO7( 6)
	KERNELMACRO7( 8)
	KERNELMACRO7(10)
	KERNELMACRO7(12)
	KERNELMACRO7(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L104

.L106:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L108

.L107:
	KERNELMACRO7( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L107

.L108:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulpd	%xmm3, %xmm5
	movl	%ecx, %edx
	mulpd	%xmm3, %xmm6
	addl	%eax, %edx
	mulsd	%xmm3, %xmm7
	cmpl	$8, %eax
	jne	.L109

	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm0
	movhpd	  3 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm5

	movsd	  4 * SIZE(%ecx), %xmm0
	movhpd	  5 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm6

	movsd	  6 * SIZE(%ecx), %xmm0
	addsd	%xmm0, %xmm7

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 3 * SIZE(%ecx)

	movsd	%xmm6, 4 * SIZE(%ecx)
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 5 * SIZE(%ecx)

	movsd	%xmm7, 6 * SIZE(%ecx)
	jmp	.L99

.L109:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	addpd	%xmm1, %xmm5

	movsd	  0 * SIZE(%edx), %xmm2
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm2
	addl	  %eax, %edx
	addpd	%xmm2, %xmm6

	movsd	  0 * SIZE(%edx), %xmm0
	addsd	%xmm0, %xmm7

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm6, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm7, 0 * SIZE(%ecx)
	jmp	.L99

.L110:
	cmpl	$6, %esi
	jne	.L120

.L111:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6

	movl	A, %edx		# aoffset = a
	addl	$6 * SIZE, A	# a += 6

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L116

.L114:
	KERNELMACRO6( 0)
	KERNELMACRO6( 2)
	KERNELMACRO6( 4)
	KERNELMACRO6( 6)
	KERNELMACRO6( 8)
	KERNELMACRO6(10)
	KERNELMACRO6(12)
	KERNELMACRO6(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L114

.L116:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L118

.L117:
	KERNELMACRO6( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L117

.L118:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulpd	%xmm3, %xmm5
	movl	%ecx, %edx
	mulpd	%xmm3, %xmm6
	addl	%eax, %edx
	cmpl	$8, %eax
	jne	.L119

	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm0
	movhpd	  3 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm5

	movsd	  4 * SIZE(%ecx), %xmm0
	movhpd	  5 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm6

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 3 * SIZE(%ecx)

	movsd	%xmm6, 4 * SIZE(%ecx)
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 5 * SIZE(%ecx)
	jmp	.L99

.L119:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	addpd	%xmm1, %xmm5

	movsd	  0 * SIZE(%edx), %xmm2
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm2
	addpd	%xmm2, %xmm6

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm6, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm6, %xmm6
	movsd	%xmm6, 0 * SIZE(%ecx)
	jmp	.L99

.L120:
	cmpl	$5, %esi
	jne	.L130

.L121:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5
	pxor	%xmm6, %xmm6

	movl	A, %edx		# aoffset = a
	addl	$5 * SIZE, A	# a += 5

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L126

.L124:
	KERNELMACRO5( 0)
	KERNELMACRO5( 2)
	KERNELMACRO5( 4)
	KERNELMACRO5( 6)
	KERNELMACRO5( 8)
	KERNELMACRO5(10)
	KERNELMACRO5(12)
	KERNELMACRO5(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L124

.L126:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L128

.L127:
	KERNELMACRO5( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L127

.L128:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulpd	%xmm3, %xmm5
	movl	%ecx, %edx
	mulsd	%xmm3, %xmm6
	addl	%eax, %edx
	cmpl	$8, %eax
	jne	.L129

	movsd	  0 * SIZE(%ecx), %xmm0
	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm0
	movhpd	  3 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm5

	movsd	  4 * SIZE(%ecx), %xmm0
	addsd	%xmm0, %xmm6

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 3 * SIZE(%ecx)

	movsd	%xmm6, 4 * SIZE(%ecx)
	jmp	.L99

.L129:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	addpd	%xmm1, %xmm5

	movsd	  0 * SIZE(%edx), %xmm2
	addsd	%xmm2, %xmm6

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm6, 0 * SIZE(%ecx)
	jmp	.L99

.L130:
	cmpl	$4, %esi
	jne	.L140

.L131:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5

	movl	A, %edx		# aoffset = a
	addl	$4 * SIZE, A	# a += 5

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L136

.L134:
	KERNELMACRO4( 0)
	KERNELMACRO4( 2)
	KERNELMACRO4( 4)
	KERNELMACRO4( 6)
	KERNELMACRO4( 8)
	KERNELMACRO4(10)
	KERNELMACRO4(12)
	KERNELMACRO4(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L134

.L136:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L138

.L137:
	KERNELMACRO4( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L137

.L138:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulpd	%xmm3, %xmm5
	movl	%ecx, %edx
	addl	%eax, %edx
	cmpl	$8, %eax
	jne	.L139

	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm0
	movhpd	  3 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm5

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 3 * SIZE(%ecx)
	jmp	.L99

.L139:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addl	  %eax, %edx
	movhpd	  0 * SIZE(%edx), %xmm1
	addpd	%xmm1, %xmm5

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm5, %xmm5
	movsd	%xmm5, 0 * SIZE(%ecx)
	jmp	.L99

.L140:
	cmpl	$3, %esi
	jne	.L150

.L141:
	pxor	%xmm4, %xmm4
	pxor	%xmm5, %xmm5

	movl	A, %edx		# aoffset = a
	addl	$3 * SIZE, A	# a += 5

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L146

.L144:
	KERNELMACRO3( 0)
	KERNELMACRO3( 2)
	KERNELMACRO3( 4)
	KERNELMACRO3( 6)
	KERNELMACRO3( 8)
	KERNELMACRO3(10)
	KERNELMACRO3(12)
	KERNELMACRO3(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L144

.L146:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L148

.L147:
	KERNELMACRO3( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L147

.L148:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	mulsd	%xmm3, %xmm5
	movl	%ecx, %edx
	addl	%eax, %edx
	cmpl	$8, %eax
	jne	.L149

	movsd	  0 * SIZE(%ecx), %xmm0
	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	  2 * SIZE(%ecx), %xmm0
	addsd	%xmm0, %xmm5

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)

	movsd	%xmm5, 2 * SIZE(%ecx)
	jmp	.L99

.L149:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	  0 * SIZE(%edx), %xmm1
	addsd	%xmm1, %xmm5

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx

	movsd	%xmm5, 0 * SIZE(%ecx)
	jmp	.L99

.L150:
	cmpl	$2, %esi
	jne	.L160

.L151:
	pxor	%xmm4, %xmm4

	movl	A, %edx		# aoffset = a
	addl	$2 * SIZE, A	# a += 5

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L156

.L154:
	KERNELMACRO2( 0)
	KERNELMACRO2( 2)
	KERNELMACRO2( 4)
	KERNELMACRO2( 6)
	KERNELMACRO2( 8)
	KERNELMACRO2(10)
	KERNELMACRO2(12)
	KERNELMACRO2(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L154

.L156:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L158

.L157:
	KERNELMACRO2( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L157

.L158:
	movsd	  0 * SIZE(%ecx), %xmm0
	mulpd	%xmm3, %xmm4
	movl	INCY, %eax
	movl	%ecx, %edx
	addl	%eax, %edx
	cmpl	$8, %eax
	jne	.L159

	movsd	  0 * SIZE(%ecx), %xmm0
	movhpd	  1 * SIZE(%ecx), %xmm0
	addpd	%xmm0, %xmm4

	movsd	%xmm4, 0 * SIZE(%ecx)
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 1 * SIZE(%ecx)
	jmp	.L99

.L159:
	movhpd	  0 * SIZE(%edx), %xmm0
	addl	  %eax, %edx
	addpd	%xmm0, %xmm4

	movsd	%xmm4, 0 * SIZE(%ecx)
	addl	  %eax, %ecx
	unpckhpd %xmm4, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	jmp	.L99

.L160:
	pxor	%xmm4, %xmm4

	movl	A, %edx		# aoffset = a
	addl	$1 * SIZE, A	# a += 5

	movl	BUFFER, %ebx	# boffset = buffer
	movapd	  0 * SIZE(%ebx), %xmm0

	movl	%edi, %eax	# i = min_n
	sarl	$3, %eax
	jle	.L166

.L164:
	KERNELMACRO1( 0)
	KERNELMACRO1( 2)
	KERNELMACRO1( 4)
	KERNELMACRO1( 6)
	KERNELMACRO1( 8)
	KERNELMACRO1(10)
	KERNELMACRO1(12)
	KERNELMACRO1(14)
	addl	$16 * SIZE, %ebx
	decl	%eax
	jg	.L164

.L166:
	movl	%edi, %eax	# i = min_n
	andl	$7, %eax
	jle	.L168

.L167:
	KERNELMACRO1( 0)
	addl	$2 * SIZE, %ebx
	decl	%eax
	jg	.L167

.L168:
	mulsd	%xmm3, %xmm4
	movsd	  0 * SIZE(%ecx), %xmm0
	addsd	%xmm0, %xmm4
	movsd	%xmm4, 0 * SIZE(%ecx)
	jmp	.L99	

	EPILOGUE
