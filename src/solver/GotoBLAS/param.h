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

#include "param_old.h"

#ifndef PARAM_H
#define PARAM_H

#ifdef OPTERON

#define GEMM_BUFFER_A_OFFSET  64
#define GEMM_BUFFER_B_OFFSET 128
#define GEMM_ALIGN 0x03ffffUL

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 4
#define DGEMM_UNROLL_M 2
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1
#endif

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SGEMM_P sgemm_p
#define DGEMM_P dgemm_p
#define QGEMM_P qgemm_p
#define CGEMM_P cgemm_p
#define ZGEMM_P zgemm_p
#define XGEMM_P xgemm_p

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SGEMM_Q 256
#define DGEMM_Q 256
#define QGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 256
#define XGEMM_Q 256

#define SYMV_P	16
#define HAVE_EXCLUSIVE_CACHE

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)

#endif

#ifdef BARCELONA

#define GEMM_BUFFER_A_OFFSET  64
#define GEMM_BUFFER_B_OFFSET  64
#define GEMM_ALIGN 0x0fffUL

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 4
#define DGEMM_UNROLL_M 2
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1
#endif

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SGEMM_P sgemm_p
#define DGEMM_P dgemm_p
#define QGEMM_P qgemm_p
#define CGEMM_P cgemm_p
#define ZGEMM_P zgemm_p
#define XGEMM_P xgemm_p

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SGEMM_Q 232
#define DGEMM_Q 232
#define QGEMM_Q 232
#define CGEMM_Q 232
#define ZGEMM_Q 232
#define XGEMM_Q 232

#define SYMV_P	16
#define HAVE_EXCLUSIVE_CACHE

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)

#define GEMM_THREAD gemm_thread_n

#endif

#ifdef ATHLON

#define GEMM_BUFFER_A_OFFSET   0
#define GEMM_BUFFER_B_OFFSET 256
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#define SGEMM_UNROLL_M 2
#define DGEMM_UNROLL_M 1
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 1
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1
#define XGEMM_VECSIZE  1

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SGEMM_P 224
#define DGEMM_P 112
#define QGEMM_P  56
#define CGEMM_P 112
#define ZGEMM_P  56
#define XGEMM_P  28

#define SGEMM_Q 256
#define DGEMM_Q 256
#define QGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 256
#define XGEMM_Q 256

#define SYMV_P	16
#define HAVE_EXCLUSIVE_CACHE
#endif

#ifdef VIAC3

#define GEMM_BUFFER_A_OFFSET   0
#define GEMM_BUFFER_B_OFFSET 256
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#define SGEMM_UNROLL_M 2
#define DGEMM_UNROLL_M 1
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 1
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1
#define XGEMM_VECSIZE  1

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SGEMM_P 128
#define DGEMM_P 128
#define QGEMM_P 128
#define CGEMM_P 128
#define ZGEMM_P 128
#define XGEMM_P 128

#define SGEMM_Q 512
#define DGEMM_Q 256
#define QGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 128
#define XGEMM_Q 128

#define SYMV_P	16
#endif

#if defined(PENTIUM3)
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 0
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 8
#define SGEMM_UNROLL_N 2
#define DGEMM_UNROLL_M 2
#define DGEMM_UNROLL_N 2
#define QGEMM_UNROLL_M 2
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_M 4
#define CGEMM_UNROLL_N 1
#define ZGEMM_UNROLL_M 1
#define ZGEMM_UNROLL_N 1
#define XGEMM_UNROLL_M 1
#define XGEMM_UNROLL_N 1

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1
#define XGEMM_VECSIZE  1

#define SGEMM_P sgemm_p
#define SGEMM_Q 256
#define SGEMM_R sgemm_r

#define DGEMM_P dgemm_p
#define DGEMM_Q 256
#define DGEMM_R dgemm_r

#define QGEMM_P qgemm_p
#define QGEMM_Q 256
#define QGEMM_R qgemm_r

#define CGEMM_P cgemm_p
#define CGEMM_Q 256
#define CGEMM_R cgemm_r

