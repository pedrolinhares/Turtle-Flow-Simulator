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

#ifndef COMMON_H
#define COMMON_H

#if defined(SMP_SERVER) || defined(SMP_ONDEMAND)
#define SMP
#endif

#if (defined( __WIN32__) || defined(__CYGWIN32__) || defined(__WIN64__)) && defined(DOUBLE)
#define DOUBLE_DEFINED DOUBLE
#undef  DOUBLE
#endif

#if !defined(NOINCLUDE) && !defined(ASSEMBLER)
#include <stdio.h>
#include <stdlib.h>

#ifdef linux
#include <malloc.h>
#endif

#if defined(__WIN32__) || defined(__WIN64__) || defined(__CYGWIN32__)
#include <windows.h>
#else
#include <sys/mman.h>
#include <sys/shm.h>
#include <sys/time.h>
#include <unistd.h>
#include <math.h>
#ifdef SMP
#include <pthread.h>
#endif
#endif

#ifdef __DECC
#include <c_asm.h>
#include <machine/builtins.h>
#endif
#endif

#if (defined( __WIN32__) || defined(__CYGWIN32__) || defined(__WIN64__)) && defined(DOUBLE_DEFINED)
#define DOUBLE DOUBLE_DEFINED
#undef DOUBLE_DEFINED
#endif

#undef DEBUG_INFO
#undef SMP_DEBUG
#undef MALLOC_DEBUG
#undef SMP_ALLOC_DEBUG

#ifndef ZERO
#define ZERO 0.000
#endif

#ifndef ONE
#define ONE  1.000
#endif

#define BITMASK(a, b, c) ((((a) >> (b)) & (c)))

#define ALLOCA_ALIGN 63UL

#ifdef NEEDBUNDERSCORE
#define BLASFUNC(FUNC) FUNC##_
#else
#define BLASFUNC(FUNC) FUNC
#endif

#undef	USE_PTHREAD_LOCK
#undef	USE_PTHREAD_SPINLOCK

#if defined(USE_PTHREAD_LOCK) && defined(USE_PTHREAD_SPINLOCK)
#error "You can't specify both LOCK operation!"
#endif

#ifdef SMP
#define USE_PTHREAD_LOCK
#undef	USE_PTHREAD_SPINLOCK
#endif

#if defined( __WIN32__) || defined(__CYGWIN32__)
#undef	USE_PTHREAD_LOCK
#undef	USE_PTHREAD_SPINLOCK
#endif

#if   defined(USE_PTHREAD_LOCK)
#define   LOCK_COMMAND(x)   pthread_mutex_lock(x)
#define UNLOCK_COMMAND(x)   pthread_mutex_unlock(x)
#elif defined(USE_PTHREAD_SPINLOCK)
#ifndef ASSEMBLER
typedef volatile int pthread_spinlock_t;
int pthread_spin_lock (pthread_spinlock_t *__lock);
int pthread_spin_unlock (pthread_spinlock_t *__lock);
#endif
#define   LOCK_COMMAND(x)   pthread_spin_lock(x)
#define UNLOCK_COMMAND(x)   pthread_spin_unlock(x)
#else
#define   LOCK_COMMAND(x)   blas_lock(x)
#define UNLOCK_COMMAND(x)   blas_unlock(x)
#endif

#ifndef ASSEMBLER

#ifdef __WIN64__
typedef long long BLASLONG;
typedef unsigned long long BLASULONG;
#else
typedef long BLASLONG;
typedef unsigned long BLASULONG;
#endif

#ifdef USE64BITINT
typedef BLASLONG blasint;
#else
typedef int blasint;
#endif
#else
#ifdef USE64BITINT
#define INTSHIFT	3
#define INTSIZE		8
#else
#define INTSHIFT	2
#define INTSIZE		4
#endif
#endif

