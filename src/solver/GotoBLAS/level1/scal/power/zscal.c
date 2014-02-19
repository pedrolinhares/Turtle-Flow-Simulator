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

double fabs(double);

int CNAME(BLASLONG n, BLASLONG dummy1, BLASLONG dummy2, FLOAT alpha_r, FLOAT alpha_i,
	 FLOAT* x, BLASLONG incx, FLOAT *dummy3, BLASLONG dummy4, FLOAT *dummy5, BLASLONG dummy6){

  BLASLONG i;
  FLOAT xr, xi, yr, yi;

  if (n <= 0) return 0;

  incx *= 2;

  if (fabs(alpha_r) + fabs(alpha_i) == ZERO){
    if (incx == 2){
      i = (n >> 2);
      if (i > 0){
	do {
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  *(x + 2) = 0.;
	  *(x + 3) = 0.;
	  *(x + 4) = 0.;
	  *(x + 5) = 0.;
	  *(x + 6) = 0.;
	  *(x + 7) = 0.;
	  x += 8;
	  i --;
	} while (i > 0);
      }

      i = (n & 3);
      if (i > 0){
	do {
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += 2;
	  i --;
	} while (i > 0);
      }
    } else {
      i = (n >> 2);
      if (i > 0){
	do {
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += incx;
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += incx;
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += incx;
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += incx;
	  i --;
	} while (i > 0);
      }

      i = (n & 3);
      if (i > 0){
	do {
	  *(x + 0) = 0.;
	  *(x + 1) = 0.;
	  x += incx;
	  i --;
	} while (i > 0);
      }
    }
  } else {
    i = n;
    do {
      
      yr = *(x + 0);
      yr *= alpha_i;
      
      yi = *(x + 1);
      yi *= alpha_r;
      
      yr += yi;
      
      xr = *(x + 0);
      xr *= alpha_r;
      
      xi = *(x + 1);
      xi *= alpha_i;
      
      xr -= xi;
      
      *(x + 0) = xr;
      *(x + 1) = yr;
      
      x += incx;
      i --;
    } while (i > 0);
  }
  return 0;
}


