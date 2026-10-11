const std = @import("std");
const c = @import("c");
const index = @import("CFIndex.zig");

pub const CFRange = c.CFRange;

pub fn init(location: usize, length: usize) error{InputTooLong}!CFRange {
    const start = try index.fromUsize(location);
    const count = try index.fromUsize(length);
    _ = std.math.add(c.CFIndex, start, count) catch return error.InputTooLong;
    return .{ .location = start, .length = count };
}
