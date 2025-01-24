const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn Grid2D(T: type) type {
    return struct {

        const Self = @This();
        
        width: usize,
        height: usize,
        values: []T,

        pub fn fromSlice(values: []T, width: usize, height: usize) Self {
            return .{
                .width = width,
                .height = height,
                .values = values
            };
        }

        pub fn init(allocator: Allocator, width: usize, height: usize) Allocator.Error!Self {

            const values = try allocator.alloc(T, width * height);
            return .{
                .width = width,
                .height = height,
                .values = values
            };
        }

        pub fn deinit(self: Self, allocator: Allocator) void {
            allocator.free(self.values);
        }

        pub fn size(self: Self) usize {
            return self.width * self.height;
        }

        pub fn get(self: Self, x: usize, y: usize) T {
            
            assert(x < self.width);
            assert(y < self.height);

            const index = x + y * self.width;
            return self.values[index];
        }

        pub fn getWrapped(self: Self, x: usize, y: usize) T {

            const xWrapped = x % self.width;
            const yWrapped = y % self.height;
            
            const index = xWrapped + yWrapped * self.width;
            return self.values[index];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {

            assert(x < self.width);
            assert(y < self.height);

            const index = x + y * self.width;
            self.values[index] = value;
        }


        pub fn setWrapped(self: *Self, x: usize, y: usize, value: T) void {

            const xWrapped = x % self.width;
            const yWrapped = y % self.height;
            
            const index = xWrapped + yWrapped * self.width;
            self.values[index] = value;
        }
    };
}

const testing = std.testing;
const expectEqual = testing.expectEqual;

test Grid2D {

    const allocator = testing.allocator;
    var l = try Grid2D(u32).init(allocator, 2, 2);
    defer l.deinit(allocator);

    try expectEqual(4, l.size());
}