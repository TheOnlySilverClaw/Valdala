const std = @import("std");
const zigimg = @import("zigimg");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Surface = @import("Surface.zig");
const Image = zigimg.ImageUnmanaged;

const Self = @This();


const pixel_format = zigimg.PixelFormat.rgba32;

allocator: Allocator,
buffer: *webgpu.Buffer,
width: u32,
height: u32,
size: u32,
timestamp: i64,
saved: bool,

pub fn capture(self: *Self, device: *webgpu.Device, texture: *webgpu.Texture, command_encoder: *webgpu.CommandEncoder) !void {

    const width = texture.getWidth();
    const height = texture.getHeight();

    const byte_size = width * height * pixel_format.channelCount();
    
    const buffer_descriptor = webgpu.BufferDescriptor {
        .label = webgpu.StringView.sized("screenshot"),
        .mapped_at_creation = 0,
        .size = byte_size,
        .usage = .{ .copy_dst = true, .map_read = true }
    };

    const buffer = device.createBuffer(&buffer_descriptor);

    const source = webgpu.TexelCopyTextureInfo {
        .texture = texture,
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = 0,
            .y = 0,
            .z = 0
        }
    };

    const destination = webgpu.TexelCopyBufferInfo {
        .buffer = buffer,
        .layout = webgpu.TexelCopyBufferLayout {
            .bytes_per_row = width * pixel_format.channelCount(),
            .rows_per_image = height,
            .offset = 0
        }
    };

    const copy_size = webgpu.Extent3D {
        .width = width,
        .height = height,
        .depth_or_array_layers = 1
    };

    command_encoder.copyTextureToBuffer(&source, &destination, &copy_size);
    
    self.width = width;
    self.height = height;
    self.size = byte_size;
    self.buffer = buffer;
    self.timestamp = std.time.milliTimestamp();
    self.saved = false;
}

pub fn deinit(self: Self) void {
    
    self.buffer.destroy();
    self.buffer.release();
}

const log = std.log.scoped(.screenshot);

pub fn save(self: *Self, allocator: *Allocator) !void {

    
    const callback_info = webgpu.BufferMapCallbackInfo {
        .mode = .wait_any_only,
        .callback = readCallback,
        .userdata1 = @ptrCast(self),
        .userdata2 = @ptrCast(allocator)
    };

    _ = self.buffer.mapAsync(.{ .read = true }, 0, self.size, callback_info);

    var tried: u32 = 0;
    while(!self.saved and tried < 10) {
        tried += 1;
        log.debug("waiting for save", .{});
        std.time.sleep(200_0000);
    }
}

fn readCallback(status: webgpu.MapAsyncStatus, message: webgpu.StringView, userdata1: ?*webgpu.UserData, userdata2: ?*webgpu.UserData) callconv(.C) void {

    const self: *Self = @ptrCast(@alignCast(userdata1));
    const allocator = @as(*Allocator, @ptrCast(@alignCast(userdata2))).*;
    _ = message;


    log.debug("map status {}", .{ status });
    if(status == .success) {
        if(self.buffer.getConstMappedRange(u8, 0, self.size)) |range| {
            self.buffer.unmap();
            var image = Image.fromRawPixels(allocator, self.width, self.height, range, pixel_format) catch |err| { log.err("{}", .{ err }); return; };
            var file = std.fs.cwd().openFile("screen.png", .{}) catch |err| { log.err("{}", .{ err }); return; };
            image.writeToFile(allocator, file, .{ .png = .{}}) catch |err| { log.err("{}", .{ err }); return; };
            file.close();
            image.deinit(allocator);
            self.saved = true;
        }
    }
}