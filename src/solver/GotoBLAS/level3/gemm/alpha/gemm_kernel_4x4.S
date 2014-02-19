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
#define PREFETCHSIZE 56
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
#define A	$20
#define	B	$21
#define C	$22
#define	LDC	$23

#define C1	$19
#define C2	$24
#define	C3	$25
#define C4	$27

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

#define alpha	$f30

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

#define ALPHA	64($sp)


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

	ldq	C,        0 + STACKSIZE($sp)
	ldq	LDC,      8 + STACKSIZE($sp)

	SXADDQ	LDC, 0, LDC

	stt	$f2,   0($sp)
	stt	$f3,   8($sp)
	stt	$f4,  16($sp)
	stt	$f5,  24($sp)
	stt	$f6,  32($sp)
	stt	$f7,  40($sp)
	stt	$f8,  48($sp)
	stt	$f9,  56($sp)
	stt	$f19, ALPHA

	cmple	M, 0, $0
	cmple	N, 0, $1
	cmple	K, 0, $2

	or	$0, $1, $0
	or	$0, $2, $0
	bne	$0, $L999

$L00:
	sra	N, 2, J
	ble	J, $L40
	.align 4
	
$L01:
	mov	C,  C1
	addq	C,  LDC, C2
	mov	A, AO
	lda	J,        -1(J)

	addq	C2, LDC, C3
	s4addq	LDC, C, C
	unop
	addq	C3, LDC, C4
	.align 4

$L10:
	sra	M,  2, I
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

 	lds	$f31,  4 * SIZE(C3)
	unop
	lda	AO,  4 * SIZE(AO)
	fclr	c12

	lds	$f31,  4 * SIZE(C4)
	fclr	c16
	unop
	ble	L, $L15
	.align	5

$L12:
/*  1 */
	ADD	c11,  t1, c11
#ifndef EV4
	ldq	$31,   PREFETCHSIZE * SIZE(AO)
#else
	unop
#endif
	MUL	b1, a1, t1
