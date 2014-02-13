#include <stdio.h>
#include "common.h"

int CNAME(BLASLONG n, FLOAT *x, BLASLONG incx, FLOAT *y, BLASLONG incy, FLOAT c, FLOAT s){

  BLASLONG i;
  FLOAT dx1, dx2, dy1, dy2;

  for (i = 0; i < n; i ++){
    dx1 = *(x + 0);
    dx2 = *(x + 1);
    dy1 = *(y + 0);
    dy2 = *(y + 1);

    *(x + 0) = c * dx1 + s * dy1;
    *(x + 1) = c * dx2 + s * dy2;
    *(y + 0) = c * dy1 - s * dx1;
    *(y + 1) = c * dy2 - s * dx2;

    x += incx * 2;
    y += incy * 2;
  }

  return 0;
}

