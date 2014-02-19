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

#undef MUL
#undef ADD

#if defined(DOUBLE) || defined(DOUBLESUM)
#define MUL	mult
#define ADD	addt
#else
#define MUL	muls
#define ADD	adds
#endif
	
	PROLOGUE
	PROFCODE
	.frame	$sp, 16, $26, 0

	lda	$sp, -16($sp)
	nop
	stt	$f2,   0($sp)
	fclr	$f0

#ifdef F_INTERFACE
	ldl	$16,   0($16)
#ifndef SDSDOT
	ldl	$18,   0($18)
	ldl	$20,   0($20)
#else
	lds	$f0,   0($17)
	mov	$18, $17
	ldl	$18,   0($19)
	mov	$20, $19
	ldl	$20,   0($21)
#endif
#else
#ifdef SDSDOT
	fmov	$f17, $f0
	mov	$18, $17
	mov	$19, $18
	mov	$20, $19
	mov	$21, $20
#endif
#endif
#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	ble	$16,  $End

	cmpeq	$18, 1, $21
	cmpeq	$20, 1, $22
	srl	$16, 3, $5		# k = (n>> 3)
	and	$21, $22, $22

	and	$16, 7, $6		# l = (n & 7)
	beq	$22, $Continue1
	beq	$5, $Remain
	.align 4

	LD	$f10, 0*SIZE($17)	# atemp1
	fclr	$f26
	LD	$f18, 0*SIZE($19)	# btemp1
	fclr	$f27

	LD	$f11, 1*SIZE($17)	# atemp2
	fclr	$f1
	LD	$f19, 1*SIZE($19)	# btemp2
	fclr	$f28

	LD	$f12, 2*SIZE($17)	# atemp3
	fclr	$f2
	LD	$f20, 2*SIZE($19)	# btemp3
	fclr	$f29

	LD	$f13, 3*SIZE($17)	# atemp4
	fclr	$f30
	LD	$f21, 3*SIZE($19)	# btemp4
	unop

	LD	$f14, 4*SIZE($17)	# atemp5
	LD	$f22, 4*SIZE($19)	# btemp5
	LD	$f15, 5*SIZE($17)	# atemp6
	LD	$f23, 5*SIZE($19)	# btemp6

	LD	$f16, 6*SIZE($17)	# atemp7
	LD	$f24, 6*SIZE($19)	# btemp7
	LD	$f17, 7*SIZE($17)	# atemp8
	LD	$f25, 7*SIZE($19)	# btemp8

	subq	$5,   1, $5		# k--
	addq	$17, 8*SIZE, $17	# dx += 8
	addq	$19, 8*SIZE, $19	# dy += 8
	ble	$5, $MainLoopEnd
	.align 4

    /*   Thanks for Naohiko Shimizu <nshimizu@et.u-tokai.ac.jp> */
    /*                about advising MAF and prefetch strategy. */

