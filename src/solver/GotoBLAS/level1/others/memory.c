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

#undef  DEBUG
#undef  DEBUG_AFFINITY

#if (!defined(ARCH_X86) && !defined(ARCH_X86_64)) || \
     !defined(SMP_SERVER) || !defined(linux) || (MAX_CPU_NUMBER == 1)
#undef USE_CPU_AFFINITY
#undef USE_MEMORY_AFFINITY
#endif

#if defined(linux) && !defined(USE_CPU_AFFINITY) && defined(USE_MEMORY_AFFINITY)
#define USE_CPU_AFFINITY
#endif

#ifndef ALLOC_STATIC
#if defined( __WIN32__) || defined(__CYGWIN32__) || defined(__WIN64__)
#define ALLOC_WINDOWS
#ifndef __CYGWIN32__
#include <tchar.h>
#endif
#else
#define ALLOC_MMAP
#define ALLOC_MALLOC
#endif
#endif

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#ifdef __unix__
#include <pthread.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#endif
#include <sys/types.h>
#ifdef linux
#include <sys/sysinfo.h>
#include <sched.h>
#include <errno.h>
#include <linux/unistd.h>
#if 0
#ifdef USE_MEMORY_AFFINITY
#include <linux/mempolicy.h>
#endif
#endif
#endif

#if defined(__WIN32__) || defined(__WIN64__) || defined(__CYGWIN32__)
#include <windows.h>
#endif

#ifdef USE_MEMORY_AFFINITY
#include <numa.h>
#include <numaif.h>
#endif

#if defined(__FreeBSD__) || defined(__APPLE__)
#include <sys/sysctl.h>
#endif

#include "common.h"

#ifdef ALLOC_HUGETLB
#define SHM_HUGETLB 04000
#endif

#ifdef USE_CPU_AFFINITY

static inline int get_physical_pos(void){
  int eax, ebx, ecx, edx;
  int apicid;

  cpuid(1, &eax, &ebx, &ecx, &edx);
  apicid  = BITMASK(ebx, 24, 0xff);

  return apicid;
}

#ifdef CORE2
static int CPU_mapping[] = {0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7};
#define STATIC_MAPPING
#endif