#define ZGEMM_P zgemm_p
#define ZGEMM_Q 256
#define ZGEMM_R zgemm_r

#define XGEMM_P xgemm_p
#define XGEMM_Q 256
#define XGEMM_R xgemm_r

#define SYMV_P	4
#endif

#ifdef PENTIUMM
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 0
#define GEMM_ALIGN 0x0ffffUL

#ifdef CORE_YONAH
#define SGEMM_UNROLL_M 4
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 2
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_M 2
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_M 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 1
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_M 1
#define XGEMM_UNROLL_N 1

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1
#else
#define SGEMM_UNROLL_M 8
#define SGEMM_UNROLL_N 2
#define DGEMM_UNROLL_M 2
#define DGEMM_UNROLL_N 2
#define QGEMM_UNROLL_M 2
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_M 4
#define CGEMM_UNROLL_N 1
#define ZGEMM_UNROLL_M 1
#define ZGEMM_UNROLL_N 1
#define XGEMM_UNROLL_M 1
#define XGEMM_UNROLL_N 1

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1
#define XGEMM_VECSIZE  1
#endif

#define SGEMM_P sgemm_p
#define SGEMM_Q 256
#define SGEMM_R sgemm_r

#define DGEMM_P dgemm_p
#define DGEMM_Q 256
#define DGEMM_R dgemm_r

#define QGEMM_P qgemm_p
#define QGEMM_Q 256
#define QGEMM_R qgemm_r

#define CGEMM_P cgemm_p
#define CGEMM_Q 256
#define CGEMM_R cgemm_r

#define ZGEMM_P zgemm_p
#define ZGEMM_Q 256
#define ZGEMM_R zgemm_r

#define XGEMM_P xgemm_p
#define XGEMM_Q 256
#define XGEMM_R xgemm_r

#define SYMV_P	4
#endif

#ifdef PENTIUM4

#ifndef CORE_PRESCOTT
#define GEMM_BUFFER_A_OFFSET    512
#define GEMM_BUFFER_B_OFFSET    128
#else
#define GEMM_BUFFER_A_OFFSET      0
#define GEMM_BUFFER_B_OFFSET    256
#endif
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SYMV_P	8

#ifdef CORE_PRESCOTT

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 4
#define DGEMM_UNROLL_M 2
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1
#endif

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1

#define SGEMM_UNROLL_N 2
#define DGEMM_UNROLL_N 2
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 1
#define ZGEMM_UNROLL_N 1
#define XGEMM_UNROLL_N 1

#endif

#ifndef ALLOC_HUGETLB
#if L2_SIZE >= 1048576
#define VL2_SIZE ((L2_SIZE * (L2_ASSOCIATIVE - 2) / L2_ASSOCIATIVE))
#else
#define VL2_SIZE ((L2_SIZE * (L2_ASSOCIATIVE - 1) / L2_ASSOCIATIVE))
#endif
#endif

#define SGEMM_P sgemm_p
#define SGEMM_R sgemm_r

#define DGEMM_P dgemm_p
#define DGEMM_R dgemm_r

#define QGEMM_P qgemm_p
#define QGEMM_R qgemm_r

#define CGEMM_P cgemm_p
#define CGEMM_R cgemm_r

#define ZGEMM_P zgemm_p
#define ZGEMM_R zgemm_r

#define XGEMM_P xgemm_p
#define XGEMM_R xgemm_r

#endif

#ifdef CORE2

#define GEMM_BUFFER_A_OFFSET     96
#define GEMM_BUFFER_B_OFFSET     96
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SYMV_P	8

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)
#define SWITCH_RATIO	4

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1

#define SGEMM_UNROLL_N 2
#define DGEMM_UNROLL_N 2
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 1
#define ZGEMM_UNROLL_N 1
#define XGEMM_UNROLL_N 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1
#endif

#define VL2_SIZE ((L2_SIZE * (L2_ASSOCIATIVE - 2) / L2_ASSOCIATIVE))

