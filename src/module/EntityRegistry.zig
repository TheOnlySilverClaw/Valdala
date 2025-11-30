const std = @import("std");
const fs = std.fs;
const graphics = @import("graphics");
const Model = @import("gltf/Model.zig");
const log = std.log.scoped(.entity_loader);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Yaml = @import("yaml").Yaml;
const Entity = @import("Entity.zig");
const ModelLoader = @import("gltf/Loader.zig");
const TextureList = graphics.TextureList;
const Self = @This();

allocator: Allocator,
entities: List(Entity),
texture_list: TextureList,

pub fn init(allocator: Allocator, texture_list: TextureList) Self {

    return .{
        .allocator = allocator,
        .entities = .empty,
        .texture_list = texture_list
    };
}

pub fn deinit(self: *Self) void {

    for(self.entities.items) |*entity| {
        entity.deinit(self.allocator);
    }
    self.entities.clearAndFree(self.allocator);
    self.texture_list.deinit();
}

pub fn load(self: *Self, directory: fs.Dir, id: Entity.ID, descriptor: Yaml.Map) !void {

    var entity: Entity = undefined;
    entity.id = id;

    entity.name = try self.allocator.dupe(u8, descriptor.get("name").?.asScalar().?);
    
    if(descriptor.get("model")) |model_descriptor| {
        switch (model_descriptor) {
            .map => |map| {

                const file_path = map.get("file").?.asScalar().?;
                const node_name = map.get("node").?.asScalar().?;
                log.debug("load model for entity {s} at node {s} from {s}", .{ id, node_name, file_path });

                var model_loader = ModelLoader.init(self.allocator);
                const model = try model_loader.load(directory, file_path);
                entity.model = model;
                const node = searchNode(&model, node_name) orelse return error.EntityNodeMissing;
                entity.node = node;
            },
            else => {}
       }
    }

    try self.entities.append(self.allocator, entity);
}

fn searchNode(model: *const Model, node_name: []const u8) ?*const Model.Node {

    for(model.nodes) |*node| {
        if(node.name) |name| {
            log.debug("checking node {s}", .{ name });
            if(std.mem.eql(u8, name, node_name)) {
                return node;
            }
        }
    }
    return null;
}