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

#ifndef COMPLEX
#ifdef XDOUBLE
#define SYMM_IUTCOPY qsymm_iutcopy
#define SYMM_ILTCOPY qsymm_iltcopy
#define SYMM_OUTCOPY qsymm_outcopy
#define SYMM_OLTCOPY qsymm_oltcopy
#elif defined(DOUBLE)
#define SYMM_IUTCOPY dsymm_iutcopy
#define SYMM_ILTCOPY dsymm_iltcopy
#define SYMM_OUTCOPY dsymm_outcopy
#define SYMM_OLTCOPY dsymm_oltcopy
#else
#define SYMM_IUTCOPY ssymm_iutcopy
#define SYMM_ILTCOPY ssymm_iltcopy
#define SYMM_OUTCOPY ssymm_outcopy
#define SYMM_OLTCOPY ssymm_oltcopy
#endif
#else
#ifdef XDOUBLE
#define SYMM_IUTCOPY xsymm_iutcopy
#define SYMM_ILTCOPY xsymm_iltcopy
#define SYMM_OUTCOPY xsymm_outcopy
#define SYMM_OLTCOPY xsymm_oltcopy
#elif defined(DOUBLE)
#define SYMM_IUTCOPY zsymm_iutcopy
#define SYMM_ILTCOPY zsymm_iltcopy
#define SYMM_OUTCOPY zsymm_outcopy
#define SYMM_OLTCOPY zsymm_oltcopy
#else
#define SYMM_IUTCOPY csymm_iutcopy
#define SYMM_ILTCOPY csymm_iltcopy
#define SYMM_OUTCOPY csymm_outcopy
#define SYMM_OLTCOPY csymm_oltcopy
#endif
#endif

#if GEMM_UNROLL_M == GEMM_UNROLL_N
#undef  SYMM_IUTCOPY
#undef  SYMM_ILTCOPY
#define SYMM_IUTCOPY SYMM_OUTCOPY
#define SYMM_ILTCOPY SYMM_OLTCOPY
#endif

#ifndef RSIDE
#ifndef LOWER
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) SYMM_IUTCOPY(M, N, A, LDA, Y, X, BUFFER);
#else
#define ICOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) SYMM_ILTCOPY(M, N, A, LDA, Y, X, BUFFER);
#endif
#endif

#ifdef RSIDE
#ifndef LOWER
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) SYMM_OUTCOPY(M, N, A, LDA, Y, X, BUFFER);
#else
#define OCOPY_OPERATION(M, N, A, LDA, X, Y, BUFFER) SYMM_OLTCOPY(M, N, A, LDA, Y, X, BUFFER);
#endif
#endif

#ifndef RSIDE
#define K		args -> m
#ifndef LOWER
#define GEMM_LOCAL    SYMM_LU
#else
#define GEMM_LOCAL    SYMM_LL
#endif
#else
#define K		args -> n
#ifndef LOWER
#define GEMM_LOCAL    SYMM_RU
#else
#define GEMM_LOCAL    SYMM_RL
#endif
#endif

#ifdef THREADED_LEVEL3
#include "../gemm/level3_thread.c"
#else
#include "../gemm/level3.c"
#endif