#define SGEMM_P sgemm_p
#define SGEMM_R sgemm_r

#define DGEMM_P dgemm_p
#define DGEMM_R dgemm_r

#define QGEMM_P qgemm_p
#define QGEMM_R qgemm_r

#define CGEMM_P cgemm_p
#define CGEMM_R cgemm_r

#define ZGEMM_P zgemm_p
#define ZGEMM_R zgemm_r

#define XGEMM_P xgemm_p
#define XGEMM_R xgemm_r

#define SGEMM_Q 256
#define DGEMM_Q 256
#define QGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 256
#define XGEMM_Q 256

#endif

#ifdef PENRYN

#define GEMM_BUFFER_A_OFFSET    128
#define GEMM_BUFFER_B_OFFSET      0
#define GEMM_ALIGN 0x0fffffUL

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SYMV_P	8

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)
#define SWITCH_RATIO	4

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 4
#define DGEMM_UNROLL_M 2
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1
#endif

#define VL2_SIZE ((L2_SIZE * (L2_ASSOCIATIVE - 2) / L2_ASSOCIATIVE))

#define SGEMM_P sgemm_p
#define SGEMM_R sgemm_r

#define DGEMM_P dgemm_p
#define DGEMM_R dgemm_r

#define QGEMM_P qgemm_p
#define QGEMM_R qgemm_r

#define CGEMM_P cgemm_p
#define CGEMM_R cgemm_r

#define ZGEMM_P zgemm_p
#define ZGEMM_R zgemm_r

#define XGEMM_P xgemm_p
#define XGEMM_R xgemm_r

#define SGEMM_Q 256
#define DGEMM_Q 256
#define QGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 256
#define XGEMM_Q 256

#define SHUFPD_0	shufps	$0x44,
#define SHUFPD_1	shufps	$0x4e,
#define SHUFPD_2	shufps	$0xe4,
#define SHUFPD_3	shufps	$0xee,
#endif

#ifdef ITANIUM2
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 256
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 8
#define SGEMM_UNROLL_N 8
#define DGEMM_UNROLL_M 8
#define DGEMM_UNROLL_N 8
#define QGEMM_UNROLL_M 8
#define QGEMM_UNROLL_N 8
#define CGEMM_UNROLL_M 4
#define CGEMM_UNROLL_N 4
#define ZGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_N 4
#define XGEMM_UNROLL_M 4
#define XGEMM_UNROLL_N 4

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1
#define XGEMM_VECSIZE  1

#define SGEMM_P sgemm_p
#define DGEMM_P dgemm_p
#define QGEMM_P qgemm_p
#define CGEMM_P cgemm_p
#define ZGEMM_P zgemm_p
#define XGEMM_P xgemm_p

#define SGEMM_Q 1024
#define DGEMM_Q 1024
#define QGEMM_Q 1024
#define CGEMM_Q 1024
#define ZGEMM_Q 1024
#define XGEMM_Q 1024

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SYMV_P	 16

#define SWITCHING	(GEMM_P * 2)
#define GEMM_PP		(GEMM_P * 1)
#endif

#if defined(EV4) || defined(EV5) || defined(EV6)
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 0
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 4
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SYMV_P	 8

#ifdef EV4
#define SGEMM_P	 32
#define SGEMM_Q	112
#define SGEMM_R	256

#define DGEMM_P	 32
#define DGEMM_Q	 56
#define DGEMM_R	256

#define CGEMM_P	 32
#define CGEMM_Q	 64
#define CGEMM_R	240

#define ZGEMM_P	 32
#define ZGEMM_Q	 32
#define ZGEMM_R	240
#endif

#ifdef EV5
#define SGEMM_P	 56
#define SGEMM_Q	288
#define SGEMM_R	344

#define DGEMM_P	 56
#define DGEMM_Q	144
#define DGEMM_R	344

#define CGEMM_P	 56
#define CGEMM_Q	144
#define CGEMM_R	344

#define ZGEMM_P	 56
#define ZGEMM_Q	 72
#define ZGEMM_R	344
#endif

