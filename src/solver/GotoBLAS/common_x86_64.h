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

static void __inline blas_lock(volatile BLASULONG *address){

  int ret;

  do {
    while (*address) {};
    
    __asm__ __volatile__(
			 "xchgl %0, %1\n"
			 : "=r"(ret), "=m"(*address)
			 : "0"(1), "m"(*address)
			 : "memory");
  } while (ret);
}

static __inline BLASULONG rpcc(void){
  BLASULONG a, d;

  __asm__ __volatile__ ("rdtsc" : "=a" (a), "=d" (d));
  
  return (a + (d << 32));  
};

static __inline BLASULONG getstackaddr(void){
  BLASULONG addr;

  __asm__ __volatile__ ("movq %%rsp, %0"
			 : "=r"(addr) : : "memory");

  return addr;  
};

static __inline void cpuid(int op, int *eax, int *ebx, int *ecx, int *edx){

        __asm__ __volatile__("cpuid"
			     : "=a" (*eax),
			     "=b" (*ebx),
			     "=c" (*ecx),
			     "=d" (*edx)
			     : "0" (op));
}

#ifdef XDOUBLE
#define GET_IMAGE(res)  asm __volatile__("fstpt %0" : "=m"(res) : : "memory")
#elif defined(DOUBLE)
#define GET_IMAGE(res)  asm __volatile__("movsd %%xmm1, %0" : "=m"(res) : : "memory")
#else
#define GET_IMAGE(res)  asm __volatile__("movss %%xmm1, %0" : "=m"(res) : : "memory")
#endif

#define GET_IMAGE_CANCEL

#ifdef SMP
#ifdef USE64BITINT
static __inline blasint blas_quickdivide(blasint x, blasint y){
  return x / y;
}
#else
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

#endif

#define PAGESIZE           (4 << 10)

#define BUFFER_SIZE		(64 << 20)
#define HUGE_PAGESIZE		( 2 << 20)
#define SUBBUFFER_SIZE		( 2 << 20)

#define BUFFER_LIMIT		(BUFFER_SIZE - SUBBUFFER_SIZE)
#define SUB_BUFFER_OFFSET	((BUFFER_LIMIT + 128) /sizeof(FLOAT))
#define BUFFER_OFFSET_LIMIT	SUBBUFFER_SIZE

#if 0
#define BASE_ADDRESS (0x0000007000000000UL - BUFFER_SIZE * NUM_BUFFERS)
#else
#define SEEK_ADDRESS
#endif

#define ADDRESS_ALIGN      (BUFFER_SIZE - 1)
#define MMAP_ACCESS (PROT_READ | PROT_WRITE)
#define MMAP_POLICY (MAP_PRIVATE | MAP_ANONYMOUS)

#ifdef ASSEMBLER
#define BRANCH		.byte 0x3e
#define NOBRANCH	.byte 0x2e
#define PADDING		.byte 0x66;

#ifdef __WIN64__
#define ARG1	%rcx
#define ARG2	%rdx
#define ARG3	%r8
#define ARG4	%r9
#else
#define ARG1	%rdi
#define ARG2	%rsi
#define ARG3	%rdx
#define ARG4	%rcx
#define ARG5	%r8
#define ARG6	%r9
#endif

#if defined(HAVE_3DNOW)
#define EMMS	femms
#elif defined(HAVE_MMX)
#define EMMS	emms
#endif

#ifndef EMMS
#define EMMS
#endif

#if defined(CORE2)
#define movapd	movaps
#define andpd	andps
#define movlpd	movlps
#define movhpd	movhps
#endif

#ifndef F_INTERFACE
#define REALNAME ASMNAME
#else
#define REALNAME ASMFNAME
#endif

