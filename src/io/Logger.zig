const std = @import("std");


pub fn makeLogger(comptime file: []const u8) type {
    return struct {
        pub fn log(message: []const u8) void {
            std.debug.print("[{d}] [{s}]: {s}\n", .{ std.time.timestamp(), file, message });
        }
    };
}