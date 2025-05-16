const std = @import("std");
const net = std.net;
const log = std.log.scoped(.bouncer);

const Allocator = std.mem.Allocator;

const Self = @This();

allocator: std.mem.Allocator,
server: *net.Server,
open: bool,

pub fn init(allocator: Allocator, address: net.Address) !Self {
    
    const server = try allocator.create(net.Server);
    server.* = try address.listen(.{});

    return .{
        .allocator = allocator,
        .server = server,
        .open = false
    };
}

pub fn deinit(self: Self) void {
    
    self.server.deinit();
    self.allocator.destroy(self.server);
}

pub fn receive(self: *Self) !void {

    self.open = true;

    while(self.open) {
        log.debug("Accept next connection", .{});
        try self.accept();
    }
}

fn accept(self: *Self) !void {

    const connection_handle = try self.server.accept();
    log.info("Received connection from {any}", .{ connection_handle.address });
}

pub fn close(self: *Self) !void {
    
    self.open = false;

    const self_connection = try net.tcpConnectToAddress(self.server.listen_address);
    self_connection.close();
}
