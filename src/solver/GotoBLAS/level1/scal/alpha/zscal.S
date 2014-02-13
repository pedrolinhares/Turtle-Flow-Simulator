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
#include "version.h"

	PROLOGUE
	PROFCODE
	.frame	$sp, 16, $26, 0

	mov	$21, $18
	fmov	$f19, $f0
	ldl	$19,  0($sp)		# incx
	fmov	$f20, $f1

#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	sra	$16,  1, $24		# 2-unrolling
	lda	$23,  -1($19)

	ble	$16,  $End

	addl	$19, $19, $19
	bne	$23,  $INC_NOT_1
	.align 4

	ble	$24,  $Sub
	lda	$24,  -1($24)

	LD	$f10,   0*SIZE($18)
	LD	$f11,   1*SIZE($18)
	LD	$f12,   2*SIZE($18)
	LD	$f13,   3*SIZE($18)
	lda	$18,    4*SIZE($18)
	ble	$24,  $MainRemain
	.align 4

$MainLoop:
	MUL	$f10, $f0,  $f16		# ac
	lda	$24,   -1($24)
	MUL	$f11, $f1,  $f21		# bd
	ldl	$31,    8*SIZE($18)

	MUL	$f10, $f1,  $f20		# bc
	LD	$f10,   0*SIZE($18)
	MUL	$f11, $f0,  $f17		# ad
	LD	$f11,   1*SIZE($18)

	MUL	$f12, $f0,  $f18		# ac
	unop
	MUL	$f13, $f1,  $f23		# bd
	nop

	MUL	$f12, $f1,  $f22		# bc
	LD	$f12,   2*SIZE($18)
	MUL	$f13, $f0,  $f19		# ad
	LD	$f13,   3*SIZE($18)

	SUB	$f16, $f21, $f24		# ac - bd
	lda	$18,    4*SIZE($18)
	ADD	$f17, $f20, $f25		# ad + bc
	nop

	SUB	$f18, $f23, $f26		# ac - bd
	ADD	$f19, $f22, $f27		# ad + bc
	ST	$f24,   0*SIZE($21)
	ST	$f25,   1*SIZE($21)

	ST	$f26,   2*SIZE($21)
	ST	$f27,   3*SIZE($21)
	lda	$21,    4*SIZE($21)
	bgt	$24, $MainLoop
	.align 4

$MainRemain:
	MUL	$f10, $f0,  $f16		# ac
	MUL	$f11, $f1,  $f21		# bd
	MUL	$f11, $f0,  $f17		# ad
	MUL	$f10, $f1,  $f20		# bc

	MUL	$f12, $f0,  $f18		# ac
	MUL	$f13, $f1,  $f23		# bd
	MUL	$f13, $f0,  $f19		# ad
	MUL	$f12, $f1,  $f22		# bc

	SUB	$f16, $f21, $f24		# ac - bd
	ADD	$f17, $f20, $f25		# ad + bc
	SUB	$f18, $f23, $f26		# ac - bd
	ADD	$f19, $f22, $f27		# ad + bc

	ST	$f24,   0*SIZE($21)
	ST	$f25,   1*SIZE($21)
	ST	$f26,   2*SIZE($21)
	ST	$f27,   3*SIZE($21)
	lda	$21,    4*SIZE($21)
	.align 4

$Sub:
	blbc	$16,  $End

	LD	$f10,   0*SIZE($18)
	LD	$f11,   1*SIZE($18)
	lda	$18,    2*SIZE($18)

	MUL	$f10, $f0,  $f16		# ac
	MUL	$f11, $f0,  $f17		# ad
	MUL	$f10, $f1,  $f20		# bc
	MUL	$f11, $f1,  $f21		# bd

	SUB	$f16, $f21, $f24		# ac - bd
	ADD	$f17, $f20, $f25		# ad + bc

	ST	$f24,   0*SIZE($21)
	ST	$f25,   1*SIZE($21)
	lda	$21,    2*SIZE($21)
	.align 4

$End:
	ret
	.align 4

$INC_NOT_1:
	ble	$24,  $INC_Sub
	lda	$24,  -1($24)

	LD	$f10,   0*SIZE($18)
	LD	$f11,   1*SIZE($18)
	SXADDQ	$19, $18, $18

	LD	$f12,   0*SIZE($18)
	LD	$f13,   1*SIZE($18)
	SXADDQ	$19, $18, $18
	ble	$24,  $INC_MainRemain
	.align 4

$INC_MainLoop:
	MUL	$f10, $f0,  $f16		# ac
	lda	$24,   -1($24)
	MUL	$f11, $f1,  $f21		# bd
	ldl	$31,    8*SIZE($18)

	MUL	$f10, $f1,  $f20		# bc
	LD	$f10,   0*SIZE($18)
	MUL	$f11, $f0,  $f17		# ad
	LD	$f11,   1*SIZE($18)

	MUL	$f12, $f0,  $f18		# ac
	SXADDQ	$19, $18, $18
	MUL	$f13, $f1,  $f23		# bd
	nop

	MUL	$f12, $f1,  $f22		# bc
	LD	$f12,   0*SIZE($18)
	MUL	$f13, $f0,  $f19		# ad
	LD	$f13,   1*SIZE($18)

	SUB	$f16, $f21, $f24		# ac - bd
	SXADDQ	$19, $18, $18
	ADD	$f17, $f20, $f25		# ad + bc
	nop

	SUB	$f18, $f23, $f26		# ac - bd
	ADD	$f19, $f22, $f27		# ad + bc
	ST	$f24,   0*SIZE($21)
	ST	$f25,   1*SIZE($21)

	SXADDQ	$19, $21, $21
	ST	$f26,   0*SIZE($21)
	ST	$f27,   1*SIZE($21)
	SXADDQ	$19, $21, $21
	bgt	$24, $INC_MainLoop
	.align 4

$INC_MainRemain:
	MUL	$f10, $f0,  $f16		# ac
	MUL	$f11, $f1,  $f21		# bd
	MUL	$f11, $f0,  $f17		# ad
	MUL	$f10, $f1,  $f20		# bc

	MUL	$f12, $f0,  $f18		# ac
	MUL	$f13, $f1,  $f23		# bd
	MUL	$f13, $f0,  $f19		# ad
	MUL	$f12, $f1,  $f22		# bc

	SUB	$f16, $f21, $f24		# ac - bd
	ADD	$f17, $f20, $f25		# ad + bc
	SUB	$f18, $f23, $f26		# ac - bd
	ADD	$f19, $f22, $f27		# ad + bc

	ST	$f24,   0*SIZE($21)
	nop
	ST	$f25,   1*SIZE($21)
	SXADDQ	$19, $21, $21

	ST	$f26,   0*SIZE($21)
	nop
	ST	$f27,   1*SIZE($21)
	SXADDQ	$19, $21, $21
	.align 4

$INC_Sub:
	blbc	$16,  $INC_End

	LD	$f10,   0*SIZE($18)
	LD	$f11,   1*SIZE($18)
	SXADDQ	$19, $18, $18

	MUL	$f10, $f0,  $f16		# ac
	MUL	$f11, $f0,  $f17		# ad
	MUL	$f10, $f1,  $f20		# bc
	MUL	$f11, $f1,  $f21		# bd

	SUB	$f16, $f21, $f24		# ac - bd
	ADD	$f17, $f20, $f25		# ad + bc

	ST	$f24,   0*SIZE($21)
	ST	$f25,   1*SIZE($21)
	SXADDQ	$19, $21, $21
	.align 4

$INC_End:
	ret
	EPILOGUE
