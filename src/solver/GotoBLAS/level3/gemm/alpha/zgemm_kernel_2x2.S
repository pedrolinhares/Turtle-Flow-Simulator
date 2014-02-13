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

#if !defined(EV4) && !defined(EV5) && !defined(EV6)
#error "Architecture is not specified."
#endif

#ifdef EV6
#define PREFETCHSIZE 48
#define UNOP unop
#endif

#ifdef EV5
#define PREFETCHSIZE 48
#define UNOP
#endif

#ifdef EV4
#define UNOP
#endif

	.set	noat
	.set	noreorder
	.arch ev6

.text
	.align	5
	.globl	CNAME
	.ent	CNAME

#define STACKSIZE 80

#define M	$16
#define N	$17
#define K	$18
#define A	$21
#define	B	$22
#define C	$20
#define	LDC	$23

#define C1	$19
#define C2	$24

#define AO	$at
#define	BO	$5
#define I	$6
#define J	$7
#define L	$8

#define a1	$f16
#define a2	$f17
#define a3	$f18
#define a4	$f19

#define b1	$f20
#define b2	$f21
#define b3	$f22
#define b4	$f23

#define t1	$f24
#define t2	$f25
#define t3	$f26
#define t4	$f27

#define a5	$f28
#define a6	$f30
#define b5	$f29

#define alpha_i	$f29
#define alpha_r	$f30

#define c01	$f0
#define c02	$f1
#define c03	$f2
#define c04	$f3

#define c05	$f4
#define c06	$f5
#define c07	$f6
#define c08	$f7

#define c09	$f8
#define c10	$f9
#define c11	$f10
#define c12	$f11

#define c13	$f12
#define c14	$f13
#define c15	$f14
#define c16	$f15

#define ALPHA_R	64($sp)
#define ALPHA_I	72($sp)


CNAME:
	.frame	$sp, STACKSIZE, $26, 0

#ifdef PROFILE
	ldgp	$gp, 0($27)
	lda	$at, _mcount
	jsr	$at, ($at), _mcount
#endif

#ifndef PROFILE
	.prologue 0
#else
	.prologue 1
#endif

	lda	$sp, -STACKSIZE($sp)

	ldq	B,        0 + STACKSIZE($sp)
	ldq	C,        8 + STACKSIZE($sp)
	ldq	LDC,     16 + STACKSIZE($sp)

	sll	LDC, ZBASE_SHIFT, LDC

	stt	$f2,   0($sp)
	stt	$f3,   8($sp)
	stt	$f4,  16($sp)
	stt	$f5,  24($sp)
	stt	$f6,  32($sp)
	stt	$f7,  40($sp)
	stt	$f8,  48($sp)
	stt	$f9,  56($sp)
	stt	$f19, ALPHA_R
	stt	$f20, ALPHA_I

	cmple	M, 0, $0
	cmple	N, 0, $1
	cmple	K, 0, $2

	or	$0, $1, $0
	or	$0, $2, $0
	bne	$0, $L999

$L00:
	sra	N, 1, J
	ble	J, $L30
	.align 4
	
$L01:
	mov	C,  C1
	addq	C,  LDC, C2
	mov	A, AO
	lda	J,        -1(J)

	addq	C2, LDC, C
	unop
	.align 4

$L10:
	sra	M,  1, I
	fclr	t1
	fclr	t2
	fclr	t3
	fclr	t4

	fclr	c01
	fclr	c05
 	fclr	c09
	fclr	c13
	ble	I, $L20
	.align 4

$L11:
	LD	a1,  0 * SIZE(AO)
	fclr	c02
	LD	a2,  1 * SIZE(AO)
	fclr	c06
	LD	a3,  2 * SIZE(AO)
	fclr	c10
	LD	a4,  3 * SIZE(AO)
	fclr	c14

	LD	b1,  0 * SIZE(B)
	fclr	c03
	LD	b2,  1 * SIZE(B)
	fclr	c07
	LD	b3,  2 * SIZE(B)
	fclr	c11
	LD	b4,  3 * SIZE(B)
	fclr	c15

 	lds	$f31,  4 * SIZE(C1)
	fclr	c04
	lda	L,        -2(K)
	unop

	lds	$f31,  4 * SIZE(C2)
	unop
	lda	BO,  4 * SIZE(B)
	fclr	c08

	unop
	lda	AO,  4 * SIZE(AO)
	fclr	c12

	fclr	c16
	unop
	ble	L, $L15
	.align	5

