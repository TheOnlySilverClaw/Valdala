const std = @import("std");
const math = std.math;
const algebra = @import("algebra");

const Vector = algebra.Vector3;


pub fn Hexagon(T: type) type {

    
    if(@typeInfo(T) != .float) @compileError("Hexgon sizes must be floats");
    
    return struct {
        const Self = @This();

        /// distance between outer points
        width: T,
        // distance between inner points
        inner: T,
        /// distance from center to outer points
        circumradius: T,
        /// distance from center to inner points
        inradius: T,
        height: T,
        /// side lengths
        // equal to circumradius, just here for convenience
        side: T,


        pub fn new(width: T, height: T) Self {

            const circumradius = width / 2.0;
            const inner = width * math.sqrt(3.0) / 2.0;
            const inradius = inner / 2.0;

            return .{
                .width = width,
                .inner = inner,
                .circumradius = circumradius,
                .inradius = inradius,
                .height = height,
                .side = circumradius
            };
        }
    };
}

/// P = position component type, V = vector component type
pub fn Grid(P: type, V: type) type {

    const gap = 0.0;
    
    return struct {

        const Self = @This();

        const horizontal: V = 3.0 / 2.0;

        hexagon: Hexagon(V),

        pub fn of(hexagon: Hexagon(V)) Self {
            return .{ .hexagon = hexagon };
        }

        pub fn getCenter(self: Self, position: Position(P)) Vector(V) {

            const hex = self.hexagon;

            const n: V = @floatFromInt(position.north);
            const se: V = @floatFromInt(position.south_east);
            const h: V = @floatFromInt(position.height);

            const x = se * hex.side * 3.0 / 2.0;
            const y = n * hex.inner - se * hex.inradius;
            const z = h * hex.height;

            return Vector(V).of(x, y, z).times(1 + gap);
        }
    };
}

/// P = plane coordinate type, H = height coordinate type
pub fn Position(T: type) type {
    
    if(@typeInfo(T) != .int) @compileError("Grid positions must be integers");

    return struct {

        /// North axis
        north: T,
        /// South-East axis
        south_east: T,
        /// height
        height: T,

        pub fn of(north: T, south_east: T, height: T) Position(T) {
            return .{
                .north = north,
                .south_east = south_east,
                .height = height
            };
        }
    };
}

pub const Orientation = enum(u4) {
    full,
    half_north,
    half_north_east,
    half_south_east
};
    

const testing = std.testing;
const tolerance = math.floatEps(f32);

test "define hexagon" {

    const hex = Hexagon(f32).new(0.25, 0.25);

    try testing.expectEqual(0.125, hex.circumradius);
    try testing.expectEqual(0.108253175, hex.inradius);
    try testing.expectEqual(0.25, hex.height);
    try testing.expectEqual(0.125, hex.side);
    try testing.expectEqual(0.216506351, hex.inner);

}

test "grid to world positions" {
    
    const hex = Hexagon(f32).new(0.25, 0.25);
    const grid = Grid(i32, f32).of(hex);

    var c = grid.getCenter(Position(i32).of(0, 0, 0));

    try testing.expectEqual(0, c.x);
    try testing.expectEqual(0, c.y);
    try testing.expectEqual(0, c.z);

    c = grid.getCenter(Position(i32).of(1, 0, 0));

    try testing.expectEqual(0, c.x);
    try testing.expectEqual(0.216506351, c.y);
    try testing.expectEqual(0, c.z);

    c = grid.getCenter(Position(i32).of(0, 0, 1));

    try testing.expectEqual(0, c.x);
    try testing.expectEqual(0, c.y);
    try testing.expectEqual(0.25, c.z);

    c = grid.getCenter(Position(i32).of(0, 1, 0));

    try testing.expectEqual(0, c.x);
    try testing.expectEqual(0, c.y);
    try testing.expectEqual(0, c.z);

}