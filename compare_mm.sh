#!/usr/bin/bash


# Build 
echo "BUILDING SERIAL GEMM.."
zig build-exe ./src/matmul.zig && ./matmul 

echo "BUILDING PARALLEL GEMM.."
zig build-exe ./src/paramm.zig 

echo "N = 256 | T = 2"
./paramm 256 2

echo "N = 512 | T = 4"
./paramm 512 4

echo "N = 1024 | T = 4"
./paramm 1024 4

echo "N = 1024 | T = 8"
./paramm 1024 8

echo "N = 2048| T = 4"
./paramm 1024 8

echo "N = 4096 | T = 8"
./paramm 4096 16

echo "N = 1 << 14 | T = 16"
time ./paramm 16384 16

echo "Wow, what a speedup! Goodbye!"
