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

#ifndef COMMON_LEVEL3
#define COMMON_LEVEL3

#ifndef ASSEMBLER

#if defined(ARCH_X86) || defined(ARCH_X86_64) || defined(ARCH_IA64)
extern BLASLONG sgemm_p;
extern BLASLONG sgemm_q;
extern BLASLONG sgemm_r;
extern BLASLONG dgemm_p;
extern BLASLONG dgemm_q;
extern BLASLONG dgemm_r;
extern BLASLONG qgemm_p;
extern BLASLONG qgemm_q;
extern BLASLONG qgemm_r;
extern BLASLONG cgemm_p;
extern BLASLONG cgemm_q;
extern BLASLONG cgemm_r;
extern BLASLONG zgemm_p;
extern BLASLONG zgemm_q;
extern BLASLONG zgemm_r;
extern BLASLONG xgemm_p;
extern BLASLONG xgemm_q;
extern BLASLONG xgemm_r;
#endif

typedef struct {
  void *a, *b, *c, *alpha, *beta;
  BLASLONG	m, n, k, lda, ldb, ldc;

#ifdef SMP
  void *common;
  BLASLONG nthreads;
#endif

#ifdef PARAMTEST
  BLASLONG gemm_p, gemm_q, gemm_r;
#endif

} blas_arg_t;


int sgemm_beta(BLASLONG, BLASLONG, BLASLONG, float, 
	       float  *, BLASLONG, float   *, BLASLONG, float  *, BLASLONG);
int dgemm_beta(BLASLONG, BLASLONG, BLASLONG, double, 
	       double *, BLASLONG, double  *, BLASLONG, double *, BLASLONG);
int qgemm_beta(BLASLONG, BLASLONG, BLASLONG, xdouble, 
	       xdouble *, BLASLONG, xdouble  *, BLASLONG, xdouble *, BLASLONG);
int cgemm_beta(BLASLONG, BLASLONG, BLASLONG, float,  float,
	       float  *, BLASLONG, float   *, BLASLONG, float  *, BLASLONG);
int zgemm_beta(BLASLONG, BLASLONG, BLASLONG, double, double,
	       double *, BLASLONG, double  *, BLASLONG, double *, BLASLONG);
int xgemm_beta(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
	       xdouble *, BLASLONG, xdouble  *, BLASLONG, xdouble *, BLASLONG);

void sgemm_incopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void sgemm_itcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void sgemm_oncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void sgemm_otcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void dgemm_incopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void dgemm_itcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void dgemm_oncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void dgemm_otcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void qgemm_incopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void qgemm_itcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void qgemm_oncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void qgemm_otcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void cgemm_incopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm_itcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm_oncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm_otcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void zgemm_incopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm_itcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm_oncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm_otcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void xgemm_incopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm_itcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm_oncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm_otcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);

void strsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void dtrsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);

void qtrsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);

void ctrsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrsm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);

void ztrsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrsm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);

void xtrsm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrsm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);

void strmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);
void strmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, float, float *, float *, float *, BLASLONG, BLASLONG);

void dtrmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);
void dtrmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG);

void qtrmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void qtrmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);

void ctrmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);
void ctrmm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, float *, float *, BLASLONG, BLASLONG);

void ztrmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);
void ztrmm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG, BLASLONG);

void xtrmm_kernel_RN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_RT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_RR(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_RC(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_LN(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_LT(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_LR(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);
void xtrmm_kernel_LC(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG);

void strmm_iunucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_iunncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_iutucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_iutncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_ounucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_ounncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_outucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_outncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_ilnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_ilnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_iltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_iltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_olnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_olnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_oltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void strmm_oltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);

void dtrmm_iunucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_iunncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_iutucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_iutncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_ounucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_ounncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_outucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_outncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_ilnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_ilnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_iltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_iltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_olnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_olnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_oltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dtrmm_oltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);

void qtrmm_iunucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_iunncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_iutucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_iutncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_ounucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_ounncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_outucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_outncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_ilnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_ilnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_iltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_iltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_olnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_olnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_oltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qtrmm_oltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);

void ctrmm_iunucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_iunncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_iutucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_iutncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_ounucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_ounncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_outucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_outncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_ilnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_ilnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_iltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_iltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_olnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_olnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_oltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ctrmm_oltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);

void ztrmm_iunucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_iunncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_iutucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_iutncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_ounucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_ounncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_outucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_outncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_ilnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_ilnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_iltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_iltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_olnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_olnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_oltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void ztrmm_oltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);

void xtrmm_iunucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_iunncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_iutucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_iutncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_ounucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_ounncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_outucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_outncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_ilnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_ilnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_iltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_iltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_olnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_olnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_oltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xtrmm_oltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);

void strsm_iunucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_iunncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_iutucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_iutncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_ounucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_ounncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_outucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_outncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_ilnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_ilnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_iltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_iltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_olnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_olnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_oltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void strsm_oltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);

void dtrsm_iunucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_iunncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_iutucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_iutncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_ounucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_ounncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_outucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_outncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_ilnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_ilnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_iltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_iltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_olnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_olnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_oltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void dtrsm_oltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);

void qtrsm_iunucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_iunncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_iutucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_iutncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_ounucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_ounncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_outucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_outncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_ilnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_ilnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_iltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_iltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_olnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_olnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_oltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void qtrsm_oltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);

void ctrsm_iunucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_iunncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_iutucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_iutncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_ounucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_ounncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_outucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_outncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_ilnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_ilnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_iltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_iltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_olnucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_olnncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_oltucopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);
void ctrsm_oltncopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG offset, float *b);

void ztrsm_iunucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_iunncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_iutucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_iutncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_ounucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_ounncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_outucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_outncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_ilnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_ilnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_iltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_iltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_olnucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_olnncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_oltucopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);
void ztrsm_oltncopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG offset, double *b);

void xtrsm_iunucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_iunncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_iutucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_iutncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_ounucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_ounncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_outucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_outncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_ilnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_ilnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_iltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_iltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_olnucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_olnncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_oltucopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);
void xtrsm_oltncopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG offset, xdouble *b);

void ssymm_iutcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ssymm_outcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ssymm_iltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void ssymm_oltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void dsymm_iutcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dsymm_outcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dsymm_iltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void dsymm_oltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void qsymm_iutcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qsymm_outcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qsymm_iltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void qsymm_oltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void csymm_iutcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void csymm_outcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void csymm_iltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void csymm_oltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void zsymm_iutcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zsymm_outcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zsymm_iltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zsymm_oltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void xsymm_iutcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xsymm_outcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xsymm_iltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xsymm_oltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);

void chemm_iutcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void chemm_outcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void chemm_iltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void chemm_oltcopy(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, float *b);
void zhemm_iutcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zhemm_outcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zhemm_iltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void zhemm_oltcopy(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, double *b);
void xhemm_iutcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xhemm_outcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xhemm_iltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);
void xhemm_oltcopy(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG posX, BLASLONG posY, xdouble *b);

void ssyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, float alpha, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void ssyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, float alpha, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);

void dsyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, double alpha, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void dsyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, double alpha, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);

void qsyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);
void qsyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);

void csyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void csyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void zsyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void zsyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void xsyrk_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);
void xsyrk_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);

void ssyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, float alpha, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void ssyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, float alpha, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void dsyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, double alpha, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void dsyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, double alpha, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void qsyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);
void qsyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);

void csyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void csyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void zsyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void zsyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void xsyr2k_kernel_U(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);
void xsyr2k_kernel_L(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);

void cherk_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void cherk_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void cherk_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);
void cherk_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset);

void zherk_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void zherk_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void zherk_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);
void zherk_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset);

void xherk_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);
void xherk_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);
void xherk_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);
void xherk_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset);

void cher2k_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void cher2k_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void cher2k_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);
void cher2k_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, float alpha_r, float alpha_i, float *a, float *b, float *c, BLASLONG ldc, BLASLONG offset, int flag);

void zher2k_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void zher2k_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void zher2k_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);
void zher2k_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, double alpha_r, double alpha_i, double *a, double *b, double *c, BLASLONG ldc, BLASLONG offset, int flag);

void xher2k_kernel_UN(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);
void xher2k_kernel_UC(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);
void xher2k_kernel_LN(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);
void xher2k_kernel_LC(BLASLONG m, BLASLONG n, BLASLONG k, xdouble alpha_r, xdouble alpha_i, xdouble *a, xdouble *b, xdouble *c, BLASLONG ldc, BLASLONG offset, int flag);

