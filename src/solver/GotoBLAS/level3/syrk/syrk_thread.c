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
#include <stdlib.h>
#include <math.h>
#include "common.h"

int CNAME(int mode, blas_arg_t *arg, BLASLONG *range_m, BLASLONG *range_n, int (*function)(), void *sa, void *sb) {

  blas_queue_t queue[MAX_CPU_NUMBER];
  BLASLONG range[MAX_CPU_NUMBER + 1];

  BLASLONG width, i;
  BLASLONG n = arg -> n;
  int num_cpu;
  int mask = 0;
  double dnum = (double)n * (double)n /(double)blas_cpu_number;
  
  if (!(mode & BLAS_COMPLEX)) {

    switch (mode & BLAS_PREC) {
    case BLAS_SINGLE:
      mask = MAX(SGEMM_UNROLL_M, SGEMM_UNROLL_N);
      break;
    case BLAS_DOUBLE:
      mask = MAX(DGEMM_UNROLL_M, DGEMM_UNROLL_N);
      break;
#ifdef EXPRECISION
    case BLAS_XDOUBLE:
      mask = MAX(QGEMM_UNROLL_M, QGEMM_UNROLL_N);
      break;
#endif
    }
  } else {
    switch (mode & BLAS_PREC) {
    case BLAS_SINGLE:
      mask = MAX(CGEMM_UNROLL_M, CGEMM_UNROLL_N);
      break;
    case BLAS_DOUBLE:
      mask = MAX(ZGEMM_UNROLL_M, ZGEMM_UNROLL_N);
      break;
#ifdef EXPRECISION
    case BLAS_XDOUBLE:
      mask = MAX(XGEMM_UNROLL_M, XGEMM_UNROLL_N);
      break;
#endif
    }
  }
  
  range[0] = 0;
  num_cpu  = 0;
  i        = 0;

  while (i < n){
    
    if (blas_cpu_number - num_cpu > 1) {
      
      if (!(mode & BLAS_UPLO)) {
	double di   = (double)i;
	
	width = (BLASLONG)(sqrt(di * di + dnum) - di);
	
	if (num_cpu == 0) {
	  width = ((width +  mask - 1) & ~(mask - 1));
	} else {
	  width = (width & ~(mask - 1));
	}
	
      } else {
	double di   = (double)(n - i);
	double dx   = di * di - dnum;
	
	if (dx > 0) {
	  width = (BLASLONG)(di - sqrt(dx));
	  if (num_cpu == 0) {
	    width = ((width + mask - 1) & ~(mask - 1));
	  } else {
	    width = (width & ~(mask - 1));
	  }
	} else {
	  width = n - i;
	}
      }
      
      if ((width > n - i) || (width < mask)) width = n - i;
	
    } else {
      width = n - i;
    }
      
    range[num_cpu + 1] = range[num_cpu] + width;
    
    queue[num_cpu].mode    = mode;
    queue[num_cpu].routine = function;
    queue[num_cpu].args    = arg;
    queue[num_cpu].range_m = range_m;
    queue[num_cpu].range_n = &range[num_cpu];
    queue[num_cpu].sa      = NULL;
    queue[num_cpu].sb      = NULL;
    queue[num_cpu].next    = &queue[num_cpu + 1];
    
    num_cpu ++;
    i += width;
  }

  if (num_cpu) {
    queue[0].sa = sa;
    queue[0].sb = sb;
    queue[num_cpu - 1].next = NULL;
    
    exec_blas(num_cpu, queue);
  }

  return 0;
}
