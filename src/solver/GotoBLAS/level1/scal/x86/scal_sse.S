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
#define ARGS     0

#define STACK_M	 	 4 + STACK + ARGS(%esp)
#define STACK_ALPHA	16 + STACK + ARGS(%esp)
#define STACK_X		20 + STACK + ARGS(%esp)
#define STACK_INCX	24 + STACK + ARGS(%esp)

#define M	%ebx
#define X	%ecx
#define INCX	%edx
#define I	%esi
#define XX	%edi

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

	PROFCODE

	movl	STACK_M,     M
	movl	STACK_X,     X
	movl	STACK_INCX,  INCX

	movss	STACK_ALPHA, %xmm0

	pxor	%xmm1, %xmm1
	comiss	%xmm0, %xmm1
	shufps	$0, %xmm0, %xmm0

	lea	(, INCX, SIZE), INCX
	jne	.L100		# Alpha != ZERO

/* Alpha == ZERO */
	cmpl	$SIZE, INCX
	jne	.L50

/* INCX == 1 */
	cmpl	$8, M
 	jle	.L20

	testl	$3, X
	jne	.L20		# Unaligned Mode

	testl	$4, X		# aligned for quad word?
	je	.L05

	movss	%xmm1, 0 * SIZE(X)
	addl	$SIZE, X
	decl	M
	ALIGN_3
.L05:

	testl	$8, X		# aligned for quad word?
	je	.L06

	movsd	%xmm1, 0 * SIZE(X)
	addl	$2 * SIZE, X
	subl	$2, M
	ALIGN_3
.L06:
	
/* Aligned Mode */
	movl	M,  I	# rcx = n
	sarl	$4, I
	jle	.L12
	ALIGN_4

.L11:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movaps	%xmm1,  0 * SIZE(X)
	movaps	%xmm1,  4 * SIZE(X)
	movaps	%xmm1,  8 * SIZE(X)
	movaps	%xmm1, 12 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L11
	ALIGN_4

.L12:
	testl	$15, M
	je	.L999
	testl	$8, M
	je	.L13

	movaps	%xmm1,  0 * SIZE(X)
	movaps	%xmm1,  4 * SIZE(X)
	addl	$8 * SIZE, X
	ALIGN_3

.L13:
	testl  $4, M
	je    .L14

	movaps	%xmm1,  0 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L14:
	testl  $2, M
	je    .L15

	movsd	%xmm1,  0 * SIZE(X)
	addl	$2 * SIZE, X
	ALIGN_3

.L15:
	testl  $1, M
	je    .L999

	movss	%xmm1,  0 * SIZE(X)
	jmp	.L999
	ALIGN_4


/* Unaligned Mode */
.L20:
	movl	M,  I	# rcx = n
	sarl	$4, I	# (n >> 3)
	jle	.L22
	ALIGN_4

.L21:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movsd	%xmm1,  0 * SIZE(X)
	movsd	%xmm1,  2 * SIZE(X)
	movsd	%xmm1,  4 * SIZE(X)
	movsd	%xmm1,  6 * SIZE(X)
	movsd	%xmm1,  8 * SIZE(X)
	movsd	%xmm1, 10 * SIZE(X)
	movsd	%xmm1, 12 * SIZE(X)
	movsd	%xmm1, 14 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L21
	ALIGN_4

.L22:
	testl	$15, M
	je	.L999

	testl	$8, M
	je	.L23

	movsd	%xmm1, 0 * SIZE(X)
	movsd	%xmm1, 2 * SIZE(X)
	movsd	%xmm1, 4 * SIZE(X)
	movsd	%xmm1, 6 * SIZE(X)
	addl	$8 * SIZE, X
	ALIGN_3

.L23:
	testl	$4, M
	je	.L24

	movsd	%xmm1, 0 * SIZE(X)
	movsd	%xmm1, 2 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L24:
	testl	$2, M
	je	.L25

	movsd	%xmm1, 0 * SIZE(X)
	addl	$2 * SIZE, X
	ALIGN_3

.L25:
	testl	$1, M
	je	.L999

	movss	%xmm1, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4


/* incx != 1 */
.L50:
	movl	M,  I		# rcx = n
	sarl	$3, I		# (n >> 3)
	jle	.L52
	ALIGN_4

.L51:
#ifdef HAVE_3DNOW
	prefetchw	88 * SIZE(X)
#endif
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X

	decl	I
	jg	.L51
	ALIGN_4

.L52:
	testl	$7, M
	je	.L999

	testl	$4, M
	je	.L53

	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	ALIGN_3