$L12:
/*  1 */
	ADD	c11,  t1, c11
#ifndef EV4
	ldq	$31,  PREFETCHSIZE * SIZE(AO)
#else
	unop
#endif
	MUL	b1, a1, t1
#ifndef EV4
	ldl	$31,  PREFETCHSIZE * SIZE(BO)
#else
	unop
#endif

	ADD	c12,  t2, c12
	unop
	MUL	b1, a2, t2
	unop

	ADD	c16,  t3, c16
	unop
	MUL	b2, a2, t3
	LD	a5,   0 * SIZE(AO)

	ADD	c15, t4, c15
	unop
	MUL	b2, a1, t4
	LD	b5,   0 * SIZE(BO)

/*  2 */
	ADD	c01, t1, c01
	UNOP
	MUL	b1, a3, t1
	UNOP

	ADD	c02, t2, c02
	UNOP
	MUL	b1, a4, t2
	UNOP

	ADD	c06,  t3, c06
	unop
	MUL	b2, a4, t3
	unop

	ADD	c05, t4, c05
	unop
	MUL	b4, a1, t4
	unop

/*  3 */
	ADD	c03, t1, c03
	unop
	MUL	b3, a1, t1
	unop

	ADD	c04, t2, c04
	unop
	MUL	b3, a2, t2
	unop

	ADD	c08,  t3, c08
	unop
	MUL	b4, a2, t3
	LD	a2,  1 * SIZE(AO)

	ADD	c13, t4, c13
	unop
	MUL	b2, a3, t4
	LD	b2,  1 * SIZE(BO)

/*  4 */
	ADD	c09,  t1, c09
	unop
	MUL	b3, a3, t1
	LD	a6,  2 * SIZE(AO)

	ADD	c10,  t2, c10
	unop
	MUL	b3, a4, t2
	LD	b3,  2 * SIZE(BO)

	ADD	c14, t3, c14
	unop
	MUL	b4, a4, t3
	LD	a4,  3 * SIZE(AO)

	ADD	c07,  t4, c07
	unop
	MUL	b4, a3, t4
	LD	b4,  3 * SIZE(BO)

/*  5 */
	ADD	c11,  t1, c11
	unop
	MUL	b5,  a5,  t1
	LD	a1,  4 * SIZE(AO)

	ADD	c12,  t2, c12
	lda	L,        -2(L)
	MUL	b5,  a2, t2
	LD	b1,  4 * SIZE(BO)

	ADD	c16,  t3, c16
	unop
	MUL	b2, a2, t3
	unop

	ADD	c15, t4, c15
	unop
	MUL	b2, a5,  t4
	unop

/*  6 */
	ADD	c01, t1, c01
	unop
	MUL	b5,  a6, t1
	unop

	ADD	c02, t2, c02
	unop
	MUL	b5,  a4, t2
	unop

	ADD	c06,  t3, c06
	unop
	MUL	b2, a4, t3
	unop

	ADD	c05, t4, c05
	unop
	MUL	b4, a5,  t4
	unop

/*  7 */
	ADD	c03, t1, c03
	lda	AO,    8 * SIZE(AO)
	MUL	b3, a5,  t1
	unop

	ADD	c04, t2, c04
	lda	BO,    8 * SIZE(BO)
	MUL	b3, a2, t2
	unop

	ADD	c08,  t3, c08
	unop
	MUL	b4, a2, t3
	LD	a2, -3 * SIZE(AO)

	ADD	c13, t4, c13
	unop
	MUL	b2, a6, t4
	LD	b2, -3 * SIZE(BO)

/*  8 */
	ADD	c09,  t1, c09
	unop
	MUL	b3, a6, t1
	LD	a3, -2 * SIZE(AO)

	ADD	c10,  t2, c10
	unop
	MUL	b3, a4, t2
	LD	b3, -2 * SIZE(BO)

	ADD	c14, t3, c14
	unop
	MUL	b4, a4, t3
	LD	a4, -1 * SIZE(AO)

	ADD	c07,  t4, c07
	MUL	b4, a6, t4
	LD	b4, -1 * SIZE(BO)
	bgt	L,  $L12
	.align 4

