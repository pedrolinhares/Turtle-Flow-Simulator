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

#ifdef EV6
#ifdef DOUBLE
#define Q   200
#else
#define Q   400
#endif
#endif
	
#ifdef EV5
#ifdef DOUBLE
#define Q   200
#else
#define Q   400
#endif
#endif

#ifdef EV4
#ifdef DOUBLE
#define Q    16
#else
#define Q    16
#endif
#endif

	.set noat
	.set noreorder

/*
 $0 :		 $1 :		 $2 :		 $3 : 
 $4 :		 $5 : a_offset	 $6 : a_offset1	 $7 : x_offset
 $8 : y_offset	 $9 : 		 $10:		 $11: 
 $12: 		 $13:		 $14:		 $15:  
 $16: m		 $17: n		 $18: a_offset2	 $19: x
 $20: incx   	 $21: y		 $22: incy	 $23: a
 $24: lda	 $25: i		 $26: is	 $27: min_i
 $at: j		 $29: GP	 $30: SP	 $31: Zero
*/

#define STACKSIZE 32

.text
	.align 5
	.globl NAME
	.ent NAME
NAME:
	.frame	$sp, STACKSIZE, $26, 0

#ifdef PROFILE
	ldgp	$gp, 0($27)
	lda	$28, _mcount
	jsr	$28, ($28), _mcount
#endif

	fmov	$f19, $f1		 # alpha
	ldq	$19, 0($sp)		 # y
	lda	$sp, -STACKSIZE($sp)
	clr	$0

	ldl	$22, STACKSIZE +  8($sp) # incy
	ldq	$23, STACKSIZE + 16($sp) # a
	or	$16, $17, $2
	ldl	$24, STACKSIZE + 24($sp) # lda

#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	stq	$9,   0($sp)
	lda	$18, Q
	cmpeq	$21,  1, $1
	beq	$2,   $End

	ldq	$9,  STACKSIZE + 32($sp)	# Buffer
	clr	$4			# is = 0
	cmovne	$1,   0, $21
	fbeq	$f19,  $End
	.align 4

$L21:
	subl	$16, $4,  $27		# min_i = m - is
	SXADDQ	$4, $23, $5		# a_offset = a + is
	cmple	$27, $18, $1		# $1 = (Q < min_i)
	mov	$9,  $6

	cmoveq	$1,  $18, $27		# if (Q<min_i) min_i = Q
	mov	$27, $25
	nop
	beq	$21, $Skip_Copying
	.align 4
	
$Copy_Loop:
	LD	$f10,    0($20)
	SXADDQ	$21, $20, $20
	ST	$f10,    0($6)
	lda	$6,   SIZE($6)
	lda	$25,    -1($25)
	bgt	$25, $Copy_Loop
	.align 4

$Skip_Copying:
	sra	$17,  1, $28		# j = (n >> 1)
	mov	$19, $8			# y_offset = y
	addq	$4, $18, $4		# is += Q
	ble	$28, $L23
	.align 4

$L38:
	mov	$5,  $6			# a_offset1 = a_offset

	LD	$f10,  0($8)
	SXADDQ	$22, $8,  $8		# y_offset += incy
	LD	$f11,  0($8)
	SXADDQ	$22, $8,  $8		# y_offset += incy

	lda	$28,  -1($28)		# j --
	sra	$27,  3,  $25		# i = (min_i >> 2)
	SXADDQ	$24, $5, $3		# a_offset2 = a_offset  + lda
	MUL	$f1, $f10, $f25		# temp1 = alpha * *y_offset

	SXADDQ	$24, $3,  $5		# a_offset  = a_offset2 + lda;
	mov	$20, $7			# x_offset  = x
	cmovne	$21, $9,  $7

	MUL	$f1, $f11, $f21		# temp2 = alpha * *y_offset
	ble	$25,$L27

	LD	$f22, 0*SIZE($7)
	LD	$f29, 1*SIZE($7)
	LD	$f28, 2*SIZE($7)
	LD	$f27, 3*SIZE($7)

	LD	$f26, 0*SIZE($6)
	LD	$f19, 1*SIZE($6)
	LD	$f30, 2*SIZE($6)
	LD	$f20, 3*SIZE($6)

	LD	$f17, 0*SIZE($3)
	MUL	$f25, $f22, $f10
	LD	$f18, 1*SIZE($3)
	MUL	$f25, $f29, $f13

	LD	$f16, 2*SIZE($3)
	MUL	$f25, $f28, $f11
	LD	$f0,  3*SIZE($3)
	MUL	$f25, $f27, $f12

	lda	$25,   -1($25)
	ble	$25, $L28
	.align 4

