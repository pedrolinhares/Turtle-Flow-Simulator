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

#include  <sys/utsname.h>
#ifdef _AIX
#include <sys/vminfo.h>
#endif

#define CPUTYPE_UNKNOWN    0
#define CPUTYPE_POWER3     1
#define CPUTYPE_POWER4     2
#define CPUTYPE_PPC970     3
#define CPUTYPE_POWER5     4
#define CPUTYPE_CELL       5

char *cpuname[] = {
  "UNKNOWN",
  "POWER3",
  "POWER4",
  "PPC970",
  "POWER5",
  "CELL",
};

char *lowercpuname[] = {
  "unknown",
  "power3",
  "power4",
  "ppc970",
  "power5",
  "cell",
};

char *corename[] = {
  "UNKNOWN",
  "POWER3",
  "POWER4",
  "POWER4",
  "POWER4",
  "CELL",
};

int detect(void){

#ifdef linux
  FILE *infile;
  char buffer[512], *p;

  p = (char *)NULL;
  infile = fopen("/proc/cpuinfo", "r");
  while (fgets(buffer, sizeof(buffer), infile)){
    if (!strncmp("cpu", buffer, 3)){
	p = strchr(buffer, ':') + 2;
#if 0
	fprintf(stderr, "%s\n", p);
#endif
	break;
      }
  }

  fclose(infile);

  if (!strncasecmp(p, "POWER3", 6)) return CPUTYPE_POWER3;
  if (!strncasecmp(p, "POWER4", 6)) return CPUTYPE_POWER4;
  if (!strncasecmp(p, "PPC970", 6)) return CPUTYPE_PPC970;
  if (!strncasecmp(p, "POWER5", 6)) return CPUTYPE_POWER5;
  if (!strncasecmp(p, "Cell",   4)) return CPUTYPE_CELL;

  return CPUTYPE_UNKNOWN;
#endif

#ifdef _AIX
  return CPUTYPE_POWER5;
#endif

#ifdef __APPLE__
  return  CPUTYPE_PPC970;
#endif
}

void get_architecture(void){
  printf("POWER");
}

void get_subdirname(void){
    printf("power");
}


void get_subarchitecture(void){
  printf("%s", cpuname[detect()]);
}

void get_cpuconfig(void){
#if 0
#ifdef _AIX
  struct vminfo info;
#endif
#endif

  printf("-DARCH_POWER -D%s -DCORE_%s ", cpuname[detect()], corename[detect()]);
  printf("-DL1_DATA_SIZE=32768 -DL1_DATA_LINESIZE=128 "
	 "-DL2_SIZE=524288 -DL2_LINESIZE=128 "
	 "-DDTB_ENTRIES=128 -DDTB_SIZE=4096 -DL2_ASSOCIATIVE=8 ");

#if 0
#ifdef _AIX
  if (vmgetinfo(&info, VMINFO, 0) == 0) {
    if ((info.lgpg_size >> 20) >= 1024) {
      printf("-DALLOC_HUGETLB ");
    }
  }
#endif
#endif

}

void get_libname(void){
  printf("%s", lowercpuname[detect()]);
}

char *get_corename(void){
  return cpuname[detect()];
}