.L53:
	testl	$2, M
	je	.L54

	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	movss	%xmm1, 0 * SIZE(X)
	addl	INCX, X
	ALIGN_3

.L54:
	testl	$1, M
	je	.L999

	movss	%xmm1, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* Alpha != ZERO */

.L100:
	cmpl	$SIZE, INCX
	jne	.L150

	cmpl	$4, M
	jle	.L122

	testl	$3, X
	jne	.L120		# Unaligned Mode

	testl	$4, X		# aligned for quad word?
	je	.L105

	movss	0 * SIZE(X), %xmm1
	mulss	%xmm0, %xmm1
	movss	%xmm1, 0 * SIZE(X)
	addl	$SIZE, X
	decl	M
	ALIGN_3
.L105:
	testl	$8, X		# aligned for quad word?
	je	.L106

	movsd	0 * SIZE(X), %xmm1
	mulps	%xmm0, %xmm1
	movsd	%xmm1, 0 * SIZE(X)
	addl	$2 * SIZE, X
	subl	$2, M
	ALIGN_3
.L106:


/* Aligned Mode */
.L110:
	movl	M,  I		# rcx = n
	sarl	$4, I
	jle	.L112
	ALIGN_4

.L111:
#ifdef HAVE_3DNOW
	prefetchw	32 * SIZE(X)
#endif
	movaps	 0 * SIZE(X), %xmm1
	movaps	 4 * SIZE(X), %xmm3
	movaps	 8 * SIZE(X), %xmm5
	movaps	12 * SIZE(X), %xmm7

	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm3
	mulps	%xmm0, %xmm5
	mulps	%xmm0, %xmm7

	movaps	%xmm1,  0 * SIZE(X)
	movaps	%xmm3,  4 * SIZE(X)
	movaps	%xmm5,  8 * SIZE(X)
	movaps	%xmm7, 12 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L111
	ALIGN_4

.L112:
	testl	$15, M
	je	.L999

	testl	$8, M
	je	.L113

	movaps	 0 * SIZE(X), %xmm1
	movaps	 4 * SIZE(X), %xmm3
	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm3
	movaps	%xmm1,  0 * SIZE(X)
	movaps	%xmm3,  4 * SIZE(X)
	addl	$8 * SIZE, X
	ALIGN_3

.L113:
	testl	$4, M
	je	.L114

	movaps	 0 * SIZE(X), %xmm1
	mulps	%xmm0, %xmm1
	movaps	%xmm1,  0 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L114:
	testl	$2, M
	je	.L115

	movsd	 0 * SIZE(X), %xmm1
	mulps	%xmm0, %xmm1
	movsd	%xmm1,  0 * SIZE(X)
	addl	$2 * SIZE, X
	ALIGN_3


.L115:
	testl	$1, M
	je	.L999

	movss	 0 * SIZE(X), %xmm1
	mulss	%xmm0, %xmm1
	movss	%xmm1,  0 * SIZE(X)
	jmp	.L999
	ALIGN_3


/* Unaligned Mode */
.L120:
	movl	M,  I		# rcx = n
	sarl	$4, I
	jle	.L122
	ALIGN_4

.L121:
#ifdef HAVE_3DNOW
	prefetchw	40 * SIZE(X)
#endif
	movsd	 0 * SIZE(X), %xmm1
	movsd	 2 * SIZE(X), %xmm2
	movsd	 4 * SIZE(X), %xmm3
	movsd	 6 * SIZE(X), %xmm4

	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm2
	mulps	%xmm0, %xmm3
	mulps	%xmm0, %xmm4

	movsd	%xmm1,  0 * SIZE(X)
	movsd	%xmm2,  2 * SIZE(X)
	movsd	%xmm3,  4 * SIZE(X)
	movsd	%xmm4,  6 * SIZE(X)

	movsd	 8 * SIZE(X), %xmm1
	movsd	10 * SIZE(X), %xmm2
	movsd	12 * SIZE(X), %xmm3
	movsd	14 * SIZE(X), %xmm4

	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm2
	mulps	%xmm0, %xmm3
	mulps	%xmm0, %xmm4

	movsd	%xmm1,  8 * SIZE(X)
	movsd	%xmm2, 10 * SIZE(X)
	movsd	%xmm3, 12 * SIZE(X)
	movsd	%xmm4, 14 * SIZE(X)
	addl	$16 * SIZE, X
	decl	I
	jg	.L121
	ALIGN_4

