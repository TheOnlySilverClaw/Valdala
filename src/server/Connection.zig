const std = @import("std");
const net = std.net;
const log = std.log.scoped(.connection);
const protocol = @import("protocol");

const Allocator = std.mem.Allocator;
const ClientHeader = protocol.client.Header;

const Self = @This();

allocator: Allocator,
handle: net.Server.Connection,
reader: net.Stream.Reader,
writer: net.Stream.Writer,
open: bool,

pub fn init(allocator: Allocator, handle: net.Server.Connection) !Self {
    return .{
        .allocator = allocator,
        .handle = handle,
        .reader = handle.stream.reader(),
        .writer = handle.stream.writer(),
        .open = false
    };
}

pub fn start(self: *Self) void {
    self.receive() catch |err| log.err("Connection crashed: {}", .{ err });
}

fn receive(self: *Self) !void {
    
    try self.validate();

    self.open = true;

    while(self.open) {
        const header = try self.readHeader();
        switch (header) {
            .disconnect => try self.close(),
            else => log.err("Invalid header {s}", .{ @tagName(header)})
        }
    }
}

fn validate(self: *Self) !void {
    const header = try self.readHeader();
    if(header != .connect) return error.ConnectHeaderInvalid;
}

fn readHeader(self: *Self) !ClientHeader {
    return try self.reader.readEnum(ClientHeader, .big);
}

pub fn close(self: *Self) !void {

    self.open = false;
    self.handle.stream.close();
}