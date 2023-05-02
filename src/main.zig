//! This program performs some insanely difficult parallel program

const std = @import("std");
const unopt = @import("sequential.zig");

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
        // Default is 1-
        iterations = @as(i32, 5);
    }

    std.debug.print("Running Monte Carlo Approximation of pi....\n", .{});

    // Take input from user
    // Normal
    const unoptpi = unopt.monte(iterations);

    std.debug.print("Unoptimized: {}\n", .{unoptpi});

    // ========================
    // Parallel
    // ========================

    //try stdout.print("Optimized: {}\n", .{unoptpi});

    // Clean
    // try bw.flush();
}
