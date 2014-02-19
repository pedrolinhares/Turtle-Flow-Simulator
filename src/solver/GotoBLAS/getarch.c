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
#include <string.h>
#if defined(__WIN32__) || defined(__WIN64__)
#include <windows.h>
#endif
#if defined(__FreeBSD__) || defined(__APPLE__)
#include <sys/sysctl.h>
#endif

/* #define FORCE_P2		*/
/* #define FORCE_KATMAI		*/
/* #define FORCE_COPPERMINE	*/
/* #define FORCE_NORTHWOOD	*/
/* #define FORCE_PRESCOTT	*/
#define FORCE_BANIAS	
/* #define FORCE_YONAH		*/
/* #define FORCE_CORE2		*/
/* #define FORCE_PENRYN		*/
/* #define FORCE_ATHLON		*/
/* #define FORCE_OPTERON	*/
/* #define FORCE_OPTERON_SSE3	*/
/* #define FORCE_BARCELONA	*/
/* #define FORCE_SSE_GENERIC	*/
/* #define FORCE_VIAC3		*/
/* #define FORCE_POWER3		*/
/* #define FORCE_POWER4		*/
/* #define FORCE_POWER5		*/
/* #define FORCE_PPCG4		*/
/* #define FORCE_PPC970		*/
/* #define FORCE_PPC970MP	*/
/* #define FORCE_PPC440		*/
/* #define FORCE_PPC440FP2	*/
/* #define FORCE_CELL		*/
/* #define FORCE_GENERIC	*/

#ifdef FORCE_P2
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENTIUM2"
#define ARCHCONFIG   "-DPENTIUM2 " \
		     "-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=512488 -DL2_LINESIZE=32 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX"
#define LIBNAME   "p2"
#define CORENAME  "P5"
#endif

#ifdef FORCE_COPPERMINE
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENTIUM3"
#define ARCHCONFIG   "-DPENTIUM3 " \
		     "-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=262144 -DL2_LINESIZE=32 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE "
#define LIBNAME   "coppermine"
#define CORENAME  "COPPERMINE"
#endif

#ifdef FORCE_KATMAI
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENTIUM3"
#define ARCHCONFIG   "-DPENTIUM3 " \
		     "-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=524288 -DL2_LINESIZE=32 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE "
#define LIBNAME   "katmai"
#define CORENAME  "KATMAI"
#endif

#ifdef FORCE_NORTHWOOD
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENTIUM4"
#define ARCHCONFIG   "-DPENTIUM4 " \
		     "-DL1_DATA_SIZE=8192 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=524288 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 "
#define LIBNAME   "northwood"
#define CORENAME  "NORTHWOOD"
#endif

#ifdef FORCE_PRESCOTT
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENTIUM4"
#define ARCHCONFIG   "-DPENTIUM4 " \
		     "-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 -DHAVE_SSE3"
#define LIBNAME   "prescott"
#define CORENAME  "PRESCOTT"
#endif

#ifdef FORCE_BANIAS
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "BANIAS"
#define ARCHCONFIG   "-DPENTIUMM " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 "
#define LIBNAME   "banias"
#define CORENAME  "BANIAS"
#endif

#ifdef FORCE_YONAH
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "YONAH"
#define ARCHCONFIG   "-DPENTIUMM " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 "
#define LIBNAME   "yonah"
#define CORENAME  "YONAH"
#endif

#ifdef FORCE_CORE2
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "CONRORE"
#define ARCHCONFIG   "-DCORE2 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=256 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 -DHAVE_SSE3 -DHAVE_SSSE3"
#define LIBNAME   "core2"
#define CORENAME  "CORE2"
#endif

#ifdef FORCE_PENRYN
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "PENRYN"
#define ARCHCONFIG   "-DPENRYN " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=256 -DDTB_SIZE=4096 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 -DHAVE_SSE3 -DHAVE_SSSE3 -DHAVE_SSE4_1"
#define LIBNAME   "penryn"
#define CORENAME  "PENRYN"
#endif

#ifdef FORCE_ATHLON
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "ATHLON"
#define ARCHCONFIG   "-DATHLON " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=32 -DDTB_SIZE=4096 -DHAVE_3DNOW  " \
		     "-DHAVE_3DNOWEX -DHAVE_MMX -DHAVE_SSE "
