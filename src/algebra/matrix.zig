const std = @import("std");
const fmt = std.fmt;
const math = std.math;

pub fn Matrix(comptime T: type, comptime columns: u32, comptime rows: u32) type {

    return struct {

        const Self = @This();

        pub const C = columns;
        pub const R = rows;


        pub const zero = all(0);
        pub const identity = diagonal(.{ 1 } ** C);

        const length = C * R;

        values: [C * R]T,

        /// Specify in COLUMN MAJOR
        pub fn of(values: [length] T) Self {
            return .{ .values = values };
        }
        
        pub fn all(value: T) Self {
            return of(.{ value } ** length);
        }

        pub fn diagonal(values: [C]T) Self {
            
            comptime if(!isQuadratic()) @compileError("Matrix must be quadratic");

            var m = zero;
            m.setDiagonal(values);
            return m;
        }

        fn indexOf(column: u32, row: u32) usize {
            return R * column + row;
        }

        pub fn get(self: Self, column: u32, row: u32) T {
            return self.values[indexOf(column, row)];
        }

        pub fn set(self: *Self, column: u32, row: u32, value: T) void {
            self.values[indexOf(column, row)] = value;
        }

        pub fn setColumn(self: *Self, column: u32, values: [R]T) void {

            inline for(0..R) |row| {
                self.set( column, row, values[row]);
            }
        }

        pub fn setRow(self: *Self, row: u32, values: [C]T) void {

            inline for(0..C) |column| {
                self.set( column, row, values[column]);
            }
        }

        pub fn setDiagonal(self: *Self, values: [C]T) void {

            comptime if(!isQuadratic()) @compileError("Matrix must be quadratic");

            inline for(0..C) |d| {
                self.set( d, d, values[d]);
            }
        }

        pub fn isQuadratic() bool {
            return C == R;
        }

        pub fn transpose(self: Self) Self {

            comptime if(!isQuadratic()) @compileError("Matrix must be quadratic");

            var new: Self = undefined;
            inline for(0..R) |row| {
                inline for(0..C) |column| {
                    const value = self.get(column, row);
                    new.set(row, column, value);
                }
            }
            return new;
        }

        pub fn add(self: Self, other: Self) Self {

            var new: Self = undefined;
            inline for(&new.values, self.values, other.values) |*value, a, b| {
                value.* = a + b;
            }
            return new;
        }

        pub fn substract(self: Self, other: Self) Self {
            return self.add(other.times(-1));
        }

        pub fn times(self: Self, scalar: T) Self {

            var new: Self = undefined;
            inline for(&new.values, self.values) |*value, v| {
                value.* = v * scalar;
            }
            return new;
        }

        pub fn multiply(self: Self, other: anytype) Matrix(T,@TypeOf(other).C, R) {

            const Other = @TypeOf(other);
            comptime if(Self.C != Other.R) @compileError("Columns of self must equal rows of other");

            var new: Matrix(T, Other.C, R) = undefined;

            inline for(0..R) |row| {
                inline for(0..Other.C) |column| {
                    var sum: T = 0;
                    inline for(0..C) |i| {
                        const a = self.get(i, row);
                        const b = other.get(column, i);
                        sum = sum + a * b;
                    }
                    new.set(column, row, sum);
                }
            }
            return new;
        }

        pub fn format(self: Self, writer: *std.Io.Writer) std.Io.Writer.Error!void {

            const options = fmt.float.Options {
                .mode = .decimal,
                .precision = 4
            };

            const buffer_size = fmt.float.bufferSize(.decimal, T);
            var buffer: [buffer_size]u8 = undefined;

            inline for(0..R) |row| {
                _ = try writer.write("( ");

                inline for(0..C-1) |column| {
                    const value = self.get(column, row);
                    const slice = fmt.float.render(&buffer, value, options) catch return std.Io.Writer.Error.WriteFailed;
                    _ = try writer.write(slice);
                    _ = try writer.write(", ");
                }

                const value = self.get(C-1, row);
                const slice = fmt.float.render(&buffer, value, options) catch return std.Io.Writer.Error.WriteFailed;
                _ = try writer.write(slice);
                _ = try writer.write(" )\n");
            }
        }
    };
}

const Mat2 = Matrix(f32, 2, 2);
const testing = std.testing;
const tolerance = math.floatEps(f32);

test "add" {
    
    const a = Mat2.identity;
    const b = Mat2.all(1);
    const c = a.add(b);
    
    try testing.expectApproxEqAbs(2, c.get(0, 0), tolerance);
    try testing.expectApproxEqAbs(1, c.get(1, 0), tolerance);
    try testing.expectApproxEqAbs(1, c.get(0, 1), tolerance);
    try testing.expectApproxEqAbs(2, c.get(1, 1), tolerance);
}

test "subtract" {

    const a = Mat2.identity;
    const b = Mat2.all(1);
    const c = a.substract(b);

    try testing.expectApproxEqAbs(0, c.get(0, 0), tolerance);
    try testing.expectApproxEqAbs(-1, c.get(1, 0), tolerance);
    try testing.expectApproxEqAbs(-1, c.get(0, 1), tolerance);
    try testing.expectApproxEqAbs(0, c.get(1, 1), tolerance);
}

test "multiply quadratic" {

    const a = Mat2.of(.{ 1, 2, 3, 4 });
    const b = Mat2.all(1);
    const c = a.multiply(b);

    try testing.expectApproxEqAbs(4, c.get(0, 0), tolerance);
    try testing.expectApproxEqAbs(4, c.get(1, 0), tolerance);
    try testing.expectApproxEqAbs(6, c.get(0, 1), tolerance);
    try testing.expectApproxEqAbs(6, c.get(1, 1), tolerance);
}

test "multiply different shapes" {

    const Mat4x2 = Matrix(f32, 4, 2);
    const Matx2x4 = Matrix(f32, 2, 4);

    const a = Mat4x2.of(.{ 1, 2, 3, 4, 5, 6, 7, 8 });
    const b = Matx2x4.all(1);
    const c = a.multiply(b);

    try testing.expectEqual(2, @TypeOf(c).C);
    try testing.expectEqual(2, @TypeOf(c).R);

    try testing.expectApproxEqAbs(16, c.get(0, 0), tolerance);
    try testing.expectApproxEqAbs(16, c.get(1, 0), tolerance);
    try testing.expectApproxEqAbs(20, c.get(0, 1), tolerance);
    try testing.expectApproxEqAbs(20, c.get(1, 1), tolerance);
}