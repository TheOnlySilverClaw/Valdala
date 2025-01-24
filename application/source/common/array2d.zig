const std = @import("std");
const assert = std.debug.assert;

pub fn Array2D(T: type, W: comptime_int, H: comptime_int) type {
    return struct {

        const Self = @This();

        pub const width = W;
        pub const height = H;
        pub const size = width * height;

        values: [size]T,

        pub fn ofUndefined() Self {
            return .{
                .values = undefined
            };
        }

        pub fn ofValue(value: T) Self {
            return .{
                .values = .{ value } ** size
            };
        }

        pub fn ofValues(values: [size]T) Self {
            return .{
                .values = values
            };
        }

        pub fn get(self: Self, x: usize, y: usize) T {
            
            assert(x < width);
            assert(y < height);

            const index = x + y * width;
            return self.values[index];
        }

        pub fn getWrapped(self: Self, x: usize, y: usize) T {

            const xWrapped = x % width;
            const yWrapped = y % height;
            
            const index = xWrapped + yWrapped * width;
            return self.values[index];
        }

        pub fn set(self: *Self, x: usize, y: usize, value: T) void {

            assert(x < width);
            assert(y < height);

            const index = x + y * width;
            self.values[index] = value;
        }


        pub fn setWrapped(self: *Self, x: usize, y: usize, value: T) void {

            const xWrapped = x % width;
            const yWrapped = y % height;
            
            const index = xWrapped + yWrapped * width;
            self.values[index] = value;
        }
    };
}


const expectEqual = std.testing.expectEqual;

test Array2D {

    var a = Array2D(u32, 2, 2).ofUndefined();
    a.set(0, 0, 4);
    try expectEqual(4, a.get(0, 0));

    var b = Array2D(u8, 2, 2).ofValue(1);
    try expectEqual(1, b.get(0, 0));
    try expectEqual(1, b.get(1, 0));
    try expectEqual(1, b.get(0, 1));
    try expectEqual(1, b.get(1, 1));

    b.setWrapped(3, 3, 2);
    try expectEqual(2, b.get(1, 1));


    const c = Array2D(u32, 2, 3).ofValues(.{ 1, 2, 3, 4, 5, 6 });

    try expectEqual(1, c.get(0, 0));
    try expectEqual(2, c.get(1, 0));
    try expectEqual(6, c.get(1, 2));

    try expectEqual(2, c.getWrapped(5, 0));
    try expectEqual(4, c.getWrapped(1, 4));

}