#ifndef EV4
	ldl	$31,   PREFETCHSIZE * SIZE(BO)
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
	ldt	alpha, ALPHA
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
	LD	a5,  0 * SIZE(C1)

	ADD	c16,  t3, c16
	unop
	MUL	b2, a2, t3
	unop

	ADD	c15, t4, c15
	unop
	MUL	b2, a1, t4
	LD	b5,  1 * SIZE(C1)

	ADD	c01, t1, c01
	unop
	MUL	b1, a3, t1
	unop

	ADD	c02, t2, c02
	unop
	MUL	b1, a4, t2
	LD	b1,  0 * SIZE(C2)

	ADD	c06,  t3, c06
	unop
	MUL	b2, a4, t3
	unop

	ADD	c05, t4, c05
	unop
	MUL	b4, a1, t4
	unop

	ADD	c03, t1, c03
	unop
	MUL	b3, a1, t1
	unop

	ADD	c04, t2, c04
	unop
	MUL	b3, a2, t2
	LD	a1,  0 * SIZE(C3)

	ADD	c08,  t3, c08
	unop
	MUL	b4, a2, t3
	LD	a2,  2 * SIZE(C1)

	ADD	c13, t4, c13
	unop
	MUL	b2, a3, t4
	LD	b2,  3 * SIZE(C1)

	ADD	c09,  t1, c09
	lda	I,        -1(I)
	MUL	b3, a3, t1
	unop

	ADD	c10,  t2, c10
	unop
	MUL	b3, a4, t2
	LD	b3,  0 * SIZE(C4)

	ADD	c14, t3, c14
	unop
	MUL	b4, a4, t3
	LD	a4,  1 * SIZE(C2)

	ADD	c07,  t4, c07
	unop
	MUL	b4, a3, t4
  	LD	a3,  2 * SIZE(C2)

	ADD	c11,  t1, c11
	unop
	MUL	alpha, c01, c01
	LD	b4,  3 * SIZE(C2)

	ADD	c12,  t2, c12
	unop
	MUL	alpha, c02, c02
	LD	t1,  1 * SIZE(C3)

	ADD	c16,  t3, c16
	unop
  	MUL	alpha, c03, c03
	LD	t2,  2 * SIZE(C3)

	ADD	c15, t4, c15
	unop
	MUL	alpha, c04, c04
	LD	t3,  3 * SIZE(C3)

	MUL	alpha, c05, c05
	unop
	ADD	c01,  a5, c01
	LD	t4,  1 * SIZE(C4)

	MUL	alpha, c06, c06
	unop
	ADD	c02,  b5, c02
	LD	a5,  2 * SIZE(C4)

	MUL	alpha, c07, c07
	unop
	ADD	c03,  a2, c03
	LD	b5,  3 * SIZE(C4)

	MUL	alpha, c08, c08
	unop
	ADD	c04,  b2, c04
	unop

	MUL	alpha, c09, c09
	ST	c01,  0 * SIZE(C1)
	ADD	c05,  b1, c05
	unop

	MUL	alpha, c10, c10
	ST	c02,  1 * SIZE(C1)
	ADD	c06,  a4, c06
	unop

	MUL	alpha, c11, c11
	ST	c03,  2 * SIZE(C1)
	ADD	c07,  a3, c07
	unop

	MUL	alpha, c12, c12
	ST	c04,  3 * SIZE(C1)
	ADD	c08,  b4, c08
	lda	C1,   4 * SIZE(C1)

	MUL	alpha, c13, c13
	ST	c05,  0 * SIZE(C2)
	ADD	c09,  a1, c09
	unop

	MUL	alpha, c14, c14
 	ST	c06,  1 * SIZE(C2)
	ADD	c10,  t1, c10
	unop

	MUL	alpha, c15, c15
	ST	c07,  2 * SIZE(C2)
	ADD	c11,  t2, c11
	unop

	MUL	alpha, c16, c16
	ST	c08,  3 * SIZE(C2)
	ADD	c12,  t3, c12
	lda	C2,   4 * SIZE(C2)

	ADD	c13,  b3, c13
	ST	c09,  0 * SIZE(C3)
	fclr	t1
	lda	C4,   4 * SIZE(C4)

	ADD	c14,  t4, c14
	ST	c10,  1 * SIZE(C3)
	fclr	t2
	unop

	ADD	c15,  a5, c15
	ST	c11,  2 * SIZE(C3)
	fclr	t3
	unop

	ADD	c16,  b5, c16
	ST	c12,  3 * SIZE(C3)
	fclr	t4
	lda	C3,   4 * SIZE(C3)

	ST	c13, -4 * SIZE(C4)
	fclr	c01
	ST	c14, -3 * SIZE(C4)
	fclr	c05

	ST	c15, -2 * SIZE(C4)
 	fclr	c09
	unop
	unop

	ST	c16, -1 * SIZE(C4)
	fclr	c13
	unop
	bgt	I, $L11
	.align 4

$L20:
	and	M,  2, I
	ble	I, $L30
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
	.align	4

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
	ldt	alpha, ALPHA
	MUL	a1, b1, t1
	blbs	K, $L28

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
	LD	a3,  0 * SIZE(C1)

	ADD	c13, t3, c13
	unop
	MUL	a1, b2, t3
	LD	a4,  1 * SIZE(C1)

	ADD	c14, t4, c14
	unop
	MUL	a2, b2, t4
	LD	a5,  0 * SIZE(C2)

	ADD	c01, t1, c01
	unop
	MUL	a1, b3, t1
	LD	b5,  1 * SIZE(C2)

	ADD	c02, t2, c02
	unop
	MUL	a2, b3, t2
	LD	b1,  0 * SIZE(C3)

	ADD	c05, t3, c05
	unop
	MUL	a1, b4, t3
	LD	b2,  1 * SIZE(C3)

	ADD	c06, t4, c06
	unop
	MUL	a2, b4, t4
	LD	b3,  0 * SIZE(C4)

	ADD	c09, t1, c09
	unop
	MUL	alpha, c01, c01
	LD	b4,  1 * SIZE(C4)

	ADD	c10, t2, c10
	unop
	MUL	alpha, c02, c02
	unop

	ADD	c13, t3, c13
	MUL	alpha, c05, c05
	ADD	c14, t4, c14
	MUL	alpha, c06, c06

	MUL	alpha, c09, c09
	ADD	c01,  a3, c01
	MUL	alpha, c10, c10
	ADD	c02,  a4, c02

	MUL	alpha, c13, c13
	ADD	c05,  a5, c05
	MUL	alpha, c14, c14
	ADD	c06,  b5, c06

	ADD	c09,  b1, c09
	ST	c01,  0 * SIZE(C1)
	fclr	t1
	unop

	ADD	c10,  b2, c10
	ST	c02,  1 * SIZE(C1)
	fclr	t2
	unop

	ADD	c13,  b3, c13
	ST	c05,  0 * SIZE(C2)
	fclr	t3
	unop

	ADD	c14,  b4, c14
	ST	c06,  1 * SIZE(C2)
	fclr	t4
	unop

	ST	c09,  0 * SIZE(C3)
	fclr	c01
	lda	C1,   2 * SIZE(C1)
	unop

	ST	c10,  1 * SIZE(C3)
	fclr	c05
	lda	C2,   2 * SIZE(C2)
	unop

	ST	c13,  0 * SIZE(C4)
 	fclr	c09
	lda	C3,   2 * SIZE(C3)
	unop

	ST	c14,  1 * SIZE(C4)
	fclr	c13
	lda	C4,   2 * SIZE(C4)
	unop
	.align 4

