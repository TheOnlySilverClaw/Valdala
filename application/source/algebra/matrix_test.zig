const std = @import("std");
const assert = std.debug.assert;
const expectEqual = std.testing.expectEqual;

const Matrix = @import("matrix.zig").Matrix(f32);
const Matrix4x4 = Matrix.Sized(4, 4);


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