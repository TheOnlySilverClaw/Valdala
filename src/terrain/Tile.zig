const coordinate = @import("coordinate");

pub const Position = coordinate.hexagon.Position(i64);

const Self = @This();

// TODO these should be determined by terrain type eventually, not hardcoded
pub const air = Self { .index = 0 };
pub const water = Self { .index = 1 };
pub const sand = Self { .index = 2 };
pub const topsoil = Self { .index = 3 };
pub const soil = Self { .index = 4 };
pub const rock = Self { .index = 5 };

index: u32