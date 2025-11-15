//! Single producer single consumer queue.

const builtin = @import("builtin");
const std = @import("std");
const testing = std.testing;
const log = std.log.scoped(.scene_queue);

const Atomic = std.atomic.Value;

/// A SPSC queue.
///
/// Be sure to only call `enqueue` and `dequeue` on the producer and consumer threads, respectively.
pub fn SpscQueue(comptime T: type, comptime log2_capacity: usize) type {

    return struct {
        head: Atomic(usize) = .{ .raw = 0 },
        tail: Atomic(usize) = .{ .raw = 0 },

        buffer: [capacity]T = undefined,

        const Self = @This();

        const capacity = 1 << log2_capacity;
        const mask = capacity - 1;

        pub fn enqueue(queue: *Self, item: T) bool {

            const tail = queue.tail.load(.unordered);
            const nextTail = (tail + 1) & mask;

            if (nextTail == queue.head.load(.acquire)) {
                return false;
            }

            queue.buffer[tail] = item;
            queue.tail.store(nextTail, .release);

            return true;
        }

        pub fn dequeue(queue: *Self) ?T {

            const head = queue.head.load(.unordered);

            if (head == queue.tail.load(.acquire)) {
                return null;
            }

            const item = queue.buffer[head];
            queue.head.store((head + 1) & mask, .release);

            return item;
        }
    };
}