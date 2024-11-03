const std = @import("std");
const assert = std.debug.assert;


pub fn Matrix(comptime T: type) type {

    return struct {
        
        pub fn Sized(comptime C: u32, comptime R: u32) type {

            return struct {
                
                const Self = @This();
                const length = C * R;

                values: [length]T,

                pub fn ofValue(value: T) Self {
                    return ofValues(.{ value } ** length);
                }

                pub fn ofValues(values: [length] T) Self {
                    return .{
                        .values = values
                    };
                }

                pub fn zeros() Self {
                    return .ofValue(0);
                }

                pub fn identity() Self {
                    
                    var m = zeros();
                    m.setDiagonal(.{ 1 } ** C);
                    return m;
                }

                pub inline fn get(self: Self, column: u32, row: u32) T {
                    return self.values[C * column + row];
                }

                pub inline fn set(self: *Self, column: u32, row: u32, value: T) void {
                    self.values[C * column + row] = value;
                }

                pub fn setColumn(self: *Self, column: u32, values: [C]T) void {
                    
                    inline for(0..R) |row| {
                        self.set( column, row, values[row]);
                    }
                }

                pub fn setRow(self: *Self, row: u32, values: [R]T) void {
                    
                    inline for(0..C) |column| {
                        self.set( column, row, values[column]);
                    }
                }

                pub fn setDiagonal(self: *Self, values: [C]T) void {
                    
                    inline for(0..C) |diagonal| {
                        self.set( diagonal, diagonal, values[diagonal]);
                    }
                }

                pub fn transpose(self: Self) Self {

                    var new = self;
                    inline for(0..C) |column| {
                        inline for(0..R) |row| {
                            const value = self.get(column, row);
                            new.set(row, column, value);
                        }
                    }
                    return new;
                }

                pub fn add(self: Self, other: Self) Self {

                    var new = self;
                    inline for(&new.values, self.values, other.values) |*value, a, b| {
                        value.* = a + b;
                    }
                    return new;
                }

                pub fn scale(self: Self, scalar: T) Self {

                    var new = self;
                    inline for(&new.values) |*value| {
                        value.* = scalar * value.*;
                    }
                    return new;
                }

                // TODO figure out different dimensions
                pub fn multiply(self: Self, other: Self) Self {

                    var new = self;
                    inline for(0..C) |column| {
                        inline for(0..R) |row| {
                            var sum: T = 0;
                            inline for(0..C) |i| {
                                const a = self.get(i, row);
                                const b = other.get(column, i);
                                sum += a * b;
                            }
                            new.set(column, row, sum);
                        }
                    }
                    return new;
                }

                pub fn print(self: Self) void {

                    const p = std.debug.print;

                    inline for(0..R) |row| {
                        p("( ", .{});
                        inline for(0..C-1) |column| {
                            const value = self.get(column, row);
                            p("{d: >7.4}, ", .{value});
                        }
                        const value = self.get(C-1, row);
                        p("{d: >7.4}", .{value});
                        p(" )\n", .{});
                    }
                }
            };
        }
    };
}


const expectEqual = std.testing.expectEqual;

const Matrix4x4 = Matrix(f32).Sized(4, 4);


test "zeros" {
    const m = Matrix4x4.zeros();
    try expectEqual( .{ 0 } ** 16, m.values);
}

test "identity" {
    
    const m = Matrix4x4.identity();
    try expectEqual(.{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    },m.values);
}

test "get and set single value" {
    
    var m = Matrix4x4.zeros();
    try expectEqual(m.get(0, 0), 0);

    m.set(0, 2, 4);
    try expectEqual(.{
        0, 0, 0, 0,
        0, 0, 0, 0,
        4, 0, 0, 0,
        0, 0, 0, 0
    }, m.transpose().values);
    try expectEqual(m.get(0, 2), 4);
    
    m.set(2, 0, 7);
    try expectEqual(.{
        0, 0, 7, 0,
        0, 0, 0, 0,
        4, 0, 0, 0,
        0, 0, 0, 0
    }, m.transpose().values);
    try expectEqual(m.get(2, 0), 7);
}

test "set multiple values" {
    
    var m = Matrix4x4.zeros();
    
    m.setColumn(1, .{ 1, 2, 3, 4 });
    try expectEqual(.{
        0, 1, 0, 0,
        0, 2, 0, 0,
        0, 3, 0, 0,
        0, 4, 0, 0
    }, m.transpose().values);

    m.setRow(3, .{ 5, 6, 7, 8 });
    try expectEqual(.{
        0, 1, 0, 0,
        0, 2, 0, 0,
        0, 3, 0, 0,
        5, 6, 7, 8
    }, m.transpose().values);

    m.setDiagonal(.{ 9 } ** 4);
    try expectEqual(.{
        9, 1, 0, 0,
        0, 9, 0, 0,
        0, 3, 9, 0,
        5, 6, 7, 9
    }, m.transpose().values);
}

test "add" {
    
    var m1 = Matrix4x4.zeros();
    m1.setColumn(1, .{ 1, 2, 3, 4 });
    const m2 = Matrix4x4.identity();
    const m = m1.add(m2);

    try expectEqual(.{
        1, 1, 0, 0,
        0, 3, 0, 0,
        0, 3, 1, 0,
        0, 4, 0, 1
    }, m.transpose().values);
}

test "scale" {
    
    var m = Matrix4x4.zeros();
    m.setColumn(1, .{ 1, 2, 3, 4 });
    m.setRow(1, .{ 4.5 } ** 4);
    m = m.scale(2);

    try expectEqual(.{
        0, 2, 0, 0,
        9, 9, 9, 9,
        0, 6, 0, 0,
        0, 8, 0, 0
    }, m.transpose().values);
}

test "multiply" {

    var m = Matrix4x4.ofValue(3);
    
    // try expectEqual(m, m.multiply(Matrix4x4.identity()));
    // try expectEqual(Matrix4x4.zeros(), m.multiply(Matrix4x4.zeros()));

    var o = Matrix4x4.zeros();
    o.setColumn(1, .{ 1, 2, 3, 4 });

    try expectEqual(.{
        0, 30, 0, 0,
        0, 30, 0, 0,
        0, 30, 0, 0,
        0, 30, 0, 0
    }, m.multiply(o).transpose().values);
}