#if defined(OPTERON) || defined(BARCELONA)
static int CPU_mapping[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
#define STATIC_MAPPING
#endif


#if NUM_BUFFERS > 16
#undef STATIC_MAPPING
#endif

#endif

#ifdef USE_MEMORY_AFFINITY

/* This function works only on Opteron/Prescott */
static inline int get_num_cores(void){

  int ncores;

#if   defined(CORE_PRESCOTT)
  int eax, ebx, ecx, edx;

  cpuid(4, &eax, &ebx, &ecx, &edx);
  ncores = BITMASK(eax, 26, 0x3f) + 1;
#elif defined(CORE_OPTERON) || defined(BARCELONA)
  int eax, ebx, ecx, edx;

  cpuid(0x80000008, &eax, &ebx, &ecx, &edx);
  ncores = BITMASK(ecx,  0, 0xff) + 1;
#else
  ncores = 1;
#endif

  return ncores;
}
#endif

#ifndef FIXED_PAGESIZE
#define FIXED_PAGESIZE 4096
#endif

#define BITMASK(a, b, c) ((((a) >> (b)) & (c)))

#ifndef SMP

#define blas_cpu_number 1

#else

#ifdef linux

extern int omp_get_num_procs(void) __attribute__ ((weak));

static inline BLASLONG get_num_procs(void) {
  
  cpu_set_t cpu_mask;
  BLASLONG rv;
  BLASLONG num_procs = get_nprocs();
  BLASLONG i, count;

  rv = sched_getaffinity((pid_t)0, sizeof(cpu_mask), &cpu_mask);

  if (rv) return num_procs;

  count = 0;

  for (i = 0; i < num_procs; i ++) { if (CPU_ISSET(i, &cpu_mask)) count ++; }

  return count;
}

#endif

#if defined(__WIN32__) || defined(__WIN64__) || defined(__CYGWIN32__)

static inline BLASLONG get_num_procs(void) {
  
  SYSTEM_INFO sysinfo;

  GetSystemInfo(&sysinfo);
  
  return sysinfo.dwNumberOfProcessors;
}

#endif

#if defined(__FreeBSD__) || defined(__APPLE__)

static inline BLASLONG get_num_procs(void) {
  
  int m[2], count;
  size_t len;
  
  m[0] = CTL_HW;
  m[1] = HW_NCPU;
  len = sizeof(int);
  sysctl(m, 2, &count, &len, NULL, 0);
  
  return count;
}

#endif

/* Global Parameter */
int blas_cpu_number = 0;
int blas_omp_linked = 0;

int blas_get_cpu_number(void){
  char *p;
#if defined(linux) || defined(__WIN32__) || defined(__WIN64__) || defined(__FreeBSD__) || defined(__APPLE__)
  int max_num;
#endif
  int blas_goto_num   = 0;
  int blas_omp_num    = 0;

  if (blas_cpu_number) return blas_cpu_number;

#if defined(linux) || defined(__WIN32__) || defined(__WIN64__) || defined(__FreeBSD__) || defined(__APPLE__)
  max_num = get_num_procs();
#endif

  blas_goto_num = 0;
  p = getenv("GOTO_NUM_THREADS");
  if (p) blas_goto_num = atoi(p);
  if (blas_goto_num < 0) blas_goto_num = 0;

  blas_omp_num = 0;
  p = getenv("OMP_NUM_THREADS");
  if (p) blas_omp_num = atoi(p);
  if (blas_omp_num < 0) blas_omp_num = 0;

#if defined(linux) && !defined(__PGI)
  blas_omp_linked = (omp_get_num_procs != 0);
#else
  blas_omp_linked = 0;
#endif

  if (!blas_omp_linked) {
    if (blas_goto_num > 0) blas_cpu_number = blas_goto_num;
    else if (blas_omp_num > 0) blas_cpu_number = blas_omp_num;
    else blas_cpu_number = MAX_CPU_NUMBER;
  } else {
    if (blas_goto_num == 0) blas_goto_num = 1;
    if (blas_omp_num  == 0) blas_omp_num  = 1;
    blas_cpu_number = blas_goto_num * blas_omp_num;
  }

#if defined(linux) || defined(__WIN32__) || defined(__WIN64__) || defined(__FreeBSD__) || defined(__APPLE__)
  //  if (blas_cpu_number > max_num) blas_cpu_number = max_num;
#endif

  if (blas_cpu_number > MAX_CPU_NUMBER) blas_cpu_number = MAX_CPU_NUMBER;

#ifdef DEBUG
    printf( "Adjusted number of threads : %3d\n", blas_cpu_number);
#endif

  return blas_cpu_number;
}
#endif

#ifdef ALLOC_STATIC
extern double alloc_area[NUM_BUFFERS * BUFFER_SIZE / sizeof(double)];
#else
#ifdef SEEK_ADDRESS
static BLASULONG base_address      = 0UL;
#else
static BLASULONG base_address      = BASE_ADDRESS;
#endif
static BLASULONG alloc_area[NUM_BUFFERS];
#endif

static int alloc_used[NUM_BUFFERS];

#if   defined(USE_PTHREAD_LOCK)
static pthread_mutex_t    alloc_lock = PTHREAD_MUTEX_INITIALIZER;
#elif defined(USE_PTHREAD_SPINLOCK)
static pthread_spinlock_t alloc_lock = 0;
#else
static BLASULONG      alloc_lock = 0UL;
#endif

#ifdef ALLOC_MMAP
static void *alloc_mmap(void *address){
  void *map_address;

  if (address){
    map_address = mmap(address, 
		       BUFFER_SIZE, 
		       MMAP_ACCESS, MMAP_POLICY | MAP_FIXED, -1, 0);
  } else {
    map_address = mmap(address, 
		       BUFFER_SIZE, 
		       MMAP_ACCESS, MMAP_POLICY, -1, 0);
  }

  return map_address;
}
#endif

#ifdef ALLOC_MALLOC
static void *alloc_malloc(void *address){
  void *map_address;

  map_address = (void *)malloc(BUFFER_SIZE + FIXED_PAGESIZE);

  /* Dangerous. Never release this area */
  return (void *)(((BLASLONG)map_address + FIXED_PAGESIZE - 1) & ~(FIXED_PAGESIZE - 1));
}
#endif

#ifdef ALLOC_QALLOC
void *qalloc(int flags, size_t bytes);
#define QNONCACHE 0x1
#define QCOMMS    0x2
#define QFAST     0x4

static void *alloc_qalloc(void *address){
  void *map_address;

  map_address = (void *)qalloc(QCOMMS | QFAST, BUFFER_SIZE + FIXED_PAGESIZE);

  return (void *)(((BLASLONG)map_address + FIXED_PAGESIZE - 1) & ~(FIXED_PAGESIZE - 1));
}
#endif

#ifdef ALLOC_WINDOWS
static void *alloc_windows(void *address){
  void *map_address;

  map_address  = VirtualAlloc(address,
			      BUFFER_SIZE,
			      MEM_RESERVE | MEM_COMMIT,
			      PAGE_READWRITE);

  return map_address;
}
#endif

#ifdef ALLOC_BIGPHYSAREA

#ifndef BIGPHYS_DEVICE_NAME
#define BIGPHYS_DEVICE_NAME "/dev/mapper"
#endif

static void *alloc_bigphysarea(void *address){
  
  int fd;
  void *map_address;

  if ((fd = open(BIGPHYS_DEVICE_NAME, O_RDWR | O_SYNC)) < 0) {
    fprintf(stderr, "BLAS warining : failed allocation for bigphysarea\n");
    return (void *)-1;
  }

  map_address = mmap(address, BUFFER_SIZE,
		     PROT_READ | PROT_WRITE,
		     MAP_SHARED| MAP_LOCKED,
		     fd, 0);
  
  return map_address;
}
#endif

#ifdef ALLOC_SHM
static void *alloc_shm(void *address){
  BLASULONG map_address;
  int shmid;
  
  shmid = shmget(IPC_PRIVATE, BUFFER_SIZE,IPC_CREAT | 0600);
  
  map_address = (BLASULONG)shmat(shmid, address, 0);

  if ((BLASLONG)map_address != -1){
    shmctl(shmid, IPC_RMID, 0);
  }

  return (void *)map_address;
}
#endif

#ifdef ALLOC_HUGETLB
static void *alloc_hugetlb(void *address){
  BLASULONG map_address = (BLASULONG)-1;

#if defined(linux) || defined(_AIX)
  int shmid;
  
  shmid = shmget(IPC_PRIVATE, BUFFER_SIZE,
#ifdef linux
		 SHM_HUGETLB |
#endif
#ifdef _AIX
		 SHM_LGPAGE | SHM_PIN |
#endif
		 IPC_CREAT | SHM_R | SHM_W);
  
  if (shmid != -1) {
    map_address = (BLASULONG)shmat(shmid, address, SHM_RND);
    
    if ((BLASLONG)map_address != -1){
      shmctl(shmid, IPC_RMID, 0);
    }
  }
#endif

#ifdef __sun__
  struct memcntl_mha mha;
  
  mha.mha_cmd = MHA_MAPSIZE_BSSBRK;
  mha.mha_flags = 0;
  mha.mha_pagesize = HUGE_PAGESIZE;
  memcntl(NULL, 0, MC_HAT_ADVISE, (char *)&mha, 0, 0);

  map_address = (BLASULONG)memalign(HUGE_PAGESIZE, BUFFER_SIZE);
#endif

#if defined(__WIN32__) || defined(__WIN64__)

  HANDLE hToken;
  TOKEN_PRIVILEGES tp;

  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken);

  LookupPrivilegeValue(NULL, "SeLockMemoryPrivilege", &tp.Privileges[0].Luid);

  tp.PrivilegeCount = 1;
  tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

  AdjustTokenPrivileges(hToken, FALSE, &tp, 0, (PTOKEN_PRIVILEGES)NULL, 0);

  map_address  = VirtualAlloc(address,
			      BUFFER_SIZE,
			      MEM_LARGE_PAGES | MEM_RESERVE | MEM_COMMIT,
			      PAGE_READWRITE);

#endif

  return (void *)map_address;
}
#endif

