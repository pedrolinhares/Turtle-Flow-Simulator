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

#ifndef COMMON_ALPHA
#define COMMON_ALPHA

#ifndef ASSEMBLER

#define MB  asm("mb")
#define WMB asm("wmb")

static void __inline blas_lock(unsigned long *address){
#ifndef __DECC
  unsigned long tmp1, tmp2;
  asm volatile(
    "1: ldq	%1,  %0\n"
    "	bne	%1,  2f\n"
    "	ldq_l	%1,  %0\n"
    "	bne	%1,  2f\n"
    "	or	%1,  1, %2\n"
    "	stq_c	%2,  %0\n"
    "	beq	%2,  2f\n"
    "	mb\n              "
    "	br      $31, 3f\n"
    "2: br      $31, 1b\n"
    "3:\n" : "=m"(*address), "=&r"(tmp1), "=&r"(tmp2) : :  "memory");
#else
  asm (
    "10:"
    "   ldq	%t0,  0(%a0); "
    "	bne	%t0, 20f;     "
    "	ldq_l	%t0,  0(%a0); "
    "	bne	%t0, 20f;     "
    "	or	%t0, 1, %t1;"
    "	stq_c	%t1,  0(%a0); "
    "	beq	%t1, 20f;     "
    "	mb;                   "
    "	br      %r31,30f;     "
    "20:                      "
    "	br      %r31,10b;     "
    "30:", address);
#endif
}

static __inline unsigned int rpcc(void){

  unsigned long r0;

#ifndef __DECC
  asm __volatile__("rpcc %0" : "=r"(r0)  : : "memory");
#else
  r0 = asm("rpcc %v0");
#endif

#if 0
  r0 = ((r0 + (r0<<32)) >>32);
#endif

  r0 &= 0xffffffffUL;

  return (unsigned int)r0;
}


#define HALT 	ldq	$0, 0($0)

#ifndef __DECC
#define GET_IMAGE(res)  asm __volatile__("fmov $f1, %0" : "=f"(res)  : : "memory")
#else
#define GET_IMAGE(res) res = dasm("fmov $f1, %f0")
#endif

#ifdef SMP
#ifdef USE64BITINT
static __inline long blas_quickdivide(long x, long y){
  return x/y;
}
#else
extern unsigned int blas_quick_divide_table[];

static __inline int blas_quickdivide(unsigned int x, unsigned int y){
  if (y <= 1) return x;
  return (int)((x * (unsigned long)blas_quick_divide_table[y]) >> 32);
}
#endif
#endif

#define BASE_ADDRESS ((0x1b0UL << 33) | (0x1c0UL << 23) | (0x000UL << 13))

#define PAGESIZE           (16UL << 10)
#define ADDRESS_ALIGN      ((8UL << 20) - 1)  /* 8MB required */
#define MMAP_ACCESS (PROT_READ | PROT_WRITE)
#define MMAP_POLICY (MAP_PRIVATE | MAP_ANONYMOUS)

#define BUFFER_SIZE         (64UL << 20)        /* 4MB required */
#define HUGE_PAGESIZE 		( 4UL << 20)
#define SUBBUFFER_SIZE		(  2UL << 20)

#define BUFFER_LIMIT		(BUFFER_SIZE - SUBBUFFER_SIZE)
#define SUB_BUFFER_OFFSET	((BUFFER_LIMIT + 128) /sizeof(FLOAT))
#define BUFFER_OFFSET_LIMIT	SUBBUFFER_SIZE

#else

#ifndef F_INTERFACE
#define REALNAME ASMNAME
#else
#define REALNAME ASMFNAME
#endif

#define PROLOGUE \
	.set noat; \
	.set noreorder; \
.text; \
	.align 5; \
	.globl REALNAME; \
	.ent REALNAME; \
REALNAME:

#ifdef PROFILE
#define PROFCODE \
	ldgp	$gp, 0($27); \
	lda	$28, _mcount; \
	jsr	$28, ($28), _mcount; \
	.prologue 1
#else
#define PROFCODE .prologue 0
#endif

#define EPILOGUE \
	.end REALNAME; \
	.ident VERSION
#endif

#ifdef DOUBLE
#define SXADDQ	s8addq
#define SXSUBL	s8subl
#define LD	ldt
#define ST	stt
#define STQ	stq
#define ADD	addt
#define SUB	subt
#define MUL	mult
#define DIV	divt
#else
#define SXADDQ  s4addq
#define SXSUBL	s4subl
#define LD      lds
#define ST	sts
#define STQ	stl
#define ADD	adds
#define SUB	subs
#define MUL	muls
#define DIV	divs
#endif
#endif
