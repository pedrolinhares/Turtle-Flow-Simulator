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

#include "common.h"

#ifdef OUTER

#ifdef LOWER
#if GEMM_UNROLL_N ==  1
#include "zsymm_lcopy_1.c"
#endif
#if GEMM_UNROLL_N ==  2
#include "zsymm_lcopy_2.c"
#endif
#if GEMM_UNROLL_N ==  4
#include "zsymm_lcopy_4.c"
#endif
#if GEMM_UNROLL_N ==  8
#include "zsymm_lcopy_8.c"
#endif
#if GEMM_UNROLL_N == 16
#include "zsymm_lcopy_16.c"
#endif
#else
#if GEMM_UNROLL_N ==  1
#include "zsymm_ucopy_1.c"
#endif
#if GEMM_UNROLL_N ==  2
#include "zsymm_ucopy_2.c"
#endif
#if GEMM_UNROLL_N ==  4
#include "zsymm_ucopy_4.c"
#endif
#if GEMM_UNROLL_N ==  8
#include "zsymm_ucopy_8.c"
#endif
#if GEMM_UNROLL_N == 16
#include "zsymm_ucopy_16.c"
#endif
#endif

#else

#if GEMM_UNROLL_M != GEMM_UNROLL_N
#ifdef LOWER
#if GEMM_UNROLL_M ==  1
#include "zsymm_lcopy_1.c"
#endif
#if GEMM_UNROLL_M ==  2
#include "zsymm_lcopy_2.c"
#endif
#if GEMM_UNROLL_M ==  4
#include "zsymm_lcopy_4.c"
#endif
#if GEMM_UNROLL_M ==  8
#include "zsymm_lcopy_8.c"
#endif
#if GEMM_UNROLL_M == 16
#include "zsymm_lcopy_16.c"
#endif
#else
#if GEMM_UNROLL_M ==  1
#include "zsymm_ucopy_1.c"
#endif
#if GEMM_UNROLL_M ==  2
#include "zsymm_ucopy_2.c"
#endif
#if (GEMM_UNROLL_M) ==  4
#include "zsymm_ucopy_4.c"
#endif
#if GEMM_UNROLL_M ==  8
#include "zsymm_ucopy_8.c"
#endif
#if GEMM_UNROLL_M == 16
#include "zsymm_ucopy_16.c"
#endif
#endif
#endif

#endif