#ifdef EV6
#define SGEMM_P	120
#define SGEMM_Q	1056
#define SGEMM_R	512

#define DGEMM_P	120
#define DGEMM_Q	528
#define DGEMM_R	512

#define CGEMM_P	120
#define CGEMM_Q	528
#define CGEMM_R	512

#define ZGEMM_P	120
#define ZGEMM_Q	264
#define ZGEMM_R	512
#endif

#endif

#ifdef CELL
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 8192
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 16
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 8
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1

#define SGEMM_P 128
#define DGEMM_P 128
#define CGEMM_P 128
#define ZGEMM_P 128

#define SGEMM_Q  512
#define DGEMM_Q  256
#define CGEMM_Q  256
#define ZGEMM_Q  128

#define SYMV_P	 4
#endif

#ifdef PPCG4
#define GEMM_BUFFER_A_OFFSET    0
#define GEMM_BUFFER_B_OFFSET 1024
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 16
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 8
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1

#define SGEMM_P 256
#define DGEMM_P 128
#define CGEMM_P 128
#define ZGEMM_P  64

#define SGEMM_Q 256
#define DGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 256

#define SYMV_P	 4
#endif

#ifdef PPC970
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 2048
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 16
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 8
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  1

#ifdef linux
#if L2_SIZE == 1024976
#define SGEMM_P 320
#define DGEMM_P 256
#define CGEMM_P 256
#define ZGEMM_P 256
#else
#define SGEMM_P 160
#define DGEMM_P 160
#define CGEMM_P 160
#define ZGEMM_P 160
#endif
#endif

#define SGEMM_Q 512
#define DGEMM_Q 256
#define CGEMM_Q 256
#define ZGEMM_Q 128

#define SYMV_P	 4

#endif

#ifdef PPC440
#define GEMM_BUFFER_A_OFFSET (32 * 0)
#define GEMM_BUFFER_B_OFFSET (32 * 0)
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 4
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SGEMM_P 512
#define DGEMM_P 512
#define CGEMM_P 512
#define ZGEMM_P 512

#define SGEMM_Q 1024
#define DGEMM_Q  512
#define CGEMM_Q  512
#define ZGEMM_Q  256

#define SGEMM_R SGEMM_P
#define DGEMM_R DGEMM_P
#define CGEMM_R CGEMM_P
#define ZGEMM_R ZGEMM_P

#define SYMV_P	 4
#endif

#ifdef PPC440FP2
#define GEMM_BUFFER_A_OFFSET (32 * 0)
#define GEMM_BUFFER_B_OFFSET (32 * 0)
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 8
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 8
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 4
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SGEMM_P 128
#define DGEMM_P 128
#define CGEMM_P 128
#define ZGEMM_P 128
#if 1
#define SGEMM_Q 4096
#define DGEMM_Q 3072
#define CGEMM_Q 2048
#define ZGEMM_Q 1024
#else
#define SGEMM_Q  512
#define DGEMM_Q  256
#define CGEMM_Q  256
#define ZGEMM_Q  128
#endif

#define SYMV_P	 4
#endif



#if defined(POWER3) || defined(POWER4) || defined(POWER5)
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 2048
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 4
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  4)

#ifdef POWER3
#define SGEMM_P 256
#define SGEMM_Q 432
#define SGEMM_R 1012

#define DGEMM_P 256
#define DGEMM_Q 216
#define DGEMM_R 1012

#define ZGEMM_P 256
#define ZGEMM_Q 104
#define ZGEMM_R 1012
#endif

#if defined(POWER4)
#ifdef ALLOC_HUGETLB
#define SGEMM_P 184
#define DGEMM_P 184
#define CGEMM_P 184
#define ZGEMM_P 184
#else
#define SGEMM_P 144
#define DGEMM_P 144
#define CGEMM_P 144
#define ZGEMM_P 144
#endif
#endif

