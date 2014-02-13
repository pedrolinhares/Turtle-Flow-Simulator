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

#ifndef COMPLEX
#define SCAL	SCAL_K
#else
#define SCAL	ZSCAL_K
#endif

static inline int syrk_beta(BLASLONG m_from, BLASLONG m_to, BLASLONG n_from, BLASLONG n_to, FLOAT *alpha, FLOAT *c, BLASLONG ldc) {

  BLASLONG i;

  c += n_from * ldc * COMPSIZE;

  for (i = n_from; i < n_to; i++){
#ifndef LOWER
    SCAL(MIN(i, m_to) + 1 - m_from, 0, 0, alpha[0],
#ifdef COMPLEX
	   alpha[1],
#endif
	   c + m_from * COMPSIZE, 1, NULL, 0, NULL, 0);
#else
    SCAL(m_to - MAX(i, m_from), 0, 0, alpha[0], 
#ifdef COMPLEX
	   alpha[1],
#endif
	   c + MAX(i, m_from) * COMPSIZE, 1, NULL, 0, NULL, 0);
#endif

    c += ldc * COMPSIZE;
  }

  return 0;
}

#include "level3_syrk.c"