$L30:
	and	M,  1, I
	ble	I, $L39
	.align 4

$L31:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	lda	L,        -2(K)
	LD	b2,  1 * SIZE(B)
	lda	AO,  1 * SIZE(AO)

	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)
	lda	BO,  4 * SIZE(B)
	ble	L, $L35
	.align	4

$L32:
	ADD	c01, t1, c01
	lda	L,        -2(L)
	MUL	a1, b1, t1
	LD	b1,  0 * SIZE(BO)

	ADD	c05, t2, c05
	lda	AO,    2 * SIZE(AO)
	MUL	a1, b2, t2
	LD	b2,  1 * SIZE(BO)

	ADD	c09, t3, c09
	LD	b5,  3 * SIZE(BO)
	MUL	a1, b3, t3
	LD	b3,  2 * SIZE(BO)

	ADD	c13, t4, c13
	MUL	a1, b4, t4
	LD	a1, -1 * SIZE(AO)

	ADD	c01, t1, c01
	MUL	a2, b1, t1
	LD	b1,  4 * SIZE(BO)
	lda	BO,    8 * SIZE(BO)

	ADD	c05, t2, c05
	MUL	a2, b2, t2
	LD	b2, -3 * SIZE(BO)

	ADD	c09, t3, c09
	LD	b4, -1 * SIZE(BO)
	MUL	a2, b3, t3
	LD	b3, -2 * SIZE(BO)

	ADD	c13, t4, c13
	MUL	a2, b5, t4
	LD	a2,  0 * SIZE(AO)
	bgt	L,  $L32
	.align 4

$L35:
	ADD	c01, t1, c01
	ldt	alpha, ALPHA
	MUL	a1, b1, t1
	blbs	K, $L38
	.align 4

	ADD	c05, t2, c05
	LD	b1,  0 * SIZE(BO)
	MUL	a1, b2, t2
	LD	b2,  1 * SIZE(BO)

	ADD	c09, t3, c09
	MUL	a1, b3, t3
	LD	b3,  2 * SIZE(BO)

	ADD	c13, t4, c13
	MUL	a1, b4, t4
	LD	a1,  0 * SIZE(AO)
	lda	AO,  1 * SIZE(AO)

	ADD	c01, t1, c01
	LD	b4,  3 * SIZE(BO)
	MUL	a1, b1, t1
	lda	BO,  4 * SIZE(BO)
	.align 4

$L38:
	ADD	c05, t2, c05
	unop
	MUL	a1, b2, t2
	LD	a5,  0 * SIZE(C1)

	ADD	c09, t3, c09
	unop
	MUL	a1, b3, t3
	LD	b5,  0 * SIZE(C2)

	ADD	c13, t4, c13
	unop
	MUL	a1, b4, t4
	LD	a2,  0 * SIZE(C3)

	ADD	c01, t1, c01
	unop
	MUL	alpha, c01, c01
	LD	a3,  0 * SIZE(C4)

	ADD	c05, t2, c05
	unop
	MUL	alpha, c05, c05
	unop

	ADD	c09, t3, c09
	MUL	alpha, c09, c09
	ADD	c13, t4, c13
	MUL	alpha, c13, c13

	ADD	c01,  a5, c01
	ADD	c05,  b5, c05
	ADD	c09,  a2, c09
	ADD	c13,  a3, c13

	ST	c01,  0 * SIZE(C1)
	ST	c05,  0 * SIZE(C2)
	ST	c09,  0 * SIZE(C3)
	ST	c13,  0 * SIZE(C4)
	.align 4

