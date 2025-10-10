const std = @import("std");
const net = std.net;
const log = std.log.scoped(.connection);
const protocol = @import("protocol");
const color = @import("color");

const Allocator = std.mem.Allocator;
const ClientHeader = protocol.client.Header;

const Self = @This();

allocator: Allocator,
handle: net.Server.Connection,
read_buffer: []u8,
write_buffer: []u8,
reader: net.Stream.Reader,
writer: net.Stream.Writer,
open: bool,

pub fn init(allocator: Allocator, handle: net.Server.Connection) !Self {

    const read_buffer = try allocator.alloc(u8, 1024);
    const write_buffer = try allocator.alloc(u8, 1024);

    return .{
        .allocator = allocator,
        .handle = handle,
        .read_buffer = read_buffer,
        .reader = handle.stream.reader(read_buffer),
        .write_buffer = write_buffer,
        .writer = handle.stream.writer(write_buffer),
        .open = false
    };
}

pub fn start(self: *Self) void {
    self.receive() catch |err| log.err("Connection crashed: {}", .{ err });
}

pub fn close(self: *Self) !void {

    self.open = false;
    self.handle.stream.close();
}

pub fn writeMessage(self: *Self, T: anytype, message: protocol.server.Message(T)) !void {
    
    var writer = self.writer.interface;
    
    try writer.writeByte(@intCast(@intFromEnum(message.header)));   
    try writer.writeStruct(message.body.*, .big);
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
    var reader = self.reader.interface();
    return try reader.takeEnum(ClientHeader, .big);
}
