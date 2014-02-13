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
#include <string.h>
#include "cpuid.h"

#ifdef __APPLE__
void cpuid(int op, int *eax, int *ebx, int *ecx, int *edx);
#else
static inline void cpuid(int op, int *eax, int *ebx, int *ecx, int *edx){
  __asm__ __volatile__
    ("cpuid": "=a" (*eax), "=b" (*ebx), "=c" (*ecx), "=d" (*edx) : "a" (op) : "cc");

}
#endif


static inline int have_cpuid(void){
  int eax, ebx, ecx, edx;

  cpuid(0, &eax, &ebx, &ecx, &edx);
  return eax;
}

static inline int have_excpuid(void){
  int eax, ebx, ecx, edx;

  cpuid(0x80000000, &eax, &ebx, &ecx, &edx);
  return eax & 0xffff;
}

int get_vendor(void){
  int eax, ebx, ecx, edx;
  char vendor[13];

  cpuid(0, &eax, &ebx, &ecx, &edx);
  
  *(int *)(&vendor[0]) = ebx;
  *(int *)(&vendor[4]) = edx;
  *(int *)(&vendor[8]) = ecx;
  vendor[12] = (char)NULL;

  if (!strcmp(vendor, "GenuineIntel")) return VENDOR_INTEL;
  if (!strcmp(vendor, " UMC UMC UMC")) return VENDOR_UMC;
  if (!strcmp(vendor, "AuthenticAMD")) return VENDOR_AMD;
  if (!strcmp(vendor, "CyrixInstead")) return VENDOR_CYRIX;
  if (!strcmp(vendor, "NexGenDriven")) return VENDOR_NEXGEN;
  if (!strcmp(vendor, "CentaurHauls")) return VENDOR_CENTAUR;
  if (!strcmp(vendor, "RiseRiseRise")) return VENDOR_RISE;
  if (!strcmp(vendor, " SiS SiS SiS")) return VENDOR_SIS;
  if (!strcmp(vendor, "GenuineTMx86")) return VENDOR_TRANSMETA;
  if (!strcmp(vendor, "Geode by NSC")) return VENDOR_NSC;

  if ((eax == 0) || ((eax & 0x500) != 0)) return VENDOR_INTEL;

  return VENDOR_UNKNOWN;
}
  
int get_cputype(int gettype){
  int eax, ebx, ecx, edx;
  int extend_family, family;
  int extend_model, model;
  int type, stepping;
  int feature = 0;

  cpuid(1, &eax, &ebx, &ecx, &edx);
  
  switch (gettype) {
  case GET_EXFAMILY :
    return BITMASK(eax, 20, 0xff);
  case GET_EXMODEL :
    return BITMASK(eax, 16, 0x0f);
  case GET_TYPE :
    return BITMASK(eax, 12, 0x03);
  case GET_FAMILY :
    return BITMASK(eax,  8, 0x0f);
  case GET_MODEL :
    return BITMASK(eax,  4, 0x0f);
  case GET_APICID :
    return BITMASK(ebx, 24, 0x0f);
  case GET_LCOUNT :
    return BITMASK(ebx, 16, 0x0f);
  case GET_CHUNKS :
    return BITMASK(ebx,  8, 0x0f);
  case GET_STEPPING :
    return BITMASK(eax,  0, 0x0f);
  case GET_BLANDID :
    return BITMASK(ebx,  0, 0xff);
  case GET_NUMSHARE :
    if (have_cpuid() < 4) return 0;
    cpuid(4, &eax, &ebx, &ecx, &edx);
    return BITMASK(eax, 14, 0xfff);
  case GET_NUMCORES :
    if (have_cpuid() < 4) return 0;
    cpuid(4, &eax, &ebx, &ecx, &edx);
    return BITMASK(eax, 26, 0x3f);

  case GET_FEATURE :
    if ((edx & (1 <<  3)) != 0) feature |= HAVE_PSE;
    if ((edx & (1 << 15)) != 0) feature |= HAVE_CMOV;
    if ((edx & (1 << 19)) != 0) feature |= HAVE_CFLUSH;
    if ((edx & (1 << 23)) != 0) feature |= HAVE_MMX;
    if ((edx & (1 << 25)) != 0) feature |= HAVE_SSE;
    if ((edx & (1 << 26)) != 0) feature |= HAVE_SSE2;
    if ((edx & (1 << 27)) != 0) {
      if (BITMASK(ebx, 16, 0x0f) > 0) feature |= HAVE_HIT;
    }
    if ((ecx & (1 <<  0)) != 0) feature |= HAVE_SSE3;
    if ((ecx & (1 <<  9)) != 0) feature |= HAVE_SSSE3;
    if ((ecx & (1 << 19)) != 0) feature |= HAVE_SSE4_1;
    if ((ecx & (1 << 20)) != 0) feature |= HAVE_SSE4_2;

    cpuid(0x80000001, &eax, &ebx, &ecx, &edx);
    if ((ecx & (1 <<  6)) != 0) feature |= HAVE_SSE4A;
    if ((ecx & (1 <<  7)) != 0) feature |= HAVE_MISALIGNSSE;
    if ((edx & (1 << 30)) != 0) feature |= HAVE_3DNOWEX;
    if ((edx & (1 << 31)) != 0) feature |= HAVE_3DNOW;

    if (have_excpuid() >= 0x1a) {
      cpuid(0x8000001a, &eax, &ebx, &ecx, &edx);
      if ((eax & (1 <<  0)) != 0) feature |= HAVE_128BITFPU;
      if ((eax & (1 <<  1)) != 0) feature |= HAVE_FASTMOVU;
    }
  }
  return feature;
}
  