$L39:
 	mov	BO, B
	unop
	unop
	bgt	J, $L01
	.align 4

$L40:
	and	N, 2, J
	mov	C,  C1
	addq	C,  LDC, C2
	ble	J, $L80
	
	mov	A, AO
	lda	J,        -1(J)
	unop
	addq	C2, LDC, C
	.align 4

$L50:
	sra	M,  2, I
	fclr	t1
	fclr	t2
	fclr	t3
	fclr	t4

	fclr	c01
	fclr	c05
 	fclr	c02
	fclr	c06
	ble	I, $L60
	.align 4

$L51:
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
	ble	L, $L55
	.align	4

$L52:
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
	bgt	L,  $L52
	.align 4

$L55:
	ADD	c05, t1, c05
	ldt	alpha, ALPHA
	MUL	a1, b1, t1
	blbs	K, $L58
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

$L58:
	ADD	c06, t2, c06
	unop
	MUL	a2, b1, t2
	LD	c09,  0 * SIZE(C1)

	ADD	c07, t3, c07
	unop
	MUL	a3, b1, t3
	LD	c10,  1 * SIZE(C1)

	ADD	c08, t4, c08
	unop
	MUL	a4, b1, t4
	LD	c11,  2 * SIZE(C1)

	ADD	c01, t1, c01
	unop
	MUL	a1, b2, t1
	LD	c12,  3 * SIZE(C1)

	ADD	c02, t2, c02
	unop
	MUL	a2, b2, t2
	LD	c13,  0 * SIZE(C2)

	ADD	c03, t3, c03
	unop
	MUL	a3, b2, t3
	LD	c14,  1 * SIZE(C2)

	ADD	c04, t4, c04
	unop
	MUL	a4, b2, t4
	LD	c15,  2 * SIZE(C2)

	ADD	c05, t1, c05
	unop
	MUL	alpha, c01, c01
	LD	c16,  3 * SIZE(C2)

	ADD	c06, t2, c06
	unop
	MUL	alpha, c02, c02
	unop

	ADD	c07, t3, c07
	MUL	alpha, c03, c03
	ADD	c08, t4, c08
	MUL	alpha, c04, c04

	MUL	alpha, c05, c05
	ADD	c01,  c09, c01
	MUL	alpha, c06, c06
	ADD	c02,  c10, c02

	MUL	alpha, c07, c07
	ADD	c03,  c11, c03
	MUL	alpha, c08, c08
	ADD	c04,  c12, c04

	ADD	c05,  c13, c05
	ST	c01,  0 * SIZE(C1)
	fclr	t1
	lda	I,        -1(I)

	ADD	c06,  c14, c06
	ST	c02,  1 * SIZE(C1)
	fclr	t2
	unop

	ADD	c07,  c15, c07
	ST	c03,  2 * SIZE(C1)
	fclr	t3
	lda	C2,   4 * SIZE(C2)

	ADD	c08,  c16, c08
	ST	c04,  3 * SIZE(C1)
	fclr	t4
	lda	C1,   4 * SIZE(C1)

	ST	c05, -4 * SIZE(C2)
	fclr	c01
	ST	c06, -3 * SIZE(C2)
	fclr	c05

	ST	c07, -2 * SIZE(C2)
 	fclr	c02
	ST	c08, -1 * SIZE(C2)
	fclr	c06
	bgt	I, $L51
	.align 4

$L60:
	and	M,  2, I
	ble	I, $L70
	.align 4

$L61:
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
	ble	L, $L65
	.align	4

$L62:
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
	bgt	L,  $L62
	.align 4

$L65:
	ADD	c01, t1, c01
	ldt	alpha, ALPHA
	MUL	a1, b1, t1
	blbs	K, $L68
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