$L15:
	ADD	c11,  t1, c11
	ldt	alpha_r, ALPHA_R
	MUL	b1, a1, t1
	blbs	K, $L18
	.align 4

	ADD	c12,  t2, c12
	MUL	b1, a2, t2
	ADD	c16,  t3, c16
	MUL	b2, a2, t3

	ADD	c15, t4, c15
	MUL	b2, a1, t4
	ADD	c01, t1, c01
	MUL	b1, a3, t1

	ADD	c02, t2, c02
	unop
	MUL	b1, a4, t2
	LD	b1,  0 * SIZE(BO)

	ADD	c06,  t3, c06
	MUL	b2, a4, t3
	ADD	c05, t4, c05
	MUL	b4, a1, t4

	ADD	c03, t1, c03
	unop
	MUL	b3, a1, t1
	LD	a1,  0 * SIZE(AO)

	ADD	c04, t2, c04
	unop
	MUL	b3, a2, t2
	unop

	ADD	c08,  t3, c08
	unop
	MUL	b4, a2, t3
	LD	a2,  1 * SIZE(AO)

	ADD	c13, t4, c13
	unop
	MUL	b2, a3, t4
	LD	b2,  1 * SIZE(BO)

	ADD	c09,  t1, c09
	unop
	MUL	b3, a3, t1
	lda	AO,  4 * SIZE(AO)

	ADD	c10,  t2, c10
	unop
	MUL	b3, a4, t2
 	LD	b3,  2 * SIZE(BO)

	ADD	c14, t3, c14
	unop
	MUL	b4, a4, t3
	LD	a4, -1 * SIZE(AO)

	ADD	c07,  t4, c07
	unop
	MUL	b4, a3, t4
	LD	a3, -2 * SIZE(AO)

	ADD	c11,  t1, c11
	LD	b4,  3 * SIZE(BO)
	MUL	b1, a1, t1
	lda	BO,  4 * SIZE(BO)
	.align 4

$L18:
	ADD	c12,  t2, c12
	unop
	MUL	b1, a2, t2
	ldt	alpha_i, ALPHA_I

	ADD	c16,  t3, c16
	unop
	MUL	b2, a2, t3
	LD	a5, 0 * SIZE(C1)

	ADD	c15, t4, c15
	MUL	b2, a1, t4
	ADD	c01, t1, c01
	MUL	b1, a3, t1

	ADD	c02, t2, c02
	unop
	MUL	b1, a4, t2
	LD	b1, 1 * SIZE(C1)

	ADD	c06,  t3, c06
	MUL	b2, a4, t3
	ADD	c05, t4, c05
	MUL	b4, a1, t4

	ADD	c03, t1, c03
	unop
	MUL	b3, a1, t1
	LD	a1, 2 * SIZE(C1)

	ADD	c04, t2, c04
	unop
	MUL	b3, a2, t2
	unop

	ADD	c08,  t3, c08
	unop
	MUL	b4, a2, t3
	LD	a2, 3 * SIZE(C1)

	ADD	c13, t4, c13
	unop
	MUL	b2, a3, t4
	LD	b2, 0 * SIZE(C2)

	ADD	c09,  t1, c09
	lda	I,        -1(I)
	MUL	b3, a3, t1
	unop

	ADD	c10,  t2, c10
	unop
	MUL	b3, a4, t2
	LD	b3, 1 * SIZE(C2)

	ADD	c14, t3, c14
	unop
	MUL	b4, a4, t3
  	LD	a4, 2 * SIZE(C2)

	ADD	c07,  t4, c07
	unop
	MUL	b4, a3, t4
	LD	a3, 3 * SIZE(C2)

	ADD	c11,  t1, c11
	ADD	c12,  t2, c12
	ADD	c16,  t3, c16
	ADD	c15,  t4, c15

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(CC) || defined(CR) || defined(RC) || defined(RR)
	SUB	c01, c06, c01
	ADD	c02, c05, c02
	SUB	c03, c08, c03
	ADD	c04, c07, c04

	SUB	c09, c14, c09
	MUL	  alpha_r, c01, t1
	ADD	c10, c13, c10
	MUL	  alpha_r, c02, t2

	SUB	c11, c16, c11
	MUL	  alpha_r, c03, t3
	ADD	c12, c15, c12
	MUL	  alpha_r, c04, t4
#else
	ADD	c01, c06, c01
	SUB	c02, c05, c02
	ADD	c03, c08, c03
	SUB	c04, c07, c04

	ADD	c09, c14, c09
	MUL	  alpha_r, c01, t1
	SUB	c10, c13, c10
	MUL	  alpha_r, c02, t2

	ADD	c11, c16, c11
	MUL	  alpha_r, c03, t3
	SUB	c12, c15, c12
	MUL	  alpha_r, c04, t4
