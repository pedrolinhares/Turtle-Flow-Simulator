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
#define Q	 160
#else
#define Q	 320
#endif
#endif

#ifdef EV5
#ifdef DOUBLE
#define Q	 160
#else
#define Q	 320
#endif
#endif

#ifdef EV4
#ifdef DOUBLE
#define Q	  16
#else
#define Q	  16
#endif
#endif

	.set noat
	.set noreorder

#define STACKSIZE	8*8

/*
 $0 :		 $1 :		 $2 :		 $3 : is
 $4 : j		 $5 : is	 $6 : i		 $7 : min_i
 $8 : b_offset	 $9 : ---	 $10: ---	 $11: ---
 $12: ---	 $13: ---	 $14: ---	 $15: ---
 $16: m		 $17: n		 $18:		 $19: x
 $20: incx   	 $21: x		 $22: incy	 $23: a
 $24: lda	 $25: c_offset	 $26: ---	 $27:
 $at: a_orig	 $29: GP	 $30: SP	 $31: Zero
*/

/*
 $f0 : atemp4	 $f1 : alpha_r	 $f2 : alpha_i	 $f3 : temp5
 $f4 : temp6	 $f5 : temp7	 $f6 : temp8	 $f7 : 
 $f8 :		 $f9 :		 $f10: temp3	 $f11: temp1
 $f12: temp2	 $f13: temp4	 $f14: temp9,5	 $f15: temp10,6
 $f16: atemp8	 $f17: atemp6	 $f18: ctemp4	 $f19: ctemp3
 $f20: atemp2  	 $f21: atemp7	 $f22: temp11,7	 $f23: temp12,8
 $f24: temp_r	 $f25: temp_i	 $f26: atemp1	 $f27: ctemp2
 $f28: ctemp1	 $f29: atemp2	 $f30: atemp5	 $f31: Zero
*/
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

	lda	$sp,-STACKSIZE($sp)
	stt	$f2,  0($sp)
	stt	$f3,  8($sp)
	stt	$f4, 16($sp)
	stt	$f5, 24($sp)
	stt	$f6, 32($sp)
#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	ldl	$20, STACKSIZE+ 0($sp)	# incx
	fabs	$f19, $f10
	ldq	$19, STACKSIZE+ 8($sp)	# y
	fabs	$f20, $f11

	ldl	$22, STACKSIZE+16($sp)	# incy
	fmov	$f19, $f1		# alpha_r
	ldq	$23, STACKSIZE+24($sp)	# a
	fmov	$f20, $f2		# alpha_i

	ldl	$24, STACKSIZE+32($sp)	# lda
	clr	$18
	ldq	$27, STACKSIZE+40($sp)	# buffer
	or	$16, $17, $1

	addq	$20, $20, $20		# incx *= 2
	addq	$22, $22, $22		# incy *= 2
	addq	$24, $24, $24
	beq	$1,  $End

	lda	$1,  2
	ADD	$f10, $f11, $f10
	clr	$3			# is = 0
	cmpeq	$20, 2, $1

	cmovne	$1,  0, $20
	fbeq	$f10,$End
	.align 4

$L23:
	subl	$16, $3,  $7		# min_i = m - is
	lda	$2,  Q
	cmple	$7, $2, $1
	mov	$19, $8			# b_offset = y

	cmoveq	$1, $2, $7
	mov	$23, $28		# a_orig = a
	mov	$17, $4			# j = n
	mov	$27, $5

	mov	$7, $25
	beq	$20, $L39
	.align 4

$Copy_Loop:
	LD	$f30, 0*SIZE($21)
	LD	$f17, 1*SIZE($21)
	ST	$f30, 0*SIZE($5)	
	ST	$f17, 1*SIZE($5)	
	SXADDQ	$20, $21, $21
	lda	$5,   2*SIZE($5)
	lda	$25, -1($25)
	bgt	$25, $Copy_Loop
	.align 4

$L39:
	LD	$f26,   0*SIZE($8)
	mov	$28, $5			# a_offset = a_orig + is
	LD	$f29,   1*SIZE($8)
	mov	$21, $25		# x

	MUL	$f1, $f26, $f11
	cmovne	$20, $27, $25
	MUL	$f2, $f29, $f12
	lda	$4,  -1($4)

	MUL	$f1, $f29, $f10
	sra	$7,  2,   $6		# i = (min_i >> 2)
	MUL	$f2, $f26, $f13
	SXADDQ	$22, $8,  $8		# b_offset += incy

#ifndef CONJ
	SUB	$f11, $f12, $f24
	unop
	ADD	$f13, $f10, $f25
#else
	ADD	$f11, $f12, $f24
	unop
	SUB	$f13, $f10, $f25