$L68:
	ADD	c02, t2, c02
	unop
	MUL	a2, b1, t2
	LD	c09,  0 * SIZE(C1)

	ADD	c05, t3, c05
	unop
	MUL	a1, b2, t3
	LD	c10,  1 * SIZE(C1)

	ADD	c06, t4, c06
	unop
	MUL	a2, b2, t4
	LD	c11,  0 * SIZE(C2)

	ADD	c01, t1, c01
	unop
	MUL	alpha, c01, c01
	LD	c12,  1 * SIZE(C2)

	ADD	c02, t2, c02
	lda	C1,   2 * SIZE(C1)
	MUL	alpha, c02, c02
	lda	C2,   2 * SIZE(C2)

	ADD	c05, t3, c05
	MUL	alpha, c05, c05
	ADD	c06, t4, c06
	MUL	alpha, c06, c06

	ADD	c01,  c09, c01
	fclr	t1
	ADD	c02,  c10, c02
	fclr	t2
	ADD	c05,  c11, c05
	fclr	t3
	ADD	c06,  c12, c06
	fclr	t4

	ST	c01, -2 * SIZE(C1)
	fclr	c01
	ST	c02, -1 * SIZE(C1)
 	fclr	c02

	ST	c05, -2 * SIZE(C2)
	fclr	c05
	ST	c06, -1 * SIZE(C2)
	fclr	c06
	.align 4

$L70:
	and	M,  1, I
	ble	I, $L79
	.align 4

$L71:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	lda	L,        -2(K)
	LD	b2,  1 * SIZE(B)
	lda	AO,  1 * SIZE(AO)

	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)
	lda	BO,  2 * SIZE(B)
	ble	L, $L75
	.align	4

$L72:
	ADD	c01, t1, c01
	lda	L,        -2(L)
	MUL	a1, b1, t1
	LD	b1,  2 * SIZE(BO)

	ADD	c05, t2, c05
	MUL	a1, b2, t2
	LD	a1,  1 * SIZE(AO)
	LD	b2,  3 * SIZE(BO)

	ADD	c02, t3, c02
	lda	AO,    2 * SIZE(AO)
	MUL	a2, b3, t3
	LD	b3,  4 * SIZE(BO)

	ADD	c06, t4, c06
	MUL	a2, b4, t4
	LD	a2,  0 * SIZE(AO)
	LD	b4,  5 * SIZE(BO)

	lda	BO,    4 * SIZE(BO)
	unop
	unop
	bgt	L,  $L72
	.align 4

$L75:
	ADD	c01, t1, c01
	ldt	alpha, ALPHA
	MUL	a1, b1, t1
	blbs	K, $L78
	.align 4

	ADD	c05, t2, c05
	MUL	a1, b2, t2
	LD	a1,  0 * SIZE(AO)
	LD	b1,  0 * SIZE(BO)

	ADD	c01, t1, c01
	LD	b2,  1 * SIZE(BO)
	lda	AO,  1 * SIZE(AO)
	MUL	a1, b1, t1
	lda	BO,  2 * SIZE(BO)
	.align 4

$L78:
	ADD	c05, t2, c05
	MUL	a1, b2, t2
	LD	a5,  0 * SIZE(C1)

	ADD	c02, t3, c02
	ADD	c06, t4, c06
	LD	b5,  0 * SIZE(C2)

	ADD	c01, c02, c01
	ADD	c05, c06, c05

	ADD	c01, t1, c01
	ADD	c05, t2, c05

	MUL	alpha, c01, c01
	MUL	alpha, c05, c05

	ADD	c01,  a5, c01
	ADD	c05,  b5, c05

	ST	c01,  0 * SIZE(C1)
	ST	c05,  0 * SIZE(C2)
	.align 4

$L79:
 	mov	BO, B
	unop
	unop
	.align 4

$L80:
	and	N, 1, J
	mov	C,  C1
	mov	A, AO
	ble	J, $L999
	.align 4

$L90:
	sra	M,  2, I
	fclr	t1
	fclr	t2
	fclr	t3
	fclr	t4

	fclr	c01
	fclr	c02
 	fclr	c03
	fclr	c04
	ble	I, $L100
	.align 4

$L91:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)
	LD	a3,  2 * SIZE(AO)
	LD	a4,  3 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	LD	b2,  1 * SIZE(B)
	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)

	sra	K, 2, L
	mov	B, BO
	unop
	ble	L, $L95
	.align	5

