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
#include <stdlib.h>
#include <sys/mman.h>
#include "common.h"

#ifdef SMP_SERVER

#undef MONITOR
#undef TIMING
#undef TIMING_DEBUG
#undef NEED_STACKATTR

#define ATTRIBUTE_SIZE 128

/* This is a thread server model implementation.  The threads are   */
/* spawned at first access to blas library, and still remains until */
/* destruction routine is called.  The number of threads are        */
/* equal to "OMP_NUM_THREADS - 1" and thread only wakes up when     */
/* jobs is queued.                                                  */

/* We need this grobal for cheking if initialization is finished.   */
int blas_server_avail   __attribute__((aligned(ATTRIBUTE_SIZE))) = 0;

/* Local Variables */
#if   defined(USE_PTHREAD_LOCK)
static pthread_mutex_t  server_lock    = PTHREAD_MUTEX_INITIALIZER;
#elif defined(USE_PTHREAD_SPINLOCK)
static pthread_spinlock_t  server_lock = 0;
#else
static BLASULONG server_lock       = 0;
#endif

#define THREAD_STATUS_SLEEP		2
#define THREAD_STATUS_WAKEUP		4

typedef struct {
  blas_queue_t * volatile queue   __attribute__((aligned(ATTRIBUTE_SIZE)));

  volatile BLASLONG		status;

  pthread_mutex_t	 lock;
  pthread_cond_t	 wakeup;

} thread_status_t;

static pthread_t       blas_threads [MAX_CPU_NUMBER];
static thread_status_t thread_status[MAX_CPU_NUMBER] __attribute__((aligned(ATTRIBUTE_SIZE)));

#ifndef THREAD_TIMEOUT
#define THREAD_TIMEOUT	26
#endif

static unsigned int thread_timeout = (1U << (THREAD_TIMEOUT));

#ifdef MONITOR

/* Monitor is a function to see thread's status for every seconds. */
/* Usually it turns off and it's for debugging.                    */

static pthread_t      monitor_thread;
static int main_status[MAX_CPU_NUMBER];
#define MAIN_ENTER	 0x01
#define MAIN_EXIT	 0x02
#define MAIN_TRYLOCK	 0x03
#define MAIN_LOCKSUCCESS 0x04
#define MAIN_QUEUING	 0x05
#define MAIN_RECEIVING   0x06
#define MAIN_RUNNING1    0x07
#define MAIN_RUNNING2    0x08
#define MAIN_RUNNING3    0x09
#define MAIN_WAITING	 0x0a
#define MAIN_SLEEPING	 0x0b
#define MAIN_FINISH      0x0c
#define MAIN_DONE	 0x0d
#endif

#define BLAS_QUEUE_FINISHED	3
#define BLAS_QUEUE_RUNNING	4

#ifdef TIMING
BLASLONG	exit_time[MAX_CPU_NUMBER];
#endif

