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

#define N	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#else
#define INCY	%r10
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
#endif

	SAVEREGISTERS

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

	leaq	(, INCX, SIZE), INCX	
	leaq	(, INCY, SIZE), INCY	

	pxor	%xmm0, %xmm0
	pxor	%xmm1, %xmm1
	pxor	%xmm2, %xmm2
	pxor	%xmm3, %xmm3

	cmpq	$0, N
	jle	.L999

	cmpq	$SIZE, INCX
	jne	.L50
	cmpq	$SIZE, INCY
	jne	.L50

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y

	cmpq	$3, N
	jle	.L17

	testq	$SIZE, Y
	je	.L05

	movss	-32 * SIZE(X), %xmm0
	mulss	-32 * SIZE(Y), %xmm0
	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	N
	ALIGN_2

.L05:
	testq	$2 * SIZE, Y
	je	.L10

	movsd	-32 * SIZE(X), %xmm4
	movsd	-32 * SIZE(Y), %xmm1
	mulps	%xmm4, %xmm1
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	subq	$2, N
	jle	.L999
	ALIGN_2


.L10:
	testq	$3 * SIZE, X
	jne	.L20

	movq	N,  %rax
	sarq	$5, %rax
	jle	.L14

	movaps	-32 * SIZE(X), %xmm12
	pxor	%xmm4, %xmm4
	movaps	-28 * SIZE(X), %xmm13
	pxor	%xmm5, %xmm5
	movaps	-24 * SIZE(X), %xmm14
	pxor	%xmm6, %xmm6
	movaps	-20 * SIZE(X), %xmm15
	pxor	%xmm7, %xmm7

	movaps	-32 * SIZE(Y), %xmm8
	movaps	-28 * SIZE(Y), %xmm9
	movaps	-24 * SIZE(Y), %xmm10
	movaps	-20 * SIZE(Y), %xmm11
	subq	$1, %rax
	jle	.L12
	ALIGN_3

.L11:
	addps	%xmm4,  %xmm0
	movaps	-16 * SIZE(X), %xmm4
	mulps	%xmm8,  %xmm12
	movaps	-16 * SIZE(Y), %xmm8
	addps	%xmm5,  %xmm1
	movaps	-12 * SIZE(X), %xmm5
	mulps	%xmm9,  %xmm13
	movaps	-12 * SIZE(Y), %xmm9
	addps	%xmm6,  %xmm2
	movaps	 -8 * SIZE(X), %xmm6
	mulps	%xmm10, %xmm14
	movaps	 -8 * SIZE(Y), %xmm10
	addps	%xmm7,  %xmm3
	movaps	 -4 * SIZE(X), %xmm7
	mulps	%xmm11, %xmm15
	movaps	 -4 * SIZE(Y), %xmm11

	addps	%xmm12,  %xmm0
	movaps	  0 * SIZE(X), %xmm12
	mulps	%xmm8,  %xmm4
	movaps	  0 * SIZE(Y), %xmm8
	addps	%xmm13,  %xmm1
	movaps	  4 * SIZE(X), %xmm13
	mulps	%xmm9,  %xmm5
	movaps	  4 * SIZE(Y), %xmm9
	addps	%xmm14,  %xmm2
	movaps	  8 * SIZE(X), %xmm14
	mulps	%xmm10, %xmm6
	movaps	  8 * SIZE(Y), %xmm10
	addps	%xmm15,  %xmm3
	movaps	 12 * SIZE(X), %xmm15
	mulps	%xmm11, %xmm7
	subq	$-32 * SIZE, X
	movaps	 12 * SIZE(Y), %xmm11
	subq	$-32 * SIZE, Y

	subq	$1, %rax
	jg,pt	.L11
	ALIGN_3

.L12:
	addps	%xmm4,  %xmm0
	movaps	-16 * SIZE(X), %xmm4
	mulps	%xmm8,  %xmm12
	movaps	-16 * SIZE(Y), %xmm8
	addps	%xmm5,  %xmm1
	movaps	-12 * SIZE(X), %xmm5
	mulps	%xmm9,  %xmm13
	movaps	-12 * SIZE(Y), %xmm9
	addps	%xmm6,  %xmm2
	movaps	 -8 * SIZE(X), %xmm6
	mulps	%xmm10, %xmm14
	movaps	 -8 * SIZE(Y), %xmm10
	addps	%xmm7,  %xmm3
	movaps	 -4 * SIZE(X), %xmm7
	mulps	%xmm11, %xmm15
	movaps	 -4 * SIZE(Y), %xmm11

	addps	%xmm12,  %xmm0
	mulps	%xmm8,  %xmm4
	addps	%xmm13,  %xmm1
	mulps	%xmm9,  %xmm5
	addps	%xmm14,  %xmm2
	mulps	%xmm10, %xmm6
	addps	%xmm15,  %xmm3
	mulps	%xmm11, %xmm7

	addps	%xmm4,  %xmm0
	addps	%xmm5,  %xmm1
	addps	%xmm6,  %xmm2
	subq	$-32 * SIZE, X
	addps	%xmm7,  %xmm3
	subq	$-32 * SIZE, Y
	ALIGN_3