#endif
	ble	$6,$L28
	.align 4

	LD	$f30,  0*SIZE($25)
	LD	$f17,  1*SIZE($25)
	LD	$f21,  2*SIZE($25)
	LD	$f16,  3*SIZE($25)

	LD	$f28,  0*SIZE($5)
	LD	$f27,  1*SIZE($5)
	LD	$f19,  2*SIZE($5)
	LD	$f18,  3*SIZE($5)

	MUL	$f30, $f24, $f11	# temp1  = atemp5 * temp_r
	LD	$f26,  4*SIZE($25)
	MUL	$f30, $f25, $f12	# temp2  = atemp5 * temp_i
	LD	$f29,  5*SIZE($25)

	MUL	$f21, $f24, $f10	# temp3  = atemp7 * temp_r
	LD	$f20,  6*SIZE($25)
	MUL	$f21, $f25, $f13	# temp4  = atemp7 * temp_i
	LD	$f0,   7*SIZE($25)

	ADD	$f28, $f11, $f3		# temp5  = ctemp1 + temp1
	lda	$6,    -1($6)
	MUL	$f17, $f25, $f11	# temp1  = atemp6 * temp_i
	LD	$f28,  4*SIZE($5)

	ADD	$f27, $f12, $f4		# temp6  = ctemp2 + temp2
	unop
	MUL	$f17, $f24, $f12	# temp2  = atemp6 * temp_r
	LD	$f27,  5*SIZE($5)

	ADD	$f19, $f10, $f5		# temp7  = ctemp3 + temp3
	unop
	MUL	$f16, $f25, $f10	# temp3  = atemp8 * temp_i
	LD	$f19,  6*SIZE($5)

	ADD	$f18, $f13, $f6		# temp8  = ctemp4 + temp4
	MUL	$f16, $f24, $f13	# temp4  = atemp8 * temp_r
	LD	$f18,  7*SIZE($5)
	ble	$6,$L29
	.align 4

$MainLoop:
	SUB	$f3,  $f11, $f14	# temp9  = temp5 - temp1
	lds	$f31, 24*SIZE($5)
	MUL	$f26, $f24, $f11	# temp1  = atemp1 * temp_r
	LD	$f30,  8*SIZE($25)	# atemp5

	ADD	$f4,  $f12, $f15	# temp10 = temp6 - temp2
	LD	$f17,  9*SIZE($25)	# atemp6
	MUL	$f26, $f25, $f12	# temp2  = atemp1 * temp_i
	LD	$f26, 12*SIZE($25)	# atemp1

	SUB	$f5,  $f10, $f22	# temp11 = temp7 - temp3
	LD	$f31, 32*SIZE($25)
	MUL	$f20, $f24, $f10	# temp3  = atemp3 * temp_r
	LD	$f21, 10*SIZE($25)	# atemp7

	ADD	$f6,  $f13, $f23	# temp12 = temp8 - temp4
	LD	$f16, 11*SIZE($25)	# atemp8
	MUL	$f20, $f25, $f13	# temp4  = atemp3 * temp_i
	LD	$f20, 14*SIZE($25)	# atemp3

	ADD	$f28, $f11, $f3		# temp5  = ctemp1 + temp1
	LD	$f28,  8*SIZE($5)	# ctemp1
	MUL	$f29, $f25, $f11	# temp1  = atemp2 * temp_i
	lda	$6,    -1($6)

	ST	$f14,  0*SIZE($5)	# temp9
	ST	$f15,  1*SIZE($5)	# temp10
	ST	$f22,  2*SIZE($5)	# temp11
	ST	$f23,  3*SIZE($5)	# temp12

	ADD	$f27, $f12, $f4		# temp6  = ctemp2 + temp2
	LD	$f27,  9*SIZE($5)	# ctemp2
	MUL	$f29, $f24, $f12	# temp2  = atemp2 * temp_r
	LD	$f29, 13*SIZE($25)	# atemp2

	ADD	$f19, $f10, $f5		# temp7  = ctemp3 + temp3
	LD	$f19, 10*SIZE($5)	# ctemp3
	MUL	$f0,  $f25, $f10	# temp3  = atemp4 * temp_i
	unop

	ADD	$f18, $f13, $f6		# temp8  = ctemp4 + temp4
	LD	$f18, 11*SIZE($5)	# ctemp4
	MUL	$f0,  $f24, $f13	# temp4  = atemp4 * temp_r
	unop

	SUB	$f3,  $f11, $f14	# temp9  = temp5 - temp1
	unop
	MUL	$f30, $f24, $f11	# temp1  = atemp5 * temp_r
	LD	$f0,  15*SIZE($25)	# atemp4

	ADD	$f4,  $f12, $f15	# temp10 = temp6 + temp2
	unop
	MUL	$f30, $f25, $f12	# temp2  = atemp5 * temp_i
	lda	$25, 8*SIZE($25)

	SUB	$f5,  $f10, $f22	# temp11 = temp7 - temp3
	MUL	$f21, $f24, $f10	# temp3  = atemp7 * temp_r
	ADD	$f6,  $f13, $f23	# temp12 = temp8 + temp4
	MUL	$f21, $f25, $f13	# temp4  = atemp8 * temp_i

	ADD	$f28, $f11, $f3		# temp5  = ctemp1 + temp1
	LD	$f28, 12*SIZE($5)	# ctemp1
	MUL	$f17, $f25, $f11	# temp1  = atemp6 * temp_i
	ST	$f14,  4*SIZE($5)	# temp9

	ADD	$f27, $f12, $f4		# temp6  = ctemp2 + temp2
	LD	$f27, 13*SIZE($5)	# ctemp2
	MUL	$f17, $f24, $f12	# temp2  = atemp6 * temp_r
	ST	$f15,  5*SIZE($5)	# temp10

	ADD	$f19, $f10, $f5		# temp7  = ctemp3 + temp3
	MUL	$f16, $f25, $f10	# temp3  = atemp8 * temp_i
	LD	$f19, 14*SIZE($5)	# ctemp3
	ST	$f22,  6*SIZE($5)	# temp11

	ADD	$f18, $f13, $f6		# temp8  = ctemp4 + temp4
	MUL	$f16, $f24, $f13	# temp4  = atemp8 * temp_r
	LD	$f18, 15*SIZE($5)	# ctemp4
	ST	$f23,  7*SIZE($5)	# temp12

	lda	$5,  8*SIZE($5)
	bgt	$6,  $MainLoop
	.align 4

