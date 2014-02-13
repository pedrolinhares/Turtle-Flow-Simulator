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

#ifndef COMMON_LEVEL2
#define COMMON_LEVEL2

#ifndef ASSEMBLER

/* Level 2 Blas routines */

int sger_k (BLASLONG, BLASLONG, BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int dger_k (BLASLONG, BLASLONG, BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int qger_k (BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int cgeru_k(BLASLONG, BLASLONG, BLASLONG,
	      float, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int cgerc_k(BLASLONG, BLASLONG, BLASLONG,
	      float, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int zgeru_k(BLASLONG, BLASLONG, BLASLONG,
	      double, double,  double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int zgerc_k(BLASLONG, BLASLONG, BLASLONG,
	      double, double,  double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int xgeru_k(BLASLONG, BLASLONG, BLASLONG,
	      xdouble, xdouble,  xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xgerc_k(BLASLONG, BLASLONG, BLASLONG,
	      xdouble, xdouble,  xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

void sgemv_n(BLASLONG, BLASLONG, BLASLONG, float, 
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void sgemv_t(BLASLONG, BLASLONG, BLASLONG, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void dgemv_n(BLASLONG, BLASLONG, BLASLONG, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void dgemv_t(BLASLONG, BLASLONG, BLASLONG, double, 
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void qgemv_n(BLASLONG, BLASLONG, BLASLONG, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void qgemv_t(BLASLONG, BLASLONG, BLASLONG, xdouble, 
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);

void cgemv_n(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_t(BLASLONG, BLASLONG, BLASLONG, float, float, 
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_r(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_c(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_o(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_u(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_s(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgemv_d(BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);

void zgemv_n(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_t(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_r(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_c(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_o(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_u(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_s(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgemv_d(BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);

void xgemv_n(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_t(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_r(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_c(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_o(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_u(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_s(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgemv_d(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);

int strsv_NUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_NUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_NLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_NLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_TUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_TUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_TLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strsv_TLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int dtrsv_NUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_NUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_NLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_NLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_TUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_TUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_TLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrsv_TLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int qtrsv_NUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_NUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_NLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_NLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_TUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_TUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_TLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrsv_TLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ctrsv_NUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_NUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_NLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_NLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_TUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_TUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_TLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_TLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_RUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_RUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_RLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_RLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_CUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_CUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_CLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrsv_CLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int ztrsv_NUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_NUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_NLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_NLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_TUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_TUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_TLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_TLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_RUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_RUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_RLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_RLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_CUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_CUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_CLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrsv_CLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int xtrsv_NUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_NUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_NLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_NLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_TUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_TUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_TLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_TLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_RUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_RUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_RLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_RLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_CUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_CUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_CLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrsv_CLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int strmv_NUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_NUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_NLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_NLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_TUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_TUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_TLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int strmv_TLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int dtrmv_NUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_NUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_NLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_NLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_TUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_TUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_TLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtrmv_TLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int qtrmv_NUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_NUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_NLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_NLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_TUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_TUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_TLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtrmv_TLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ctrmv_NUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_NUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_NLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_NLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_TUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_TUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_TLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_TLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_RUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_RUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_RLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_RLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_CUU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_CUN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_CLU(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctrmv_CLN(BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int ztrmv_NUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_NUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_NLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_NLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_TUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_TUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_TLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_TLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_RUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_RUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_RLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_RLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_CUU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_CUN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_CLU(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztrmv_CLN(BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int xtrmv_NUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_NUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_NLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_NLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_TUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_TUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_TLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_TLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_RUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_RUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_RLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_RLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_CUU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_CUN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_CLU(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtrmv_CLN(BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int stpsv_NUU(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_NUN(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_NLU(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_NLN(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_TUU(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_TUN(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_TLU(BLASLONG, float *, float *, BLASLONG, void *);
int stpsv_TLN(BLASLONG, float *, float *, BLASLONG, void *);

int dtpsv_NUU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_NUN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_NLU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_NLN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_TUU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_TUN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_TLU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpsv_TLN(BLASLONG, double *, double *, BLASLONG, void *);

int qtpsv_NUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_NUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_NLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_NLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_TUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_TUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_TLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpsv_TLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);

int ctpsv_NUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_NUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_NLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_NLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_TUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_TUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_TLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_TLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_RUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_RUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_RLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_RLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_CUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_CUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_CLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpsv_CLN(BLASLONG, float *, float *, BLASLONG, void *);

int ztpsv_NUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_NUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_NLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_NLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_TUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_TUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_TLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_TLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_RUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_RUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_RLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_RLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_CUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_CUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_CLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpsv_CLN(BLASLONG, double *, double *, BLASLONG, void *);

int xtpsv_NUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_NUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_NLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_NLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_TUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_TUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_TLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_TLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_RUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_RUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_RLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_RLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_CUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_CUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_CLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpsv_CLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);

int stpmv_NUU(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_NUN(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_NLU(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_NLN(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_TUU(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_TUN(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_TLU(BLASLONG, float *, float *, BLASLONG, void *);
int stpmv_TLN(BLASLONG, float *, float *, BLASLONG, void *);

int dtpmv_NUU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_NUN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_NLU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_NLN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_TUU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_TUN(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_TLU(BLASLONG, double *, double *, BLASLONG, void *);
int dtpmv_TLN(BLASLONG, double *, double *, BLASLONG, void *);

int qtpmv_NUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_NUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_NLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_NLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_TUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_TUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_TLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int qtpmv_TLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);

int ctpmv_NUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_NUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_NLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_NLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_TUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_TUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_TLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_TLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_RUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_RUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_RLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_RLN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_CUU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_CUN(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_CLU(BLASLONG, float *, float *, BLASLONG, void *);
int ctpmv_CLN(BLASLONG, float *, float *, BLASLONG, void *);

int ztpmv_NUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_NUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_NLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_NLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_TUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_TUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_TLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_TLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_RUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_RUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_RLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_RLN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_CUU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_CUN(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_CLU(BLASLONG, double *, double *, BLASLONG, void *);
int ztpmv_CLN(BLASLONG, double *, double *, BLASLONG, void *);

int xtpmv_NUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_NUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_NLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_NLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_TUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_TUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_TLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_TLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_RUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_RUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_RLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_RLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_CUU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_CUN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_CLU(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);
int xtpmv_CLN(BLASLONG, xdouble *, xdouble *, BLASLONG, void *);

int ssymv_L(BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int ssymv_U(BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int dsymv_L(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int dsymv_U(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int qsymv_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int qsymv_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int csymv_L(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int csymv_U(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int zsymv_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int zsymv_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int xsymv_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xsymv_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int sspmv_L(BLASLONG, float,  float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int sspmv_U(BLASLONG, float,  float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int dspmv_L(BLASLONG, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int dspmv_U(BLASLONG, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int qspmv_L(BLASLONG, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qspmv_U(BLASLONG, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int cspmv_L(BLASLONG, float,  float, float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int cspmv_U(BLASLONG, float,  float, float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int zspmv_L(BLASLONG, double, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int zspmv_U(BLASLONG, double, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int xspmv_L(BLASLONG, xdouble, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xspmv_U(BLASLONG, xdouble, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ssyr_L(BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float *);
int ssyr_U(BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float *);
int dsyr_L(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *);
int dsyr_U(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *);
int qsyr_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int qsyr_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int csyr_L(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float *);
int csyr_U(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float *);
int zsyr_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *);
int zsyr_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *);
int xsyr_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xsyr_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int ssyr2_L(BLASLONG, float,  float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int ssyr2_U(BLASLONG, float,  float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int dsyr2_L(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int dsyr2_U(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int qsyr2_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int qsyr2_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int csyr2_L(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int csyr2_U(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int zsyr2_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int zsyr2_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int xsyr2_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xsyr2_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int sspr_L(BLASLONG, float,  float  *, BLASLONG, float  *, float *);
int sspr_U(BLASLONG, float,  float  *, BLASLONG, float  *, float *);
int dspr_L(BLASLONG, double, double *, BLASLONG, double *, double *);
int dspr_U(BLASLONG, double, double *, BLASLONG, double *, double *);
int qspr_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);
int qspr_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);
int cspr_L(BLASLONG, float,  float, float  *, BLASLONG, float  *, float *);
int cspr_U(BLASLONG, float,  float, float  *, BLASLONG, float  *, float *);
int zspr_L(BLASLONG, double, double, double *, BLASLONG, double *, double *);
int zspr_U(BLASLONG, double, double, double *, BLASLONG, double *, double *);
int xspr_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);
int xspr_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);

int sspr2_L(BLASLONG, float,  float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int sspr2_U(BLASLONG, float,  float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int dspr2_L(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int dspr2_U(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int qspr2_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);
int qspr2_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);
int cspr2_L(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int cspr2_U(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int zspr2_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int zspr2_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int xspr2_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);
int xspr2_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);

int cher_L(BLASLONG, float, float  *, BLASLONG, float  *, BLASLONG, float *);
int cher_U(BLASLONG, float, float  *, BLASLONG, float  *, BLASLONG, float *);
int zher_L(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *);
int zher_U(BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *);
int xher_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xher_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int cher2_L(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int cher2_U(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, BLASLONG, float *);
int zher2_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int zher2_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int xher2_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xher2_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int chpr_L(BLASLONG, float, float  *, BLASLONG, float  *, float *);
int chpr_U(BLASLONG, float, float  *, BLASLONG, float  *, float *);
int zhpr_L(BLASLONG, double, double *, BLASLONG, double *, double *);
int zhpr_U(BLASLONG, double, double *, BLASLONG, double *, double *);
int xhpr_L(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);
int xhpr_U(BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, xdouble *);

int chpr2_L(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int chpr2_U(BLASLONG, float,  float, float  *, BLASLONG, float *, BLASLONG, float  *, float *);
int zhpr2_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int zhpr2_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, double *);
int xhpr2_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);
int xhpr2_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, xdouble *);

int chemv_L(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int chemv_U(BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, float *);
int zhemv_L(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int zhemv_U(BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, double *);
int xhemv_L(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);
int xhemv_U(BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *);

int chpmv_L(BLASLONG, float,  float, float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int chpmv_U(BLASLONG, float,  float, float  *, float  *, BLASLONG, float  *, BLASLONG, void *);
int zhpmv_L(BLASLONG, double, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int zhpmv_U(BLASLONG, double, double, double *, double *, BLASLONG, double *, BLASLONG, void *);
int xhpmv_L(BLASLONG, xdouble, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xhpmv_U(BLASLONG, xdouble, xdouble, xdouble *, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ssbmv_L(BLASLONG, BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int ssbmv_U(BLASLONG, BLASLONG, float,  float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int dsbmv_L(BLASLONG, BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dsbmv_U(BLASLONG, BLASLONG, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int qsbmv_L(BLASLONG, BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qsbmv_U(BLASLONG, BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int csbmv_L(BLASLONG, BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int csbmv_U(BLASLONG, BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int zsbmv_L(BLASLONG, BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int zsbmv_U(BLASLONG, BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int xsbmv_L(BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xsbmv_U(BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int chbmv_L(BLASLONG, BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int chbmv_U(BLASLONG, BLASLONG, float,  float, float  *, BLASLONG, float  *, BLASLONG, float  *, BLASLONG, void *);
int zhbmv_L(BLASLONG, BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int zhbmv_U(BLASLONG, BLASLONG, double, double, double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int xhbmv_L(BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xhbmv_U(BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int snorm_n(BLASLONG, BLASLONG, float  *a, BLASLONG);
int snorm_t(BLASLONG, BLASLONG, float  *a, BLASLONG);
int dnorm_n(BLASLONG, BLASLONG, double *a, BLASLONG);
int dnorm_t(BLASLONG, BLASLONG, double *a, BLASLONG);
int cnorm_n(BLASLONG, BLASLONG, float  *a, BLASLONG);
int cnorm_t(BLASLONG, BLASLONG, float  *a, BLASLONG);
int znorm_n(BLASLONG, BLASLONG, double *a, BLASLONG);
int znorm_t(BLASLONG, BLASLONG, double *a, BLASLONG);

void sgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, 
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void sgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);

void dgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void dgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, 
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);

void qgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void qgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, 
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);

void cgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float, 
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_r(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_c(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_o(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_u(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_s(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void cgbmv_d(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);

void zgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_r(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_c(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_o(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_u(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_s(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void zgbmv_d(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);

void xgbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_r(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_c(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_o(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_u(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_s(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void xgbmv_d(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);

void ssbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float, 
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);
void ssbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, float,
		 float *, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *buffer);

void dsbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double,
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);
void dsbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, double, 
		 double *, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *buffer);

void qsbmv_n(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble,
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);
void qsbmv_t(BLASLONG, BLASLONG, BLASLONG, BLASLONG, xdouble, 
		 xdouble *, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *buffer);

int stbmv_NUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_NUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_NLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_NLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_TUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_TUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_TLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbmv_TLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int dtbmv_NUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_NUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_NLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_NLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_TUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_TUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_TLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbmv_TLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int qtbmv_NUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_NUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_NLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_NLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_TUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_TUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_TLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbmv_TLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ctbmv_NUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_NUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_NLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_NLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_TUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_TUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_TLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_TLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_RUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_RUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_RLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_RLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_CUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_CUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_CLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbmv_CLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int ztbmv_NUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_NUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_NLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_NLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_TUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_TUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_TLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_TLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_RUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_RUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_RLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_RLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_CUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_CUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_CLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbmv_CLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int xtbmv_NUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_NUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_NLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_NLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_TUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_TUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_TLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_TLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_RUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_RUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_RLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_RLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_CUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_CUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_CLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbmv_CLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int stbsv_NUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_NUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_NLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_NLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_TUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_TUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_TLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int stbsv_TLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int dtbsv_NUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_NUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_NLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_NLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_TUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_TUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_TLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int dtbsv_TLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int qtbsv_NUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_NUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_NLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_NLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_TUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_TUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_TLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int qtbsv_TLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);

int ctbsv_NUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_NUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_NLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_NLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_TUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_TUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_TLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_TLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_RUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_RUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_RLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_RLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_CUU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_CUN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_CLU(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);
int ctbsv_CLN(BLASLONG, BLASLONG, float *, BLASLONG, float *, BLASLONG, void *);

int ztbsv_NUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_NUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_NLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_NLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_TUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_TUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_TLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_TLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_RUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_RUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_RLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_RLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_CUU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_CUN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_CLU(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);
int ztbsv_CLN(BLASLONG, BLASLONG, double *, BLASLONG, double *, BLASLONG, void *);

int xtbsv_NUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_NUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_NLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_NLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_TUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_TUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_TLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_TLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_RUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_RUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_RLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_RLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_CUU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_CUN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_CLU(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);
int xtbsv_CLN(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *, BLASLONG, void *);


#ifdef XDOUBLE

#define GEMV_NCOPY      qgemv_ncopy
#define GEMV_TCOPY      qgemv_tcopy
#define GEMV_KERNEL     qgemv_kernel

#define GEMV_N    qgemv_n
#define GEMV_T    qgemv_t
#define ZGEMV_N   xgemv_n
#define ZGEMV_T   xgemv_t
#define ZGEMV_R   xgemv_r
#define ZGEMV_C   xgemv_c
#define ZGEMV_O   xgemv_o
#define ZGEMV_U   xgemv_u
#define ZGEMV_S   xgemv_s
#define ZGEMV_D   xgemv_d

#define GER_K      qger_k
#define ZGERU_K   xgeru_k
#define ZGERC_K   xgerc_k

#define TRSV_NUU qtrsv_NUU
#define TRSV_NUN qtrsv_NUN
#define TRSV_NLU qtrsv_NLU
#define TRSV_NLN qtrsv_NLN
#define TRSV_TUU qtrsv_TUU
#define TRSV_TUN qtrsv_TUN
#define TRSV_TLU qtrsv_TLU
#define TRSV_TLN qtrsv_TLN

#define ZTRSV_NUU xtrsv_NUU
#define ZTRSV_NUN xtrsv_NUN
#define ZTRSV_NLU xtrsv_NLU
#define ZTRSV_NLN xtrsv_NLN
#define ZTRSV_TUU xtrsv_TUU
#define ZTRSV_TUN xtrsv_TUN
#define ZTRSV_TLU xtrsv_TLU
#define ZTRSV_TLN xtrsv_TLN
#define ZTRSV_RUU xtrsv_RUU
#define ZTRSV_RUN xtrsv_RUN
#define ZTRSV_RLU xtrsv_RLU
#define ZTRSV_RLN xtrsv_RLN
#define ZTRSV_CUU xtrsv_CUU
#define ZTRSV_CUN xtrsv_CUN
#define ZTRSV_CLU xtrsv_CLU
#define ZTRSV_CLN xtrsv_CLN

#define TRMV_NUU qtrmv_NUU
#define TRMV_NUN qtrmv_NUN
#define TRMV_NLU qtrmv_NLU
#define TRMV_NLN qtrmv_NLN
#define TRMV_TUU qtrmv_TUU
#define TRMV_TUN qtrmv_TUN
#define TRMV_TLU qtrmv_TLU
#define TRMV_TLN qtrmv_TLN

#define ZTRMV_NUU xtrmv_NUU
#define ZTRMV_NUN xtrmv_NUN
#define ZTRMV_NLU xtrmv_NLU
#define ZTRMV_NLN xtrmv_NLN
#define ZTRMV_TUU xtrmv_TUU
#define ZTRMV_TUN xtrmv_TUN
#define ZTRMV_TLU xtrmv_TLU
#define ZTRMV_TLN xtrmv_TLN
#define ZTRMV_RUU xtrmv_RUU
#define ZTRMV_RUN xtrmv_RUN
#define ZTRMV_RLU xtrmv_RLU
#define ZTRMV_RLN xtrmv_RLN
#define ZTRMV_CUU xtrmv_CUU
#define ZTRMV_CUN xtrmv_CUN
#define ZTRMV_CLU xtrmv_CLU
#define ZTRMV_CLN xtrmv_CLN

#elif defined(DOUBLE)

#define GEMV_NCOPY      dgemv_ncopy
#define GEMV_TCOPY      dgemv_tcopy
#define GEMV_KERNEL     dgemv_kernel

#define GEMV_N    dgemv_n
#define GEMV_T    dgemv_t
#define ZGEMV_N   zgemv_n
#define ZGEMV_T   zgemv_t
#define ZGEMV_R   zgemv_r
#define ZGEMV_C   zgemv_c
#define ZGEMV_O   zgemv_o
#define ZGEMV_U   zgemv_u
#define ZGEMV_S   zgemv_s
#define ZGEMV_D   zgemv_d

#define GER_K      dger_k
#define ZGERU_K   zgeru_k
#define ZGERC_K   zgerc_k

#define TRSV_NUU dtrsv_NUU
#define TRSV_NUN dtrsv_NUN
#define TRSV_NLU dtrsv_NLU
#define TRSV_NLN dtrsv_NLN
#define TRSV_TUU dtrsv_TUU
#define TRSV_TUN dtrsv_TUN
#define TRSV_TLU dtrsv_TLU
#define TRSV_TLN dtrsv_TLN

#define ZTRSV_NUU ztrsv_NUU
#define ZTRSV_NUN ztrsv_NUN
#define ZTRSV_NLU ztrsv_NLU
#define ZTRSV_NLN ztrsv_NLN
#define ZTRSV_TUU ztrsv_TUU
#define ZTRSV_TUN ztrsv_TUN
#define ZTRSV_TLU ztrsv_TLU
#define ZTRSV_TLN ztrsv_TLN
#define ZTRSV_RUU ztrsv_RUU
#define ZTRSV_RUN ztrsv_RUN
#define ZTRSV_RLU ztrsv_RLU
#define ZTRSV_RLN ztrsv_RLN
#define ZTRSV_CUU ztrsv_CUU
#define ZTRSV_CUN ztrsv_CUN
#define ZTRSV_CLU ztrsv_CLU
#define ZTRSV_CLN ztrsv_CLN

#define TRMV_NUU dtrmv_NUU
#define TRMV_NUN dtrmv_NUN
#define TRMV_NLU dtrmv_NLU
#define TRMV_NLN dtrmv_NLN
#define TRMV_TUU dtrmv_TUU
#define TRMV_TUN dtrmv_TUN
#define TRMV_TLU dtrmv_TLU
#define TRMV_TLN dtrmv_TLN

#define ZTRMV_NUU ztrmv_NUU
#define ZTRMV_NUN ztrmv_NUN
#define ZTRMV_NLU ztrmv_NLU
#define ZTRMV_NLN ztrmv_NLN
#define ZTRMV_TUU ztrmv_TUU
#define ZTRMV_TUN ztrmv_TUN
#define ZTRMV_TLU ztrmv_TLU
#define ZTRMV_TLN ztrmv_TLN
#define ZTRMV_RUU ztrmv_RUU
#define ZTRMV_RUN ztrmv_RUN
#define ZTRMV_RLU ztrmv_RLU
#define ZTRMV_RLN ztrmv_RLN
#define ZTRMV_CUU ztrmv_CUU
#define ZTRMV_CUN ztrmv_CUN
#define ZTRMV_CLU ztrmv_CLU
#define ZTRMV_CLN ztrmv_CLN

#else

#define GEMV      sgemv_
#define ZGEMV_    cgemv_

#define GEMV_N    sgemv_n
#define GEMV_T    sgemv_t
#define ZGEMV_N   cgemv_n
#define ZGEMV_T   cgemv_t
#define ZGEMV_R   cgemv_r
#define ZGEMV_C   cgemv_c
#define ZGEMV_O   cgemv_o
#define ZGEMV_U   cgemv_u
#define ZGEMV_S   cgemv_s
#define ZGEMV_D   cgemv_d

#define GER_K     sger_k
#define ZGERU_K   cgeru_k
#define ZGERC_K   cgerc_k

#define TRSV_NUU strsv_NUU
#define TRSV_NUN strsv_NUN
#define TRSV_NLU strsv_NLU
#define TRSV_NLN strsv_NLN
#define TRSV_TUU strsv_TUU
#define TRSV_TUN strsv_TUN
#define TRSV_TLU strsv_TLU
#define TRSV_TLN strsv_TLN

#define ZTRSV_NUU ctrsv_NUU
#define ZTRSV_NUN ctrsv_NUN
#define ZTRSV_NLU ctrsv_NLU
#define ZTRSV_NLN ctrsv_NLN
#define ZTRSV_TUU ctrsv_TUU
#define ZTRSV_TUN ctrsv_TUN
#define ZTRSV_TLU ctrsv_TLU
#define ZTRSV_TLN ctrsv_TLN
#define ZTRSV_RUU ctrsv_RUU
#define ZTRSV_RUN ctrsv_RUN
#define ZTRSV_RLU ctrsv_RLU
#define ZTRSV_RLN ctrsv_RLN
#define ZTRSV_CUU ctrsv_CUU
#define ZTRSV_CUN ctrsv_CUN
#define ZTRSV_CLU ctrsv_CLU
#define ZTRSV_CLN ctrsv_CLN

#define TRMV_NUU strmv_NUU
#define TRMV_NUN strmv_NUN
#define TRMV_NLU strmv_NLU
#define TRMV_NLN strmv_NLN
#define TRMV_TUU strmv_TUU
#define TRMV_TUN strmv_TUN
#define TRMV_TLU strmv_TLU
#define TRMV_TLN strmv_TLN

#define ZTRMV_NUU ctrmv_NUU
#define ZTRMV_NUN ctrmv_NUN
#define ZTRMV_NLU ctrmv_NLU
#define ZTRMV_NLN ctrmv_NLN
#define ZTRMV_TUU ctrmv_TUU
#define ZTRMV_TUN ctrmv_TUN
#define ZTRMV_TLU ctrmv_TLU
#define ZTRMV_TLN ctrmv_TLN
#define ZTRMV_RUU ctrmv_RUU
#define ZTRMV_RUN ctrmv_RUN
#define ZTRMV_RLU ctrmv_RLU
#define ZTRMV_RLN ctrmv_RLN
#define ZTRMV_CUU ctrmv_CUU
#define ZTRMV_CUN ctrmv_CUN
#define ZTRMV_CLU ctrmv_CLU
#define ZTRMV_CLN ctrmv_CLN

#endif

#endif
#endif