#endif


#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(NC) || defined(TC) || defined(NR) || defined(TR)
	ADD	  a5,  t1,  a5
	MUL	  alpha_i, c02, t1
	ADD	  b1,  t2,  b1
	MUL	  alpha_i, c01, t2

	ADD	  a1,  t3,  a1
	MUL	  alpha_i, c04, t3
	ADD	  a2,  t4,  a2
	MUL	  alpha_i, c03, t4

	SUB	  a5,  t1,  a5
	MUL	  alpha_r, c09, t1
	ADD	  b1,  t2,  b1
	MUL	  alpha_r, c10, t2

	SUB	  a1,  t3,  a1
	MUL	  alpha_r, c11, t3
	ADD	  a2,  t4,  a2
	MUL	  alpha_r, c12, t4

	ADD	  b2,  t1,  b2
	MUL	  alpha_i, c10, t1
	ADD	  b3,  t2,  b3
	MUL	  alpha_i, c09, t2

	ADD	  a4,  t3,  a4
	MUL	  alpha_i, c12, t3
	ADD	  a3,  t4,  a3
	MUL	  alpha_i, c11, t4

	SUB	  b2,  t1,  b2
	ST	a5,  0 * SIZE(C1)
	fclr	t1
	unop

	ADD	  b3,  t2,  b3
	ST	b1,  1 * SIZE(C1)
	fclr	t2
	unop

	SUB	  a4,  t3,  a4
	ST	a1,  2 * SIZE(C1)
	fclr	t3
	unop

	ADD	  a3,  t4,  a3
	ST	a2,  3 * SIZE(C1)
	fclr	t4
	lda	C1,   4 * SIZE(C1)
#else
	ADD	  a5,  t1,  a5
	MUL	  alpha_i, c02, t1
	SUB	  b1,  t2,  b1
	MUL	  alpha_i, c01, t2

	ADD	  a1,  t3,  a1
	MUL	  alpha_i, c04, t3
	SUB	  a2,  t4,  a2
	MUL	  alpha_i, c03, t4

	ADD	  a5,  t1,  a5
	MUL	  alpha_r, c09, t1
	ADD	  b1,  t2,  b1
	MUL	  alpha_r, c10, t2

	ADD	  a1,  t3,  a1
	MUL	  alpha_r, c11, t3
	ADD	  a2,  t4,  a2
	MUL	  alpha_r, c12, t4

	ADD	  b2,  t1,  b2
	MUL	  alpha_i, c10, t1
	SUB	  b3,  t2,  b3
	MUL	  alpha_i, c09, t2

	ADD	  a4,  t3,  a4
	MUL	  alpha_i, c12, t3
	SUB	  a3,  t4,  a3
	MUL	  alpha_i, c11, t4

	ADD	  b2,  t1,  b2
	ST	a5,  0 * SIZE(C1)
	fclr	t1
	unop

	ADD	  b3,  t2,  b3
	ST	b1,  1 * SIZE(C1)
	fclr	t2
	unop

	ADD	  a4,  t3,  a4
	ST	a1,  2 * SIZE(C1)
	fclr	t3
	unop

	ADD	  a3,  t4,  a3
	ST	a2,  3 * SIZE(C1)
	fclr	t4
	lda	C1,   4 * SIZE(C1)
#endif

	ST	b2,  0 * SIZE(C2)
	fclr	c01
 	ST	b3,  1 * SIZE(C2)
	fclr	c05

	ST	a4,  2 * SIZE(C2)
	unop
 	fclr	c09
	unop

	ST	a3,  3 * SIZE(C2)
	fclr	c13
	lda	C2,   4 * SIZE(C2)
	bgt	I, $L11
	.align 4

$L20:
	and	M,  1, I
	ble	I, $L29
	.align 4

$L21:
	LD	a1,  0 * SIZE(AO)
	fclr	c02
	LD	a2,  1 * SIZE(AO)
	fclr	c06

	LD	a3,  2 * SIZE(AO)
	fclr	c10
	LD	a4,  3 * SIZE(AO)
	fclr	c14

	LD	b1,  0 * SIZE(B)
	lda	L,        -2(K)
	LD	b2,  1 * SIZE(B)
	lda	AO,  2 * SIZE(AO)

	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)
	lda	BO,  4 * SIZE(B)
	ble	L, $L25
	.align	5

