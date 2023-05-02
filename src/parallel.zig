const std = @import("std");
const Thread = std.Thread;

// C imports
const time = @cImport(@cInclude("time.h"));
const cstd = @cImport(@cInclude("stdlib.h"));

/// Change this when you feel like it
pub const NUM_THREADS = 4;

/// Array containing our threads as in pthreads
var threads: [NUM_THREADS]Thread = undefined;

/// Each thread does local work and adds to this
/// Think about what errors can occur when dealing with it this way
var count: [NUM_THREADS]f32 = undefined;

/// A way to get random numbers in zig without having to use C
fn get_random_number() f32 {
    cstd.srand(@intCast(u32, time.time(0)));
    return @intToFloat(f32, @as(i32, cstd.rand())) / @intToFloat(f32, @as(i32, cstd.RAND_MAX));
}

/// Only updates the area in memory it is working against
fn monte_thread(value: *f32, total: *i32, event: *Thread.ResetEvent) void {
    var tot = total.*;

    var i: usize = 0;
    while (i < tot) : (i += 1) {
        const x: f32 = get_random_number();
        const y: f32 = get_random_number();

        var circle_radius = std.math.sqrt(x * x + y * y);

        if (circle_radius <= 1.0) {
            value.* += 1;
        }
    }
    event.set();
}

/// Random boring approximation of the monte carlo algorithm
pub fn fast_monte(iterations: i32) f32 {
    if (@rem(iterations, NUM_THREADS) != 0) {
        std.debug.print("Oops, you need a factor amount of threads compared to total iterations!", .{});
        return 1.0;
    }
    var total: i32 = @divFloor(iterations, NUM_THREADS);

    var pi: f32 = undefined;

    // Spawn threads and initialize work
    var i: usize = 0;
    while (i < NUM_THREADS) : (i += 1) {
        var event = Thread.ResetEvent{};
        threads[i] = try Thread.spawn(.{}, monte_thread, .{ &count[i], &total, &event });
    }

    var count_circle: i32 = 0;

    // JOIN threads
    // NOTE: Thread.detatch() can also be used!
    for (threads) |t, j| {
        t.join();
        count_circle += count[j];
    }

    pi = 4.0 * @intToFloat(f32, count_circle) / @intToFloat(f32, total) / @as(f32, NUM_THREADS);

    return pi;
}
