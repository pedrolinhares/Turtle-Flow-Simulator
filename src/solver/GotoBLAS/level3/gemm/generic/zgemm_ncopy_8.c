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
  FLOAT *aoffset5, *aoffset6, *aoffset7, *aoffset8;

  FLOAT *boffset;
  FLOAT ctemp01, ctemp02, ctemp03, ctemp04;
  FLOAT ctemp05, ctemp06, ctemp07, ctemp08;
  FLOAT ctemp09, ctemp10, ctemp11, ctemp12;
  FLOAT ctemp13, ctemp14, ctemp15, ctemp16;

  aoffset = a;
  boffset = b;
  lda *= 2;
  
  j = (n >> 3);
  if (j > 0){
    do{
      aoffset1  = aoffset;
      aoffset2  = aoffset1 + lda;
      aoffset3  = aoffset2 + lda;
      aoffset4  = aoffset3 + lda;
      aoffset5  = aoffset4 + lda;
      aoffset6  = aoffset5 + lda;
      aoffset7  = aoffset6 + lda;
      aoffset8  = aoffset7 + lda;
      aoffset += 8 * lda;
      
      i = m;
      if (i > 0){
	do{
	  ctemp01 = *(aoffset1 +  0);
	  ctemp02 = *(aoffset1 +  1);
	  ctemp03 = *(aoffset2 +  0);
	  ctemp04 = *(aoffset2 +  1);
	  ctemp05 = *(aoffset3 +  0);
	  ctemp06 = *(aoffset3 +  1);
	  ctemp07 = *(aoffset4 +  0);
	  ctemp08 = *(aoffset4 +  1);
	  ctemp09 = *(aoffset5 +  0);
	  ctemp10 = *(aoffset5 +  1);
	  ctemp11 = *(aoffset6 +  0);
	  ctemp12 = *(aoffset6 +  1);
	  ctemp13 = *(aoffset7 +  0);
	  ctemp14 = *(aoffset7 +  1);
	  ctemp15 = *(aoffset8 +  0);
	  ctemp16 = *(aoffset8 +  1);
	  
	  *(boffset +  0) = ctemp01;
	  *(boffset +  1) = ctemp02;
	  *(boffset +  2) = ctemp03;
	  *(boffset +  3) = ctemp04;
	  *(boffset +  4) = ctemp05;
	  *(boffset +  5) = ctemp06;
	  *(boffset +  6) = ctemp07;
	  *(boffset +  7) = ctemp08;
	  *(boffset +  8) = ctemp09;
	  *(boffset +  9) = ctemp10;
	  *(boffset + 10) = ctemp11;
	  *(boffset + 11) = ctemp12;
	  *(boffset + 12) = ctemp13;
	  *(boffset + 13) = ctemp14;
	  *(boffset + 14) = ctemp15;
	  *(boffset + 15) = ctemp16;

	  aoffset1 += 2;
	  aoffset2 += 2;
	  aoffset3 += 2;
	  aoffset4 += 2;
	  aoffset5 += 2;
	  aoffset6 += 2;
	  aoffset7 += 2;
	  aoffset8 += 2;
	  
	  boffset += 16;
	  i --;
	}while(i > 0);
      }
      j--;
    }while(j > 0);
  } /* end of if(j > 0) */
  
  if (n & 4){
    aoffset1  = aoffset;
    aoffset2  = aoffset1 + lda;
    aoffset3  = aoffset2 + lda;
    aoffset4  = aoffset3 + lda;
    aoffset += 4 * lda;
    
    i = m;
    if (i > 0){
      do{
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);
	ctemp03 = *(aoffset2 +  0);
	ctemp04 = *(aoffset2 +  1);
	ctemp05 = *(aoffset3 +  0);
	ctemp06 = *(aoffset3 +  1);
	ctemp07 = *(aoffset4 +  0);
	ctemp08 = *(aoffset4 +  1);
	
	*(boffset +  0) = ctemp01;
	*(boffset +  1) = ctemp02;
	*(boffset +  2) = ctemp03;
	*(boffset +  3) = ctemp04;
	*(boffset +  4) = ctemp05;
	*(boffset +  5) = ctemp06;
	*(boffset +  6) = ctemp07;
	*(boffset +  7) = ctemp08;

	aoffset1 += 2;
	aoffset2 += 2;
	aoffset3 += 2;
	aoffset4 += 2;

	boffset += 8;
	i --;
      }while(i > 0);
    }
  } /* end of if(j > 0) */

  if (n & 2){
    aoffset1  = aoffset;
    aoffset2  = aoffset1 + lda;
    aoffset += 2 * lda;
    
    i = m;
    if (i > 0){
      do{
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);
	ctemp03 = *(aoffset2 +  0);
	ctemp04 = *(aoffset2 +  1);
	
	*(boffset +  0) = ctemp01;
	*(boffset +  1) = ctemp02;
	*(boffset +  2) = ctemp03;
	*(boffset +  3) = ctemp04;
	
	aoffset1 +=  2;
	aoffset2 +=  2;
	boffset  +=  4;
	i --;
      }while(i > 0);
    }
   
  } /* end of if(j > 0) */

  if (n & 1){
    aoffset1  = aoffset;
    
    i = m;
    if (i > 0){
      do{
	ctemp01 = *(aoffset1 +  0);
	ctemp02 = *(aoffset1 +  1);

	*(boffset +  0) = ctemp01;
	*(boffset +  1) = ctemp02;

	aoffset1 += 2;
	boffset  += 2;
	i --;
      }while(i > 0);
    }
    
  } /* end of if(j > 0) */

}