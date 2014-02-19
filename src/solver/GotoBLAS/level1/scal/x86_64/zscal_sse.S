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
#else
#define M	ARG1
#define X	ARG2
#define INCX	ARG3
#endif

#define XX	%r10
#define FLAG	%r11
#define I	%rax

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movaps	%xmm3, %xmm0
	movsd	40(%rsp), %xmm1
	movq	48(%rsp), X
	movq	56(%rsp), INCX
#endif

	SAVEREGISTERS
	
	salq	$ZBASE_SHIFT, INCX
	xor	FLAG, FLAG

	testq	M, M
	jle	.L999

	pxor	%xmm15, %xmm15
	comiss	%xmm0, %xmm15
	jne	.L100		# Alpha_r != ZERO

	comiss	%xmm1, %xmm15
	jne	.L100		# Alpha_i != ZERO

/* Alpha == ZERO */
	cmpq	$2 * SIZE, INCX
	jne	.L50

/* INCX == 1 */
	cmpq	$3, M
	jle	.L13

	testq	$4, X
	je	.L05
	movss	%xmm15, 0 * SIZE(X)
	addq	$SIZE, X
	movq	$1, FLAG
	decq	M
	ALIGN_3

.L05:
	testq	$8, X
	je	.L06

	movsd	%xmm15, 0 * SIZE(X)
	addq	$2 * SIZE, X
	subq	$1, M
	ALIGN_3
.L06:

/* Aligned Mode */
	movq	M,  I	# rcx = n
	sarq	$3, I
	jle	.L12
	ALIGN_4

.L11:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movaps	%xmm15,  0 * SIZE(X)
	movaps	%xmm15,  4 * SIZE(X)
	movaps	%xmm15,  8 * SIZE(X)
	movaps	%xmm15, 12 * SIZE(X)
	addq	$16 * SIZE, X
	decq	I
	jg	.L11
	ALIGN_4

.L12:
	testq	$7, M
	je	.L19
	testq	$4, M
	je	.L13

	movaps	%xmm15,  0 * SIZE(X)
	movaps	%xmm15,  4 * SIZE(X)
	addq	$8 * SIZE, X
	ALIGN_3

.L13:
	testq  $2, M
	je    .L14

	movlps	%xmm15,  0 * SIZE(X)
	movhps	%xmm15,  2 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L14:
	testq  $1, M
	je    .L19

	movlps	%xmm15,  0 * SIZE(X)
	addq	$2 * SIZE, X
	ALIGN_3

.L19:
	testq  $1, FLAG
	je    .L999

	movss	%xmm15, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* incx != 1 */
.L50:
	movq	M,  I		# rcx = n
	sarq	$2, I
	jle	.L52
	ALIGN_4

.L51:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	decq	I
	jg	.L51
	ALIGN_4

.L52:
	testq	$3, M
	je	.L999

	testq	$2, M
	je	.L53

	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	ALIGN_3

.L53:
	testq	$1, M
	je	.L999

	movsd	%xmm15, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* Alpha != ZERO */

.L100:
	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	subps	%xmm1, %xmm15
	unpcklps  %xmm1, %xmm15
	movaps	  %xmm15, %xmm1

	cmpq	$2 * SIZE, INCX
	jne	.L150

	cmpq	$4, M
	jle	.L120

	testq	$7, X
	jne	.L120		# Unaligned Mode

	testq	$8, X
	je	.L105
	movsd	 0 * SIZE(X), %xmm2
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	addq	$2 * SIZE, X
	decq	M
	ALIGN_3
.L105:

/* Aligned Mode */
.L110:
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L112
	ALIGN_4

.L111:
#ifdef HAVE_3DNOW
	prefetchw	32 * SIZE(X)
#endif
	movaps	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	movaps	 4 * SIZE(X), %xmm4
	movaps	 %xmm4, %xmm5
	shufps	 $0xb1, %xmm4, %xmm5
	mulps	 %xmm0, %xmm4
	movaps	 8 * SIZE(X), %xmm6
	movaps	 %xmm6, %xmm7
	shufps	 $0xb1, %xmm6, %xmm7
	mulps	 %xmm0, %xmm6
	movaps	 12 * SIZE(X), %xmm8
	movaps	 %xmm8, %xmm9
	shufps	 $0xb1, %xmm8, %xmm9
	mulps	 %xmm0, %xmm8

	mulps	 %xmm1, %xmm3
	mulps	 %xmm1, %xmm5
	mulps	 %xmm1, %xmm7
	mulps	 %xmm1, %xmm9
	addps	 %xmm3, %xmm2
	addps	 %xmm5, %xmm4
	addps	 %xmm7, %xmm6
	addps	 %xmm9, %xmm8
	movaps	%xmm2,  0 * SIZE(X)
	movaps	%xmm4,  4 * SIZE(X)
	movaps	%xmm6,   8 * SIZE(X)
	movaps	%xmm8,  12 * SIZE(X)

	addq	$16 * SIZE, X
	decq	I
	jg	.L111
	ALIGN_4

.L112:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L113

	movaps	 0 * SIZE(X), %xmm2
	movaps	 4 * SIZE(X), %xmm4
	movaps	 %xmm2, %xmm3
	movaps	 %xmm4, %xmm5
	shufps	 $0xb1, %xmm2, %xmm3
	shufps	 $0xb1, %xmm4, %xmm5
	mulps	 %xmm0, %xmm2
	mulps	 %xmm0, %xmm4
	mulps	 %xmm1, %xmm3
	mulps	 %xmm1, %xmm5
	addps	 %xmm3, %xmm2
	addps	 %xmm5, %xmm4
	movaps	%xmm2,  0 * SIZE(X)
	movaps	%xmm4,  4 * SIZE(X)
	addq	$8 * SIZE, X
	ALIGN_3

