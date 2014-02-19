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

#define PREFETCH	prefetcht0
#define PREFETCH_SIZE	(8 * 2)

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
	comisd	%xmm0, %xmm15
	jne	.L100		# Alpha_r != ZERO

	comisd	%xmm1, %xmm15
	jne	.L100		# Alpha_i != ZERO


/* Alpha == ZERO */
	cmpq	$2 * SIZE, INCX
	jne	.L50

/* INCX == 1 */
	testq	$SIZE, X
	je	.L05

	movsd	%xmm15, 0 * SIZE(X)
	addq	$SIZE, X
	movq	$1, FLAG
	decq	M
	jle	.L19
	ALIGN_3
.L05:

/* Aligned Mode */
	movq	M,  I	# rcx = n
	sarq	$3, I
	jle	.L12
	ALIGN_4

.L11:
	movapd	%xmm15,  0 * SIZE(X)
	movapd	%xmm15,  2 * SIZE(X)
	movapd	%xmm15,  4 * SIZE(X)
	movapd	%xmm15,  6 * SIZE(X)

	movapd	%xmm15,  8 * SIZE(X)
	movapd	%xmm15, 10 * SIZE(X)
	movapd	%xmm15, 12 * SIZE(X)
	movapd	%xmm15, 14 * SIZE(X)

	addq	$16 * SIZE, X
	decq	I
	jg	.L11
	ALIGN_4

.L12:
	testq	$4, M
	je	.L13

	movapd	%xmm15,  0 * SIZE(X)
	movapd	%xmm15,  2 * SIZE(X)
	movapd	%xmm15,  4 * SIZE(X)
	movapd	%xmm15,  6 * SIZE(X)
	addq	$8 * SIZE, X
	ALIGN_3

.L13:
	testq  $2, M
	je    .L14

	movapd	%xmm15,  0 * SIZE(X)
	movapd	%xmm15,  2 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L14:
	testq  $1, M
	je    .L19
	movapd	%xmm15,  0 * SIZE(X)
	addq	$2 * SIZE, X
	ALIGN_3

.L19:
	testq  $1, FLAG
	je    .L999

	movsd	%xmm15, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* incx != 1 */
.L50:
	testq	$SIZE, X
	jne	.L60

/* Aligned Mode */
	movq	M,  I		# rcx = n
	sarq	$2, I
	jle	.L52
	ALIGN_4

.L51:	
	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	decq	I
	jg	.L51
	ALIGN_4

.L52:
	testq	$3, M
	je	.L999

	testq	$2, M
	je	.L53

	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	movapd	%xmm15, 0 * SIZE(X)
	addq	INCX, X
	ALIGN_3

.L53:
	testq	$1, M
	je	.L999

	movapd	%xmm15, 0 * SIZE(X)
	jmp	.L999
	ALIGN_4


/* Unaligned Mode */
.L60:
	movq	M,  I		# rcx = n
	sarq	$2, I
	jle	.L62
	ALIGN_4

.L61:
	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	decq	I
	jg	.L61
	ALIGN_4

.L62:
	testq	$3, M
	je	.L999

	testq	$2, M
	je	.L63

	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	addq	INCX, X
	ALIGN_3

.L63:
	testq	$1, M
	je	.L999

	movsd	%xmm15, 0 * SIZE(X)
	movsd	%xmm15, 1 * SIZE(X)
	jmp	.L999
	ALIGN_4

/* Alpha != ZERO */
.L100:
	movddup	 %xmm0,  %xmm14		# a    a
	pxor	 %xmm15, %xmm15		#  0   0
	subsd	 %xmm1,  %xmm15		#  0  -b
	unpcklpd %xmm1,  %xmm15		#  b  -b

	testq	$SIZE, X
	jne	.L200

/* Aligned Mode */

	cmpq	$2 * SIZE, INCX
	jne	.L120

.L110:
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L115
	ALIGN_4

.L111:
	PREFETCH	(PREFETCH_SIZE + 0) * SIZE(X)

	movapd	 0 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 2 * SIZE(X), %xmm2
	movsd	 3 * SIZE(X), %xmm3
	movhpd	 2 * SIZE(X), %xmm3

	movapd	 4 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movapd	 6 * SIZE(X), %xmm6
	movsd	 7 * SIZE(X), %xmm7
	movhpd	 6 * SIZE(X), %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  0 * SIZE(X)
	movapd	%xmm2,  2 * SIZE(X)
	movapd	%xmm4,  4 * SIZE(X)
	movapd	%xmm6,  6 * SIZE(X)

	PREFETCH	(PREFETCH_SIZE + 8) * SIZE(X)

	movapd	 8 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	10 * SIZE(X), %xmm2
	movsd	11 * SIZE(X), %xmm3
	movhpd	10 * SIZE(X), %xmm3
	movapd	12 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movapd	14 * SIZE(X), %xmm6
	movsd	15 * SIZE(X), %xmm7
	movhpd	14 * SIZE(X), %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3

	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  8 * SIZE(X)
	movapd	%xmm2, 10 * SIZE(X)
	movapd	%xmm4, 12 * SIZE(X)
	movapd	%xmm6, 14 * SIZE(X)

	subq	$-16 * SIZE, X
	decq	I
	jg	.L111
	ALIGN_4

