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

#define M	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#define FLAG	ARG6
#else
#define INCY	%r10
#define FLAG	%r11
#endif

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
#endif

	SAVEREGISTERS

	leaq	(, INCX, SIZE * 2), INCX
	leaq	(, INCY, SIZE * 2), INCY

	xorq	FLAG, FLAG

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y

	cmpq	$2 * SIZE, INCX
	jne	.L80
	cmpq	$2 * SIZE, INCY
	jne	.L80

	testq	$1 * SIZE, Y
	je	.L05

	movq	$1, FLAG
	movss	-32 * SIZE(X), %xmm0
	movss	%xmm0, -32 * SIZE(Y)

	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	M
	jle	.L18
	ALIGN_4

.L05:
	testq	$2 * SIZE, Y
	je	.L10

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, -32 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	decq	M
	jle	.L18

.L10:
	testq	$3 * SIZE, X
	jne	.L20

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L13

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1
	movaps	-24 * SIZE(X), %xmm2
	movaps	-20 * SIZE(X), %xmm3

	movaps	-16 * SIZE(X), %xmm4
	movaps	-12 * SIZE(X), %xmm5
	movaps	 -8 * SIZE(X), %xmm6
	movaps	 -4 * SIZE(X), %xmm7
	decq	%rax
	jle .L12
	ALIGN_3

.L11:
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	 0 * SIZE(X), %xmm0
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	 4 * SIZE(X), %xmm1
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	 8 * SIZE(X), %xmm2
	movaps	%xmm3, -20 * SIZE(Y)
	movaps	12 * SIZE(X), %xmm3

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	16 * SIZE(X), %xmm4
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	20 * SIZE(X), %xmm5
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	24 * SIZE(X), %xmm6
	movaps	%xmm7,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	movaps	28 * SIZE(X), %xmm7
	subq	$-32 * SIZE, X

	subq	$1, %rax
	jg,pt	.L11
	ALIGN_3

.L12:
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	movaps	%xmm4, -16 * SIZE(Y)
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	%xmm7,  -4 * SIZE(Y)

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L13:
	testq	$8, M
	jle	.L14
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1
	movaps	-24 * SIZE(X), %xmm2
	movaps	-20 * SIZE(X), %xmm3

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	%xmm3, -20 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L14:
	testq	$4, M
	jle	.L15
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	-28 * SIZE(X), %xmm1

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L15:
	testq	$2, M
	jle	.L16
	ALIGN_3

	movaps	-32 * SIZE(X), %xmm0
	movaps	%xmm0, -32 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L16:
	testq	$1, M
	jle	.L18
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, 	-32 * SIZE(Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L18:
	testq	$1, FLAG
	je	.L19

	movss	-32 * SIZE(X), %xmm0
	movss	%xmm0, -32 * SIZE(Y)
	ALIGN_3

.L19:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L20:
	testq	$2 * SIZE, X
	jne	.L30

	movaps	-33 * SIZE(X), %xmm0

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L23

	movaps	-29 * SIZE(X), %xmm1
	movaps	-25 * SIZE(X), %xmm2
	movaps	-21 * SIZE(X), %xmm3
	movaps	-17 * SIZE(X), %xmm4
	movaps	-13 * SIZE(X), %xmm5
	movaps	 -9 * SIZE(X), %xmm6
	movaps	 -5 * SIZE(X), %xmm7
	movaps	 -1 * SIZE(X), %xmm8

	decq	%rax
	jle .L22
	ALIGN_3

.L21:
	movaps	%xmm1, %xmm9
	palignr	$4, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)
	movaps	  3 * SIZE(X), %xmm1

	movaps	%xmm2, %xmm10
	palignr	$4, %xmm9, %xmm2
	movaps	%xmm2, -28 * SIZE(Y)
	movaps	  7 * SIZE(X), %xmm2

	movaps	%xmm3, %xmm11
	palignr	$4, %xmm10, %xmm3
	movaps	%xmm3, -24 * SIZE(Y)
	movaps	 11 * SIZE(X), %xmm3

	movaps	%xmm4, %xmm12
	palignr	$4, %xmm11, %xmm4
	movaps	%xmm4, -20 * SIZE(Y)
	movaps	 15 * SIZE(X), %xmm4

	movaps	%xmm5, %xmm13
	palignr	$4, %xmm12, %xmm5
	movaps	%xmm5, -16 * SIZE(Y)
	movaps	 19 * SIZE(X), %xmm5

	movaps	%xmm6, %xmm14
	palignr	$4, %xmm13, %xmm6
	movaps	%xmm6, -12 * SIZE(Y)
	movaps	 23 * SIZE(X), %xmm6

	movaps	%xmm7, %xmm15
	palignr	$4, %xmm14, %xmm7
	movaps	%xmm7,  -8 * SIZE(Y)
	movaps	 27 * SIZE(X), %xmm7

	movaps	%xmm8, %xmm0
	palignr	$4, %xmm15, %xmm8
	movaps	%xmm8,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	movaps	 31 * SIZE(X), %xmm8
	subq	$-32 * SIZE, X

	subq	$1, %rax
	jg,pt	.L21
	ALIGN_3