#ifndef PREFETCHTEST
unsigned int sgemm_kernel(BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float  *, BLASLONG);
unsigned int dgemm_kernel(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG);
unsigned int qgemm_kernel(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int sgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float  *, BLASLONG);
unsigned int dgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG);
unsigned int qgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
#else
unsigned int sgemm_kernel(BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float  *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
unsigned int dgemm_kernel(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
unsigned int qgemm_kernel(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
unsigned int sgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float  *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
unsigned int dgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
unsigned int qgemm_kernel_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, BLASLONG, BLASLONG, BLASLONG);
#endif

unsigned int sgemm_fused_kernel_notrans(BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float *, BLASLONG, float  *, BLASLONG);
unsigned int sgemm_fused_kernel_trans  (BLASLONG, BLASLONG, BLASLONG, float,  float  *, float  *, float *, BLASLONG, float  *, BLASLONG);
unsigned int dgemm_fused_kernel_notrans(BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, double *, BLASLONG);
unsigned int dgemm_fused_kernel_trans  (BLASLONG, BLASLONG, BLASLONG, double, double *, double *, double *, BLASLONG, double *, BLASLONG);
unsigned int qgemm_fused_kernel_notrans(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG);
unsigned int qgemm_fused_kernel_trans  (BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG);

unsigned int cgemm_kernel_n(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_l(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_r(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_b(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_n_b0(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_l_b0(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_r_b0(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int cgemm_kernel_b_b0(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);

unsigned int zgemm_kernel_n(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_l(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_r(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_b(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_n_b0(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_l_b0(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_r_b0(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int zgemm_kernel_b_b0(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);

unsigned int xgemm_kernel_n(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_l(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_r(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_b(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_n_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_l_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_r_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);
unsigned int xgemm_kernel_b_b0(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);

unsigned int cgemm3m_kernel(BLASLONG, BLASLONG, BLASLONG, float,  float,  float  *, float  *, float  *, BLASLONG);
unsigned int zgemm3m_kernel(BLASLONG, BLASLONG, BLASLONG, double, double, double *, double *, double *, BLASLONG);
unsigned int xgemm3m_kernel(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, xdouble *, xdouble *, BLASLONG);

GEMMRETTYPE sgemm_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

GEMMRETTYPE dgemm_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

GEMMRETTYPE qgemm_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

GEMMRETTYPE cgemm_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_nr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_nc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_tr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_tc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_rn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_rt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_rr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_rc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_cn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_ct(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_cr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_cc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

GEMMRETTYPE zgemm_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_nr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_nc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_tr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_tc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_rn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_rt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_rr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_rc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_cn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_ct(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_cr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_cc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

GEMMRETTYPE xgemm_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_nr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_nc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_tr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_tc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_rn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_rt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_rr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_rc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_cn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_ct(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_cr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_cc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

GEMMRETTYPE sgemm_thread_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_thread_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_thread_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE sgemm_thread_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

GEMMRETTYPE dgemm_thread_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_thread_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_thread_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE dgemm_thread_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

GEMMRETTYPE qgemm_thread_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_thread_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_thread_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE qgemm_thread_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

GEMMRETTYPE cgemm_thread_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_nr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_nc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_tr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_tc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_rn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_rt(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_rr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_rc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_cn(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_ct(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_cr(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
GEMMRETTYPE cgemm_thread_cc(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

GEMMRETTYPE zgemm_thread_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_nr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_nc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_tr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_tc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_rn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_rt(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_rr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_rc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_cn(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_ct(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_cr(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
GEMMRETTYPE zgemm_thread_cc(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

GEMMRETTYPE xgemm_thread_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_nr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_nc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_tr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_tc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_rn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_rt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_rr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_rc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_cn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_ct(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_cr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
GEMMRETTYPE xgemm_thread_cc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

GEMMRETTYPE cgemm3m_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_nr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_nc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_tr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_tc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_rn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_rt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_rr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_rc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_cn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_ct(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_cr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_cc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_nr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_nc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_tr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_tc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_rn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_rt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_rr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_rc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_cn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_ct(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_cr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_cc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_nr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_nc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_tr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_tc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_rn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_rt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_rr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_rc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_cn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_ct(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_cr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_cc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_nn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_nt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_nr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_nc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_tn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_tt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_tr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_tc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_rn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_rt(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_rr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_rc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_cn(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_ct(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_cr(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE cgemm3m_thread_cc(blas_arg_t *, void *, void *, float *, float *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_nn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_nt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_nr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_nc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_tn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_tt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_tr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_tc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_rn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_rt(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_rr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_rc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_cn(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_ct(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_cr(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE zgemm3m_thread_cc(blas_arg_t *, void *, void *, double *, double *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_nn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_nt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_nr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_nc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_tn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_tt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_tr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_tc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_rn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_rt(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_rr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_rc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_cn(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_ct(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_cr(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

GEMMRETTYPE xgemm3m_thread_cc(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG
#ifdef PARAMTEST
		     , BLASLONG, BLASLONG, BLASLONG
#endif
);

int cher2m_LNN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LNT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LNR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LNC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LTN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LTT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LTR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LTC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LRN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LRT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LRR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LRC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LCN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LCT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LCR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_LCC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UNN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UNT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UNR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UNC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UTN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UTT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UTR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UTC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_URN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_URT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_URR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_URC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UCN(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UCT(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UCR(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);
int cher2m_UCC(BLASLONG, BLASLONG, BLASLONG, float, float, float *, BLASLONG,
	       float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, BLASLONG);

int zher2m_LNN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LNT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LNR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LNC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LTN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LTT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LTR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LTC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LRN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LRT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LRR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LRC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LCN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LCT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LCR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_LCC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UNN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UNT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UNR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UNC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UTN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UTT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UTR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UTC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_URN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_URT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_URR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_URC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UCN(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UCT(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UCR(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);
int zher2m_UCC(BLASLONG, BLASLONG, BLASLONG, double, double, double *, BLASLONG,
	       double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, BLASLONG);

int strsm_LNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_LTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strsm_RTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dtrsm_LNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_LTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrsm_RTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qtrsm_LNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_LTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrsm_RTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ctrsm_LNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LRUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LRUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LRLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LRLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LCUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LCUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LCLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_LCLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RRUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RRUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RRLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RRLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RCUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RCUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RCLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrsm_RCLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int ztrsm_LNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LRUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LRUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LRLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LRLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LCUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LCUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LCLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_LCLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RRUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RRUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RRLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RRLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RCUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RCUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RCLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrsm_RCLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xtrsm_LNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LRUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LRUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LRLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LRLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LCUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LCUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LCLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_LCLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RRUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RRUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RRLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RRLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RCUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RCUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RCLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrsm_RCLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int strmm_LNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_LTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int strmm_RTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dtrmm_LNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_LTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dtrmm_RTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qtrmm_LNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_LTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qtrmm_RTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ctrmm_LNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LRUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LRUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LRLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LRLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LCUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LCUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LCLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_LCLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RNUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RNUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RNLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RNLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RTUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RTUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RTLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RTLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RRUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RRUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RRLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RRLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RCUU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RCUN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RCLU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ctrmm_RCLN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int ztrmm_LNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LRUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LRUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LRLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LRLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LCUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LCUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LCLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_LCLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RNUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RNUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RNLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RNLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RTUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RTUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RTLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RTLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RRUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RRUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RRLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RRLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RCUU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RCUN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RCLU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int ztrmm_RCLN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xtrmm_LNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LRUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LRUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LRLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LRLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LCUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LCUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LCLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_LCLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RNUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RNUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RNLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RNLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RTUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RTUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RTLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RTLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RRUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RRUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RRLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RRLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RCUU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RCUN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RCLU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xtrmm_RCLN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ssymm_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dsymm_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qsymm_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csymm_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsymm_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsymm_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csymm3m_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsymm3m_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsymm3m_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csymm3m_thread_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_thread_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_thread_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm3m_thread_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsymm3m_thread_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_thread_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_thread_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm3m_thread_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsymm3m_thread_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_thread_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_thread_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm3m_thread_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int chemm_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zhemm_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xhemm_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int chemm3m_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zhemm3m_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xhemm3m_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int chemm3m_thread_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_thread_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_thread_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm3m_thread_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zhemm3m_thread_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_thread_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_thread_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm3m_thread_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xhemm3m_thread_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_thread_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_thread_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm3m_thread_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ssymm_thread_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_thread_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_thread_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssymm_thread_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dsymm_thread_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_thread_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_thread_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsymm_thread_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qsymm_thread_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_thread_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_thread_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsymm_thread_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csymm_thread_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_thread_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_thread_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csymm_thread_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsymm_thread_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_thread_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_thread_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsymm_thread_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsymm_thread_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_thread_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_thread_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsymm_thread_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int chemm_thread_LU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_thread_LL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_thread_RU(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int chemm_thread_RL(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zhemm_thread_LU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_thread_LL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_thread_RU(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zhemm_thread_RL(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xhemm_thread_LU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_thread_LL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_thread_RU(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xhemm_thread_RL(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ssyrk_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dsyrk_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qsyrk_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csyrk_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsyrk_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsyrk_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ssyrk_thread_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_thread_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_thread_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyrk_thread_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dsyrk_thread_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_thread_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_thread_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyrk_thread_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qsyrk_thread_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_thread_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_thread_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyrk_thread_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csyrk_thread_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_thread_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_thread_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyrk_thread_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsyrk_thread_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_thread_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_thread_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyrk_thread_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsyrk_thread_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_thread_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_thread_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyrk_thread_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int ssyr2k_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyr2k_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyr2k_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int ssyr2k_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int dsyr2k_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyr2k_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyr2k_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int dsyr2k_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int qsyr2k_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyr2k_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyr2k_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int qsyr2k_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int csyr2k_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyr2k_UT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyr2k_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int csyr2k_LT(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zsyr2k_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyr2k_UT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyr2k_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zsyr2k_LT(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xsyr2k_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyr2k_UT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyr2k_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xsyr2k_LT(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int cherk_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cherk_UC(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cherk_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cherk_LC(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zherk_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zherk_UC(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zherk_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zherk_LC(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xherk_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xherk_UC(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xherk_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xherk_LC(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int cher2k_UN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cher2k_UC(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cher2k_LN(blas_arg_t *, void *, void *, float *, float *, BLASLONG);
int cher2k_LC(blas_arg_t *, void *, void *, float *, float *, BLASLONG);

int zher2k_UN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zher2k_UC(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zher2k_LN(blas_arg_t *, void *, void *, double *, double *, BLASLONG);
int zher2k_LC(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

int xher2k_UN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xher2k_UC(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xher2k_LN(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);
int xher2k_LC(blas_arg_t *, void *, void *, xdouble *, xdouble *, BLASLONG);

int sgemt_n(BLASLONG, BLASLONG, float,  float   *, BLASLONG, float    *, int);
int sgemt_t(BLASLONG, BLASLONG, float,  float   *, BLASLONG, float    *, int);
int dgemt_n(BLASLONG, BLASLONG, double, double  *, BLASLONG, double   *, int);
int dgemt_t(BLASLONG, BLASLONG, double, double  *, BLASLONG, double   *, int);

int cgemt_n(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, int);
int cgemt_t(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, int);
int cgemt_r(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, int);
int cgemt_c(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, int);
int zgemt_n(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, int);
int zgemt_t(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, int);
int zgemt_r(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, int);
int zgemt_c(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, int);

int sgema_n(BLASLONG, BLASLONG, float,  float   *, BLASLONG, float    *, BLASLONG);
int sgema_t(BLASLONG, BLASLONG, float,  float   *, BLASLONG, float    *, BLASLONG);
int dgema_n(BLASLONG, BLASLONG, double, double  *, BLASLONG, double   *, BLASLONG);
int dgema_t(BLASLONG, BLASLONG, double, double  *, BLASLONG, double   *, BLASLONG);

int cgema_n(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, BLASLONG);
int cgema_t(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, BLASLONG);
int cgema_r(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, BLASLONG);
int cgema_c(BLASLONG, BLASLONG, float,  float,  float   *, BLASLONG, float    *, BLASLONG);
int zgema_n(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, BLASLONG);
int zgema_t(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, BLASLONG);
int zgema_r(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, BLASLONG);
int zgema_c(BLASLONG, BLASLONG, double, double, double  *, BLASLONG, double   *, BLASLONG);

void cgemm3m_incopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm3m_incopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm3m_incopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm3m_itcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm3m_itcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);
void cgemm3m_itcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float *b);

void cgemm3m_oncopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);
void cgemm3m_oncopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);
void cgemm3m_oncopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);
void cgemm3m_otcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);
void cgemm3m_otcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);
void cgemm3m_otcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, float alpha_r, float alpha_i, float *b);

void zgemm3m_incopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm3m_incopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm3m_incopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm3m_itcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm3m_itcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);
void zgemm3m_itcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double *b);

void zgemm3m_oncopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);
void zgemm3m_oncopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);
void zgemm3m_oncopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);
void zgemm3m_otcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);
void zgemm3m_otcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);
void zgemm3m_otcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, double alpha_r, double alpha_i, double *b);

void xgemm3m_incopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm3m_incopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm3m_incopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm3m_itcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm3m_itcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);
void xgemm3m_itcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble *b);

void xgemm3m_oncopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xgemm3m_oncopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xgemm3m_oncopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xgemm3m_otcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xgemm3m_otcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xgemm3m_otcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, xdouble alpha_r, xdouble alpha_i, xdouble *b);

void csymm3m_iucopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void csymm3m_ilcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void csymm3m_iucopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void csymm3m_ilcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void csymm3m_iucopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void csymm3m_ilcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);

void csymm3m_oucopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void csymm3m_olcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void csymm3m_oucopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void csymm3m_olcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void csymm3m_oucopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void csymm3m_olcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);

void zsymm3m_iucopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zsymm3m_ilcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zsymm3m_iucopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zsymm3m_ilcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zsymm3m_iucopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zsymm3m_ilcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);

void zsymm3m_oucopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zsymm3m_olcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zsymm3m_oucopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zsymm3m_olcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zsymm3m_oucopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zsymm3m_olcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);

void xsymm3m_iucopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xsymm3m_ilcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xsymm3m_iucopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xsymm3m_ilcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xsymm3m_iucopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xsymm3m_ilcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);

void xsymm3m_oucopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xsymm3m_olcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xsymm3m_oucopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xsymm3m_olcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xsymm3m_oucopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xsymm3m_olcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);

void chemm3m_iucopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void chemm3m_ilcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void chemm3m_iucopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void chemm3m_ilcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void chemm3m_iucopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);
void chemm3m_ilcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float *b);

void chemm3m_oucopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void chemm3m_olcopyb(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void chemm3m_oucopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void chemm3m_olcopyr(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void chemm3m_oucopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);
void chemm3m_olcopyi(BLASLONG m, BLASLONG n, float *a, BLASLONG lda, BLASLONG x, BLASLONG y, float alpha_r, float alpha_i, float *b);

void zhemm3m_iucopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zhemm3m_ilcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zhemm3m_iucopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zhemm3m_ilcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zhemm3m_iucopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);
void zhemm3m_ilcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double *b);

void zhemm3m_oucopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zhemm3m_olcopyb(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zhemm3m_oucopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zhemm3m_olcopyr(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zhemm3m_oucopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);
void zhemm3m_olcopyi(BLASLONG m, BLASLONG n, double *a, BLASLONG lda, BLASLONG x, BLASLONG y, double alpha_r, double alpha_i, double *b);

void xhemm3m_iucopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xhemm3m_ilcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xhemm3m_iucopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xhemm3m_ilcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xhemm3m_iucopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);
void xhemm3m_ilcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble *b);

void xhemm3m_oucopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xhemm3m_olcopyb(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xhemm3m_oucopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xhemm3m_olcopyr(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xhemm3m_oucopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);
void xhemm3m_olcopyi(BLASLONG m, BLASLONG n, xdouble *a, BLASLONG lda, BLASLONG x, BLASLONG y, xdouble alpha_r, xdouble alpha_i, xdouble *b);

#endif

#ifndef COMPLEX
#ifdef XDOUBLE
/* REAL && EXPRECISION */
#define   GEMM_BETA   qgemm_beta
#define   GEMM_ONCOPY qgemm_oncopy
#define   GEMM_OTCOPY qgemm_otcopy
#if QGEMM_UNROLL_M != QGEMM_UNROLL_N
#define   GEMM_INCOPY qgemm_incopy
#define   GEMM_ITCOPY qgemm_itcopy
#else
#define   GEMM_INCOPY qgemm_oncopy
#define   GEMM_ITCOPY qgemm_otcopy
#endif
#define   GEMM_KERNEL_N qgemm_kernel
#define   GEMM_KERNEL_L qgemm_kernel
#define   GEMM_KERNEL_R qgemm_kernel
#define   GEMM_KERNEL_B qgemm_kernel
#define   FUSED_GEMM_KERNEL_N qgemm_fused_kernel_notrans
#define   FUSED_GEMM_KERNEL_T qgemm_fused_kernel_trans
#define   GEMM_KERNEL_N_B0 qgemm_kernel_b0
#define   GEMM_KERNEL_L_B0 qgemm_kernel_b0
#define   GEMM_KERNEL_R_B0 qgemm_kernel_b0
#define   GEMM_KERNEL_B_B0 qgemm_kernel_b0
#define   GEMM_NN     qgemm_nn
#define   GEMM_TN     qgemm_tn
#define   GEMM_RN     qgemm_nn
#define   GEMM_CN     qgemm_tn
#define   GEMM_NT     qgemm_nt
#define   GEMM_TT     qgemm_tt
#define   GEMM_RT     qgemm_nt
#define   GEMM_CT     qgemm_tt
#define   GEMM_NR     qgemm_nn
#define   GEMM_TR     qgemm_tn
#define   GEMM_RR     qgemm_nn
#define   GEMM_CR     qgemm_tn
#define   GEMM_NC     qgemm_nt
#define   GEMM_TC     qgemm_tt
#define   GEMM_RC     qgemm_nt
#define   GEMM_CC     qgemm_tt
#define   GEMM_THREAD_NN     qgemm_thread_nn
#define   GEMM_THREAD_TN     qgemm_thread_tn
#define   GEMM_THREAD_RN     qgemm_thread_nn
#define   GEMM_THREAD_CN     qgemm_thread_tn
#define   GEMM_THREAD_NT     qgemm_thread_nt
#define   GEMM_THREAD_TT     qgemm_thread_tt
#define   GEMM_THREAD_RT     qgemm_thread_nt
#define   GEMM_THREAD_CT     qgemm_thread_tt
#define   GEMM_THREAD_NR     qgemm_thread_nn
#define   GEMM_THREAD_TR     qgemm_thread_tn
#define   GEMM_THREAD_RR     qgemm_thread_nn
#define   GEMM_THREAD_CR     qgemm_thread_tn
#define   GEMM_THREAD_NC     qgemm_thread_nt
#define   GEMM_THREAD_TC     qgemm_thread_tt
#define   GEMM_THREAD_RC     qgemm_thread_nt
#define   GEMM_THREAD_CC     qgemm_thread_tt

#define	  SYMM_LU		qsymm_LU
#define	  SYMM_LL		qsymm_LL
#define	  SYMM_RU		qsymm_RU
#define	  SYMM_RL		qsymm_RL
#define	  SYMM_THREADED_LU	qsymm_threaded_LU
#define	  SYMM_THREADED_LL	qsymm_threaded_LL
#define	  SYMM_THREADED_RU	qsymm_threaded_RU
#define	  SYMM_THREADED_RL	qsymm_threaded_RL

#define TRMM_KERNEL_LN  qtrmm_kernel_LN
#define TRMM_KERNEL_LT  qtrmm_kernel_LT
#define TRMM_KERNEL_LR  qtrmm_kernel_LN
#define TRMM_KERNEL_LC  qtrmm_kernel_LT
#define TRMM_KERNEL_RN  qtrmm_kernel_RN
#define TRMM_KERNEL_RT  qtrmm_kernel_RT
#define TRMM_KERNEL_RR  qtrmm_kernel_RN
#define TRMM_KERNEL_RC  qtrmm_kernel_RT

#define TRSM_KERNEL_LN  qtrsm_kernel_LN
#define TRSM_KERNEL_LT  qtrsm_kernel_LT
#define TRSM_KERNEL_LR  qtrsm_kernel_LN
#define TRSM_KERNEL_LC  qtrsm_kernel_LT
#define TRSM_KERNEL_RN  qtrsm_kernel_RN
#define TRSM_KERNEL_RT  qtrsm_kernel_RT
#define TRSM_KERNEL_RR  qtrsm_kernel_RN
#define TRSM_KERNEL_RC  qtrsm_kernel_RT

#define TRMM_LNUU qtrmm_LNUU
#define TRMM_LNUN qtrmm_LNUN
#define TRMM_LNLU qtrmm_LNLU
#define TRMM_LNLN qtrmm_LNLN
#define TRMM_LTUU qtrmm_LTUU
#define TRMM_LTUN qtrmm_LTUN
#define TRMM_LTLU qtrmm_LTLU
#define TRMM_LTLN qtrmm_LTLN
#define TRMM_LRUU qtrmm_LNUU
#define TRMM_LRUN qtrmm_LNUN
#define TRMM_LRLU qtrmm_LNLU
#define TRMM_LRLN qtrmm_LNLN
#define TRMM_LCUU qtrmm_LTUU
#define TRMM_LCUN qtrmm_LTUN
#define TRMM_LCLU qtrmm_LTLU
#define TRMM_LCLN qtrmm_LTLN

#define TRMM_RNUU qtrmm_RNUU
#define TRMM_RNUN qtrmm_RNUN
#define TRMM_RNLU qtrmm_RNLU
#define TRMM_RNLN qtrmm_RNLN
#define TRMM_RTUU qtrmm_RTUU
#define TRMM_RTUN qtrmm_RTUN
#define TRMM_RTLU qtrmm_RTLU
#define TRMM_RTLN qtrmm_RTLN
#define TRMM_RRUU qtrmm_RNUU
#define TRMM_RRUN qtrmm_RNUN
#define TRMM_RRLU qtrmm_RNLU
#define TRMM_RRLN qtrmm_RNLN
#define TRMM_RCUU qtrmm_RTUU
#define TRMM_RCUN qtrmm_RTUN
#define TRMM_RCLU qtrmm_RTLU
#define TRMM_RCLN qtrmm_RTLN

#define TRSM_LNUU qtrsm_LNUU
#define TRSM_LNUN qtrsm_LNUN
#define TRSM_LNLU qtrsm_LNLU
#define TRSM_LNLN qtrsm_LNLN
#define TRSM_LTUU qtrsm_LTUU
#define TRSM_LTUN qtrsm_LTUN
#define TRSM_LTLU qtrsm_LTLU
#define TRSM_LTLN qtrsm_LTLN
#define TRSM_LRUU qtrsm_LNUU
#define TRSM_LRUN qtrsm_LNUN
#define TRSM_LRLU qtrsm_LNLU
#define TRSM_LRLN qtrsm_LNLN
#define TRSM_LCUU qtrsm_LTUU
#define TRSM_LCUN qtrsm_LTUN
#define TRSM_LCLU qtrsm_LTLU
#define TRSM_LCLN qtrsm_LTLN

#define TRSM_RNUU qtrsm_RNUU
#define TRSM_RNUN qtrsm_RNUN
#define TRSM_RNLU qtrsm_RNLU
#define TRSM_RNLN qtrsm_RNLN
#define TRSM_RTUU qtrsm_RTUU
#define TRSM_RTUN qtrsm_RTUN
#define TRSM_RTLU qtrsm_RTLU
#define TRSM_RTLN qtrsm_RTLN
#define TRSM_RRUU qtrsm_RNUU
#define TRSM_RRUN qtrsm_RNUN
#define TRSM_RRLU qtrsm_RNLU
#define TRSM_RRLN qtrsm_RNLN
#define TRSM_RCUU qtrsm_RTUU
#define TRSM_RCUN qtrsm_RTUN
#define TRSM_RCLU qtrsm_RTLU
#define TRSM_RCLN qtrsm_RTLN

#define  SYRK_UN   qsyrk_UN
#define  SYRK_UT   qsyrk_UT
#define  SYRK_LN   qsyrk_LN
#define  SYRK_LT   qsyrk_LT
#define  SYRK_UR   qsyrk_UN
#define  SYRK_UC   qsyrk_UT
#define  SYRK_LR   qsyrk_LN
#define  SYRK_LC   qsyrk_LT

#define  SYR2K_UN  qsyr2k_UN
#define  SYR2K_UT  qsyr2k_UT
#define  SYR2K_LN  qsyr2k_LN
#define  SYR2K_LT  qsyr2k_LT
#define  SYR2K_UR  qsyr2k_UN
#define  SYR2K_UC  qsyr2k_UT
#define  SYR2K_LR  qsyr2k_LN
#define  SYR2K_LC  qsyr2k_LT

#define  HERK_UN   qsyrk_UN
#define  HERK_UT   qsyrk_UT
#define  HERK_LN   qsyrk_LN
#define  HERK_LT   qsyrk_LT
#define  HERK_UR   qsyrk_UN
#define  HERK_UC   qsyrk_UT
#define  HERK_LR   qsyrk_LN
#define  HERK_LC   qsyrk_LT

#define SYRK_KERNEL_U qsyrk_kernel_U
#define SYRK_KERNEL_L qsyrk_kernel_L

#define  SYMCOPY_L qsymcopy_L
#define  SYMCOPY_U qsymcopy_U
#define  HEMCOPY_L qsymcopy_L
#define  HEMCOPY_U qsymcopy_U

#elif defined(DOUBLE)

/* REAL && DOUBLE */
#define   GEMM_BETA   dgemm_beta
#define   GEMM_ONCOPY dgemm_oncopy
#define   GEMM_OTCOPY dgemm_otcopy
#if DGEMM_UNROLL_M != DGEMM_UNROLL_N
#define   GEMM_INCOPY dgemm_incopy
#define   GEMM_ITCOPY dgemm_itcopy
#else
#define   GEMM_INCOPY dgemm_oncopy
#define   GEMM_ITCOPY dgemm_otcopy
#endif
#define   GEMM_KERNEL_N dgemm_kernel
#define   GEMM_KERNEL_L dgemm_kernel
#define   GEMM_KERNEL_R dgemm_kernel
#define   GEMM_KERNEL_B dgemm_kernel
#define   FUSED_GEMM_KERNEL_N dgemm_fused_kernel_notrans
#define   FUSED_GEMM_KERNEL_T dgemm_fused_kernel_trans
#define   GEMM_KERNEL_N_B0 dgemm_kernel_b0
#define   GEMM_KERNEL_L_B0 dgemm_kernel_b0
#define   GEMM_KERNEL_R_B0 dgemm_kernel_b0
#define   GEMM_KERNEL_B_B0 dgemm_kernel_b0
#define   GEMM_NN     dgemm_nn
#define   GEMM_TN     dgemm_tn
#define   GEMM_RN     dgemm_nn
#define   GEMM_CN     dgemm_tn
#define   GEMM_NT     dgemm_nt
#define   GEMM_TT     dgemm_tt
#define   GEMM_RT     dgemm_nt
#define   GEMM_CT     dgemm_tt
#define   GEMM_NR     dgemm_nn
#define   GEMM_TR     dgemm_tn
#define   GEMM_RR     dgemm_nn
#define   GEMM_CR     dgemm_tn
#define   GEMM_NC     dgemm_nt
#define   GEMM_TC     dgemm_tt
#define   GEMM_RC     dgemm_nt
#define   GEMM_CC     dgemm_tt
#define   GEMM_THREAD_NN     dgemm_thread_nn
#define   GEMM_THREAD_TN     dgemm_thread_tn
#define   GEMM_THREAD_RN     dgemm_thread_nn
#define   GEMM_THREAD_CN     dgemm_thread_tn
#define   GEMM_THREAD_NT     dgemm_thread_nt
#define   GEMM_THREAD_TT     dgemm_thread_tt
#define   GEMM_THREAD_RT     dgemm_thread_nt
#define   GEMM_THREAD_CT     dgemm_thread_tt
#define   GEMM_THREAD_NR     dgemm_thread_nn
#define   GEMM_THREAD_TR     dgemm_thread_tn
#define   GEMM_THREAD_RR     dgemm_thread_nn
#define   GEMM_THREAD_CR     dgemm_thread_tn
#define   GEMM_THREAD_NC     dgemm_thread_nt
#define   GEMM_THREAD_TC     dgemm_thread_tt
#define   GEMM_THREAD_RC     dgemm_thread_nt
#define   GEMM_THREAD_CC     dgemm_thread_tt

#define	  SYMM_LU		dsymm_LU
#define	  SYMM_LL		dsymm_LL
#define	  SYMM_RU		dsymm_RU
#define	  SYMM_RL		dsymm_RL
#define	  SYMM_THREADED_LU	dsymm_threaded_LU
#define	  SYMM_THREADED_LL	dsymm_threaded_LL
#define	  SYMM_THREADED_RU	dsymm_threaded_RU
#define	  SYMM_THREADED_RL	dsymm_threaded_RL

#define TRMM_KERNEL_LN  dtrmm_kernel_LN
#define TRMM_KERNEL_LT  dtrmm_kernel_LT
#define TRMM_KERNEL_LR  dtrmm_kernel_LN
#define TRMM_KERNEL_LC  dtrmm_kernel_LT
#define TRMM_KERNEL_RN  dtrmm_kernel_RN
#define TRMM_KERNEL_RT  dtrmm_kernel_RT
#define TRMM_KERNEL_RR  dtrmm_kernel_RN
#define TRMM_KERNEL_RC  dtrmm_kernel_RT

#define TRSM_KERNEL_LN  dtrsm_kernel_LN
#define TRSM_KERNEL_LT  dtrsm_kernel_LT
#define TRSM_KERNEL_LR  dtrsm_kernel_LN
#define TRSM_KERNEL_LC  dtrsm_kernel_LT
#define TRSM_KERNEL_RN  dtrsm_kernel_RN
#define TRSM_KERNEL_RT  dtrsm_kernel_RT
#define TRSM_KERNEL_RR  dtrsm_kernel_RN
#define TRSM_KERNEL_RC  dtrsm_kernel_RT

#define TRMM_LNUU dtrmm_LNUU
#define TRMM_LNUN dtrmm_LNUN
#define TRMM_LNLU dtrmm_LNLU
#define TRMM_LNLN dtrmm_LNLN
#define TRMM_LTUU dtrmm_LTUU
#define TRMM_LTUN dtrmm_LTUN
#define TRMM_LTLU dtrmm_LTLU
#define TRMM_LTLN dtrmm_LTLN
#define TRMM_LRUU dtrmm_LNUU
#define TRMM_LRUN dtrmm_LNUN
#define TRMM_LRLU dtrmm_LNLU
#define TRMM_LRLN dtrmm_LNLN
#define TRMM_LCUU dtrmm_LTUU
#define TRMM_LCUN dtrmm_LTUN
#define TRMM_LCLU dtrmm_LTLU
#define TRMM_LCLN dtrmm_LTLN

#define TRMM_RNUU dtrmm_RNUU
#define TRMM_RNUN dtrmm_RNUN
#define TRMM_RNLU dtrmm_RNLU
#define TRMM_RNLN dtrmm_RNLN
#define TRMM_RTUU dtrmm_RTUU
#define TRMM_RTUN dtrmm_RTUN
#define TRMM_RTLU dtrmm_RTLU
#define TRMM_RTLN dtrmm_RTLN
#define TRMM_RRUU dtrmm_RNUU
#define TRMM_RRUN dtrmm_RNUN
#define TRMM_RRLU dtrmm_RNLU
#define TRMM_RRLN dtrmm_RNLN
#define TRMM_RCUU dtrmm_RTUU
#define TRMM_RCUN dtrmm_RTUN
#define TRMM_RCLU dtrmm_RTLU
#define TRMM_RCLN dtrmm_RTLN

#define TRSM_LNUU dtrsm_LNUU
#define TRSM_LNUN dtrsm_LNUN
#define TRSM_LNLU dtrsm_LNLU
#define TRSM_LNLN dtrsm_LNLN
#define TRSM_LTUU dtrsm_LTUU
#define TRSM_LTUN dtrsm_LTUN
#define TRSM_LTLU dtrsm_LTLU
#define TRSM_LTLN dtrsm_LTLN
#define TRSM_LRUU dtrsm_LNUU
#define TRSM_LRUN dtrsm_LNUN
#define TRSM_LRLU dtrsm_LNLU
#define TRSM_LRLN dtrsm_LNLN
#define TRSM_LCUU dtrsm_LTUU
#define TRSM_LCUN dtrsm_LTUN
#define TRSM_LCLU dtrsm_LTLU
#define TRSM_LCLN dtrsm_LTLN

#define TRSM_RNUU dtrsm_RNUU
#define TRSM_RNUN dtrsm_RNUN
#define TRSM_RNLU dtrsm_RNLU
#define TRSM_RNLN dtrsm_RNLN
#define TRSM_RTUU dtrsm_RTUU
#define TRSM_RTUN dtrsm_RTUN
#define TRSM_RTLU dtrsm_RTLU
#define TRSM_RTLN dtrsm_RTLN
#define TRSM_RRUU dtrsm_RNUU
#define TRSM_RRUN dtrsm_RNUN
#define TRSM_RRLU dtrsm_RNLU
#define TRSM_RRLN dtrsm_RNLN
#define TRSM_RCUU dtrsm_RTUU
#define TRSM_RCUN dtrsm_RTUN
#define TRSM_RCLU dtrsm_RTLU
#define TRSM_RCLN dtrsm_RTLN

#define  SYRK_UN   dsyrk_UN
#define  SYRK_UT   dsyrk_UT
#define  SYRK_LN   dsyrk_LN
#define  SYRK_LT   dsyrk_LT
#define  SYRK_UR   dsyrk_UN
#define  SYRK_UC   dsyrk_UT
#define  SYRK_LR   dsyrk_LN
#define  SYRK_LC   dsyrk_LT

#define  HERK_UN   dsyrk_UN
#define  HERK_UT   dsyrk_UT
#define  HERK_LN   dsyrk_LN
#define  HERK_LT   dsyrk_LT
#define  HERK_UR   dsyrk_UN
#define  HERK_UC   dsyrk_UT
#define  HERK_LR   dsyrk_LN
#define  HERK_LC   dsyrk_LT

#define SYRK_KERNEL_U dsyrk_kernel_U
#define SYRK_KERNEL_L dsyrk_kernel_L

#define  SYR2K_UN  dsyr2k_UN
#define  SYR2K_UT  dsyr2k_UT
#define  SYR2K_LN  dsyr2k_LN
#define  SYR2K_LT  dsyr2k_LT
#define  SYR2K_UR  dsyr2k_UN
#define  SYR2K_UC  dsyr2k_UT
#define  SYR2K_LR  dsyr2k_LN
#define  SYR2K_LC  dsyr2k_LT

#define  SYMCOPY_L dsymcopy_L
#define  SYMCOPY_U dsymcopy_U
#define  HEMCOPY_L dsymcopy_L
#define  HEMCOPY_U dsymcopy_U

#else
/* REAL && SINGLE */

#define   GEMM_BETA   sgemm_beta
#define   GEMM_ONCOPY sgemm_oncopy
#define   GEMM_OTCOPY sgemm_otcopy
#if SGEMM_UNROLL_M != SGEMM_UNROLL_N
#define   GEMM_INCOPY sgemm_incopy
#define   GEMM_ITCOPY sgemm_itcopy
#else
#define   GEMM_INCOPY sgemm_oncopy
#define   GEMM_ITCOPY sgemm_otcopy
#endif
#define   GEMM_KERNEL_N sgemm_kernel
#define   GEMM_KERNEL_L sgemm_kernel
#define   GEMM_KERNEL_R sgemm_kernel
#define   GEMM_KERNEL_B sgemm_kernel
#define   FUSED_GEMM_KERNEL_N sgemm_fused_kernel_notrans
#define   FUSED_GEMM_KERNEL_T sgemm_fused_kernel_trans
#define   GEMM_KERNEL_N_B0 sgemm_kernel_b0
#define   GEMM_KERNEL_L_B0 sgemm_kernel_b0
#define   GEMM_KERNEL_R_B0 sgemm_kernel_b0
#define   GEMM_KERNEL_B_B0 sgemm_kernel_b0
#define   GEMM_NN     sgemm_nn
#define   GEMM_TN     sgemm_tn
#define   GEMM_RN     sgemm_nn
#define   GEMM_CN     sgemm_tn
#define   GEMM_NT     sgemm_nt
#define   GEMM_TT     sgemm_tt
#define   GEMM_RT     sgemm_nt
#define   GEMM_CT     sgemm_tt
#define   GEMM_NR     sgemm_nn
#define   GEMM_TR     sgemm_tn
#define   GEMM_RR     sgemm_nn
#define   GEMM_CR     sgemm_tn
#define   GEMM_NC     sgemm_nt
#define   GEMM_TC     sgemm_tt
#define   GEMM_RC     sgemm_nt
#define   GEMM_CC     sgemm_tt
#define   GEMM_THREAD_NN     sgemm_thread_nn
#define   GEMM_THREAD_TN     sgemm_thread_tn
#define   GEMM_THREAD_RN     sgemm_thread_nn
#define   GEMM_THREAD_CN     sgemm_thread_tn
#define   GEMM_THREAD_NT     sgemm_thread_nt
#define   GEMM_THREAD_TT     sgemm_thread_tt
#define   GEMM_THREAD_RT     sgemm_thread_nt
#define   GEMM_THREAD_CT     sgemm_thread_tt
#define   GEMM_THREAD_NR     sgemm_thread_nn
#define   GEMM_THREAD_TR     sgemm_thread_tn
#define   GEMM_THREAD_RR     sgemm_thread_nn
#define   GEMM_THREAD_CR     sgemm_thread_tn
#define   GEMM_THREAD_NC     sgemm_thread_nt
#define   GEMM_THREAD_TC     sgemm_thread_tt
#define   GEMM_THREAD_RC     sgemm_thread_nt
#define   GEMM_THREAD_CC     sgemm_thread_tt

#define	  SYMM_LU		ssymm_LU
#define	  SYMM_LL		ssymm_LL
#define	  SYMM_RU		ssymm_RU
#define	  SYMM_RL		ssymm_RL
#define	  SYMM_THREADED_LU	ssymm_threaded_LU
#define	  SYMM_THREADED_LL	ssymm_threaded_LL
#define	  SYMM_THREADED_RU	ssymm_threaded_RU
#define	  SYMM_THREADED_RL	ssymm_threaded_RL

#define TRMM_KERNEL_LN  strmm_kernel_LN
#define TRMM_KERNEL_LT  strmm_kernel_LT
#define TRMM_KERNEL_LR  strmm_kernel_LN
#define TRMM_KERNEL_LC  strmm_kernel_LT
#define TRMM_KERNEL_RN  strmm_kernel_RN
#define TRMM_KERNEL_RT  strmm_kernel_RT
#define TRMM_KERNEL_RR  strmm_kernel_RN
#define TRMM_KERNEL_RC  strmm_kernel_RT

#define TRSM_KERNEL_LN  strsm_kernel_LN
#define TRSM_KERNEL_LT  strsm_kernel_LT
#define TRSM_KERNEL_LR  strsm_kernel_LN
#define TRSM_KERNEL_LC  strsm_kernel_LT
#define TRSM_KERNEL_RN  strsm_kernel_RN
#define TRSM_KERNEL_RT  strsm_kernel_RT
#define TRSM_KERNEL_RR  strsm_kernel_RN
#define TRSM_KERNEL_RC  strsm_kernel_RT

#define TRMM_LNUU strmm_LNUU
#define TRMM_LNUN strmm_LNUN
#define TRMM_LNLU strmm_LNLU
#define TRMM_LNLN strmm_LNLN
#define TRMM_LTUU strmm_LTUU
#define TRMM_LTUN strmm_LTUN
#define TRMM_LTLU strmm_LTLU
#define TRMM_LTLN strmm_LTLN
#define TRMM_LRUU strmm_LNUU
#define TRMM_LRUN strmm_LNUN
#define TRMM_LRLU strmm_LNLU
#define TRMM_LRLN strmm_LNLN
#define TRMM_LCUU strmm_LTUU
#define TRMM_LCUN strmm_LTUN
#define TRMM_LCLU strmm_LTLU
#define TRMM_LCLN strmm_LTLN

#define TRMM_RNUU strmm_RNUU
#define TRMM_RNUN strmm_RNUN
#define TRMM_RNLU strmm_RNLU
#define TRMM_RNLN strmm_RNLN
#define TRMM_RTUU strmm_RTUU
#define TRMM_RTUN strmm_RTUN
#define TRMM_RTLU strmm_RTLU
#define TRMM_RTLN strmm_RTLN
#define TRMM_RRUU strmm_RNUU
#define TRMM_RRUN strmm_RNUN
#define TRMM_RRLU strmm_RNLU
#define TRMM_RRLN strmm_RNLN
#define TRMM_RCUU strmm_RTUU
#define TRMM_RCUN strmm_RTUN
#define TRMM_RCLU strmm_RTLU
#define TRMM_RCLN strmm_RTLN

#define TRSM_LNUU strsm_LNUU
#define TRSM_LNUN strsm_LNUN
#define TRSM_LNLU strsm_LNLU
#define TRSM_LNLN strsm_LNLN
#define TRSM_LTUU strsm_LTUU
#define TRSM_LTUN strsm_LTUN
#define TRSM_LTLU strsm_LTLU
#define TRSM_LTLN strsm_LTLN
#define TRSM_LRUU strsm_LNUU
#define TRSM_LRUN strsm_LNUN
#define TRSM_LRLU strsm_LNLU
#define TRSM_LRLN strsm_LNLN
#define TRSM_LCUU strsm_LTUU
#define TRSM_LCUN strsm_LTUN
#define TRSM_LCLU strsm_LTLU
#define TRSM_LCLN strsm_LTLN

#define TRSM_RNUU strsm_RNUU
#define TRSM_RNUN strsm_RNUN
#define TRSM_RNLU strsm_RNLU
#define TRSM_RNLN strsm_RNLN
#define TRSM_RTUU strsm_RTUU
#define TRSM_RTUN strsm_RTUN
#define TRSM_RTLU strsm_RTLU
#define TRSM_RTLN strsm_RTLN
#define TRSM_RRUU strsm_RNUU
#define TRSM_RRUN strsm_RNUN
#define TRSM_RRLU strsm_RNLU
#define TRSM_RRLN strsm_RNLN
#define TRSM_RCUU strsm_RTUU
#define TRSM_RCUN strsm_RTUN
#define TRSM_RCLU strsm_RTLU
#define TRSM_RCLN strsm_RTLN

#define  SYRK_UN   ssyrk_UN
#define  SYRK_UT   ssyrk_UT
#define  SYRK_LN   ssyrk_LN
#define  SYRK_LT   ssyrk_LT
#define  SYRK_UR   ssyrk_UN
#define  SYRK_UC   ssyrk_UT
#define  SYRK_LR   ssyrk_LN
#define  SYRK_LC   ssyrk_LT

#define  SYR2K_UN  ssyr2k_UN
#define  SYR2K_UT  ssyr2k_UT
#define  SYR2K_LN  ssyr2k_LN
#define  SYR2K_LT  ssyr2k_LT
#define  SYR2K_UR  ssyr2k_UN
#define  SYR2K_UC  ssyr2k_UT
#define  SYR2K_LR  ssyr2k_LN
#define  SYR2K_LC  ssyr2k_LT

#define  HERK_UN   ssyrk_UN
#define  HERK_UT   ssyrk_UT
#define  HERK_LN   ssyrk_LN
#define  HERK_LT   ssyrk_LT
#define  HERK_UR   ssyrk_UN
#define  HERK_UC   ssyrk_UT
#define  HERK_LR   ssyrk_LN
#define  HERK_LC   ssyrk_LT

#define SYRK_KERNEL_U ssyrk_kernel_U
#define SYRK_KERNEL_L ssyrk_kernel_L

#define  SYMCOPY_L ssymcopy_L
#define  SYMCOPY_U ssymcopy_U
#define  HEMCOPY_L ssymcopy_L
#define  HEMCOPY_U ssymcopy_U
#endif

#else

#ifdef XDOUBLE
/* COMPLEX && EXTENDED */
#define   GEMM_BETA   xgemm_beta
#define   GEMM_ONCOPY xgemm_oncopy
#define   GEMM_OTCOPY xgemm_otcopy
#define   GEMM3M_ONCOPYB xgemm3m_oncopyb
#define   GEMM3M_ONCOPYR xgemm3m_oncopyr
#define   GEMM3M_ONCOPYI xgemm3m_oncopyi
#define   GEMM3M_OTCOPYB xgemm3m_otcopyb
#define   GEMM3M_OTCOPYR xgemm3m_otcopyr
#define   GEMM3M_OTCOPYI xgemm3m_otcopyi
#define   GEMM3M_INCOPYB xgemm3m_incopyb
#define   GEMM3M_INCOPYR xgemm3m_incopyr
#define   GEMM3M_INCOPYI xgemm3m_incopyi
#define   GEMM3M_ITCOPYB xgemm3m_itcopyb
#define   GEMM3M_ITCOPYR xgemm3m_itcopyr
#define   GEMM3M_ITCOPYI xgemm3m_itcopyi
#if XGEMM_UNROLL_M != XGEMM_UNROLL_N
#define   GEMM_INCOPY xgemm_incopy
#define   GEMM_ITCOPY xgemm_itcopy
#else
#define   GEMM_INCOPY xgemm_oncopy
#define   GEMM_ITCOPY xgemm_otcopy
#endif
#define   GEMM_KERNEL_N xgemm_kernel_n
#define   GEMM_KERNEL_L xgemm_kernel_l
#define   GEMM_KERNEL_R xgemm_kernel_r
#define   GEMM_KERNEL_B xgemm_kernel_b
#define   GEMM3M_KERNEL_N xgemm3m_kernel_n
#define   GEMM3M_KERNEL_L xgemm3m_kernel_l
#define   GEMM3M_KERNEL_R xgemm3m_kernel_r
#define   GEMM3M_KERNEL_B xgemm3m_kernel_b
#define   GEMM_KERNEL_N_B0 xgemm_kernel_n_b0
#define   GEMM_KERNEL_L_B0 xgemm_kernel_l_b0
#define   GEMM_KERNEL_R_B0 xgemm_kernel_r_b0
#define   GEMM_KERNEL_B_B0 xgemm_kernel_b_b0

#define   GEMM_NN     xgemm_nn
#define   GEMM_CN     xgemm_cn
#define   GEMM_TN     xgemm_tn
#define   GEMM_NC     xgemm_nc
#define   GEMM_NT     xgemm_nt
#define   GEMM_CC     xgemm_cc
#define   GEMM_CT     xgemm_ct
#define   GEMM_TC     xgemm_tc
#define   GEMM_TT     xgemm_tt
#define   GEMM_NR     xgemm_nr
#define   GEMM_TR     xgemm_tr
#define   GEMM_CR     xgemm_cr
#define   GEMM_RN     xgemm_rn
#define   GEMM_RT     xgemm_rt
#define   GEMM_RC     xgemm_rc
#define   GEMM_RR     xgemm_rr

#define   GEMM_THREAD_NN     xgemm_thread_nn
#define   GEMM_THREAD_CN     xgemm_thread_cn
#define   GEMM_THREAD_TN     xgemm_thread_tn
#define   GEMM_THREAD_NC     xgemm_thread_nc
#define   GEMM_THREAD_NT     xgemm_thread_nt
#define   GEMM_THREAD_CC     xgemm_thread_cc
#define   GEMM_THREAD_CT     xgemm_thread_ct
#define   GEMM_THREAD_TC     xgemm_thread_tc
#define   GEMM_THREAD_TT     xgemm_thread_tt
#define   GEMM_THREAD_NR     xgemm_thread_nr
#define   GEMM_THREAD_TR     xgemm_thread_tr
#define   GEMM_THREAD_CR     xgemm_thread_cr
#define   GEMM_THREAD_RN     xgemm_thread_rn
#define   GEMM_THREAD_RT     xgemm_thread_rt
#define   GEMM_THREAD_RC     xgemm_thread_rc
#define   GEMM_THREAD_RR     xgemm_thread_rr

#define   GEMM3M_NN     xgemm3m_nn
#define   GEMM3M_CN     xgemm3m_cn
#define   GEMM3M_TN     xgemm3m_tn
#define   GEMM3M_NC     xgemm3m_nc
#define   GEMM3M_NT     xgemm3m_nt
#define   GEMM3M_CC     xgemm3m_cc
#define   GEMM3M_CT     xgemm3m_ct
#define   GEMM3M_TC     xgemm3m_tc
#define   GEMM3M_TT     xgemm3m_tt
#define   GEMM3M_NR     xgemm3m_nr
#define   GEMM3M_TR     xgemm3m_tr
#define   GEMM3M_CR     xgemm3m_cr
#define   GEMM3M_RN     xgemm3m_rn
#define   GEMM3M_RT     xgemm3m_rt
#define   GEMM3M_RC     xgemm3m_rc
#define   GEMM3M_RR     xgemm3m_rr

#define   GEMM3M_THREAD_NN     xgemm3m_thread_nn
#define   GEMM3M_THREAD_CN     xgemm3m_thread_cn
#define   GEMM3M_THREAD_TN     xgemm3m_thread_tn
#define   GEMM3M_THREAD_NC     xgemm3m_thread_nc
#define   GEMM3M_THREAD_NT     xgemm3m_thread_nt
#define   GEMM3M_THREAD_CC     xgemm3m_thread_cc
#define   GEMM3M_THREAD_CT     xgemm3m_thread_ct
#define   GEMM3M_THREAD_TC     xgemm3m_thread_tc
#define   GEMM3M_THREAD_TT     xgemm3m_thread_tt
#define   GEMM3M_THREAD_NR     xgemm3m_thread_nr
#define   GEMM3M_THREAD_TR     xgemm3m_thread_tr
#define   GEMM3M_THREAD_CR     xgemm3m_thread_cr
#define   GEMM3M_THREAD_RN     xgemm3m_thread_rn
#define   GEMM3M_THREAD_RT     xgemm3m_thread_rt
#define   GEMM3M_THREAD_RC     xgemm3m_thread_rc
#define   GEMM3M_THREAD_RR     xgemm3m_thread_rr

#define   SYMM3M_ILCOPYB xsymm3m_ilcopyb
#define   SYMM3M_IUCOPYB xsymm3m_iucopyb
#define   SYMM3M_ILCOPYR xsymm3m_ilcopyr
#define   SYMM3M_IUCOPYR xsymm3m_iucopyr
#define   SYMM3M_ILCOPYI xsymm3m_ilcopyi
#define   SYMM3M_IUCOPYI xsymm3m_iucopyi

#define   SYMM3M_OLCOPYB xsymm3m_olcopyb
#define   SYMM3M_OUCOPYB xsymm3m_oucopyb
#define   SYMM3M_OLCOPYR xsymm3m_olcopyr
#define   SYMM3M_OUCOPYR xsymm3m_oucopyr
#define   SYMM3M_OLCOPYI xsymm3m_olcopyi
#define   SYMM3M_OUCOPYI xsymm3m_oucopyi

#define   HEMM3M_ILCOPYB xhemm3m_ilcopyb
#define   HEMM3M_IUCOPYB xhemm3m_iucopyb
#define   HEMM3M_ILCOPYR xhemm3m_ilcopyr
#define   HEMM3M_IUCOPYR xhemm3m_iucopyr
#define   HEMM3M_ILCOPYI xhemm3m_ilcopyi
#define   HEMM3M_IUCOPYI xhemm3m_iucopyi

#define   HEMM3M_OLCOPYB xhemm3m_olcopyb
#define   HEMM3M_OUCOPYB xhemm3m_oucopyb
#define   HEMM3M_OLCOPYR xhemm3m_olcopyr
#define   HEMM3M_OUCOPYR xhemm3m_oucopyr
#define   HEMM3M_OLCOPYI xhemm3m_olcopyi
#define   HEMM3M_OUCOPYI xhemm3m_oucopyi

#define	  SYMM_LU		xsymm_LU
#define	  SYMM_LL		xsymm_LL
#define	  SYMM_RU		xsymm_RU
#define	  SYMM_RL		xsymm_RL
#define	  SYMM3M_LU		xsymm3m_LU
#define	  SYMM3M_LL		xsymm3m_LL
#define	  SYMM3M_RU		xsymm3m_RU
#define	  SYMM3M_RL		xsymm3m_RL
#define	  HEMM3M_LU		xhemm3m_LU
#define	  HEMM3M_LL		xhemm3m_LL
#define	  HEMM3M_RU		xhemm3m_RU
#define	  HEMM3M_RL		xhemm3m_RL
#define	  SYMM_THREADED_LU	xsymm_threaded_LU
#define	  SYMM_THREADED_LL	xsymm_threaded_LL
#define	  SYMM_THREADED_RU	xsymm_threaded_RU
#define	  SYMM_THREADED_RL	xsymm_threaded_RL

#define	  HEMM_LU		xhemm_LU
#define	  HEMM_LL		xhemm_LL
#define	  HEMM_RU		xhemm_RU
#define	  HEMM_RL		xhemm_RL
#define	  HEMM_THREADED_LU	xhemm_threaded_LU
#define	  HEMM_THREADED_LL	xhemm_threaded_LL
#define	  HEMM_THREADED_RU	xhemm_threaded_RU
#define	  HEMM_THREADED_RL	xhemm_threaded_RL

#define TRMM_KERNEL_LN  xtrmm_kernel_LN
#define TRMM_KERNEL_LT  xtrmm_kernel_LT
#define TRMM_KERNEL_LR  xtrmm_kernel_LR
#define TRMM_KERNEL_LC  xtrmm_kernel_LC
#define TRMM_KERNEL_RN  xtrmm_kernel_RN
#define TRMM_KERNEL_RT  xtrmm_kernel_RT
#define TRMM_KERNEL_RR  xtrmm_kernel_RR
#define TRMM_KERNEL_RC  xtrmm_kernel_RC

#define TRSM_KERNEL_LN  xtrsm_kernel_LN
#define TRSM_KERNEL_LT  xtrsm_kernel_LT
#define TRSM_KERNEL_LR  xtrsm_kernel_LR
#define TRSM_KERNEL_LC  xtrsm_kernel_LC
#define TRSM_KERNEL_RN  xtrsm_kernel_RN
#define TRSM_KERNEL_RT  xtrsm_kernel_RT
#define TRSM_KERNEL_RR  xtrsm_kernel_RR
#define TRSM_KERNEL_RC  xtrsm_kernel_RC

#define TRMM_LNUU xtrmm_LNUU
#define TRMM_LNUN xtrmm_LNUN
#define TRMM_LNLU xtrmm_LNLU
#define TRMM_LNLN xtrmm_LNLN
#define TRMM_LTUU xtrmm_LTUU
#define TRMM_LTUN xtrmm_LTUN
#define TRMM_LTLU xtrmm_LTLU
#define TRMM_LTLN xtrmm_LTLN
#define TRMM_LRUU xtrmm_LRUU
#define TRMM_LRUN xtrmm_LRUN
#define TRMM_LRLU xtrmm_LRLU
#define TRMM_LRLN xtrmm_LRLN
#define TRMM_LCUU xtrmm_LCUU
#define TRMM_LCUN xtrmm_LCUN
#define TRMM_LCLU xtrmm_LCLU
#define TRMM_LCLN xtrmm_LCLN

#define TRMM_RNUU xtrmm_RNUU
#define TRMM_RNUN xtrmm_RNUN
#define TRMM_RNLU xtrmm_RNLU
#define TRMM_RNLN xtrmm_RNLN
#define TRMM_RTUU xtrmm_RTUU
#define TRMM_RTUN xtrmm_RTUN
#define TRMM_RTLU xtrmm_RTLU
#define TRMM_RTLN xtrmm_RTLN
#define TRMM_RRUU xtrmm_RRUU
#define TRMM_RRUN xtrmm_RRUN
#define TRMM_RRLU xtrmm_RRLU
#define TRMM_RRLN xtrmm_RRLN
#define TRMM_RCUU xtrmm_RCUU
#define TRMM_RCUN xtrmm_RCUN
#define TRMM_RCLU xtrmm_RCLU
#define TRMM_RCLN xtrmm_RCLN

#define TRSM_LNUU xtrsm_LNUU
#define TRSM_LNUN xtrsm_LNUN
#define TRSM_LNLU xtrsm_LNLU
#define TRSM_LNLN xtrsm_LNLN
#define TRSM_LTUU xtrsm_LTUU
#define TRSM_LTUN xtrsm_LTUN
#define TRSM_LTLU xtrsm_LTLU
#define TRSM_LTLN xtrsm_LTLN
#define TRSM_LRUU xtrsm_LRUU
#define TRSM_LRUN xtrsm_LRUN
#define TRSM_LRLU xtrsm_LRLU
#define TRSM_LRLN xtrsm_LRLN
#define TRSM_LCUU xtrsm_LCUU
#define TRSM_LCUN xtrsm_LCUN
#define TRSM_LCLU xtrsm_LCLU
#define TRSM_LCLN xtrsm_LCLN

#define TRSM_RNUU xtrsm_RNUU
#define TRSM_RNUN xtrsm_RNUN
#define TRSM_RNLU xtrsm_RNLU
#define TRSM_RNLN xtrsm_RNLN
#define TRSM_RTUU xtrsm_RTUU
#define TRSM_RTUN xtrsm_RTUN
#define TRSM_RTLU xtrsm_RTLU
#define TRSM_RTLN xtrsm_RTLN
#define TRSM_RRUU xtrsm_RRUU
#define TRSM_RRUN xtrsm_RRUN
#define TRSM_RRLU xtrsm_RRLU
#define TRSM_RRLN xtrsm_RRLN
#define TRSM_RCUU xtrsm_RCUU
#define TRSM_RCUN xtrsm_RCUN
#define TRSM_RCLU xtrsm_RCLU
#define TRSM_RCLN xtrsm_RCLN

#define  SYRK_UN   xsyrk_UN
#define  SYRK_UT   xsyrk_UT
#define  SYRK_LN   xsyrk_LN
#define  SYRK_LT   xsyrk_LT
#define  SYRK_UR   xsyrk_UR
#define  SYRK_UC   xsyrk_UC
#define  SYRK_LR   xsyrk_LR
#define  SYRK_LC   xsyrk_LC

#define  HERK_UN   xherk_UN
#define  HERK_UT   xherk_UT
#define  HERK_LN   xherk_LN
#define  HERK_LT   xherk_LT
#define  HERK_UR   xherk_UR
#define  HERK_UC   xherk_UC
#define  HERK_LR   xherk_LR
#define  HERK_LC   xherk_LC

#define SYRK_KERNEL_U xsyrk_kernel_U
#define SYRK_KERNEL_L xsyrk_kernel_L

#define  SYR2K_UN  xsyr2k_UN
#define  SYR2K_UT  xsyr2k_UT
#define  SYR2K_LN  xsyr2k_LN
#define  SYR2K_LT  xsyr2k_LT
#define  SYR2K_UR  xsyr2k_UR
#define  SYR2K_UC  xsyr2k_UC
#define  SYR2K_LR  xsyr2k_LR
#define  SYR2K_LC  xsyr2k_LC

#define  SYMCOPY_L xsymcopy_L
#define  SYMCOPY_U xsymcopy_U
#define  HEMCOPY_L xhemcopy_L
#define  HEMCOPY_U xhemcopy_U

#elif defined(DOUBLE)
/* COMPLEX && DOUBLE */
#define   GEMM_BETA   zgemm_beta
#define   GEMM_ONCOPY zgemm_oncopy
#define   GEMM_OTCOPY zgemm_otcopy
#define   GEMM3M_ONCOPYB zgemm3m_oncopyb
#define   GEMM3M_ONCOPYR zgemm3m_oncopyr
#define   GEMM3M_ONCOPYI zgemm3m_oncopyi
#define   GEMM3M_OTCOPYB zgemm3m_otcopyb
#define   GEMM3M_OTCOPYR zgemm3m_otcopyr
#define   GEMM3M_OTCOPYI zgemm3m_otcopyi
#define   GEMM3M_INCOPYB zgemm3m_incopyb
#define   GEMM3M_INCOPYR zgemm3m_incopyr
#define   GEMM3M_INCOPYI zgemm3m_incopyi
#define   GEMM3M_ITCOPYB zgemm3m_itcopyb
#define   GEMM3M_ITCOPYR zgemm3m_itcopyr
#define   GEMM3M_ITCOPYI zgemm3m_itcopyi
#if ZGEMM_UNROLL_M != ZGEMM_UNROLL_N
#define   GEMM_INCOPY zgemm_incopy
#define   GEMM_ITCOPY zgemm_itcopy
#else
#define   GEMM_INCOPY zgemm_oncopy
#define   GEMM_ITCOPY zgemm_otcopy
#endif
#define   GEMM_KERNEL_N zgemm_kernel_n
#define   GEMM_KERNEL_L zgemm_kernel_l
#define   GEMM_KERNEL_R zgemm_kernel_r
#define   GEMM_KERNEL_B zgemm_kernel_b
#define   GEMM_KERNEL_N_B0 zgemm_kernel_n_b0
#define   GEMM_KERNEL_L_B0 zgemm_kernel_l_b0
#define   GEMM_KERNEL_R_B0 zgemm_kernel_r_b0
#define   GEMM_KERNEL_B_B0 zgemm_kernel_b_b0
#define   GEMM3M_KERNEL_N zgemm3m_kernel
#define   GEMM3M_KERNEL_L zgemm3m_kernel
#define   GEMM3M_KERNEL_R zgemm3m_kernel
#define   GEMM3M_KERNEL_B zgemm3m_kernel
#define   GEMM_NN     zgemm_nn
#define   GEMM_CN     zgemm_cn
#define   GEMM_TN     zgemm_tn
#define   GEMM_NC     zgemm_nc
#define   GEMM_NT     zgemm_nt
#define   GEMM_CC     zgemm_cc
#define   GEMM_CT     zgemm_ct
#define   GEMM_TC     zgemm_tc
#define   GEMM_TT     zgemm_tt
#define   GEMM_NR     zgemm_nr
#define   GEMM_TR     zgemm_tr
#define   GEMM_CR     zgemm_cr
#define   GEMM_RN     zgemm_rn
#define   GEMM_RT     zgemm_rt
#define   GEMM_RC     zgemm_rc
#define   GEMM_RR     zgemm_rr

#define   GEMM_THREAD_NN     zgemm_thread_nn
#define   GEMM_THREAD_CN     zgemm_thread_cn
#define   GEMM_THREAD_TN     zgemm_thread_tn
#define   GEMM_THREAD_NC     zgemm_thread_nc
#define   GEMM_THREAD_NT     zgemm_thread_nt
#define   GEMM_THREAD_CC     zgemm_thread_cc
#define   GEMM_THREAD_CT     zgemm_thread_ct
#define   GEMM_THREAD_TC     zgemm_thread_tc
#define   GEMM_THREAD_TT     zgemm_thread_tt
#define   GEMM_THREAD_NR     zgemm_thread_nr
#define   GEMM_THREAD_TR     zgemm_thread_tr
#define   GEMM_THREAD_CR     zgemm_thread_cr
#define   GEMM_THREAD_RN     zgemm_thread_rn
#define   GEMM_THREAD_RT     zgemm_thread_rt
#define   GEMM_THREAD_RC     zgemm_thread_rc
#define   GEMM_THREAD_RR     zgemm_thread_rr

#define   GEMM3M_NN     zgemm3m_nn
#define   GEMM3M_CN     zgemm3m_cn
#define   GEMM3M_TN     zgemm3m_tn
#define   GEMM3M_NC     zgemm3m_nc
#define   GEMM3M_NT     zgemm3m_nt
#define   GEMM3M_CC     zgemm3m_cc
#define   GEMM3M_CT     zgemm3m_ct
#define   GEMM3M_TC     zgemm3m_tc
#define   GEMM3M_TT     zgemm3m_tt
#define   GEMM3M_NR     zgemm3m_nr
#define   GEMM3M_TR     zgemm3m_tr
#define   GEMM3M_CR     zgemm3m_cr
#define   GEMM3M_RN     zgemm3m_rn
#define   GEMM3M_RT     zgemm3m_rt
#define   GEMM3M_RC     zgemm3m_rc
#define   GEMM3M_RR     zgemm3m_rr

#define   GEMM3M_THREAD_NN     zgemm3m_thread_nn
#define   GEMM3M_THREAD_CN     zgemm3m_thread_cn
#define   GEMM3M_THREAD_TN     zgemm3m_thread_tn
#define   GEMM3M_THREAD_NC     zgemm3m_thread_nc
#define   GEMM3M_THREAD_NT     zgemm3m_thread_nt
#define   GEMM3M_THREAD_CC     zgemm3m_thread_cc
#define   GEMM3M_THREAD_CT     zgemm3m_thread_ct
#define   GEMM3M_THREAD_TC     zgemm3m_thread_tc
#define   GEMM3M_THREAD_TT     zgemm3m_thread_tt
#define   GEMM3M_THREAD_NR     zgemm3m_thread_nr
#define   GEMM3M_THREAD_TR     zgemm3m_thread_tr
#define   GEMM3M_THREAD_CR     zgemm3m_thread_cr
#define   GEMM3M_THREAD_RN     zgemm3m_thread_rn
#define   GEMM3M_THREAD_RT     zgemm3m_thread_rt
#define   GEMM3M_THREAD_RC     zgemm3m_thread_rc
#define   GEMM3M_THREAD_RR     zgemm3m_thread_rr

#define   SYMM3M_ILCOPYB zsymm3m_ilcopyb
#define   SYMM3M_IUCOPYB zsymm3m_iucopyb
#define   SYMM3M_ILCOPYR zsymm3m_ilcopyr
#define   SYMM3M_IUCOPYR zsymm3m_iucopyr
#define   SYMM3M_ILCOPYI zsymm3m_ilcopyi
#define   SYMM3M_IUCOPYI zsymm3m_iucopyi

#define   SYMM3M_OLCOPYB zsymm3m_olcopyb
#define   SYMM3M_OUCOPYB zsymm3m_oucopyb
#define   SYMM3M_OLCOPYR zsymm3m_olcopyr
#define   SYMM3M_OUCOPYR zsymm3m_oucopyr
#define   SYMM3M_OLCOPYI zsymm3m_olcopyi
#define   SYMM3M_OUCOPYI zsymm3m_oucopyi

#define   HEMM3M_ILCOPYB zhemm3m_ilcopyb
#define   HEMM3M_IUCOPYB zhemm3m_iucopyb
#define   HEMM3M_ILCOPYR zhemm3m_ilcopyr
#define   HEMM3M_IUCOPYR zhemm3m_iucopyr
#define   HEMM3M_ILCOPYI zhemm3m_ilcopyi
#define   HEMM3M_IUCOPYI zhemm3m_iucopyi

#define   HEMM3M_OLCOPYB zhemm3m_olcopyb
#define   HEMM3M_OUCOPYB zhemm3m_oucopyb
#define   HEMM3M_OLCOPYR zhemm3m_olcopyr
#define   HEMM3M_OUCOPYR zhemm3m_oucopyr
#define   HEMM3M_OLCOPYI zhemm3m_olcopyi
#define   HEMM3M_OUCOPYI zhemm3m_oucopyi

#define	  SYMM_LU		zsymm_LU
#define	  SYMM_LL		zsymm_LL
#define	  SYMM_RU		zsymm_RU
#define	  SYMM_RL		zsymm_RL
#define	  SYMM3M_LU		zsymm3m_LU
#define	  SYMM3M_LL		zsymm3m_LL
#define	  SYMM3M_RU		zsymm3m_RU
#define	  SYMM3M_RL		zsymm3m_RL
#define	  HEMM3M_LU		zhemm3m_LU
#define	  HEMM3M_LL		zhemm3m_LL
#define	  HEMM3M_RU		zhemm3m_RU
#define	  HEMM3M_RL		zhemm3m_RL
#define	  SYMM_THREADED_LU	zsymm_threaded_LU
#define	  SYMM_THREADED_LL	zsymm_threaded_LL
#define	  SYMM_THREADED_RU	zsymm_threaded_RU
#define	  SYMM_THREADED_RL	zsymm_threaded_RL

#define	  HEMM_LU		zhemm_LU
#define	  HEMM_LL		zhemm_LL
#define	  HEMM_RU		zhemm_RU
#define	  HEMM_RL		zhemm_RL
#define	  HEMM_THREADED_LU	zhemm_threaded_LU
#define	  HEMM_THREADED_LL	zhemm_threaded_LL
#define	  HEMM_THREADED_RU	zhemm_threaded_RU
#define	  HEMM_THREADED_RL	zhemm_threaded_RL

#define TRMM_KERNEL_LN  ztrmm_kernel_LN
#define TRMM_KERNEL_LT  ztrmm_kernel_LT
#define TRMM_KERNEL_LR  ztrmm_kernel_LR
#define TRMM_KERNEL_LC  ztrmm_kernel_LC
#define TRMM_KERNEL_RN  ztrmm_kernel_RN
#define TRMM_KERNEL_RT  ztrmm_kernel_RT
#define TRMM_KERNEL_RR  ztrmm_kernel_RR
#define TRMM_KERNEL_RC  ztrmm_kernel_RC

#define TRSM_KERNEL_LN  ztrsm_kernel_LN
#define TRSM_KERNEL_LT  ztrsm_kernel_LT
#define TRSM_KERNEL_LR  ztrsm_kernel_LR
#define TRSM_KERNEL_LC  ztrsm_kernel_LC
#define TRSM_KERNEL_RN  ztrsm_kernel_RN
#define TRSM_KERNEL_RT  ztrsm_kernel_RT
#define TRSM_KERNEL_RR  ztrsm_kernel_RR
#define TRSM_KERNEL_RC  ztrsm_kernel_RC

#define TRMM_LNUU ztrmm_LNUU
#define TRMM_LNUN ztrmm_LNUN
#define TRMM_LNLU ztrmm_LNLU
#define TRMM_LNLN ztrmm_LNLN
#define TRMM_LTUU ztrmm_LTUU
#define TRMM_LTUN ztrmm_LTUN
#define TRMM_LTLU ztrmm_LTLU
#define TRMM_LTLN ztrmm_LTLN
#define TRMM_LRUU ztrmm_LRUU
#define TRMM_LRUN ztrmm_LRUN
#define TRMM_LRLU ztrmm_LRLU
#define TRMM_LRLN ztrmm_LRLN
#define TRMM_LCUU ztrmm_LCUU
#define TRMM_LCUN ztrmm_LCUN
#define TRMM_LCLU ztrmm_LCLU
#define TRMM_LCLN ztrmm_LCLN

#define TRMM_RNUU ztrmm_RNUU
#define TRMM_RNUN ztrmm_RNUN
#define TRMM_RNLU ztrmm_RNLU
#define TRMM_RNLN ztrmm_RNLN
#define TRMM_RTUU ztrmm_RTUU
#define TRMM_RTUN ztrmm_RTUN
#define TRMM_RTLU ztrmm_RTLU
#define TRMM_RTLN ztrmm_RTLN
#define TRMM_RRUU ztrmm_RRUU
#define TRMM_RRUN ztrmm_RRUN
#define TRMM_RRLU ztrmm_RRLU
#define TRMM_RRLN ztrmm_RRLN
#define TRMM_RCUU ztrmm_RCUU
#define TRMM_RCUN ztrmm_RCUN
#define TRMM_RCLU ztrmm_RCLU
#define TRMM_RCLN ztrmm_RCLN

#define TRSM_LNUU ztrsm_LNUU
#define TRSM_LNUN ztrsm_LNUN
#define TRSM_LNLU ztrsm_LNLU
#define TRSM_LNLN ztrsm_LNLN
#define TRSM_LTUU ztrsm_LTUU
#define TRSM_LTUN ztrsm_LTUN
#define TRSM_LTLU ztrsm_LTLU
#define TRSM_LTLN ztrsm_LTLN
#define TRSM_LRUU ztrsm_LRUU
#define TRSM_LRUN ztrsm_LRUN
#define TRSM_LRLU ztrsm_LRLU
#define TRSM_LRLN ztrsm_LRLN
#define TRSM_LCUU ztrsm_LCUU
#define TRSM_LCUN ztrsm_LCUN
#define TRSM_LCLU ztrsm_LCLU
#define TRSM_LCLN ztrsm_LCLN

#define TRSM_RNUU ztrsm_RNUU
#define TRSM_RNUN ztrsm_RNUN
#define TRSM_RNLU ztrsm_RNLU
#define TRSM_RNLN ztrsm_RNLN
#define TRSM_RTUU ztrsm_RTUU
#define TRSM_RTUN ztrsm_RTUN
#define TRSM_RTLU ztrsm_RTLU
#define TRSM_RTLN ztrsm_RTLN
#define TRSM_RRUU ztrsm_RRUU
#define TRSM_RRUN ztrsm_RRUN
#define TRSM_RRLU ztrsm_RRLU
#define TRSM_RRLN ztrsm_RRLN
#define TRSM_RCUU ztrsm_RCUU
#define TRSM_RCUN ztrsm_RCUN
#define TRSM_RCLU ztrsm_RCLU
#define TRSM_RCLN ztrsm_RCLN

#define  SYRK_UN   zsyrk_UN
#define  SYRK_UT   zsyrk_UT
#define  SYRK_LN   zsyrk_LN
#define  SYRK_LT   zsyrk_LT
#define  SYRK_UR   zsyrk_UR
#define  SYRK_UC   zsyrk_UC
#define  SYRK_LR   zsyrk_LR
#define  SYRK_LC   zsyrk_LC

#define  HERK_UN   zherk_UN
#define  HERK_UT   zherk_UT
#define  HERK_LN   zherk_LN
#define  HERK_LT   zherk_LT
#define  HERK_UR   zherk_UR
#define  HERK_UC   zherk_UC
#define  HERK_LR   zherk_LR
#define  HERK_LC   zherk_LC

#define SYRK_KERNEL_U zsyrk_kernel_U
#define SYRK_KERNEL_L zsyrk_kernel_L

#define  SYR2K_UN  zsyr2k_UN
#define  SYR2K_UT  zsyr2k_UT
#define  SYR2K_LN  zsyr2k_LN
#define  SYR2K_LT  zsyr2k_LT
#define  SYR2K_UR  zsyr2k_UR
#define  SYR2K_UC  zsyr2k_UC
#define  SYR2K_LR  zsyr2k_LR
#define  SYR2K_LC  zsyr2k_LC

#define  SYMCOPY_L zsymcopy_L
#define  SYMCOPY_U zsymcopy_U
#define  HEMCOPY_L zhemcopy_L
#define  HEMCOPY_U zhemcopy_U

#else

/* COMPLEX && SINGLE */
#define   GEMM_BETA   cgemm_beta
#define   GEMM_ONCOPY cgemm_oncopy
#define   GEMM_OTCOPY cgemm_otcopy
#define   GEMM3M_ONCOPYB cgemm3m_oncopyb
#define   GEMM3M_ONCOPYR cgemm3m_oncopyr
#define   GEMM3M_ONCOPYI cgemm3m_oncopyi
#define   GEMM3M_OTCOPYB cgemm3m_otcopyb
#define   GEMM3M_OTCOPYR cgemm3m_otcopyr
#define   GEMM3M_OTCOPYI cgemm3m_otcopyi
#define   GEMM3M_INCOPYB cgemm3m_incopyb
#define   GEMM3M_INCOPYR cgemm3m_incopyr
#define   GEMM3M_INCOPYI cgemm3m_incopyi
#define   GEMM3M_ITCOPYB cgemm3m_itcopyb
#define   GEMM3M_ITCOPYR cgemm3m_itcopyr
#define   GEMM3M_ITCOPYI cgemm3m_itcopyi
#if CGEMM_UNROLL_M != CGEMM_UNROLL_N
#define   GEMM_INCOPY cgemm_incopy
#define   GEMM_ITCOPY cgemm_itcopy
#else
#define   GEMM_INCOPY cgemm_oncopy
#define   GEMM_ITCOPY cgemm_otcopy
#endif
#define   GEMM_KERNEL_N cgemm_kernel_n
#define   GEMM_KERNEL_L cgemm_kernel_l
#define   GEMM_KERNEL_R cgemm_kernel_r
#define   GEMM_KERNEL_B cgemm_kernel_b
#define   GEMM_KERNEL_N_B0 cgemm_kernel_n_b0
#define   GEMM_KERNEL_L_B0 cgemm_kernel_l_b0
#define   GEMM_KERNEL_R_B0 cgemm_kernel_r_b0
#define   GEMM_KERNEL_B_B0 cgemm_kernel_b_b0
#define   GEMM3M_KERNEL_N cgemm3m_kernel_n
#define   GEMM3M_KERNEL_L cgemm3m_kernel_l
#define   GEMM3M_KERNEL_R cgemm3m_kernel_r
#define   GEMM3M_KERNEL_B cgemm3m_kernel_b
#define   GEMM_NN     cgemm_nn
#define   GEMM_CN     cgemm_cn
#define   GEMM_TN     cgemm_tn
#define   GEMM_NC     cgemm_nc
#define   GEMM_NT     cgemm_nt
#define   GEMM_CC     cgemm_cc
#define   GEMM_CT     cgemm_ct
#define   GEMM_TC     cgemm_tc
#define   GEMM_TT     cgemm_tt
#define   GEMM_NR     cgemm_nr
#define   GEMM_TR     cgemm_tr
#define   GEMM_CR     cgemm_cr
#define   GEMM_RN     cgemm_rn
#define   GEMM_RT     cgemm_rt
#define   GEMM_RC     cgemm_rc
#define   GEMM_RR     cgemm_rr

#define   GEMM_THREAD_NN     cgemm_thread_nn
#define   GEMM_THREAD_CN     cgemm_thread_cn
#define   GEMM_THREAD_TN     cgemm_thread_tn
#define   GEMM_THREAD_NC     cgemm_thread_nc
#define   GEMM_THREAD_NT     cgemm_thread_nt
#define   GEMM_THREAD_CC     cgemm_thread_cc
#define   GEMM_THREAD_CT     cgemm_thread_ct
#define   GEMM_THREAD_TC     cgemm_thread_tc
#define   GEMM_THREAD_TT     cgemm_thread_tt
#define   GEMM_THREAD_NR     cgemm_thread_nr
#define   GEMM_THREAD_TR     cgemm_thread_tr
#define   GEMM_THREAD_CR     cgemm_thread_cr
#define   GEMM_THREAD_RN     cgemm_thread_rn
#define   GEMM_THREAD_RT     cgemm_thread_rt
#define   GEMM_THREAD_RC     cgemm_thread_rc
#define   GEMM_THREAD_RR     cgemm_thread_rr

#define   GEMM3M_NN     cgemm3m_nn
#define   GEMM3M_CN     cgemm3m_cn
#define   GEMM3M_TN     cgemm3m_tn
#define   GEMM3M_NC     cgemm3m_nc
#define   GEMM3M_NT     cgemm3m_nt
#define   GEMM3M_CC     cgemm3m_cc
#define   GEMM3M_CT     cgemm3m_ct
#define   GEMM3M_TC     cgemm3m_tc
#define   GEMM3M_TT     cgemm3m_tt
#define   GEMM3M_NR     cgemm3m_nr
#define   GEMM3M_TR     cgemm3m_tr
#define   GEMM3M_CR     cgemm3m_cr
#define   GEMM3M_RN     cgemm3m_rn
#define   GEMM3M_RT     cgemm3m_rt
#define   GEMM3M_RC     cgemm3m_rc
#define   GEMM3M_RR     cgemm3m_rr

#define   GEMM3M_THREAD_NN     cgemm3m_thread_nn
#define   GEMM3M_THREAD_CN     cgemm3m_thread_cn
#define   GEMM3M_THREAD_TN     cgemm3m_thread_tn
#define   GEMM3M_THREAD_NC     cgemm3m_thread_nc
#define   GEMM3M_THREAD_NT     cgemm3m_thread_nt
#define   GEMM3M_THREAD_CC     cgemm3m_thread_cc
#define   GEMM3M_THREAD_CT     cgemm3m_thread_ct
#define   GEMM3M_THREAD_TC     cgemm3m_thread_tc
#define   GEMM3M_THREAD_TT     cgemm3m_thread_tt
#define   GEMM3M_THREAD_NR     cgemm3m_thread_nr
#define   GEMM3M_THREAD_TR     cgemm3m_thread_tr
#define   GEMM3M_THREAD_CR     cgemm3m_thread_cr
#define   GEMM3M_THREAD_RN     cgemm3m_thread_rn
#define   GEMM3M_THREAD_RT     cgemm3m_thread_rt
#define   GEMM3M_THREAD_RC     cgemm3m_thread_rc
#define   GEMM3M_THREAD_RR     cgemm3m_thread_rr

#define   SYMM3M_ILCOPYB csymm3m_ilcopyb
#define   SYMM3M_IUCOPYB csymm3m_iucopyb
#define   SYMM3M_ILCOPYR csymm3m_ilcopyr
#define   SYMM3M_IUCOPYR csymm3m_iucopyr
#define   SYMM3M_ILCOPYI csymm3m_ilcopyi
#define   SYMM3M_IUCOPYI csymm3m_iucopyi

#define   SYMM3M_OLCOPYB csymm3m_olcopyb
#define   SYMM3M_OUCOPYB csymm3m_oucopyb
#define   SYMM3M_OLCOPYR csymm3m_olcopyr
#define   SYMM3M_OUCOPYR csymm3m_oucopyr
#define   SYMM3M_OLCOPYI csymm3m_olcopyi
#define   SYMM3M_OUCOPYI csymm3m_oucopyi

#define   HEMM3M_ILCOPYB chemm3m_ilcopyb
#define   HEMM3M_IUCOPYB chemm3m_iucopyb
#define   HEMM3M_ILCOPYR chemm3m_ilcopyr
#define   HEMM3M_IUCOPYR chemm3m_iucopyr
#define   HEMM3M_ILCOPYI chemm3m_ilcopyi
#define   HEMM3M_IUCOPYI chemm3m_iucopyi

#define   HEMM3M_OLCOPYB chemm3m_olcopyb
#define   HEMM3M_OUCOPYB chemm3m_oucopyb
#define   HEMM3M_OLCOPYR chemm3m_olcopyr
#define   HEMM3M_OUCOPYR chemm3m_oucopyr
#define   HEMM3M_OLCOPYI chemm3m_olcopyi
#define   HEMM3M_OUCOPYI chemm3m_oucopyi

#define	  SYMM_LU		csymm_LU
#define	  SYMM_LL		csymm_LL
#define	  SYMM_RU		csymm_RU
#define	  SYMM_RL		csymm_RL
#define	  SYMM3M_LU		csymm3m_LU
#define	  SYMM3M_LL		csymm3m_LL
#define	  SYMM3M_RU		csymm3m_RU
#define	  SYMM3M_RL		csymm3m_RL
#define	  HEMM3M_LU		chemm3m_LU
#define	  HEMM3M_LL		chemm3m_LL
#define	  HEMM3M_RU		chemm3m_RU
#define	  HEMM3M_RL		chemm3m_RL
#define	  SYMM_THREADED_LU	csymm_threaded_LU
#define	  SYMM_THREADED_LL	csymm_threaded_LL
#define	  SYMM_THREADED_RU	csymm_threaded_RU
#define	  SYMM_THREADED_RL	csymm_threaded_RL

#define	  HEMM_LU		chemm_LU
#define	  HEMM_LL		chemm_LL
#define	  HEMM_RU		chemm_RU
#define	  HEMM_RL		chemm_RL
#define	  HEMM_THREADED_LU	chemm_threaded_LU
#define	  HEMM_THREADED_LL	chemm_threaded_LL
#define	  HEMM_THREADED_RU	chemm_threaded_RU
#define	  HEMM_THREADED_RL	chemm_threaded_RL

#define TRMM_KERNEL_LN  ctrmm_kernel_LN
#define TRMM_KERNEL_LT  ctrmm_kernel_LT
#define TRMM_KERNEL_LR  ctrmm_kernel_LR
#define TRMM_KERNEL_LC  ctrmm_kernel_LC
#define TRMM_KERNEL_RN  ctrmm_kernel_RN
#define TRMM_KERNEL_RT  ctrmm_kernel_RT
#define TRMM_KERNEL_RR  ctrmm_kernel_RR
#define TRMM_KERNEL_RC  ctrmm_kernel_RC

#define TRSM_KERNEL_LN  ctrsm_kernel_LN
#define TRSM_KERNEL_LT  ctrsm_kernel_LT
#define TRSM_KERNEL_LR  ctrsm_kernel_LR
#define TRSM_KERNEL_LC  ctrsm_kernel_LC
#define TRSM_KERNEL_RN  ctrsm_kernel_RN
#define TRSM_KERNEL_RT  ctrsm_kernel_RT
#define TRSM_KERNEL_RR  ctrsm_kernel_RR
#define TRSM_KERNEL_RC  ctrsm_kernel_RC

#define TRMM_LNUU ctrmm_LNUU
#define TRMM_LNUN ctrmm_LNUN
#define TRMM_LNLU ctrmm_LNLU
#define TRMM_LNLN ctrmm_LNLN
#define TRMM_LTUU ctrmm_LTUU
#define TRMM_LTUN ctrmm_LTUN
#define TRMM_LTLU ctrmm_LTLU
#define TRMM_LTLN ctrmm_LTLN
#define TRMM_LRUU ctrmm_LRUU
#define TRMM_LRUN ctrmm_LRUN
#define TRMM_LRLU ctrmm_LRLU
#define TRMM_LRLN ctrmm_LRLN
#define TRMM_LCUU ctrmm_LCUU
#define TRMM_LCUN ctrmm_LCUN
#define TRMM_LCLU ctrmm_LCLU
#define TRMM_LCLN ctrmm_LCLN

#define TRMM_RNUU ctrmm_RNUU
#define TRMM_RNUN ctrmm_RNUN
#define TRMM_RNLU ctrmm_RNLU
#define TRMM_RNLN ctrmm_RNLN
#define TRMM_RTUU ctrmm_RTUU
#define TRMM_RTUN ctrmm_RTUN
#define TRMM_RTLU ctrmm_RTLU
#define TRMM_RTLN ctrmm_RTLN
#define TRMM_RRUU ctrmm_RRUU
#define TRMM_RRUN ctrmm_RRUN
#define TRMM_RRLU ctrmm_RRLU
#define TRMM_RRLN ctrmm_RRLN
#define TRMM_RCUU ctrmm_RCUU
#define TRMM_RCUN ctrmm_RCUN
#define TRMM_RCLU ctrmm_RCLU
#define TRMM_RCLN ctrmm_RCLN

#define TRSM_LNUU ctrsm_LNUU
#define TRSM_LNUN ctrsm_LNUN
#define TRSM_LNLU ctrsm_LNLU
#define TRSM_LNLN ctrsm_LNLN
#define TRSM_LTUU ctrsm_LTUU
#define TRSM_LTUN ctrsm_LTUN
#define TRSM_LTLU ctrsm_LTLU
#define TRSM_LTLN ctrsm_LTLN
#define TRSM_LRUU ctrsm_LRUU
#define TRSM_LRUN ctrsm_LRUN
#define TRSM_LRLU ctrsm_LRLU
#define TRSM_LRLN ctrsm_LRLN
#define TRSM_LCUU ctrsm_LCUU
#define TRSM_LCUN ctrsm_LCUN
#define TRSM_LCLU ctrsm_LCLU
#define TRSM_LCLN ctrsm_LCLN

#define TRSM_RNUU ctrsm_RNUU
#define TRSM_RNUN ctrsm_RNUN
#define TRSM_RNLU ctrsm_RNLU
#define TRSM_RNLN ctrsm_RNLN
#define TRSM_RTUU ctrsm_RTUU
#define TRSM_RTUN ctrsm_RTUN
#define TRSM_RTLU ctrsm_RTLU
#define TRSM_RTLN ctrsm_RTLN
#define TRSM_RRUU ctrsm_RRUU
#define TRSM_RRUN ctrsm_RRUN
#define TRSM_RRLU ctrsm_RRLU
#define TRSM_RRLN ctrsm_RRLN
#define TRSM_RCUU ctrsm_RCUU
#define TRSM_RCUN ctrsm_RCUN
#define TRSM_RCLU ctrsm_RCLU
#define TRSM_RCLN ctrsm_RCLN

#define  SYRK_UN   csyrk_UN
#define  SYRK_UT   csyrk_UT
#define  SYRK_LN   csyrk_LN
#define  SYRK_LT   csyrk_LT
#define  SYRK_UR   csyrk_UR
#define  SYRK_UC   csyrk_UC
#define  SYRK_LR   csyrk_LR
#define  SYRK_LC   csyrk_LC

#define  HERK_UN   cherk_UN
#define  HERK_UT   cherk_UT
#define  HERK_LN   cherk_LN
#define  HERK_LT   cherk_LT
#define  HERK_UR   cherk_UR
#define  HERK_UC   cherk_UC
#define  HERK_LR   cherk_LR
#define  HERK_LC   cherk_LC

#define SYRK_KERNEL_U csyrk_kernel_U
#define SYRK_KERNEL_L csyrk_kernel_L

#define  SYR2K_UN  csyr2k_UN
#define  SYR2K_UT  csyr2k_UT
#define  SYR2K_LN  csyr2k_LN
#define  SYR2K_LT  csyr2k_LT
#define  SYR2K_UR  csyr2k_UR
#define  SYR2K_UC  csyr2k_UC
#define  SYR2K_LR  csyr2k_LR
#define  SYR2K_LC  csyr2k_LC

#define  SYMCOPY_L csymcopy_L
#define  SYMCOPY_U csymcopy_U
#define  HEMCOPY_L chemcopy_L
#define  HEMCOPY_U chemcopy_U
#endif
#endif

#ifdef UNIT
#ifndef COMPLEX
#ifdef XDOUBLE
#define TRMM_IUNCOPY qtrmm_iunucopy
#define TRMM_IUTCOPY qtrmm_iutucopy
#define TRMM_ILNCOPY qtrmm_ilnucopy
#define TRMM_ILTCOPY qtrmm_iltucopy
#define TRMM_OUNCOPY qtrmm_ounucopy
#define TRMM_OUTCOPY qtrmm_outucopy
#define TRMM_OLNCOPY qtrmm_olnucopy
#define TRMM_OLTCOPY qtrmm_oltucopy

#define TRSM_IUNCOPY qtrsm_iunucopy
#define TRSM_IUTCOPY qtrsm_iutucopy
#define TRSM_ILNCOPY qtrsm_ilnucopy
#define TRSM_ILTCOPY qtrsm_iltucopy
#define TRSM_OUNCOPY qtrsm_ounucopy
#define TRSM_OUTCOPY qtrsm_outucopy
#define TRSM_OLNCOPY qtrsm_olnucopy
#define TRSM_OLTCOPY qtrsm_oltucopy
#elif defined(DOUBLE)
#define TRMM_IUNCOPY dtrmm_iunucopy
#define TRMM_IUTCOPY dtrmm_iutucopy
#define TRMM_ILNCOPY dtrmm_ilnucopy
#define TRMM_ILTCOPY dtrmm_iltucopy
#define TRMM_OUNCOPY dtrmm_ounucopy
#define TRMM_OUTCOPY dtrmm_outucopy
#define TRMM_OLNCOPY dtrmm_olnucopy
#define TRMM_OLTCOPY dtrmm_oltucopy

#define TRSM_IUNCOPY dtrsm_iunucopy
#define TRSM_IUTCOPY dtrsm_iutucopy
#define TRSM_ILNCOPY dtrsm_ilnucopy
#define TRSM_ILTCOPY dtrsm_iltucopy
#define TRSM_OUNCOPY dtrsm_ounucopy
#define TRSM_OUTCOPY dtrsm_outucopy
#define TRSM_OLNCOPY dtrsm_olnucopy
#define TRSM_OLTCOPY dtrsm_oltucopy
#else
#define TRMM_IUNCOPY strmm_iunucopy
#define TRMM_IUTCOPY strmm_iutucopy
#define TRMM_ILNCOPY strmm_ilnucopy
#define TRMM_ILTCOPY strmm_iltucopy
#define TRMM_OUNCOPY strmm_ounucopy
#define TRMM_OUTCOPY strmm_outucopy
#define TRMM_OLNCOPY strmm_olnucopy
#define TRMM_OLTCOPY strmm_oltucopy

#define TRSM_IUNCOPY strsm_iunucopy
#define TRSM_IUTCOPY strsm_iutucopy
#define TRSM_ILNCOPY strsm_ilnucopy
#define TRSM_ILTCOPY strsm_iltucopy
#define TRSM_OUNCOPY strsm_ounucopy
#define TRSM_OUTCOPY strsm_outucopy
#define TRSM_OLNCOPY strsm_olnucopy
#define TRSM_OLTCOPY strsm_oltucopy
#endif
#else
#ifdef XDOUBLE
#define TRMM_IUNCOPY xtrmm_iunucopy
#define TRMM_IUTCOPY xtrmm_iutucopy
#define TRMM_ILNCOPY xtrmm_ilnucopy
#define TRMM_ILTCOPY xtrmm_iltucopy
#define TRMM_OUNCOPY xtrmm_ounucopy
#define TRMM_OUTCOPY xtrmm_outucopy
#define TRMM_OLNCOPY xtrmm_olnucopy
#define TRMM_OLTCOPY xtrmm_oltucopy

#define TRSM_IUNCOPY xtrsm_iunucopy
#define TRSM_IUTCOPY xtrsm_iutucopy
#define TRSM_ILNCOPY xtrsm_ilnucopy
#define TRSM_ILTCOPY xtrsm_iltucopy
#define TRSM_OUNCOPY xtrsm_ounucopy
#define TRSM_OUTCOPY xtrsm_outucopy
#define TRSM_OLNCOPY xtrsm_olnucopy
#define TRSM_OLTCOPY xtrsm_oltucopy
#elif defined(DOUBLE)
#define TRMM_IUNCOPY ztrmm_iunucopy
#define TRMM_IUTCOPY ztrmm_iutucopy
#define TRMM_ILNCOPY ztrmm_ilnucopy
#define TRMM_ILTCOPY ztrmm_iltucopy
#define TRMM_OUNCOPY ztrmm_ounucopy
#define TRMM_OUTCOPY ztrmm_outucopy
#define TRMM_OLNCOPY ztrmm_olnucopy
#define TRMM_OLTCOPY ztrmm_oltucopy

#define TRSM_IUNCOPY ztrsm_iunucopy
#define TRSM_IUTCOPY ztrsm_iutucopy
#define TRSM_ILNCOPY ztrsm_ilnucopy
#define TRSM_ILTCOPY ztrsm_iltucopy
#define TRSM_OUNCOPY ztrsm_ounucopy
#define TRSM_OUTCOPY ztrsm_outucopy
#define TRSM_OLNCOPY ztrsm_olnucopy
#define TRSM_OLTCOPY ztrsm_oltucopy
#else
#define TRMM_IUNCOPY ctrmm_iunucopy
#define TRMM_IUTCOPY ctrmm_iutucopy
#define TRMM_ILNCOPY ctrmm_ilnucopy
#define TRMM_ILTCOPY ctrmm_iltucopy
#define TRMM_OUNCOPY ctrmm_ounucopy
#define TRMM_OUTCOPY ctrmm_outucopy
#define TRMM_OLNCOPY ctrmm_olnucopy
#define TRMM_OLTCOPY ctrmm_oltucopy

#define TRSM_IUNCOPY ctrsm_iunucopy
#define TRSM_IUTCOPY ctrsm_iutucopy
#define TRSM_ILNCOPY ctrsm_ilnucopy
#define TRSM_ILTCOPY ctrsm_iltucopy
#define TRSM_OUNCOPY ctrsm_ounucopy
#define TRSM_OUTCOPY ctrsm_outucopy
#define TRSM_OLNCOPY ctrsm_olnucopy
#define TRSM_OLTCOPY ctrsm_oltucopy
#endif
#endif
#else
#ifndef COMPLEX
#ifdef XDOUBLE
#define TRMM_IUNCOPY qtrmm_iunncopy
#define TRMM_IUTCOPY qtrmm_iutncopy
#define TRMM_ILNCOPY qtrmm_ilnncopy
#define TRMM_ILTCOPY qtrmm_iltncopy
#define TRMM_OUNCOPY qtrmm_ounncopy
#define TRMM_OUTCOPY qtrmm_outncopy
#define TRMM_OLNCOPY qtrmm_olnncopy
#define TRMM_OLTCOPY qtrmm_oltncopy

#define TRSM_IUNCOPY qtrsm_iunncopy
#define TRSM_IUTCOPY qtrsm_iutncopy
#define TRSM_ILNCOPY qtrsm_ilnncopy
#define TRSM_ILTCOPY qtrsm_iltncopy
#define TRSM_OUNCOPY qtrsm_ounncopy
#define TRSM_OUTCOPY qtrsm_outncopy
#define TRSM_OLNCOPY qtrsm_olnncopy
#define TRSM_OLTCOPY qtrsm_oltncopy
#elif defined(DOUBLE)
#define TRMM_IUNCOPY dtrmm_iunncopy
#define TRMM_IUTCOPY dtrmm_iutncopy
#define TRMM_ILNCOPY dtrmm_ilnncopy
#define TRMM_ILTCOPY dtrmm_iltncopy
#define TRMM_OUNCOPY dtrmm_ounncopy
#define TRMM_OUTCOPY dtrmm_outncopy
#define TRMM_OLNCOPY dtrmm_olnncopy
#define TRMM_OLTCOPY dtrmm_oltncopy

#define TRSM_IUNCOPY dtrsm_iunncopy
#define TRSM_IUTCOPY dtrsm_iutncopy
#define TRSM_ILNCOPY dtrsm_ilnncopy
#define TRSM_ILTCOPY dtrsm_iltncopy
#define TRSM_OUNCOPY dtrsm_ounncopy
#define TRSM_OUTCOPY dtrsm_outncopy
#define TRSM_OLNCOPY dtrsm_olnncopy
#define TRSM_OLTCOPY dtrsm_oltncopy
#else
#define TRMM_IUNCOPY strmm_iunncopy
#define TRMM_IUTCOPY strmm_iutncopy
#define TRMM_ILNCOPY strmm_ilnncopy
#define TRMM_ILTCOPY strmm_iltncopy
#define TRMM_OUNCOPY strmm_ounncopy
#define TRMM_OUTCOPY strmm_outncopy
#define TRMM_OLNCOPY strmm_olnncopy
#define TRMM_OLTCOPY strmm_oltncopy

#define TRSM_IUNCOPY strsm_iunncopy
#define TRSM_IUTCOPY strsm_iutncopy
#define TRSM_ILNCOPY strsm_ilnncopy
#define TRSM_ILTCOPY strsm_iltncopy
#define TRSM_OUNCOPY strsm_ounncopy
#define TRSM_OUTCOPY strsm_outncopy
#define TRSM_OLNCOPY strsm_olnncopy
#define TRSM_OLTCOPY strsm_oltncopy
#endif
#else
#ifdef XDOUBLE
#define TRMM_IUNCOPY xtrmm_iunncopy
#define TRMM_IUTCOPY xtrmm_iutncopy
#define TRMM_ILNCOPY xtrmm_ilnncopy
#define TRMM_ILTCOPY xtrmm_iltncopy
#define TRMM_OUNCOPY xtrmm_ounncopy
#define TRMM_OUTCOPY xtrmm_outncopy
#define TRMM_OLNCOPY xtrmm_olnncopy
#define TRMM_OLTCOPY xtrmm_oltncopy

#define TRSM_IUNCOPY xtrsm_iunncopy
#define TRSM_IUTCOPY xtrsm_iutncopy
#define TRSM_ILNCOPY xtrsm_ilnncopy
#define TRSM_ILTCOPY xtrsm_iltncopy
#define TRSM_OUNCOPY xtrsm_ounncopy
#define TRSM_OUTCOPY xtrsm_outncopy
#define TRSM_OLNCOPY xtrsm_olnncopy
#define TRSM_OLTCOPY xtrsm_oltncopy
#elif defined(DOUBLE)
#define TRMM_IUNCOPY ztrmm_iunncopy
#define TRMM_IUTCOPY ztrmm_iutncopy
#define TRMM_ILNCOPY ztrmm_ilnncopy
#define TRMM_ILTCOPY ztrmm_iltncopy
#define TRMM_OUNCOPY ztrmm_ounncopy
#define TRMM_OUTCOPY ztrmm_outncopy
#define TRMM_OLNCOPY ztrmm_olnncopy
#define TRMM_OLTCOPY ztrmm_oltncopy

#define TRSM_IUNCOPY ztrsm_iunncopy
#define TRSM_IUTCOPY ztrsm_iutncopy
#define TRSM_ILNCOPY ztrsm_ilnncopy
#define TRSM_ILTCOPY ztrsm_iltncopy
#define TRSM_OUNCOPY ztrsm_ounncopy
#define TRSM_OUTCOPY ztrsm_outncopy
#define TRSM_OLNCOPY ztrsm_olnncopy
#define TRSM_OLTCOPY ztrsm_oltncopy
#else
#define TRMM_IUNCOPY ctrmm_iunncopy
#define TRMM_IUTCOPY ctrmm_iutncopy
#define TRMM_ILNCOPY ctrmm_ilnncopy
#define TRMM_ILTCOPY ctrmm_iltncopy
#define TRMM_OUNCOPY ctrmm_ounncopy
#define TRMM_OUTCOPY ctrmm_outncopy
#define TRMM_OLNCOPY ctrmm_olnncopy
#define TRMM_OLTCOPY ctrmm_oltncopy

#define TRSM_IUNCOPY ctrsm_iunncopy
#define TRSM_IUTCOPY ctrsm_iutncopy
#define TRSM_ILNCOPY ctrsm_ilnncopy
#define TRSM_ILTCOPY ctrsm_iltncopy
#define TRSM_OUNCOPY ctrsm_ounncopy
#define TRSM_OUTCOPY ctrsm_outncopy
#define TRSM_OLNCOPY ctrsm_olnncopy
#define TRSM_OLTCOPY ctrsm_oltncopy
#endif
#endif
#endif

#if GEMM_UNROLL_M == GEMM_UNROLL_N
#undef  TRMM_IUNCOPY
#undef  TRMM_IUTCOPY
#undef  TRMM_ILNCOPY
#undef  TRMM_ILTCOPY
#define TRMM_IUNCOPY TRMM_OUNCOPY
#define TRMM_IUTCOPY TRMM_OUTCOPY
#define TRMM_ILNCOPY TRMM_OLNCOPY
#define TRMM_ILTCOPY TRMM_OLTCOPY

#undef  TRSM_IUNCOPY
#undef  TRSM_IUTCOPY
#undef  TRSM_ILNCOPY
#undef  TRSM_ILTCOPY
#define TRSM_IUNCOPY TRSM_OUNCOPY
#define TRSM_IUTCOPY TRSM_OUTCOPY
#define TRSM_ILNCOPY TRSM_OLNCOPY
#define TRSM_ILTCOPY TRSM_OLTCOPY
#endif

#endif
