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

int beta_thread(blas_arg_t *, int (*fuction)()) {

  blas_arg_t   arg;
  blas_queue_t queue[MAX_CPU_NUMBER];
  BLASLONG cstride;
  BLASLONG width, i, num_cpu, calc_type;

  calc_type = (mode & BLAS_PREC) + ((mode & BLAS_COMPLEX) != 0) + 2;

  for (i = 0; i < blas_cpu_number; i++) blas_queue_init(&queue[i]);

  num_cpu = 0;
  i = n;

  while (i > 0){

/* Adjust Parameters */
    width  = blas_quickdivide(i + blas_cpu_number - num_cpu - 1,
			      blas_cpu_number - num_cpu);

    i -= width;
    if (i < 0) width = width + i;
    
    cstride = width * ldc;

    cstride <<= calc_type;

    queue[num_cpu].mode = mode;
    queue[num_cpu].routine = function;
    queue[num_cpu].m = m;
    queue[num_cpu].n = width;
    queue[num_cpu].c = (void *)c;
    queue[num_cpu].ldc = ldc;
    queue[num_cpu].alpha[0] = alpha_r;
    queue[num_cpu].alpha[1] = alpha_i;
    queue[num_cpu].next     = NULL;
    queue[num_cpu].next  = &queue[num_cpu + 1];
    
    c = (void *)((BLASULONG)c + cstride);

    num_cpu ++;
  }

  if (num_cpu) {
    queue[num_cpu - 1].next = NULL;
    queue[num_cpu - 1].last = 1;
   
    exec_blas(queue, NULL);
  }

  return 0;
}