#define LIBNAME   "athlon"
#define CORENAME  "ATHLON"
#endif

#ifdef FORCE_OPTERON
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "OPTERON"
#define ARCHCONFIG   "-DOPTERON " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=32 -DDTB_SIZE=4096 -DHAVE_3DNOW " \
		     "-DHAVE_3DNOWEX -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 "
#define LIBNAME   "opteron"
#define CORENAME  "OPTERON"
#endif

#ifdef FORCE_OPTERON_SSE3
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "OPTERON"
#define ARCHCONFIG   "-DOPTERON " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=1048576 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=32 -DDTB_SIZE=4096 -DHAVE_3DNOW " \
		     "-DHAVE_3DNOWEX -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 -DHAVE_SSE3"
#define LIBNAME   "opteron"
#define CORENAME  "OPTERON"
#endif

#ifdef FORCE_BARCELONA
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "BARCELONA"
#define ARCHCONFIG   "-DBARCELONA " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=524288 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=40 -DDTB_SIZE=4096 -DHAVE_3DNOW " \
		     "-DHAVE_3DNOWEX -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2 -DHAVE_SSE3 " \
		     "-DHAVE_SSE4A -DHAVE_MISALIGNSSE -DHAVE_128BITFPU -DHAVE_FASTMOVU"
#define LIBNAME   "barcelona"
#define CORENAME  "BARCELONA"
#endif

#ifdef FORCE_SSE_GENERIC
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "GENERIC"
#define ARCHCONFIG   "-DGENERIC " \
		     "-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=64 " \
		     "-DL2_SIZE=524288 -DL2_LINESIZE=64 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 " \
		     "-DHAVE_CMOV -DHAVE_MMX -DHAVE_SSE -DHAVE_SSE2"
#define LIBNAME   "generic"
#define CORENAME  "GENERIC"
#endif

#ifdef FORCE_VIAC3
#define FORCE
#define FORCE_INTEL
#define ARCHITECTURE    "X86"
#define SUBARCHITECTURE "VIAC3"
#define ARCHCONFIG   "-DVIAC3 " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=65536 -DL2_LINESIZE=32 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 " \
		     "-DHAVE_MMX -DHAVE_SSE "
#define LIBNAME   "viac3"
#define CORENAME  "VIAC3"
#endif

#ifdef FORCE_POWER3
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "POWER3"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPOWER3 " \
		     "-DL1_DATA_SIZE=65536 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=2097152 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=256 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "power3"
#define CORENAME  "POWER3"
#endif

#ifdef FORCE_POWER4
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "POWER4"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPOWER4 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=1509949 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=6 "
#define LIBNAME   "power4"
#define CORENAME  "POWER4"
#endif

#ifdef FORCE_POWER5
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "POWER5"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPOWER5 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=1509949 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=6 "
#define LIBNAME   "power5"
#define CORENAME  "POWER4"
#endif

#ifdef FORCE_PPCG4
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "PPCG4"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPPCG4 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=262144 -DL2_LINESIZE=32 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "ppcg4"
#define CORENAME  "PPCG4"
#endif

#ifdef FORCE_PPC970
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "PPC970"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPPC970 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=512488 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "ppc970"
#define CORENAME  "PPC970"
#endif

#ifdef FORCE_PPC970MP
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "PPC970"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPPC970 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=1024976 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "ppc970mp"
#define CORENAME  "PPC970"
#endif

#ifdef FORCE_PPC440
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "PPC440"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPPC440 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=16384 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=16 "
#define LIBNAME   "ppc440"
#define CORENAME  "PPC440"
#endif

#ifdef FORCE_PPC440FP2
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "PPC440FP2"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DPPC440FP2 " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=32 " \
		     "-DL2_SIZE=16384 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=64 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=16 "
#define LIBNAME   "ppc440FP2"
#define CORENAME  "PPC440FP2"
#endif

#ifdef FORCE_CELL
#define FORCE
#define ARCHITECTURE    "POWER"
#define SUBARCHITECTURE "CELL"
#define SUBDIRNAME      "power"
#define ARCHCONFIG   "-DARCH_POWER -DCELL " \
		     "-DL1_DATA_SIZE=262144 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=512488 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "cell"
#define CORENAME  "CELL"
#endif

