const std = @import("std");
const log = std.log;
const process = std.process;
const Application = @import("Application.zig");

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;

    const allocator = gpa.allocator();

    const args = process.argsAlloc(allocator) catch {
        log.err("Failed to allocate arguments", .{});
        return;
    };

    std.log.debug("args: {s}", .{ args });

    var application = Application.init(allocator) catch |err| {
        log.err("Failed to initialize: {}", .{ err });
        return err;
    };

    application.launch() catch |err| {
        log.err("Crashed with error: {}", .{ err });
    };
    
    application.deinit();
    process.argsFree(allocator, args);
    
    const check = gpa.deinit();
    if(check == .leak) {
        log.warn("Memory leaks detected!", .{});
    }
}