int get_cacheinfo(int type, cache_info_t *cacheinfo){
  int eax, ebx, ecx, edx, cpuid_level;
  int info[15];
  int i;
  cache_info_t LC1, LD1, L2, L3, 
    ITB, DTB, LITB, LDTB,
    L2ITB, L2DTB, L2LITB, L2LDTB;

  LC1.size    = 0; LC1.associative = 0; LC1.linesize = 0; LC1.shared = 0;
  LD1.size    = 0; LD1.associative    = 0; LD1.linesize    = 0; LD1.shared    = 0;
  L2.size     = 0; L2.associative     = 0; L2.linesize     = 0; L2.shared     = 0;
  L3.size     = 0; L3.associative     = 0; L3.linesize     = 0; L3.shared     = 0;
  ITB.size    = 0; ITB.associative    = 0; ITB.linesize    = 0; ITB.shared    = 0;
  DTB.size    = 0; DTB.associative    = 0; DTB.linesize    = 0; DTB.shared    = 0;
  LITB.size   = 0; LITB.associative   = 0; LITB.linesize   = 0; LITB.shared   = 0;
  LDTB.size   = 0; LDTB.associative   = 0; LDTB.linesize   = 0; LDTB.shared   = 0;
  L2ITB.size  = 0; L2ITB.associative  = 0; L2ITB.linesize  = 0; L2ITB.shared  = 0;
  L2DTB.size  = 0; L2DTB.associative  = 0; L2DTB.linesize  = 0; L2DTB.shared  = 0;
  L2LITB.size = 0; L2LITB.associative = 0; L2LITB.linesize = 0; L2LITB.shared = 0;
  L2LDTB.size = 0; L2LDTB.associative = 0; L2LDTB.linesize = 0; L2LDTB.shared = 0;

  cpuid(0, &cpuid_level, &ebx, &ecx, &edx);

  if (cpuid_level > 1) {

    cpuid(2, &eax, &ebx, &ecx, &edx);

    info[ 0] = BITMASK(eax,  8, 0xff);
    info[ 1] = BITMASK(eax, 16, 0xff);
    info[ 2] = BITMASK(eax, 24, 0xff);
    
    info[ 3] = BITMASK(ebx,  0, 0xff);
    info[ 4] = BITMASK(ebx,  8, 0xff);
    info[ 5] = BITMASK(ebx, 16, 0xff);
    info[ 6] = BITMASK(ebx, 24, 0xff);
    
    info[ 7] = BITMASK(ecx,  0, 0xff);
    info[ 8] = BITMASK(ecx,  8, 0xff);
    info[ 9] = BITMASK(ecx, 16, 0xff);
    info[10] = BITMASK(ecx, 24, 0xff);
    
    info[11] = BITMASK(edx,  0, 0xff);
    info[12] = BITMASK(edx,  8, 0xff);
    info[13] = BITMASK(edx, 16, 0xff);
    info[14] = BITMASK(edx, 24, 0xff);
    
    for (i = 0; i < 15; i++){

      switch (info[i]){

	/* This table is from http://www.sandpile.org/ia32/cpuid.htm */

      case 0x01 :
	ITB.size        =     4;
	ITB.associative =     4;
	ITB.linesize     =   32;
	break;
      case 0x02 :
	LITB.size        = 4096;
	LITB.associative =    0;
	LITB.linesize    =    2;
	break;
      case 0x03 :
	DTB.size        =     4;
	DTB.associative =     4;
	DTB.linesize     =   64;
	break;
      case 0x04 :
	LDTB.size        = 4096;
	LDTB.associative =    4;
	LDTB.linesize    =    8;
	break;
      case 0x05 :
	LDTB.size        = 4096;
	LDTB.associative =    4;
	LDTB.linesize    =   32;
	break;
      case 0x06 :
	LC1.size        = 8;
	LC1.associative = 4;
	LC1.linesize    = 32;
	break;
      case 0x08 :
	LC1.size        = 16;
	LC1.associative = 4;
	LC1.linesize    = 32;
	break;
      case 0x0a :
	LD1.size        = 8;
	LD1.associative = 2;
	LD1.linesize    = 32;
	break;
      case 0x0c :
	LD1.size        = 16;
	LD1.associative = 4;
	LD1.linesize    = 32;
	break;
      case 0x10 :
	LD1.size        = 16;
	LD1.associative = 4;
	LD1.linesize    = 32;
	break;
      case 0x15 :
	LC1.size        = 16;
	LC1.associative = 4;
	LC1.linesize    = 32;
	break;
      case 0x1a :
	L2.size         = 96;
	L2.associative  = 6;
	L2.linesize     = 64;
	break;
      case 0x22 :
	L3.size         = 512;
	L3.associative  = 4;
	L3.linesize     = 64;
	break;
      case 0x23 :
	L3.size         = 1024;
	L3.associative  = 8;
	L3.linesize     = 64;
	break;
      case 0x25 :
	L3.size         = 2048;
	L3.associative  = 8;
	L3.linesize     = 64;
	break;
      case 0x29 :
	L3.size         = 4096;
	L3.associative  = 8;
	L3.linesize     = 64;
	break;
      case 0x2c :
	LD1.size        = 32;
	LD1.associative = 8;
	LD1.linesize    = 64;
	break;
      case 0x30 :
	LC1.size        = 32;
	LC1.associative = 8;
	LC1.linesize    = 64;
	break;
      case 0x39 :
	L2.size         = 128;
	L2.associative  = 4;
	L2.linesize     = 64;
	break;
      case 0x3a :
	L2.size         = 192;
	L2.associative  = 6;
	L2.linesize     = 64;
	break;
      case 0x3b :
	L2.size         = 128;
	L2.associative  = 2;
	L2.linesize     = 64;
	break;
      case 0x3c :
	L2.size         = 256;
	L2.associative  = 4;
	L2.linesize     = 64;
	break;
      case 0x3d :
	L2.size         = 384;
	L2.associative  = 6;
	L2.linesize     = 64;
	break;
      case 0x3e :
	L2.size         = 512;
	L2.associative  = 4;
	L2.linesize     = 64;
	break;
      case 0x41 :
	L2.size         = 128;
	L2.associative  = 4;
	L2.linesize     = 32;
	break;
      case 0x42 :
	L2.size         = 256;
	L2.associative  = 4;
	L2.linesize     = 32;
	break;
      case 0x43 :
	L2.size         = 512;
	L2.associative  = 4;
	L2.linesize     = 32;
	break;
      case 0x44 :
	L2.size         = 1024;
	L2.associative  = 4;
	L2.linesize     = 32;
	break;
      case 0x45 :
	L2.size         = 2048;
	L2.associative  = 4;
	L2.linesize     = 32;
	break;
      case 0x46 :
	L3.size         = 4096;
	L3.associative  = 4;
	L3.linesize     = 64;
	break;
      case 0x47 :
	L3.size         = 8192;
	L3.associative  = 8;
	L3.linesize     = 64;
	break;
      case 0x49 :
	L2.size         = 4096;
	L2.associative  = 16;
	L2.linesize     = 64;
	break;
      case 0x4a :
	L3.size         = 6144;
	L3.associative  = 12;
	L3.linesize     = 64;
	break;
      case 0x4b :
	L3.size         = 8192;
	L3.associative  = 16;
	L3.linesize     = 64;
	break;
      case 0x4c :
	L3.size         = 12280;
	L3.associative  = 12;
	L3.linesize     = 64;
	break;
      case 0x4d :
	L3.size         = 16384;
	L3.associative  = 16;
	L3.linesize     = 64;
	break;
      case 0x4e :
	L2.size         = 6144;
	L2.associative  = 24;
	L2.linesize     = 64;
	break;
      case 0x50 :
	ITB.size         = 4;
	ITB.associative  = 0;
	ITB.linesize     = 64;
	LITB.size        = 4096;
	LITB.associative = 0;
	LITB.linesize    = 64;
	LITB.shared      = 1;
	break;
      case 0x51 :
	ITB.size        = 4;
	ITB.associative = 0;
	ITB.linesize     = 128;
	LITB.size        = 4096;
	LITB.associative = 0;
	LITB.linesize    = 128;
	LITB.shared      = 1;
	break;
      case 0x52 :
	ITB.size         = 4;
	ITB.associative  = 0;
	ITB.linesize     = 256;
	LITB.size        = 4096;
	LITB.associative = 0;
	LITB.linesize    = 256;
	LITB.shared      = 1;
	break;
      case 0x56 :
	LDTB.size        = 4096;
	LDTB.associative = 4;
	LDTB.linesize    = 16;
	break;
      case 0x57 :
	LDTB.size        = 4096;
	LDTB.associative = 4;
	LDTB.linesize    = 16;
	break;
      case 0x5b :
	DTB.size         = 4;
	DTB.associative  = 0;
	DTB.linesize     = 64;
	LDTB.size        = 4096;
	LDTB.associative = 0;
	LDTB.linesize    = 64;
	LDTB.shared      = 1;
	break;
      case 0x5c :
	DTB.size         = 4;
	DTB.associative  = 0;
	DTB.linesize     = 128;
	LDTB.size        = 4096;
	LDTB.associative = 0;
	LDTB.linesize    = 128;
	LDTB.shared      = 1;
	break;
      case 0x5d :
	DTB.size         = 4;
	DTB.associative  = 0;
	DTB.linesize     = 256;
	LDTB.size        = 4096;
	LDTB.associative = 0;
	LDTB.linesize    = 256;
	LDTB.shared      = 1;
	break;
      case 0x60 :
	LD1.size        = 16;
	LD1.associative = 8;
	LD1.linesize    = 64;
	break;
      case 0x66 :
	LD1.size        = 8;
	LD1.associative = 4;
	LD1.linesize    = 64;
	break;
      case 0x67 :
	LD1.size        = 16;
	LD1.associative = 4;
	LD1.linesize    = 64;
	break;
      case 0x68 :
	LD1.size        = 32;
	LD1.associative = 4;
	LD1.linesize    = 64;
	break;
      case 0x70 :
	LC1.size        = 12;
	LC1.associative = 8;
	break;
      case 0x71 :
	LC1.size        = 16;
	LC1.associative = 8;
	break;
      case 0x72 :
	LC1.size        = 32;
	LC1.associative = 8;
	break;
      case 0x73 :
	LC1.size        = 64;
	LC1.associative = 8;
	break;
      case 0x77 :
	LC1.size        = 16;
	LC1.associative = 4;
	LC1.linesize    = 64;
	break;
      case 0x78 :
	L2.size        = 1024;
	L2.associative = 4;
	L2.linesize    = 64;
	break;
      case 0x79 :
	L2.size         = 128;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x7a :
	L2.size         = 256;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x7b :
	L2.size         = 512;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x7c :
	L2.size         = 1024;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x7d :
	L2.size         = 2048;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x7e :
	L2.size         = 256;
	L2.associative  = 8;
	L2.linesize     = 128;
	break;
      case 0x7f :
	L2.size         = 512;
	L2.associative  = 2;
	L2.linesize     = 64;
	break;
      case 0x81 :
	L2.size         = 128;
	L2.associative  = 8;
	L2.linesize     = 32;
	break;
      case 0x82 :
	L2.size         = 256;
	L2.associative  = 8;
	L2.linesize     = 32;
	break;
      case 0x83 :
	L2.size         = 512;
	L2.associative  = 8;
	L2.linesize     = 32;
	break;
      case 0x84 :
	L2.size         = 1024;
	L2.associative  = 8;
	L2.linesize     = 32;
	break;
      case 0x85 :
	L2.size         = 2048;
	L2.associative  = 8;
	L2.linesize     = 32;
	break;
      case 0x86 :
	L2.size         = 512;
	L2.associative  = 4;
	L2.linesize     = 64;
	break;
      case 0x87 :
	L2.size         = 1024;
	L2.associative  = 8;
	L2.linesize     = 64;
	break;
      case 0x88 :
	L3.size         = 2048;
	L3.associative  = 4;
	L3.linesize     = 64;
	break;
      case 0x89 :
	L3.size         = 4096;
	L3.associative  = 4;
	L3.linesize     = 64;
	break;
      case 0x8a :
	L3.size         = 8192;
	L3.associative  = 4;
	L3.linesize     = 64;
	break;
      case 0x8d :
	L3.size         = 3096;
	L3.associative  = 12;
	L3.linesize     = 128;
	break;
      case 0x90 :
	ITB.size        = 4;
	ITB.associative = 0;
	ITB.linesize    = 64;
	break;
      case 0x96 :
	DTB.size        = 4;
	DTB.associative = 0;
	DTB.linesize    = 32;
	break;
      case 0x9b :
	L2DTB.size        = 4;
	L2DTB.associative = 0;
	L2DTB.linesize    = 96;
	break;
      case 0xb0 :
	ITB.size        = 4;
	ITB.associative = 4;
	ITB.linesize    = 128;
	break;
      case 0xb1 :
	LITB.size        = 4096;
	LITB.associative = 4;
	LITB.linesize    = 4;
	break;
      case 0xb3 :
	DTB.size        = 4;
	DTB.associative = 4;
	DTB.linesize    = 128;
	break;
      case 0xb4 :
	DTB.size        = 4;
	DTB.associative = 4;
	DTB.linesize    = 256;
	break;
      }
    }
  }

  if (get_vendor() == VENDOR_INTEL) {
    cpuid(0x80000000, &cpuid_level, &ebx, &ecx, &edx);
    if (cpuid_level >= 0x80000006) {
      cpuid(0x80000006, &eax, &ebx, &ecx, &edx);

      L2.size         = BITMASK(ecx, 16, 0xffff);
      L2.associative  = BITMASK(ecx, 12, 0x0f);
      L2.linesize     = BITMASK(ecx,  0, 0xff);
    }
  }

  if ((get_vendor() == VENDOR_AMD) || (get_vendor() == VENDOR_CENTAUR)) {
    cpuid(0x80000005, &eax, &ebx, &ecx, &edx);

    LDTB.size        = 4096;
    LDTB.associative = BITMASK(eax, 24, 0xff);
    if (LDTB.associative == 0xff) LDTB.associative = 0;
    LDTB.linesize    = BITMASK(eax, 16, 0xff);

    LITB.size        = 4096;
    LITB.associative = BITMASK(eax,  8, 0xff);
    if (LITB.associative == 0xff) LITB.associative = 0;
    LITB.linesize    = BITMASK(eax,  0, 0xff);
    
    DTB.size        = 4;
    DTB.associative = BITMASK(ebx, 24, 0xff);
    if (DTB.associative == 0xff) DTB.associative = 0;
    DTB.linesize    = BITMASK(ebx, 16, 0xff);

    ITB.size        = 4;
    ITB.associative = BITMASK(ebx,  8, 0xff);
    if (ITB.associative == 0xff) ITB.associative = 0;
    ITB.linesize    = BITMASK(ebx,  0, 0xff);

    LD1.size        = BITMASK(ecx, 24, 0xff);
    LD1.associative = BITMASK(ecx, 16, 0xff);
    if (LD1.associative == 0xff) LD1.associative = 0;
    LD1.linesize    = BITMASK(ecx,  0, 0xff);

    LC1.size        = BITMASK(ecx, 24, 0xff);
    LC1.associative = BITMASK(ecx, 16, 0xff);
    if (LC1.associative == 0xff) LC1.associative = 0;
    LC1.linesize    = BITMASK(ecx,  0, 0xff);

    cpuid(0x80000006, &eax, &ebx, &ecx, &edx);

    L2LDTB.size        = 4096;
    L2LDTB.associative = BITMASK(eax, 24, 0xff);
    if (L2LDTB.associative == 0xff) L2LDTB.associative = 0;
    L2LDTB.linesize    = BITMASK(eax, 16, 0xff);

    L2LITB.size        = 4096;
    L2LITB.associative = BITMASK(eax,  8, 0xff);
    if (L2LITB.associative == 0xff) L2LITB.associative = 0;
    L2LITB.linesize    = BITMASK(eax,  0, 0xff);
    
    L2DTB.size        = 4;
    L2DTB.associative = BITMASK(ebx, 24, 0xff);
    if (L2DTB.associative == 0xff) L2DTB.associative = 0;
    L2DTB.linesize    = BITMASK(ebx, 16, 0xff);

    L2ITB.size        = 4;
    L2ITB.associative = BITMASK(ebx,  8, 0xff);
    if (L2ITB.associative == 0xff) L2ITB.associative = 0;
    L2ITB.linesize    = BITMASK(ebx,  0, 0xff);

    L2.size        = BITMASK(ecx, 16, 0xffff);
    L2.associative = BITMASK(ecx, 12, 0xf);
    if (L2.associative == 0xff) L2.associative = 0;
    L2.linesize    = BITMASK(ecx,  0, 0xff);
  }

    switch (type) {
      
    case CACHE_INFO_L1_I :
      *cacheinfo = LC1;
      break;
    case CACHE_INFO_L1_D :
      *cacheinfo = LD1;
      break;
    case CACHE_INFO_L2 :
      *cacheinfo = L2;
      break;
    case CACHE_INFO_L3 :
      *cacheinfo = L3;
      break;
    case CACHE_INFO_L1_DTB :
      *cacheinfo = DTB;
      break;
    case CACHE_INFO_L1_ITB :
      *cacheinfo = ITB;
      break;
    case CACHE_INFO_L1_LDTB :
      *cacheinfo = LDTB;
      break;
    case CACHE_INFO_L1_LITB :
      *cacheinfo = LITB;
      break;
    case CACHE_INFO_L2_DTB :
      *cacheinfo = L2DTB;
      break;
    case CACHE_INFO_L2_ITB :
      *cacheinfo = L2ITB;
      break;
    case CACHE_INFO_L2_LDTB :
      *cacheinfo = L2LDTB;
      break;
    case CACHE_INFO_L2_LITB :
      *cacheinfo = L2LITB;
      break;
    }
  return 0;
}

