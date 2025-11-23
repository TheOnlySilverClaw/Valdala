const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Gltf = @import("zgltf").Gltf;
const log = std.log.scoped(.model_loader);

const Allocator = mem.Allocator;
const LoadedMesh = @import("LoadedMesh.zig");

const Self = @This();

allocator: Allocator,
root: fs.Dir,

pub fn init(allocator: Allocator, root: fs.Dir) Self {
    return .{
        .allocator = allocator,
        .root = root
    };
}

pub fn load(self: Self, file_path: []const u8, mesh_name: []const u8) !LoadedMesh {

    const file = try self.root.openFile(file_path, .{});
    defer file.close();

    var parser = Gltf.init(self.allocator);
    defer parser.deinit();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(&read_buffer);
    const source = try reader.interface.allocRemaining(self.allocator, .unlimited);
    defer self.allocator.free(source);

    // TODO do we need to check anything before alignCast here?
    try parser.parse(@alignCast(source));
    const data = parser.data;

    const mesh_descriptor = searchMesh(data.meshes, mesh_name) orelse return error.MeshMissing;

    // we only support one buffer for now
    const mesh_buffer = data.buffers[0];
    const buffer_data = try self.loadBuffer(mesh_buffer);
    defer self.allocator.free(buffer_data);

    const positions = try self.loadAttributeData(f32, .position, parser, mesh_descriptor, buffer_data);
    const indices = try self.loadIndices(u16, parser, mesh_descriptor, buffer_data);
    
    remapPositions(positions);

    return .{
        .positions = positions,
        .indices = indices
    };
}

fn remapPositions(positions: []f32) void {

    var i: usize = 0;
    while(i < positions.len) : (i += 3) {
        
        const y = positions[i + 1];
        const z = positions[i + 2];

        positions[i + 1] = z;
        positions[i + 2] = y;
    }
}

fn loadAttributeData(self: Self, T: type, comptime tag: std.meta.Tag(Gltf.Attribute), parser: Gltf, mesh: Gltf.Mesh, buffer_data: []const u8) ![]T {
    
    // we only support one set of primitives for now
    const primitives = mesh.primitives[0];
    const accessor_index: usize = searchAttribute(primitives.attributes, tag) orelse return error.AttributeMissing;
    const accessor = parser.data.accessors[accessor_index];
    const loaded = try parser.getDataFromBufferView(T, self.allocator, accessor, buffer_data);
    return loaded;
}

fn loadIndices(self: Self, T: type, parser: Gltf, mesh: Gltf.Mesh, buffer_data: []const u8) ![]T {

    // we only support one set of primitives for now
    const primitives = mesh.primitives[0];
    const accessor_index = primitives.indices orelse return error.IndicesMissing;
    const accessor = parser.data.accessors[accessor_index];
    const loaded = try parser.getDataFromBufferView(T, self.allocator, accessor, buffer_data);
    return loaded;
}

fn loadBuffer(self: Self, descriptor: Gltf.Buffer) ![]const u8 {
    
    const uri = descriptor.uri orelse return error.BufferUriMissing;
    var file = try self.root.openFile(uri, .{});
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(&read_buffer);
    const data = try reader.interface.allocRemaining(self.allocator, .unlimited);
    return data;
}

fn searchMesh(meshes: []const Gltf.Mesh, search_name: []const u8) ?Gltf.Mesh {

    for(meshes) |mesh| {
        if(mesh.name) |found_name| {
            if(mem.eql(u8, found_name, search_name)) {
                return mesh;
            }
        }
    }
    return null;
}

fn searchAttribute(attributes: []const Gltf.Attribute, comptime tag: std.meta.Tag(Gltf.Attribute)) ?std.meta.TagPayload(Gltf.Attribute, tag) {

    for(attributes) |attribute| {
        if(std.meta.activeTag(attribute) == tag) {
            return switch (attribute) {
                tag => |index| index,
                else => null
            };
        }
    }
    return null;
}

const testing = std.testing;
const expectEqual = testing.expectEqual;

test {
    
    const allocator = testing.allocator;    
    // TODO figure out where to put a test that requires a directory with specific files
    const root = try fs.cwd().openDir("modules/valdala/entities/cube", .{});
    
    const loader = Self.init(allocator, root);
    const mesh = try loader.load("cube.gltf", "Cube");
    defer mesh.deinit(allocator);

    try expectEqual(6 * 4 * 3, mesh.positions.len);
    try expectEqual(36, mesh.indices.len);
}