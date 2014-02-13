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
#define NEEDPARAM
#ifndef COMPLEX
#ifndef TRANS
#include "gemv_n.S"
#else
#include "gemv_t.S"
#endif
#else
#ifndef TRANS
#include "zgemv_n.S"
#else
#include "zgemv_t.S"
#endif
#endif

unsigned int dcbt(int rega, int regb, int num){

  return (0x7c00022c | (rega << 16) | (regb << 11) | ((num) << 21));
}

unsigned int dcbtst(int rega, int regb, int num){

  return (0x7c0001ec | (rega << 16) | (regb << 11) | ((num) << 21));
}

int main(void){

  printf("#define PREFETCH_A1 .long 0x%x\n", dcbt(PREA, AO1, DCBT_ARG));
  printf("#define PREFETCH_A2 .long 0x%x\n", dcbt(PREA, AO2, DCBT_ARG));
  printf("#define PREFETCH_A3 .long 0x%x\n", dcbt(PREA, AO3, DCBT_ARG));
  printf("#define PREFETCH_A4 .long 0x%x\n", dcbt(PREA, AO4, DCBT_ARG));
#ifndef COMPLEX
  printf("#define PREFETCH_A5 .long 0x%x\n", dcbt(PREA, AO5, DCBT_ARG));
  printf("#define PREFETCH_A6 .long 0x%x\n", dcbt(PREA, AO6, DCBT_ARG));
  printf("#define PREFETCH_A7 .long 0x%x\n", dcbt(PREA, AO7, DCBT_ARG));
  printf("#define PREFETCH_A8 .long 0x%x\n", dcbt(PREA, AO8, DCBT_ARG));
#endif
  printf("#define PREFETCH_Y  .long 0x%x\n", dcbtst(PREC, Y1,  DCBT_ARG));

  return 0;
}
