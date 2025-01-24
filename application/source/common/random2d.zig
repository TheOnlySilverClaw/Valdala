const std = @import("std");
const assert = std.debug.assert;

const magic_prime: u64 = 16492986069509280893;

pub const Random2D = struct {
    seed: u64,

    pub fn new(seed: u64) Random2D {
        return .{
            .seed = seed,
        };
    }

    pub fn get(self: Random2D, x: usize, y: usize) u64 {

        const seeded: u64 = @mulWithOverflow(x ^ magic_prime, y ^ self.seed)[0];
        const shifted = xorshift(seeded);
        return shifted;
    }

    fn xorshift(value: u64) u64 {

        var shifted = value;
        shifted ^= shifted << 13;
        shifted ^= shifted >> 7;
        shifted ^= shifted << 17;
        return shifted;
    }
};


const expectEqual = std.testing.expectEqual;

test Random2D {

    const random = Random2D.new(@intCast(std.time.milliTimestamp()));
    const size = 10;

    for(0..size) |x| {
        for(0..size) |y| {
            try expectEqual(random.get(x, y), random.get(x, y));
        }
    }
}