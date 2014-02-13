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
#define STACK_ALPHA_R	16 + STACK + ARGS(%esp)
#define STACK_ALPHA_I	20 + STACK + ARGS(%esp)
#define STACK_X		24 + STACK + ARGS(%esp)
#define STACK_INCX	28 + STACK + ARGS(%esp)

#define M	%ebx
#define X	%ecx
#define INCX	%edx
#define I	%esi
#define XX	%edi
#define FLAG	%ebp

#ifdef PENTIUM4
#define PREFETCHSIZE 88
#endif

#ifdef OPTERON
#define PREFETCHSIZE 80
#define movsd	     movlps
#endif

	PROLOGUE

	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%ebp

	PROFCODE

	movl	STACK_M,     M
	movl	STACK_X,     X
	movl	STACK_INCX,  INCX

	movss	STACK_ALPHA_R, %xmm0
	movss	STACK_ALPHA_I, %xmm1

	sall	$ZBASE_SHIFT, INCX
	xor	FLAG, FLAG

	pxor	%xmm7, %xmm7
	comiss	%xmm0, %xmm7
	jne	.L100		# Alpha_r != ZERO

	comiss	%xmm1, %xmm7
	jne	.L100		# Alpha_i != ZERO


/* Alpha == ZERO */
	cmpl	$2 * SIZE, INCX
	jne	.L50

/* INCX == 1 */
	cmpl	$4, M
	jle	.L20

	testl	$3, X
	jne	.L20		# Unaligned Mode

	testl	$4, X
	je	.L05
	movss	%xmm7, 0 * SIZE(X)
	addl	$SIZE, X
	movl	$1, FLAG
	decl	M
	ALIGN_3
.L05:

	testl	$8, X
	je	.L06

	movsd	%xmm7, 0 * SIZE(X)
	addl	$2 * SIZE, X
	subl	$1, M
	ALIGN_3
.L06:

/* Aligned Mode */
	movl	M,  I	# rcx = n
	sarl	$3, I
	jle	.L12
	ALIGN_4

.L11:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movaps	%xmm7,  0 * SIZE(X)
	movaps	%xmm7,  4 * SIZE(X)
	movaps	%xmm7,  8 * SIZE(X)
	movaps	%xmm7, 12 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L11
	ALIGN_4

.L12:
	testl	$7, M
	je	.L19
	testl	$4, M
	je	.L13

	movaps	%xmm7,  0 * SIZE(X)
	movaps	%xmm7,  4 * SIZE(X)
	addl	$8 * SIZE, X
	ALIGN_3

.L13:
	testl	$2, M
	je    .L14

	movaps	%xmm7,  0 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L14:
	testl	$1, M
	je    .L19
	movsd	%xmm7,  0 * SIZE(X)
	addl	$2 * SIZE, X
	ALIGN_3

.L19:
	testl	$1, FLAG
	je    .L999

	movss	%xmm7, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4


/* Unaligned Mode */
.L20:
	movl	M,  I	# rcx = n
	sarl	$3, I
	jle	.L22
	ALIGN_4

.L21:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movsd	%xmm7,  0 * SIZE(X)
	movsd	%xmm7,  2 * SIZE(X)
	movsd	%xmm7,  4 * SIZE(X)
	movsd	%xmm7,  6 * SIZE(X)
	movsd	%xmm7,  8 * SIZE(X)
	movsd	%xmm7, 10 * SIZE(X)
	movsd	%xmm7, 12 * SIZE(X)
	movsd	%xmm7, 14 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L21
	ALIGN_4

.L22:
	testl	$7, M
	je	.L999

	testl	$4, M
	je	.L23
	movsd	%xmm7,  0 * SIZE(X)
	movsd	%xmm7,  2 * SIZE(X)
	movsd	%xmm7,  4 * SIZE(X)
	movsd	%xmm7,  6 * SIZE(X)
	addl	$8 * SIZE, X

	ALIGN_3
.L23:
	testl	$2, M
	je	.L24

	movsd	%xmm7, 0 * SIZE(X)
	movsd	%xmm7, 2 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L24:
	testl	$1, M
	je	.L999

	movsd	%xmm7, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4


/* incx != 1 */
.L50:
	movl	M,  I		# rcx = n
	sarl	$2, I
	jle	.L52
	ALIGN_4

.L51:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	decl	I
	jg	.L51
	ALIGN_4

.L52:
	testl	$3, M
	je	.L999

	testl	$2, M
	je	.L53

	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	movsd	%xmm7, 0 * SIZE(X)
	addl	INCX, X
	ALIGN_3

.L53:
	testl	$1, M
	je	.L999

	movsd	%xmm7, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* Alpha != ZERO */