#if defined(ARCH_X86) || defined(ARCH_X86_64) || defined(ARCH_IA64)
static int              initialized = 0;
#endif

/*       Memory allocation routine           */
/* procpos ... indicates where it comes from */
/*                0 : Level 3 functions      */
/*                1 : Level 2 functions      */
/*                2 : Thread                 */

void *blas_memory_alloc(int procpos){
  
  int position;
  long  pagesize;

#ifndef ALLOC_STATIC
  BLASULONG map_address;
#endif
#ifdef USE_CPU_AFFINITY
  unsigned long rv;
  cpu_set_t cpu_mask;
#endif
#ifdef USE_MEMORY_AFFINITY
  unsigned long  num_nodes   = numa_max_node() + 1;
  unsigned long  mem_mask[2] = {(1 << num_nodes) - 1, 0};
#endif

  void *(*memoryalloc[])(void *address) = {
#ifdef ALLOC_BIGPHYSAREA
    alloc_bigphysarea,
#endif
#ifdef ALLOC_HUGETLB
    alloc_hugetlb,
#endif
#ifdef ALLOC_SHM
    alloc_shm,
#endif
#ifdef ALLOC_MMAP
    alloc_mmap,
#endif
#ifdef ALLOC_QALLOC
    alloc_qalloc,
#endif
#ifdef ALLOC_WINDOWS
    alloc_windows,
#endif
#ifdef ALLOC_MALLOC
    alloc_malloc,
#endif
    NULL,
  };
  void *(**func)(void *address);

#ifdef SMP
  if (!blas_cpu_number) blas_get_cpu_number();
#endif

  LOCK_COMMAND(&alloc_lock);
  
#ifdef DEBUG
  printf("Alloc Start ...\n");
#endif

#if MAX_CPU_NUMBER == 1
  position = 0;
#else
  if (procpos >= 2) position = 1; else position = 0;
#endif

#ifdef SMP
  if ((position == 0) && (alloc_used[0])) {
    position = MAX_CPU_NUMBER;
  }
#endif

  while (alloc_used[position]) position++;

  if ((position < 0) || (position >= NUM_BUFFERS)) goto error;

#ifdef DEBUG
  printf("  Position -> %d\n", position);
#endif

#ifndef ALLOC_STATIC

  if (!alloc_area[position]) {
    do {
#ifdef DEBUG
      printf("Allocation Start : %lx\n", base_address);
#endif

#ifdef USE_CPU_AFFINITY
      rv = sched_getaffinity((pid_t)0, sizeof(cpu_mask), &cpu_mask);

#ifdef STATIC_MAPPING
      if (rv == 0) {
	CPU_ZERO(&cpu_mask);
	CPU_SET(CPU_mapping[position], &cpu_mask);
	rv = sched_setaffinity((pid_t)0, sizeof(cpu_mask), &cpu_mask);
      }
#else
      if ((rv == 0) && (CPU_ISSET(0, &cpu_mask) & (1 << position))) {
	CPU_ZERO(&cpu_mask);
	CPU_SET(position, &cpu_mask);
	rv = sched_setaffinity((pid_t)0, sizeof(cpu_mask), &cpu_mask);
      }
#endif
#endif
      map_address = (BLASULONG)-1;
      func = &memoryalloc[0];

      while ((func != NULL) && (map_address == (BLASULONG) -1)) {
	map_address = (BLASULONG)(*func)((void *)base_address);

#ifdef ALLOC_HUGETLB
	if ((*func == alloc_hugetlb) && (map_address == (BLASULONG)-1)) {
	    fprintf(stderr, "GotoBLAS Warning ... HugeTLB alloation was failed.\n");
	}
#endif

#ifdef ALLOC_HUGETLB
	  if (*func != alloc_hugetlb) {
	    pagesize = FIXED_PAGESIZE;
	  } else {
	    pagesize = HUGE_PAGESIZE;
	  }
#else
	    pagesize = FIXED_PAGESIZE;
#endif

#ifdef USE_MEMORY_AFFINITY
	if (map_address != (BLASULONG)-1) {

#ifndef INTERLEAVED_MAPPING

	  mem_mask[0] = (1 << (position / num_nodes)); 

	  mbind((void *)map_address, BUFFER_SIZE, 
		MPOL_BIND, mem_mask, sizeof(mem_mask), MPOL_MF_STRICT | MPOL_MF_MOVE);
	  
#else
	  mbind((void *)map_address, BUFFER_SIZE, 
		MPOL_INTERLEAVE, mem_mask, sizeof(mem_mask), MPOL_MF_STRICT | MPOL_MF_MOVE);

#endif
	}
#endif

	func ++;
      }

#ifdef DEBUG
      printf("  Success -> %08lx\n", map_address);
#endif
      if (((BLASLONG) map_address) == -1) base_address = 0UL;

      if (base_address) base_address += BUFFER_SIZE + FIXED_PAGESIZE;

    } while ((BLASLONG)map_address == -1);

    alloc_area[position] = map_address; 

#ifdef DEBUG
    printf("  Mapping Succeeded. %p(%d)\n", (void *)alloc_area[position], position);
#endif
  }
 
#endif

  alloc_used[position] = 1;

#ifdef DEBUG
  printf("Mapped   : %p  %3d\n\n",
	  (void *)alloc_area[position], position);
#endif  

#if defined(ARCH_X86) || defined(ARCH_X86_64) || defined(ARCH_IA64)
  if (initialized == 0) {
    blas_set_parameter();
    initialized = 1;
  }
#endif

  UNLOCK_COMMAND(&alloc_lock);
  
#ifndef ALLOC_STATIC
  return (void *)alloc_area[position];
#else
  return ((void *)alloc_area) + position * BUFFER_SIZE;
#endif

 error:
  UNLOCK_COMMAND(&alloc_lock);
  printf("BLAS : Program is Terminated. Because you tried to allocate too many memory regions.\n");
  printf("       If you use OpenMP, MAX_THREADS in Makefile.rule should be larger than\n");
  printf("       OMP_NUM_THREADS * GOTO_NUM_THREADS.\n");
  exit(1);
}