$L22:
	ADD	c09, t1, c09
	unop
	MUL	a1, b1, t1
	unop

	ADD	c10, t2, c10
	unop
	MUL	a2, b1, t2
	LD	b1,  0 * SIZE(BO)

	ADD	c13, t3, c13
	unop
	MUL	a1, b2, t3
	lda	BO,    8 * SIZE(BO)

	ADD	c14, t4, c14
	unop
	MUL	a2, b2, t4
	LD	b2, -7 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b3, t1
	unop

	ADD	c02, t2, c02
	unop
	MUL	a2, b3, t2
	LD	b3, -6 * SIZE(BO)

	ADD	c05, t3, c05
	unop
	MUL	a1, b4, t3
	LD	a1,  2 * SIZE(AO)

	ADD	c06, t4, c06
	MUL	a2, b4, t4
	LD	b5, -5 * SIZE(BO)

	ADD	c09, t1, c09
	unop
	MUL	a3, b1, t1
	LD	a2,  3 * SIZE(AO)

	ADD	c10, t2, c10
	unop
	MUL	a4, b1, t2
	LD	b1, -4 * SIZE(BO)

	ADD	c13, t3, c13
	unop
	MUL	a3, b2, t3
	lda	AO,    4 * SIZE(AO)

	ADD	c14, t4, c14
	MUL	a4, b2, t4
	LD	b2, -3 * SIZE(BO)

	ADD	c01, t1, c01
	lda	L,        -2(L)
	MUL	a3, b3, t1
	LD	b4, -1 * SIZE(BO)

	ADD	c02, t2, c02
	unop
	MUL	a4, b3, t2
	LD	b3, -2 * SIZE(BO)

	ADD	c05, t3, c05
	unop
	MUL	a3, b5, t3
	LD	a3,  0 * SIZE(AO)

	ADD	c06, t4, c06
	MUL	a4, b5, t4
	LD	a4,  1 * SIZE(AO)
	bgt	L,  $L22
	.align 4

$L25:
	ADD	c09, t1, c09
	ldt	alpha_r, ALPHA_R
	MUL	a1, b1, t1
	blbs	K, $L28
	.align 4

	ADD	c10, t2, c10
	unop
	MUL	a2, b1, t2
	LD	b1,  0 * SIZE(BO)

	ADD	c13, t3, c13
	unop
	MUL	a1, b2, t3
	unop

	ADD	c14, t4, c14
	unop
	MUL	a2, b2, t4
	LD	b2,  1 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b3, t1
	lda	AO,  2 * SIZE(AO)

	ADD	c02, t2, c02
	unop
	MUL	a2, b3, t2
	LD	b3,  2 * SIZE(BO)

	ADD	c05, t3, c05
	unop
	MUL	a1, b4, t3
	LD	a1, -2 * SIZE(AO)

	ADD	c06, t4, c06
	unop
	MUL	a2, b4, t4
	LD	a2, -1 * SIZE(AO)

	ADD	c09, t1, c09
	LD	b4,  3 * SIZE(BO)
	MUL	a1, b1, t1
	lda	BO,  4 * SIZE(BO)
	.align 4

$L28:
	ADD	c10, t2, c10
	unop
	MUL	a2, b1, t2
	ldt	alpha_i, ALPHA_I

	ADD	c13, t3, c13
	unop
	MUL	a1, b2, t3
	LD	c03, 0 * SIZE(C1)

	ADD	c14, t4, c14
	unop
	MUL	a2, b2, t4
	LD	c04, 1 * SIZE(C1)

	ADD	c01, t1, c01
	unop
	MUL	a1, b3, t1
	LD	c11, 0 * SIZE(C2)

	ADD	c02, t2, c02
	unop
	MUL	a2, b3, t2
	LD	c12, 1 * SIZE(C2)

	ADD	c05, t3, c05
	MUL	a1, b4, t3
	ADD	c06, t4, c06
	MUL	a2, b4, t4

	ADD	c09, t1, c09
	ADD	c10, t2, c10
	ADD	c13, t3, c13
	ADD	c14, t4, c14

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(CC) || defined(CR) || defined(RC) || defined(RR)
	SUB	c01, c06, c01
	ADD	c02, c05, c02
	SUB	c09, c14, c09
	ADD	c10, c13, c10