$L92:
	ADD	c01, t1, c01
	unop
	MUL	a1, b1, t1
	LD	a1,  4 * SIZE(AO)

	ADD	c02, t2, c02
	lda	L,   -1(L)
	MUL	a2, b1, t2
	LD	a2,  5 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b1, t3
	LD	a3,  6 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b1, t4
	LD	a4,  7 * SIZE(AO)
	LD	b1,  4 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b2, t1
	LD	a1,  8 * SIZE(AO)

	ADD	c02, t2, c02
	unop
	MUL	a2, b2, t2
	LD	a2,  9 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b2, t3
	LD	a3, 10 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b2, t4
	LD	a4, 11 * SIZE(AO)
	LD	b2,  5 * SIZE(BO)

	ADD	c01, t1, c01
	unop
	MUL	a1, b3, t1
	LD	a1, 12 * SIZE(AO)

	ADD	c02, t2, c02
	unop
	MUL	a2, b3, t2
	LD	a2, 13 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b3, t3
	LD	a3, 14 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b3, t4
	LD	a5, 15 * SIZE(AO)
	LD	b3,  6 * SIZE(BO)

	ADD	c01, t1, c01
	MUL	a1, b4, t1
	LD	a1, 16 * SIZE(AO)
	lda	AO, 16 * SIZE(AO)

	ADD	c02, t2, c02
	lda	BO,  4 * SIZE(BO)
	MUL	a2, b4, t2
	LD	a2,  1 * SIZE(AO)

	ADD	c03, t3, c03
	LD	a4,  3 * SIZE(AO)
	MUL	a3, b4, t3
	LD	a3,  2 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a5, b4, t4
	LD	b4,  3 * SIZE(BO)
	bgt	L,  $L92
	.align 4

$L95:
	and	K, 3, L
	ldt	alpha, ALPHA
	unop
	ble	L, $L98
	.align 4

$L96:
	ADD	c01, t1, c01
	lda	L,   -1(L)
	MUL	a1, b1, t1
	LD	a1,  4 * SIZE(AO)

	ADD	c02, t2, c02
	lda	BO,  1 * SIZE(BO)
	MUL	a2, b1, t2
	LD	a2,  5 * SIZE(AO)

	ADD	c03, t3, c03
	unop
	MUL	a3, b1, t3
	LD	a3,  6 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b1, t4
	LD	a4,  7 * SIZE(AO)
	LD	b1,  0 * SIZE(BO)

	lda	AO,  4 * SIZE(AO)
	bgt	L,  $L96
	.align 4

$L98:
	ADD	c01, t1, c01
	LD	c05,  0 * SIZE(C1)
	ADD	c02, t2, c02
	LD	c06,  1 * SIZE(C1)
	ADD	c03, t3, c03
	LD	c07,  2 * SIZE(C1)
	ADD	c04, t4, c04
	LD	c08,  3 * SIZE(C1)

	MUL	alpha, c01, c01
	MUL	alpha, c02, c02
	MUL	alpha, c03, c03
	MUL	alpha, c04, c04

	ADD	c01,  c05, c01
	fclr	t1
	ADD	c02,  c06, c02
	fclr	t2

	ADD	c03,  c07, c03
	lda	I,        -1(I)
	unop
	fclr	t3

	ADD	c04,  c08, c04
	unop
	fclr	t4
	unop

	ST	c01,  0 * SIZE(C1)
	fclr	c01
	ST	c02,  1 * SIZE(C1)
	fclr	c02

	ST	c03,  2 * SIZE(C1)
 	fclr	c03
	ST	c04,  3 * SIZE(C1)
	fclr	c04
	lda	C1,   4 * SIZE(C1)
	bgt	I, $L91
	.align 4

$L100:
	and	M,  2, I
	unop
	unop
	ble	I, $L110
	.align 4

$L101:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)
	LD	a3,  2 * SIZE(AO)
	LD	a4,  3 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	sra	K, 2, L
	LD	b2,  1 * SIZE(B)
	mov	B, BO

	LD	b3,  2 * SIZE(B)
	unop
	LD	b4,  3 * SIZE(B)
	ble	L, $L105
	.align	5

$L102:
	ADD	c01, t1, c01
	lda	L,        -1(L)
	MUL	a1, b1, t1
	LD	a1,  4 * SIZE(AO)

	ADD	c02, t2, c02
	MUL	a2, b1, t2
	LD	a2,  5 * SIZE(AO)
	LD	b1,  4 * SIZE(BO)

	ADD	c03, t3, c03
	lda	BO,    4 * SIZE(BO)
	MUL	a3, b2, t3
	LD	a3,  6 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a4, b2, t4
	LD	a5,  7 * SIZE(AO)
	LD	b2,  1 * SIZE(BO)

	ADD	c01, t1, c01
	MUL	a1, b3, t1
	LD	a1,  8 * SIZE(AO)
	lda	AO,  8 * SIZE(AO)

	ADD	c02, t2, c02
	MUL	a2, b3, t2
	LD	b3,  2 * SIZE(BO)
	LD	a2,  1 * SIZE(AO)

	ADD	c03, t3, c03
	LD	a4,  3 * SIZE(AO)
	MUL	a3, b4, t3
	LD	a3,  2 * SIZE(AO)

	ADD	c04, t4, c04
	MUL	a5, b4, t4
	LD	b4,  3 * SIZE(BO)
	bgt	L,  $L102
	.align 4