void blas_memory_free(void *free_area){

  int position;

  LOCK_COMMAND(&alloc_lock);

#ifdef DEBUG
  printf("Unmapped Start : %p ...\n", free_area);
#endif  

#ifndef ALLOC_STATIC
  position = 0;

  while (((BLASULONG)alloc_area[position] != (BLASULONG)free_area)
	 && (position < NUM_BUFFERS)) position++;

  if ((BLASULONG)alloc_area[position] != (BLASULONG)free_area) goto error;
#else
  position = ((BLASULONG)free_area - (BLASULONG)alloc_area) / BUFFER_SIZE;
  if ((position < 0) || (position >= NUM_BUFFERS)) goto error;
#endif

#ifdef DEBUG
  printf("  Position : %d\n", position);
#endif  

  alloc_used[position] = 0;
 
#ifdef DEBUG
  printf("Unmap Succeeded.\n\n");
#endif  

  UNLOCK_COMMAND(&alloc_lock);

  return;
  
 error:
  printf("BLAS : Bad memory unallocation! : %4d  %p\n", position,  free_area);

#ifdef DEBUG
  for (position = 0; position < NUM_BUFFERS; position++) 
    printf("%4ld  %p : %d\n", position, alloc_area[position], alloc_used[position]);
#endif

  UNLOCK_COMMAND(&alloc_lock);

  return;
}

#ifdef __PGI
void __pgdbg_stub(void) {};
void __pgio_ini(void) {};
#endif
