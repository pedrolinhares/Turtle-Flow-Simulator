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
#include "common.h"

int ger_thread(int mode, BLASLONG m, BLASLONG n, void *alpha,
		void *a, BLASLONG lda,
		void *b, BLASLONG ldb, 
		void *c, BLASLONG ldc, int (*function)(), void *buffer){

  blas_queue_t queue[MAX_CPU_NUMBER];
  blas_arg_t   args [MAX_CPU_NUMBER];

  BLASLONG width, bstride, cstride, i;
  int num_cpu, calc_type;

  calc_type = ((mode & BLAS_DOUBLE) != 0) + ((mode & BLAS_COMPLEX) != 0) + 2;

  mode |= BLAS_LEGACY;

  for (i = 0; i < blas_cpu_number; i++) blas_queue_init(&queue[i]);

  num_cpu = 0;
  i = n;
  
  while (i > 0){
    
    /* Adjust Queueeters */
    width  = blas_quickdivide(i + blas_cpu_number - num_cpu - 1,
			      blas_cpu_number - num_cpu);
    i -= width;
    if (i < 0) width = width + i;
    
    bstride = width * ldb;
    cstride = width * ldc;

    bstride <<= calc_type;
    cstride <<= calc_type;

    args[num_cpu].m = m;
    args[num_cpu].n = width;
    args[num_cpu].a = (void *)a;
    args[num_cpu].b = (void *)b;
    args[num_cpu].c = (void *)c;
    args[num_cpu].lda = lda;
    args[num_cpu].ldb = ldb;
    args[num_cpu].ldc = ldc;
    args[num_cpu].alpha = alpha;

    queue[num_cpu].mode    = mode;
    queue[num_cpu].routine = function;
    queue[num_cpu].args    = &args[num_cpu];
    queue[num_cpu].next    = &queue[num_cpu + 1];

    b = (void *)((BLASULONG)b + bstride);
    c = (void *)((BLASULONG)c + cstride);

    num_cpu ++;
  }

  if (num_cpu) {
    queue[0].sb = buffer;

    queue[num_cpu - 1].next = NULL;

    exec_blas(num_cpu, queue);
  }

  return 0;
}