.L14:
	movq	N,  %rax
	andq	$16, %rax
	jle	.L15

	movaps	-32 * SIZE(X), %xmm4
	movaps	-28 * SIZE(X), %xmm5
	movaps	-24 * SIZE(X), %xmm6
	movaps	-20 * SIZE(X), %xmm7

	mulps	-32 * SIZE(Y), %xmm4
	mulps	-28 * SIZE(Y), %xmm5
	mulps	-24 * SIZE(Y), %xmm6
	mulps	-20 * SIZE(Y), %xmm7

	addps	%xmm4,  %xmm0
	addps	%xmm5,  %xmm1
	addps	%xmm6,  %xmm2
	addps	%xmm7,  %xmm3

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L15:
	movq	N,  %rax
	andq	$8, %rax
	jle	.L16

	movaps	-32 * SIZE(X), %xmm4
	movaps	-28 * SIZE(X), %xmm5

	mulps	-32 * SIZE(Y), %xmm4
	mulps	-28 * SIZE(Y), %xmm5

	addps	%xmm4,  %xmm0
	addps	%xmm5,  %xmm1

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	movq	N,  %rax
	andq	$4, %rax
	jle	.L17

	movaps	-32 * SIZE(X), %xmm4
	mulps	-32 * SIZE(Y), %xmm4

	addps	%xmm4,  %xmm2

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	movq	N,  %rax
	andq	$2, %rax
	jle	.L18

	movsd	-32 * SIZE(X), %xmm4
	movsd	-32 * SIZE(Y), %xmm8

	mulps	%xmm8,  %xmm4
	addps	%xmm4,  %xmm3

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L18:
	movq	N,  %rax
	andq	$1, %rax
	jle	.L999

	movss	-32 * SIZE(X), %xmm4
	mulss	-32 * SIZE(Y), %xmm4
	addss	%xmm4,  %xmm0
	jmp	.L999
	ALIGN_3

.L20:
	testq	$2 * SIZE, X
	jne	.L30

	movaps	-33 * SIZE(X), %xmm4

	movq	N,  %rax
	sarq	$5, %rax
	jle	.L23

	movaps	-29 * SIZE(X), %xmm5
	pxor	%xmm12, %xmm12
	movaps	-25 * SIZE(X), %xmm6
	pxor	%xmm13, %xmm13
	movaps	-21 * SIZE(X), %xmm7
	pxor	%xmm14, %xmm14
	movaps	-17 * SIZE(X), %xmm8
	pxor	%xmm15, %xmm15

	decq	%rax
	jle .L22
	ALIGN_3

.L21:
	addps	%xmm12, %xmm0
	movaps	-13 * SIZE(X), %xmm12
	addps	%xmm13, %xmm1
	movaps	 -9 * SIZE(X), %xmm13

	addps	%xmm14, %xmm2
	movaps	 -5 * SIZE(X), %xmm14
	addps	%xmm15, %xmm3
	movaps	 -1 * SIZE(X), %xmm15

	movaps	%xmm5, %xmm9
	palignr	$4, %xmm4, %xmm5
	mulps	-32 * SIZE(Y), %xmm5
	movaps	%xmm6, %xmm10
	palignr	$4, %xmm9, %xmm6
	mulps	-28 * SIZE(Y), %xmm6

	movaps	%xmm7, %xmm11
	palignr	$4, %xmm10, %xmm7
	mulps	-24 * SIZE(Y), %xmm7
	movaps	%xmm8, %xmm4
	palignr	$4, %xmm11, %xmm8
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	movaps	  3 * SIZE(X), %xmm5
	addps	%xmm6, %xmm1
	movaps	  7 * SIZE(X), %xmm6
	addps	%xmm7, %xmm2
	movaps	 11 * SIZE(X), %xmm7
	addps	%xmm8, %xmm3
	movaps	 15 * SIZE(X), %xmm8

	movaps	%xmm12, %xmm9
	palignr	$4, %xmm4, %xmm12
	mulps	-16 * SIZE(Y), %xmm12
	movaps	%xmm13, %xmm10
	palignr	$4, %xmm9, %xmm13
	mulps	-12 * SIZE(Y), %xmm13

	movaps	%xmm14, %xmm11
	palignr	$4, %xmm10, %xmm14
	mulps	 -8 * SIZE(Y), %xmm14
	subq	$-32 * SIZE, X
	movaps	%xmm15, %xmm4
	palignr	$4, %xmm11, %xmm15
	mulps	 -4 * SIZE(Y), %xmm15
	subq	$-32 * SIZE, Y

	subq	$1, %rax
	jg,pt	.L21
	ALIGN_3