#if defined(POWER5)
#ifdef ALLOC_HUGETLB
#define SGEMM_P 512
#define DGEMM_P 256
#define CGEMM_P 256
#define ZGEMM_P 128
#else
#define SGEMM_P 320
#define DGEMM_P 160
#define CGEMM_P 160
#define ZGEMM_P  80
#endif

#define SGEMM_Q 256
#define CGEMM_Q 256
#define DGEMM_Q 256
#define ZGEMM_Q 256
#endif

#define SYMV_P	 8

#endif

#if defined(ARCH_SPARC) && defined(V9)
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 2048
#define GEMM_ALIGN 0x03fffUL

#define SGEMM_UNROLL_M 4
#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_M 4
#define DGEMM_UNROLL_N 4
#define CGEMM_UNROLL_M 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_N 2

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SGEMM_P  512
#define DGEMM_P  512
#define CGEMM_P  512
#define ZGEMM_P  512

#define SGEMM_Q 1024
#define DGEMM_Q  512
#define CGEMM_Q  512
#define ZGEMM_Q  256

#define SYMV_P	 8
#endif

#ifdef ARCH_CLEARSPEED
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 0

#define GEMM_PARAM_OFFSET 64

#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_M 96
#define SGEMM_UNROLL_N 96
#define DGEMM_UNROLL_M 96
#define DGEMM_UNROLL_N 96
#define CGEMM_UNROLL_M 48
#define CGEMM_UNROLL_N 48
#define ZGEMM_UNROLL_M 48
#define ZGEMM_UNROLL_N 48

#define SGEMM_VECSIZE  1
#define DGEMM_VECSIZE  1
#define CGEMM_VECSIZE  1
#define ZGEMM_VECSIZE  1

#define SGEMM_P 9600
#define DGEMM_P 9600
#define CGEMM_P 9600
#define ZGEMM_P 9600

#define SGEMM_Q 64
#define DGEMM_Q 64
#define CGEMM_Q 64
#define ZGEMM_Q 64

#define SGEMM_R 2000
#define DGEMM_R 1920
#define CGEMM_R 2000
#define ZGEMM_R 2000

#endif

#ifdef GENERIC
#define GEMM_BUFFER_A_OFFSET 0
#define GEMM_BUFFER_B_OFFSET 0
#define GEMM_ALIGN 0x0ffffUL

#define SGEMM_UNROLL_N 4
#define DGEMM_UNROLL_N 4
#define QGEMM_UNROLL_N 2
#define CGEMM_UNROLL_N 2
#define ZGEMM_UNROLL_N 2
#define XGEMM_UNROLL_N 1

#ifdef ARCH_X86
#define SGEMM_UNROLL_M 4
#define DGEMM_UNROLL_M 2
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 2
#define ZGEMM_UNROLL_M 1
#define XGEMM_UNROLL_M 1
#else
#define SGEMM_UNROLL_M 8
#define DGEMM_UNROLL_M 4
#define QGEMM_UNROLL_M 2
#define CGEMM_UNROLL_M 4
#define ZGEMM_UNROLL_M 2
#define XGEMM_UNROLL_M 1
#endif

#define SGEMM_VECSIZE  4
#define DGEMM_VECSIZE  2
#define QGEMM_VECSIZE  1
#define CGEMM_VECSIZE  4
#define ZGEMM_VECSIZE  2
#define XGEMM_VECSIZE  1

#define SGEMM_P sgemm_p
#define DGEMM_P dgemm_p
#define QGEMM_P qgemm_p
#define CGEMM_P cgemm_p
#define ZGEMM_P zgemm_p
#define XGEMM_P xgemm_p

#define SGEMM_R sgemm_r
#define DGEMM_R dgemm_r
#define QGEMM_R qgemm_r
#define CGEMM_R cgemm_r
#define ZGEMM_R zgemm_r
#define XGEMM_R xgemm_r

#define SGEMM_Q 128
#define DGEMM_Q 128
#define QGEMM_Q 128
#define CGEMM_Q 128
#define ZGEMM_Q 128
#define XGEMM_Q 128

