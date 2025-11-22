const std = @import("std");
const fs = std.fs;
const log = std.log.scoped(.entity_loader);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Yaml = @import("yaml").Yaml;
const Entity = @import("Entity.zig");
const ModelLoader = @import("ModelLoader.zig");

const Self = @This();

allocator: Allocator,
entities: List(Entity),

pub fn init(allocator: Allocator) Self {

    return .{
        .allocator = allocator,
        .entities = .empty
    };
}

pub fn deinit(self: *Self) void {

    for(self.entities.items) |entity| {
        entity.deinit(self.allocator);
    }
    self.entities.clearAndFree(self.allocator);
}

pub fn load(self: *Self, directory: fs.Dir, id: Entity.ID, descriptor: Yaml.Map) !void {

    var entity: Entity = undefined;
    entity.id = id;

    entity.name = try self.allocator.dupe(u8, descriptor.get("name").?.asScalar().?);
    
    if(descriptor.get("model")) |model| {
        switch (model) {
            .map => |map| {

                const file_path = map.get("file").?.asScalar().?;
                const mesh_name = map.get("mesh").?.asScalar().?;
                log.debug("load mesh {s} from {s}", .{ mesh_name, file_path });

                const model_loader = ModelLoader.init(self.allocator, directory);
                entity.mesh = try model_loader.load(file_path, mesh_name);
            },
            else => {}
       }
    }

    try self.entities.append(self.allocator, entity);
}