.L22:
	addps	%xmm12, %xmm0
	movaps	-13 * SIZE(X), %xmm12
	addps	%xmm13, %xmm1
	movaps	 -9 * SIZE(X), %xmm13
	addps	%xmm14, %xmm2
	movaps	 -5 * SIZE(X), %xmm14
	addps	%xmm15, %xmm3
	movaps	 -1 * SIZE(X), %xmm15

	movaps	%xmm5, %xmm9
	palignr	$4, %xmm4, %xmm5
	movaps	%xmm6, %xmm10
	palignr	$4, %xmm9, %xmm6
	movaps	%xmm7, %xmm11
	palignr	$4, %xmm10, %xmm7
	movaps	%xmm8, %xmm4
	palignr	$4, %xmm11, %xmm8

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6
	mulps	-24 * SIZE(Y), %xmm7
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	addps	%xmm6, %xmm1
	addps	%xmm7, %xmm2
	addps	%xmm8, %xmm3

	movaps	%xmm12, %xmm9
	palignr	$4, %xmm4, %xmm12
	movaps	%xmm13, %xmm10
	palignr	$4, %xmm9, %xmm13

	movaps	%xmm14, %xmm11
	palignr	$4, %xmm10, %xmm14
	movaps	%xmm15, %xmm4
	palignr	$4, %xmm11, %xmm15

	mulps	-16 * SIZE(Y), %xmm12
	mulps	-12 * SIZE(Y), %xmm13
	mulps	 -8 * SIZE(Y), %xmm14
	mulps	 -4 * SIZE(Y), %xmm15

	addps	%xmm12, %xmm0
	addps	%xmm13, %xmm1
	addps	%xmm14, %xmm2
	addps	%xmm15, %xmm3

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L23:
	testq	$16, N
	jle	.L24
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm5
	movaps	-25 * SIZE(X), %xmm6
	movaps	-21 * SIZE(X), %xmm7
	movaps	-17 * SIZE(X), %xmm8

	movaps	%xmm5, %xmm9
	movaps	%xmm6, %xmm10

	palignr	$4, %xmm4, %xmm5
	palignr	$4, %xmm9, %xmm6

	movaps	%xmm7, %xmm11
	movaps	%xmm8, %xmm4

	palignr	$4, %xmm10, %xmm7
	palignr	$4, %xmm11, %xmm8

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6
	mulps	-24 * SIZE(Y), %xmm7
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	addps	%xmm6, %xmm1
	addps	%xmm7, %xmm2
	addps	%xmm8, %xmm3

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L24:
	testq	$8, N
	jle	.L25
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm5
	movaps	-25 * SIZE(X), %xmm6

	movaps	%xmm5, %xmm7
	movaps	%xmm6, %xmm8

	palignr	$4, %xmm4, %xmm5
	palignr	$4, %xmm7, %xmm6
	movaps	%xmm8, %xmm4

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6

	addps	%xmm5,  %xmm0
	addps	%xmm6,  %xmm1

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	testq	$4, N
	jle	.L26
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm5
	palignr	$4, %xmm4, %xmm5
	mulps	-32 * SIZE(Y), %xmm5
	addps	%xmm5,  %xmm2

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	testq	$2, N
	jle	.L27
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm4
	movsd	-32 * SIZE(Y), %xmm8

	mulps	%xmm8,  %xmm4
	addps	%xmm4,  %xmm3

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L27:
	testq	$1, N
	jle	.L999
	ALIGN_3

	movss	-32 * SIZE(X), %xmm4
	mulss	-32 * SIZE(Y), %xmm4
	addss	%xmm4,  %xmm0
	jmp	.L999
	ALIGN_3

