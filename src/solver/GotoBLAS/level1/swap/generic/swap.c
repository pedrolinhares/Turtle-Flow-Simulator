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


int NAME(int n, int dummy1, int dummy2, FLOAT dummy3, 
	 FLOAT *x, int incx, FLOAT *y, int incy, FLOAT *dummy4, int dummy5){

  int i;
  FLOAT temp1, temp2, temp3, temp4;
  FLOAT temp5, temp6, temp7, temp8;
  
  if (incx == 1 && incy == 1) {

    i = (n >> 2);
    if (i > 0) {
      do {
	temp1 = *(x + 0);
	temp2 = *(x + 1);
	temp3 = *(x + 2);
	temp4 = *(x + 3);
	
	temp5 = *(y + 0);
	temp6 = *(y + 1);
	temp7 = *(y + 2);
	temp8 = *(y + 3);
	
	*(x + 0) = temp5;
	*(x + 1) = temp6;
	*(x + 2) = temp7;
	*(x + 3) = temp8;
	
	*(y + 0) = temp1;
	*(y + 1) = temp2;
	*(y + 2) = temp3;
	*(y + 3) = temp4;

	x += 4;
	y += 4;
	i --;
      } while (i > 0);
    }

    i = (n & 3);
    if (i > 0) {
      do {
	temp1 = *(x + 0);
	temp5 = *(y + 0);
	*(x + 0) = temp5;
	*(y + 0) = temp1;
	x ++;
	y ++;
	i --;
      } while (i > 0);
    }
  } else {

    i = (n >> 2);
    if (i > 0) {
      do {
	temp1 = *(x + 0);
	x += incx;
	temp2 = *(x + 0);
	x += incx;
	temp3 = *(x + 0);
	x += incx;
	temp4 = *(x + 0);
	
	temp5 = *(y + 0);
	y += incy;
	temp6 = *(y + 0);
	y += incy;
	temp7 = *(y + 0);
	y += incy;
	temp8 = *(y + 0);

	*(x + 0) = temp8;
	x -= incx;
	*(x + 0) = temp7;
	x -= incx;
	*(x + 0) = temp6;
	x -= incx;
	*(x + 0) = temp5;
	x += 4 * incx;
	
	*(y + 0) = temp4;
	y -= incy;
	*(y + 0) = temp3;
	y -= incy;
	*(y + 0) = temp2;
	y -= incy;
	*(y + 0) = temp1;
	y += 4 * incy;

	i --;
      } while (i > 0);
    }

    i = (n & 3);
    if (i > 0) {
      do {
	temp1 = *(x + 0);
	temp5 = *(y + 0);
	*(x + 0) = temp5;
	*(y + 0) = temp1;
	x += incx;
	y += incy;
	i --;
      } while (i > 0);
    }



  }

  return 0;
}

