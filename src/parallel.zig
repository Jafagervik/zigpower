const std = @import("std");
const Thread = std.Thread;

// C imports
const time = @cImport(@cInclude("time.h"));
const cstd = @cImport(@cInclude("stdlib.h"));

/// Change this when you feel like it
pub const NUM_THREADS: i32 = 4;

/// Array containing our threads as in pthreads
var threads: [NUM_THREADS]Thread = undefined;

var cps: [NUM_THREADS]i32 = undefined;
var sps: [NUM_THREADS]i32 = undefined;

/// Only updates the area in memory it is working against
fn monte_thread(circle_point: *i32, square_point: *i32, loc_work: *i32, iters: *i32, event: *Thread.ResetEvent) void {
    var iterations = iters.*;
    var tot = loc_work.*;
    circle_point.* = 0;
    square_point.* = 0;

    var i: usize = 0;
    while (i < tot) : (i += 1) {
        const x: f32 = @as(f32, @intToFloat(f32, @as(i32, @rem(cstd.rand(), @divFloor(iterations, 4)) + 1))) / @intToFloat(f32, @divFloor(iterations, 4));
        const y: f32 = @as(f32, @intToFloat(f32, @as(i32, @rem(cstd.rand(), @divFloor(iterations, 4)) + 1))) / @intToFloat(f32, @divFloor(iterations, 4));

        var origin_dist: f32 = std.math.pow(f32, x, 2) + std.math.pow(f32, y, 2);

        if (origin_dist <= 1.0) {
            circle_point.* += 1;
        }

        square_point.* += 1;
    }
    event.set();
}

/// Random boring approximation of the monte carlo algorithm
pub fn fast_monte(iterations: i32) f32 {
    cstd.srand(@intCast(u32, time.time(0)));

    if (@rem(iterations, NUM_THREADS) != 0) {
        std.debug.print("Oops, you need a factor amount of threads compared to total iterations!", .{});
        return 1.0;
    }
    var loc_work: i32 = std.math.pow(i32, @intCast(i32, @divExact(iterations, NUM_THREADS)), 2);

    std.debug.print("Loc work: {}\n", .{loc_work});
    var pi: f32 = undefined;
    var its = iterations;

    // Spawn threads and initialize work
    var i: usize = 0;
    while (i < NUM_THREADS) : (i += 1) {
        var event = Thread.ResetEvent{};
        const spawn_config = Thread.SpawnConfig{ .stack_size = 5000 };
        threads[i] = Thread.spawn(spawn_config, monte_thread, .{ &cps[i], &sps[i], &loc_work, &its, &event }) catch @panic("Oops!");
        threads[i].detach();
    }

    var circle_points: i32 = 0;
    var square_points: i32 = 0;

    for (cps) |cp, s| {
        circle_points += cp;
        square_points += sps[s];
    }

    pi = @intToFloat(f32, 4 * circle_points) / @intToFloat(f32, square_points);

    // JOIN threads
    // NOTE: Thread.detatch() can also be used!

    return pi;
}
