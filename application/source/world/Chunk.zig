const std = @import("std");
const math = std.math;

const Block = @import("Block.zig");

pub const Position = struct {
	x: u32,
	y: u32,
	z: u32
};

pub const Width = u6;
pub const Height = u4;

const Self = @This();

pub const width = math.maxInt(Width);
pub const height = math.maxInt(Height);

blocks: [width][width][height]Block,

pub fn getBlock(self: Self, x: Width, y: Width, z: Height) Block {
	return  self.blocks[x][y][z];
}