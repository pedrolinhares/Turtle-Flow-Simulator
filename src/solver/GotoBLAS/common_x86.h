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

#ifndef COMMON_X86
#define COMMON_X86

#ifndef ASSEMBLER

#ifdef HAVE_SSE2
#define MB   __asm__ __volatile__ ("mfence");
#define WMB  __asm__ __volatile__ ("sfence");
#else
#define MB
#define WMB
#endif

static void __inline blas_lock(volatile unsigned long *address){

  int ret;

  do {
    while (*address) {
#ifdef PENTIUM4
      __asm__ __volatile__("pause\n");
#endif
};
    
    __asm__ __volatile__(
#ifdef PENTIUM4
			 "mfence\n"
#endif
			 "xchgl %0, %1\n"
#ifdef PENTIUM4
			 "mfence\n"
#endif
			 : "=r"(ret), "=m"(*address)
			 : "0"(1), "m"(*address)
			 : "memory");

  } while (ret);

}

static __inline unsigned int rpcc(void){
  unsigned int clocks;

  __asm__ __volatile__ ("rdtsc" : "=a" (clocks) : : "edx");
  
  return clocks;  
};

static __inline unsigned long getstackaddr(void){
  unsigned long addr;

  __asm__ __volatile__ ("mov %%esp, %0"
			 : "=r"(addr) : : "memory");

  return addr;  
};


static __inline long double sqrt_long(long double val) {
  long double result;

  asm __volatile__ ("fldt %1\n"
		    "fsqrt\n"
		    "fstpt %0\n" : "=m" (result) : "m"(val));
  return result;
}

#define SQRT(a)  sqrt_long(a)


/* This is due to gcc's bug */
void cpuid(int op, int *eax, int *ebx, int *ecx, int *edx);

#ifdef XDOUBLE
#define GET_IMAGE(res)  asm __volatile__("fstpt %0" : "=m"(res) : : "memory")
#elif defined(DOUBLE)
#define GET_IMAGE(res)  asm __volatile__("fstpl %0" : "=m"(res) : : "memory")
#else
#define GET_IMAGE(res)  asm __volatile__("fstps %0" : "=m"(res) : : "memory");
#endif

#define GET_IMAGE_CANCEL	asm __volatile__ ("ffree %st")

#ifdef SMP
extern unsigned int blas_quick_divide_table[];

static __inline int blas_quickdivide(unsigned int x, unsigned int y){

  unsigned int result;

  if (y <= 1) return x;

  y = blas_quick_divide_table[y];

  __asm__ __volatile__  ("mull %0" :"=d" (result) :"a"(x), "0" (y));

  return result;
}
#endif

#endif

#if defined(DOUBLE) || defined(XDOUBLE)
#define	MMXLOAD		movq
#define MMXSTORE	movq
#else
#define MMXLOAD		movd
#define MMXSTORE	movd
#endif

#if defined(HAVE_3DNOW)
#define EMMS	femms
#elif defined(HAVE_MMX)
#define EMMS	emms
#endif

#ifndef EMMS
#define EMMS
#endif

#if defined(CORE2) || defined(PENTIUM4)
#define movapd	movaps
#endif

#define BRANCH		.byte 0x3e
#define NOBRANCH	.byte 0x2e
#define PADDING		.byte 0x66;
#define HALT		hlt

#ifndef F_INTERFACE
#define REALNAME ASMNAME
#else
#define REALNAME ASMFNAME
#endif

#ifdef __APPLE__
#define PROLOGUE .text;.align 5; .globl REALNAME; REALNAME:
#endif

#if defined(__ELF__) || (defined(__WIN32__) && defined(__PGI))
#define PROLOGUE \
	.text; \
	.align 16; \
	.globl REALNAME ;\
       .type REALNAME, @function; \
REALNAME:
#endif

#if defined(__CYGWIN32__) || (defined(__WIN32__) && defined(__GNUC__)) || defined(__INTERIX)
#define PROLOGUE \
	.text; \
	.align 16; \
	.globl REALNAME ;\
	.def REALNAME;.scl	2;.type	32;.endef; \
REALNAME:
#endif

#ifdef PROFILE
#ifdef PGICOMPILER
#define	MCOUNT	_mcount
#if defined(__ELF__) && !defined(ASSEMBLER)
asm("\t mcount = _mcount");
#endif
#else
#define	MCOUNT	mcount
#endif

#define PROFCODE \
.data; \
	.align 4; \
.LP1:; \
	.long 0; \
.text; \
	movl $.LP1, %edx; \
	call MCOUNT
#else
#define PROFCODE
#endif

#ifdef __APPLE__
#define EPILOGUE	.subsections_via_symbols
#endif

#if defined(__ELF__) || (defined(__WIN32__) && defined(__PGI))
#define EPILOGUE \
	.size	 REALNAME,.-REALNAME
#endif

#if defined(__CYGWIN32__) || (defined(__WIN32__) && defined(__GNUC__))
#define EPILOGUE \
	.end	 REALNAME
#endif

#ifdef __INTERIX
#define EPILOGUE
#endif

#ifdef XDOUBLE
#define FLD	fldt
#define FST	fstpt
#define FSTU	fstt
#define FMUL	fmult
#define FADD	faddt
#define FSUB	fsubt
#define FSUBR	fsubrt
#elif defined(DOUBLE)
#define FLD	fldl
#define FST	fstpl
#define FSTU	fstl
#define FMUL	fmull
#define FADD	faddl
#define FSUB	fsubl
#define FSUBR	fsubrl
#else
#define FLD	flds
#define FST	fstps
#define FSTU	fsts
#define FMUL	fmuls
#define FADD	fadds
#define FSUB	fsubs
#define FSUBR	fsubrs
#endif
#endif

#define SEEK_ADDRESS

#define BUFFER_SIZE		(32 << 20)
#define HUGE_PAGESIZE           ( 2 << 20)
#define SUBBUFFER_SIZE		( 2 << 20)

#define PAGESIZE		( 4 << 10)
#define BASE_ADDRESS (START_ADDRESS - BUFFER_SIZE * MAX_CPU_NUMBER)

#define BUFFER_LIMIT		(BUFFER_SIZE - SUBBUFFER_SIZE)
#define SUB_BUFFER_OFFSET	((BUFFER_LIMIT + 128) /sizeof(FLOAT))
#define BUFFER_OFFSET_LIMIT	SUBBUFFER_SIZE

#define ADDRESS_ALIGN      (BUFFER_SIZE - 1)
#define MMAP_ACCESS (PROT_READ | PROT_WRITE)
#define MMAP_POLICY (MAP_PRIVATE | MAP_ANONYMOUS)

#ifdef __APPLE__
#define ALIGN_2 .align 2
#define ALIGN_3 .align 3
#define ALIGN_4 .align 4
#define ffreep	fstp
#endif

#ifndef ALIGN_2
#define ALIGN_2 .align 4
#endif

#ifndef ALIGN_3
#define ALIGN_3 .align 8
#endif

#ifndef ALIGN_4
#define ALIGN_4 .align 16
#endif

#ifndef ALIGN_5
#define ALIGN_5 .align 32
#endif

#ifndef ALIGN_6
#define ALIGN_6 .align 64
#endif