.L100:
	shufps	$0, %xmm0, %xmm0
	shufps	$0, %xmm1, %xmm1
	subps	%xmm1,  %xmm7
	unpcklps  %xmm1, %xmm7
	movaps	  %xmm7, %xmm1

	cmpl	$2 * SIZE, INCX
	jne	.L150

	cmpl	$4, M
	jle	.L120

	testl	$7, X
	jne	.L120		# Unaligned Mode

	testl	$8, X
	je	.L105
	movsd	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	addl	$2 * SIZE, X
	decl	M
	ALIGN_3
.L105:

/* Aligned Mode */
.L110:
	movl	M,  I		# rcx = n
	sarl	$3, I
	jle	.L112
	ALIGN_4

.L111:
#ifdef HAVE_3DNOW
	prefetchw	32 * SIZE(X)
#endif
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

	movaps	 8 * SIZE(X), %xmm2
	movaps	12 * SIZE(X), %xmm4

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

	movaps	%xmm2,  8 * SIZE(X)
	movaps	%xmm4, 12 * SIZE(X)

	addl	$16 * SIZE, X
	decl	I
	jg	.L111
	ALIGN_4

.L112:
	testl	$7, M
	je	.L999

	testl	$4, M
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
	addl	$8 * SIZE, X
	ALIGN_3

.L113:
	testl	$2, M
	je	.L114

	movaps	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movaps	%xmm2,  0 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L114:
	testl	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	jmp	.L999
	ALIGN_3


/* Unaligned Mode */
.L120:
	movl	M,  I		# rcx = n
	sarl	$3, I
	jle	.L122
	ALIGN_4

.L121:
#ifdef HAVE_3DNOW	
	prefetchw	96 * SIZE(X)
#endif
	movsd	  0 * SIZE(X), %xmm2
	movhps	  2 * SIZE(X), %xmm2
	movsd	  4 * SIZE(X), %xmm4
	movhps	  6 * SIZE(X), %xmm4

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

	movsd	%xmm2,   0 * SIZE(X)
	movhps	%xmm2,   2 * SIZE(X)
	movsd	%xmm4,   4 * SIZE(X)
	movhps	%xmm4,   6 * SIZE(X)

	movsd	  8 * SIZE(X), %xmm2
	movhps	 10 * SIZE(X), %xmm2
	movsd	 12 * SIZE(X), %xmm4
	movhps	 14 * SIZE(X), %xmm4

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

	movsd	%xmm2,   8 * SIZE(X)
	movhps	%xmm2,  10 * SIZE(X)
	movsd	%xmm4,  12 * SIZE(X)
	movhps	%xmm4,  14 * SIZE(X)

	addl	$16 * SIZE, X
	decl	I
	jg	.L121
	ALIGN_4

.L122:
	testl	$7, M
	je	.L999

	testl	$4, M
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
	addl	$8 * SIZE, X
	ALIGN_3

.L123:
	testl	$2, M
	je	.L124
	movsd	 0 * SIZE(X), %xmm2
	movhps	 2 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	movhps	%xmm2,  2 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L124:
	testl	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
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
	movl	X, XX

	movl	M,  I		# rcx = n
	sarl	$2, I		# (n >> 3)
	jle	.L152
	ALIGN_4

.L151:
	movsd	 0 * SIZE(X), %xmm2
	addl	 INCX, X
	movhps	 0 * SIZE(X), %xmm2
	addl	 INCX, X
	movsd	 0 * SIZE(X), %xmm4
	addl	 INCX, X
	movhps	 0 * SIZE(X), %xmm4
	addl	 INCX, X
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
	addl	 INCX, XX
	movhps	%xmm2,  0 * SIZE(XX)
	addl	 INCX, XX
	movsd	%xmm4,  0 * SIZE(XX)
	addl	 INCX, XX
	movhps	%xmm4,  0 * SIZE(XX)
	addl	 INCX, XX
	decl	I
	jg	.L151
	ALIGN_4

.L152:
	testl	$3, M
	je	.L999

	testl	$2, M
	je	.L153

	movsd	 0 * SIZE(X), %xmm2
	addl	 INCX, X
	movhps	 0 * SIZE(X), %xmm2
	addl	 INCX, X
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(XX)
	addl	 INCX, XX
	movhps	%xmm2,  0 * SIZE(XX)
	addl	 INCX, XX
	ALIGN_3

.L153:
	testl	$1, M
	je	.L999

	movsd	 0 * SIZE(X), %xmm2
	movaps	 %xmm2, %xmm3
	shufps	 $0xb1, %xmm2, %xmm3
	mulps	 %xmm0, %xmm2
	mulps	 %xmm1, %xmm3
	addps	 %xmm3, %xmm2
	movsd	%xmm2,  0 * SIZE(X)
	ALIGN_4

.L999:
	xorl	%eax, %eax
	popl	%ebp
	popl	%ebx
	popl	%esi
	popl	%edi

	ret

	EPILOGUE