.L22:
	movaps	%xmm1, %xmm9
	palignr	$4, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)

	movaps	%xmm2, %xmm10
	palignr	$4, %xmm9, %xmm2
	movaps	%xmm2, -28 * SIZE(Y)

	movaps	%xmm3, %xmm11
	palignr	$4, %xmm10, %xmm3
	movaps	%xmm3, -24 * SIZE(Y)

	movaps	%xmm4, %xmm12
	palignr	$4, %xmm11, %xmm4
	movaps	%xmm4, -20 * SIZE(Y)

	movaps	%xmm5, %xmm13
	palignr	$4, %xmm12, %xmm5
	movaps	%xmm5, -16 * SIZE(Y)

	movaps	%xmm6, %xmm14
	palignr	$4, %xmm13, %xmm6
	movaps	%xmm6, -12 * SIZE(Y)

	movaps	%xmm7, %xmm15
	palignr	$4, %xmm14, %xmm7
	movaps	%xmm7,  -8 * SIZE(Y)

	movaps	%xmm8, %xmm0
	palignr	$4, %xmm15, %xmm8
	movaps	%xmm8,  -4 * SIZE(Y)

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L23:
	testq	$8, M
	jle	.L24
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm1
	movaps	-25 * SIZE(X), %xmm2
	movaps	-21 * SIZE(X), %xmm3
	movaps	-17 * SIZE(X), %xmm4

	movaps	%xmm1, %xmm5
	movaps	%xmm2, %xmm6

	palignr	$4, %xmm0, %xmm1
	palignr	$4, %xmm5, %xmm2

	movaps	%xmm3, %xmm7
	movaps	%xmm4, %xmm0

	palignr	$4, %xmm6, %xmm3
	palignr	$4, %xmm7, %xmm4

	movaps	%xmm1, -32 * SIZE(Y)
	movaps	%xmm2, -28 * SIZE(Y)
	movaps	%xmm3, -24 * SIZE(Y)
	movaps	%xmm4, -20 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L24:
	testq	$4, M
	jle	.L25
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm1
	movaps	-25 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm3
	movaps	%xmm2, %xmm4

	palignr	$4, %xmm0, %xmm1
	palignr	$4, %xmm3, %xmm2
	movaps	%xmm4, %xmm0

	movaps	%xmm1, -32 * SIZE(Y)
	movaps	%xmm2, -28 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L25:
	testq	$2, M
	jle	.L26
	ALIGN_3

	movaps	-29 * SIZE(X), %xmm1
	palignr	$4, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L26:
	testq	$1, M
	jle	.L27
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, 	-32 * SIZE(Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L27:
	testq	$1, FLAG
	jle	.L29
	ALIGN_3

	movss	-32 * SIZE(X), %xmm0
	movss	%xmm0, 	-32 * SIZE(Y)
	ALIGN_3

.L29:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L30:
	testq	$1 * SIZE, X
	jne	.L40

	movaps	 -34 * SIZE(X), %xmm0

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L33

	movaps	 -30 * SIZE(X), %xmm1
	movaps	 -26 * SIZE(X), %xmm2
	movaps	 -22 * SIZE(X), %xmm3
	movaps	 -18 * SIZE(X), %xmm4
	movaps	 -14 * SIZE(X), %xmm5
	movaps	 -10 * SIZE(X), %xmm6
	movaps	  -6 * SIZE(X), %xmm7

	decq	%rax
	jle .L32
	ALIGN_4

.L31:
	SHUFPD_1 %xmm1, %xmm0
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	 -2 * SIZE(X), %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	  2 * SIZE(X), %xmm1

	SHUFPD_1 %xmm3, %xmm2
	movaps	%xmm2, -24 * SIZE(Y)
	movaps	  6 * SIZE(X), %xmm2
	SHUFPD_1 %xmm4, %xmm3
	movaps	%xmm3, -20 * SIZE(Y)
	movaps	 10 * SIZE(X), %xmm3

	SHUFPD_1 %xmm5, %xmm4
	movaps	%xmm4, -16 * SIZE(Y)
	movaps	 14 * SIZE(X), %xmm4
	SHUFPD_1 %xmm6, %xmm5
	movaps	%xmm5, -12 * SIZE(Y)
	movaps	 18 * SIZE(X), %xmm5

	SHUFPD_1 %xmm7, %xmm6
	movaps	%xmm6,  -8 * SIZE(Y)
	movaps	 22 * SIZE(X), %xmm6
	SHUFPD_1 %xmm0, %xmm7
	movaps	%xmm7,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	movaps	 26 * SIZE(X), %xmm7
	subq	$-32 * SIZE, X

	subq	$1, %rax
	jg,pt	.L31
	ALIGN_3

.L32:
	SHUFPD_1 %xmm1, %xmm0
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	 -2 * SIZE(X), %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movaps	%xmm1, -28 * SIZE(Y)
	SHUFPD_1 %xmm3, %xmm2
	movaps	%xmm2, -24 * SIZE(Y)
	SHUFPD_1 %xmm4, %xmm3
	movaps	%xmm3, -20 * SIZE(Y)

	SHUFPD_1 %xmm5, %xmm4
	movaps	%xmm4, -16 * SIZE(Y)
	SHUFPD_1 %xmm6, %xmm5
	movaps	%xmm5, -12 * SIZE(Y)
	SHUFPD_1 %xmm7, %xmm6
	movaps	%xmm6,  -8 * SIZE(Y)
	subq	$-32 * SIZE, X
	SHUFPD_1 %xmm0, %xmm7
	movaps	%xmm7,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	ALIGN_3

.L33:
	testq	$8, M
	jle	.L34
	ALIGN_3

	movaps	-30 * SIZE(X), %xmm1
	movaps	-26 * SIZE(X), %xmm2
	movaps	-22 * SIZE(X), %xmm3
	movaps	-18 * SIZE(X), %xmm8

	SHUFPD_1 %xmm1, %xmm0
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm8, %xmm0
	SHUFPD_1 %xmm2, %xmm1
	movaps	%xmm1, -28 * SIZE(Y)
	SHUFPD_1 %xmm3, %xmm2
	movaps	%xmm2, -24 * SIZE(Y)
	addq	$16 * SIZE, X
	SHUFPD_1 %xmm8, %xmm3
	movaps	%xmm3, -20 * SIZE(Y)
	addq	$16 * SIZE, Y
	ALIGN_3

.L34:
	testq	$4, M
	jle	.L35
	ALIGN_3
 
	movaps	-30 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	movaps	-26 * SIZE(X), %xmm2
	SHUFPD_1 %xmm2, %xmm1

	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, -28 * SIZE(Y)
	movaps	%xmm2, %xmm0

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L35:
	testq	$2, M
	jle	.L36
	ALIGN_3

	movaps	-30 * SIZE(X), %xmm1
	SHUFPD_1 %xmm1, %xmm0
	movaps	%xmm0, -32 * SIZE(Y)
	movaps	%xmm1, %xmm0

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L36:
	testq	$1, M
	jle	.L37
	ALIGN_3

	movhps	%xmm0, -32 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L37:
	testq	$1, FLAG
	jle	.L39
	ALIGN_3

	movss	-32 * SIZE(X), %xmm0
	movss	%xmm0, 	-32 * SIZE(Y)
	ALIGN_3

.L39:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L40:
	movaps	-35 * SIZE(X), %xmm0

	movq	M,  %rax
	sarq	$4, %rax
	jle	.L43

	movaps	-31 * SIZE(X), %xmm1
	movaps	-27 * SIZE(X), %xmm2
	movaps	-23 * SIZE(X), %xmm3
	movaps	-19 * SIZE(X), %xmm4
	movaps	-15 * SIZE(X), %xmm5
	movaps	-11 * SIZE(X), %xmm6
	movaps	 -7 * SIZE(X), %xmm7
	movaps	 -3 * SIZE(X), %xmm8

	decq	%rax
	jle .L42
	ALIGN_3

.L41:
	movaps	%xmm1, %xmm9
	palignr	$12, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)
	movaps	  1 * SIZE(X), %xmm1

	movaps	%xmm2, %xmm10
	palignr	$12, %xmm9, %xmm2
	movaps	%xmm2, -28 * SIZE(Y)
	movaps	  5 * SIZE(X), %xmm2

	movaps	%xmm3, %xmm11
	palignr	$12, %xmm10, %xmm3
	movaps	%xmm3, -24 * SIZE(Y)
	movaps	  9 * SIZE(X), %xmm3

	movaps	%xmm4, %xmm12
	palignr	$12, %xmm11, %xmm4
	movaps	%xmm4, -20 * SIZE(Y)
	movaps	 13 * SIZE(X), %xmm4

	movaps	%xmm5, %xmm13
	palignr	$12, %xmm12, %xmm5
	movaps	%xmm5, -16 * SIZE(Y)
	movaps	 17 * SIZE(X), %xmm5

	movaps	%xmm6, %xmm14
	palignr	$12, %xmm13, %xmm6
	movaps	%xmm6, -12 * SIZE(Y)
	movaps	 21 * SIZE(X), %xmm6

	movaps	%xmm7, %xmm15
	palignr	$12, %xmm14, %xmm7
	movaps	%xmm7,  -8 * SIZE(Y)
	movaps	 25 * SIZE(X), %xmm7

	movaps	%xmm8, %xmm0
	palignr	$12, %xmm15, %xmm8
	movaps	%xmm8,  -4 * SIZE(Y)
	subq	$-32 * SIZE, Y
	movaps	 29 * SIZE(X), %xmm8
	subq	$-32 * SIZE, X

	subq	$1, %rax
	jg,pt	.L41
	ALIGN_3

