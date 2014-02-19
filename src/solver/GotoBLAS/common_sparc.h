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

#ifndef COMMON_POWER
#define COMMON_POWER

#define MB	__asm__ __volatile__ ("nop")
#define WMB	__asm__ __volatile__ ("nop")

#ifndef ASSEMBLER

static void __inline blas_lock(volatile unsigned long *address){

  long int ret = 1;

  do {
    __asm__ __volatile__(
			 "ldstub [%1], %0"
			 : "=&r"(ret)
			 : "r" (address)
			 : "memory");
  } while (ret);
}

static __inline unsigned long rpcc(void){
  unsigned long clocks;

  __asm__ __volatile__ ("rd %%tick, %0" : "=r" (clocks));

  return clocks;
};

#ifdef DOUBLE
#define GET_IMAGE(res)  asm __volatile__("fmovd %%f2, %0" : "=f"(res)  : : "memory")
#else
#define GET_IMAGE(res)  asm __volatile__("fmovs %%f1, %0" : "=f"(res)  : : "memory")
#endif

#define GET_IMAGE_CANCEL

#ifdef SMP
static __inline int blas_quickdivide(blasint x, blasint y){
  return x / y;
}
#endif
#endif


#ifdef ASSEMBLER

#ifndef __64BIT__
#define STACK_START 64
#define SAVESP		save	%sp, -64, %sp
#else
#define STACK_START 2167
#define SAVESP		save	%sp, -128, %sp
#endif

#define NOP	or %g1, %g1, %g1

#ifdef DOUBLE
#define LDF	ldd
#define STF	std
#define FADD	faddd
#define FMUL	fmuld
#define FMOV	fmovd
#define FABS	fabsd
#define FSUB	fsubd
#define FCMP	fcmpd
#define FMOVG	fmovdg
#define FMOVL	fmovdl
#define FSQRT	fsqrtd
#define FDIV	fdivd
#else
#define LDF	ld
#define STF	st
#define FADD	fadds
#define FMUL	fmuls
#define FMOV	fmovs
#define FABS	fabss
#define FSUB	fsubs
#define FCMP	fcmps
#define FMOVG	fmovsg
#define FMOVL	fmovsl
#define FSQRT	fsqrts
#define FDIV	fdivs
#endif
	
#define HALT prefetch [%g0], 5

#define FMADDS(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | ( 1 << 5) | (rs2))

#define FMADDD(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | ( 2 << 5) | (rs2))

#define FMSUBS(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | ( 5 << 5) | (rs2))

#define FMSUBD(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | ( 6 << 5) | (rs2))

#define FNMSUBS(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | ( 9 << 5) | (rs2))

#define FNMSUBD(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | (10 << 5) | (rs2))

#define FNMADDS(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | (13 << 5) | (rs2))

#define FNMADDD(rs1, rs2, rs3, rd) \
        ((2 << 30) | ((rd) << 25) | ( 0x37 << 19) | ((rs1) << 14) | ((rs3) << 9) | (14 << 5) | (rs2))

#ifndef F_INTERFACE
#define REALNAME ASMNAME
#else
#define REALNAME ASMFNAME
#endif

#ifdef sparc
#define PROLOGUE \
	.section	".text"; \
	.align 32; \
	.global REALNAME;\
	.type	REALNAME, #function; \
	.proc	07; \
REALNAME:;
#define EPILOGUE \
	.size	 REALNAME, .-REALNAME
#endif

#endif

#ifdef sparc
#define SEEK_ADDRESS
#endif

#define BUFFER_SIZE     (32 << 20)        /* 1MB required */
#define HUGE_PAGESIZE   ( 4 << 20)
#define SUBBUFFER_SIZE	( 2 << 20)

#define BASE_ADDRESS (START_ADDRESS - BUFFER_SIZE * MAX_CPU_NUMBER)

#define BUFFER_LIMIT		(BUFFER_SIZE - SUBBUFFER_SIZE)
#define SUB_BUFFER_OFFSET	((BUFFER_LIMIT + 128) /sizeof(FLOAT))
#define BUFFER_OFFSET_LIMIT	SUBBUFFER_SIZE
#define MMAP_ACCESS (PROT_READ | PROT_WRITE)
#define MMAP_POLICY (MAP_PRIVATE | MAP_ANONYMOUS)

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif
#endif
