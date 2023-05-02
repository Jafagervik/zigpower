//! This program performs some insanely difficult parallel program

const std = @import("std");
const time = std.time;

const unopt = @import("sequential.zig");
const para = @import("parallel.zig");

/// Calculates time
fn nanos_to_secs(val: u64) f64 {
    return @intToFloat(f64, val) / @as(f64, 10e8);
}

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();

    // Read user input
    const stdin = std.io.getStdIn().reader();

    std.debug.print("A number please: ", .{});

    var iterations: i32 = undefined;
    var buf: [10]u8 = undefined;

    // Read from
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        iterations = try std.fmt.parseInt(i32, user_input, 10);
    } else {
        // Default is 5
        iterations = @as(i32, 5);
    }

    std.debug.print("Running Monte Carlo Approximation of pi....\n", .{});

    // ========================
    // Normal
    // ========================

    var timer = try time.Timer.start();
    const slow_monte = unopt.monte(iterations);
    const elapsed = timer.read();
    const time_unopt = nanos_to_secs(elapsed);

    std.debug.print("Unoptimized Pi: {d:.3}\n Time: {d:.2}s\n", .{ slow_monte, time_unopt });

    // ========================
    // Parallel
    // ========================

    var timer2 = try time.Timer.start();
    const monte_fast = para.fast_monte(iterations);
    const elapsed2 = timer2.read();
    const time_opt = nanos_to_secs(elapsed2);

    std.debug.print("Optimized: {d:.3}\n Time: {d:.2}s\n", .{ monte_fast, time_opt });

    std.debug.print("Speedup is {d:.2} for {} added threads here in ZIG!\n", .{ time_unopt / time_opt, 4 });
}
