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

#undef TIMING

#ifdef COMPLEX
#ifdef XDOUBLE
#define HEMM_IUTCOPY xhemm_iutcopy
#define HEMM_ILTCOPY xhemm_iltcopy
#define HEMM_OUTCOPY xhemm_outcopy
#define HEMM_OLTCOPY xhemm_oltcopy
#elif defined(DOUBLE)
#define HEMM_IUTCOPY zhemm_iutcopy
#define HEMM_ILTCOPY zhemm_iltcopy
#define HEMM_OUTCOPY zhemm_outcopy
#define HEMM_OLTCOPY zhemm_oltcopy
#else
#define HEMM_IUTCOPY chemm_iutcopy
#define HEMM_ILTCOPY chemm_iltcopy
#define HEMM_OUTCOPY chemm_outcopy
#define HEMM_OLTCOPY chemm_oltcopy
#endif
#endif

#if GEMM_UNROLL_M == GEMM_UNROLL_N
#undef  HEMM_IUTCOPY
#undef  HEMM_ILTCOPY
#define HEMM_IUTCOPY HEMM_OUTCOPY
#define HEMM_ILTCOPY HEMM_OLTCOPY
#endif

#ifndef RSIDE
#ifndef LOWER
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) HEMM_IUTCOPY(M, N, A, LDA, Y, X, BUFFER);
#else
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) HEMM_ILTCOPY(M, N, A, LDA, Y, X, BUFFER);
#endif
#endif

#ifdef RSIDE
#ifndef LOWER
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) HEMM_OUTCOPY(M, N, A, LDA, Y, X, BUFFER);
#else
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) HEMM_OLTCOPY(M, N, A, LDA, Y, X, BUFFER);
#endif
#endif

#ifndef RSIDE
#define K		args -> m
#ifndef LOWER
#define GEMM_LOCAL    HEMM_LU
#else
#define GEMM_LOCAL    HEMM_LL
#endif
#else
#define K		args -> n
#ifndef LOWER
#define GEMM_LOCAL    HEMM_RU
#else
#define GEMM_LOCAL    HEMM_RL
#endif
#endif

#ifdef THREADED_LEVEL3
#include "../gemm/level3_thread.c"
#else
#include "../gemm/level3.c"
#endif