static void legacy_exec(void *func, int mode, blas_arg_t *args, void *sb){

      if (!(mode & BLAS_COMPLEX)){
#ifdef EXPRECISION
	if (mode & BLAS_XDOUBLE){
	  /* REAL / Extended Double */
	  void (*afunc)(BLASLONG, BLASLONG, BLASLONG, xdouble, 
			xdouble *, BLASLONG, xdouble *, BLASLONG, 
			xdouble *, BLASLONG, void *) = func;

	  afunc(args -> m, args -> n, args -> k,
		((xdouble *)args -> alpha)[0],
		args -> a, args -> lda,
		args -> b, args -> ldb,
		args -> c, args -> ldc, sb);
	} else 
#endif
	  if (mode & BLAS_DOUBLE){
	    /* REAL / Double */
	    void (*afunc)(BLASLONG, BLASLONG, BLASLONG, double, 
			  double *, BLASLONG, double *, BLASLONG, 
			  double *, BLASLONG, void *) = func;
	    
	    afunc(args -> m, args -> n, args -> k,
		  ((double *)args -> alpha)[0],
		  args -> a, args -> lda,
		  args -> b, args -> ldb,
		  args -> c, args -> ldc, sb);
	  } else {
	    /* REAL / Single */
	    void (*afunc)(BLASLONG, BLASLONG, BLASLONG, float, 
			  float *, BLASLONG, float *, BLASLONG, 
			  float *, BLASLONG, void *) = func;
	    
	    afunc(args -> m, args -> n, args -> k,
		  ((float *)args -> alpha)[0],
		  args -> a, args -> lda,
		  args -> b, args -> ldb,
		  args -> c, args -> ldc, sb);
	  }
      } else {
#ifdef EXPRECISION
	if (mode & BLAS_XDOUBLE){
	  /* COMPLEX / Extended Double */
	  void (*afunc)(BLASLONG, BLASLONG, BLASLONG, xdouble, xdouble,
			xdouble *, BLASLONG, xdouble *, BLASLONG, 
			xdouble *, BLASLONG, void *) = func;

	  afunc(args -> m, args -> n, args -> k,
		((xdouble *)args -> alpha)[0],
		((xdouble *)args -> alpha)[1],
		args -> a, args -> lda,
		args -> b, args -> ldb,
		args -> c, args -> ldc, sb);
	} else
#endif
	  if (mode & BLAS_DOUBLE){
	    /* COMPLEX / Double */
	  void (*afunc)(BLASLONG, BLASLONG, BLASLONG, double, double,
			double *, BLASLONG, double *, BLASLONG, 
			double *, BLASLONG, void *) = func;

	  afunc(args -> m, args -> n, args -> k,
		((double *)args -> alpha)[0],
		((double *)args -> alpha)[1],
		args -> a, args -> lda,
		args -> b, args -> ldb,
		args -> c, args -> ldc, sb);
	  } else {
	    /* COMPLEX / Single */
	  void (*afunc)(BLASLONG, BLASLONG, BLASLONG, float, float,
			float *, BLASLONG, float *, BLASLONG, 
			float *, BLASLONG, void *) = func;

	  afunc(args -> m, args -> n, args -> k,
		((float *)args -> alpha)[0],
		((float *)args -> alpha)[1],
		args -> a, args -> lda,
		args -> b, args -> ldb,
		args -> c, args -> ldc, sb);
	  }
      }
}

/* If library is linked with OpenMP */
int omp_set_num_procs(void) __attribute__ ((weak));

static pthread_mutex_t pool_lock;
static pthread_cond_t  pool_filled;
static blas_queue_t   *pool_queue = NULL;