$MainLoop:
	ADD	$f0,  $f26, $f0		# stemp1 += temp1
	MUL	$f10, $f18, $f26	# temp1 = atemp1 * btemp1
	LD	$f10, 0*SIZE($17)	# atemp1
	LD	$f18, 0*SIZE($19)	# btemp1

	ADD	$f1,  $f27, $f1		# stemp2 += temp2
	MUL	$f11, $f19, $f27	# temp1 = atemp1 * btemp1
	LD	$f11, 1*SIZE($17)	# atemp2
	LD	$f19, 1*SIZE($19)	# btemp2

	ADD	$f2,  $f28, $f2		# stemp3 += temp3
	MUL	$f12, $f20, $f28	# temp1 = atemp1 * btemp1
	LD	$f12, 2*SIZE($17)	# atemp3
	LD	$f20, 2*SIZE($19)	# btemp3

	ADD	$f30, $f29, $f30	# stemp4 += temp4
	MUL	$f13, $f21, $f29	# temp1 = atemp1 * btemp1
	LD	$f13, 3*SIZE($17)	# atemp4
	LD	$f21, 3*SIZE($19)	# btemp4

	ADD	$f0,  $f26, $f0		# stemp1 += temp1
	MUL	$f14, $f22, $f26	# temp1 = atemp1 * btemp1
	LD	$f14, 4*SIZE($17)	# atemp5
	LD	$f22, 4*SIZE($19)	# btemp5

	ADD	$f1,  $f27, $f1		# stemp2 += temp2
	MUL	$f15, $f23, $f27	# temp1 = atemp1 * btemp1
	LD	$f15, 5*SIZE($17)	# atemp6
	LD	$f23, 5*SIZE($19)	# btemp6

	ADD	$f2,  $f28, $f2		# stemp3 += temp3
	MUL	$f16, $f24, $f28	# temp1 = atemp1 * btemp1
	LD	$f16, 6*SIZE($17)	# atemp7
	LD	$f24, 6*SIZE($19)	# btemp7

	ADD	$f30, $f29, $f30	# stemp4 += temp4
	MUL	$f17, $f25, $f29	# temp1 = atemp1 * btemp1
	LD	$f17, 7*SIZE($17)	# atemp8
	LD	$f25, 7*SIZE($19)	# btemp8

	LD	$f31, 136($17)
	subq	$5,   1, $5		# k--
	addq	$17, 8*SIZE, $17	# dx += 8
	addq	$19, 8*SIZE, $19	# dy += 8
	bgt	$5, $MainLoop
	.align 4

$MainLoopEnd:
	ADD	$f0,  $f26, $f0		# stemp1 += temp1
	MUL	$f10, $f18, $f26	# temp1 = atemp1 * btemp1
	ADD	$f1,  $f27, $f1		# stemp2 += temp2
	MUL	$f11, $f19, $f27	# temp1 = atemp1 * btemp1

	ADD	$f2,  $f28, $f2		# stemp3 += temp3
	MUL	$f12, $f20, $f28	# temp1 = atemp1 * btemp1
	ADD	$f30, $f29, $f30	# stemp4 += temp4
	MUL	$f13, $f21, $f29	# temp1 = atemp1 * btemp1

	ADD	$f0,  $f26, $f0		# stemp1 += temp1
	MUL	$f14, $f22, $f26	# temp1 = atemp1 * btemp1
	ADD	$f1,  $f27, $f1		# stemp2 += temp2
	MUL	$f15, $f23, $f27	# temp1 = atemp1 * btemp1

	ADD	$f2,  $f28, $f2		# stemp3 += temp3
	MUL	$f16, $f24, $f28	# temp1 = atemp1 * btemp1
	ADD	$f30, $f29, $f30	# stemp4 += temp4
	MUL	$f17, $f25, $f29	# temp1 = atemp1 * btemp1

	ADD	$f0,  $f26, $f0		# stemp1 += temp1
	ADD	$f1,  $f27, $f1		# stemp2 += temp2
	ADD	$f2,  $f28, $f2		# stemp3 += temp3
	ADD	$f30, $f29, $f30	# stemp4 += temp4

	ADD	$f0, $f1,  $f0
	ADD	$f2, $f30, $f2
	ADD	$f0, $f2,  $f0
	bne	$6, $RemainContinue
	.align 4

$Remain:
	bne	$6, $RemainContinue
	ldt	$f2,  0($sp)
	lda	$sp, 16($sp)
	ret
	.align 4

$RemainContinue:
	LD	$f10, 0($17)
	addq	$17, SIZE, $17
	fclr	$f26

	LD	$f18, 0($19)
	addq	$19, SIZE, $19

	subq	$6, 1, $6
	beq	$6, $Remain_LoopEnd

	.align 4

$Remain_Loop:
	ADD	$f0,  $f26, $f0
	MUL	$f10, $f18, $f26
	LD	$f10, 0($17)
	LD	$f18, 0($19)

	subq	$6, 1, $6
	addq	$17, SIZE, $17
	addq	$19, SIZE, $19
	bgt	$6, $Remain_Loop
	.align 4

$Remain_LoopEnd:
	ADD	$f0,  $f26, $f0
	MUL	$f10, $f18, $f26
	ADD	$f0,  $f26, $f0
	ldt	$f2,  0($sp)
	lda	$sp, 16($sp)
	ret
	.align 4