.L42:
	movaps	%xmm1, %xmm9
	palignr	$12, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)

	movaps	%xmm2, %xmm10
	palignr	$12, %xmm9, %xmm2
	movaps	%xmm2, -28 * SIZE(Y)

	movaps	%xmm3, %xmm11
	palignr	$12, %xmm10, %xmm3
	movaps	%xmm3, -24 * SIZE(Y)

	movaps	%xmm4, %xmm12
	palignr	$12, %xmm11, %xmm4
	movaps	%xmm4, -20 * SIZE(Y)

	movaps	%xmm5, %xmm13
	palignr	$12, %xmm12, %xmm5
	movaps	%xmm5, -16 * SIZE(Y)

	movaps	%xmm6, %xmm14
	palignr	$12, %xmm13, %xmm6
	movaps	%xmm6, -12 * SIZE(Y)

	movaps	%xmm7, %xmm15
	palignr	$12, %xmm14, %xmm7
	movaps	%xmm7,  -8 * SIZE(Y)

	movaps	%xmm8, %xmm0
	palignr	$12, %xmm15, %xmm8
	movaps	%xmm8,  -4 * SIZE(Y)

	subq	$-32 * SIZE, X
	subq	$-32 * SIZE, Y
	ALIGN_3

.L43:
	testq	$8, M
	jle	.L44
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm1
	movaps	-27 * SIZE(X), %xmm2
	movaps	-23 * SIZE(X), %xmm3
	movaps	-19 * SIZE(X), %xmm4

	movaps	%xmm1, %xmm5
	movaps	%xmm2, %xmm6

	palignr	$12, %xmm0, %xmm1
	palignr	$12, %xmm5, %xmm2

	movaps	%xmm3, %xmm7
	movaps	%xmm4, %xmm0

	palignr	$12, %xmm6, %xmm3
	palignr	$12, %xmm7, %xmm4

	movaps	%xmm1, -32 * SIZE(Y)
	movaps	%xmm2, -28 * SIZE(Y)
	movaps	%xmm3, -24 * SIZE(Y)
	movaps	%xmm4, -20 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L44:
	testq	$4, M
	jle	.L45
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm1
	movaps	-27 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm3
	movaps	%xmm2, %xmm4

	palignr	$12, %xmm0, %xmm1
	palignr	$12, %xmm3, %xmm2
	movaps	%xmm4, %xmm0

	movaps	%xmm1, -32 * SIZE(Y)
	movaps	%xmm2, -28 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L45:
	testq	$2, M
	jle	.L46
	ALIGN_3

	movaps	-31 * SIZE(X), %xmm1
	palignr	$12, %xmm0, %xmm1
	movaps	%xmm1, -32 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L46:
	testq	$1, M
	jle	.L47
	ALIGN_3

	movsd	-32 * SIZE(X), %xmm0
	movsd	%xmm0, 	-32 * SIZE(Y)
	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L47:
	testq	$1, FLAG
	jle	.L49
	ALIGN_3

	movss	-32 * SIZE(X), %xmm0
	movss	%xmm0, 	-32 * SIZE(Y)
	ALIGN_3

.L49:
	xorq	%rax,%rax

	RESTOREREGISTERS

	ret
	ALIGN_3

.L80:
	addq	$-32 * SIZE, X
	addq	$-32 * SIZE, Y

	movq	M,  %rax
	sarq	$3, %rax
	jle	.L85
	ALIGN_3

.L81:
	movsd	0 * SIZE(X), %xmm0
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm3
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm4
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm5
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm6
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm7
	addq	INCX, X

	movsd	%xmm0, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm1, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm2, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm3, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm4, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm5, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm6, 0 * SIZE(Y)
	addq	INCY, Y
	movsd	%xmm7, 0 * SIZE(Y)
	addq	INCY, Y

	decq	%rax
	jg	.L81
	ALIGN_3

.L85:
	movq	M,  %rax
	andq	$7, %rax
	jle	.L87
	ALIGN_3

.L86:
	movsd	(X), %xmm0
	addq	INCX, X
	movsd	%xmm0, (Y)
	addq	INCY, Y
	decq	%rax
	jg	.L86
	ALIGN_3

.L87:
	xorq	%rax, %rax

	RESTOREREGISTERS

	ret

	EPILOGUE
