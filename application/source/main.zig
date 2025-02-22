const std = @import("std");
const log = std.log;
const Application = @import("Application.zig");

pub fn main() void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

    const allocator = gpa.allocator();

    var application = Application.init(allocator) catch |err| {
        log.err("Failed to initialize: {}", .{ err });
        return;
    };

    application.launch() catch |err| {
        log.err("Crashed with error: {}", .{ err });
    };
    
    application.deinit();
    
    const check = gpa.deinit();
    if(check == .leak) {
        log.warn("Memory leaks detected!", .{});
    }
}
