const std = @import("std");
const net = std.net;
const log = std.log.scoped(.connection);

const Allocator = std.mem.Allocator;

const Self = @This();

allocator: Allocator,
handle: net.Server.Connection,
open: bool,

pub fn init(allocator: Allocator, handle: net.Server.Connection) !Self {
    return .{
        .allocator = allocator,
        .handle = handle,
        .open = false
    };
}

pub fn start(self: *Self) void {
    self.receive() catch |err| log.err("Connection crashed: {}", .{ err });
}

pub fn receive(self: *Self) !void {
    
    self.open = true;

    while(self.open) {
        const header = try self.handle.stream.reader().readByte();
        log.debug("Received header {d}", .{ header });
    }
}

pub fn close(self: *Self) !void {

    self.open = false;
    self.handle.stream.close();
}