#define SYMV_P	16

#define SWITCHING	(GEMM_P *  4)
#define GEMM_PP		(GEMM_P *  1)

#endif

#ifndef VL2_SIZE
#define VL2_SIZE L2_SIZE
#endif

#ifndef QGEMM_UNROLL_M
#define QGEMM_UNROLL_M 2
#endif

#ifndef QGEMM_UNROLL_N
#define QGEMM_UNROLL_N 2
#endif

#ifndef XGEMM_UNROLL_M
#define XGEMM_UNROLL_M 2
#endif

#ifndef XGEMM_UNROLL_N
#define XGEMM_UNROLL_N 2
#endif

#ifndef QGEMM_VECSIZE
#define QGEMM_VECSIZE 1
#endif

#ifndef XGEMM_VECSIZE
#define XGEMM_VECSIZE 1
#endif

#ifndef GEMM_THREAD
#define GEMM_THREAD gemm_thread_n
#endif

#ifndef SGEMM_Q
#define IDEAL_SGEMM_Q (DTB_SIZE / 2 /  4)
#define CACHE_SGEMM_Q (L1_DATA_SIZE / 2 /  4 / SGEMM_UNROLL_N / SGEMM_VECSIZE)
#if IDEAL_SGEMM_Q < CACHE_SGEMM_Q
#define SGEMM_Q IDEAL_SGEMM_Q
#else
#define SGEMM_Q CACHE_SGEMM_Q
#endif
#endif

#ifndef DGEMM_Q
#define IDEAL_DGEMM_Q (DTB_SIZE / 2 /  8)
#define CACHE_DGEMM_Q (L1_DATA_SIZE / 2 /  8 / DGEMM_UNROLL_N / DGEMM_VECSIZE)
#if IDEAL_DGEMM_Q < CACHE_DGEMM_Q
#define DGEMM_Q IDEAL_DGEMM_Q
#else
#define DGEMM_Q CACHE_DGEMM_Q
#endif
#endif

#ifndef QGEMM_Q
#define IDEAL_QGEMM_Q (DTB_SIZE / 2 / 16)
#define CACHE_QGEMM_Q (L1_DATA_SIZE / 2 / 16 / QGEMM_UNROLL_N / QGEMM_VECSIZE)
#if IDEAL_QGEMM_Q < CACHE_QGEMM_Q
#define QGEMM_Q IDEAL_QGEMM_Q
#else
#define QGEMM_Q CACHE_QGEMM_Q
#endif
#endif

#ifndef CGEMM_Q
#define IDEAL_CGEMM_Q (DTB_SIZE / 2 /  8)
#define CACHE_CGEMM_Q (L1_DATA_SIZE / 2 /  8 / CGEMM_UNROLL_N / CGEMM_VECSIZE)
#if IDEAL_CGEMM_Q < CACHE_CGEMM_Q
#define CGEMM_Q IDEAL_CGEMM_Q
#else
#define CGEMM_Q CACHE_CGEMM_Q
#endif
#endif

#ifndef ZGEMM_Q
#define IDEAL_ZGEMM_Q (DTB_SIZE / 2 / 16)
#define CACHE_ZGEMM_Q (L1_DATA_SIZE / 2 / 16 / ZGEMM_UNROLL_N / ZGEMM_VECSIZE)
#if IDEAL_ZGEMM_Q < CACHE_ZGEMM_Q
#define ZGEMM_Q IDEAL_ZGEMM_Q
#else
#define ZGEMM_Q CACHE_ZGEMM_Q
#endif
#endif

#ifndef XGEMM_Q
#define IDEAL_XGEMM_Q (DTB_SIZE / 2 / 32)
#define CACHE_XGEMM_Q (L1_DATA_SIZE / 2 / 32 / XGEMM_UNROLL_N / XGEMM_VECSIZE)
#if IDEAL_XGEMM_Q < CACHE_XGEMM_Q
#define XGEMM_Q IDEAL_XGEMM_Q
#else
#define XGEMM_Q CACHE_XGEMM_Q
#endif
#endif

