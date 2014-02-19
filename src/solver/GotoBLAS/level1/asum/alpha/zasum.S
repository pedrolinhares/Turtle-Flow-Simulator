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
	.frame	$sp, 0, $26, 0
	.frame	$sp, 0, $26, 0

#ifdef F_INTERFACE
	ldl	$16,   0($16)
	fclr	$f0
	ldl	$18,   0($18)
	fclr	$f29
#else
	unop
	fclr	$f0
	unop
	fclr	$f29
#endif
#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	fclr	$f30
	sra	$16, 1, $20
	fclr	$f28
	ble	$16,  $End

	ble	$18,  $End
	addl	$18, $18, $18
	ble	$20, $Sub
	.align 4

	lda	$20,  -1($20)
	LD	$f16,    0($17)
	LD	$f17, SIZE($17)
	SXADDQ	$18, $17, $17

	LD	$f18,    0($17)
	LD	$f19, SIZE($17)
	SXADDQ	$18, $17, $17
	ble	$20, $MainLoopEnd
	.align 4

$MainLoop:
	fabs	$f16, $f20
	LD	$f16,    0($17)
	unop
	unop

	fabs	$f17, $f21
	LD	$f17, SIZE($17)
	unop
	SXADDQ	$18, $17, $17

	fabs	$f18, $f22
	LD	$f18,    0($17)
	unop
	unop

	fabs	$f19, $f23
	LD	$f19, SIZE($17)
	unop
	lda	$20,  -1($20)

	ADD	$f0,  $f20, $f0
	ADD	$f28, $f21, $f28
	ADD	$f29, $f22, $f29
	ADD	$f30, $f23, $f30

	SXADDQ	$18, $17, $17
	unop
	unop
	bne	$20, $MainLoop
	.align 4

$MainLoopEnd:
	fabs	$f16, $f20
	fabs	$f17, $f21
	fabs	$f18, $f22
	fabs	$f19, $f23

	ADD	$f0,  $f20, $f0
	ADD	$f28, $f21, $f28
	ADD	$f29, $f22, $f29
	ADD	$f30, $f23, $f30
	.align 4

$Sub:
	ADD	$f0,  $f28, $f0
	unop
	ADD	$f29, $f30, $f29
	blbc	$16, $End
	.align 4

$SubLoop:
	LD	$f16,  0($17)
	fabs	$f16, $f20
	ADD	$f0,  $f20, $f0

	LD	$f16, SIZE($17)
	fabs	$f16, $f20
	ADD	$f0,  $f20, $f0
	.align 4

$End:
	ADD	$f0,  $f29, $f0
	ret
	EPILOGUE
