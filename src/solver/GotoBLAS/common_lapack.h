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

#ifndef COMMON_LAPACK
#define COMMON_LAPACK

#ifndef ASSEMBLER

/* Lapack Library */

blasint sgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xgetf2_k(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint sgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xgetrf_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint sgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xgetrf_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

int slaswp_plus (BLASLONG, BLASLONG, BLASLONG, float,   float   *, BLASLONG, float  *, BLASLONG, blasint *, BLASLONG);
int slaswp_minus(BLASLONG, BLASLONG, BLASLONG, float,   float   *, BLASLONG, float  *, BLASLONG, blasint *, BLASLONG);
int dlaswp_plus (BLASLONG, BLASLONG, BLASLONG, double,  double  *, BLASLONG, double *, BLASLONG, blasint *, BLASLONG);
int dlaswp_minus(BLASLONG, BLASLONG, BLASLONG, double,  double  *, BLASLONG, double *, BLASLONG, blasint *, BLASLONG);
int qlaswp_plus (BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, blasint *, BLASLONG);
int qlaswp_minus(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, blasint *, BLASLONG);

int claswp_plus (BLASLONG, BLASLONG, BLASLONG, float,   float,   float   *, BLASLONG, float   *, BLASLONG, blasint *, BLASLONG);
int claswp_minus(BLASLONG, BLASLONG, BLASLONG, float,   float,   float   *, BLASLONG, float   *, BLASLONG, blasint *, BLASLONG);
int zlaswp_plus (BLASLONG, BLASLONG, BLASLONG, double,  double,  double  *, BLASLONG, double  *, BLASLONG, blasint *, BLASLONG);
int zlaswp_minus(BLASLONG, BLASLONG, BLASLONG, double,  double,  double  *, BLASLONG, double  *, BLASLONG, blasint *, BLASLONG);
int xlaswp_plus (BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, blasint *, BLASLONG);
int xlaswp_minus(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble, xdouble *, BLASLONG, xdouble *, BLASLONG, blasint *, BLASLONG);

int slaswp_ncopy(BLASLONG, BLASLONG, BLASLONG, float   *, BLASLONG, blasint *, float   *);
int dlaswp_ncopy(BLASLONG, BLASLONG, BLASLONG, double  *, BLASLONG, blasint *, double  *);
int qlaswp_ncopy(BLASLONG, BLASLONG, BLASLONG, xdouble *, BLASLONG, blasint *, xdouble *);
int claswp_ncopy(BLASLONG, BLASLONG, BLASLONG, float   *, BLASLONG, blasint *, float   *);
int zlaswp_ncopy(BLASLONG, BLASLONG, BLASLONG, double  *, BLASLONG, blasint *, double  *);
int xlaswp_ncopy(BLASLONG, BLASLONG, BLASLONG, xdouble *, BLASLONG, blasint *, xdouble *);

blasint sgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint sgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_R_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_C_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_R_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_C_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xgetrs_N_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_T_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_R_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_C_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint sgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint sgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_R_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cgetrs_C_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_R_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zgetrs_C_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xgetrs_N_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_T_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_R_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xgetrs_C_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint spotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint spotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dpotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dpotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qpotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qpotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cpotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cpotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zpotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zpotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xpotf2_U(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xpotf2_L(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint spotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint spotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dpotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dpotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qpotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qpotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cpotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cpotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zpotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zpotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xpotrf_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xpotrf_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint spotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint spotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dpotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dpotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qpotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qpotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint cpotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint cpotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zpotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zpotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xpotrf_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xpotrf_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint slauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint slauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dlauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dlauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qlauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qlauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint clauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint clauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zlauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zlauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xlauu2_U(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xlauu2_L(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint slauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint slauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dlauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dlauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qlauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qlauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint clauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint clauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zlauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zlauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xlauum_U_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xlauum_L_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint slauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint slauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dlauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dlauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qlauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qlauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint clauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint clauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint zlauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint zlauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xlauum_U_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xlauum_L_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint strti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dtrti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qtrti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint ctrti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ztrti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xtrti2_UU(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrti2_UN(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrti2_LU(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrti2_LN(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint strtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dtrtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qtrtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint ctrtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ztrtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xtrtri_UU_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_UN_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_LU_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_LN_single(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

blasint strtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint strtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint dtrtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint dtrtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint qtrtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint qtrtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint ctrtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ctrtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, float *, float *, BLASLONG);
blasint ztrtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint ztrtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, double *, double *, BLASLONG);
blasint xtrtri_UU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_UN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_LU_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);
blasint xtrtri_LN_parallel(blas_arg_t *, BLASLONG *, BLASLONG *, xdouble *, xdouble *, BLASLONG);

void sneg_tcopy(BLASLONG, BLASLONG, float   *, BLASLONG, float   *);
void dneg_tcopy(BLASLONG, BLASLONG, double  *, BLASLONG, double  *);
void qneg_tcopy(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *);
void cneg_tcopy(BLASLONG, BLASLONG, float   *, BLASLONG, float   *);
void zneg_tcopy(BLASLONG, BLASLONG, double  *, BLASLONG, double  *);
void xneg_tcopy(BLASLONG, BLASLONG, xdouble *, BLASLONG, xdouble *);

#define SGETF2	sgetf2_k
#define DGETF2	dgetf2_k
#define QGETF2	qgetf2_k
#define CGETF2	cgetf2_k
#define ZGETF2	zgetf2_k
#define XGETF2	xgetf2_k

#define SLASWP_PLUS	slaswp_plus
#define SLASWP_MINUS	slaswp_minus
#define DLASWP_PLUS	dlaswp_plus
#define DLASWP_MINUS	dlaswp_minus
#define QLASWP_PLUS	qlaswp_plus
#define QLASWP_MINUS	qlaswp_minus
#define CLASWP_PLUS	claswp_plus
#define CLASWP_MINUS	claswp_minus
#define ZLASWP_PLUS	zlaswp_plus
#define ZLASWP_MINUS	zlaswp_minus
#define XLASWP_PLUS	xlaswp_plus
#define XLASWP_MINUS	xlaswp_minus

#define SLASWP_NCOPY	slaswp_ncopy
#define DLASWP_NCOPY	dlaswp_ncopy
#define QLASWP_NCOPY	qlaswp_ncopy
#define CLASWP_NCOPY	claswp_ncopy
#define ZLASWP_NCOPY	zlaswp_ncopy
#define XLASWP_NCOPY	xlaswp_ncopy

#define SNEG_TCOPY	sneg_tcopy
#define DNEG_TCOPY	dneg_tcopy
#define QNEG_TCOPY	qneg_tcopy
#define CNEG_TCOPY	cneg_tcopy
#define ZNEG_TCOPY	zneg_tcopy
#define XNEG_TCOPY	xneg_tcopy

#ifndef COMPLEX
#ifdef XDOUBLE
#define GETF2	QGETF2
#define GETRF	QGETRF
#define GETRS_N_SINGLE	qgetrs_N_single
#define GETRS_T_SINGLE	qgetrs_T_single
#define GETRS_R_SINGLE	qgetrs_N_single
#define GETRS_C_SINGLE	qgetrs_T_single
#define GETRS_N_PARALLEL	qgetrs_N_parallel
#define GETRS_T_PARALLEL	qgetrs_T_parallel
#define GETRS_R_PARALLEL	qgetrs_N_parallel
#define GETRS_C_PARALLEL	qgetrs_T_parallel
#define LASWP_PLUS	QLASWP_PLUS
#define LASWP_MINUS	QLASWP_MINUS
#define LASWP_NCOPY	QLASWP_NCOPY
#define GETRS_N		QGETRS_N
#define GETRS_T		QGETRS_T
#define GETRF_SINGLE	qgetrf_single
#define GETRF_PARALLEL	qgetrf_parallel
#define NEG_TCOPY	QNEG_TCOPY
#elif defined(DOUBLE)
#define GETF2	DGETF2
#define GETRF	DGETRF
#define GETRS_N_SINGLE	dgetrs_N_single
#define GETRS_T_SINGLE	dgetrs_T_single
#define GETRS_R_SINGLE	dgetrs_N_single
#define GETRS_C_SINGLE	dgetrs_T_single
#define GETRS_N_PARALLEL	dgetrs_N_parallel
#define GETRS_T_PARALLEL	dgetrs_T_parallel
#define GETRS_R_PARALLEL	dgetrs_N_parallel
#define GETRS_C_PARALLEL	dgetrs_T_parallel
#define LASWP_PLUS	DLASWP_PLUS
#define LASWP_MINUS	DLASWP_MINUS
#define LASWP_NCOPY	DLASWP_NCOPY
#define GETRS_N		DGETRS_N
#define GETRS_T		DGETRS_T
#define GETRF_SINGLE	dgetrf_single
#define GETRF_PARALLEL	dgetrf_parallel
#define NEG_TCOPY	DNEG_TCOPY
#else
#define GETF2	SGETF2
#define GETRF	SGETRF
#define GETRS_N_SINGLE	sgetrs_N_single
#define GETRS_T_SINGLE	sgetrs_T_single
#define GETRS_R_SINGLE	sgetrs_N_single
#define GETRS_C_SINGLE	sgetrs_T_single
#define GETRS_N_PARALLEL	sgetrs_N_parallel
#define GETRS_T_PARALLEL	sgetrs_T_parallel
#define GETRS_R_PARALLEL	sgetrs_N_parallel
#define GETRS_C_PARALLEL	sgetrs_T_parallel
#define LASWP_PLUS	SLASWP_PLUS
#define LASWP_MINUS	SLASWP_MINUS
#define LASWP_NCOPY	SLASWP_NCOPY
#define GETRS_N		SGETRS_N
#define GETRS_T		SGETRS_T
#define GETRF_SINGLE	sgetrf_single
#define GETRF_PARALLEL	sgetrf_parallel
#define NEG_TCOPY	SNEG_TCOPY
#endif
#else
#ifdef XDOUBLE
#define GETF2	XGETF2
#define GETRF	XGETRF
#define GETRS_N_SINGLE	xgetrs_N_single
#define GETRS_T_SINGLE	xgetrs_T_single
#define GETRS_R_SINGLE	xgetrs_R_single
#define GETRS_C_SINGLE	xgetrs_C_single
#define GETRS_N_PARALLEL	xgetrs_N_parallel
#define GETRS_T_PARALLEL	xgetrs_T_parallel
#define GETRS_R_PARALLEL	xgetrs_R_parallel
#define GETRS_C_PARALLEL	xgetrs_C_parallel
#define LASWP_PLUS	XLASWP_PLUS
#define LASWP_MINUS	XLASWP_MINUS
#define LASWP_NCOPY	XLASWP_NCOPY
#define GETRS_N		XGETRS_N
#define GETRS_T		XGETRS_T
#define GETRF_SINGLE	xgetrf_single
#define GETRF_PARALLEL	xgetrf_parallel
#define NEG_TCOPY	XNEG_TCOPY
#elif defined(DOUBLE)
#define GETF2	ZGETF2
#define GETRF	ZGETRF
#define GETRS_N_SINGLE	zgetrs_N_single
#define GETRS_T_SINGLE	zgetrs_T_single
#define GETRS_R_SINGLE	zgetrs_R_single
#define GETRS_C_SINGLE	zgetrs_C_single
#define GETRS_N_PARALLEL	zgetrs_N_parallel
#define GETRS_T_PARALLEL	zgetrs_T_parallel
#define GETRS_R_PARALLEL	zgetrs_R_parallel
#define GETRS_C_PARALLEL	zgetrs_C_parallel
#define LASWP_PLUS	ZLASWP_PLUS
#define LASWP_MINUS	ZLASWP_MINUS
#define LASWP_NCOPY	ZLASWP_NCOPY
#define GETRS_N		ZGETRS_N
#define GETRS_T		ZGETRS_T
#define GETRF_SINGLE	zgetrf_single
#define GETRF_PARALLEL	zgetrf_parallel
#define NEG_TCOPY	ZNEG_TCOPY
#else
#define GETF2	CGETF2
#define GETRF	CGETRF
#define GETRS_N_SINGLE	cgetrs_N_single
#define GETRS_T_SINGLE	cgetrs_T_single
#define GETRS_R_SINGLE	cgetrs_R_single
#define GETRS_C_SINGLE	cgetrs_C_single
#define GETRS_N_PARALLEL	cgetrs_N_parallel
#define GETRS_T_PARALLEL	cgetrs_T_parallel
#define GETRS_R_PARALLEL	cgetrs_R_parallel
#define GETRS_C_PARALLEL	cgetrs_C_parallel
#define LASWP_PLUS	CLASWP_PLUS
#define LASWP_MINUS	CLASWP_MINUS
#define LASWP_NCOPY	CLASWP_NCOPY
#define GETRS_N		CGETRS_N
#define GETRS_T		CGETRS_T
#define GETRF_SINGLE	cgetrf_single
#define GETRF_PARALLEL	cgetrf_parallel
#define NEG_TCOPY	CNEG_TCOPY
#endif
#endif

#ifndef COMPLEX
#ifdef XDOUBLE
#define  POTF2_U  qpotf2_U
#define  POTF2_L  qpotf2_L
#define  LAUU2_U  qlauu2_U
#define  LAUU2_L  qlauu2_L
#define  POTRF_U_SINGLE qpotrf_U_single
#define  POTRF_L_SINGLE qpotrf_L_single
#define  POTRF_U_PARALLEL qpotrf_U_parallel
#define  POTRF_L_PARALLEL qpotrf_L_parallel
#define  LAUUM_U_SINGLE qlauum_U_single
#define  LAUUM_L_SINGLE qlauum_L_single
#define  LAUUM_U_PARALLEL qlauum_U_parallel
#define  LAUUM_L_PARALLEL qlauum_L_parallel
#define  TRTI2_UU qtrti2_UU
#define  TRTI2_UN qtrti2_UN
#define  TRTI2_LU qtrti2_LU
#define  TRTI2_LN qtrti2_LN
#define  TRTRI_UU_SINGLE qtrtri_UU_single
#define  TRTRI_UN_SINGLE qtrtri_UN_single
#define  TRTRI_LU_SINGLE qtrtri_LU_single
#define  TRTRI_LN_SINGLE qtrtri_LN_single
#define  TRTRI_UU_PARALLEL qtrtri_UU_parallel
#define  TRTRI_UN_PARALLEL qtrtri_UN_parallel
#define  TRTRI_LU_PARALLEL qtrtri_LU_parallel
#define  TRTRI_LN_PARALLEL qtrtri_LN_parallel
#elif defined(DOUBLE)
#define  POTF2_U  dpotf2_U
#define  POTF2_L  dpotf2_L
#define  LAUU2_U  dlauu2_U
#define  LAUU2_L  dlauu2_L
#define  POTRF_U_SINGLE dpotrf_U_single
#define  POTRF_L_SINGLE dpotrf_L_single
#define  POTRF_U_PARALLEL dpotrf_U_parallel
#define  POTRF_L_PARALLEL dpotrf_L_parallel
#define  LAUUM_U_SINGLE dlauum_U_single
#define  LAUUM_L_SINGLE dlauum_L_single
#define  LAUUM_U_PARALLEL dlauum_U_parallel
#define  LAUUM_L_PARALLEL dlauum_L_parallel
#define  TRTI2_UU dtrti2_UU
#define  TRTI2_UN dtrti2_UN
#define  TRTI2_LU dtrti2_LU
#define  TRTI2_LN dtrti2_LN
#define  TRTRI_UU_SINGLE dtrtri_UU_single
#define  TRTRI_UN_SINGLE dtrtri_UN_single
#define  TRTRI_LU_SINGLE dtrtri_LU_single
#define  TRTRI_LN_SINGLE dtrtri_LN_single
#define  TRTRI_UU_PARALLEL dtrtri_UU_parallel
#define  TRTRI_UN_PARALLEL dtrtri_UN_parallel
#define  TRTRI_LU_PARALLEL dtrtri_LU_parallel
#define  TRTRI_LN_PARALLEL dtrtri_LN_parallel
#else
#define  POTF2_U  spotf2_U
#define  POTF2_L  spotf2_L
#define  LAUU2_U  slauu2_U
#define  LAUU2_L  slauu2_L
#define  POTRF_U_SINGLE spotrf_U_single
#define  POTRF_L_SINGLE spotrf_L_single
#define  POTRF_U_PARALLEL spotrf_U_parallel
#define  POTRF_L_PARALLEL spotrf_L_parallel
#define  LAUUM_U_SINGLE slauum_U_single
#define  LAUUM_L_SINGLE slauum_L_single
#define  LAUUM_U_PARALLEL slauum_U_parallel
#define  LAUUM_L_PARALLEL slauum_L_parallel
#define  TRTI2_UU strti2_UU
#define  TRTI2_UN strti2_UN
#define  TRTI2_LU strti2_LU
#define  TRTI2_LN strti2_LN
#define  TRTRI_UU_SINGLE strtri_UU_single
#define  TRTRI_UN_SINGLE strtri_UN_single
#define  TRTRI_LU_SINGLE strtri_LU_single
#define  TRTRI_LN_SINGLE strtri_LN_single
#define  TRTRI_UU_PARALLEL strtri_UU_parallel
#define  TRTRI_UN_PARALLEL strtri_UN_parallel
#define  TRTRI_LU_PARALLEL strtri_LU_parallel
#define  TRTRI_LN_PARALLEL strtri_LN_parallel
#endif
#else
#ifdef XDOUBLE
#define  POTF2_U  xpotf2_U
#define  POTF2_L  xpotf2_L
#define  LAUU2_U  xlauu2_U
#define  LAUU2_L  xlauu2_L
#define  POTRF_U_SINGLE xpotrf_U_single
#define  POTRF_L_SINGLE xpotrf_L_single
#define  POTRF_U_PARALLEL xpotrf_U_parallel
#define  POTRF_L_PARALLEL xpotrf_L_parallel
#define  LAUUM_U_SINGLE xlauum_U_single
#define  LAUUM_L_SINGLE xlauum_L_single
#define  LAUUM_U_PARALLEL xlauum_U_parallel
#define  LAUUM_L_PARALLEL xlauum_L_parallel
#define  TRTI2_UU xtrti2_UU
#define  TRTI2_UN xtrti2_UN
#define  TRTI2_LU xtrti2_LU
#define  TRTI2_LN xtrti2_LN
#define  TRTRI_UU_SINGLE xtrtri_UU_single
#define  TRTRI_UN_SINGLE xtrtri_UN_single
#define  TRTRI_LU_SINGLE xtrtri_LU_single
#define  TRTRI_LN_SINGLE xtrtri_LN_single
#define  TRTRI_UU_PARALLEL xtrtri_UU_parallel
#define  TRTRI_UN_PARALLEL xtrtri_UN_parallel
#define  TRTRI_LU_PARALLEL xtrtri_LU_parallel
#define  TRTRI_LN_PARALLEL xtrtri_LN_parallel
#elif defined(DOUBLE)
#define  POTF2_U  zpotf2_U
#define  POTF2_L  zpotf2_L
#define  LAUU2_U  zlauu2_U
#define  LAUU2_L  zlauu2_L
#define  POTRF_U_SINGLE zpotrf_U_single
#define  POTRF_L_SINGLE zpotrf_L_single
#define  POTRF_U_PARALLEL zpotrf_U_parallel
#define  POTRF_L_PARALLEL zpotrf_L_parallel
#define  LAUUM_U_SINGLE zlauum_U_single
#define  LAUUM_L_SINGLE zlauum_L_single
#define  LAUUM_U_PARALLEL zlauum_U_parallel
#define  LAUUM_L_PARALLEL zlauum_L_parallel
#define  TRTI2_UU ztrti2_UU
#define  TRTI2_UN ztrti2_UN
#define  TRTI2_LU ztrti2_LU
#define  TRTI2_LN ztrti2_LN
#define  TRTRI_UU_SINGLE ztrtri_UU_single
#define  TRTRI_UN_SINGLE ztrtri_UN_single
#define  TRTRI_LU_SINGLE ztrtri_LU_single
#define  TRTRI_LN_SINGLE ztrtri_LN_single
#define  TRTRI_UU_PARALLEL ztrtri_UU_parallel
#define  TRTRI_UN_PARALLEL ztrtri_UN_parallel
#define  TRTRI_LU_PARALLEL ztrtri_LU_parallel
#define  TRTRI_LN_PARALLEL ztrtri_LN_parallel
#else
#define  POTF2_U  cpotf2_U
#define  POTF2_L  cpotf2_L
#define  LAUU2_U  clauu2_U
#define  LAUU2_L  clauu2_L
#define  POTRF_U_SINGLE cpotrf_U_single
#define  POTRF_L_SINGLE cpotrf_L_single
#define  POTRF_U_PARALLEL cpotrf_U_parallel
#define  POTRF_L_PARALLEL cpotrf_L_parallel
#define  LAUUM_U_SINGLE clauum_U_single
#define  LAUUM_L_SINGLE clauum_L_single
#define  LAUUM_U_PARALLEL clauum_U_parallel
#define  LAUUM_L_PARALLEL clauum_L_parallel
#define  TRTI2_UU ctrti2_UU
#define  TRTI2_UN ctrti2_UN
#define  TRTI2_LU ctrti2_LU
#define  TRTI2_LN ctrti2_LN
#define  TRTRI_UU_SINGLE ctrtri_UU_single
#define  TRTRI_UN_SINGLE ctrtri_UN_single
#define  TRTRI_LU_SINGLE ctrtri_LU_single
#define  TRTRI_LN_SINGLE ctrtri_LN_single
#define  TRTRI_UU_PARALLEL ctrtri_UU_parallel
#define  TRTRI_UN_PARALLEL ctrtri_UN_parallel
#define  TRTRI_LU_PARALLEL ctrtri_LU_parallel
#define  TRTRI_LN_PARALLEL ctrtri_LN_parallel
#endif
#endif

#endif
#endif