#ifndef __WIN64__
#define SAVEREGISTERS
#define RESTOREREGISTERS
#else
#define SAVEREGISTERS \
	subq	$256, %rsp;\
	movups	%xmm6,    0(%rsp);\
	movups	%xmm7,   16(%rsp);\
	movups	%xmm8,   32(%rsp);\
	movups	%xmm9,   48(%rsp);\
	movups	%xmm10,  64(%rsp);\
	movups	%xmm11,  80(%rsp);\
	movups	%xmm12,  96(%rsp);\
	movups	%xmm13, 112(%rsp);\
	movups	%xmm14, 128(%rsp);\
	movups	%xmm15, 144(%rsp)


#define RESTOREREGISTERS \
	movups	   0(%rsp), %xmm6;\
	movups	  16(%rsp), %xmm7;\
	movups	  32(%rsp), %xmm8;\
	movups	  48(%rsp), %xmm9;\
	movups	  64(%rsp), %xmm10;\
	movups	  80(%rsp), %xmm11;\
	movups	  96(%rsp), %xmm12;\
	movups	 112(%rsp), %xmm13;\
	movups	 128(%rsp), %xmm14;\
	movups	 144(%rsp), %xmm15;\
	addq	$256, %rsp
#endif


#if defined(__WIN64__) && defined(__PGI)
#define PROLOGUE \
	.text; \
	.align 16; \
	.globl REALNAME ;\
REALNAME:

#define PROFCODE

#define EPILOGUE \
       .type REALNAME, @function; \
	.size	 REALNAME, .-REALNAME
#endif

#if defined(__ELF__)
#define PROLOGUE \
	.text; \
	.align 256; \
	.globl REALNAME ;\
       .type REALNAME, @function; \
REALNAME:

#ifdef PROFILE
#ifdef PGICOMPILER
#define	MCOUNT	_mcount
#if defined(__ELF__) && !defined(ASSEMBLER)
asm("\t mcount = _mcount");
#endif
#endif

#ifdef F_SUN
#define	MCOUNT	_mcount
#define PROFCODE \
	.data; \
	.align 8 ;\
.LP2:; \
	.quad	0 ;\
	.text ;\
	movq	$.LP2, %r11 ;\
	call	MCOUNT;
#endif

#ifdef linux
#define MCOUNT	*mcount@GOTPCREL(%rip)
#endif

#ifndef MCOUNT
#define	MCOUNT	mcount
#endif

#ifndef PROFCODE
#define PROFCODE call	MCOUNT;
#endif

#else
#define PROFCODE
#endif

#define EPILOGUE \
	.size	 REALNAME, .-REALNAME
#endif
#endif

#ifdef __APPLE__
#define PROLOGUE .text;.align 5; .globl REALNAME; REALNAME:
#define EPILOGUE	.subsections_via_symbols
#define PROFCODE
#endif

#ifdef XDOUBLE
#define FLD	fldt
#define FST	fstpt
#define MOVQ	movq
#elif defined(DOUBLE)
#define FLD	fldl
#define FST	fstpl
#define FSTU	fstl
#define FMUL	fmull
#define FADD	faddl
#define MOVSD	movsd
#define MULSD	mulsd
#define MULPD	mulpd
#define CMPEQPD	cmpeqpd
#define COMISD	comisd
#define PSRLQ	psrlq
#define ANDPD	andpd
#define ADDPD	addpd
#define ADDSD	addsd
#define SUBPD	subpd
#define SUBSD	subsd
#define MOVQ	movq
#define MOVUPD	movupd
#define XORPD	xorpd
#else
#define FLD	flds
#define FST	fstps
#define FSTU	fsts
#define FMUL	fmuls
#define FADD	fadds
#define MOVSD	movss
#define MULSD	mulss
#define MULPD	mulps
#define CMPEQPD	cmpeqps
#define COMISD	comiss
#define PSRLQ	psrld
#define ANDPD	andps
#define ADDPD	addps
#define ADDSD	addss
#define SUBPD	subps
#define SUBSD	subss
#define MOVQ	movd
#define MOVUPD	movups
#define XORPD	xorps
#endif

#define HALT	hlt

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

#endif
