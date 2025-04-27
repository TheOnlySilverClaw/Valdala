const std = @import("std");
const fs = std.fs;
const log = std.log;

const umka = @import("umka");

const Allocator = std.mem.Allocator;
const List = std.ArrayList;

const Self = @This();

const file_extension = ".um";

allocator: Allocator,
path: [*:0]const u8,
instance: umka.Instance,

pub fn init(allocator: Allocator, path: [*:0]const u8) !Self {

	log.debug("Load module {s}", .{ path });

	var instance = try umka.Instance.alloc(path, null, 1024 * 64, &.{}, false, false, null);

	instance.compile() catch {
		const err = instance.getError();
		log.err("Umka compiler error: {s}", .{ err.msg });
	};

	log.debug("assembly: \n{s}", .{ instance.assembly() });

	var blub = umka.Function.new(null, "blub");
	try blub.get(instance);
	try blub.call();
	const result = blub.getResult().int;
	log.debug("result: {}", .{ result });

	return .{
		.allocator = allocator,
		.path = path,
		.instance = instance
	};
}

