const std = @import("std");
const simd = std.simd;

/// TODO: Create some multithreaded SIMD operator or sum
pub fn main() !void {
    const a = simd.iota(f32, 10);

    const trues = @Vector(5, bool){ true, false, true, false, false };

    const b = simd.repeat(10, [_]f32{ 1, 2, 3, 4, 5 });

    const c = @splat(5, @as(f32, 1.0));
    const d = simd.countTrues(trues);

    std.debug.print("vector: {}\n", .{a});
    std.debug.print("vector: {}\n", .{b});
    std.debug.print("vector: {}\n", .{c});
    std.debug.print("trues: {}\n", .{d});
    std.debug.print("reduce: {}\n", .{@reduce(.Add, b)});
}
