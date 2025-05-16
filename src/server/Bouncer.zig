const std = @import("std");
const net = std.net;
const log = std.log.scoped(.bouncer);

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const List = std.ArrayListUnmanaged;
const Connection = @import("Connection.zig");

const Self = @This();

allocator: std.mem.Allocator,
server: *net.Server,
thread_pool: *Thread.Pool,
connections: List(*Connection),
open: bool,

pub fn init(allocator: Allocator, address: net.Address, connection_limit: u32) !Self {
    
    const server = try allocator.create(net.Server);
    server.* = try address.listen(.{ .reuse_address = true });

    const thread_pool = try allocator.create(Thread.Pool);
    try thread_pool.init(.{
        .allocator = allocator,
        .n_jobs = connection_limit
    });

    var connections = List(*Connection).empty;
    try connections.ensureTotalCapacity(allocator, connection_limit);

    return .{
        .allocator = allocator,
        .server = server,
        .thread_pool = thread_pool,
        .connections = connections,
        .open = false
    };
}

pub fn deinit(self: *Self) void {
    self.server.deinit();
    self.allocator.destroy(self.server);

    for(self.connections.items) |connection| {
        self.allocator.destroy(connection);
    }
    self.connections.clearAndFree(self.allocator);

    self.thread_pool.deinit();
    self.allocator.destroy(self.thread_pool);
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

    const connection = try self.allocator.create(Connection);
    connection.* = try Connection.init(self.allocator, connection_handle);
    try self.connections.append(self.allocator, connection);
    try self.thread_pool.spawn(Connection.start, .{ connection });
}

pub fn close(self: *Self) !void {
    
    self.open = false;

    const self_connection = try net.tcpConnectToAddress(self.server.listen_address);
    self_connection.close();

    for(self.connections.items) |connection| {
        try connection.close();
    }
}
