const coordinate = @import("coordinate");

pub const Position = coordinate.Position(i32);

pub const Index = u16;

pub const Orientation = enum(u4) {
    full,
    half_north,
    half_north_east,
    half_south_east
};

const State = u12;

/// A slot is what is saved directly in a Chunk grid.
/// Additional data has to be resolved through the tile registry or from a linked TileEntity
const Slot = struct {
    index: Index,
    orientation: Orientation,
    state: State
};


pub const air: Index = 0;

