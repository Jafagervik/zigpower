const std = @import("std");

// Type aliasing;
const Matrix = [][]f32;

/// Size of vector
const N: usize = 1 << 9;

const DEBUG = false;

// Naive matrix multiplication
fn gemm(res: *Matrix, a: *Matrix, b: *Matrix, n: usize) void {
    for (a.*, 0..n) |_, i| {
        for (a.*[0], 0..n) |_, j| {
            res.*[i][j] = 0.0;

            for (b.*, 0..n) |_, k| {
                res.*[i][j] += a.*[i][k] * b.*[k][j];
            }
        }
    }
}

pub fn main() !void {
    std.log.info("Now displaying matrix multiplication!", .{});

    var allocator = std.heap.page_allocator;
    var allocator2 = std.heap.page_allocator;
    var allocator3 = std.heap.page_allocator;

    var matA: Matrix = try build_matrix(N, N, &allocator);
    var matB: Matrix = try build_matrix(N, N, &allocator2);
    var matC: Matrix = try build_matrix(N, N, &allocator3);

    defer allocator.free(matA);
    defer allocator2.free(matB);
    defer allocator3.free(matC);

    initMatrix(&matA);
    initMatrix(&matB);

    var timer = try std.time.Timer.start();

    gemm(&matC, &matA, &matB, N);

    const time = timer.read();

    std.debug.print("\n\nIt took {d:.2}s to calculate this GEMM\n", .{nanos_to_secs(time)});

    if (DEBUG) printMatrix(&matC);
}

/// Calculates time
fn nanos_to_secs(val: u64) f64 {
    return @intToFloat(f64, val) * @as(f64, 1e-9);
}

fn initMatrix(mat: *Matrix) void {
    if (DEBUG) std.debug.print("\n=============\nInput matrix\n=============\n", .{});
    for (mat.*) |row| {
        if (DEBUG) std.debug.print("\n", .{});
        for (row) |*cell| {
            cell.* = getRandomNumber();
            if (DEBUG) std.debug.print("{d:.2} ", .{cell.*});
        }
    }

    std.debug.print("\n", .{});
}

fn printMatrix(mat: *Matrix) void {
    std.debug.print("\n==============\nResult matrix:\n==============\n", .{});
    for (mat.*) |row| {
        std.debug.print("\n", .{});
        for (row) |cell| {
            std.debug.print("{d:.2} ", .{cell});
        }
    }
}

/// Build matrix on heap requires some sort of allocator
fn build_matrix(rows: usize, cols: usize, alloc: *std.mem.Allocator) !Matrix {
    var mat: Matrix = undefined;

    mat = try alloc.alloc([]f32, cols);

    for (mat) |*row| {
        row.* = try alloc.alloc(f32, rows);
    }

    return mat;
}

/// Get random number
fn getRandomNumber() f32 {
    const RndGen = std.rand.DefaultPrng;
    var rnd = RndGen.init(@intCast(u64, std.time.microTimestamp()));

    return rnd.random().float(f32) * 100;
}

/// Old version using while loops
fn _initMatrix(mat: *Matrix) void {
    const ys = mat.len;
    const xs = mat.*[0].len;

    std.debug.print("Rows: {}, Cols: {}\n", .{ ys, xs });

    var r: usize = 0;
    var c: usize = 0;
    std.debug.print("\n=============\nInput matrix\n=============\n", .{});

    while (r < ys) : (r += 1) {
        std.debug.print("\n", .{});

        while (c < xs) : (c += 1) {
            std.debug.print("Row, Col: {},{}\n", .{ r, c });

            mat.*[r][c] = 3.141;
            std.debug.print("{d:.2}\n", .{mat.*[r][c]});
        }
    }
}