$MainLoop:
	lds	$f31, 32*SIZE($3)
	unop
	lds	$f31, 32*SIZE($6)
	unop

	ADD	$f10, $f26, $f10
	LD	$f26, 4*SIZE($6)	# 8 Clocks
	MUL	$f21, $f22, $f24
	LD	$f9,  4*SIZE($7)	#

	ADD	$f13, $f19, $f13
	LD	$f19, 5*SIZE($6)
	MUL	$f21, $f29, $f23
	LD	$f29, 5*SIZE($7)

	ADD	$f11, $f30, $f11
	LD	$f30, 6*SIZE($6)
	MUL	$f21, $f28, $f15
	LD	$f28, 6*SIZE($7)

	ADD	$f12, $f20, $f12
	LD	$f20, 7*SIZE($6)
	MUL	$f21, $f27, $f14
	LD	$f27, 7*SIZE($7)

	ST	$f10, 0*SIZE($6)
	ADD	$f24, $f17, $f24
	MUL	$f25, $f9,  $f10
	LD	$f17, 4*SIZE($3)	# 8 Clocks

	ST	$f13, 1*SIZE($6)
	ADD	$f23, $f18, $f23
	LD	$f18, 5*SIZE($3)
	MUL	$f25, $f29, $f13

	ST	$f11, 2*SIZE($6)
	ADD	$f15, $f16, $f15
	MUL	$f25, $f28, $f11
	LD	$f16, 6*SIZE($3)

	ST	$f12, 3*SIZE($6)
	ADD	$f14, $f0,  $f14
	LD	$f0,  7*SIZE($3)
	MUL	$f25, $f27, $f12

	ST	$f24, 0*SIZE($3)
	unop
	unop
	unop

	ADD	$f10, $f26, $f10
	LD	$f26, 8*SIZE($6)
	MUL	$f21, $f9,  $f24
	LD	$f22, 8*SIZE($7)	# 4 Clocks

	ST	$f23, 1*SIZE($3)
	unop
	unop
	unop

	ADD	$f13, $f19, $f13
	LD	$f19, 9*SIZE($6)
	MUL	$f21, $f29, $f23
	LD	$f29, 9*SIZE($7)

	ST	$f15, 2*SIZE($3)
	unop
	unop
	unop

	ADD	$f11, $f30, $f11
	LD	$f30,10*SIZE($6)
	MUL	$f21, $f28, $f15
	LD	$f28,10*SIZE($7)

	ST	$f14, 3*SIZE($3)
	unop
	unop
	lda	$25,   -1($25)

	ADD	$f12, $f20, $f12
	LD	$f20,11*SIZE($6)
	MUL	$f21, $f27, $f14
	LD	$f27,11*SIZE($7)

	ST	$f10, 4*SIZE($6)
	ADD	$f24, $f17, $f24
	LD	$f17, 8*SIZE($3)		# 9 clocks
	MUL	$f25, $f22, $f10

	ST	$f13, 5*SIZE($6)
	ADD	$f23, $f18, $f23
	LD	$f18, 9*SIZE($3)
	MUL	$f25, $f29, $f13

	ST	$f11, 6*SIZE($6)
	ADD	$f15, $f16, $f15
	LD	$f16,10*SIZE($3)
	MUL	$f25, $f28, $f11

	ST	$f12, 7*SIZE($6)
	ADD	$f14, $f0,  $f14
	LD	$f0, 11*SIZE($3)
	MUL	$f25, $f27, $f12

	ST	$f24, 4*SIZE($3)
	lda	$7,   8*SIZE($7)
	ST	$f23, 5*SIZE($3)
	lda	$6,   8*SIZE($6)

	ST	$f15, 6*SIZE($3)
	ST	$f14, 7*SIZE($3)
	lda	$3,   8*SIZE($3)
	bgt	$25,$MainLoop
	.align 4

