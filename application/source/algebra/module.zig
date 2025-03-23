pub const vector = @import("vector.zig");
pub const matrix = @import("matrix.zig");
pub const Quaternion = @import("quaternion.zig").Quaternion;
pub const Transform = @import("transform.zig").Transform;

const std = @import("std");

pub fn formatGeneric(
    self: anytype,
    comptime T: type,
    C: comptime_int,
    R: comptime_int,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    const is_float = switch (@typeInfo(T)) {
        .float => true,
        .int => false,
        else => @compileError("Unsupported type for formatting: " ++ @typeName(T)),
    };
    const ff = std.fmt.format_float;
    const valueOptions = ff.FormatOptions{ .mode = .decimal, .precision = options.precision };
    var buffer: [ff.min_buffer_size]u8 = undefined;
    var column_widths: [C]usize = [_]usize{0} ** C;
    for (0..R) |row| {
        for (0..C) |column| {
            const array: [C][R]T = @bitCast(self);
            const value = array[column][row];
            var slice: []const u8 = undefined;
            if (is_float) {
                slice = try std.fmt.formatFloat(&buffer, value, valueOptions);
            } else {
                slice = try std.fmt.bufPrint(&buffer, "{}", .{value});
            }
            column_widths[column] = @max(column_widths[column], slice.len);
        }
    }
    for (0..R) |row| {
        _ = try writer.write("[ ");
        for (0..C) |column| {
            const array: [C][R]T = @bitCast(self);
            const value = array[column][row];
            var slice: []const u8 = undefined;
            if (is_float) {
                slice = try std.fmt.formatFloat(&buffer, value, valueOptions);
            } else {
                slice = try std.fmt.bufPrint(&buffer, "{}", .{value});
            }
            _ = try writer.write(slice);
            const padding = column_widths[column] - slice.len;
            var pad_buffer: [32]u8 = [_]u8{' '} ** 32;
            _ = try writer.write(pad_buffer[0..padding]);
            if (column < C - 1) {
                _ = try writer.write("  "); // Add space between columns
            }
        }
        _ = try writer.write(" ]\n");
    }
}