int get_cpuname(void){

  int family, exfamily, model, vendor, exmodel;

  if (!have_cpuid()) return CPUTYPE_80386;

  family   = get_cputype(GET_FAMILY);
  exfamily = get_cputype(GET_EXFAMILY);
  model    = get_cputype(GET_MODEL);
  exmodel  = get_cputype(GET_EXMODEL);

  vendor = get_vendor();

  if (vendor == VENDOR_INTEL){
    switch (family) {
    case 0x4:
      return CPUTYPE_80486;
    case 0x5:
      return CPUTYPE_PENTIUM;
    case 0x6:
      switch (exmodel) {
      case 0: 
	if ((model >= 3) && (model <= 6)) return CPUTYPE_PENTIUM2;
	if (((model >=  7) && (model <= 8)) ||
	    ((model >= 10) && (model <= 11))) return CPUTYPE_PENTIUM3;
	if ((model == 9) || 
	    ((model >= 13) && (model <= 14))) return CPUTYPE_PENTIUMM;
	if (model == 15) return CPUTYPE_CORE2;
	break;
      case 1:
	if (model == 6) return  CPUTYPE_CORE2;
	if (model == 7) return  CPUTYPE_PENRYN;
	break;
      }
      break;
    case 0x7:
      return CPUTYPE_ITANIUM;
    case 0xf:
      switch (exfamily) {
      case 0 :
	return CPUTYPE_PENTIUM4;
      case 1 :
	return CPUTYPE_ITANIUM;
      }
      break;
    }
    return CPUTYPE_INTEL_UNKNOWN;
  }

  if (vendor == VENDOR_AMD){
    switch (family) {
    case 0x4:
      return CPUTYPE_AMD5X86;
    case 0x5:
      return CPUTYPE_AMDK6;
    case 0x6:
      return CPUTYPE_ATHLON;
    case 0xf:
      switch (exfamily) {
      case 0 :
	return CPUTYPE_OPTERON;
      case 1 :
	return CPUTYPE_BARCELONA;
      }
      break;
    }
    return CPUTYPE_AMD_UNKNOWN;
  }

  if (vendor == VENDOR_CYRIX){
    switch (family) {
    case 0x4:
      return CPUTYPE_CYRIX5X86;
    case 0x5:
      return CPUTYPE_CYRIXM1;
    case 0x6:
      return CPUTYPE_CYRIXM2;
    }
    return CPUTYPE_CYRIX_UNKNOWN;
  }

  if (vendor == VENDOR_NEXGEN){
    switch (family) {
    case 0x5:
      return CPUTYPE_NEXGENNX586;
    }
    return CPUTYPE_NEXGEN_UNKNOWN;
  }

  if (vendor == VENDOR_CENTAUR){
    switch (family) {
    case 0x5:
      return CPUTYPE_CENTAURC6;
    }
    return CPUTYPE_VIAC3;
  }

  if (vendor == VENDOR_RISE){
    switch (family) {
    case 0x5:
      return CPUTYPE_RISEMP6;
    }
    return CPUTYPE_RISE_UNKNOWN;
  }

  if (vendor == VENDOR_SIS){
    switch (family) {
    case 0x5:
      return CPUTYPE_SYS55X;
    }
    return CPUTYPE_SIS_UNKNOWN;
  }

  if (vendor == VENDOR_TRANSMETA){
    switch (family) {
    case 0x5:
      return CPUTYPE_CRUSOETM3X;
    }
    return CPUTYPE_TRANSMETA_UNKNOWN;
  }

  if (vendor == VENDOR_NSC){
    switch (family) {
    case 0x5:
      return CPUTYPE_NSGEODE;
    }
    return CPUTYPE_NSC_UNKNOWN;
  }

  return CPUTYPE_UNKNOWN;
}

