const std = @import("std");
const math = std.math;
const io = std.io;
const mem = std.mem;
const os = std.os;

// C imports
const time = @cImport(@cInclude("time.h"));
const cstd = @cImport(@cInclude("stdlib.h"));

/// Random boring approximation of the monte carlo algorithm
pub fn monte(interval: i32) f32 {
    cstd.srand(@intCast(u32, time.time(0)));

    var rand_x: f32 = undefined;
    var rand_y: f32 = undefined;
    var pi: f32 = undefined;
    var origin_dist: f32 = undefined;
    var circle_points: i32 = 0;
    var square_points: i32 = 0;

    // One way to write for loops in ZIG
    const maxrange = math.pow(i64, interval, 2);

    std.debug.print("Maxrange: {}\n", .{maxrange});

    var i: usize = 0;
    while (i < maxrange) : (i += 1) {
        rand_x = @as(f32, @intToFloat(f32, @as(i32, @rem(cstd.rand(), interval) + 1))) / @intToFloat(f32, interval);
        rand_y = @as(f32, @intToFloat(f32, @as(i32, @rem(cstd.rand(), interval) + 1))) / @intToFloat(f32, interval);

        origin_dist = math.pow(f32, rand_x, 2) + math.pow(f32, rand_y, 2);

        if (origin_dist <= 1) {
            circle_points += 1;
        }

        square_points += 1;

        pi = @intToFloat(f32, 4 * circle_points) / @intToFloat(f32, square_points);
    }

    return pi;
}
