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

#ifndef PARAMOLD_H
#define PARAMOLD_H

#ifdef ATHLON
#define TRSM_P1  32
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  32
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)

#define TRSV_P1  8
#define TRSV_P2 (TRSV_P1 * 2)
#define SYR_P1  4000
#define SYR2_P1    8
#endif

#if defined(OPTERON) || defined(BARCELONA)
#define TRSV_P1    8
#define TRSV_P2 (TRSV_P1 * 2)
#define SYR_P1  4000
#define SYR2_P1    8

#define TRSM_P1   64
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  64
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)
#endif

#ifdef ITANIUM2
#define TRSM_P1  48
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  104
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)

#define TRSV_P1  16
#define TRSV_P2 (TRSV_P1 * 4)
#define SYR_P1  4000
#define SYR2_P1   8
#endif

#ifdef PENTIUM
#define TRSM_P1  32
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  32
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)
#endif

#if defined(PENTIUM3) || defined(PENTIUMM)
#define TRSM_P1  (DTB_ENTRIES - 8)
#ifndef TRANSA
#define TRSM_Q1  TRSM_P1
#else
#define TRSM_Q1 (TRSM_P1 * 4)
#endif
#define TRSM_P2 (TRSM_P1 * 2)
#ifndef TRANS
#define SYRK_P1  (DTB_ENTRIES - 8)
#else
#define SYRK_P1  (DTB_ENTRIES + 8)
#endif
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)

#define TRSV_P1  16
#define TRSV_P2  64
#define SYR_P1  4000
#define SYR2_P1 120
#endif

#ifdef PENTIUM4
#define TRSM_P1  32
#define TRSM_Q1 TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#ifndef TRANS
#define SYRK_P1  (DTB_ENTRIES - 8)
#else
#define SYRK_P1  (DTB_ENTRIES + 8)
#endif
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 8)

#define SYR_P1  4000

#define TRSV_P1  32
#define SYR2_P1 120
#endif

#if defined(CORE2) || defined(PENRYN)
#define TRSM_P1  32
#define TRSM_Q1 TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#ifndef TRANS
#define SYRK_P1  (DTB_ENTRIES - 8)
#else
#define SYRK_P1  (DTB_ENTRIES + 8)
#endif
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 8)

#define SYR_P1  4000

#define TRSV_P1  32
#define SYR2_P1 120
#endif

#ifdef GENERIC
#define TRSM_P1  32
#define TRSM_Q1 TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  32
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 8)

#define SYR_P1  4000

#define TRSV_P1  32
#define SYR2_P1 120
#endif

#ifdef EV4
#define TRSM_P1  16
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  32
#define SYRK_Q1  SYRK_P1
#define SYRK_P2  (SYRK_P1 * 5)
#define SYRK_Q2  SYRK_P2
#define SYR_P1  4000
#endif

#ifdef EV5
#define TRSM_P1  56
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  40
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 200
#define SYRK_Q2  SYRK_P2
#define SYR_P1  4000
#endif

#ifdef EV6
#define TRSM_P1  64
#define TRSM_Q1  TRSM_P1
#define TRSM_P2 (TRSM_P1 * 4)
#define SYRK_P1  88
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 264
#define SYRK_Q2  SYRK_P2

#define SYR_P1  4000
#endif

#if defined(PPC970) || defined(PPC440) || defined(PPC440FP2) || defined(CELL) || defined(PPCG4)
#define TRSM_P1  48
#define TRSM_Q1  80
#define TRSM_P2 (TRSM_P1 * 4)

#define SYRK_P1  104
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)
#define TRSV_P1    8
#define SYR_P1  4000
#define SYR2_P1    8
#endif

#ifdef POWER3
#define TRSM_P1  72
#ifndef TRANSA
#define TRSM_Q1  TRSM_P1
#else
#define TRSM_Q1 (TRSM_P1 * 4)
#endif
#define TRSM_P2 (TRSM_P1 * 2)
#endif

#if defined(POWER4) || defined(POWER5)
#define TRSM_P1  48
#define TRSM_Q1  80

#define SYRK_P1  104
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)

#define TRSV_P1    8

#define SYR_P1  2000
#define SYR2_P1    8
#endif

#ifdef ARCH_SPARC
#define TRSM_P1  80
#ifndef TRANSA
#define TRSM_Q1  TRSM_P1
#else
#define TRSM_Q1 (TRSM_P1 * 4)
#endif
#define TRSM_P2 (TRSM_P1 * 4)

#define SYRK_P1  104
#define SYRK_Q1  SYRK_P1
#define SYRK_P2 (SYRK_P1 * 4)

#define TRSV_P1   16

#define SYR_P1  2000
#define SYR2_P1    8

#endif

#ifdef PENTIUM2
#define TRSV_P1  16
#define TRSV_P2  64
#endif


#ifdef EV6
#define TRSV_P1   16
#define TRSV_P2  184
#endif

#ifdef EV5
#define TRSV_P1   16
#define TRSV_P2   80
#endif

#ifdef EV4
#define TRSV_P1   16
#define TRSV_P2   80
#endif

#ifndef SYR2_P1
#define SYR2_P1 400
#endif

#endif