static char *cpuname[] = {
  "UNKNOWN",
  "INTEL_UNKNOWN",
  "UMC_UNKNOWN",
  "AMD_UNKNOWN",
  "CYRIX_UNKNOWN",
  "NEXGEN_UNKNOWN",
  "CENTAUR_UNKNOWN",
  "RISE_UNKNOWN",
  "SIS_UNKNOWN",
  "TRANSMETA_UNKNOWN",
  "NSC_UNKNOWN",
  "80386",
  "80486",
  "PENTIUM",
  "PENTIUM2",
  "PENTIUM3",
  "PENTIUMM",
  "PENTIUM4",
  "CORE2",
  "PENRYN",
  "ITANIUM",
  "ITANIUM2",
  "5X86",
  "K6",
  "ATHLON",
  "DURON",
  "OPTERON",
  "BARCELONA",
  "CYRIX5X86",
  "CYRIXM1",
  "CYRIXM2",
  "NEXGENNX586",
  "CENTAURC6",
  "RISEMP6",
  "SYS55X",
  "TM3X00",
  "NSGEODE",
  "VIAC3",
};

static char *lowercpuname[] = {
  "unknown",
  "intel_unknown",
  "umc_unknown",
  "amd_unknown",
  "cyrix_unknown",
  "nexgen_unknown",
  "centaur_unknown",
  "rise_unknown",
  "sis_unknown",
  "transmeta_unknown",
  "nsc_unknown",
  "80386",
  "80486",
  "pentium",
  "pentium2",
  "pentium3",
  "pentiumm",
  "pentium4",
  "core2",
  "penryn",
  "itanium",
  "itanium2",
  "5x86",
  "k6",
  "athlon",
  "duron",
  "opteron",
  "barcelona",
  "cyrix5x86",
  "cyrixm1",
  "cyrixm2",
  "nexgennx586",
  "centaurc6",
  "risemp6",
  "sys55x",
  "tms3x00",
  "nsgeode",
};