#else
	ADD	c01, c06, c01
	SUB	c02, c05, c02
	ADD	c09, c14, c09
	SUB	c10, c13, c10
#endif

	MUL	  alpha_r, c01, t1
	MUL	  alpha_r, c02, t2
	MUL	  alpha_r, c09, t3
	MUL	  alpha_r, c10, t4

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(NC) || defined(TC) || defined(NR) || defined(TR)
	ADD	  c03,  t1,  c03
	MUL	  alpha_i, c02, t1
	ADD	  c04,  t2,  c04
	MUL	  alpha_i, c01, t2

	ADD	  c11,  t3,  c11
	MUL	  alpha_i, c10, t3
	ADD	  c12,  t4,  c12
	MUL	  alpha_i, c09, t4

	SUB	  c03,  t1,  c03
	ADD	  c04,  t2,  c04
	SUB	  c11,  t3,  c11
	ADD	  c12,  t4,  c12
#else
	ADD	  c03,  t1,  c03
	MUL	  alpha_i, c02, t1
	SUB	  c04,  t2,  c04
	MUL	  alpha_i, c01, t2

	ADD	  c11,  t3,  c11
	MUL	  alpha_i, c10, t3
	SUB	  c12,  t4,  c12
	MUL	  alpha_i, c09, t4

	ADD	  c03,  t1,  c03
	ADD	  c04,  t2,  c04
	ADD	  c11,  t3,  c11
	ADD	  c12,  t4,  c12
#endif

	ST	c03,  0 * SIZE(C1)
	ST	c04,  1 * SIZE(C1)
	ST	c11,  0 * SIZE(C2)
 	ST	c12,  1 * SIZE(C2)
	.align 4

$L29:
 	mov	BO, B
	unop
	unop
	bgt	J, $L01
	.align 4

$L30:
	and	N, 1, J
	mov	C,  C1
	mov	A, AO
	ble	J, $L999
	.align 4

$L40:
	sra	M,  1, I
	fclr	t1
	fclr	t2
	fclr	t3
	fclr	t4

	fclr	c01
	fclr	c05
 	fclr	c02
	fclr	c06
	ble	I, $L50
	.align 4

$L41:
	LD	a1,  0 * SIZE(AO)
	fclr	c03
	LD	a2,  1 * SIZE(AO)
	fclr	c07
	LD	a3,  2 * SIZE(AO)
	fclr	c04
	LD	a4,  3 * SIZE(AO)
	fclr	c08

	LD	b1,  0 * SIZE(B)
	LD	b2,  1 * SIZE(B)
	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)

	lda	L,        -2(K)
	lda	BO,  2 * SIZE(B)
	lda	AO,  4 * SIZE(AO)
	ble	L, $L45
	.align	5

$L42:
	ADD	c05, t1, c05
	unop
	MUL	a1, b1, t1
	unop

	ADD	c06, t2, c06
	lda	L,   -2(L)
	MUL	a2, b1, t2
	unop

	ADD	c07, t3, c07
	unop
	MUL	a3, b1, t3
	unop

	ADD	c08, t4, c08
	unop
	MUL	a4, b1, t4
	LD	b1,  2 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b2, t1
	LD	a1,  0 * SIZE(AO)

	ADD	c02, t2, c02
	lda	BO,  4 * SIZE(BO)
	MUL	a2, b2, t2
	LD	a2,  1 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b2, t3
	LD	a3,  2 * SIZE(AO)

	ADD	c04, t4, c04
	unop
	MUL	a4, b2, t4
	LD	a5,  3 * SIZE(AO)

	ADD	c05, t1, c05
	unop
	MUL	a1, b3, t1
	LD	b2, -1 * SIZE(BO)

	ADD	c06, t2, c06
	unop
	MUL	a2, b3, t2
	unop

	ADD	c07, t3, c07
	unop
	MUL	a3, b3, t3
	lda	AO,  8 * SIZE(AO)

	ADD	c08, t4, c08
	unop
	MUL	a5, b3, t4
	LD	b3,  0 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b4, t1
	LD	a1, -4 * SIZE(AO)

	ADD	c02, t2, c02
	unop
	MUL	a2, b4, t2
	LD	a2, -3 * SIZE(AO)

	ADD	c03, t3, c03
	LD	a4, -1 * SIZE(AO)
	MUL	a3, b4, t3
	LD	a3, -2 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a5, b4, t4
	LD	b4,  1 * SIZE(BO)
	bgt	L,  $L42
	.align 4