.L30:
	testq	$1 * SIZE, X
	jne	.L40

	movaps	 -34 * SIZE(X), %xmm4

	movq	N,  %rax
	sarq	$5, %rax
	jle	.L33
	ALIGN_4

.L31:
	movaps	 -30 * SIZE(X), %xmm5
	SHUFPD_1 %xmm5, %xmm4
	movaps	 -26 * SIZE(X), %xmm6
	SHUFPD_1 %xmm6, %xmm5
	movaps	 -22 * SIZE(X), %xmm7
	SHUFPD_1 %xmm7, %xmm6
	movaps	 -18 * SIZE(X), %xmm8
	SHUFPD_1 %xmm8, %xmm7

	mulps	-32 * SIZE(Y), %xmm4
	addps	%xmm4, %xmm0
	mulps	-28 * SIZE(Y), %xmm5
	addps	%xmm5, %xmm1
	mulps	-24 * SIZE(Y), %xmm6
	addps	%xmm6, %xmm2
	mulps	-20 * SIZE(Y), %xmm7
	addps	%xmm7, %xmm3

	movaps	 -14 * SIZE(X), %xmm9
	SHUFPD_1 %xmm9,  %xmm8
	movaps	 -10 * SIZE(X), %xmm10
	SHUFPD_1 %xmm10, %xmm9
	movaps	  -6 * SIZE(X), %xmm11
	SHUFPD_1 %xmm11, %xmm10
	movaps	  -2 * SIZE(X), %xmm4
	subq	$-32 * SIZE, X
	SHUFPD_1 %xmm4,  %xmm11

	mulps	-16 * SIZE(Y), %xmm8
	addps	%xmm8,  %xmm0
	mulps	-12 * SIZE(Y), %xmm9
	addps	%xmm9,  %xmm1
	mulps	 -8 * SIZE(Y), %xmm10
	addps	%xmm10, %xmm2
	mulps	 -4 * SIZE(Y), %xmm11
	subq	$-32 * SIZE, Y
	addps	%xmm11, %xmm3

	subq	$1, %rax
	jg,pt	.L31
	ALIGN_3

.L33:
	testq	$16, N
	jle	.L34
	ALIGN_3

	movaps	-30 * SIZE(X), %xmm5
	movaps	-26 * SIZE(X), %xmm6
	movaps	-22 * SIZE(X), %xmm7
	movaps	-18 * SIZE(X), %xmm8

	SHUFPD_1 %xmm5, %xmm4
	SHUFPD_1 %xmm6, %xmm5
	SHUFPD_1 %xmm7, %xmm6
	SHUFPD_1 %xmm8, %xmm7

	mulps	-32 * SIZE(Y), %xmm4
	mulps	-28 * SIZE(Y), %xmm5
	mulps	-24 * SIZE(Y), %xmm6
	mulps	-20 * SIZE(Y), %xmm7

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1
	addps	%xmm6, %xmm2
	addps	%xmm7, %xmm3

	movaps	%xmm8, %xmm4
	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L34:
	testq	$8, N
	jle	.L35
	ALIGN_3
 
	movaps	-30 * SIZE(X), %xmm5
	SHUFPD_1 %xmm5, %xmm4
	movaps	-26 * SIZE(X), %xmm6
	SHUFPD_1 %xmm6, %xmm5

	mulps	-32 * SIZE(Y), %xmm4
	mulps	-28 * SIZE(Y), %xmm5

	addps	%xmm4, %xmm0
	addps	%xmm5, %xmm1
	movaps	%xmm6, %xmm4

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L35:
	testq	$4, N
	jle	.L36
	ALIGN_3

	movaps	-30 * SIZE(X), %xmm5
	SHUFPD_1 %xmm5, %xmm4
	mulps	-32 * SIZE(Y), %xmm4

	addps	%xmm4, %xmm2
	movaps	%xmm5, %xmm4

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L36:
	testq	$2, N
	jle	.L37
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm4
	movsd	-32 * SIZE(Y), %xmm8

	mulps	%xmm8,  %xmm4
	addps	%xmm4,  %xmm3

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L37:
	testq	$1, N
	jle	.L999
	ALIGN_3

	movss	-32 * SIZE(X), %xmm4
	mulss	-32 * SIZE(Y), %xmm4
	addss	%xmm4, %xmm0

	jmp	.L999
	ALIGN_3