$L28:
	ADD	$f10, $f26, $f10
	LD	$f26, 4*SIZE($6)
	MUL	$f21, $f22, $f24
	LD	$f9,  4*SIZE($7)

	ADD	$f13, $f19, $f13
	LD	$f19, 5*SIZE($6)
	MUL	$f21, $f29, $f23
	LD	$f29, 5*SIZE($7)

	ADD	$f11, $f30, $f11
	LD	$f30, 6*SIZE($6)
	MUL	$f21, $f28, $f15
	LD	$f28, 6*SIZE($7)

	ADD	$f12, $f20, $f12
	LD	$f20, 7*SIZE($6)
	MUL	$f21, $f27, $f14
	LD	$f27, 7*SIZE($7)

	ST	$f10, 0*SIZE($6)
	ADD	$f24, $f17, $f24
	MUL	$f25, $f9,  $f10
	LD	$f17, 4*SIZE($3)

	ST	$f13, 1*SIZE($6)
	ADD	$f23, $f18, $f23
	MUL	$f25, $f29, $f13
	LD	$f18, 5*SIZE($3)

	ST	$f11, 2*SIZE($6)
	ADD	$f15, $f16, $f15
	MUL	$f25, $f28, $f11
	LD	$f16, 6*SIZE($3)

	ST	$f12, 3*SIZE($6)
	ADD	$f14, $f0,  $f14
	MUL	$f25, $f27, $f12
	LD	$f0,  7*SIZE($3)

	ADD	$f10, $f26, $f10
	ST	$f24, 0*SIZE($3)
	MUL	$f21, $f9,  $f24
	unop

	ADD	$f13, $f19, $f13
	ST	$f23, 1*SIZE($3)
	MUL	$f21, $f29, $f23
	unop

	ADD	$f11, $f30, $f11
	ST	$f15, 2*SIZE($3)
	MUL	$f21, $f28, $f15
	unop

	ADD	$f12, $f20, $f12
	ST	$f14, 3*SIZE($3)
	MUL	$f21, $f27, $f14
	unop

	ADD	$f24, $f17, $f24
	ST	$f10, 4*SIZE($6)
	ADD	$f23, $f18, $f23
	ST	$f13, 5*SIZE($6)

	ADD	$f15, $f16, $f15
	ST	$f11, 6*SIZE($6)
	ADD	$f14, $f0,  $f14
	ST	$f12, 7*SIZE($6)

	ST	$f24, 4*SIZE($3)
	lda	$6,   8*SIZE($6)
	ST	$f23, 5*SIZE($3)
	lda	$7,   8*SIZE($7)

	ST	$f15, 6*SIZE($3)
	nop
	ST	$f14, 7*SIZE($3)
	lda	$3,   8*SIZE($3)
	.align 4

$L27:
	and	$27,7,$25		# min_i
	unop
	unop
	ble	$25,$L26
	.align 4

