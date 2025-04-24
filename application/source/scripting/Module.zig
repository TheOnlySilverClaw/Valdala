const std = @import("std");
const fs = std.fs;
const log = std.log;

const umka = @import("umka");

const Allocator = std.mem.Allocator;
const List = std.ArrayList;

const Self = @This();

const file_extension = ".um";

allocator: Allocator,
path: []const u8,
instance: umka.Instance,

pub fn init(allocator: Allocator, path: []const u8, root: [*:0]const u8) !Self {

	log.debug("Load module {s}", .{ path });

	var source_buffer: [1024 * 16]u8 = undefined;

	// TODO should probably pick one file as the entry point module?
	var directory = try fs.cwd().openDir(path, .{
		.access_sub_paths = true,
		.iterate = true,
		.no_follow = true
	});

	// TODO figure out string conversions...
	var root_file = try directory.openFile("foo.um", .{});
	const root_source_length = try root_file.reader().readAll(&source_buffer);
	root_file.close();
	source_buffer[root_source_length] = 0;

	var instance = try umka.Instance.alloc(root, @ptrCast(source_buffer[0..root_source_length + 1]), 1024 * 16, &.{}, false, false, null);

	var iterator = directory.iterateAssumeFirstIteration();
	while(try iterator.next()) |entry| {
		// TODO figure out loading of other files
		if(false and entry.kind == .file and std.mem.eql(u8, fs.path.extension(entry.name), file_extension)) {

			var file = try directory.openFile(entry.name, .{});
			const source_length = try file.reader().readAll(&source_buffer);
			file.close();
			source_buffer[source_length] = 0;

			const module_name = try allocator.alloc(u8, entry.name.len + 1);
			std.mem.copyForwards(u8, module_name, entry.name);
			module_name[entry.name.len] = 0;

			log.debug("add module {s}\n{s}", .{ entry.name, source_buffer[0..source_length + 1] });
			try instance.addModule(@ptrCast(module_name), @ptrCast(source_buffer[0..source_length + 1]));
			// allocator.free(module_name);

		}
	}

	instance.compile() catch {
		const err = instance.getError();
		log.err("Umka compiler error: {s}", .{ err.msg });
	};

	log.debug("assembly: \n{s}", .{ instance.assembly() });

	var blub = umka.Function.new("foo.um", "blub");
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