#ifndef SGEMM_P
#define SGEMM_P (VL2_SIZE  / 2 /  4 / SGEMM_Q)
#endif

#ifndef DGEMM_P
#define DGEMM_P (VL2_SIZE  / 2 /  8 / DGEMM_Q)
#endif

#ifndef QGEMM_P
#define QGEMM_P (VL2_SIZE  / 2 / 16 / QGEMM_Q)
#endif

#ifndef CGEMM_P
#define CGEMM_P (VL2_SIZE  / 2 /  8 / CGEMM_Q)
#endif

#ifndef ZGEMM_P
#define ZGEMM_P (VL2_SIZE  / 2 / 16 / ZGEMM_Q)
#endif

#ifndef XGEMM_P
#define XGEMM_P (VL2_SIZE  / 2 / 32 / XGEMM_Q)
#endif

#ifndef SGEMM_R
#define SGEMM_R (((BUFFER_LIMIT - ((SGEMM_P * SGEMM_Q *  4 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (SGEMM_Q *  4) - 15) & ~15)
#endif

#ifndef DGEMM_R
#define DGEMM_R (((BUFFER_LIMIT - ((DGEMM_P * DGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (DGEMM_Q *  8) - 15) & ~15)
#endif

#ifndef QGEMM_R
#define QGEMM_R (((BUFFER_LIMIT - ((QGEMM_P * QGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (QGEMM_Q * 16) - 15) & ~15)
#endif

#ifndef CGEMM_R
#define CGEMM_R (((BUFFER_LIMIT - ((CGEMM_P * CGEMM_Q *  8 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (CGEMM_Q *  8) - 15) & ~15)
#endif

#ifndef ZGEMM_R
#define ZGEMM_R (((BUFFER_LIMIT - ((ZGEMM_P * ZGEMM_Q * 16 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (ZGEMM_Q * 16) - 15) & ~15)
#endif

#ifndef XGEMM_R
#define XGEMM_R (((BUFFER_LIMIT - ((XGEMM_P * XGEMM_Q * 32 + GEMM_BUFFER_A_OFFSET + GEMM_ALIGN) & ~GEMM_ALIGN)) / (XGEMM_Q * 32) - 15) & ~15)
#endif

#ifndef COMPLEX
#ifdef  XDOUBLE
#define GEMM_P QGEMM_P
#define GEMM_Q QGEMM_Q
#define GEMM_R QGEMM_R
#define GEMM_UNROLL_M QGEMM_UNROLL_M
#define GEMM_UNROLL_N QGEMM_UNROLL_N
#elif defined(DOUBLE)
#define GEMM_P DGEMM_P
#define GEMM_Q DGEMM_Q
#define GEMM_R DGEMM_R
#define GEMM_UNROLL_M DGEMM_UNROLL_M
#define GEMM_UNROLL_N DGEMM_UNROLL_N
#else
#define GEMM_P SGEMM_P
#define GEMM_Q SGEMM_Q
#define GEMM_R SGEMM_R
#define GEMM_UNROLL_M SGEMM_UNROLL_M
#define GEMM_UNROLL_N SGEMM_UNROLL_N
#endif
#else
#ifdef XDOUBLE
#define GEMM_P XGEMM_P
#define GEMM_Q XGEMM_Q
#define GEMM_R XGEMM_R
#define GEMM_UNROLL_M XGEMM_UNROLL_M
#define GEMM_UNROLL_N XGEMM_UNROLL_N
#elif defined(DOUBLE)
#define GEMM_P ZGEMM_P
#define GEMM_Q ZGEMM_Q
#define GEMM_R ZGEMM_R
#define GEMM_UNROLL_M ZGEMM_UNROLL_M
#define GEMM_UNROLL_N ZGEMM_UNROLL_N
#else
#define GEMM_P CGEMM_P
#define GEMM_Q CGEMM_Q
#define GEMM_R CGEMM_R
#define GEMM_UNROLL_M CGEMM_UNROLL_M
#define GEMM_UNROLL_N CGEMM_UNROLL_N
#endif
#endif