$L45:
	ADD	c05, t1, c05
	ldt	alpha_r, ALPHA_R
	MUL	b1, a1, t1
	blbs	K, $L48
	.align 4

	ADD	c06, t2, c06
	MUL	a2, b1, t2
	ADD	c07, t3, c07
	MUL	a3, b1, t3

	ADD	c08, t4, c08
	unop
	MUL	a4, b1, t4
	LD	b1,  0 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b2, t1
	LD	a1,  0 * SIZE(AO)

	ADD	c02, t2, c02
	unop
	MUL	a2, b2, t2
	LD	a2,  1 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b2, t3
	LD	a3,  2 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b2, t4
	LD	a4,  3 * SIZE(AO)
	lda	AO,  4 * SIZE(AO)

	ADD	c05, t1, c05
	LD	b2,  1 * SIZE(BO)
	MUL	a1, b1, t1
	lda	BO,  2 * SIZE(BO)
	.align 4

$L48:
	ADD	c06, t2, c06
	unop
	MUL	a2, b1, t2
	ldt	alpha_i, ALPHA_I

	ADD	c07, t3, c07
	lda	I,        -1(I)
	MUL	a3, b1, t3
	LD	c09, 0 * SIZE(C1)

	ADD	c08, t4, c08
	unop
	MUL	a4, b1, t4
	LD	c10, 1 * SIZE(C1)

	ADD	c01, t1, c01
	unop
	MUL	a1, b2, t1
	LD	c11, 2 * SIZE(C1)

	ADD	c02, t2, c02
	unop
	MUL	a2, b2, t2
	LD	c12, 3 * SIZE(C1)

	ADD	c03, t3, c03
	MUL	a3, b2, t3
	ADD	c04, t4, c04
	MUL	a4, b2, t4

	ADD	c05, t1, c05
	ADD	c06, t2, c06
	ADD	c07, t3, c07
	ADD	c08, t4, c08

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(CC) || defined(CR) || defined(RC) || defined(RR)
	SUB	c01, c06, c01
	ADD	c02, c05, c02
	SUB	c03, c08, c03
	ADD	c04, c07, c04
#else
	ADD	c01, c06, c01
	SUB	c02, c05, c02
	ADD	c03, c08, c03
	SUB	c04, c07, c04
#endif

	MUL	  alpha_r, c01, t1
	MUL	  alpha_r, c02, t2
	MUL	  alpha_r, c03, t3
	MUL	  alpha_r, c04, t4

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(NC) || defined(TC) || defined(NR) || defined(TR)
	ADD	  c09,  t1,  c09
	MUL	  alpha_i, c02, t1
	ADD	  c10,  t2,  c10
	MUL	  alpha_i, c01, t2

	ADD	  c11,  t3,  c11
	MUL	  alpha_i, c04, t3
	ADD	  c12,  t4,  c12
	MUL	  alpha_i, c03, t4

	SUB	  c09,  t1,  c09
	fclr	t1
	ADD	  c10,  t2,  c10
	fclr	t2

	SUB	  c11,  t3,  c11
	fclr	t3
	ADD	  c12,  t4,  c12
	fclr	t4
#else
	ADD	  c09,  t1,  c09
	MUL	  alpha_i, c02, t1
	SUB	  c10,  t2,  c10
	MUL	  alpha_i, c01, t2

	ADD	  c11,  t3,  c11
	MUL	  alpha_i, c04, t3
	SUB	  c12,  t4,  c12
	MUL	  alpha_i, c03, t4

	ADD	  c09,  t1,  c09
	fclr	t1
	ADD	  c10,  t2,  c10
	fclr	t2
	ADD	  c11,  t3,  c11
	fclr	t3
	ADD	  c12,  t4,  c12
	fclr	t4
#endif

	ST	c09,  0 * SIZE(C1)
	fclr	c01
	ST	c10,  1 * SIZE(C1)
	fclr	c02

	ST	c11,  2 * SIZE(C1)
	unop
 	fclr	c05
	unop

	ST	c12,  3 * SIZE(C1)
	fclr	c06
	lda	C1,   4 * SIZE(C1)
	bgt	I, $L41
	.align 4

$L50:
	and	M,  1, I
	ble	I, $L999
	.align 4