.L115:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L116

	movapd	 0 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 2 * SIZE(X), %xmm2
	movsd	 3 * SIZE(X), %xmm3
	movhpd	 2 * SIZE(X), %xmm3

	movapd	 4 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movapd	 6 * SIZE(X), %xmm6
	movsd	 7 * SIZE(X), %xmm7
	movhpd	 6 * SIZE(X), %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  0 * SIZE(X)
	movapd	%xmm2,  2 * SIZE(X)
	movapd	%xmm4,  4 * SIZE(X)
	movapd	%xmm6,  6 * SIZE(X)

	addq	$8 * SIZE, X
	ALIGN_3

.L116:
	testq	$2, M
	je	.L117

	movapd	 0 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movapd	 2 * SIZE(X), %xmm2
	movsd	 3 * SIZE(X), %xmm3
	movhpd	 2 * SIZE(X), %xmm3

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2

	movapd	%xmm0,  0 * SIZE(X)
	movapd	%xmm2,  2 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L117:
	testq	$1, M
	je	.L999

	movapd	 0 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm1,  %xmm0
	movapd	%xmm0,  0 * SIZE(X)

	jmp	.L999
	ALIGN_3

.L120:
	movq	X, XX
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L125
	ALIGN_4

.L121:
	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movapd	 (X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movapd	 (X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movapd	 (X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  (XX)
	addq	INCX, XX
	movapd	%xmm2,  (XX)
	addq	INCX, XX
	movapd	%xmm4,  (XX)
	addq	INCX, XX
	movapd	%xmm6,  (XX)
	addq	INCX, XX

	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movapd	 (X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movapd	 (X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movapd	 (X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  (XX)
	addq	INCX, XX
	movapd	%xmm2,  (XX)
	addq	INCX, XX
	movapd	%xmm4,  (XX)
	addq	INCX, XX
	movapd	%xmm6,  (XX)
	addq	INCX, XX

	decq	I
	jg	.L121
	ALIGN_4

.L125:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L126

	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movapd	 (X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movapd	 (X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movapd	 (X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movapd	%xmm0,  (XX)
	addq	INCX, XX
	movapd	%xmm2,  (XX)
	addq	INCX, XX
	movapd	%xmm4,  (XX)
	addq	INCX, XX
	movapd	%xmm6,  (XX)
	addq	INCX, XX
	ALIGN_3

.L126:
	testq	$2, M
	je	.L127

	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movapd	 (X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2

	movapd	%xmm0,  (XX)
	addq	INCX, XX
	movapd	%xmm2,  (XX)
	addq	INCX, XX
	ALIGN_3

.L127:
	testq	$1, M
	je	.L999

	movapd	 (X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm1,  %xmm0
	movapd	%xmm0,  (XX)
	jmp	.L999
	ALIGN_3

/* Unaligned */

.L200:
	cmpq	$2 * SIZE, INCX
	jne	.L220

.L210:
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L215
	ALIGN_4

.L211:
	movsd	 0 * SIZE(X), %xmm0
	movhpd	 1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	 2 * SIZE(X), %xmm2
	movhpd	 3 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	movsd	 4 * SIZE(X), %xmm4
	movhpd	 5 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movsd	 6 * SIZE(X), %xmm6
	movhpd	 7 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  0 * SIZE(X)
	movhpd	%xmm0,  1 * SIZE(X)
	movlpd	%xmm2,  2 * SIZE(X)
	movhpd	%xmm2,  3 * SIZE(X)
	movlpd	%xmm4,  4 * SIZE(X)
	movhpd	%xmm4,  5 * SIZE(X)
	movlpd	%xmm6,  6 * SIZE(X)
	movhpd	%xmm6,  7 * SIZE(X)

	movsd	 8 * SIZE(X), %xmm0
	movhpd	 9 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	10 * SIZE(X), %xmm2
	movhpd	11 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	movsd	12 * SIZE(X), %xmm4
	movhpd	13 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movsd	14 * SIZE(X), %xmm6
	movhpd	15 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  8 * SIZE(X)
	movhpd	%xmm0,  9 * SIZE(X)
	movlpd	%xmm2, 10 * SIZE(X)
	movhpd	%xmm2, 11 * SIZE(X)
	movlpd	%xmm4, 12 * SIZE(X)
	movhpd	%xmm4, 13 * SIZE(X)
	movlpd	%xmm6, 14 * SIZE(X)
	movhpd	%xmm6, 15 * SIZE(X)

	addq	$16 * SIZE, X
	decq	I
	jg	.L211
	ALIGN_4


.L215:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L216

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	2 * SIZE(X), %xmm2
	movhpd	3 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	movsd	4 * SIZE(X), %xmm4
	movhpd	5 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	movsd	6 * SIZE(X), %xmm6
	movhpd	7 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  0 * SIZE(X)
	movhpd	%xmm0,  1 * SIZE(X)
	movlpd	%xmm2,  2 * SIZE(X)
	movhpd	%xmm2,  3 * SIZE(X)
	movlpd	%xmm4,  4 * SIZE(X)
	movhpd	%xmm4,  5 * SIZE(X)
	movlpd	%xmm6,  6 * SIZE(X)
	movhpd	%xmm6,  7 * SIZE(X)
	addq	$8 * SIZE, X
	ALIGN_3

.L216:
	testq	$2, M
	je	.L217

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	movsd	2 * SIZE(X), %xmm2
	movhpd	3 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2

	movlpd	%xmm0,  0 * SIZE(X)
	movhpd	%xmm0,  1 * SIZE(X)
	movlpd	%xmm2,  2 * SIZE(X)
	movhpd	%xmm2,  3 * SIZE(X)
	addq	$4 * SIZE, X
	ALIGN_3

.L217:
	testq	$1, M
	je	.L999

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm1,  %xmm0

	movlpd	%xmm0,  0 * SIZE(X)
	movhpd	%xmm0,  1 * SIZE(X)
	jmp	.L999
	ALIGN_3

.L220:
	movq	X, XX
	movq	M,  I		# rcx = n
	sarq	$3, I
	jle	.L225
	ALIGN_4

.L221:
	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  0 * SIZE(XX)
	movhpd	%xmm0,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm2,  0 * SIZE(XX)
	movhpd	%xmm2,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm4,  0 * SIZE(XX)
	movhpd	%xmm4,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm6,  0 * SIZE(XX)
	movhpd	%xmm6,  1 * SIZE(XX)
	addq	INCX, XX

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  0 * SIZE(XX)
	movhpd	%xmm0,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm2,  0 * SIZE(XX)
	movhpd	%xmm2,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm4,  0 * SIZE(XX)
	movhpd	%xmm4,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm6,  0 * SIZE(XX)
	movhpd	%xmm6,  1 * SIZE(XX)
	addq	INCX, XX

	decq	I
	jg	.L221
	ALIGN_4

.L225:
	testq	$7, M
	je	.L999

	testq	$4, M
	je	.L226

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm4
	movhpd	1 * SIZE(X), %xmm4
	pshufd	 $0x4e, %xmm4, %xmm5
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm6
	movhpd	1 * SIZE(X), %xmm6
	pshufd	 $0x4e, %xmm6, %xmm7
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	mulpd	%xmm14, %xmm4
	mulpd	%xmm15, %xmm5
	mulpd	%xmm14, %xmm6
	mulpd	%xmm15, %xmm7

	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2
	addpd	%xmm5,  %xmm4
	addpd	%xmm7,  %xmm6

	movlpd	%xmm0,  0 * SIZE(XX)
	movhpd	%xmm0,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm2,  0 * SIZE(XX)
	movhpd	%xmm2,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm4,  0 * SIZE(XX)
	movhpd	%xmm4,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm6,  0 * SIZE(XX)
	movhpd	%xmm6,  1 * SIZE(XX)
	addq	INCX, XX
	ALIGN_3

.L226:
	testq	$2, M
	je	.L227

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1
	addq	INCX, X
	movsd	0 * SIZE(X), %xmm2
	movhpd	1 * SIZE(X), %xmm2
	pshufd	 $0x4e, %xmm2, %xmm3
	addq	INCX, X

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	mulpd	%xmm14, %xmm2
	mulpd	%xmm15, %xmm3
	addpd	%xmm1,  %xmm0
	addpd	%xmm3,  %xmm2

	movlpd	%xmm0,  0 * SIZE(XX)
	movhpd	%xmm0,  1 * SIZE(XX)
	addq	INCX, XX
	movlpd	%xmm2,  0 * SIZE(XX)
	movhpd	%xmm2,  1 * SIZE(XX)
	addq	INCX, XX
	ALIGN_3

.L227:
	testq	$1, M
	je	.L999

	movsd	0 * SIZE(X), %xmm0
	movhpd	1 * SIZE(X), %xmm0
	pshufd	 $0x4e, %xmm0, %xmm1

	mulpd	%xmm14, %xmm0
	mulpd	%xmm15, %xmm1
	addpd	%xmm1,  %xmm0

	movlpd	%xmm0,  0 * SIZE(XX)
	movhpd	%xmm0,  1 * SIZE(XX)
	ALIGN_3

.L999:
	xorq	%rax, %rax

	RESTOREREGISTERS
	
	ret

	EPILOGUE

