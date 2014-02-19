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

#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	mov	$20, $18
	sra	$16,  2, $24		# 4-unrolling
	and	$16,  3, $22		# 4-unrolling

	ble	$16, $End

	lda	$23,  -1($21)
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
	MUL	$f10, $f19,  $f20
	LD	$f10,   0*SIZE($18)
	MUL	$f11, $f19,  $f21
	LD	$f11,   1*SIZE($18)

	MUL	$f12, $f19,  $f22
	LD	$f12,   2*SIZE($18)
	MUL	$f13, $f19,  $f23
	LD	$f13,   3*SIZE($18)

	lda	$18,    4*SIZE($18)
#ifdef EV6
	ldl	$31,   12*SIZE($18)
#else
	lds	$f31,  16*SIZE($18)
#endif
	lda	$24,   -1($24)

	ST	$f20,   0*SIZE($20)
	ST	$f21,   1*SIZE($20)
	ST	$f22,   2*SIZE($20)
	ST	$f23,   3*SIZE($20)
	lda	$20,    4*SIZE($20)

	bgt	$24, $MainLoop
	.align 4

$MainRemain:
	MUL	$f10, $f19,  $f20
	MUL	$f11, $f19,  $f21
	MUL	$f12, $f19,  $f22
	MUL	$f13, $f19,  $f23

	ST	$f20,   0*SIZE($20)
	ST	$f21,   1*SIZE($20)
	ST	$f22,   2*SIZE($20)
	ST	$f23,   3*SIZE($20)
	lda	$20,    4*SIZE($20)
	.align 4

$Sub:
	ble	$22, $End
	.align 4

$SubLoop:
	LD	$f10,      0($18)
	lda	$18,    SIZE($18)
	MUL	$f10, $f19,  $f20
	ST	$f20,      0($20)
	lda	$20,    SIZE($20)
	lda	$22,   -1($22)
	bgt	$22, $SubLoop
	.align 4

$End:
	ret
	.align 4

$INC_NOT_1:
	ble	$24,  $INC_Sub
	lda	$24,  -1($24)

	LD	$f10,   0($18)
	SXADDQ	$21, $18, $18
	LD	$f11,   0($18)
	SXADDQ	$21, $18, $18

	LD	$f12,   0($18)
	SXADDQ	$21, $18, $18
	LD	$f13,   0($18)
	SXADDQ	$21, $18, $18
	ble	$24,  $INC_MainRemain
	.align 4

$INC_MainLoop:
	MUL	$f10, $f19,  $f20
	LD	$f10,   0($18)
	unop
	SXADDQ	$21, $18, $18

	MUL	$f11, $f19,  $f21
	LD	$f11,   0($18)
	unop
	SXADDQ	$21, $18, $18

	MUL	$f12, $f19,  $f22
	LD	$f12,   0($18)
	unop
	SXADDQ	$21, $18, $18

	MUL	$f13, $f19,  $f23
	LD	$f13,   0($18)
	unop
	SXADDQ	$21, $18, $18

	ST	$f20,   0($20)
	SXADDQ	$21, $20, $20
	unop
	lda	$24,   -1($24)

	ST	$f21,   0($20)
	SXADDQ	$21, $20, $20
	ST	$f22,   0($20)
	SXADDQ	$21, $20, $20

	ST	$f23,   0($20)
	SXADDQ	$21, $20, $20
	unop
	bgt	$24, $INC_MainLoop
	.align 4

$INC_MainRemain:
	MUL	$f10, $f19,  $f20
	MUL	$f11, $f19,  $f21
	MUL	$f12, $f19,  $f22
	MUL	$f13, $f19,  $f23

	ST	$f20,   0($20)
	SXADDQ	$21, $20, $20
	ST	$f21,   0($20)
	SXADDQ	$21, $20, $20

	ST	$f22,   0($20)
	SXADDQ	$21, $20, $20
	ST	$f23,   0($20)
	SXADDQ	$21, $20, $20
	.align 4

$INC_Sub:
	ble	$22, $INC_End
	.align 4

$INC_SubLoop:
	LD	$f10,   0($18)
	SXADDQ	$21, $18, $18
	MUL	$f10, $f19,  $f20
	ST	$f20,   0($20)
	SXADDQ	$21, $20, $20

	lda	$22,   -1($22)
	bgt	$22, $INC_SubLoop
	.align 4

$INC_End:
	ret
	EPILOGUE
