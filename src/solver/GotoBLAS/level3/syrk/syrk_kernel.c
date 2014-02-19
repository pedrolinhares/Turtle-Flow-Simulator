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

#ifndef CONJA
#ifndef CONJB
#define GEMM_KERNEL	GEMM_KERNEL_N
#else
#define GEMM_KERNEL	GEMM_KERNEL_R
#endif
#else
#ifndef CONJB
#define GEMM_KERNEL	GEMM_KERNEL_L
#else
#define GEMM_KERNEL	GEMM_KERNEL_B
#endif
#endif

void CNAME(BLASLONG m, BLASLONG n, BLASLONG k, FLOAT alpha_r,
#ifdef COMPLEX
	   FLOAT alpha_i,
#endif
	   FLOAT *a, FLOAT *b, FLOAT *c, BLASLONG ldc, BLASLONG offset){

  BLASLONG i, j;
  BLASLONG loop;
  FLOAT *cc, *ss;
  FLOAT subbuffer[MAXMN * MAXMN * COMPSIZE];

  if (m + offset < 0) {
#ifndef LOWER
    GEMM_KERNEL(m, n, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a, b, c, ldc); 
#endif
    return;
  }

  if (n < offset) {
#ifdef LOWER
    GEMM_KERNEL(m, n, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a, b, c, ldc); 
#endif
    return;
  }


  if (offset > 0) {
#ifdef LOWER
    GEMM_KERNEL(m, offset, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a, b, c, ldc); 
#endif
    b += offset * k   * COMPSIZE;
    c += offset * ldc * COMPSIZE;
    n -= offset;
    offset = 0;

    if (n <= 0) return;
  }

  if (n > m + offset) {
#ifndef LOWER
      GEMM_KERNEL(m, n - m - offset, k,
		  alpha_r,
#ifdef COMPLEX
		  alpha_i,
#endif
		  a,
		  b + (m + offset) * k   * COMPSIZE,
		  c + (m + offset) * ldc * COMPSIZE, ldc); 
#endif

    n = m + offset;
    if (n <= 0) return;
  }


  if (offset < 0) {
#ifndef LOWER
    GEMM_KERNEL(-offset, n, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a, b, c, ldc); 
#endif
    a -= offset * k   * COMPSIZE;
    c -= offset       * COMPSIZE;
    m += offset;
    offset = 0;

  if (m <= 0) return;
  }

  if (m > n - offset) {
#ifdef LOWER
    GEMM_KERNEL(m - n + offset, n, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a + (n - offset) * k * COMPSIZE,
		b,
		c + (n - offset)     * COMPSIZE, ldc); 
#endif
    m = n + offset;
  if (m <= 0) return;
  }

  for (loop = 0; loop < n; loop += MAXMN) {

    int mm, nn;

    mm = (loop & ~(MAXMN - 1));
    nn = MIN(MAXMN, n - loop);

#ifndef LOWER
    GEMM_KERNEL(mm, nn, k,
		  alpha_r,
#ifdef COMPLEX
		  alpha_i,
#endif
		  a, b + loop * k * COMPSIZE, c + loop * ldc * COMPSIZE, ldc); 
#endif

#if MAXMN * MAXMN * COMPSIZE > 64
    GEMM_BETA(nn, nn, 0, ZERO, 
#ifdef COMPLEX
	      ZERO,
#endif
	      NULL, 0, NULL, 0, subbuffer, nn);
#else
    subbuffer[ 0] = ZERO;
#if MAXMN * MAXMN * COMPSIZE >= 2
    subbuffer[ 1] = ZERO;
#endif
#if MAXMN * MAXMN * COMPSIZE >= 4
    subbuffer[ 2] = ZERO;
    subbuffer[ 3] = ZERO;
#endif
#if MAXMN * MAXMN * COMPSIZE >= 8
    subbuffer[ 4] = ZERO;
    subbuffer[ 5] = ZERO;
    subbuffer[ 6] = ZERO;
    subbuffer[ 7] = ZERO;
#endif
#if MAXMN * MAXMN * COMPSIZE >= 16
    subbuffer[ 8] = ZERO;
    subbuffer[ 9] = ZERO;
    subbuffer[10] = ZERO;
    subbuffer[11] = ZERO;
    subbuffer[12] = ZERO;
    subbuffer[13] = ZERO;
    subbuffer[14] = ZERO;
    subbuffer[15] = ZERO;
#endif
#if MAXMN * MAXMN * COMPSIZE >= 32
    subbuffer[16] = ZERO;
    subbuffer[17] = ZERO;
    subbuffer[18] = ZERO;
    subbuffer[19] = ZERO;
    subbuffer[20] = ZERO;
    subbuffer[21] = ZERO;
    subbuffer[22] = ZERO;
    subbuffer[23] = ZERO;
    subbuffer[24] = ZERO;
    subbuffer[25] = ZERO;
    subbuffer[26] = ZERO;
    subbuffer[27] = ZERO;
    subbuffer[28] = ZERO;
    subbuffer[29] = ZERO;
    subbuffer[30] = ZERO;
    subbuffer[31] = ZERO;
#endif
#if MAXMN * MAXMN * COMPSIZE >= 64
    subbuffer[32] = ZERO;
    subbuffer[33] = ZERO;
    subbuffer[34] = ZERO;
    subbuffer[35] = ZERO;
    subbuffer[36] = ZERO;
    subbuffer[37] = ZERO;
    subbuffer[38] = ZERO;
    subbuffer[39] = ZERO;
    subbuffer[40] = ZERO;
    subbuffer[41] = ZERO;
    subbuffer[42] = ZERO;
    subbuffer[43] = ZERO;
    subbuffer[44] = ZERO;
    subbuffer[45] = ZERO;
    subbuffer[46] = ZERO;
    subbuffer[47] = ZERO;
    subbuffer[48] = ZERO;
    subbuffer[49] = ZERO;
    subbuffer[50] = ZERO;
    subbuffer[51] = ZERO;
    subbuffer[52] = ZERO;
    subbuffer[53] = ZERO;
    subbuffer[54] = ZERO;
    subbuffer[55] = ZERO;
    subbuffer[56] = ZERO;
    subbuffer[57] = ZERO;
    subbuffer[58] = ZERO;
    subbuffer[59] = ZERO;
    subbuffer[60] = ZERO;
    subbuffer[61] = ZERO;
    subbuffer[62] = ZERO;
    subbuffer[63] = ZERO;
#endif
#endif
    
    GEMM_KERNEL(nn, nn, k,
		alpha_r,
#ifdef COMPLEX
		alpha_i,
#endif
		a + loop * k * COMPSIZE, b + loop * k * COMPSIZE, subbuffer, nn); 

    cc = c + (loop + loop * ldc) * COMPSIZE;
    ss = subbuffer;

#ifndef LOWER
 for (j = 0; j < nn; j ++) {
    for (i = 0; i <= j; i ++) {
#ifndef COMPLEX
      cc[i] += ss[i];
#else
      cc[i * 2 + 0] += ss[i * 2 + 0];
      cc[i * 2 + 1] += ss[i * 2 + 1];
#endif
    }
    ss += nn  * COMPSIZE;
    cc += ldc * COMPSIZE;
  }
#else
  for (j = 0; j < nn; j ++) {
    for (i = j; i < nn; i ++) {
#ifndef COMPLEX
      cc[i] += ss[i];
#else
      cc[i * 2 + 0] += ss[i * 2 + 0];
      cc[i * 2 + 1] += ss[i * 2 + 1];
#endif
    }
    ss += nn  * COMPSIZE;
    cc += ldc * COMPSIZE;
  }
#endif

#ifdef LOWER
    GEMM_KERNEL(m - mm - nn, nn, k,
		  alpha_r,
#ifdef COMPLEX
		  alpha_i,
#endif
		  a + (mm + nn) * k * COMPSIZE, b + loop * k * COMPSIZE, 
		  c + (mm + nn + loop * ldc) * COMPSIZE, ldc); 
#endif

  }

    return;
}
