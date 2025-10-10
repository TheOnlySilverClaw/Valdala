const std = @import("std");
const net = std.net;
const log = std.log.scoped(.connector);
const protocol = @import("protocol");

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const Mutex = Thread.RwLock;
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
        try self.accept();
    }
}

fn accept(self: *Self) !void {

    const connection_handle = try self.server.accept();
    log.debug("Received connection from {f}", .{ connection_handle.address });

    const connection = try self.allocator.create(Connection);
    connection.* = try Connection.init(self.allocator, connection_handle);
    try self.connections.append(self.allocator, connection);
    try self.thread_pool.spawn(Connection.start, .{ connection });
}

const Shutdown = extern struct {};

pub fn close(self: *Self) !void {
    
    self.open = false;

    try self.broadcast(Shutdown, .{
        .header = .shutdown,
        .body = &Shutdown {}
    });

    const self_connection = try net.tcpConnectToAddress(self.server.listen_address);
    // currently required because I know of no other way to unblock an accepting server socket
    const ClientHeader = @import("protocol").client.Header;
    var write_buffer: [64]u8 = undefined;
    var writer = self_connection.writer(&write_buffer).interface;
    try writer.writeByte(@intFromEnum(ClientHeader.connect));
    try writer.writeByte(@intFromEnum(ClientHeader.disconnect));
    self_connection.close();

    // TODO figure out how to close the connection while reading if the client does not
    // probably wait for std.net or libxev to become mature enough
    for(self.connections.items) |connection| {
        if(connection.open) {   
            try connection.close();
        }
    }
}

pub fn broadcast(self: *Self, T: anytype, message: protocol.server.Message(T)) !void {

    for(self.connections.items) |connection| {
        // TODO remove closed connections
        if(connection.open) {
            try connection.writeMessage(T, message);
        }
    }
}