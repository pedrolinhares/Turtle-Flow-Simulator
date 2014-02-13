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

#include <stdio.h>
#include "common.h"

int get_L2_size(void);

#define DEFAULT_GEMM_P 128
#define DEFAULT_GEMM_Q 128
#define DEFAULT_GEMM_R 128

/* Global Parameter */
#if SGEMM_P == sgemm_p
BLASLONG sgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG sgemm_p = SGEMM_P;
#endif
#if DGEMM_P == dgemm_p
BLASLONG dgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG dgemm_p = DGEMM_P;
#endif
#if CGEMM_P == cgemm_p
BLASLONG cgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG cgemm_p = CGEMM_P;
#endif
#if ZGEMM_P == zgemm_p
BLASLONG zgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG zgemm_p = ZGEMM_P;
#endif

#if SGEMM_Q == sgemm_q
BLASLONG sgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG sgemm_q = SGEMM_Q;
#endif
#if DGEMM_Q == dgemm_q
BLASLONG dgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG dgemm_q = DGEMM_Q;
#endif
#if CGEMM_Q == cgemm_q
BLASLONG cgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG cgemm_q = CGEMM_Q;
#endif
#if ZGEMM_Q == zgemm_q
BLASLONG zgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG zgemm_q = ZGEMM_Q;
#endif

#if SGEMM_R == sgemm_r
BLASLONG sgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG sgemm_r = SGEMM_R;
#endif
#if DGEMM_R == dgemm_r
BLASLONG dgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG dgemm_r = DGEMM_R;
#endif
#if CGEMM_R == cgemm_r
BLASLONG cgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG cgemm_r = CGEMM_R;
#endif
#if ZGEMM_R == zgemm_r
BLASLONG zgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG zgemm_r = ZGEMM_R;
#endif

#ifdef EXPRECISION
#if QGEMM_P == qgemm_p
BLASLONG qgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG qgemm_p = QGEMM_P;
#endif
#if XGEMM_P == xgemm_p
BLASLONG xgemm_p = DEFAULT_GEMM_P;
#else
BLASLONG xgemm_p = XGEMM_P;
#endif
#if QGEMM_Q == qgemm_q
BLASLONG qgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG qgemm_q = QGEMM_Q;
#endif
#if XGEMM_Q == xgemm_q
BLASLONG xgemm_q = DEFAULT_GEMM_Q;
#else
BLASLONG xgemm_q = XGEMM_Q;
#endif
#if QGEMM_R == qgemm_r
BLASLONG qgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG qgemm_r = QGEMM_R;
#endif
#if XGEMM_R == xgemm_r
BLASLONG xgemm_r = DEFAULT_GEMM_R;
#else
BLASLONG xgemm_r = XGEMM_R;
#endif
#endif

#if defined(ARCH_X86) || defined(ARCH_X86_64)

int get_L2_size(void){

  int eax, ebx, ecx, edx;

#if defined(ATHLON) || defined(OPTERON) || defined(BARCELONA) || \
    defined(CORE_PRESCOTT) || defined(CORE_CORE2) || defined(PENRYN) || defined(GENERIC)

  cpuid(0x80000006, &eax, &ebx, &ecx, &edx);

  return BITMASK(ecx, 16, 0xffff);

#else

  int info[15];
  int i;

  cpuid(2, &eax, &ebx, &ecx, &edx);
  
  info[ 0] = BITMASK(eax,  8, 0xff);
  info[ 1] = BITMASK(eax, 16, 0xff);
  info[ 2] = BITMASK(eax, 24, 0xff);
  
  info[ 3] = BITMASK(ebx,  0, 0xff);
  info[ 4] = BITMASK(ebx,  8, 0xff);
  info[ 5] = BITMASK(ebx, 16, 0xff);
  info[ 6] = BITMASK(ebx, 24, 0xff);
  
  info[ 7] = BITMASK(ecx,  0, 0xff);
  info[ 8] = BITMASK(ecx,  8, 0xff);
  info[ 9] = BITMASK(ecx, 16, 0xff);
  info[10] = BITMASK(ecx, 24, 0xff);
  
  info[11] = BITMASK(edx,  0, 0xff);
  info[12] = BITMASK(edx,  8, 0xff);
  info[13] = BITMASK(edx, 16, 0xff);
  info[14] = BITMASK(edx, 24, 0xff);
  
  for (i = 0; i < 15; i++){

    switch (info[i]){
      case 0x3b :
      case 0x41 :
      case 0x79 :
	return  128;
	break;

      case 0x3c :
      case 0x42 :
      case 0x7a :
      case 0x7e :
      case 0x82 :
	return  256;
	break;

      case 0x43 :
      case 0x7b :
      case 0x7f :
      case 0x83 :
      case 0x86 :
	return  512;
	break;

      case 0x44 :
      case 0x78 :
      case 0x7c :
      case 0x84 :
      case 0x87 :
	return 1024;
	break;

      case 0x45 :
      case 0x7d :
      case 0x85 :
	return 2048;

      case 0x49 :
	return 4096;
	break;
    }
  }

  /* Never reached */
  return 0;
#endif
}

