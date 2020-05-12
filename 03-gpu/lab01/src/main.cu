#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "timings/helper_timer.h"

__global__ void add(int *a, int *b, int *c, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < size) {
        c[tid] = a[tid] + b[tid];
    }
}

void add_cpu(int *a, int *b, int *c, int size) {
    for (int i = 0; i < size; i++) {
        c[i] = a[i] + b[i];
    }
}

bool check(int *a, int *b, int size) {
    for (int i = 0; i < size; i++) {
        if (a[i] != b[i]) {
            return false;
        }
    }
    return true;
}

int main(void) {

    int size, threads, blocks;
    printf("enter vector size: ");
    scanf("%d", &size);
    printf("enter threads per block: ");
    scanf("%d", &threads);
    printf("enter blocks per grid: ");
    scanf("%d", &blocks);
    
    int *a = (int*)calloc(size, sizeof(int));
    int *b = (int*)calloc(size, sizeof(int));
    int *c = (int*)calloc(size, sizeof(int));
    int *c_cpu = (int *)calloc(size, sizeof(int));

    int *dev_a, *dev_b, *dev_c;
    cudaMalloc((void**)&dev_a, size * sizeof(int));
    cudaMalloc((void**)&dev_b, size * sizeof(int));
    cudaMalloc((void**)&dev_c, size * sizeof(int));
    
    for (int i = 0; i < size; i++) {
        a[i] = i;
        b[i] = i * 2;
    }
    cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, size * sizeof(int), cudaMemcpyHostToDevice);
    
    StopWatchInterface *timer=NULL;
    sdkCreateTimer(&timer);
    sdkResetTimer(&timer);
    sdkStartTimer(&timer);
    add <<<blocks, threads>>> (dev_a, dev_b, dev_c, size);
    cudaThreadSynchronize();
    sdkStopTimer(&timer);
    float time = sdkGetTimerValue(&timer);
    sdkDeleteTimer(&timer);

    cudaMemcpy(c, dev_c, size*sizeof(int), cudaMemcpyDeviceToHost);
    // for (int i = 0; i < size; i++) {
    //     printf("%d+%d=%d\n", a[i], b[i], c[i]);
    // }
    printf("time for the kernel %f (ms) \n", time);
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
    
//    clock_t t;
//    t = clock();
//    add_cpu(a, b, c_cpu, size);
//    t = clock() - t;
//    printf("time for the cpu fun %f (ms) \n", ((double)t)/CLOCKS_PER_SEC * 1000);
//
//    if (check(c, c_cpu, size)) {
//        printf("Results are the same\n");
//    } else {
//        printf("Results are not the same\n");
//    }

    free(a);
    free(b);
    free(c);
    free(c_cpu);

    return 0;
}
