#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <pthread.h>

#define NUM_THREAD 4

void* circle_point(void *param);

pthread_t tid[NUM_THREAD]={0};
int count[NUM_THREAD]={0};
clock_t start_time, end_time;
static long int total_point;
static long int count_circle=0;


int main(int argc, char const *argv[]){
   if(argc==1){
       printf("Enter number point\n");
       return -1;
      }

   if(argc!=2){
       printf("Argument is wrong\n");
       return -1;
     }

   total_point=atoll(argv[1])/NUM_THREAD;

   start_time= clock();
   srand(time(NULL));

   static int i;
   for(i=0; i<NUM_THREAD;i++)
   pthread_create(&tid[i],NULL,circle_point,&count[i]);

   for(i=0;i<NUM_THREAD;i++){
       pthread_join(tid[i],NULL);
       count_circle+=count[i];
     }

   double pi=4.0*(double)count_circle/(double)total_point/(double)NUM_THREAD;
   end_time=clock();

   printf("PI = %17.15f\n",pi);
   printf("Time to compute= %g second\n",(double)(end_time-start_time)/CLOCKS_PER_SEC);
   return 0;
  }

 void* circle_point(void *param){
   int *pcount= (int*)param;
   int i;

   for(i=0; i<total_point;i++){
       double x= (double)rand()/(double)RAND_MAX;
       double y=(double)rand()/(double)RAND_MAX;
       double r= sqrt(x*x+y*y);
       if(r<=1) *pcount=*pcount+1;
     }
   pthread_exit(0);
 }
