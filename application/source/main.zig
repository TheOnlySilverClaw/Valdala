const std = @import("std");
const log = std.log;
const process = std.process;
const Application = @import("Application.zig");

pub fn main() !void {

    var gpa = std.heap.DebugAllocator(.{}).init;

    const allocator = gpa.allocator();

    const args = process.argsAlloc(allocator) catch |err| {
        log.err("Failed to allocate arguments", .{});
        return err;
    };

    const path = args[1];

    var application = Application.init(allocator, path) catch |err| {
        log.err("Failed to initialize: {}", .{ err });
        return err;
    };

    application.launch() catch |err| {
        log.err("Crashed with error: {}", .{ err });
	return err;
    };

    application.deinit();
    process.argsFree(allocator, args);

    const check = gpa.deinit();
    if(check == .leak) {
        log.warn("Memory leaks detected!", .{});
    }
}
