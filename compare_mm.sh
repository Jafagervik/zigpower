#!/usr/bin/bash


# Build 
echo "BUILDING SERIAL GEMM..\n"
zig build-exe ./src/matmul.zig && ./matmul 

echo "BUILDING PARALLEL GEMM..\n"
zig build-exe ./src/paramm.zig 

echo "N = 512 | T = 4\n"
./paramm 256 4


echo "N = 512 | T = 8\n"
./paramm 512 8

echo "N = 1024 | T = 8\n"
./paramm 1024 8

echo "N = 4096 | T = 16\n"
./paramm 4096 16

echo "Wow, what a speedup!\n Goodbye!\n"
