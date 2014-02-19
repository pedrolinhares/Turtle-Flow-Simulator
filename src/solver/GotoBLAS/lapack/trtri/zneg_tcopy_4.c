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

void CNAME(BLASLONG m, BLASLONG n, FLOAT *a, BLASLONG lda, FLOAT *b){

  BLASLONG i, j;

  FLOAT *aoffset;
  FLOAT *aoffset1, *aoffset2, *aoffset3, *aoffset4;
  FLOAT *boffset,  *boffset1, *boffset2, *boffset3;

  FLOAT ctemp01, ctemp02, ctemp03, ctemp04;
  FLOAT ctemp05, ctemp06, ctemp07, ctemp08;
  FLOAT ctemp09, ctemp10, ctemp11, ctemp12;
  FLOAT ctemp13, ctemp14, ctemp15, ctemp16;
  FLOAT ctemp17, ctemp18, ctemp19, ctemp20;
  FLOAT ctemp21, ctemp22, ctemp23, ctemp24;
  FLOAT ctemp25, ctemp26, ctemp27, ctemp28;
  FLOAT ctemp29, ctemp30, ctemp31, ctemp32;

  aoffset   = a;
  boffset   = b;
  lda *= 2;

  boffset2  = b + 2 * m  * (n & ~3);
  boffset3  = b + 2 * m  * (n & ~1);

#if 0
  fprintf(stderr, "m = %d n = %d\n", m,n );
#endif

  j = (m >> 2);
  if (j > 0){
    do{
      aoffset1  = aoffset;
      aoffset2  = aoffset1 + lda;
      aoffset3  = aoffset2 + lda;
      aoffset4  = aoffset3 + lda;
      aoffset += 4 * lda;

      boffset1  = boffset;
      boffset  += 32;

      i = (n >> 2);
      if (i > 0){
	do{
	  ctemp01 = *(aoffset1 +  0);
	  ctemp02 = *(aoffset1 +  1);
	  ctemp03 = *(aoffset1 +  2);
	  ctemp04 = *(aoffset1 +  3);
	  ctemp05 = *(aoffset1 +  4);
	  ctemp06 = *(aoffset1 +  5);
	  ctemp07 = *(aoffset1 +  6);
	  ctemp08 = *(aoffset1 +  7);
	  
	  ctemp09 = *(aoffset2 +  0);
	  ctemp10 = *(aoffset2 +  1);
	  ctemp11 = *(aoffset2 +  2);
	  ctemp12 = *(aoffset2 +  3);
	  ctemp13 = *(aoffset2 +  4);
	  ctemp14 = *(aoffset2 +  5);
	  ctemp15 = *(aoffset2 +  6);
	  ctemp16 = *(aoffset2 +  7);
	  
	  ctemp17 = *(aoffset3 +  0);
	  ctemp18 = *(aoffset3 +  1);
	  ctemp19 = *(aoffset3 +  2);
	  ctemp20 = *(aoffset3 +  3);
	  ctemp21 = *(aoffset3 +  4);
	  ctemp22 = *(aoffset3 +  5);
	  ctemp23 = *(aoffset3 +  6);
	  ctemp24 = *(aoffset3 +  7);
	  
	  ctemp25 = *(aoffset4 +  0);
	  ctemp26 = *(aoffset4 +  1);
	  ctemp27 = *(aoffset4 +  2);
	  ctemp28 = *(aoffset4 +  3);
	  ctemp29 = *(aoffset4 +  4);
	  ctemp30 = *(aoffset4 +  5);
	  ctemp31 = *(aoffset4 +  6);
	  ctemp32 = *(aoffset4 +  7);

	  *(boffset1 +  0) = -ctemp01;
	  *(boffset1 +  1) = -ctemp02;
	  *(boffset1 +  2) = -ctemp03;
	  *(boffset1 +  3) = -ctemp04;
	  *(boffset1 +  4) = -ctemp05;
	  *(boffset1 +  5) = -ctemp06;
	  *(boffset1 +  6) = -ctemp07;
	  *(boffset1 +  7) = -ctemp08;
	  
	  *(boffset1 +  8) = -ctemp09;
	  *(boffset1 +  9) = -ctemp10;
	  *(boffset1 + 10) = -ctemp11;
	  *(boffset1 + 11) = -ctemp12;
	  *(boffset1 + 12) = -ctemp13;
	  *(boffset1 + 13) = -ctemp14;
	  *(boffset1 + 14) = -ctemp15;
	  *(boffset1 + 15) = -ctemp16;

	  *(boffset1 + 16) = -ctemp17;
	  *(boffset1 + 17) = -ctemp18;
	  *(boffset1 + 18) = -ctemp19;
	  *(boffset1 + 19) = -ctemp20;
	  *(boffset1 + 20) = -ctemp21;
	  *(boffset1 + 21) = -ctemp22;
	  *(boffset1 + 22) = -ctemp23;
	  *(boffset1 + 23) = -ctemp24;
	  
	  *(boffset1 + 24) = -ctemp25;
	  *(boffset1 + 25) = -ctemp26;
	  *(boffset1 + 26) = -ctemp27;
	  *(boffset1 + 27) = -ctemp28;
	  *(boffset1 + 28) = -ctemp29;
	  *(boffset1 + 29) = -ctemp30;
	  *(boffset1 + 30) = -ctemp31;
	  *(boffset1 + 31) = -ctemp32;

	  aoffset1 += 8;
	  aoffset2 += 8;
	  aoffset3 += 8;
	  aoffset4 += 8;

	  boffset1 += m * 8;
	  i --;
	}while(i > 0);
      }

      if (n & 2){
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);
	ctemp03 = *(aoffset1 +  2);
	ctemp04 = *(aoffset1 +  3);

	ctemp05 = *(aoffset2 +  0);
	ctemp06 = *(aoffset2 +  1);
	ctemp07 = *(aoffset2 +  2);
	ctemp08 = *(aoffset2 +  3);
	  
	ctemp09 = *(aoffset3 +  0);
	ctemp10 = *(aoffset3 +  1);
	ctemp11 = *(aoffset3 +  2);
	ctemp12 = *(aoffset3 +  3);
	
	ctemp13 = *(aoffset4 +  0);
	ctemp14 = *(aoffset4 +  1);
	ctemp15 = *(aoffset4 +  2);
	ctemp16 = *(aoffset4 +  3);
	
	*(boffset2 +  0) = -ctemp01;
	*(boffset2 +  1) = -ctemp02;
	*(boffset2 +  2) = -ctemp03;
	*(boffset2 +  3) = -ctemp04;
	*(boffset2 +  4) = -ctemp05;
	*(boffset2 +  5) = -ctemp06;
	*(boffset2 +  6) = -ctemp07;
	*(boffset2 +  7) = -ctemp08;
	
	*(boffset2 +  8) = -ctemp09;
	*(boffset2 +  9) = -ctemp10;
	*(boffset2 + 10) = -ctemp11;
	*(boffset2 + 11) = -ctemp12;
	*(boffset2 + 12) = -ctemp13;
	*(boffset2 + 13) = -ctemp14;
	*(boffset2 + 14) = -ctemp15;
	*(boffset2 + 15) = -ctemp16;
	
	aoffset1 += 4;
	aoffset2 += 4;
	aoffset3 += 4;
	aoffset4 += 4;
	
	boffset2 += 16;
      }

      if (n & 1){
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);

	ctemp03 = *(aoffset2 +  0);
	ctemp04 = *(aoffset2 +  1);
	  
	ctemp05 = *(aoffset3 +  0);
	ctemp06 = *(aoffset3 +  1);
	
	ctemp07 = *(aoffset4 +  0);
	ctemp08 = *(aoffset4 +  1);
	
	*(boffset3 +  0) = -ctemp01;
	*(boffset3 +  1) = -ctemp02;
	*(boffset3 +  2) = -ctemp03;
	*(boffset3 +  3) = -ctemp04;
	*(boffset3 +  4) = -ctemp05;
	*(boffset3 +  5) = -ctemp06;
	*(boffset3 +  6) = -ctemp07;
	*(boffset3 +  7) = -ctemp08;
	
	aoffset1 += 2;
	aoffset2 += 2;
	aoffset3 += 2;
	aoffset4 += 2;
	
	boffset3 += 8;
      }
      j--;
    }while(j > 0);
  }

  if (m & 2){
    aoffset1  = aoffset;
    aoffset2  = aoffset1 + lda;
    aoffset += 2 * lda;
    
    boffset1  = boffset;
    boffset  += 16;
    
    i = (n >> 2);
    if (i > 0){
      do{
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);
	ctemp03 = *(aoffset1 +  2);
	ctemp04 = *(aoffset1 +  3);
	ctemp05 = *(aoffset1 +  4);
	ctemp06 = *(aoffset1 +  5);
	ctemp07 = *(aoffset1 +  6);
	ctemp08 = *(aoffset1 +  7);
	
	ctemp09 = *(aoffset2 +  0);
	ctemp10 = *(aoffset2 +  1);
	ctemp11 = *(aoffset2 +  2);
	ctemp12 = *(aoffset2 +  3);
	ctemp13 = *(aoffset2 +  4);
	ctemp14 = *(aoffset2 +  5);
	ctemp15 = *(aoffset2 +  6);
	ctemp16 = *(aoffset2 +  7);
	
	*(boffset1 +  0) = -ctemp01;
	*(boffset1 +  1) = -ctemp02;
	*(boffset1 +  2) = -ctemp03;
	*(boffset1 +  3) = -ctemp04;
	*(boffset1 +  4) = -ctemp05;
	*(boffset1 +  5) = -ctemp06;
	*(boffset1 +  6) = -ctemp07;
	*(boffset1 +  7) = -ctemp08;
	
	*(boffset1 +  8) = -ctemp09;
	*(boffset1 +  9) = -ctemp10;
	*(boffset1 + 10) = -ctemp11;
	*(boffset1 + 11) = -ctemp12;
	*(boffset1 + 12) = -ctemp13;
	*(boffset1 + 13) = -ctemp14;
	*(boffset1 + 14) = -ctemp15;
	*(boffset1 + 15) = -ctemp16;
	
	aoffset1 += 8;
	aoffset2 += 8;
	aoffset3 += 8;
	aoffset4 += 8;
	
	boffset1 += m * 8;
	i --;
      }while(i > 0);
    }

    if (n & 2){
      ctemp01 = *(aoffset1 +  0);
      ctemp02 = *(aoffset1 +  1);
      ctemp03 = *(aoffset1 +  2);
      ctemp04 = *(aoffset1 +  3);
      
      ctemp05 = *(aoffset2 +  0);
      ctemp06 = *(aoffset2 +  1);
      ctemp07 = *(aoffset2 +  2);
      ctemp08 = *(aoffset2 +  3);
      
      *(boffset2 +  0) = -ctemp01;
      *(boffset2 +  1) = -ctemp02;
      *(boffset2 +  2) = -ctemp03;
      *(boffset2 +  3) = -ctemp04;
      *(boffset2 +  4) = -ctemp05;
      *(boffset2 +  5) = -ctemp06;
      *(boffset2 +  6) = -ctemp07;
      *(boffset2 +  7) = -ctemp08;
      
      aoffset1 += 4;
      aoffset2 += 4;
      
      boffset2 += 8;
    }
    
    if (n & 1){
      ctemp01 = *(aoffset1 +  0);
      ctemp02 = *(aoffset1 +  1);
      ctemp03 = *(aoffset2 +  0);
      ctemp04 = *(aoffset2 +  1);
      
      *(boffset3 +  0) = -ctemp01;
      *(boffset3 +  1) = -ctemp02;
      *(boffset3 +  2) = -ctemp03;
      *(boffset3 +  3) = -ctemp04;
      
      aoffset1 += 2;
      aoffset2 += 2;
      boffset3 += 4;
    }
  }
  
  if (m & 1){
    aoffset1  = aoffset;
    boffset1  = boffset;
    
    i = (n >> 2);
    if (i > 0){
      do{
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);
	ctemp03 = *(aoffset1 +  2);
	ctemp04 = *(aoffset1 +  3);
	ctemp05 = *(aoffset1 +  4);
	ctemp06 = *(aoffset1 +  5);
	ctemp07 = *(aoffset1 +  6);
	ctemp08 = *(aoffset1 +  7);
	
	*(boffset1 +  0) = -ctemp01;
	*(boffset1 +  1) = -ctemp02;
	*(boffset1 +  2) = -ctemp03;
	*(boffset1 +  3) = -ctemp04;
	*(boffset1 +  4) = -ctemp05;
	*(boffset1 +  5) = -ctemp06;
	*(boffset1 +  6) = -ctemp07;
	*(boffset1 +  7) = -ctemp08;
	
	aoffset1 += 8;
	boffset1 += m * 8;
	i --;
      }while(i > 0);
    }

    if (n & 2){
      ctemp01 = *(aoffset1 +  0);
      ctemp02 = *(aoffset1 +  1);
      ctemp03 = *(aoffset1 +  2);
      ctemp04 = *(aoffset1 +  3);
      
      *(boffset2 +  0) = -ctemp01;
      *(boffset2 +  1) = -ctemp02;
      *(boffset2 +  2) = -ctemp03;
      *(boffset2 +  3) = -ctemp04;

      aoffset1 += 4;
      boffset2 += 4;
    }
    
    if (n & 1){
      ctemp01 = *(aoffset1 +  0);
      ctemp02 = *(aoffset1 +  1);
      
      *(boffset3 +  0) = -ctemp01;
      *(boffset3 +  1) = -ctemp02;
    }
  }
}