$L105:
	and	K, 3, L
	ldt	alpha, ALPHA
	LD	a3,  0 * SIZE(C1)
	LD	a4,  1 * SIZE(C1)
	ble	L, $L108
	.align 4

$L106:
	ADD	c01, t1, c01
	lda	L,        -1(L)
	MUL	a1, b1, t1
	LD	a1,  2 * SIZE(AO)

	ADD	c02, t2, c02
	MUL	a2, b1, t2
	LD	a2,  3 * SIZE(AO)
	LD	b1,  1 * SIZE(BO)

	lda	AO,  2 * SIZE(AO)
	unop
	lda	BO,  1 * SIZE(BO)
	bgt	L,  $L106
	.align 4

$L108:
	ADD	c01, t1, c01
	fclr	t1
	ADD	c02, t2, c02
	fclr	t2
	ADD	c03, t3, c03
	fclr	t3
	ADD	c04, t4, c04
	fclr	t4

	ADD	c01, c03, c01
	ADD	c02, c04, c02

	MUL	alpha, c01, c01
	MUL	alpha, c02, c02

	ADD	c01,  a3, c01
 	fclr	c03
	ADD	c02,  a4, c02
	fclr	c04

	ST	c01,  0 * SIZE(C1)
	fclr	c01
	ST	c02,  1 * SIZE(C1)
	fclr	c02
	lda	C1,   2 * SIZE(C1)
	.align 4

$L110:
	and	M,  1, I
	ble	I, $L999
	.align 4

$L111:
	LD	a1,  0 * SIZE(AO)
	LD	a2,  1 * SIZE(AO)
	LD	a3,  2 * SIZE(AO)
	LD	a4,  3 * SIZE(AO)

	LD	b1,  0 * SIZE(B)
	LD	b2,  1 * SIZE(B)
	LD	b3,  2 * SIZE(B)
	LD	b4,  3 * SIZE(B)

	sra	K, 2, L
	mov	B, BO
	unop
	ble	L, $L115
	.align	4

$L112:
	ADD	c01, t1, c01
	MUL	a1,  b1, t1
	LD	a1,  4 * SIZE(AO)
	LD	b1,  4 * SIZE(BO)

	ADD	c02, t2, c02
	MUL	a2,  b2, t2
	LD	a2,  5 * SIZE(AO)
	LD	b2,  5 * SIZE(BO)

	ADD	c03, t3, c03
	MUL	a3,  b3, t3
	LD	a3,  6 * SIZE(AO)
	LD	b3,  6 * SIZE(BO)

	ADD	c04, t4, c04
	MUL	a4,  b4, t4
	LD	a4,  7 * SIZE(AO)
	LD	b4,  7 * SIZE(BO)

	lda	L,        -1(L)
	lda	AO,    4 * SIZE(AO)
	lda	BO,    4 * SIZE(BO)
	bgt	L,  $L112
	.align 4

$L115:
	and	K, 3, L
	ldt	alpha, ALPHA
	LD	a2,  0 * SIZE(C1)
	ble	L, $L118
	.align	4

$L116:
	ADD	c01, t1, c01
	MUL	a1,  b1, t1
	LD	a1,  1 * SIZE(AO)
	LD	b1,  1 * SIZE(BO)

	lda	L,        -1(L)
	lda	AO,  1 * SIZE(AO)
	lda	BO,  1 * SIZE(BO)
	bgt	L,  $L116
	.align 4

$L118:
	ADD	c01, t1, c01
	ADD	c02, t2, c02
	ADD	c03, t3, c03
	ADD	c04, t4, c04

	ADD	c01, c02, c01
	ADD	c03, c04, c03
	ADD	c01, c03, c01

	MUL	alpha, c01, c01
	ADD	c01,  a2, c01
	ST	c01,  0 * SIZE(C1)
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
