const std = @import("std");
const math = std.math;
const common = @import("common");

const List = std.ArrayListUnmanaged;
const Allocator = std.mem.Allocator;
const Point2D = common.Point2D;
const Grid2D = common.Grid2D;
const Random2D = common.Random2d;

pub const HeightMap = struct {

    allocator: Allocator,
    seed: u64,
    width: u32,
    height: u32,
    grid: Grid2D(u8),
    random: Random2D,

    pub fn init(allocator: Allocator, width: u32, height: u32, seed: u64) Allocator.Error!HeightMap {
        
        const grid = try Grid2D(u8).init(allocator, width, height);

        return .{
            .allocator = allocator,
            .seed = seed,
            .width = width,
            .height = height,
            .random = Random2D.new(seed),
            .grid = grid
        };
    }

    pub fn deinit(self: HeightMap) void {
        self.grid.deinit(self.allocator);
    }

    pub fn randomize(self: *HeightMap) void {

        for(0..self.width) |x| {
            for(0..self.height) |y| {
                const r: u8 = @truncate(self.random.get(x, y));
                self.grid.set(x, y, r);
            }
        }
    }

    pub fn generateMountains(self: *HeightMap) Allocator.Error!void {

        const amount: u32 = 16;
        std.debug.print("# of mountains {d}\n", .{amount});

        var summits = try List(Point2D(u32)).initCapacity(self.allocator, amount);
        defer summits.deinit(self.allocator);

        for(0..amount) |s| {
            const r: [2]u32 = @bitCast(self.random.get(s, s));
            const point = Point2D(u32) {
                .x = r[0] % self.width,
                .y = r[1] % self.height
            };
            summits.appendAssumeCapacity(point);
        }

        const widthF: f32 = @floatFromInt(self.width);
        const heightF: f32 = @floatFromInt(self.height);
        const amountF: f32 = @floatFromInt(amount);
        const summitFactor = math.sqrt(amountF);

        for(0..self.width) |x| {
            
            const xf: f32 = @floatFromInt(x);
            
            for(0..self.height) |y| {

                const yf: f32 = @floatFromInt(y);

                var pointHeight: f32 = 0;

                for(summits.items) |summit| {
                    
                    const xfs: f32 = @floatFromInt(summit.x);
                    const yfs: f32 = @floatFromInt(summit.y);

                    const summitHeight: u8 = @truncate(self.random.get(summit.x, summit.y));
                    const summitHeightf: f32 = @floatFromInt(summitHeight);

                    const xdist = math.pow(f32, xf - xfs, 2) / widthF;
                    const ydist = math.pow(f32, yf - yfs, 2) / heightF;
                    const distance = math.sqrt(xdist + ydist);
                    
                    var weightedHeight: f32 = 0;
                    if(distance < 1e-5) {
                        weightedHeight = summitHeightf;
                    } else if (distance < @as(f32, @floatFromInt(amount))) {
                        weightedHeight = summitHeightf / distance;
                    }
                    pointHeight += weightedHeight;
                }
                const scaledHeight: u8 = @intFromFloat(@min(math.maxInt(u8), pointHeight / summitFactor));
                self.grid.set(x, y, scaledHeight);            
            }
        }
    }
};


const testing = std.testing;

test HeightMap {

    var hm = try HeightMap.init(testing.allocator, 40, 30);
    defer hm.deinit();
    
    try hm.generateMountains();
}