$L29:
	SUB	$f3,  $f11, $f14	# temp9  = temp5 - temp1
	MUL	$f26, $f24, $f11	# temp1  = atemp1 * temp_r
	ADD	$f4,  $f12, $f15	# temp10 = temp6 - temp2
	MUL	$f26, $f25, $f12	# temp2  = atemp1 * temp_i

	SUB	$f5,  $f10, $f22	# temp11 = temp7 - temp3
	MUL	$f20, $f24, $f10	# temp3  = atemp3 * temp_r
	ADD	$f6,  $f13, $f23	# temp12 = temp8 - temp4
	MUL	$f20, $f25, $f13	# temp4  = atemp3 * temp_i

	ADD	$f28, $f11, $f3		# temp5  = ctemp1 + temp1
	MUL	$f29, $f25, $f11	# temp1  = atemp2 * temp_i
	ADD	$f27, $f12, $f4		# temp6  = ctemp2 + temp2
	MUL	$f29, $f24, $f12	# temp2  = atemp2 * temp_r

	ADD	$f19, $f10, $f5		# temp7  = ctemp3 + temp3
	ST	$f14,  0*SIZE($5)
	MUL	$f0,  $f25, $f10	# temp3  = atemp4 * temp_i
	unop

	ADD	$f18, $f13, $f6		# temp8  = ctemp4 + temp4
	ST	$f15,  1*SIZE($5)
	MUL	$f0,  $f24, $f13	# temp4  = atemp4 * temp_r
	unop

	SUB	$f3,  $f11, $f14	# temp9  = temp5 - temp1
	ST	$f22,  2*SIZE($5)
	ADD	$f4,  $f12, $f15	# temp10 = temp6 + temp2
	lda	$25, 8*SIZE($25)

	SUB	$f5,  $f10, $f22	# temp11 = temp7 - temp3
	ST	$f23,  3*SIZE($5)
	ADD	$f6,  $f13, $f23	# temp12 = temp8 + temp4
	lda	$5,  8*SIZE($5)

	ST	$f14, -4*SIZE($5)
	ST	$f15, -3*SIZE($5)
	ST	$f22, -2*SIZE($5)
	ST	$f23, -1*SIZE($5)
	.align 4

$L28:
	and	$7, 3, $6
	ble	$6, $L34
	.align 4

$L38:
	LD	$f26,  0*SIZE($25)
	LD	$f29,  1*SIZE($25)
	LD	$f28,  0*SIZE($5)
	LD	$f27,  1*SIZE($5)

	MUL	$f26, $f25, $f12
	MUL	$f26, $f24, $f11
	MUL	$f29, $f24, $f13
	MUL	$f29, $f25, $f10

	ADD	$f28, $f11, $f14
	ADD	$f27, $f12, $f15
	SUB	$f14, $f10, $f14
	ADD	$f15, $f13, $f15

	lda	$25,   2*SIZE($25)
	lda	$6,    -1($6)
	ST	$f14,  0*SIZE($5)
	ST	$f15,  1*SIZE($5)

	lda	$5,    2*SIZE($5)
	bgt	$6, $L38
	.align 4

$L34:
	SXADDQ	$24, $28, $28		# a_orig += lda
	unop
	unop
	bgt	$4, $L39
	.align 4

	lda	$2,  2*Q*SIZE($21)	# c_offset = x + is
	lda	$23,  2*Q*SIZE($23)
	lda	$3, Q($3)
	cmoveq	$20, $2, $21
	cmplt	$3,$16,$1
	bne	$1,$L23
	.align 4


$End:
	clr	$0
	ldt	$f2,  0($sp)
	ldt	$f3,  8($sp)
	ldt	$f4, 16($sp)
	ldt	$f5, 24($sp)
	ldt	$f6, 32($sp)
	lda	$sp, STACKSIZE($sp)
	ret
	.end NAME
	.ident VERSION
