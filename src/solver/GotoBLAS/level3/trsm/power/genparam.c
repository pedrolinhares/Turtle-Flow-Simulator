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
#include "trsm_kernel_LT.S"
#else
#include "ztrsm_kernel_LT.S"
#endif

unsigned int dcbt(int rega, int regb, int num){

  return (0x7c00022c | (rega << 16) | (regb << 11) | ((num) << 21));
}

unsigned int dcbtst(int rega, int regb, int num){

  return (0x7c0001ec | (rega << 16) | (regb << 11) | ((num) << 21));
}

int main(void){

  printf("#define PREFETCH_A .long 0x%x\n", dcbt(PREA, AO, DCBT_ARG));
  printf("#define PREFETCH_B .long 0x%x\n", dcbt(PREB, BO, DCBT_ARG));

  printf("#define PREFETCH_C1 .long 0x%x\n", dcbtst(PREC, CO1, DCBT_ARG));
  printf("#define PREFETCH_C2 .long 0x%x\n", dcbtst(PREC, CO2, DCBT_ARG));
#ifndef COMPLEX
  printf("#define PREFETCH_C3 .long 0x%x\n", dcbtst(PREC, CO3, DCBT_ARG));
  printf("#define PREFETCH_C4 .long 0x%x\n", dcbtst(PREC, CO4, DCBT_ARG));
#endif
  return 0;
}