$L37:
	LD	$f22,  0($7)
	LD	$f26,  0($6)
	LD	$f30,  0($3)
	lda	$25,  -1($25)

	MUL	$f25,$f22,$f10
	MUL	$f21,$f22,$f11
	ADD	$f10,$f26,$f10
	ADD	$f11,$f30,$f11

	ST	$f10,0($6)
	lda	$6,  SIZE($6)
	ST	$f11,0($3)
	lda	$3,  SIZE($3)

	lda	$7,  SIZE($7)
	bgt	$25,$L37
	.align 4

$L26:
	bgt	$28, $L38
	.align 4

$L23:
	blbc	$17, $L39
	.align 4

$L54:
	LD	$f10,0($8)
	mov	$5,  $6			# a_offset1 = a_offset

	mov	$20, $7			# x_offset  = x
	cmovne	$21, $9,  $7

	SXADDQ	$22, $8,  $8		# y_offset += incy

	MUL	$f1,$f10,$f25

	sra	$27, 2, $25		# min_i
	ble	$25,$L43

	LD	$f22, 0*SIZE($7)
	LD	$f29, 1*SIZE($7)
	LD	$f28, 2*SIZE($7)
	LD	$f27, 3*SIZE($7)

	LD	$f26, 0*SIZE($6)
	LD	$f19, 1*SIZE($6)
	LD	$f30, 2*SIZE($6)
	LD	$f20, 3*SIZE($6)

	subl	$25,1,$25
	ble	$25,$L44
	.align 4

$L48:
	MUL	$f25, $f22, $f10
	LD	$f22, 4*SIZE($7)
	MUL	$f25, $f29, $f13
	LD	$f29, 5*SIZE($7)

	MUL	$f25, $f28, $f11
	LD	$f28, 6*SIZE($7)
	MUL	$f25, $f27, $f12
	LD	$f27, 7*SIZE($7)

	ADD	$f10, $f26, $f10
	LD	$f26, 4*SIZE($6)
	ADD	$f13, $f19, $f13
	LD	$f19, 5*SIZE($6)

	ADD	$f11, $f30, $f11
	LD	$f30, 6*SIZE($6)
	ADD	$f12, $f20, $f12
	LD	$f20, 7*SIZE($6)

	ST	$f10, 0*SIZE($6)
	lda	$25,  -1($25)
	ST	$f13, 1*SIZE($6)
	lda	$7,   4*SIZE($7)

	ST	$f11, 2*SIZE($6)
	ST	$f12, 3*SIZE($6)
	lda	$6,   4*SIZE($6)
	bgt	$25,$L48
	.align 4

$L44:
	MUL	$f25, $f22, $f10
	MUL	$f25, $f29, $f13
	MUL	$f25, $f28, $f11
	MUL	$f25, $f27, $f12

	ADD	$f10, $f26, $f10
	ADD	$f13, $f19, $f13
	ADD	$f11, $f30, $f11
	ADD	$f12, $f20, $f12

	ST	$f10, 0*SIZE($6)
	ST	$f13, 1*SIZE($6)
	ST	$f11, 2*SIZE($6)
	lda	$7,   4*SIZE($7)

	ST	$f12, 3*SIZE($6)
	lda	$6,  4*SIZE($6)
	.align 4

$L43:
	and	$27,  3, $25		# min_i
	ble	$25,  $L42
	.align 4

$L53:
	LD	$f22,0($7)
	LD	$f26,0($6)
	MUL	$f25,$f22,$f10
	ADD	$f10,$f26,$f10

	lda	$7, SIZE($7)
	lda	$25,  -1($25)
	ST	$f10,0($6)
	lda	$6, SIZE($6)	

	bgt	$25,$L53
	.align 4

$L42:
	bgt	$28,$L54
	.align 4

$L39:
	SXADDQ	$18, $20, $6			# x += Q
	cmoveq	$21, $6,  $20
	cmplt	$4, $16, $1
	bne	$1,  $L21
	.align 4

$End:
	ldq	$9,    0($sp)
	lda	$sp,  STACKSIZE($sp)
	ret

	.end NAME
	.ident VERSION
