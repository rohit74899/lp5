%%cu
#include <iostream>
using namespace std;

__global__ void add(int* A, int* B, int* C, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < size) {
        C[tid] = A[tid] + B[tid];
    }
}


void initialize(int* vector, int size) {
    for (int i = 0; i < size; i++) {
        vector[i] = rand() % 10;
    }
}

void print(int* vector, int size) {
    for (int i = 0; i < size; i++) {
        cout << vector[i] << " ";
    }
    cout << endl;
}

int main() {
    int N = 4;
    int* A, * B, * C;

    int vectorSize = N;
    size_t vectorBytes = vectorSize * sizeof(int);

    A = new int[vectorSize];
    B = new int[vectorSize];
    C = new int[vectorSize];

    initialize(A, vectorSize);
    initialize(B, vectorSize);

    cout << "Vector A: ";
    print(A, N);
    cout << "Vector B: ";
    print(B, N);

    int* X, * Y, * Z;
    cudaMalloc(&X, vectorBytes);
    cudaMalloc(&Y, vectorBytes);
    cudaMalloc(&Z, vectorBytes);

    cudaMemcpy(X, A, vectorBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(Y, B, vectorBytes, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    add<<<blocksPerGrid, threadsPerBlock>>>(X, Y, Z, N);

    cudaMemcpy(C, Z, vectorBytes, cudaMemcpyDeviceToHost);

    cout << "Addition: ";
    print(C, N);

    delete[] A;
    delete[] B;
    delete[] C;

    cudaFree(X);
    cudaFree(Y);
    cudaFree(Z);

    return 0;
}





%%cu
#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

// CUDA kernel for vector addition
__global__ void add(int* A, int* B, int* C, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < size) {
        C[tid] = A[tid] + B[tid];
    }
}

int main() {
    // Size of the vectors
    int N = 1000000;

    // Host vectors
    int* A = new int[N];
    int* B = new int[N];
    int* C = new int[N];

    // Initialize host vectors with random values
    for (int i = 0; i < N; i++) {
        A[i] = rand() % 10;
        B[i] = rand() % 10;
    }

    // Device vectors
    int* X, * Y, * Z;
    cudaMalloc(&X, N * sizeof(int));
    cudaMalloc(&Y, N * sizeof(int));
    cudaMalloc(&Z, N * sizeof(int));

    // Copy host vectors to device
    cudaMemcpy(X, A, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(Y, B, N * sizeof(int), cudaMemcpyHostToDevice);

    // Set up grid and block dimensions
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    // Measure execution time of parallel algorithm
    auto startParallel = high_resolution_clock::now();
    add<<<blocksPerGrid, threadsPerBlock>>>(X, Y, Z, N);
    cudaDeviceSynchronize();
    auto stopParallel = high_resolution_clock::now();
    auto durationParallel = duration_cast<milliseconds>(stopParallel - startParallel);
    cout << "Parallel Execution Time: " << durationParallel.count() << " milliseconds" << endl;

    // Free device memory
    cudaFree(X);
    cudaFree(Y);
    cudaFree(Z);

    // Free host memory
    delete[] A;
    delete[] B;
    delete[] C;

    return 0;
}





sequential

#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

// Sequential implementation of vector addition
void addSequential(int* A, int* B, int* C, int size) {
    for (int i = 0; i < size; i++) {
        C[i] = A[i] + B[i];
    }
}

int main() {
    // Size of the vectors
    int N = 1000000;

    // Dynamic memory allocation for arrays A, B, and C
    int* A = new int[N];
    int* B = new int[N];
    int* C = new int[N];

    // Initialize vectors A and B with random values
    for (int i = 0; i < N; i++) {
        A[i] = rand() % 10;
        B[i] = rand() % 10;
    }

    // Measure execution time of sequential algorithm
    auto startSequential = high_resolution_clock::now();
    addSequential(A, B, C, N);
    auto stopSequential = high_resolution_clock::now();
    auto durationSequential = duration_cast<milliseconds>(stopSequential - startSequential);
    cout << "Sequential Execution Time: " << durationSequential.count() << " milliseconds" << endl;

    // Free allocated memory
    delete[] A;
    delete[] B;
    delete[] C;

    return 0;
}



!pip install git+https://github.com/afnan47/cuda.git
%load_ext nvcc_plugin

%%cu