#ifdef FORCE_GENERIC
#define FORCE
#define ARCHITECTURE    "GENERIC"
#define SUBARCHITECTURE "GENERIC"
#define SUBDIRNAME      "generic"
#define ARCHCONFIG   "-DARCH_GENERIC -DGENERIC " \
		     "-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 " \
		     "-DL2_SIZE=512488 -DL2_LINESIZE=128 " \
		     "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 "
#define LIBNAME   "generic"
#define CORENAME  "generic"
#endif

#ifndef FORCE

#if defined(__powerpc__) || defined(__powerpc) || defined(powerpc) || \
    defined(__PPC__) || defined(PPC) || defined(_POWER) || defined(__POWERPC__)
#ifndef POWER
#define POWER
#endif
#endif

#if defined(__i386__) || (__x86_64__)
#ifdef __64BIT__
#define ADDITIONAL	"-DARCH_X86_64"
#undef  SUBDIRNAME
#define SUBDIRNAME      "x86_64"
#else
#define ADDITIONAL	"-DARCH_X86"
#undef  SUBDIRNAME
#define SUBDIRNAME      "x86"
#endif
#endif

#if defined(__i386__) || (__x86_64__)
#include "cpuid_x86.c"
#endif

#ifdef __ia64__
#include "cpuid_ia64.c"
#endif

#ifdef __alpha
#include "cpuid_alpha.c"
#endif

#ifdef POWER
#include "cpuid_power.c"
#endif

#ifdef sparc
#include "cpuid_sparc.c"
#endif

#else

#if defined(__i386__) || (__x86_64__)
#ifdef __64BIT__
#define ADDITIONAL	"-DARCH_X86_64"
#define SUBDIRNAME      "x86_64"
#else
#define ADDITIONAL	"-DARCH_X86"
#define SUBDIRNAME      "x86"
#endif
#endif

#endif


int main(int argc, char *argv[]){

#if defined(__WIN32__) || defined(__WIN64__)
  SYSTEM_INFO sysinfo;
#elif defined(__FreeBSD__) || defined(__APPLE__)
  int m[2], count;
  size_t len;
#endif

  if (argc == 1) return 0;

  switch (argv[1][0]) {

  case '0' : /* ARCHITECTURE */
#ifdef FORCE
    printf("%s", ARCHITECTURE);
#if defined(FORCE_INTEL) && defined(__64BIT__)
    printf("_64");
#endif
#else
    get_architecture();
#endif
    break;

  case '1' :  /* Sub Architecture */
#ifdef FORCE
    printf("%s", SUBARCHITECTURE);
#else
    get_subarchitecture();
#endif
    break;

  case '2' : /* Subdirectory Name */
#ifdef FORCE
    printf("%s", SUBDIRNAME);
#else
    get_subdirname();
#endif
    break;

  case '3' : /* Architecture Definition */
#ifdef FORCE_INTEL
    printf("%s ", ADDITIONAL);
#endif

#ifdef FORCE
    printf("%s -DCORE_%s", ARCHCONFIG, CORENAME);
#else
    get_cpuconfig();
#endif
    break;

  case '4' :  /* if it needs a prefix in front of symbol; it's depend on OS */
#if defined(__CYGWIN__) || defined(__APPLE__) || defined(NEED_FU)
    printf("_");
#endif
    break;

  case '5' : /* Library Name */
#ifdef FORCE
    printf("%s", LIBNAME);
#else
    get_libname();
#endif
    break;

  case '6' : /* Core Name */
#ifdef FORCE
    printf("%s", CORENAME);
#else    
#if defined(__i386__) || defined(__x86_64__) || defined(POWER)
    printf("%s", get_corename());
#endif
#endif
    break;

  case '7' :
#ifdef linux

  printf("%d", get_nprocs());

#elif defined(__WIN32__) || defined(__WIN64__)

  GetSystemInfo(&sysinfo);
  printf("%d", sysinfo.dwNumberOfProcessors);

#elif defined(__FreeBSD__) || defined(__APPLE__)
  m[0] = CTL_HW;
  m[1] = HW_NCPU;
  len = sizeof(int);
  sysctl(m, 2, &count, &len, NULL, 0);

  printf("%d", count);
#else
  printf("2");
#endif
 break;

  }

  fflush(stdout);

  return 0;
}

