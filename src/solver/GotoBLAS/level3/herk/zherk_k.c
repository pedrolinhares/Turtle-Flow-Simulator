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

#ifndef LOWER

#ifndef CONJ
#ifdef XDOUBLE
#define KERNEL_FUNC xherk_kernel_UN
#elif defined(DOUBLE)
#define KERNEL_FUNC zherk_kernel_UN
#else
#define KERNEL_FUNC cherk_kernel_UN
#endif
#else
#ifdef XDOUBLE
#define KERNEL_FUNC xherk_kernel_UC
#elif defined(DOUBLE)
#define KERNEL_FUNC zherk_kernel_UC
#else
#define KERNEL_FUNC cherk_kernel_UC
#endif
#endif

#else

#ifndef CONJ
#ifdef XDOUBLE
#define KERNEL_FUNC xherk_kernel_LN
#elif defined(DOUBLE)
#define KERNEL_FUNC zherk_kernel_LN
#else
#define KERNEL_FUNC cherk_kernel_LN
#endif
#else
#ifdef XDOUBLE
#define KERNEL_FUNC xherk_kernel_LC
#elif defined(DOUBLE)
#define KERNEL_FUNC zherk_kernel_LC
#else
#define KERNEL_FUNC cherk_kernel_LC
#endif
#endif

#endif

#define KERNEL_OPERATION(M, N, K, ALPHA, SA, SB, C, LDC, X, Y) \
	KERNEL_FUNC(M, N, K, ALPHA[0], SA, SB, (FLOAT *)(C) + ((X) + (Y) * LDC) * COMPSIZE, LDC, (X) - (Y))


static inline int syrk_beta(BLASLONG m_from, BLASLONG m_to, BLASLONG n_from, BLASLONG n_to, FLOAT *alpha, FLOAT *c, BLASLONG ldc) {

  BLASLONG i;

  c += n_from * ldc * COMPSIZE;

  for (i = n_from; i < n_to; i++){
#ifndef LOWER
    SCAL_K((MIN(i, m_to) - m_from) * COMPSIZE, 0, 0, alpha[0],
	   c + m_from         * COMPSIZE, 1, NULL, 0, NULL, 0);
    if (i < m_to) {
      *(c + i * COMPSIZE + 0) *= alpha[0];
      *(c + i * COMPSIZE + 1)  = ZERO;
    }
#else
    if (i >= m_from) {
      *(c + i * COMPSIZE + 0) *= alpha[0];
      *(c + i * COMPSIZE + 1)  = ZERO;
    }

    SCAL_K((m_to - MAX(i, m_from) - 1) * COMPSIZE, 0, 0, alpha[0], 
	 c + (MAX(i, m_from) + 1) * COMPSIZE, 1, NULL, 0, NULL, 0);
#endif
    c += ldc * COMPSIZE;
  }

  return 0;
}

#include "../syrk/level3_syrk.c"
