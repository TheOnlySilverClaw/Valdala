const std = @import("std");

const thread_name_buffer = [std.Thread.max_name_len:0]u8;


pub fn pretty(comptime message_level: std.log.Level, comptime scope: @TypeOf(.enum_literal), comptime format: []const u8, args: anytype) void {

    switch (scope) {
        // from yaml library
        .parser, .tokenizer => {},
        else => write(message_level, scope, format, args) catch return
    }
}

fn write(comptime message_level: std.log.Level, comptime scope: @TypeOf(.enum_literal), comptime format: []const u8, args: anytype) !void {

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

    var writer = std.io.getStdOut().writer();
    try std.fmt.format(writer, "{s} {d}  {s:<5}  @{s} \t", .{ color_code, std.time.milliTimestamp(), level_string, @tagName(scope) });
    try std.fmt.format(writer, format, args);
    try writer.writeAll("\n\x1b[0m");
}