$Continue1:
	or	$18, $20, $21
	bne	$21, $Continue2
	stq	$16,  8($sp)
	LD	$f10, 0($17)

	LD	$f11, 0($19)
	ldt	$f12, 8($sp)
	MUL	$f10, $f11, $f0
	cvtqt	$f12, $f12

	MUL	$f0,  $f12, $f0
	ldt	$f2,  0($sp)
	lda	$sp, 16($sp)
	ret
	.align 4

$Continue2:
	SXSUBL	$16,  SIZE, $21
#ifdef F_INTERFACE
	bge	$18, $IncX
	mulq	$21, $18, $22
	subq	$17, $22, $17
	.align 4

$IncX:
	bge	$20, $IncY
	mulq	$21, $20, $23
	subq	$19, $23, $19
	.align 4

$IncY:
#else
	.align 4
#endif
	srl	$16, 2, $5		# k = (n>> 2)
	and	$16, 3, $6		# l = (n & 3)
	nop
	beq	$5, $SubRemain

	LD	$f10, 0($17)	
	fclr	$f0
	LD	$f18, 0($19)
	fclr	$f1

	SXADDQ	$18, $17, $17
	fclr	$f22
	SXADDQ	$20, $19, $19
	fclr	$f23

	LD	$f11, 0($17)	
	LD	$f19, 0($19)
	SXADDQ	$18, $17, $17
	SXADDQ	$20, $19, $19

	LD	$f12, 0($17)	
	LD	$f20, 0($19)
	SXADDQ	$18, $17, $17
	SXADDQ	$20, $19, $19

	LD	$f13, 0($17)	
	LD	$f21, 0($19)
	SXADDQ	$18, $17, $17
	SXADDQ	$20, $19, $19

	subq	$5, 1, $5
	beq	$5, $SubMainEnd
	.align 4

$SubMainLoop:
	ADD	$f0,  $f22, $f0
	MUL	$f10, $f18, $f22
	LD	$f10, 0($17)	
	LD	$f18, 0($19)

	SXADDQ	$18, $17, $17
	fnop
	SXADDQ	$20, $19, $19
	fnop

	ADD	$f1,  $f23, $f1
	MUL	$f11, $f19, $f23
	LD	$f11, 0($17)	
	LD	$f19, 0($19)

	SXADDQ	$18, $17, $17
	fnop
	SXADDQ	$20, $19, $19
	fnop

	ADD	$f0,  $f22, $f0
	MUL	$f12, $f20, $f22
	LD	$f12, 0($17)	
	LD	$f20, 0($19)

	SXADDQ	$18, $17, $17
	fnop
	SXADDQ	$20, $19, $19
	fnop

	ADD	$f1,  $f23, $f1
	MUL	$f13, $f21, $f23
	LD	$f13, 0($17)	
	LD	$f21, 0($19)

	SXADDQ	$18, $17, $17
	subq	$5, 1, $5
	SXADDQ	$20, $19, $19
	bgt	$5, $SubMainLoop
	.align 4

$SubMainEnd:
	ADD	$f0,  $f22, $f0
	MUL	$f10, $f18, $f22
	ADD	$f1,  $f23, $f1
	MUL	$f11, $f19, $f23

	ADD	$f0,  $f22, $f0
	MUL	$f12, $f20, $f22
	ADD	$f1,  $f23, $f1
	MUL	$f13, $f21, $f23

	ADD	$f0,  $f22, $f0
	ADD	$f1,  $f23, $f1
	ADD	$f0,  $f1,  $f0
	beq	$6, $End
	.align 4

$SubRemain:
	fclr	$f12
	beq	$6, $End
	.align 4

$SubRemainLoop:
	LD	$f10, 0($17)
	LD	$f11, 0($19)
	SXADDQ	$18, $17, $17
	subq	$6, 1, $6

	ADD	$f0,  $f12, $f0
	SXADDQ	$20, $19, $19
	MUL	$f10, $f11, $f12
	bgt	$6, $SubRemainLoop
	ADD	$f0,  $f12, $f0
	.align 4
$End:
	ldt	$f2,  0($sp)
	lda	$sp, 16($sp)
	ret

	EPILOGUE
