#include <stdio.h>
#include "common.h"

int CNAME(BLASLONG n, FLOAT *x, BLASLONG incx, FLOAT *y, BLASLONG incy, FLOAT c, FLOAT s){

  BLASLONG i;
  FLOAT dx1, dx2, dx3, dx4, dx5, dx6, dx7, dx8;
  FLOAT dy1, dy2, dy3, dy4, dy5, dy6, dy7, dy8;

  if ((incx == 1) && (incy == 1)) {

    i = (n >> 3);
    if (i > 0) {
      do {
	dx1 = *(x + 0);
	dx2 = *(x + 1);
	dx3 = *(x + 2);
	dx4 = *(x + 3);
	dx5 = *(x + 4);
	dx6 = *(x + 5);
	dx7 = *(x + 6);
	dx8 = *(x + 7);

	dy1 = *(y + 0);
	dy2 = *(y + 1);
	dy3 = *(y + 2);
	dy4 = *(y + 3);
	dy5 = *(y + 4);
	dy6 = *(y + 5);
	dy7 = *(y + 6);
	dy8 = *(y + 7);

	*(x + 0) = c * dx1 + s * dy1;
	*(y + 0) = c * dy1 - s * dx1;
	*(x + 1) = c * dx2 + s * dy2;
	*(y + 1) = c * dy2 - s * dx2;
	*(x + 2) = c * dx3 + s * dy3;
	*(y + 2) = c * dy3 - s * dx3;
	*(x + 3) = c * dx4 + s * dy4;
	*(y + 3) = c * dy4 - s * dx4;
	*(x + 4) = c * dx5 + s * dy5;
	*(y + 4) = c * dy5 - s * dx5;
	*(x + 5) = c * dx6 + s * dy6;
	*(y + 5) = c * dy6 - s * dx6;
	*(x + 6) = c * dx7 + s * dy7;
	*(y + 6) = c * dy7 - s * dx7;
	*(x + 7) = c * dx8 + s * dy8;
	*(y + 7) = c * dy8 - s * dx8;
	
	x += 8;
	y += 8;
	i --;
      } while (i > 0);
    }

    i = (n & 7);
    if (i > 0) {
      do {
	dx1 = *(x + 0);
	dx2 = *(x + 1);

	dy1 = *(y + 0);
	dy2 = *(y + 1);

	*(x + 0) = c * dx1 + s * dy1;
	*(y + 0) = c * dy1 - s * dx1;
	x ++;
	y ++;

	i --;
      } while (i > 0);
    }

  } else {

  for (i = 0; i < n; i ++){
    dx1 = *x;
    dy1 = *y;

    *x = c * dx1 + s * dy1;
    *y = c * dy1 - s * dx1;

    x += incx;
    y += incy;
  }

  }

  return 0;
}