.L122:
	testl	$15, M
	je	.L999

	testl	$8, M
	je	.L123

	movsd	 0 * SIZE(X), %xmm1
	movsd	 2 * SIZE(X), %xmm2
	movsd	 4 * SIZE(X), %xmm3
	movsd	 6 * SIZE(X), %xmm4
	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm2
	mulps	%xmm0, %xmm3
	mulps	%xmm0, %xmm4
	movsd	%xmm1,  0 * SIZE(X)
	movsd	%xmm2,  2 * SIZE(X)
	movsd	%xmm3,  4 * SIZE(X)
	movsd	%xmm4,  6 * SIZE(X)
	addl	$8 * SIZE, X
	ALIGN_3

.L123:
	testl	$4, M
	je	.L124

	movsd	 0 * SIZE(X), %xmm1
	movsd	 2 * SIZE(X), %xmm2
	mulps	%xmm0, %xmm1
	mulps	%xmm0, %xmm2
	movsd	%xmm1,  0 * SIZE(X)
	movsd	%xmm2,  2 * SIZE(X)
	addl	$4 * SIZE, X
	ALIGN_3

.L124:
	testl	$2, M
	je	.L125

	movsd	 0 * SIZE(X), %xmm1
	mulps	%xmm0, %xmm1
	movsd	%xmm1,  0 * SIZE(X)
	addl	$2 * SIZE, X
	ALIGN_3

.L125:
	testl	$1, M
	je	.L999

	movss	 0 * SIZE(X), %xmm1
	mulss	%xmm0, %xmm1
	movss	%xmm1,  0 * SIZE(X)
	ALIGN_3
	jmp	.L999
	ALIGN_4

/* incx != 1 */

.L150:
	movl	X, XX
	movl	M,  I		# rcx = n
	sarl	$3, I		# (n >> 3)
	jle	.L152
	ALIGN_4

.L151:
#ifdef HAVE_3DNOW
	prefetchw	40 * SIZE(X)
#endif
	movss	0 * SIZE(X), %xmm1
	addl	INCX, X
	movss	0 * SIZE(X), %xmm2
	addl	INCX, X
	movss	0 * SIZE(X), %xmm3
	addl	INCX, X
	movss	0 * SIZE(X), %xmm4
	addl	INCX, X

	mulss	%xmm0, %xmm1
	mulss	%xmm0, %xmm2
	mulss	%xmm0, %xmm3
	mulss	%xmm0, %xmm4

	movss	%xmm1, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm2, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm3, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm4, 0 * SIZE(XX)
	addl	INCX, XX

	movss	0 * SIZE(X), %xmm1
	addl	INCX, X
	movss	0 * SIZE(X), %xmm2
	addl	INCX, X
	movss	0 * SIZE(X), %xmm3
	addl	INCX, X
	movss	0 * SIZE(X), %xmm4
	addl	INCX, X

	mulss	%xmm0, %xmm1
	mulss	%xmm0, %xmm2
	mulss	%xmm0, %xmm3
	mulss	%xmm0, %xmm4

	movss	%xmm1, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm2, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm3, 0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm4, 0 * SIZE(XX)
	addl	INCX, XX

	decl	I
	jg	.L151
	ALIGN_4

.L152:
	testl	$7, M
	je	.L999

	testl	$4, M
	je	.L153

	movss	 0 * SIZE(X), %xmm1
	addl	INCX, X
	movss	 0 * SIZE(X), %xmm2
	addl	INCX, X
	movss	 0 * SIZE(X), %xmm3
	addl	INCX, X
	movss	 0 * SIZE(X), %xmm4
	addl	INCX, X

	mulss	%xmm0, %xmm1
	mulss	%xmm0, %xmm2
	mulss	%xmm0, %xmm3
	mulss	%xmm0, %xmm4

	movss	%xmm1,  0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm2,  0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm3,  0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm4,  0 * SIZE(XX)
	addl	INCX, XX
	ALIGN_3

.L153:
	testl	$2, M
	je	.L154

	movss	 0 * SIZE(X), %xmm1
	addl	INCX, X
	movss	 0 * SIZE(X), %xmm2
	addl	INCX, X

	mulss	%xmm0, %xmm1
	mulss	%xmm0, %xmm2

	movss	%xmm1,  0 * SIZE(XX)
	addl	INCX, XX
	movss	%xmm2,  0 * SIZE(XX)
	addl	INCX, XX
	ALIGN_3

.L154:
	testl	$1, M
	je	.L999

	movss	 0 * SIZE(X), %xmm1
	mulss	%xmm0, %xmm1
	movss	%xmm1,  0 * SIZE(X)
	ALIGN_4

.L999:
	xorl	%eax, %eax

	popl	%ebx
	popl	%esi
	popl	%edi
	ret

	EPILOGUE