.L40:
	movaps	-35 * SIZE(X), %xmm4

	movq	N,  %rax
	sarq	$5, %rax
	jle	.L43

	movaps	-31 * SIZE(X), %xmm5
	pxor	%xmm12, %xmm12
	movaps	-27 * SIZE(X), %xmm6
	pxor	%xmm13, %xmm13
	movaps	-23 * SIZE(X), %xmm7
	pxor	%xmm14, %xmm14
	movaps	-19 * SIZE(X), %xmm8
	pxor	%xmm15, %xmm15

	decq	%rax
	jle .L42
	ALIGN_3

.L41:
	addps	%xmm12, %xmm0
	movaps	-15 * SIZE(X), %xmm12
	addps	%xmm13, %xmm1
	movaps	-11 * SIZE(X), %xmm13

	addps	%xmm14, %xmm2
	movaps	 -7 * SIZE(X), %xmm14
	addps	%xmm15, %xmm3
	movaps	 -3 * SIZE(X), %xmm15

	movaps	%xmm5, %xmm9
	palignr	$12, %xmm4, %xmm5
	mulps	-32 * SIZE(Y), %xmm5
	movaps	%xmm6, %xmm10
	palignr	$12, %xmm9, %xmm6
	mulps	-28 * SIZE(Y), %xmm6

	movaps	%xmm7, %xmm11
	palignr	$12, %xmm10, %xmm7
	mulps	-24 * SIZE(Y), %xmm7
	movaps	%xmm8, %xmm4
	palignr	$12, %xmm11, %xmm8
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	movaps	  1 * SIZE(X), %xmm5
	addps	%xmm6, %xmm1
	movaps	  5 * SIZE(X), %xmm6
	addps	%xmm7, %xmm2
	movaps	  9 * SIZE(X), %xmm7
	addps	%xmm8, %xmm3
	movaps	 13 * SIZE(X), %xmm8

	movaps	%xmm12, %xmm9
	palignr	$12, %xmm4, %xmm12
	mulps	-16 * SIZE(Y), %xmm12
	movaps	%xmm13, %xmm10
	palignr	$12, %xmm9, %xmm13
	mulps	-12 * SIZE(Y), %xmm13

	movaps	%xmm14, %xmm11
	palignr	$12, %xmm10, %xmm14
	mulps	 -8 * SIZE(Y), %xmm14
	subq	$-32 * SIZE, X
	movaps	%xmm15, %xmm4
	palignr	$12, %xmm11, %xmm15
	mulps	 -4 * SIZE(Y), %xmm15
	subq	$-32 * SIZE, Y

	subq	$1, %rax
	jg,pt	.L41
	ALIGN_3