#if 0
#if GEMM_Q > GEMM_P
#define TRSM_P1 GEMM_P
#define TRSM_Q1 GEMM_P
#define TRSM_P2 GEMM_Q
#define TRSM_Q2 GEMM_R
#else
#define TRSM_P1 GEMM_Q
#define TRSM_Q1 GEMM_Q
#define TRSM_P2 GEMM_P
#define TRSM_Q2 GEMM_R
#endif

#if GEMM_Q > GEMM_P
#define SYMM_P1 GEMM_P
#define SYMM_Q1 GEMM_P
#define SYMM_P2 GEMM_Q
#define SYMM_Q2 GEMM_R
#else
#define SYMM_P1 GEMM_Q
#define SYMM_Q1 GEMM_Q
#define SYMM_P2 GEMM_P
#define SYMM_Q2 GEMM_R
#endif
#endif

#if GEMM_UNROLL_M == 16
#define GEMM_UNROLL_M_SHIFT 4
#endif

#if GEMM_UNROLL_M ==  8
#define GEMM_UNROLL_M_SHIFT 3
#endif

#if GEMM_UNROLL_M ==  4
#define GEMM_UNROLL_M_SHIFT 2
#endif

#if GEMM_UNROLL_M ==  2
#define GEMM_UNROLL_M_SHIFT 1
#endif

#if GEMM_UNROLL_M ==  1
#define GEMM_UNROLL_M_SHIFT 0
#endif

#if GEMM_UNROLL_N == 16
#define GEMM_UNROLL_N_SHIFT 4
#endif

#if GEMM_UNROLL_N ==  8
#define GEMM_UNROLL_N_SHIFT 3
#endif

#if GEMM_UNROLL_N ==  4
#define GEMM_UNROLL_N_SHIFT 2
#endif

#if GEMM_UNROLL_N ==  2
#define GEMM_UNROLL_N_SHIFT 1
#endif

#if GEMM_UNROLL_N ==  1
#define GEMM_UNROLL_N_SHIFT 0
#endif

#define MAXMN MAX((GEMM_UNROLL_M), (GEMM_UNROLL_N))

#ifndef GEMM3M_P
#ifdef XDOUBLE
#define GEMM3M_P	QGEMM_P
#elif defined(DOUBLE)
#define GEMM3M_P	DGEMM_P
#else
#define GEMM3M_P	SGEMM_P
#endif
#endif

#ifndef GEMM3M_Q
#ifdef XDOUBLE
#define GEMM3M_Q	QGEMM_Q
#elif defined(DOUBLE)
#define GEMM3M_Q	DGEMM_Q
#else
#define GEMM3M_Q	SGEMM_Q
#endif
#endif

#ifndef GEMM3M_R
#ifdef XDOUBLE
#define GEMM3M_R	QGEMM_R
#elif defined(DOUBLE)
#define GEMM3M_R	DGEMM_R
#else
#define GEMM3M_R	SGEMM_R
#endif
#endif

#ifdef XDOUBLE
#define GEMM3M_UNROLL_M	QGEMM_UNROLL_M
#define GEMM3M_UNROLL_N	QGEMM_UNROLL_N
#elif defined(DOUBLE)
#define GEMM3M_UNROLL_M	DGEMM_UNROLL_M
#define GEMM3M_UNROLL_N	DGEMM_UNROLL_N
#else
#define GEMM3M_UNROLL_M	SGEMM_UNROLL_M
#define GEMM3M_UNROLL_N	SGEMM_UNROLL_N
#endif

#ifndef SHUFPD_0
#define SHUFPD_0	shufpd	$0,
#endif

#ifndef SHUFPD_1
#define SHUFPD_1	shufpd	$1,
#endif

#ifndef SHUFPD_2
#define SHUFPD_2	shufpd	$2,
#endif

#ifndef SHUFPD_3
#define SHUFPD_3	shufpd	$3,
#endif

#endif
