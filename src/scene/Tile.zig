const coordinate = @import("coordinate");

pub const Type = u16;

const Self = @This();


pub const empty = Self {
    .index = 0,
    .orientation = .full
};

index: Type,
orientation: coordinate.Orientation