.L113:
	testq	$2, M
	je	.L114

	movaps	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movaps	%xmm2,  0 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L114:
	testq	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	jmp	.L999
	ALIGN_3


/* Unaligned Mode */
.L120:
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L122
	ALIGN_4

.L121:
#ifdef HAVE_3DNOW	
	prefetchw	96 * SIZE(X)
#endif
	movsd	  0 * SIZE(X), %xmm2
	movhps	  2 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	movsd	  4 * SIZE(X), %xmm4
	movhps	  6 * SIZE(X), %xmm4
	movaps	 %xmm4, %xmm5
	shufps	 $0xb1, %xmm4, %xmm5
	mulps	 %xmm0, %xmm4
	movsd	  8 * SIZE(X), %xmm6
	movhps	 10 * SIZE(X), %xmm6
	movaps	 %xmm6, %xmm7
	shufps	 $0xb1, %xmm6, %xmm7
	mulps	 %xmm0, %xmm6
	movsd	 12 * SIZE(X), %xmm8
	movhps	 14 * SIZE(X), %xmm8
	movaps	 %xmm8, %xmm9
	shufps	 $0xb1, %xmm8, %xmm9
	mulps	 %xmm0, %xmm8

	mulps	 %xmm1, %xmm3
	mulps	 %xmm1, %xmm5
	mulps	 %xmm1, %xmm7
	mulps	 %xmm1, %xmm9
	addps	 %xmm3, %xmm2
	addps	 %xmm5, %xmm4
	addps	 %xmm7, %xmm6
	addps	 %xmm9, %xmm8
	movsd	%xmm2,   0 * SIZE(X)
	movhps	%xmm2,   2 * SIZE(X)
	movsd	%xmm4,   4 * SIZE(X)
	movhps	%xmm4,   6 * SIZE(X)
	movsd	%xmm6,   8 * SIZE(X)
	movhps	%xmm6,  10 * SIZE(X)
	movsd	%xmm8,  12 * SIZE(X)
	movhps	%xmm8,  14 * SIZE(X)
	addq	$16 * SIZE, X
	decq	I
	jg	.L121
	ALIGN_4

.L122:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L123
	movsd	 0 * SIZE(X), %xmm2
	movhps	 2 * SIZE(X), %xmm2
	movsd	 4 * SIZE(X), %xmm4
	movhps	 6 * SIZE(X), %xmm4
	movaps	 %xmm2, %xmm3
	movaps	 %xmm4, %xmm5
	shufps	 $0xb1, %xmm2, %xmm3
	shufps	 $0xb1, %xmm4, %xmm5
	mulps	 %xmm0, %xmm2
	mulps	 %xmm0, %xmm4
	mulps	 %xmm1, %xmm3
	mulps	 %xmm1, %xmm5
	addps	 %xmm3, %xmm2
	addps	 %xmm5, %xmm4
	movsd	%xmm2,  0 * SIZE(X)
	movhps	%xmm2,  2 * SIZE(X)
	movsd	%xmm4,  4 * SIZE(X)
	movhps	%xmm4,  6 * SIZE(X)
	addq	$8 * SIZE, X
	ALIGN_3

.L123:
	testq	$2, M
	je	.L124
	movsd	 0 * SIZE(X), %xmm2
	movhps	 2 * SIZE(X), %xmm2
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	movhps	%xmm2,  2 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L124:
	testq	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	ALIGN_3
	jmp	.L999
	ALIGN_4

/* incx != 1 */

.L150:
	movq	X, XX

	movq	M,  I		# rcx = n
	sarq	$2, I		# (n >> 3)
	jle	.L152
	ALIGN_4

.L151:
	movsd	 0 * SIZE(X), %xmm2
	addq	 INCX, X
	movhps	 0 * SIZE(X), %xmm2
	addq	 INCX, X
	movsd	 0 * SIZE(X), %xmm4
	addq	 INCX, X
	movhps	 0 * SIZE(X), %xmm4
	addq	 INCX, X
	movaps	 %xmm2, %xmm3
	movaps	 %xmm4, %xmm5
	shufps	 $0xb1, %xmm2, %xmm3
	shufps	 $0xb1, %xmm4, %xmm5
	mulps	 %xmm0, %xmm2
	mulps	 %xmm0, %xmm4
	mulps	 %xmm1, %xmm3
	mulps	 %xmm1, %xmm5
	addps	 %xmm3, %xmm2
	addps	 %xmm5, %xmm4
	movsd	%xmm2,  0 * SIZE(XX)
	addq	 INCX, XX
	movhps	%xmm2,  0 * SIZE(XX)
	addq	 INCX, XX
	movsd	%xmm4,  0 * SIZE(XX)
	addq	 INCX, XX
	movhps	%xmm4,  0 * SIZE(XX)
	addq	 INCX, XX
	decq	I
	jg	.L151
	ALIGN_4

.L152:
	testq	$3, M
	je	.L999

	testq	$2, M
	je	.L153

	movsd	 0 * SIZE(X), %xmm2
	addq	 INCX, X
	movhps	 0 * SIZE(X), %xmm2
	addq	 INCX, X
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(XX)
	addq	 INCX, XX
	movhps	%xmm2,  0 * SIZE(XX)
	addq	 INCX, XX
	ALIGN_3

.L153:
	testq	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movsd	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	ALIGN_4

.L999:
	xorq	%rax, %rax

	RESTOREREGISTERS
	
	ret

	EPILOGUE