#ifdef XDOUBLE
#define FLOAT	xdouble
#define SIZE	16
#define  BASE_SHIFT 4
#define ZBASE_SHIFT 5
#elif defined(DOUBLE)
#define FLOAT	double
#define SIZE	8
#define  BASE_SHIFT 3
#define ZBASE_SHIFT 4
#else
#define FLOAT	float
#define SIZE    4
#define  BASE_SHIFT 2
#define ZBASE_SHIFT 3
#endif

#ifndef COMPLEX
#define COMPSIZE  1
#else
#define COMPSIZE  2
#endif

#define Address_H(x) (((x)+(1<<15))>>16)
#define Address_L(x) ((x)-((Address_H(x))<<16))

#ifndef MAX_CPU_NUMBER
#define MAX_CPU_NUMBER 2
#endif

#ifdef ARCH_ALPHA
#include "common_alpha.h"
#endif

#ifdef ARCH_X86
#include "common_x86.h"
#endif

#ifdef ARCH_X86_64
#include "common_x86_64.h"
#endif

#ifdef ARCH_IA64
#include "common_ia64.h"
#endif

#ifdef ARCH_POWER
#include "common_power.h"
#endif

#ifdef sparc
#include "common_sparc.h"
#endif

#include "param.h"

#ifndef STDERR
#define STDERR stderr
#endif

#ifndef ASSEMBLER

#ifndef MIN
#define MIN(a,b)   (a>b? b:a)
#endif

#ifndef MAX
#define MAX(a,b)   (a<b? b:a)
#endif

#define TOUPPER(a) {if ((a) > 0x60) (a) -= 0x20;}

#ifdef EXPRECISION
typedef long double xdouble;
#else
typedef double xdouble;
#endif

#if defined(__FreeBSD__) || defined(__APPLE__)
#define MAP_ANONYMOUS MAP_ANON
#endif

/* Common Memory Management Routine */
void  blas_set_parameter(void);
int   blas_get_cpu_number(void);
void *blas_memory_alloc  (int);
void  blas_memory_free   (void *);
double fabs(double);

static __inline void blas_unlock(BLASULONG *address){
  MB;
  *address = 0;
}

static __inline void compinv(FLOAT *b, FLOAT ar, FLOAT ai){

#ifndef UNIT
  FLOAT ratio, den;
      
  if (fabs(ar) >= fabs(ai)){
    ratio = ai / ar;
    den   = 1. / (ar * ( 1 + ratio * ratio));
    ar =  den;
    ai = -ratio * den;
  } else {
    ratio = ar / ai;
    den   = 1. /(ai * ( 1 + ratio * ratio));
    ar =  ratio * den;
    ai = -den;
  }
  b[0] = ar;
  b[1] = ai;
#else
  b[0] = ONE;
  b[1] = ZERO;
#endif
  
}


#ifdef MALLOC_DEBUG
void *blas_debug_alloc(int);
void *blas_debug_free(void *);
#undef malloc
#undef free
#define malloc(a) blas_debug_alloc(a)
#define free(a)   blas_debug_free (a)
#endif

#ifndef COPYOVERHEAD
#define GEMMRETTYPE  int
#else

typedef struct {
  double outercopy;
  double innercopy;
  double kernel;
  double mflops;
} copyoverhead_t;

#define GEMMRETTYPE  copyoverhead_t
#endif
#endif

#include "common_interface.h"
#include "common_level1.h"
#include "common_level2.h"
#include "common_level3.h"
#include "common_lapack.h"

#ifndef ASSEMBLER
#include "symcopy.h"

#if defined(SMP_SERVER) && defined(SMP_ONDEMAND)
#error Both SMP_SERVER and SMP_ONDEMAND are specified.
#endif

#if defined(SMP_SERVER) || defined(SMP_ONDEMAND)
#include "common_thread.h"
#endif

#endif

#define INFO_NUM 99

#ifndef DEFAULT_CPU_NUMBER
#define DEFAULT_CPU_NUMBER 4
#endif

#endif
