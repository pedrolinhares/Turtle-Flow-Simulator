#include <math.h>
#include "common.h"

int NAME(FLOAT *DA, FLOAT *DB, FLOAT *C, FLOAT *S){

#if defined(__i386__) || defined(__x86_64__) || defined(__ia64__)

  xdouble da = *DA;
  xdouble db = *DB;
  xdouble c;
  xdouble s;
  xdouble r, roe, z;

  xdouble ada = fabs(da);
  xdouble adb = fabs(db);
  xdouble scale = ada + adb;

  roe = db;
  if (ada > adb) roe = da;

  if (scale == ZERO) {
    *C = ONE;
    *S = ZERO;
    *DA = ZERO;
    *DB = ZERO;
  } else {
    r = sqrt(da * da + db * db);
    if (roe < 0) r = -r;
    c = da / r;
    s = db / r;
    z = ONE;
    if (da != ZERO) {
      if (ada > adb){
	z = s;
      } else {
	z = ONE / c;
      }
    }

    *C = c;
    *S = s;
    *DA = r;
    *DB = z;
  }

#else
  FLOAT da = *DA;
  FLOAT db = *DB;
  FLOAT c  = *C;
  FLOAT s  = *S;
  FLOAT r, roe, z;

  FLOAT ada = fabs(da);
  FLOAT adb = fabs(db);
  FLOAT scale = ada + adb;

  roe = db;
  if (ada > adb) roe = da;

  if (scale == ZERO) {
    *C = ONE;
    *S = ZERO;
    *DA = ZERO;
    *DB = ZERO;
  } else {
    FLOAT aa = da / scale;
    FLOAT bb = db / scale;

    r = scale * sqrt(aa * aa + bb * bb);
    if (roe < 0) r = -r;
    c = da / r;
    s = db / r;
    z = ONE;
    if (ada > adb) z = s;
    if ((ada < adb) && (c != ZERO)) z = ONE / c;

    *C = c;
    *S = s;
    *DA = r;
    *DB = z;
  }
#endif

  return 0;
}
