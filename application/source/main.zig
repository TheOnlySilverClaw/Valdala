const std = @import("std");
const log = std.log;
const Application = @import("application").Application;

pub fn main() void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

    const allocator = gpa.allocator();

    var application = Application.init(allocator) catch |err| {
        log.err("Failed to initialize: {}", .{ err });
        return;
    };
    defer application.deinit();

    application.launch() catch |err| {
        log.err("Crashed with error: {}", .{ err });
    };
    
    const check = gpa.deinit();
    if(check == .leak) {
        log.warn("Memory leaks detected!", .{});
    }
}