static char *corename[] = {
  "UNKOWN",
  "80486", 
  "P5",
  "KATMAI",
  "COPPERMINE",
  "NORTHWOOD",
  "PRESCOTT",
  "BANIAS",
  "ATHLON",
  "OPTERON",
  "BARCELONA",
  "VIAC3",
  "YONAH",
  "CORE2",
  "PENRYN",
};

static char *corename_lower[] = {
  "unknown",
  "80486", 
  "p5",
  "katmai",
  "coppermine",
  "northwood",
  "prescott",
  "banias",
  "athlon",
  "opteron",
  "barcelona",
  "viac3",
  "yonah",
  "core2",
  "penryn",
};


char *get_cpunamechar(void){
  return cpuname[get_cpuname()];
}

char *get_lower_cpunamechar(void){
  return lowercpuname[get_cpuname()];
}


int get_coretype(void){

  int family, exfamily, model, exmodel, vendor;

  if (!have_cpuid()) return CORE_80486;

  family   = get_cputype(GET_FAMILY);
  exfamily = get_cputype(GET_EXFAMILY);
  model    = get_cputype(GET_MODEL);
  exmodel  = get_cputype(GET_EXMODEL);

  vendor = get_vendor();

  if (vendor == VENDOR_INTEL){
    switch (family) {
    case 0x4:
      return CORE_80486;
    case 0x5:
      return CORE_P5;
    case 0x6:
      switch (exmodel) {
      case 0:
	if (model <= 0x7) return CORE_KATMAI;
	if ((model == 0x8) || (model == 0xa) || (model == 0xb)) return CORE_COPPERMINE;
	if ((model == 0x9) || (model == 0xd)) return CORE_BANIAS;
#if 0
	if (model == 14) return CORE_YONAH;
#else
	if (model == 14) return CORE_BANIAS;
#endif
	if (model == 15) return CORE_CORE2;
	return CORE_UNKNOWN;
      case 1:
	if (model == 6) return CORE_CORE2;
	if (model == 7) return CORE_PENRYN;
	return CORE_UNKNOWN;
      }
      case 0xf:
      if (model <= 0x2) return CORE_NORTHWOOD;
      return CORE_PRESCOTT;
    }
  }

  if (vendor == VENDOR_AMD){
    if (family <= 0x5) return CORE_80486;
    if (family <= 0xe) return CORE_ATHLON;
    if (family <= 0xf){
      if (exfamily == 0) return CORE_OPTERON; else return CORE_BARCELONA;
    }
  }

  if (vendor == VENDOR_CENTAUR) return CORE_VIAC3;

  return CORE_UNKNOWN;
}