.L42:
	addps	%xmm12, %xmm0
	movaps	-15 * SIZE(X), %xmm12
	addps	%xmm13, %xmm1
	movaps	-11 * SIZE(X), %xmm13
	addps	%xmm14, %xmm2
	movaps	 -7 * SIZE(X), %xmm14
	addps	%xmm15, %xmm3
	movaps	 -3 * SIZE(X), %xmm15

	movaps	%xmm5, %xmm9
	palignr	$12, %xmm4, %xmm5
	movaps	%xmm6, %xmm10
	palignr	$12, %xmm9, %xmm6
	movaps	%xmm7, %xmm11
	palignr	$12, %xmm10, %xmm7
	movaps	%xmm8, %xmm4
	palignr	$12, %xmm11, %xmm8

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6
	mulps	-24 * SIZE(Y), %xmm7
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	addps	%xmm6, %xmm1
	addps	%xmm7, %xmm2
	addps	%xmm8, %xmm3

	movaps	%xmm12, %xmm9
	palignr	$12, %xmm4, %xmm12
	movaps	%xmm13, %xmm10
	palignr	$12, %xmm9, %xmm13

	movaps	%xmm14, %xmm11
	palignr	$12, %xmm10, %xmm14
	movaps	%xmm15, %xmm4
	palignr	$12, %xmm11, %xmm15

	mulps	-16 * SIZE(Y), %xmm12
	mulps	-12 * SIZE(Y), %xmm13
	mulps	 -8 * SIZE(Y), %xmm14
	mulps	 -4 * SIZE(Y), %xmm15

	addps	%xmm12, %xmm0
	addps	%xmm13, %xmm1
	addps	%xmm14, %xmm2
	addps	%xmm15, %xmm3

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L43:
	testq	$16, N
	jle	.L44
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm5
	movaps	-27 * SIZE(X), %xmm6
	movaps	-23 * SIZE(X), %xmm7
	movaps	-19 * SIZE(X), %xmm8

	movaps	%xmm5, %xmm9
	movaps	%xmm6, %xmm10

	palignr	$12, %xmm4, %xmm5
	palignr	$12, %xmm9, %xmm6

	movaps	%xmm7, %xmm11
	movaps	%xmm8, %xmm4

	palignr	$12, %xmm10, %xmm7
	palignr	$12, %xmm11, %xmm8

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6
	mulps	-24 * SIZE(Y), %xmm7
	mulps	-20 * SIZE(Y), %xmm8

	addps	%xmm5, %xmm0
	addps	%xmm6, %xmm1
	addps	%xmm7, %xmm2
	addps	%xmm8, %xmm3

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L44:
	testq	$8, N
	jle	.L45
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm5
	movaps	-27 * SIZE(X), %xmm6

	movaps	%xmm5, %xmm7
	movaps	%xmm6, %xmm8

	palignr	$12, %xmm4, %xmm5
	palignr	$12, %xmm7, %xmm6
	movaps	%xmm8, %xmm4

	mulps	-32 * SIZE(Y), %xmm5
	mulps	-28 * SIZE(Y), %xmm6

	addps	%xmm5,  %xmm0
	addps	%xmm6,  %xmm1

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L45:
	testq	$4, N
	jle	.L46
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm5
	palignr	$12, %xmm4, %xmm5
	mulps	-32 * SIZE(Y), %xmm5
	addps	%xmm5,  %xmm2

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L46:
	testq	$2, N
	jle	.L47
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm4
	movsd	-32 * SIZE(Y), %xmm8

	mulps	%xmm8,  %xmm4
	addps	%xmm4,  %xmm3

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L47:
	testq	$1, N
	jle	.L999
	ALIGN_3

	movss	-32 * SIZE(X), %xmm4
	mulss	-32 * SIZE(Y), %xmm4
	addss	%xmm4,  %xmm0
	jmp	.L999
	ALIGN_3

.L50:
#ifdef F_INTERFACE
	testq	INCX, INCX
	jge	.L51

	movq	N, %rax
	decq	%rax
	imulq	INCX, %rax
	subq	%rax, X
	ALIGN_3

.L51:
	testq	INCY, INCY
	jge	.L52

	movq	N, %rax
	decq	%rax
	imulq	INCY, %rax
	subq	%rax, Y
	ALIGN_3
.L52:
#endif

	movq	N,  %rax
	sarq	$2, %rax
	jle	.L55
	ALIGN_3

.L53:
	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
	mulss	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	movss	0 * SIZE(X), %xmm5
	addq	INCX, X
	mulss	0 * SIZE(Y), %xmm5
	addq	INCY, Y
	movss	0 * SIZE(X), %xmm6
	addq	INCX, X
	mulss	0 * SIZE(Y), %xmm6
	addq	INCY, Y
	movss	0 * SIZE(X), %xmm7
	addq	INCX, X
	mulss	0 * SIZE(Y), %xmm7
	addq	INCY, Y

	addss	%xmm4, %xmm0
	addss	%xmm5, %xmm1
	addss	%xmm6, %xmm2
	addss	%xmm7, %xmm3

	decq	%rax
	jg	.L53
	ALIGN_3

.L55:
	movq	N, %rax
	andq	$3,   %rax
	jle	.L999
	ALIGN_3

.L56:
	movss	0 * SIZE(X), %xmm4
	addq	INCX, X
	mulss	0 * SIZE(Y), %xmm4
	addq	INCY, Y
	addss	%xmm4, %xmm0
	decq	%rax
	jg	.L56
	ALIGN_3

.L999:
	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	addps	%xmm2, %xmm0

#ifndef HAVE_SSE3
	movhlps	%xmm0, %xmm1
	addps	%xmm1, %xmm0
	
	movaps	%xmm0, %xmm1
	shufps  $1, %xmm0, %xmm0
	addss	 %xmm1, %xmm0
#else
	haddps	%xmm0, %xmm0
	haddps	%xmm0, %xmm0
#endif

#if !defined(DOUBLE) && defined(F_INTERFACE) && defined(NEED_F2CCONV)
	cvtss2sd	%xmm0, %xmm0
#endif

	RESTOREREGISTERS

	ret

	EPILOGUE