void blas_set_parameter(void){

  int size = get_L2_size();

#if defined(CORE_KATMAI)  || defined(CORE_COPPERMINE) || defined(CORE_BANIAS)
  size >>= 7;

#if defined(CORE_BANIAS) && (HAVE_HIT > 1)
  sgemm_p =  64 / HAVE_HIT * size;
  dgemm_p =  32 / HAVE_HIT * size;
  cgemm_p =  32 / HAVE_HIT * size;
  zgemm_p =  16 / HAVE_HIT * size;
#ifdef EXPRECISION
  qgemm_p =  16 / HAVE_HIT * size;
  xgemm_p =   8 / HAVE_HIT * size;
#endif
#else
  sgemm_p =  64 * size;
  dgemm_p =  32 * size;
  cgemm_p =  32 * size;
  zgemm_p =  16 * size;
#ifdef EXPRECISION
  qgemm_p =  16 * size;
  xgemm_p =   8 * size;
#endif
#endif
#endif


#if defined(CORE_NORTHWOOD) 
  size >>= 7;
#ifdef ALLOC_HUGETLB
  sgemm_p = 128 * size;
  dgemm_p =  64 * size;
  cgemm_p =  64 * size;
  zgemm_p =  32 * size;
#ifdef EXPRECISION
  qgemm_p =  32 * size;
  xgemm_p =  16 * size;
#endif
#else
  sgemm_p = 112 * size;
  dgemm_p =  56 * size;
  cgemm_p =  56 * size;
  zgemm_p =  28 * size;
#ifdef EXPRECISION
  qgemm_p =  28 * size;
  xgemm_p =  14 * size;
#endif
#endif
#endif

#if defined(CORE_CORE2)
  size >>= 8;

#ifdef ARCH_X86
  sgemm_p =  56 * size;
  dgemm_p =  28 * size;
  cgemm_p =  28 * size;
  zgemm_p =  14 * size;
#ifdef EXPRECISION
  qgemm_p =  14 * size;
  xgemm_p =   7 * size;
#endif
#else
  sgemm_p =  64 * size;
  dgemm_p =  32 * size;
  cgemm_p =  32 * size;
  zgemm_p =  16 * size;
#ifdef EXPRECISION
  qgemm_p =  16 * size;
  xgemm_p =   8 * size;
#endif
#endif
#endif

#if defined(PENRYN)
  size >>= 8;

  sgemm_p = 1016;
  dgemm_p =  504;
  cgemm_p =  504;
  zgemm_p =  248;
#ifdef EXPRECISION
  qgemm_p =  248;
  xgemm_p =  120;
#endif
#endif

#if defined(CORE_PRESCOTT)  || defined(GENERIC)
  size >>= 7;

  sgemm_p =  56 * size;
  dgemm_p =  28 * size;
  cgemm_p =  28 * size;
  zgemm_p =  14 * size;
#ifdef EXPRECISION
  qgemm_p =  14 * size;
  xgemm_p =   7 * size;
#endif
#endif

#if defined(CORE_OPTERON) 
  sgemm_p =  240 + (size >> 2);
  dgemm_p =  120 + (size >> 3);
  cgemm_p =  120 + (size >> 3);
  zgemm_p =   60 + (size >> 4);
#ifdef EXPRECISION
  qgemm_p =   60 + (size >> 4);
  xgemm_p =   30 + (size >> 5);
#endif
#endif

#if defined(CORE_BARCELONA)
  size >>= 8;

  sgemm_p = 232 * size;
  dgemm_p = 116 * size;
  cgemm_p = 116 * size;
  zgemm_p =  58 * size;
#ifdef EXPRECISION
  qgemm_p =  58 * size;
  xgemm_p =  26 * size;
#endif
#endif

  if (sgemm_p == 0) sgemm_p = 64;
  if (dgemm_p == 0) dgemm_p = 64;
  if (cgemm_p == 0) cgemm_p = 64;
  if (zgemm_p == 0) zgemm_p = 64;
#ifdef EXPRECISION
  if (qgemm_p == 0) qgemm_p = 64;
  if (xgemm_p == 0) xgemm_p = 64;
#endif

  sgemm_r = (((BUFFER_LIMIT - ((SGEMM_P * SGEMM_Q *  4 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (SGEMM_Q *  4)) - 15) & ~15;
  dgemm_r = (((BUFFER_LIMIT - ((DGEMM_P * DGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (DGEMM_Q *  8)) - 15) & ~15;
  cgemm_r = (((BUFFER_LIMIT - ((CGEMM_P * CGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (CGEMM_Q *  8)) - 15) & ~15;
  zgemm_r = (((BUFFER_LIMIT - ((ZGEMM_P * ZGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (ZGEMM_Q * 16)) - 15) & ~15;
#ifdef EXPRECISION
  qgemm_r = (((BUFFER_LIMIT - ((QGEMM_P * QGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (QGEMM_Q * 16)) - 15) & ~15;
  xgemm_r = (((BUFFER_LIMIT - ((XGEMM_P * XGEMM_Q * 32 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (XGEMM_Q * 32)) - 15) & ~15;
#endif
  return;
}

#if 0

int get_current_cpu_info(void){

  int nlprocs, ncores, cmplegacy;
  int htt     = 0;
  int apicid  = 0;

#if defined(CORE_PRESCOTT) || defined(CORE_OPTERON)
  int eax, ebx, ecx, edx;

  cpuid(1, &eax, &ebx, &ecx, &edx);
  nlprocs = BITMASK(ebx, 16, 0xff);
  apicid  = BITMASK(ebx, 24, 0xff);
  htt     = BITMASK(edx, 28, 0x01);
#endif

#if defined(CORE_PRESCOTT)
  cpuid(4, &eax, &ebx, &ecx, &edx);
  ncores = BITMASK(eax, 26, 0x3f);

  if (htt == 0)  nlprocs = 0;
#endif

#if defined(CORE_OPTERON)
  cpuid(0x80000008, &eax, &ebx, &ecx, &edx);
  ncores = BITMASK(ecx,  0, 0xff);

  cpuid(0x80000001, &eax, &ebx, &ecx, &edx);
  cmplegacy = BITMASK(ecx,  1, 0x01);

  if (htt == 0) {
    nlprocs = 0;
    ncores  = 0;
    cmplegacy = 0;
  }
#endif

  ncores  ++;

  fprintf(stderr, "APICID = %d  Number of core = %d\n", apicid, ncores);

  return 0;
}
#endif

#endif

#if defined(ARCH_IA64)

static inline BLASULONG cpuid(BLASULONG regnum){ 
  BLASULONG value;

#ifndef __ECC
  asm ("mov %0=cpuid[%r1]" : "=r"(value) : "rO"(regnum));
#else
 value = __getIndReg(_IA64_REG_INDR_CPUID, regnum);
#endif

  return value;
}

void blas_set_parameter(void){
  
  BLASULONG cpuid3, size;

  cpuid3 = cpuid(3);
  
  size = BITMASK(cpuid3, 16, 0xff);

  sgemm_p = 192 * (size + 1);
  dgemm_p =  96 * (size + 1);
  cgemm_p =  96 * (size + 1);
  zgemm_p =  48 * (size + 1);
#ifdef EXPRECISION
  qgemm_p =  64 * (size + 1);
  xgemm_p =  32 * (size + 1);
#endif

  sgemm_r = (((BUFFER_LIMIT - ((SGEMM_P * SGEMM_Q *  4 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (SGEMM_Q *  4)) - 15) & ~15;
  dgemm_r = (((BUFFER_LIMIT - ((DGEMM_P * DGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (DGEMM_Q *  8)) - 15) & ~15;
  cgemm_r = (((BUFFER_LIMIT - ((CGEMM_P * CGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (CGEMM_Q *  8)) - 15) & ~15;
  zgemm_r = (((BUFFER_LIMIT - ((ZGEMM_P * ZGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (ZGEMM_Q * 16)) - 15) & ~15;
#ifdef EXPRECISION
  qgemm_r = (((BUFFER_LIMIT - ((QGEMM_P * QGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (QGEMM_Q * 16)) - 15) & ~15;
  xgemm_r = (((BUFFER_LIMIT - ((XGEMM_P * XGEMM_Q * 32 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (XGEMM_Q * 32)) - 15) & ~15;
#endif

  return;
}
#endif


