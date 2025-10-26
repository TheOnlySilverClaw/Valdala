const std = @import("std");
const fmt = std.fmt;

const thread_name_buffer = [std.Thread.max_name_len:0]u8;

var lock = std.Thread.Mutex {};

var buffer: [1024]u8 = undefined;

pub fn pretty(comptime message_level: std.log.Level, comptime scope: @TypeOf(.enum_literal), comptime format: []const u8, args: anytype) void {

    lock.lock();
    defer lock.unlock();
    
    switch (scope) {
        // from yaml library
        .parser, .tokenizer => {},
        else => write(message_level, scope, format, args) catch return
    }
}

fn write(comptime message_level: std.log.Level, comptime scope: @TypeOf(.enum_literal), comptime format: []const u8, args: anytype) !void {

    var stream_writer = std.fs.File.stdout().writer(&buffer);
    var writer = &stream_writer.interface;
    
    const color_code = switch (message_level) {
        .err => "\x1b[1;31m",
        .info => "\x1b[1;32m",
        .warn => "\x1b[1;33m",
        .debug => "\x1b[39m"
    };

    const level_string = switch (message_level) {
        .debug => "DEBUG",
        .info => "INFO",
        .warn => "WARN",
        .err => "ERROR"
    };

    try writer.print("{s} {d}  {s:<5}  @{s:<12}", .{ color_code, std.time.milliTimestamp(), level_string, @tagName(scope) });
    try writer.print(format, args);
    try writer.writeAll("\n\x1b[0m");
    try writer.flush();
}
