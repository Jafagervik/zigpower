const std = @import("std");
const Thread = std.Thread;
const atomic = std.atomic;
const ArrayList = std.ArrayList;
const alloc = std.mem.Allocator;

pub const NUM_THREADS = 4;

// Array containing our threads as in pthreads
var threads: [NUM_THREADS]Thread = undefined;

const TMODE = enum { SPAWN, JOIN };

/// Handle threads according to needs
fn handle_threads(mode: TMODE) !void {
    switch (mode) {
        TMODE.SPAWN => {
            for (threads) |t| {
                t.spawn();
            }
        },
        TMODE.JOIN => {
            for (threads) |t| {
                t.join();
            }
        },
    }
}

// C imports
const c = @cImport({
    @cInclude("time.h");
    @cInclude("stdlib.h");
    // https://www.reddit.com/r/Zig/comments/kh1ian/multi_threading_in_zig/
    @cInclude("pthread.h");
});

fn get_random_number() i32 {
    return 0;
}

fn threadwork() void {}

/// Random boring approximation of the monte carlo algorithm
pub fn fast_monte(interval: i32) f32 {
    _ = interval;
    c.cstd.srand(@intCast(u32, c.time.time(0)));
    var pi: f32 = undefined;

    // Spawn threads
    handle_threads(TMODE.SPAWN);

    // TODO: DO SOME TASKS

    // JOIN threads
    handle_threads(TMODE.JOIN);

    return pi;
}