$L51:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)
	LD	a3,  2 * SIZE(AO)
	LD	a4,  3 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	lda	L,        -2(K)
	LD	b2,  1 * SIZE(B)
	lda	AO,  2 * SIZE(AO)

	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)
	lda	BO,  2 * SIZE(B)
	ble	L, $L55
	.align	5

$L52:
	ADD	c01, t1, c01
	unop
	MUL	a1, b1, t1
	unop

	ADD	c02, t2, c02
	lda	AO,    4 * SIZE(AO)
	MUL	a2, b1, t2
	LD	b1,  2 * SIZE(BO)

	ADD	c05, t3, c05
	lda	L,        -2(L)
	MUL	a1, b2, t3
	LD	a1, -2 * SIZE(AO)

	ADD	c06, t4, c06
	unop
	MUL	a2, b2, t4
	LD	a2, -1 * SIZE(AO)

	ADD	c01, t1, c01
	LD	b2,  3 * SIZE(BO)
	MUL	a3, b3, t1
	lda	BO,    4 * SIZE(BO)

	ADD	c02, t2, c02
	unop
	MUL	a4, b3, t2
	LD	b3,  0 * SIZE(BO)

	ADD	c05, t3, c05
	unop
	MUL	a3, b4, t3
	LD	a3,  0 * SIZE(AO)

	ADD	c06, t4, c06
	MUL	a4, b4, t4
	LD	b4,  1 * SIZE(BO)
	unop

	LD	a4,  1 * SIZE(AO)
	unop
	unop
	bgt	L,  $L52
	.align 4

$L55:
	ADD	c01, t1, c01
	ldt	alpha_r, ALPHA_R
	MUL	a1, b1, t1
	blbs	K, $L58
	.align 4

	ADD	c02, t2, c02
	unop
	MUL	a2, b1, t2
	LD	b1,  0 * SIZE(BO)

	ADD	c05, t3, c05
	lda	BO,  2 * SIZE(BO)
	MUL	a1, b2, t3
	LD	a1,  0 * SIZE(AO)

	ADD	c06, t4, c06
	unop
	MUL	a2, b2, t4
	LD	a2,  1 * SIZE(AO)

	ADD	c01, t1, c01
	LD	b2, -1 * SIZE(BO)
	MUL	a1, b1, t1
	lda	AO,  2 * SIZE(AO)
	.align 4

$L58:
	ADD	c02, t2, c02
	unop
	MUL	a2, b1, t2
	ldt	alpha_i, ALPHA_I

	ADD	c05, t3, c05
	unop
	MUL	a1, b2, t3
	LD	c03, 0 * SIZE(C1)

	ADD	c06, t4, c06
	unop
	MUL	a2, b2, t4
	LD	c04, 1 * SIZE(C1)

	ADD	c01, t1, c01
	ADD	c02, t2, c02
	ADD	c05, t3, c05
	ADD	c06, t4, c06

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(CC) || defined(CR) || defined(RC) || defined(RR)
	SUB	c01, c06, c01
	ADD	c02, c05, c02
#else
	ADD	c01, c06, c01
	SUB	c02, c05, c02
#endif

	MUL	  alpha_r, c01, t1
	MUL	  alpha_r, c02, t2
	MUL	  alpha_i, c02, t3
	MUL	  alpha_i, c01, t4

#if   defined(NN) || defined(NT) || defined(TN) || defined(TT) || \
      defined(NC) || defined(TC) || defined(NR) || defined(TR)
	ADD	  c03,  t1,  c03
	ADD	  c04,  t2,  c04
	SUB	  c03,  t3,  c03
	ADD	  c04,  t4,  c04
#else
	ADD	  c03,  t1,  c03
	SUB	  c04,  t2,  c04
	ADD	  c03,  t3,  c03
	ADD	  c04,  t4,  c04
#endif

	ST	c03,  0 * SIZE(C1)
	ST	c04,  1 * SIZE(C1)
	.align 4


$L999:
	ldt	$f2,   0($sp)
	ldt	$f3,   8($sp)
	ldt	$f4,  16($sp)
	ldt	$f5,  24($sp)
	ldt	$f6,  32($sp)
	ldt	$f7,  40($sp)
	ldt	$f8,  48($sp)
	ldt	$f9,  56($sp)
	clr	$0
	lda	$sp, STACKSIZE($sp)
	ret
	.ident	VERSION
	.end	CNAME
