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

#if defined(__alpha) && defined(__DECC)
#include <c_asm.h>
#endif

int implver(void){
  int arch;

#ifndef __DECC
  asm __volatile__("implver %0" : "=r"(arch)  : : "memory");
#else
  arch = asm("implver %v0");
#endif
  return arch;
}
  
void get_architecture(void){
  printf("ALPHA");
}

void get_subarchitecture(void){
  printf("ev%d", implver() + 4);
}

void get_subdirname(void){
  printf("alpha");
}

void get_cpuconfig(void){
  printf("-DARCH_ALPHA -DEV%d ", implver() + 4);

  switch (implver()){
  case 0: 
    printf("-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=32 "
	   "-DL2_SIZE=2097152 -DL2_LINESIZE=32 "
	   "-DDTB_ENTRIES=32 -DDTB_SIZE=8192 ");
    break;

  case 1: 
    printf("-DL1_DATA_SIZE=16384 -DL1_DATA_LINESIZE=32 "
	   "-DL2_SIZE=2097152 -DL2_LINESIZE=64 "
	   "-DDTB_ENTRIES=64 -DDTB_SIZE=8192 ");
    break;

  case 2: 
    printf("-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=64 "
	   "-DL2_SIZE=4194304 -DL2_LINESIZE=64 "
	   "-DDTB_ENTRIES=128 -DDTB_SIZE=8192 ");
    break;
  }
}

void get_libname(void){
  printf("ev%d\n", implver() + 4);
}
