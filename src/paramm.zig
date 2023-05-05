const std = @import("std");
const Thread = std.Thread;

// Type aliasing;
const Matrix = [][]f32;
const ArgList = [2]usize;

/// Size of vector
var N: usize = undefined;
var NUM_THREADS: usize = undefined;

const DEBUG = false;

// TODO: Ideally only send slice of array instead of the whole thing
/// Worker only does its share of the workload
fn worker(res: *Matrix, a: *Matrix, b: *Matrix, tid: *const u8) void {
    var k: usize = 0;
    var j: usize = 0;
    var sum: f32 = 0.0;

    var portion: u16 = @intCast(u16, @divExact(N, NUM_THREADS));

    var row_start: u16 = (tid.*) * portion;
    var row_end: u16 = (tid.* + 1) * portion;

    //std.debug.print("\ntid: {}, Start: {}, End: {}\n", .{ tid.*, row_start, row_end });

    var i: usize = row_start;

    while (i < row_end) : (i += 1) {
        while (j < N) : (j += 1) {
            sum = 0.0;
            while (k < N) : (k += 1) {
                sum += a.*[i][k] * b.*[k][j];
            }
            if (DEBUG) {
                std.debug.print("\nTID: {}, i: {}, j: {}, sum: {d:.2}\n", .{ tid.*, i, j, sum });
            }
            res.*[i][j] = sum;
        }
    }
}

fn gemm(threads: *[]Thread, matA: *Matrix, matB: *Matrix, matC: *Matrix) void {
    var tid: u8 = 0;

    while (tid < NUM_THREADS) : (tid += 1) {
        const id: *u8 = &tid;
        threads.*[tid] = Thread.spawn(.{}, worker, .{ matC, matA, matB, id }) catch @panic("Oops!\n");
    }
}

pub fn main() !void {
    const args: ArgList = parseArgs() catch @panic("Too few arguments.");

    N = args[0];
    NUM_THREADS = args[1];

    if (@rem(N, NUM_THREADS) != 0) {
        std.debug.print("Oops, N is not evenly divisable by threads!\n", .{});
        return;
    }

    // I cant be arsed
    if (DEBUG and N > 8) std.debug.panic("no.\n", .{});

    // ALlocator for threads since we don't know the size at compile time
    var thread_alloc = std.heap.page_allocator;
    var threads: []Thread = try thread_alloc.alloc(Thread, NUM_THREADS);

    defer thread_alloc.free(threads);

    std.log.info("Now displaying matrix multiplication!\n", .{});

    // Page allocator is thread safe. See docs for more info
    var allocator = std.heap.page_allocator;
    var allocator2 = std.heap.page_allocator;
    var allocator3 = std.heap.page_allocator;

    var matA: Matrix = try buildMatrix(N, N, &allocator);
    var matB: Matrix = try buildMatrix(N, N, &allocator2);
    var matC: Matrix = try buildMatrix(N, N, &allocator3);

    defer allocator.free(matA);
    defer allocator2.free(matB);
    defer allocator3.free(matC);

    initMatrix(&matA);
    initMatrix(&matB);

    // New timer

    var timer = try std.time.Timer.start();

    gemm(&threads, &matA, &matB, &matC);

    const time = timer.read();

    // Cleanup using join!
    for (threads) |thread| {
        thread.join();
    }

    std.debug.print("\n\nIt took {d:.6}s to calculate this GEMM\n", .{nanos_to_secs(time)});

    if (DEBUG) printMatrix(&matC);
}

/// Argument parser for our lovely program
fn parseArgs() !ArgList {
    var args = std.process.args();

    // We do not care about zig program
    _ = args.skip();

    const n_str = args.next() orelse @panic("NaN\n");
    const t_str = args.next() orelse @panic("NaN\n");

    var n: usize = try std.fmt.parseUnsigned(usize, n_str, 10);
    var t: usize = try std.fmt.parseUnsigned(usize, t_str, 10);

    if (DEBUG) {
        std.debug.print("Ns: {d:}, Type: {}\n", .{ n, @TypeOf(n) });
        std.debug.print("Ts: {d:}, Type: {}\n", .{ t, @TypeOf(t) });
    }

    return ArgList{ n, t };
}

/// Here we do both initing and printing at the same time
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
fn buildMatrix(rows: usize, cols: usize, alloc: *std.mem.Allocator) !Matrix {
    var mat: Matrix = undefined;

    mat = try alloc.alloc([]f32, cols);

    for (mat) |*row| {
        row.* = try alloc.alloc(f32, rows);
    }

    return mat;
}

/// Calculates time
fn nanos_to_secs(val: u64) f64 {
    return @intToFloat(f64, val) * @as(f64, 1e-9);
}

/// Get random number
fn getRandomNumber() f32 {
    const RndGen = std.rand.DefaultPrng;
    var rnd = RndGen.init(@intCast(u64, std.time.microTimestamp()));

    return rnd.random().float(f32) * 100;
}

// ======================================================================
// ======================================================================
// ======================================================================

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

test "Verify" {
    std.testing.expect(1 == 1);
}
