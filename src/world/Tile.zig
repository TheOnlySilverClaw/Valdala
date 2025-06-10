const coordinate = @import("coordinate");

pub const Position = coordinate.Position(i32, i32);

pub const Index = u16;


const State = u12;

/// A slot is what is saved directly in a Chunk grid.
/// Additional data has to be resolved through the tile registry or from a linked TileEntity
const Slot = struct {
    index: Index,
    orientation: coordinate.Orientation,
    state: State
};


pub const air: Index = 0;

