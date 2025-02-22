const std = @import("std");
const log = std.log;
const time = std.time;
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const graphics = @import("graphics");
const input = @import("input");

const Allocator = std.mem.Allocator;
const Window = input.Window;
const UserInterface = graphics.UserInterface;

const Self = @This();

allocator: Allocator,
window: *Window,
targetFrameTime: u64,
lastFrameEndTime: i64 = undefined,
userInterface: UserInterface,

pub fn init(allocator: Allocator, targetFrameRate: u64) !Self {

    const targetFrameTime = time.ms_per_s / targetFrameRate;

    var window = try allocator.create(Window);
    try window.create("Valdala", 1600, 1200);

    const userInterface = try UserInterface.init(allocator, undefined, &window.surface);

    return .{
        .allocator = allocator,
        .window = window,
        .targetFrameTime = targetFrameTime,
        .userInterface = userInterface
    };
}

pub fn deinit(self: *Self) void {

    self.userInterface.deinit();

    self.window.destroy();
    self.allocator.destroy(self.window);
}

pub fn start(self: *Self) !void {

    self.lastFrameEndTime = time.milliTimestamp();

    while(self.window.shouldClose() == false) {
        glfw.pollEvents();
        try self.renderFrame();
    }
}

fn renderFrame(self: *Self) !void {

    const frameStartTime = time.milliTimestamp();
    const frameDeltaTime: u64 = @intCast(frameStartTime - self.lastFrameEndTime);

    try self.renderApplication(frameDeltaTime);

    const currentFrameTime: u64 = @intCast(time.milliTimestamp() - frameStartTime);
    self.lastFrameEndTime = time.milliTimestamp();

    if(currentFrameTime < self.targetFrameTime) {
        const sleepTime = self.targetFrameTime - currentFrameTime;
        time.sleep(sleepTime * time.ns_per_ms);
    } else {
        log.warn("Frame rendering took {d} ms", .{ currentFrameTime });
    }
}

fn renderApplication(self: *Self, delta: u64) !void {

    if(delta == 0) return;

    try self.userInterface.render(delta);

}