void get_cpuconfig(void){

  cache_info_t info;
  int features;

#ifndef __64BIT__
  printf("-DARCH_X86 ");
#else
  printf("-DARCH_X86_64 ");
#endif

  printf("-D%s ", cpuname[get_cpuname()]);

  get_cacheinfo(CACHE_INFO_L1_I, &info);
  if (info.size > 0) {
    printf("-DL1_CODE_SIZE=%d ", info.size * 1024);
    printf("-DL1_CODE_ASSOCIATIVE=%d ", info.associative);
    printf("-DL1_CODE_LINESIZE=%d ", info.linesize);
  }

  get_cacheinfo(CACHE_INFO_L1_D, &info);
  if (info.size > 0) {
    printf("-DL1_DATA_SIZE=%d ", info.size * 1024);
    printf("-DL1_DATA_ASSOCIATIVE=%d ", info.associative);
    printf("-DL1_DATA_LINESIZE=%d ", info.linesize);
  }

  get_cacheinfo(CACHE_INFO_L2, &info);
  if (info.size > 0) {
    printf("-DL2_SIZE=%d ", info.size * 1024);
    printf("-DL2_ASSOCIATIVE=%d ", info.associative);
    printf("-DL2_LINESIZE=%d ", info.linesize);
  }

  get_cacheinfo(CACHE_INFO_L3, &info);
  if (info.size > 0) {
    printf("-DL3_SIZE=%d ", info.size * 1024);
    printf("-DL3_ASSOCIATIVE=%d ", info.associative);
    printf("-DL3_LINESIZE=%d ", info.linesize);
  }

  get_cacheinfo(CACHE_INFO_L1_ITB, &info);
  if (info.size > 0) {
    printf("-DITB_SIZE=%d ", info.size * 1024);
    printf("-DITB_ASSOCIATIVE=%d ", info.associative);
    printf("-DITB_ENTRIES=%d ", info.linesize);
  }

  get_cacheinfo(CACHE_INFO_L1_DTB, &info);
  if (info.size > 0) {
    printf("-DDTB_SIZE=%d ", info.size * 1024);
    printf("-DDTB_ASSOCIATIVE=%d ", info.associative);
    printf("-DDTB_ENTRIES=%d ", info.linesize);
  }
  
  features = get_cputype(GET_FEATURE);

  if (features & HAVE_CMOV )   printf("-DHAVE_CMOV ");
  if (features & HAVE_MMX  )   printf("-DHAVE_MMX ");
  if (features & HAVE_SSE  )   printf("-DHAVE_SSE ");
  if (features & HAVE_SSE2 )   printf("-DHAVE_SSE2 ");
  if (features & HAVE_SSE3 )   printf("-DHAVE_SSE3 ");
  if (features & HAVE_SSSE3)   printf("-DHAVE_SSSE3 ");
  if (features & HAVE_SSE4_1)   printf("-DHAVE_SSE4_1 ");
  if (features & HAVE_SSE4_2)   printf("-DHAVE_SSE4_2 ");
  if (features & HAVE_SSE4A)   printf("-DHAVE_SSE4A ");
  if (features & HAVE_SSE5 )   printf("-DHAVE_SSSE5 ");
  if (features & HAVE_3DNOWEX) printf("-DHAVE_3DNOWEX ");
  if (features & HAVE_3DNOW)   printf("-DHAVE_3DNOW ");
  if (features & HAVE_CFLUSH)  printf("-DHAVE_CFLUSH ");
  if (features & HAVE_HIT)     printf("-DHAVE_HIT=1 ");
  if (features & HAVE_MISALIGNSSE) printf("-DHAVE_MISALIGNSSE ");
  if (features & HAVE_128BITFPU)   printf("-DHAVE_128BITFPU ");
  if (features & HAVE_FASTMOVU)    printf("-DHAVE_FASTMOVU ");

  printf("-DNUM_SHAREDCACHE=%d ", get_cputype(GET_NUMSHARE) + 1);
  printf("-DNUM_CORES=%d ", get_cputype(GET_NUMCORES) + 1);

  features = get_coretype();
  if (features > 0) printf("-DCORE_%s ", corename[features]);

  printf("\n");
}

void get_architecture(void){
#ifndef __64BIT__
    printf("X86");
#else
    printf("X86_64");
#endif
}

void get_subarchitecture(void){
    printf("%s", get_cpunamechar());
}

void get_subdirname(void){
#ifndef __64BIT__
    printf("x86");
#else
    printf("x86_64");
#endif
}

char *get_corename(void){
  return corename[get_coretype()];
}

void get_libname(void){
  printf("%s",   corename_lower[get_coretype()]);
}
