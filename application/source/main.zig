const std = @import("std");
const log = std.log;
const Application = @import("application").Application;

pub fn main() void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

    const allocator = gpa.allocator();

    const application = Application.init(allocator) catch |err| {
        log.err("failed to initialize: {}", .{ err });
        return;
    };
    defer application.deinit();

    application.launch() catch |err| {
        log.err("crashed with error: {}", .{ err });
    };
    
    log.info("shutdown", .{});

    const check = gpa.deinit();
    if(check == .leak) {
        log.warn("Memory leaks detected!", .{});
    }
}
