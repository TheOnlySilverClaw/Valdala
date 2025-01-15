const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const mem = std.mem;
const Allocator = mem.Allocator;

var random = std.Random.Xoroshiro128.init(3317654327567659);


pub const HeightMap = struct {

    seed: u64,
    width: u32,
    height: u32,
    values: []u16,


    pub fn init(allocator: Allocator, width: u32, height: u32, seed: u64) !HeightMap {

        assert(width > 0);
        assert(height > 0);

        return .{
            .seed = seed,
            .width = width,
            .height = height,
            .values = try allocator.alloc(u16, width * height)
        };
    }

    pub fn deinit(self: HeightMap, allocator: Allocator) void {
        allocator.free(self.values);
    }

    pub fn fromPoints(allocator: Allocator, size: u32, seed: u64) !HeightMap {

        var map = try HeightMap.init(allocator, size, size, seed);

        const amount = @max(3, math.log2(size) * 4);
        var points = try allocator.alloc([3]u16, amount);
        defer allocator.free(points);

        for(0..amount) |p| {
            const rotatedSeed = math.rotr(u64, seed, p);
            const split: [4]u16 = @bitCast(rotatedSeed);
            const point: [3]u16 = .{ @truncate(split[0] % size), @truncate(split[1] % size), split[2]};
            points[p] = point;
        }

        for(0..size) |x| {
            for(0..size) |y| {
                var sum: u32 = 0;
                for(points) |point| {
                    const distance: u32 = math.sqrt(
                        @abs(math.pow(i32, @as(i32, @intCast(x)) - point[0], 2)) +
                        @abs(math.pow(i32, @as(i32, @intCast(y)) - point[1], 2))
                    );
                    if(distance != 0) {
                        sum += @min(point[2] / distance, 2500);
                    } else {
                        sum += point[2];
                    }
                }
                map.set(@intCast(x), @intCast(y), @truncate(sum / points.len));
            }
        }

        return map;

    }

    pub fn fromDiamondSquare(allocator: Allocator, size: u32, seed: u64) !HeightMap {

        var map = try HeightMap.init(allocator, size, size, seed);

        for(0..size) |s| {

            const rotatedSeed = math.rotr(u64, @intCast(seed), s);

            const seedBytes: [4]u16 = @bitCast(rotatedSeed);

            const i: u32 = @intCast(s);
            map.set(0, i, seedBytes[0]);
            map.set(i, 0, seedBytes[1]);
            map.set(size - 1, i, seedBytes[2]);
            map.set(i, size - 1, seedBytes[3]);
        }

        // const steps = math.log2(@min(map.width, map.height));

        var scale: f32 = 1;
        const h = 0.2;

        for(0..7) |step| {

            std.debug.print("scale {d}\n", .{scale});

            const stepLength = size / (math.pow(u32, 2, @intCast(step + 1)));

            // // diamond
            var xd: u32 = 0;
            while(xd + stepLength + 1 < size) {
                xd += stepLength;
                
                var yd: u32 = 0;
                while(yd + stepLength + 1 < size) {
                    yd += stepLength;
                    
                    const p1: u32 = map.getWrapped(xd - stepLength, yd - stepLength);
                    const p2: u32 = map.getWrapped(xd + stepLength, yd - stepLength);
                    const p3: u32 = map.getWrapped(xd - stepLength, yd + stepLength);
                    const p4: u32 = map.getWrapped(xd + stepLength, yd + stepLength);
                    const r: f32 = @floatFromInt(@as(u16, @truncate(random.next())));
                    const sc: u32 = @intFromFloat(scale * r);
                    // std.debug.print("sc {d}\n", .{sc});
                    const v: u64 = (p1 + p2 + p3 + p4) / 4 + sc;
                    map.set(xd, yd, @truncate(v));
                }
            }

            // square
            var xs: u32 = 0;
            while(xs + stepLength + 1 < size) {
                xs += stepLength;
                
                var ys: u32 = 0;
                while(ys + stepLength + 1 < size) {
                    ys += stepLength;
                    
                    const p1: u32 = map.getWrapped(xs - stepLength, ys);
                    const p2: u32 = map.getWrapped(xs + stepLength, ys);
                    const p3: u32 = map.getWrapped(xs, ys - stepLength);
                    const p4: u32 = map.getWrapped(xs, ys + stepLength);
                    const r: f32 = @floatFromInt(@as(u16, @truncate(random.next())));
                    const sc: u32 = @intFromFloat(scale * r);
                    const v: u64 = (p1 + p2 + p3 + p4) / 4 + sc;
                    map.set(xs, ys, @truncate(v));
                }
            }
            
            scale *= math.pow(f32, 2, -h);
        }

        return map;

    }

    pub fn get(self: HeightMap, x: u32, y: u32) u16 {
        
        assert(x < self.width);
        assert(y < self.height);
        return self.values[x + y * self.width];
    }

    pub fn getWrapped(self: HeightMap, x: u32, y: u32) u16 {
        
        const wx = x % self.width;
        const wy = y % self.height;
        return self.get(wx, wy);
    }

    pub fn set(self: *HeightMap, x: u32, y: u32, value: u16) void {
        self.values[(x + y * self.width)] = value;
    }

    pub fn setWrapped(self: *HeightMap, x: u32, y: u32, value: u16) void {

        const wx = x % self.width;
        const wy = y % self.height;
        self.set(wx, wy, value);
    }

    pub fn print(self: HeightMap) void {

        for(0..self.width) |x| {
            for(0..self.height) |y| {
                std.debug.print("{d: >8} ", .{ self.get(@intCast(x), @intCast(y)) });
            }
            std.debug.print("\n", .{});
        }
    }
};


pub fn generate(allocator: Allocator) !void {

    var hm1 = try HeightMap.fromPoints(allocator, 400, @intCast(random.next()));
    var hm2 = try HeightMap.fromDiamondSquare(allocator, 400, @intCast(random.next()));

    defer hm1.deinit(allocator);
    defer hm2.deinit(allocator);

    const Image = @import("zigimg").ImageUnmanaged;
    
    var pixels = try allocator.alloc(u8, 3 * hm1.values.len);
    for(0..hm1.values.len) |v| {
        const h: u8 = @truncate(hm1.values[v]);
        pixels[v * 3] = @truncate(hm2.values[v] / 400);
        pixels[v * 3 + 1] = h;
        pixels[v * 3 + 2] = @truncate(hm2.values[v] / 100);
    }

    var image = try Image.fromRawPixelsOwned(hm1.width, hm1.height, pixels, .rgb24);
    try image.writeToFilePath(allocator, "height.png", .{.png = .{}});
    image.deinit(allocator);

}