static int blas_thread_server(void *arg){

  /* Thread identifier */
  BLASLONG  cpu = (BLASLONG)arg;
  unsigned int last_tick;
  void *buffer, *sa, *sb;
  blas_queue_t	*queue;

#ifdef MONITOR
  main_status[cpu] = MAIN_ENTER;
#endif

  buffer   = blas_memory_alloc(2);

#ifdef BARCELONA
  buffer += (cpu + 1) * 4096;
#endif

#ifdef SMP_DEBUG
  fprintf(STDERR, "Server[%2ld] Thread has just been spawned!\n", cpu);
#endif
  
  while (1){

#ifdef MONITOR
    main_status[cpu] = MAIN_QUEUING;
#endif

#ifdef TIMING
    exit_time[cpu] = rpcc();
#endif

    if (!blas_omp_linked) {

      last_tick = (unsigned int)rpcc();
      
      while (!thread_status[cpu].queue) {
	
	if ((unsigned int)rpcc() - last_tick > thread_timeout) {
	  
	  pthread_mutex_lock  (&thread_status[cpu].lock);
	  
	  if (!thread_status[cpu].queue) {
	    thread_status[cpu].status = THREAD_STATUS_SLEEP;
	    while (thread_status[cpu].status == THREAD_STATUS_SLEEP) {
	      
#ifdef MONITOR
	      main_status[cpu] = MAIN_SLEEPING;
#endif
	      
	      pthread_cond_wait(&thread_status[cpu].wakeup, &thread_status[cpu].lock);
	    }
	  }
	  
	  pthread_mutex_unlock(&thread_status[cpu].lock);
	  
	  last_tick = (unsigned int)rpcc();
	}
	
      }
      
    queue = thread_status[cpu].queue;

    } else {

      pthread_mutex_lock(&pool_lock);

      while(!pool_queue) {
	pthread_cond_wait (&pool_filled, &pool_lock);
      }

      queue = pool_queue;
      pool_queue = pool_queue -> next;

      if (pool_queue) pthread_cond_signal(&pool_filled);

      pthread_mutex_unlock(&pool_lock);
    }

    if ((BLASLONG)queue == -1) break;

#ifdef MONITOR
    main_status[cpu] = MAIN_RECEIVING;
#endif

#ifdef TIMING_DEBUG
    start = rpcc();
#endif

    if (queue) {
      int (*routine)(blas_arg_t *, void *, void *, void *, void *, BLASLONG) = queue -> routine;
	
      thread_status[cpu].queue = (blas_queue_t *)1;

      sa = queue -> sa;
      sb = queue -> sb;
      
#ifdef SMP_DEBUG
      fprintf(STDERR, "Server[%2ld] Calculation started.  Mode = 0x%03x M = %3ld N=%3ld K=%3ld\n",
	      cpu, queue->mode, queue-> args ->m, queue->args->n, queue->args->k);
#endif
      
#ifdef MONITOR
      main_status[cpu] = MAIN_RUNNING1;
#endif
      
      if (sa == NULL) sa = (void *)((BLASLONG)buffer + GEMM_BUFFER_A_OFFSET);
      
      if (sb == NULL) {
	if (!(queue -> mode & BLAS_COMPLEX)){
#ifdef EXPRECISION
	  if (queue -> mode & BLAS_XDOUBLE){
	    sb = (void *)(((BLASLONG)sa + ((QGEMM_P * QGEMM_Q * sizeof(xdouble) 
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	  } else 
#endif
	  if (queue -> mode & BLAS_DOUBLE){
	    sb = (void *)(((BLASLONG)sa + ((DGEMM_P * DGEMM_Q * sizeof(double)
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	    
	  } else {
	    sb = (void *)(((BLASLONG)sa + ((SGEMM_P * SGEMM_Q * sizeof(float)
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	  }
	} else {
#ifdef EXPRECISION
	  if (queue -> mode & BLAS_XDOUBLE){
	    sb = (void *)(((BLASLONG)sa + ((XGEMM_P * XGEMM_Q * 2 * sizeof(xdouble)
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	  } else
#endif
	  if (queue -> mode & BLAS_DOUBLE){
	    sb = (void *)(((BLASLONG)sa + ((ZGEMM_P * ZGEMM_Q * 2 * sizeof(double)
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	  } else {
	    sb = (void *)(((BLASLONG)sa + ((CGEMM_P * CGEMM_Q * 2 * sizeof(float)
					+ GEMM_ALIGN) & ~GEMM_ALIGN)) + GEMM_BUFFER_B_OFFSET);
	  }
	}
      }
	
#ifdef MONITOR
	main_status[cpu] = MAIN_RUNNING2;
#endif

      if (!(queue -> mode & BLAS_LEGACY)) {
	(routine)(queue -> args, queue -> range_m, queue -> range_n, sa, sb, queue -> position);
      } else {
	legacy_exec(routine, queue -> mode, queue -> args, sb);
      }

#ifdef SMP_DEBUG
      fprintf(STDERR, "Server[%2ld] Calculation finished!\n", cpu);
#endif

#ifdef MONITOR
      main_status[cpu] = MAIN_FINISH;
#endif
      
      if (!blas_omp_linked) {
	thread_status[cpu].queue = NULL;
	WMB;
      } else {
	pthread_mutex_lock(&queue -> lock);
	queue -> status = BLAS_STATUS_FINISHED;
	pthread_cond_signal(&queue -> finished);
	pthread_mutex_unlock(&queue -> lock);
      }
    }
    
#ifdef MONITOR
      main_status[cpu] = MAIN_DONE;
#endif

#ifdef TIMING_DEBUG
    stop = rpcc();
    
    fprintf(STDERR, "Thread[%ld] : %16lu %16lu (%8lu cycles)  %ld  %ld\n", cpu + 1,
	    start, stop,
	    stop - start, queue->from, queue->to);
#endif
    
  }

  /* Shutdown procedure */

#ifdef SMP_DEBUG
      fprintf(STDERR, "Server[%2ld] Shutdown!\n",  cpu);
#endif

  blas_memory_free(buffer);

  pthread_exit(NULL);

  return 0;
}

#ifdef MONITOR

static BLASLONG num_suspend = 0;

static int blas_monitor(void *arg){
  int i;

  while(1){
    for (i = 0; i < blas_cpu_number - 1; i++){
      switch (main_status[i]) {
      case MAIN_ENTER :
	fprintf(STDERR, "THREAD[%2d] : Entering.\n", i);
	break;
      case MAIN_EXIT :
	fprintf(STDERR, "THREAD[%2d] : Exiting.\n", i);
	break;
      case MAIN_TRYLOCK :
	fprintf(STDERR, "THREAD[%2d] : Trying lock operation.\n", i);
	break;
      case MAIN_QUEUING :
	fprintf(STDERR, "THREAD[%2d] : Queuing.\n", i);
	break;
      case MAIN_RECEIVING :
	fprintf(STDERR, "THREAD[%2d] : Receiving.\n", i);
	break;
      case MAIN_RUNNING1 :
	fprintf(STDERR, "THREAD[%2d] : Running1.\n", i);
	break;
      case MAIN_RUNNING2 :
	fprintf(STDERR, "THREAD[%2d] : Running2.\n", i);
	break;
      case MAIN_RUNNING3 :
	fprintf(STDERR, "THREAD[%2d] : Running3.\n", i);
	break;
      case MAIN_WAITING :
	fprintf(STDERR, "THREAD[%2d] : Waiting.\n", i);
	break;
      case MAIN_SLEEPING :
	fprintf(STDERR, "THREAD[%2d] : Sleeping.\n", i);
	break;
      case MAIN_FINISH :
	fprintf(STDERR, "THREAD[%2d] : Finishing.\n", i);
	break;
      case MAIN_DONE :
	fprintf(STDERR, "THREAD[%2d] : Job is done.\n", i);
	break;
      }

      fprintf(stderr, "Total number of suspended ... %ld\n", num_suspend);
    }
    sleep(1);
  }
  
 return 0;
}
#endif

/* Initializing routine */
int blas_thread_init(void){
  BLASLONG i;
#ifdef NEED_STACKATTR
  pthread_attr_t attr;
#endif

  if (blas_server_avail || ((!blas_omp_linked) && (blas_cpu_number <= 1))) return 0;
  
#ifdef NEED_STACKATTR
  pthread_attr_init(&attr);
  pthread_attr_setguardsize(&attr,  0x1000U);
  pthread_attr_setstacksize( &attr, 0x1000U);
#endif
  
  LOCK_COMMAND(&server_lock);

  if (!blas_server_avail){
    char *p;

    p = getenv("GOTO_THREAD_TIMEOUT");

    if (p) {
      thread_timeout = atoi(p);
      if (thread_timeout <  4) thread_timeout =  4;
      if (thread_timeout > 30) thread_timeout = 30;
      thread_timeout = (1 << thread_timeout);
    }

    if (blas_omp_linked) {
      pthread_mutex_init(&pool_lock, NULL);
      pthread_cond_init(&pool_filled, NULL);
    }

    for(i = 0; i < blas_cpu_number + blas_omp_linked - 1; i++){
      
      thread_status[i].queue  = (blas_queue_t *)NULL;
      thread_status[i].status = THREAD_STATUS_WAKEUP;
      
      pthread_mutex_init(&thread_status[i].lock, NULL);
      pthread_cond_init (&thread_status[i].wakeup, NULL);
      
#ifdef NEED_STACKATTR
      pthread_create(&blas_threads[i], &attr, 
		     (void *)&blas_thread_server, (void *)i);
#else
      pthread_create(&blas_threads[i], NULL, 
		     (void *)&blas_thread_server, (void *)i);
#endif
    }

#ifdef MONITOR
    pthread_create(&monitor_thread, NULL, 
		     (void *)&blas_monitor, (void *)NULL);
#endif

    blas_server_avail = 1;
  }

  UNLOCK_COMMAND(&server_lock);

  return 0;
}

/* 
   User can call one of two routines.

     exec_blas_async ... immediately returns after jobs are queued.

     exec_blas       ... returns after jobs are finished.
*/

static BLASULONG queue_lock = 0;
 
int exec_blas_async(BLASLONG pos, blas_queue_t *queue){

  BLASLONG i = 0;
  blas_queue_t *current = queue;
#ifdef SMP_DEBUG
  int exec_count = 0;
  fprintf(STDERR, "Exec_blas_async is called. Position = %d\n", pos);
#endif  

  if (!blas_omp_linked) {

    blas_lock(&queue_lock);
    
    while (queue) {
      queue -> position  = pos;
      
      while(thread_status[i].queue) {
	i ++;
	if (i >= blas_cpu_number) i = 0;
      }
      
      queue -> assigned = i;
      WMB;
      thread_status[i].queue = queue;
      WMB;
      
      queue = queue -> next;
      pos ++;
#ifdef SMP_DEBUG
      exec_count ++;
#endif
      
    }

    blas_unlock(&queue_lock);
    
#ifdef SMP_DEBUG
    fprintf(STDERR, "Done(Number of threads = %2ld).\n", exec_count);
#endif  
    
    while (current) {
      
      pos = current -> assigned;
      
      if ((BLASULONG)thread_status[pos].queue > 1) {
	
	if (thread_status[pos].status == THREAD_STATUS_SLEEP) {
	  
	  pthread_mutex_lock  (&thread_status[pos].lock);
	  
#ifdef MONITOR
	  num_suspend ++;
#endif
	  
	  if (thread_status[pos].status == THREAD_STATUS_SLEEP) {
	    thread_status[pos].status = THREAD_STATUS_WAKEUP;
	    pthread_cond_signal(&thread_status[pos].wakeup);
	  }
	  pthread_mutex_unlock(&thread_status[pos].lock);
	}
      }
      
      current = current -> next;
    }
  } else {

    while (current) {
      current -> position = pos;
      current -> status   = BLAS_STATUS_NOTYET;

      pthread_mutex_init(&current -> lock, NULL);
      pthread_cond_init(&current -> finished, NULL);
      
      pos ++;
      current = current -> next;
    }

    pthread_mutex_lock(&pool_lock);
    
    if (pool_queue) {
      current = pool_queue;
      while (current -> next) current = current -> next;
      current -> next = queue;
    } else {
      pool_queue = queue;
    }
    
    pthread_cond_signal(&pool_filled);
    pthread_mutex_unlock(&pool_lock);

  }
  
  return 0;
}

int exec_blas_async_wait(BLASLONG num, blas_queue_t *queue){

#ifdef SMP_DEBUG
  fprintf(STDERR, "Syncing[%ld]...; OMP -> %d\n", num, blas_omp_linked);
#endif
  
  if (!blas_omp_linked) {
    while ((num > 0) && queue) {
      
      while(thread_status[queue -> assigned].queue) {
	sched_yield();
      };
      
      queue = queue -> next;
      num --;
    }
  } else {

    while ((num > 0) && queue) {
      
      if (queue -> status != BLAS_STATUS_FINISHED) {

	pthread_mutex_lock(&queue -> lock);
	
	while (queue -> status != BLAS_STATUS_FINISHED) {
	  pthread_cond_wait(&queue -> finished, &queue -> lock);
	}
	
	pthread_mutex_unlock(&queue -> lock);
      }

      pthread_cond_destroy(&queue -> finished);
      pthread_mutex_destroy(&queue -> lock);

      queue = queue -> next;
      num --;
      
    }

  }

#ifdef SMP_DEBUG
  fprintf(STDERR, "Done.\n\n");
#endif
  
  return 0;
}

/* Execute Threads */
int exec_blas(BLASLONG num, blas_queue_t *queue){

   int (*routine)(blas_arg_t *, void *, void *, double *, double *, BLASLONG);

#ifdef TIMING_DEBUG
  BLASULONG start, stop;
#endif

  if ((num <= 0) || (queue == NULL)) return 0;

#ifdef SMP_DEBUG
  fprintf(STDERR, "Exec_blas is called. Number of executing threads : %ld\n", num);
#endif  

  if (!blas_omp_linked) {

    if ((num > 1) && queue -> next) exec_blas_async(1, queue -> next);
  
#ifdef TIMING_DEBUG
    start = rpcc();
    
    fprintf(STDERR, "\n");
#endif
    
    routine = queue -> routine;
    
    if (!(queue -> mode & BLAS_LEGACY)) {
      (routine)(queue -> args, queue -> range_m, queue -> range_n,
		queue -> sa, queue -> sb, 0);
    } else {
      legacy_exec(routine, queue -> mode, queue -> args, queue -> sb);
    }
    
#ifdef TIMING_DEBUG
    stop = rpcc();
#endif
    
    if ((num > 1) && queue -> next) exec_blas_async_wait(num - 1, queue -> next);

  } else {
    exec_blas_async(0, queue);
    exec_blas_async_wait(num, queue);
  }

#ifdef TIMING_DEBUG
    fprintf(STDERR, "Thread[0] : %16lu %16lu (%8lu cycles)  %ld   %ld\n", 
	    start, stop,
	    stop - start, queue->from, queue->to);
#endif

  return 0;
}

/* Shutdown procedure, but user don't have to call this routine. The */
/* kernel automatically kill threads.                                */

int blas_thread_shutdown_(void){

  int i;

  if (!blas_server_avail) return 0;
  
  LOCK_COMMAND(&server_lock);

  for (i = 0; i < blas_cpu_number - 1; i++) {
    while (thread_status[i].queue) {};
    thread_status[i].queue = (blas_queue_t *)-1;
    WMB;
  }
    
  for(i = 0; i < blas_cpu_number + blas_omp_linked - 1; i++){
    pthread_join(blas_threads[i], NULL);
  }
  
  blas_server_avail = 0;
  
  UNLOCK_COMMAND(&server_lock);
  
  return 0;
}
 
#endif
