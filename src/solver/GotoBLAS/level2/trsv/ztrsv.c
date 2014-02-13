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
#include <ctype.h>
#include "common.h"

#ifdef XDOUBLE
#define ERROR_NAME "XTRSV "
#elif defined(DOUBLE)
#define ERROR_NAME "ZTRSV "
#else
#define ERROR_NAME "CTRSV "
#endif

static int (*trsv[])(BLASLONG, FLOAT *, BLASLONG, FLOAT *, BLASLONG, void *) = {
#ifdef XDOUBLE
  xtrsv_NUU, xtrsv_NUN, xtrsv_NLU, xtrsv_NLN,
  xtrsv_TUU, xtrsv_TUN, xtrsv_TLU, xtrsv_TLN,
  xtrsv_RUU, xtrsv_RUN, xtrsv_RLU, xtrsv_RLN,
  xtrsv_CUU, xtrsv_CUN, xtrsv_CLU, xtrsv_CLN,
#elif defined(DOUBLE)
  ztrsv_NUU, ztrsv_NUN, ztrsv_NLU, ztrsv_NLN,
  ztrsv_TUU, ztrsv_TUN, ztrsv_TLU, ztrsv_TLN,
  ztrsv_RUU, ztrsv_RUN, ztrsv_RLU, ztrsv_RLN,
  ztrsv_CUU, ztrsv_CUN, ztrsv_CLU, ztrsv_CLN,
#else
  ctrsv_NUU, ctrsv_NUN, ctrsv_NLU, ctrsv_NLN,
  ctrsv_TUU, ctrsv_TUN, ctrsv_TLU, ctrsv_TLN,
  ctrsv_RUU, ctrsv_RUN, ctrsv_RLU, ctrsv_RLN,
  ctrsv_CUU, ctrsv_CUN, ctrsv_CLU, ctrsv_CLN,
#endif
};

int NAME(char *UPLO, char *TRANS, char *DIAG,
	   blasint *N, FLOAT *a, blasint *LDA, FLOAT *b, blasint *INCX){
  
  char uplo_arg  = *UPLO;
  char trans_arg = *TRANS;
  char diag_arg  = *DIAG;
  
  blasint n    = *N;
  blasint lda  = *LDA;
  blasint incx = *INCX;

  blasint info;
  int uplo;
  int unit;
  int trans;
  FLOAT *buffer;

  TOUPPER(uplo_arg);
  TOUPPER(trans_arg);
  TOUPPER(diag_arg);

  trans = -1;
  unit  = -1;
  uplo  = -1;

  if (trans_arg == 'N') trans = 0;
  if (trans_arg == 'T') trans = 1;
  if (trans_arg == 'R') trans = 2;
  if (trans_arg == 'C') trans = 3;

  if (diag_arg  == 'U') unit  = 0;
  if (diag_arg  == 'N') unit  = 1;

  if (uplo_arg  == 'U') uplo  = 0;
  if (uplo_arg  == 'L') uplo  = 1;
 

  info = 0;

  if (incx == 0)          info =  8;
  if (lda  < MAX(1, n))   info =  6;
  if (n < 0)              info =  4;
  if (unit  < 0)          info =  3;
  if (trans < 0)          info =  2;
  if (uplo  < 0)          info =  1;

  if (info != 0) {
    BLASFUNC(xerbla)(ERROR_NAME, &info, sizeof(ERROR_NAME));
    return 0;
  }
  
  if (n == 0) return 0;
  
  if (incx < 0 ) b -= (n - 1) * incx * 2;

  buffer = (FLOAT *)blas_memory_alloc(1);

  (trsv[(trans<<2) | (uplo<<1) | unit])(n, a, lda, b, incx, buffer);

  blas_memory_free(buffer);

  return 0;
}
