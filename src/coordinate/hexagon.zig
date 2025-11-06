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

            const side = width / 2.0;
            const inner = width * math.sqrt(3.0) / 2.0;
            const inradius = inner / 2.0;
            const circumradius = side;

            return .{
                .width = width,
                .inner = inner,
                .circumradius = circumradius,
                .inradius = inradius,
                .height = height,
                .side = side
            };
        }
    };
}

/// P = position component type, V = vector component type
pub fn Grid(P: type, V: type) type {

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

            const x = se * hex.side * horizontal;
            const y = n * hex.inner - se * hex.inradius;
            const z = h * hex.height;

            return Vector(V).of(x, y, z);
        }

        pub fn getHexagon(self: Self, vector: Vector(V)) Position(P) {

            const hex = self.hexagon;

            const north: P = @intFromFloat((vector.x + math.sqrt(3) * vector.y) / (3 * hex.side));
            const south_east: P = @intFromFloat((2 * vector.x) / (3 * hex.side));
            const height: P = @intFromFloat(vector.z / self.hexagon.height);

            return Position(P).of(north, south_east, height);
        }
    };
}

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

        pub fn goNorth(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north + steps, self.south_east, self.height);
        }

        pub fn goNorthEast(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north + steps, self.south_east + steps, self.height);
        }

        pub fn goSouthEast(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north, self.south_east + steps, self.height);
        }

        pub fn goSouth(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north - steps, self.south_east, self.height);
        }

        pub fn goSouthWest(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north - steps, self.south_east - steps, self.height);
        }

        pub fn goNorthWest(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north, self.south_east - steps, self.height);
        }

        pub fn goUp(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north, self.south_east, self.height + steps);
        }

        pub fn goDown(self: Position(T), steps: T) Position(T) {
            return Position(T).of(self.north, self.south_east, self.height - steps);
        }

        pub fn format(self: Position(T), writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.print("(n {}, se {}, h {})", .{ self.north, self.south_east, self.height });
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
