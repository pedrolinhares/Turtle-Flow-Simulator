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

	.set noat
	.set noreorder

.text
	.align 5
	.globl NAME
	.ent NAME
NAME:
	.frame $sp, 32, $26, 0
	ldgp	$gp,   0($27)
	lda	$sp, -32($sp)
	ldl	$16,   0($16)

	ldl	$18,   0($18)
	ldah	$4,  0x3f80
	fclr	$f0			# norm = 0.
	stq	$26,   0($sp)

	stt	$f2,   8($sp)
	stl	$4,   16($sp)
	.prologue 1

#ifdef PROFILE
	lda	$28, _mcount
	jsr	$28, ($28), _mcount
	unop
	unop
#endif

	ble	$16, $End
	ble	$18, $End

#ifndef COMPLEX
	LD	$f0,   0($17)
	cmpeq	$16, 1, $0
	fabs	$f0, $f0
	bne	$0,  $End
#else
	addl	$18, $18, $18
#endif

	fclr	$f2
	lda	$27,  sqrt
	lds	$f30, 16($sp)		# one load
	fmov	$f30, $f16		# ssq = 1.
	.align 4

$MainLoop:
	LD	$f17,  0($17)		# xi = *x
#ifndef COMPLEX
	SXADDQ	$18, $17, $17		# x += incx
	nop
	lda	$16,  -1($16)		# n --
#endif

	fabs	$f17,  $f0		# absxi = fabs(xi)
#ifndef COMPLEX
	fbeq	$f17, $MainLoopEnd
#else
	fbeq	$f17, $MainLoopNext
#endif
	cmptle	$f0,  $f2, $f10		# if (absxi < scale)
	fbeq	$f10, $ABSXI_LT_SCALE
	.align 4

$ABSXI_GE_SCALE:
	DIV	$f0,  $f2,  $f10	# divxi = (absxi / scale)
	MUL	$f10, $f10, $f10	# divxi = divxi * divxi
	ADD	$f16, $f10, $f16	# ssq += divxi
#ifndef COMPLEX
	bgt	$16,  $MainLoop
	br	$31,  $Finish
#else
	br	$31, $MainLoopNext
#endif
	.align 4

$ABSXI_LT_SCALE:
	DIV	$f2,  $f0,  $f10	# divxi = (scale / absxi)
	fmov	$f0,  $f2		# scale = absxi
	MUL	$f10, $f10, $f10	# divxi = divxi * divxi
	MUL	$f16, $f10, $f10	# ssq = ssq * divxi
	ADD	$f30, $f10, $f16	# ssq = 1. + ssq

#ifdef COMPLEX
	.align 4

$MainLoopNext:
	LD	$f17,  SIZE($17)	# xi = *x
	SXADDQ	$18, $17, $17		# x += incx
	nop
	lda	$16,  -1($16)		# n --

	fabs	$f17,  $f0		# absxi = fabs(xi)
	fbeq	$f17, $MainLoopEnd
	cmptle	$f0,  $f2, $f10		# if (absxi < scale)
	fbeq	$f10, $ABSXI_LT_SCALE2
	.align 4

$ABSXI_GE_SCALE2:
	DIV	$f0,  $f2,  $f10	# divxi = (absxi / scale)
	MUL	$f10, $f10, $f10	# divxi = divxi * divxi
	ADD	$f16, $f10, $f16	# ssq += divxi
	bgt	$16,  $MainLoop
	br	$31,  $Finish
	.align 4

$ABSXI_LT_SCALE2:
	DIV	$f2,  $f0,  $f10	# divxi = (scale / absxi)
	fmov	$f0,  $f2		# scale = absxi
	MUL	$f10, $f10, $f10	# divxi = divxi * divxi
	MUL	$f16, $f10, $f10	# ssq = ssq * divxi
	ADD	$f30, $f10, $f16	# ssq = 1. + ssq
	.align 4
#endif

$MainLoopEnd:
	bgt	$16,$MainLoop
	.align 4

$Finish:
	jsr	$26, ($27), sqrt
	ldgp	$gp,  0($26)
	MUL	$f2,$f0,$f0
	.align 4

$End:
	ldq	$26,  0($sp)
	ldt	$f2,  8($sp)
	lda	$sp, 32($sp)
	ret
	.end NAME
